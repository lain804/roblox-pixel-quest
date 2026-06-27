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

local Library = UI.new({
    Title = "discord.gg/hS7xx7pFBs",
    Size = UDim2.new(0, 640, 0, 460),
    Position = UDim2.new(0, 100, 0, 100),
    GuiName = "discord.gg/hS7xx7pFBs",
    ConfigFile = "PixelQuestUI.json",
    ConfigFolder = "PixelQuest",
    AutoSave = true,
    AutoLoad = true,
    KeyCode = Enum.KeyCode.RightShift,
    MinSize = Vector2.new(480, 340),
    MaxSize = Vector2.new(820, 620)
})

local ResizeCornerMark = Library.ResizeHandle and Library.ResizeHandle:FindFirstChild("CornerMark")
if ResizeCornerMark then
    ResizeCornerMark:Destroy()
end

local CombatTab = Library:CreateTab({ Name = "Combat" })
local AutoTab = Library:CreateTab({ Name = "Automation" })
local PlayerTab = Library:CreateTab({ Name = "Player" })
local KeybindTab = Library:CreateTab({ Name = "Keybinds" })
local ConfigTab = Library:CreateTab({ Name = "Config" })

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
local AutoLootPickupScrolls
local AutoLootPickupSouls
local AutoLootCooldownTimeout
local AutoLootTierDropdown

local AutoLootToggle = AutoTab:Toggle({
    Text = "Auto Loot",
    Flag = "AutoLoot",
    Default = false,
    Callback = function(value)
        PQ.AutoLoot:SetMinValor(tonumber(AutoLootMinValor and AutoLootMinValor:GetValue()) or 0)
        PQ.AutoLoot:SetPickupScrolls(AutoLootPickupScrolls and AutoLootPickupScrolls:GetValue() or false)
        PQ.AutoLoot:SetPickupSouls(AutoLootPickupSouls and AutoLootPickupSouls:GetValue() or false)
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

AutoLootPickupScrolls = AutoTab:Toggle({
    Text = "Pickup Scrolls",
    Flag = "AutoLootPickupScrolls",
    Default = true,
    Callback = function(value)
        PQ.AutoLoot:SetPickupScrolls(value)
    end
})

AutoLootPickupSouls = AutoTab:Toggle({
    Text = "Pickup Souls",
    Flag = "AutoLootPickupSouls",
    Default = false,
    Callback = function(value)
        PQ.AutoLoot:SetPickupSouls(value)
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

SetLabelOrder(CombatTab, "Auto Target", 200)
SetElementOrder(AutoTargetToggle, 210)
SetElementOrder(AutoTargetTileRadius, 220)
SetElementOrder(AutoTargetSpoofAbility, 230)
SetElementOrder(AutoTargetSpoofPrimary, 240)
SetElementOrder(AutoTargetInvulnerable, 250)
SetElementOrder(AutoTargetOffscreen, 260)

SetLabelOrder(CombatTab, "Ability", 300)
SetElementOrder(AutoAbilityToggle, 310)
SetElementOrder(AutoAbilityHealthThreshold, 320)
SetElementOrder(AutoAbilityManaThreshold, 330)
SetElementOrder(AutoAbilityUseOnTrainingDummies, 340)
SetElementOrder(AutoAbilityUseOnBossesOnly, 350)
SetElementOrder(AutoAbilityRequireEnemyNear, 360)
SetElementOrder(AutoAbilityTargetInvulnerable, 370)

SetLabelOrder(CombatTab, "Projectiles", 400)
SetElementOrder(ForceLinearBulletPatternToggle, 420)
SetElementOrder(RemoveBulletSpreadToggle, 430)
SetElementOrder(BulletsPenetrateTerrainToggle, 440)
SetSeparatorOrders(CombatTab, { 190, 290, 390 })

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
SetElementOrder(AutoLootPickupScrolls, 430)
SetElementOrder(AutoLootPickupSouls, 435)
SetElementOrder(AutoLootCooldownTimeout, 437)
SetElementOrder(AutoLootTierDropdown, 440)

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

SetSeparatorOrders(PlayerTab, { 190, 290, 390 })

SetLabelOrder(KeybindTab, "Combat", 100)
SetControlOrderByText(KeybindTab, "Kill Aura", 110)
SetControlOrderByText(KeybindTab, "Auto Target", 120)
SetControlOrderByText(KeybindTab, "Auto Ability", 130)
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
SetControlOrderByText(KeybindTab, "Boost Movement Speed", 430)
SetControlOrderByText(KeybindTab, "Anti AFK", 440)
SetControlOrderByText(KeybindTab, "Hide Own Projectiles", 450)
SetControlOrderByText(KeybindTab, "Force Show All Side Buttons", 460)
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

BackgroundImageBox = ConfigTab:Textbox({
    Text = "Background ID",
    Placeholder = "rbxassetid://...",
    Flag = "BackgroundImageId",
    Default = "",
    Callback = function(value)
        if BackgroundEnabledToggle and BackgroundEnabledToggle:GetValue() then
            if value ~= "" then
                Library:SetBackground(value)
            else
                Library:SetBackgroundEnabled(false)
            end
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
        if enabled then
            local id = BackgroundImageBox and BackgroundImageBox:GetValue() or ""
            if id ~= "" then
                Library:SetBackground(id)
            end
        else
            Library:SetBackgroundEnabled(false)
        end
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
