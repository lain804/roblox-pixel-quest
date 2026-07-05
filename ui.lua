while not PQ or not PQ.Loaded do
    task.wait()
end

local UserInputService = game:GetService("UserInputService")
UserInputService.MouseIconEnabled = true

local KillAuraMode = {
    single = 1,
    multi = 2,
    adaptive = 3
}

local GodmodeMode = {
    FULL = 1,
    LEGIT = nil,
    PREVENT_DEATH_ONLY = nil
}

local AntiStaffMode = {
    notify = 1,
    leave = 2
}

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/lain804/luaui/refs/heads/master/main.lua"))()

-- The window and all of its controls are authored at fixed "design" pixel sizes
-- (640x460 window, 480x340 / 820x620 resize bounds) tuned for a 1920x1080 screen.
-- Resolution independence is achieved with a single UIScale (added below) that
-- multiplies the whole UI -- window, rows AND text -- by the player's screen height
-- relative to that 1080p reference, so it looks proportional on phones and 4K alike.
local DESIGN_HEIGHT = 1080

local Library = UI.new({
    Title = "discord.gg/hS7xx7pFBs",
    Size = UDim2.fromOffset(640, 460),
    Position = UDim2.new(0, 100, 0, 100),
    GuiName = "discord.gg/hS7xx7pFBs",
    ConfigFile = "PixelQuestUI.json",
    ConfigFolder = "PixelQuest",
    AutoSave = true,
    AutoLoad = true,
    KeyCode = Enum.KeyCode.RightShift,
    -- design-space bounds; the UIScale scales the rendered size on top of these
    MinSize = Vector2.new(480, 340),
    MaxSize = Vector2.new(820, 620)
})

-- Scale the entire UI by the player's screen height vs the 1080p design reference.
-- Clamped so it never gets unusably tiny on small phones or absurdly huge on 4K.
local function computeUiScale()
    local camera = workspace.CurrentCamera
    local height = (camera and camera.ViewportSize.Y > 1) and camera.ViewportSize.Y or DESIGN_HEIGHT
    return math.clamp(height / DESIGN_HEIGHT, 0.7, 1.6)
end

local UiScale = Instance.new("UIScale")
UiScale.Scale = computeUiScale()
UiScale.Parent = Library.MainFrame

-- The library's resize handler reads MainFrame.AbsoluteSize (already multiplied by
-- UiScale) and feeds it straight back into SetSize, which would compound the scale
-- on every drag. Divide the incoming pixel sizes by the current scale so a drag of
-- N screen pixels still resizes the window by N screen pixels. UDim2/Vector2 calls
-- (used at init) are passed through untouched.
local rawSetSize = Library.SetSize
function Library:SetSize(width, height)
    local scale = UiScale.Scale
    if type(width) == "number" and type(height) == "number" and scale > 0 then
        width = width / scale
        height = height / scale
    end
    return rawSetSize(self, width, height)
end

-- keep the scale in sync if the Roblox window is resized or the device is rotated.
-- the library has no cleanup hook, so track connections and drop them on Destroy.
local scaleConnections = {}

local function watchViewport()
    local camera = workspace.CurrentCamera
    if camera then
        table.insert(scaleConnections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            UiScale.Scale = computeUiScale()
        end))
    end
end

table.insert(scaleConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    UiScale.Scale = computeUiScale()
    watchViewport()
end))
watchViewport()

local rawDestroy = Library.Destroy
function Library:Destroy()
    for _, connection in ipairs(scaleConnections) do
        connection:Disconnect()
    end
    table.clear(scaleConnections)
    return rawDestroy(self)
end

local ResizeCornerMark = Library.ResizeHandle and Library.ResizeHandle:FindFirstChild("CornerMark")
if ResizeCornerMark then
    ResizeCornerMark:Destroy()
end

local CombatTab = Library:CreateTab({ Name = "Combat" })
local AutoTab = Library:CreateTab({ Name = "Automation" })
local PlayerTab = Library:CreateTab({ Name = "Player" })
local KeybindTab = Library:CreateTab({ Name = "Keybinds" })
local ConfigTab = Library:CreateTab({ Name = "Config" })

PQ.FixPlayerShootTime:Toggle(true)

-- The library sizes each tab's scroll canvas from layout.AbsoluteContentSize (the
-- already-scaled height) but writes it into CanvasSize.Offset, which the UIScale
-- then multiplies again -- so the canvas ends up height*scale^2. On mobile (scale
-- < 1) that makes it too short and you can't scroll to the bottom. Patch the shared
-- Tab method to convert the content height back to design units before assigning,
-- so the canvas matches the content at any scale. Tab.__index == Tab, so overriding
-- it on the metatable fixes every tab at once.
local TabClass = getmetatable(CombatTab)
function TabClass:_RefreshCanvas()
    if self.content and self.layout then
        local scale = UiScale.Scale
        local contentHeight = self.layout.AbsoluteContentSize.Y
        if scale > 0 then
            contentHeight = contentHeight / scale
        end
        self.content.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
    end
end

CombatTab:Label({ Text = "Ability" })

local AutoAbilityHealthThreshold
local AutoAbilityManaThreshold
local AutoAbilityUseOnTrainingDummies
local AutoAbilityUseOnBossesOnly
local AutoAbilityRequireEnemyNear
local AutoAbilityTargetInvulnerable

local AutoAbilityToggle = CombatTab:Toggle({
    Text = "Auto Ability",
    Flag = "AutoAbility",
    Default = false,
    Callback = function(value)
        local healthThreshold = AutoAbilityHealthThreshold and AutoAbilityHealthThreshold:GetValue() or 100
        local manaThreshold = AutoAbilityManaThreshold and AutoAbilityManaThreshold:GetValue() or 0

        PQ.AutoAbility:SetHealthThresholdPercentage(healthThreshold > 0 and healthThreshold or nil)
        PQ.AutoAbility:SetManaThresholdPercentage(manaThreshold > 0 and manaThreshold or nil)
        PQ.AutoAbility:SetUseOnTrainingDummies(AutoAbilityUseOnTrainingDummies and AutoAbilityUseOnTrainingDummies:GetValue() or false)
        PQ.AutoAbility:SetUseAbilityOnBossesOnly(AutoAbilityUseOnBossesOnly and AutoAbilityUseOnBossesOnly:GetValue() or false)
        PQ.AutoAbility:SetRequireEnemyNear(AutoAbilityRequireEnemyNear and AutoAbilityRequireEnemyNear:GetValue() or false)
        PQ.AutoAbility:SetTargetInvulnerable(AutoAbilityTargetInvulnerable and AutoAbilityTargetInvulnerable:GetValue() or false)
        PQ.AutoAbility:Toggle(value)
    end
})

AutoAbilityHealthThreshold = CombatTab:Slider({
    Text = "Health Threshold %",
    Flag = "AutoAbilityHealthThreshold",
    Min = 0,
    Max = 100,
    Default = 100,
    Increment = 1,
    Callback = function(value)
        PQ.AutoAbility:SetHealthThresholdPercentage(value > 0 and value or nil)
    end
})

AutoAbilityManaThreshold = CombatTab:Slider({
    Text = "Mana Threshold %",
    Flag = "AutoAbilityManaThreshold",
    Min = 0,
    Max = 100,
    Default = 0,
    Increment = 1,
    Callback = function(value)
        PQ.AutoAbility:SetManaThresholdPercentage(value > 0 and value or nil)
    end
})

AutoAbilityUseOnTrainingDummies = CombatTab:Toggle({
    Text = "Use On Training Dummies",
    Flag = "AutoAbilityUseOnTrainingDummies",
    Default = true,
    Callback = function(value)
        PQ.AutoAbility:SetUseOnTrainingDummies(value)
    end
})

AutoAbilityUseOnBossesOnly = CombatTab:Toggle({
    Text = "Use On Bosses Only",
    Flag = "AutoAbilityUseOnBossesOnly",
    Default = false,
    Callback = function(value)
        PQ.AutoAbility:SetUseAbilityOnBossesOnly(value)
    end
})

AutoAbilityRequireEnemyNear = CombatTab:Toggle({
    Text = "Require Enemy Near",
    Flag = "AutoAbilityRequireEnemyNear",
    Default = true,
    Callback = function(value)
        PQ.AutoAbility:SetRequireEnemyNear(value)
    end
})

AutoAbilityTargetInvulnerable = CombatTab:Toggle({
    Text = "Target Invulnerable",
    Flag = "AutoAbilityTargetInvulnerable",
    Default = false,
    Callback = function(value)
        PQ.AutoAbility:SetTargetInvulnerable(value)
    end
})

CombatTab:Separator({ Text = "" })
CombatTab:Label({ Text = "Auto Target" })

local AutoTargetTileRadius
local AutoTargetSpoofAbility
local AutoTargetSpoofPrimary
local AutoTargetInvulnerable
local AutoTargetOffscreen

local AutoTargetToggle = CombatTab:Toggle({
    Text = "Auto Target",
    Flag = "AutoTarget",
    Default = false,
    Callback = function(value)
        PQ.AutoTarget:SetTileRadius(tonumber(AutoTargetTileRadius and AutoTargetTileRadius:GetValue()) or 9e9)
        PQ.AutoTarget:SetSpoofAbilityTarget(AutoTargetSpoofAbility and AutoTargetSpoofAbility:GetValue() or false)
        PQ.AutoTarget:SetSpoofPrimaryTarget(AutoTargetSpoofPrimary and AutoTargetSpoofPrimary:GetValue() or false)
        PQ.AutoTarget:SetTargetInvulnerable(AutoTargetInvulnerable and AutoTargetInvulnerable:GetValue() or false)
        PQ.AutoTarget:SetTargetOffscreen(AutoTargetOffscreen and AutoTargetOffscreen:GetValue() or false)
        PQ.AutoTarget:Toggle(value)
    end
})

AutoTargetTileRadius = CombatTab:Textbox({
    Text = "Tile Radius",
    Placeholder = "9e9",
    Flag = "AutoTargetTileRadius",
    Default = "9e9",
    Callback = function(value)
        PQ.AutoTarget:SetTileRadius(tonumber(value) or 9e9)
    end
})

AutoTargetSpoofAbility = CombatTab:Toggle({
    Text = "Spoof Ability Target",
    Flag = "AutoTargetSpoofAbility",
    Default = false,
    Callback = function(value)
        PQ.AutoTarget:SetSpoofAbilityTarget(value)
    end
})

AutoTargetSpoofPrimary = CombatTab:Toggle({
    Text = "Spoof Primary Target",
    Flag = "AutoTargetSpoofPrimary",
    Default = false,
    Callback = function(value)
        PQ.AutoTarget:SetSpoofPrimaryTarget(value)
    end
})

AutoTargetInvulnerable = CombatTab:Toggle({
    Text = "Target Invulnerable",
    Flag = "AutoTargetInvulnerable",
    Default = false,
    Callback = function(value)
        PQ.AutoTarget:SetTargetInvulnerable(value)
    end
})

AutoTargetOffscreen = CombatTab:Toggle({
    Text = "Target Offscreen",
    Flag = "AutoTargetOffscreen",
    Default = false,
    Callback = function(value)
        PQ.AutoTarget:SetTargetOffscreen(value)
    end
})

CombatTab:Separator({ Text = "" })
CombatTab:Label({ Text = "Kill Aura" })

local KillAuraHitDelay
local KillAuraComboHitDelay
local KillAuraTileRadius
local KillAuraModeDropdown
local KillAuraInvulnerable
local KillAuraOffscreen
local KillAuraHitTrainingDummies

local KillAuraToggle = CombatTab:Toggle({
    Text = "Kill Aura",
    Flag = "KillAura",
    Default = false,
    Callback = function(value)
        PQ.KillAura:SetHitDelay(KillAuraHitDelay and KillAuraHitDelay:GetValue() or 0.05)
        PQ.KillAura:SetComboHitDelay(KillAuraComboHitDelay and KillAuraComboHitDelay:GetValue() or 0.2)
        PQ.KillAura:SetTileRadius(tonumber(KillAuraTileRadius and KillAuraTileRadius:GetValue()) or 9e9)
        PQ.KillAura:SetMode(KillAuraMode[KillAuraModeDropdown and KillAuraModeDropdown:GetValue() or "adaptive"])
        PQ.KillAura:SetTargetInvulnerable(KillAuraInvulnerable and KillAuraInvulnerable:GetValue() or false)
        PQ.KillAura:SetTargetOffscreen(KillAuraOffscreen and KillAuraOffscreen:GetValue() or false)
        PQ.KillAura:SetHitTrainingDummies(KillAuraHitTrainingDummies and KillAuraHitTrainingDummies:GetValue() or false)
        PQ.KillAura:Toggle(value)
    end
})

KillAuraHitDelay = CombatTab:Slider({
    Text = "Hit Delay",
    Flag = "KillAuraHitDelay",
    Min = 0,
    Max = 1,
    Default = 0.05,
    Increment = 0.001,
    Callback = function(value)
        PQ.KillAura:SetHitDelay(value)
    end
})

KillAuraComboHitDelay = CombatTab:Slider({
    Text = "Combo Hit Delay",
    Flag = "KillAuraComboHitDelay",
    Min = 0,
    Max = 3,
    Default = 0.2,
    Increment = 0.05,
    Callback = function(value)
        PQ.KillAura:SetComboHitDelay(value)
    end
})

KillAuraTileRadius = CombatTab:Textbox({
    Text = "Tile Radius",
    Placeholder = "9e9",
    Flag = "KillAuraTileRadius",
    Default = "9e9",
    Callback = function(value)
        PQ.KillAura:SetTileRadius(tonumber(value) or 9e9)
    end
})

KillAuraModeDropdown = CombatTab:Dropdown({
    Text = "Mode",
    Flag = "KillAuraMode",
    Options = { "single", "multi", "adaptive" },
    Default = "adaptive",
    Callback = function(value)
        PQ.KillAura:SetMode(KillAuraMode[value])
    end
})

KillAuraInvulnerable = CombatTab:Toggle({
    Text = "Target Invulnerable",
    Flag = "KillAuraInvulnerable",
    Default = false,
    Callback = function(value)
        PQ.KillAura:SetTargetInvulnerable(value)
    end
})

KillAuraOffscreen = CombatTab:Toggle({
    Text = "Target Offscreen",
    Flag = "KillAuraOffscreen",
    Default = false,
    Callback = function(value)
        PQ.KillAura:SetTargetOffscreen(value)
    end
})

KillAuraHitTrainingDummies = CombatTab:Toggle({
    Text = "Hit Training Dummies",
    Flag = "KillAuraHitTrainingDummies",
    Default = true,
    Callback = function(value)
        PQ.KillAura:SetHitTrainingDummies(value)
    end
})

CombatTab:Separator({ Text = "" })
CombatTab:Label({ Text = "Fire Rate" })

-- local BoostRateOfFireMultiplierBox
local FixPlayerShootTimeJuiceMeter
local ShowFixPlayerShootTimeJuiceToggle

-- local BoostRateOfFireToggle = CombatTab:Toggle({
--     Text = "Boost Rate Of Fire",
--     Flag = "BoostRateOfFire",
--     Default = false,
--     Callback = function(value)
--         PQ.BoostRateOfFire:SetMulti(tonumber(BoostRateOfFireMultiplierBox and BoostRateOfFireMultiplierBox:GetValue()) or 1)
--         PQ.BoostRateOfFire:Toggle(value)
--     end
-- })

-- BoostRateOfFireMultiplierBox = CombatTab:Textbox({
--     Text = "Rate Of Fire Multiplier",
--     Flag = "BoostRateOfFireMultiplier",
--     Placeholder = "1",
--     Default = "1",
--     Callback = function(value)
--         PQ.BoostRateOfFire:SetMulti(tonumber(value) or 1)
--     end
-- })

ShowFixPlayerShootTimeJuiceToggle = CombatTab:Toggle({
    Text = "Show Shoot Time Juice",
    Flag = "ShowFixPlayerShootTimeJuice",
    Default = true,
    Callback = function(value)
        if not FixPlayerShootTimeJuiceMeter then
            return
        end

        if value then
            FixPlayerShootTimeJuiceMeter:Show()
        else
            FixPlayerShootTimeJuiceMeter:Hide()
        end
    end
})

FixPlayerShootTimeJuiceMeter = CombatTab:Meter({
    Text = "Shoot Time Juice",
    Min = 0,
    Max = 1,
    Default = 1,
    Color = Color3.fromRGB(92, 218, 132),
    LowColor = Color3.fromRGB(255, 96, 96),
    Format = function(value)
        return string.format("%d%%", math.floor(value * 100 + 0.5))
    end
})

if not ShowFixPlayerShootTimeJuiceToggle:GetValue() then
    FixPlayerShootTimeJuiceMeter:Hide()
end

task.spawn(function()
    while Library.MainFrame and Library.MainFrame.Parent do
        local maxOffset = PQ.FixPlayerShootTime.MAX_PLAYER_SHOOT_TIME_OFFSET
        local offset = math.clamp((PQ.FixPlayerShootTime.lastAdjustedTime or 0) - os.clock(), 0, maxOffset)
        local juice = maxOffset > 0 and math.clamp(1 - (offset / maxOffset), 0, 1) or 1

        FixPlayerShootTimeJuiceMeter:SetValue(juice)
        task.wait(0.1)
    end
end)

CombatTab:Separator({ Text = "" })
CombatTab:Label({ Text = "Projectiles" })

local ForceLinearBulletPatternToggle = CombatTab:Toggle({
    Text = "Force Linear Bullet Pattern",
    Flag = "ForceLinearBulletPattern",
    Default = false,
    Callback = function(value)
        PQ.ForceLinearBulletPattern:Toggle(value)
    end
})

local RemoveBulletSpreadToggle = CombatTab:Toggle({
    Text = "Remove Bullet Spread",
    Flag = "RemoveBulletSpread",
    Default = false,
    Callback = function(value)
        PQ.RemoveBulletSpread:Toggle(value)
    end
})

local BulletsPenetrateTerrainToggle = CombatTab:Toggle({
    Text = "Bullets Penetrate Terrain",
    Flag = "BulletsPenetrateTerrain",
    Default = false,
    Callback = function(value)
        PQ.BulletsPenetrateTerrain:Toggle(value)
    end
})

AutoTab:Label({ Text = "Claims" })

local AutoClaimQuestsToggle = AutoTab:Toggle({
    Text = "Auto Claim Quests",
    Flag = "AutoClaimQuests",
    Default = false,
    Callback = function(value)
        PQ.AutoClaimQuests:Toggle(value)
    end
})

local AutoClaimAchievementsToggle = AutoTab:Toggle({
    Text = "Auto Claim Achievements",
    Flag = "AutoClaimAchievements",
    Default = false,
    Callback = function(value)
        PQ.AutoClaimAchievements:Toggle(value)
    end
})

local AutoClaimDailyRewardsToggle = AutoTab:Toggle({
    Text = "Auto Claim Daily Rewards",
    Flag = "AutoClaimDailyRewards",
    Default = false,
    Callback = function(value)
        PQ.AutoClaimDailyRewards:Toggle(value)
    end
})

AutoTab:Separator({ Text = "" })
AutoTab:Label({ Text = "Collection" })

local AutoExpToggle = AutoTab:Toggle({
    Text = "Auto EXP",
    Flag = "AutoExp",
    Default = false,
    Callback = function(value)
        PQ.AutoExp:Toggle(value)
    end
})

local function SortedTierNames(tiers)
    local names = {}
    for tierName in tiers do
        if tierName ~= "T0" then
            table.insert(names, tierName)
        end
    end
    table.sort(names, function(a, b)
        local aNum = a:match("^T(%d+)$")
        local bNum = b:match("^T(%d+)$")
        if aNum and bNum then
            return tonumber(aNum) < tonumber(bNum)
        elseif aNum then
            return true
        elseif bNum then
            return false
        else
            return a < b
        end
    end)
    return names
end

local AutoLootTiers = SortedTierNames(PQ.AutoLoot.TIERS_TO_LOOT)
local AutoSellTiers = SortedTierNames(PQ.AutoSell.TIERS_TO_SELL)

local function ApplyTierSelection(allTiers, selected, setEnabled)
    local selectedSet = {}
    for _, tierName in selected or {} do
        selectedSet[tierName] = true
    end
    for _, tierName in allTiers do
        setEnabled(tierName, selectedSet[tierName] == true)
    end
end

AutoTab:Separator({ Text = "" })
AutoTab:Label({ Text = "Loot" })

local AutoLootMinValor
local AutoLootPickupCategoriesDropdown
local AutoLootCooldownTimeout
local AutoLootTierDropdown

local AutoLootPickupCategories = {
    "Pickup Items",
    "Pickup Scrolls",
    "Pickup Souls",
    "Pickup Infusions",
    "Pickup Corrupted Pages",
    "Pickup Chests"
}

local function ApplyAutoLootPickupSelection(selected)
    local selectedSet = {}
    for _, categoryName in selected or {} do
        selectedSet[categoryName] = true
    end

    PQ.AutoLoot:SetPickupItems(selectedSet["Pickup Items"] == true)
    PQ.AutoLoot:SetPickupScrolls(selectedSet["Pickup Scrolls"] == true)
    PQ.AutoLoot:SetPickupSouls(selectedSet["Pickup Souls"] == true)
    PQ.AutoLoot:SetPickupInfusions(selectedSet["Pickup Infusions"] == true)
    PQ.AutoLoot:SetPickupCorruptedPages(selectedSet["Pickup Corrupted Pages"] == true)
    PQ.AutoLoot:SetPickupChests(selectedSet["Pickup Chests"] == true)
end

local AutoLootToggle = AutoTab:Toggle({
    Text = "Auto Loot",
    Flag = "AutoLoot",
    Default = false,
    Callback = function(value)
        PQ.AutoLoot:SetMinValor(tonumber(AutoLootMinValor and AutoLootMinValor:GetValue()) or 0)
        ApplyAutoLootPickupSelection(AutoLootPickupCategoriesDropdown and AutoLootPickupCategoriesDropdown:GetValue())
        PQ.AutoLoot:SetCooldownTimeout(tonumber(AutoLootCooldownTimeout and AutoLootCooldownTimeout:GetValue()) or 1)
        ApplyTierSelection(AutoLootTiers, AutoLootTierDropdown and AutoLootTierDropdown:GetValue(), function(tierName, enabled)
            PQ.AutoLoot:SetLootTierEnabled(tierName, enabled)
        end)
        PQ.AutoLoot:Toggle(value)
    end
})

AutoLootMinValor = AutoTab:Textbox({
    Text = "Min Valor",
    Placeholder = "0",
    Flag = "AutoLootMinValor",
    Default = "0",
    Callback = function(value)
        PQ.AutoLoot:SetMinValor(tonumber(value) or 0)
    end
})

AutoLootPickupCategoriesDropdown = AutoTab:Dropdown({
    Text = "Pickup Categories",
    Flag = "AutoLootPickupCategories",
    Multi = true,
    Options = AutoLootPickupCategories,
    Default = { "Pickup Items", "Pickup Scrolls", "Pickup Corrupted Pages", "Pickup Chests" },
    Callback = function(value)
        ApplyAutoLootPickupSelection(value)
    end
})

AutoLootCooldownTimeout = AutoTab:Slider({
    Text = "Cooldown Timeout",
    Flag = "AutoLootCooldownTimeout",
    Min = 0,
    Max = 5,
    Default = 1,
    Increment = 0.05,
    Callback = function(value)
        PQ.AutoLoot:SetCooldownTimeout(value)
    end
})

AutoLootTierDropdown = AutoTab:Dropdown({
    Text = "Tiers",
    Flag = "AutoLootTiers",
    Multi = true,
    Options = AutoLootTiers,
    Default = {},
    Callback = function(value)
        ApplyTierSelection(AutoLootTiers, value, function(tierName, enabled)
            PQ.AutoLoot:SetLootTierEnabled(tierName, enabled)
        end)
    end
})

AutoTab:Separator({ Text = "" })
AutoTab:Label({ Text = "Sell" })

local AutoSellMinValor
local AutoSellMaxValor
local AutoSellSellScrolls
local AutoSellTierDropdown

local AutoSellToggle = AutoTab:Toggle({
    Text = "Auto Sell",
    Flag = "AutoSell",
    Default = false,
    Callback = function(value)
        PQ.AutoSell:SetMinSellValor(tonumber(AutoSellMinValor and AutoSellMinValor:GetValue()) or 0)
        PQ.AutoSell:SetMaxSellValor(tonumber(AutoSellMaxValor and AutoSellMaxValor:GetValue()) or math.huge)
        PQ.AutoSell.sellScrolls = AutoSellSellScrolls and AutoSellSellScrolls:GetValue() or false
        ApplyTierSelection(AutoSellTiers, AutoSellTierDropdown and AutoSellTierDropdown:GetValue(), function(tierName, enabled)
            PQ.AutoSell:SetSellTierEnabled(tierName, enabled)
        end)
        PQ.AutoSell:Toggle(value)
    end
})

AutoSellMinValor = AutoTab:Textbox({
    Text = "Min Sell Valor",
    Placeholder = "0",
    Flag = "AutoSellMinValor",
    Default = "0",
    Callback = function(value)
        PQ.AutoSell:SetMinSellValor(tonumber(value) or 0)
    end
})

AutoSellMaxValor = AutoTab:Textbox({
    Text = "Max Sell Valor",
    Placeholder = "inf",
    Flag = "AutoSellMaxValor",
    Default = "",
    Callback = function(value)
        PQ.AutoSell:SetMaxSellValor(tonumber(value) or math.huge)
    end
})

AutoSellSellScrolls = AutoTab:Toggle({
    Text = "Sell Scrolls",
    Flag = "AutoSellSellScrolls",
    Default = false,
    Callback = function(value)
        PQ.AutoSell.sellScrolls = value
    end
})

AutoSellTierDropdown = AutoTab:Dropdown({
    Text = "Tiers",
    Flag = "AutoSellTiers",
    Multi = true,
    Options = AutoSellTiers,
    Default = {},
    Callback = function(value)
        ApplyTierSelection(AutoSellTiers, value, function(tierName, enabled)
            PQ.AutoSell:SetSellTierEnabled(tierName, enabled)
        end)
    end
})

AutoTab:Separator({ Text = "" })
AutoTab:Label({ Text = "Inventory" })

local DropInventoryButton = AutoTab:Button({
    Text = "Drop Inventory",
    Callback = function()
        PQ.DropInventory()
    end
})

local SellInventoryButton = AutoTab:Button({
    Text = "Sell Inventory",
    Callback = function()
        PQ.SellInventory()
    end
})

PlayerTab:Label({ Text = "Movement" })

local NoclipToggle = PlayerTab:Toggle({
    Text = "Noclip",
    Flag = "Noclip",
    Default = false,
    Callback = function(value)
        PQ.Noclip:Toggle(value)
    end
})

local MovementSpeedMulti

local BoostMovementSpeedToggle = PlayerTab:Toggle({
    Text = "Boost Movement Speed",
    Flag = "BoostMovementSpeed",
    Default = false,
    Callback = function(value)
        PQ.BoostMovementSpeed:SetMulti(MovementSpeedMulti and MovementSpeedMulti:GetValue() or 1.1)
        PQ.BoostMovementSpeed:Toggle(value)
    end
})

MovementSpeedMulti = PlayerTab:Slider({
    Text = "Movement Speed Multi",
    Flag = "MovementSpeedMulti",
    Min = 1,
    Max = 1.25,
    Default = 1.1,
    Increment = 0.01,
    Callback = function(value)
        PQ.BoostMovementSpeed:SetMulti(value)
    end
})

PlayerTab:Separator({ Text = "" })
PlayerTab:Label({ Text = "Defense" })

local GodmodeToggle = PlayerTab:Toggle({
    Text = "Godmode",
    Flag = "Godmode",
    Default = false,
    Callback = function(value)
        PQ.Godmode:SetMode(GodmodeMode.FULL)
        PQ.Godmode:Toggle(value)
    end
})

local NoReplicationDelayToggle = PlayerTab:Toggle({
    Text = "No Replication Delay",
    Flag = "NoReplicationDelay",
    Default = false,
    Callback = function(value)
        PQ.NoReplicationDelay:Toggle(value)
    end
})

local DebuffImmunityToggle = PlayerTab:Toggle({
    Text = "Debuff Immunity",
    Flag = "DebuffImmunity",
    Default = false,
    Callback = function(value)
        PQ.DebuffImmunity:Toggle(value)
    end
})

-- Init populates effectNames/effectsDisabled; it is idempotent and lazily run by
-- Toggle, so call it here to have the effect list ready for the dropdown options.
PQ.DebuffImmunity:Init()

local DebuffImmunityEffects = {}
for _, effectName in PQ.DebuffImmunity.effectNames do
    table.insert(DebuffImmunityEffects, effectName)
end
table.sort(DebuffImmunityEffects)

local DebuffImmunityEffectsDropdown = PlayerTab:Dropdown({
    Text = "Immune To Effects",
    Flag = "DebuffImmunityEffects",
    Multi = true,
    Options = DebuffImmunityEffects,
    Default = {},
    Callback = function(value)
        ApplyTierSelection(DebuffImmunityEffects, value, function(effectName, enabled)
            PQ.DebuffImmunity:SetEffectEnabled(effectName, enabled)
        end)
    end
})

PlayerTab:Separator({ Text = "" })
PlayerTab:Label({ Text = "Misc" })

local AntiAfkToggle = PlayerTab:Toggle({
    Text = "Anti AFK",
    Flag = "AntiAfk",
    Default = false,
    Callback = function(value)
        PQ.AntiAfk:Toggle(value)
    end
})

local AntiStaffModeDropdown

local AntiStaffToggle = PlayerTab:Toggle({
    Text = "Anti Staff",
    Flag = "AntiStaff",
    Default = false,
    Callback = function(value)
        PQ.AntiStaff:SetMode(AntiStaffMode[AntiStaffModeDropdown and AntiStaffModeDropdown:GetValue() or "notify"])
        PQ.AntiStaff:Toggle(value)
    end
})

AntiStaffModeDropdown = PlayerTab:Dropdown({
    Text = "Anti Staff Mode",
    Flag = "AntiStaffMode",
    Options = { "notify", "leave" },
    Default = "notify",
    Callback = function(value)
        PQ.AntiStaff:SetMode(AntiStaffMode[value])
    end
})

local HotkeyQuestTPModeDropdown

HotkeyQuestTPModeDropdown = PlayerTab:Dropdown({
    Text = "Quest Teleport Mode",
    Flag = "HotkeyQuestTPMode",
    Options = { "World Boss Only", "Any Boss" },
    Default = "World Boss Only",
    Callback = function(value)
        if value == "Any Boss" then
            PQ.HotkeyQuestTP.mode = 1
        else
            PQ.HotkeyQuestTP.mode = 2
        end
    end
})

local FasterSwapTimeoutToggle = PlayerTab:Toggle({
    Text = "Faster Swap Timeout",
    Flag = "FasterSwapTimeout",
    Default = false,
    Callback = function(value)
        PQ.FasterSwapTimeout:Toggle(value)
    end
})

local SkinName

local SkinChangerToggle = PlayerTab:Toggle({
    Text = "Skin Changer",
    Flag = "SkinChanger",
    Default = false,
    Callback = function(value)
        PQ.SkinChanger:SetSkinByName(SkinName and SkinName:GetValue() or "Wilted Rose")
        PQ.SkinChanger:Toggle(value)
    end
})

SkinName = PlayerTab:Textbox({
    Text = "Skin Name",
    Placeholder = "Wilted Rose",
    Flag = "SkinName",
    Default = "Wilted Rose",
    Callback = function(value)
        PQ.SkinChanger:SetSkinByName(value)
    end
})

local HideOwnProjectilesToggle = PlayerTab:Toggle({
    Text = "Hide Own Projectiles",
    Flag = "HideOwnProjectiles",
    Default = false,
    Callback = function(value)
        PQ.HideOwnProjectiles:Toggle(value)
    end
})

local ForceShowAllSideButtonsToggle = PlayerTab:Toggle({
    Text = "Force Show All Side Buttons",
    Flag = "ForceShowAllSideButtons",
    Default = false,
    Callback = function(value)
        PQ.ForceShowAllSideButtons:Toggle(value)
    end
})

PlayerTab:Separator({ Text = "" })
PlayerTab:Label({ Text = "Visuals" })

local KeybindStatusMessagesToggle

local function ToggleFromKeybind(toggle, moduleName)
    local enabled = not toggle:GetValue()
    toggle:SetValue(enabled)
    if not KeybindStatusMessagesToggle or KeybindStatusMessagesToggle:GetValue() then
        PQ.DisplayStatusText(moduleName .. ": " .. (enabled and "ON" or "OFF"))
    end
end

KeybindTab:Label({ Text = "Combat" })

KeybindTab:Keybind({
    Text = "Auto Ability",
    Flag = "AutoAbilityKey",
    Callback = function()
        ToggleFromKeybind(AutoAbilityToggle, "Auto Ability")
    end
})

-- KeybindTab:Keybind({
--     Text = "Boost Rate Of Fire",
--     Flag = "BoostRateOfFireKey",
--     Callback = function()
--         ToggleFromKeybind(BoostRateOfFireToggle, "Boost Rate Of Fire")
--     end
-- })

KeybindTab:Keybind({
    Text = "Auto Target",
    Flag = "AutoTargetKey",
    Callback = function()
        ToggleFromKeybind(AutoTargetToggle, "Auto Target")
    end
})

KeybindTab:Keybind({
    Text = "Kill Aura",
    Flag = "KillAuraKey",
    Callback = function()
        ToggleFromKeybind(KillAuraToggle, "Kill Aura")
    end
})

KeybindTab:Keybind({
    Text = "Godmode",
    Flag = "GodmodeKey",
    Callback = function()
        ToggleFromKeybind(GodmodeToggle, "Godmode")
    end
})

KeybindTab:Keybind({
    Text = "Noclip",
    Flag = "NoclipKey",
    Callback = function()
        ToggleFromKeybind(NoclipToggle, "Noclip")
    end
})

KeybindTab:Keybind({
    Text = "Auto EXP",
    Flag = "AutoExpKey",
    Callback = function()
        ToggleFromKeybind(AutoExpToggle, "Auto EXP")
    end
})

KeybindTab:Keybind({
    Text = "Anti AFK",
    Flag = "AntiAfkKey",
    Callback = function()
        ToggleFromKeybind(AntiAfkToggle, "Anti AFK")
    end
})

KeybindTab:Keybind({
    Text = "Anti Staff",
    Flag = "AntiStaffKey",
    Callback = function()
        ToggleFromKeybind(AntiStaffToggle, "Anti Staff")
    end
})

KeybindTab:Keybind({
    Text = "Boost Movement Speed",
    Flag = "BoostMovementSpeedKey",
    Callback = function()
        ToggleFromKeybind(BoostMovementSpeedToggle, "Boost Movement Speed")
    end
})

KeybindTab:Keybind({
    Text = "Skin Changer",
    Flag = "SkinChangerKey",
    Callback = function()
        ToggleFromKeybind(SkinChangerToggle, "Skin Changer")
    end
})

KeybindTab:Keybind({
    Text = "Hide Own Projectiles",
    Flag = "HideOwnProjectilesKey",
    Callback = function()
        ToggleFromKeybind(HideOwnProjectilesToggle, "Hide Own Projectiles")
    end
})

KeybindTab:Keybind({
    Text = "Force Show All Side Buttons",
    Flag = "ForceShowAllSideButtonsKey",
    Callback = function()
        ToggleFromKeybind(ForceShowAllSideButtonsToggle, "Force Show All Side Buttons")
    end
})

KeybindTab:Keybind({
    Text = "Force Linear Bullet Pattern",
    Flag = "ForceLinearBulletPatternKey",
    Callback = function()
        ToggleFromKeybind(ForceLinearBulletPatternToggle, "Force Linear Bullet Pattern")
    end
})

KeybindTab:Keybind({
    Text = "Remove Bullet Spread",
    Flag = "RemoveBulletSpreadKey",
    Callback = function()
        ToggleFromKeybind(RemoveBulletSpreadToggle, "Remove Bullet Spread")
    end
})

KeybindTab:Keybind({
    Text = "Bullets Penetrate Terrain",
    Flag = "BulletsPenetrateTerrainKey",
    Callback = function()
        ToggleFromKeybind(BulletsPenetrateTerrainToggle, "Bullets Penetrate Terrain")
    end
})

KeybindTab:Keybind({
    Text = "Auto Claim Quests",
    Flag = "AutoClaimQuestsKey",
    Callback = function()
        ToggleFromKeybind(AutoClaimQuestsToggle, "Auto Claim Quests")
    end
})

KeybindTab:Keybind({
    Text = "Auto Claim Achievements",
    Flag = "AutoClaimAchievementsKey",
    Callback = function()
        ToggleFromKeybind(AutoClaimAchievementsToggle, "Auto Claim Achievements")
    end
})

KeybindTab:Keybind({
    Text = "Auto Claim Daily Rewards",
    Flag = "AutoClaimDailyRewardsKey",
    Callback = function()
        ToggleFromKeybind(AutoClaimDailyRewardsToggle, "Auto Claim Daily Rewards")
    end
})

KeybindTab:Keybind({
    Text = "Auto Loot",
    Flag = "AutoLootKey",
    Callback = function()
        ToggleFromKeybind(AutoLootToggle, "Auto Loot")
    end
})

KeybindTab:Keybind({
    Text = "Auto Sell",
    Flag = "AutoSellKey",
    Callback = function()
        ToggleFromKeybind(AutoSellToggle, "Auto Sell")
    end
})

KeybindTab:Keybind({
    Text = "Drop Inventory",
    Flag = "DropInventoryKey",
    Callback = function()
        PQ.DropInventory()
        PQ.DisplayStatusText("Drop Inventory")
    end
})

KeybindTab:Keybind({
    Text = "Sell Inventory",
    Flag = "SellInventoryKey",
    Callback = function()
        PQ.SellInventory()
        PQ.DisplayStatusText("Sell Inventory")
    end
})

KeybindTab:Keybind({
    Text = "No Replication Delay",
    Flag = "NoReplicationDelayKey",
    Callback = function()
        ToggleFromKeybind(NoReplicationDelayToggle, "No Replication Delay")
    end
})

KeybindTab:Keybind({
    Text = "Debuff Immunity",
    Flag = "DebuffImmunityKey",
    Callback = function()
        ToggleFromKeybind(DebuffImmunityToggle, "Debuff Immunity")
    end
})

KeybindTab:Keybind({
    Text = "Quest Teleport",
    Flag = "HotkeyQuestTPKey",
    Callback = function()
        PQ.HotkeyQuestTP:TeleportToClosestBoss()
        PQ.DisplayStatusText("Quest Teleport")
    end
})

KeybindTab:Separator({ Text = "" })
KeybindTab:Label({ Text = "Automation" })
KeybindTab:Separator({ Text = "" })
KeybindTab:Label({ Text = "Player" })

local function SetElementOrder(element, order)
    if element and element.Instance then
        element.Instance.LayoutOrder = order
    end
end

local function SetLabelOrder(tab, text, order)
    for _, child in tab.content:GetChildren() do
        if child:IsA("TextLabel") and child.Text == text then
            child.LayoutOrder = order
            return
        end
    end
end

local function SetSeparatorOrders(tab, orders)
    local index = 1
    for _, child in tab.content:GetChildren() do
        if child.Name == "SeparatorContainer" then
            child.LayoutOrder = orders[index] or child.LayoutOrder
            index += 1
        end
    end
end

local function SetControlOrderByText(tab, text, order)
    for _, child in tab.content:GetChildren() do
        if child:IsA("TextLabel") then
            continue
        end

        local label = child:FindFirstChildWhichIsA("TextLabel", true)
        if label and label.Text == text then
            child.LayoutOrder = order
            return
        end
    end
end

SetLabelOrder(CombatTab, "Kill Aura", 100)
SetElementOrder(KillAuraToggle, 110)
SetElementOrder(KillAuraHitDelay, 120)
SetElementOrder(KillAuraComboHitDelay, 130)
SetElementOrder(KillAuraTileRadius, 140)
SetElementOrder(KillAuraModeDropdown, 150)
SetElementOrder(KillAuraInvulnerable, 160)
SetElementOrder(KillAuraOffscreen, 170)
SetElementOrder(KillAuraHitTrainingDummies, 180)

SetLabelOrder(CombatTab, "Fire Rate", 200)
-- SetElementOrder(BoostRateOfFireToggle, 210)
-- SetElementOrder(BoostRateOfFireMultiplierBox, 220)
SetElementOrder(ShowFixPlayerShootTimeJuiceToggle, 230)
SetElementOrder(FixPlayerShootTimeJuiceMeter, 240)

SetLabelOrder(CombatTab, "Auto Target", 300)
SetElementOrder(AutoTargetToggle, 310)
SetElementOrder(AutoTargetTileRadius, 320)
SetElementOrder(AutoTargetSpoofAbility, 330)
SetElementOrder(AutoTargetSpoofPrimary, 340)
SetElementOrder(AutoTargetInvulnerable, 350)
SetElementOrder(AutoTargetOffscreen, 360)

SetLabelOrder(CombatTab, "Ability", 400)
SetElementOrder(AutoAbilityToggle, 410)
SetElementOrder(AutoAbilityHealthThreshold, 420)
SetElementOrder(AutoAbilityManaThreshold, 430)
SetElementOrder(AutoAbilityUseOnTrainingDummies, 440)
SetElementOrder(AutoAbilityUseOnBossesOnly, 450)
SetElementOrder(AutoAbilityRequireEnemyNear, 460)
SetElementOrder(AutoAbilityTargetInvulnerable, 470)

SetLabelOrder(CombatTab, "Projectiles", 500)
SetElementOrder(ForceLinearBulletPatternToggle, 510)
SetElementOrder(RemoveBulletSpreadToggle, 520)
SetElementOrder(BulletsPenetrateTerrainToggle, 530)
SetSeparatorOrders(CombatTab, { 190, 290, 390, 490 })

SetLabelOrder(AutoTab, "Collection", 100)
SetElementOrder(AutoExpToggle, 110)
SetLabelOrder(AutoTab, "Dealer", 200)
SetElementOrder(DealerBiomeDropdown, 210)
SetElementOrder(ShowDealerPromptButton, 220)
SetLabelOrder(AutoTab, "Claims", 300)
SetElementOrder(AutoClaimQuestsToggle, 310)
SetElementOrder(AutoClaimAchievementsToggle, 320)
SetElementOrder(AutoClaimDailyRewardsToggle, 330)

SetLabelOrder(AutoTab, "Loot", 400)
SetElementOrder(AutoLootToggle, 410)
SetElementOrder(AutoLootMinValor, 420)
SetElementOrder(AutoLootPickupCategoriesDropdown, 430)
SetElementOrder(AutoLootCooldownTimeout, 440)
SetElementOrder(AutoLootTierDropdown, 450)

SetLabelOrder(AutoTab, "Sell", 500)
SetElementOrder(AutoSellToggle, 510)
SetElementOrder(AutoSellMinValor, 520)
SetElementOrder(AutoSellMaxValor, 530)
SetElementOrder(AutoSellSellScrolls, 540)
SetElementOrder(AutoSellTierDropdown, 550)

SetLabelOrder(AutoTab, "Inventory", 600)
SetElementOrder(DropInventoryButton, 610)
SetElementOrder(SellInventoryButton, 620)

SetSeparatorOrders(AutoTab, { 190, 390, 490, 590 })

SetLabelOrder(PlayerTab, "Defense", 100)
SetElementOrder(GodmodeToggle, 110)
SetElementOrder(NoReplicationDelayToggle, 120)
SetElementOrder(DebuffImmunityToggle, 130)
SetElementOrder(DebuffImmunityEffectsDropdown, 135)

SetLabelOrder(PlayerTab, "Movement", 200)
SetElementOrder(NoclipToggle, 210)
SetElementOrder(BoostMovementSpeedToggle, 220)
SetElementOrder(MovementSpeedMulti, 230)

SetLabelOrder(PlayerTab, "Visuals", 300)
SetElementOrder(SkinChangerToggle, 310)
SetElementOrder(SkinName, 320)
SetElementOrder(HideOwnProjectilesToggle, 330)
SetElementOrder(ForceShowAllSideButtonsToggle, 340)

SetLabelOrder(PlayerTab, "Misc", 400)
SetElementOrder(AntiAfkToggle, 410)
SetElementOrder(AntiStaffToggle, 420)
SetElementOrder(AntiStaffModeDropdown, 430)
SetElementOrder(HotkeyQuestTPModeDropdown, 440)
SetElementOrder(FasterSwapTimeoutToggle, 450)

SetSeparatorOrders(PlayerTab, { 190, 290, 390 })

SetLabelOrder(KeybindTab, "Combat", 100)
SetControlOrderByText(KeybindTab, "Kill Aura", 110)
-- SetControlOrderByText(KeybindTab, "Boost Rate Of Fire", 120)
SetControlOrderByText(KeybindTab, "Auto Target", 130)
SetControlOrderByText(KeybindTab, "Auto Ability", 140)
SetControlOrderByText(KeybindTab, "Force Linear Bullet Pattern", 150)
SetControlOrderByText(KeybindTab, "Remove Bullet Spread", 160)
SetControlOrderByText(KeybindTab, "Bullets Penetrate Terrain", 170)

SetLabelOrder(KeybindTab, "Automation", 200)
SetControlOrderByText(KeybindTab, "Auto EXP", 210)
SetControlOrderByText(KeybindTab, "Auto Claim Quests", 220)
SetControlOrderByText(KeybindTab, "Auto Claim Achievements", 230)
SetControlOrderByText(KeybindTab, "Auto Claim Daily Rewards", 240)
SetControlOrderByText(KeybindTab, "Auto Loot", 250)
SetControlOrderByText(KeybindTab, "Auto Sell", 260)
SetControlOrderByText(KeybindTab, "Drop Inventory", 270)
SetControlOrderByText(KeybindTab, "Sell Inventory", 280)

SetLabelOrder(KeybindTab, "Player", 300)
SetControlOrderByText(KeybindTab, "Godmode", 310)
SetControlOrderByText(KeybindTab, "Noclip", 320)
SetControlOrderByText(KeybindTab, "Skin Changer", 330)
SetControlOrderByText(KeybindTab, "Anti Staff", 340)
SetControlOrderByText(KeybindTab, "No Replication Delay", 410)
SetControlOrderByText(KeybindTab, "Debuff Immunity", 420)
SetControlOrderByText(KeybindTab, "Quest Teleport", 430)
SetControlOrderByText(KeybindTab, "Boost Movement Speed", 440)
SetControlOrderByText(KeybindTab, "Anti AFK", 450)
SetControlOrderByText(KeybindTab, "Hide Own Projectiles", 460)
SetControlOrderByText(KeybindTab, "Force Show All Side Buttons", 470)
SetSeparatorOrders(KeybindTab, { 190, 290 })

CombatTab:_RefreshCanvas()
AutoTab:_RefreshCanvas()
PlayerTab:_RefreshCanvas()
KeybindTab:_RefreshCanvas()

ConfigTab:Label({ Text = "Settings" })

local ShowUIOnStartupToggle = ConfigTab:Toggle({
    Text = "Show UI On Startup",
    Flag = "ShowUIOnStartup",
    Default = true,
    Callback = function() end
})

KeybindStatusMessagesToggle = ConfigTab:Toggle({
    Text = "Keybind Status Messages",
    Flag = "KeybindStatusMessages",
    Default = true,
    Callback = function() end
})

ConfigTab:Separator({ Text = "" })
ConfigTab:Label({ Text = "Background" })

local BackgroundImageBox
local BackgroundEnabledToggle

-- how translucent the controls/tabs/title bar become while the background is on,
-- so the image shows through them (0 = opaque, 1 = fully see-through).
local ELEMENT_TRANSPARENCY = 0.4
-- shared with the framework's own pass so they don't fight over the same controls.
local BG_ATTR = "__uiOrigBgTransparency"

-- resolve a textbox value into a usable image string. anything containing
-- "rbxasset" is used directly; a bare id becomes rbxassetid://; an http url is
-- used as-is; otherwise it is treated as a local file name and resolved through
-- the executor's getcustomasset, e.g. "penar.png" -> getcustomasset("penar.png").
local function resolveBackgroundImage(value)
    if type(value) ~= "string" or value == "" then
        return value
    end
    if string.find(value, "rbxasset", 1, true) then
        return value
    end
    local digits = value:match("^%s*(%d+)%s*$")
    if digits then
        return "rbxassetid://" .. digits
    end
    if string.find(value, "^https?://") then
        return value
    end
    local getCustomAsset = getcustomasset
        or (getgenv and getgenv().getcustomasset)
        or (getgenv and getgenv().getsynasset)
    if getCustomAsset then
        local ok, asset = pcall(getCustomAsset, value)
        if ok and type(asset) == "string" and asset ~= "" then
            return asset
        end
    end
    return value
end

-- make the title bar, tabs and every control translucent (or restore them) so the
-- image is visible through them, not just behind them. originals are remembered in
-- an attribute so toggling off is lossless.
local function setChromeTransparency(on)
    local main = Library.MainFrame
    if not main then return end
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:IsA("GuiObject")
            and obj ~= Library.BackgroundImage
            and obj ~= Library.ContentArea
            and obj.Name ~= "Background"
        then
            if on then
                if obj:GetAttribute(BG_ATTR) == nil then
                    if obj.BackgroundTransparency < 1 then
                        obj:SetAttribute(BG_ATTR, obj.BackgroundTransparency)
                        obj.BackgroundTransparency = ELEMENT_TRANSPARENCY
                    end
                else
                    obj.BackgroundTransparency = ELEMENT_TRANSPARENCY
                end
            else
                local original = obj:GetAttribute(BG_ATTR)
                if original ~= nil then
                    obj.BackgroundTransparency = original
                    obj:SetAttribute(BG_ATTR, nil)
                end
            end
        end
    end
end

local function applyBackground(on)
    local id = BackgroundImageBox and BackgroundImageBox:GetValue() or ""
    if on and id ~= "" then
        Library:SetBackground(resolveBackgroundImage(id))
        setChromeTransparency(true)
    else
        Library:SetBackgroundEnabled(false)
        setChromeTransparency(false)
    end
end

BackgroundImageBox = ConfigTab:Textbox({
    Text = "Background ID",
    Placeholder = "rbxassetid://id or workspace file names",
    Flag = "BackgroundImageId",
    Default = "",
    Callback = function()
        if BackgroundEnabledToggle and BackgroundEnabledToggle:GetValue() then
            applyBackground(true)
        end
    end
})

ConfigTab:Slider({
    Text = "Background Transparency",
    Flag = "BackgroundTransparency",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(value)
        Library:SetBackgroundTransparency(value / 100)
    end
})

BackgroundEnabledToggle = ConfigTab:Toggle({
    Text = "Background Image",
    Flag = "BackgroundEnabled",
    Default = false,
    Callback = function(enabled)
        applyBackground(enabled)
    end
})

ConfigTab:Separator({ Text = "" })
ConfigTab:Label({ Text = "Config" })

ConfigTab:Button({
    Text = "Save Config",
    Callback = function()
        Library:SaveConfig()
    end
})

ConfigTab:Button({
    Text = "Load Config",
    Callback = function()
        Library:LoadConfig(true)
    end
})

ConfigTab:Button({
    Text = "Destroy UI",
    Callback = function()
        Library:Destroy()
    end
})

-- Honor the saved "Show UI On Startup" preference (config is auto-loaded by now).
-- Press the toggle keybind (RightShift) to reopen the window if hidden.
if not ShowUIOnStartupToggle:GetValue() then
    Library.MainFrame.Visible = false
end
