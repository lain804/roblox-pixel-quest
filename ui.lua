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

local AutoAbilityToggle = CombatTab:Toggle({
    Text = "Auto Ability",
    Flag = "AutoAbility",
    Default = false,
    Callback = function(value)
        local healthThreshold = AutoAbilityHealthThreshold and AutoAbilityHealthThreshold:GetValue() or 100
        local manaThreshold = AutoAbilityManaThreshold and AutoAbilityManaThreshold:GetValue() or 0

        PQ.AutoAbility:SetHealthThresholdPercentage(healthThreshold > 0 and healthThreshold or nil)
        PQ.AutoAbility:SetManaThresholdPercentage(manaThreshold > 0 and manaThreshold or nil)
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

CombatTab:Separator({ Text = "" })
CombatTab:Label({ Text = "Projectiles" })

local ForceBulletPierceToggle = CombatTab:Toggle({
    Text = "Force Bullet Pierce",
    Flag = "ForceBulletPierce",
    Default = false,
    Callback = function(value)
        PQ.ForceBulletPierce:Toggle(value)
    end
})

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

local function ToggleFromKeybind(toggle, moduleName)
    local enabled = not toggle:GetValue()
    toggle:SetValue(enabled)
    PQ.DisplayStatusText(moduleName .. ": " .. (enabled and "ON" or "OFF"))
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
    Text = "Force Bullet Pierce",
    Flag = "ForceBulletPierceKey",
    Callback = function()
        ToggleFromKeybind(ForceBulletPierceToggle, "Force Bullet Pierce")
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

SetLabelOrder(CombatTab, "Projectiles", 400)
SetElementOrder(ForceBulletPierceToggle, 410)
SetElementOrder(ForceLinearBulletPatternToggle, 420)
SetElementOrder(RemoveBulletSpreadToggle, 430)
SetElementOrder(BulletsPenetrateTerrainToggle, 440)
SetSeparatorOrders(CombatTab, { 190, 290, 390 })

SetLabelOrder(AutoTab, "Collection", 100)
SetElementOrder(AutoExpToggle, 110)
SetLabelOrder(AutoTab, "Claims", 200)
SetElementOrder(AutoClaimQuestsToggle, 210)
SetElementOrder(AutoClaimAchievementsToggle, 220)
SetElementOrder(AutoClaimDailyRewardsToggle, 230)
SetSeparatorOrders(AutoTab, { 190 })

SetLabelOrder(PlayerTab, "Defense", 100)
SetElementOrder(GodmodeToggle, 110)
SetLabelOrder(PlayerTab, "Movement", 200)
SetElementOrder(NoclipToggle, 210)
SetLabelOrder(PlayerTab, "Misc", 300)
SetElementOrder(SkinChangerToggle, 310)
SetElementOrder(SkinName, 320)
SetElementOrder(AntiStaffToggle, 330)
SetElementOrder(AntiStaffModeDropdown, 340)
SetElementOrder(NoReplicationDelayToggle, 410)
SetElementOrder(DebuffImmunityToggle, 420)
SetElementOrder(BoostMovementSpeedToggle, 430)
SetElementOrder(MovementSpeedMulti, 440)
SetElementOrder(AntiAfkToggle, 450)
SetElementOrder(HideOwnProjectilesToggle, 460)
SetSeparatorOrders(PlayerTab, { 190, 290 })

SetLabelOrder(KeybindTab, "Combat", 100)
SetControlOrderByText(KeybindTab, "Kill Aura", 110)
SetControlOrderByText(KeybindTab, "Auto Target", 120)
SetControlOrderByText(KeybindTab, "Auto Ability", 130)
SetControlOrderByText(KeybindTab, "Force Bullet Pierce", 140)
SetControlOrderByText(KeybindTab, "Force Linear Bullet Pattern", 150)
SetControlOrderByText(KeybindTab, "Remove Bullet Spread", 160)
SetControlOrderByText(KeybindTab, "Bullets Penetrate Terrain", 170)

SetLabelOrder(KeybindTab, "Automation", 200)
SetControlOrderByText(KeybindTab, "Auto EXP", 210)
SetControlOrderByText(KeybindTab, "Auto Claim Quests", 220)
SetControlOrderByText(KeybindTab, "Auto Claim Achievements", 230)
SetControlOrderByText(KeybindTab, "Auto Claim Daily Rewards", 240)

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
SetSeparatorOrders(KeybindTab, { 190, 290 })

CombatTab:_RefreshCanvas()
AutoTab:_RefreshCanvas()
PlayerTab:_RefreshCanvas()
KeybindTab:_RefreshCanvas()

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
