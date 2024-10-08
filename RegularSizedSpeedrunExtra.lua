RegularSizedSpeedrun                  = RegularSizedSpeedrun or {}
local RegularSizedSpeedrun            = RegularSizedSpeedrun
local sV
local cV
RegularSizedSpeedrun.slash            = "/speed" or "/SPEED"
RegularSizedSpeedrun.prefix           = "|cffffffRegularSized|r|cdf4242SpeedRun|r: "
RegularSizedSpeedrun.trialDifficulty  = 1
RegularSizedSpeedrun.groupIsHidden    = false
RegularSizedSpeedrun.npChanged        = false
RegularSizedSpeedrun.hbChanged        = false
RegularSizedSpeedrun.npHlChanged      = false
RegularSizedSpeedrun.hbHlChanged      = false
RegularSizedSpeedrun.isLocalChange    = false
local LS                  = LoadingScreen_Base
local EM                  = EVENT_MANAGER
local SM                  = SCENE_MANAGER

--[[  Loading Screen  ]]
local changes             = 0
local isLoading           = false
local hasChanged          = false
local portStart           = 0
local portFailed          = false
local loadingStart        = 0
local loadingEnd          = 0
local deactivated         = false
local normals             = 0
local vets                = 0
local lastDiffChange      = 0
--[[  Hide Group  ]]
local subzone             = ""
local inPortalZone        = false
local portalZones         = {
  -- effects related to portal enter / exit
  --         enter   inside  exit
  [1051] = { 103489, 108045, 105218 }, -- 105218 }, --{ 103489, 105218 },
  [1121] = { 121213,         121254 },
  [1263] = { 153423,         105218 }
}

local necromodeOn         = false
local inPortal            = false
local changedInPortal     = false
local changedOutOfPortal  = false
local portalTime          = 0

local isReset             = false
local isBoss              = false
local bChanges            = {}
local atBoss              = false
local inBossFight         = false
local bossFightStart      = 0
local bosses              = {}
local currentBosses       = 0
local bossesReset         = false

local shouldChange        = false
local hasChanged          = false

local hasEffect           = false
local died                = false
-------------------------
---- Functions    -------
-------------------------

--[[ stuff
/script JumpToSpecificHouse("@playername", houseid)

/script for houseid = 1, 100 do d("["..houseid .."] "..GetCollectibleName(GetCollectibleIdForHouse(houseid))) end

/script JumpToSpecificHouse("@player", 3)

SCENE_MANAGER:GetCurrentScene()

CanSpinPreviewCharacter()
]]

local function OnSubzoneChanged()
  local z = GetPlayerActiveSubzoneName()
  if z ~= "" and z ~= subzone then
    subzone = z
    zo_callLater(function()
      RegularSizedSpeedrun:dbg(2, "Subzone Changed to: <<1>>", subzone)
    end, 200)
  end
end

function RegularSizedSpeedrun.SlashCommand(string)
  local command = string.lower(string)
  -- Debug Options ----------------------------------------------------------
  if command == "track 0" then
    d(RegularSizedSpeedrun.prefix .. "Tracking: Off")
    cV.debugMode = 0

  elseif command == "track 1" then
    d(RegularSizedSpeedrun.prefix .. "Tracking: low (only checkpoints)")
    cV.debugMode = 1

  elseif command == "track 2" then
    d(RegularSizedSpeedrun.prefix .. "Tracking: medium (checkpoints and some function updates)")
    cV.debugMode = 2

  elseif command == "track 3" then
    d(RegularSizedSpeedrun.prefix .. "Tracking: high (everything. can be a lot of spam.)")
    cV.debugMode = 3

  elseif command == "time" then
    d(RegularSizedSpeedrun.prefix .. "Game time - start = <<1>>. Duration = <<2>>.", GetGameTimeSeconds() - RegularSizedSpeedrun.timeStarted, GetRaidDuration() / 1000)

  -- UI Options -------------------------------------------------------------
  elseif command == "move" or command == "lock" then
    RegularSizedSpeedrun.ToggleUILocked()

  elseif command == "hideui" then
    RegularSizedSpeedrun.SetUIHidden(true)

  elseif command == "showui" then
    RegularSizedSpeedrun.SetUIHidden(false)

  elseif command == "ui" then
    RegularSizedSpeedrun.ToggleUIVisibility()

    -- Hide Group -------------------------------------------------------------
  elseif command == "hg" or command == "hidegroup" then
    RegularSizedSpeedrun.HideGroupToggle()

  -- Adds -------------------------------------------------------------------
  elseif command == "score" then
    RegularSizedSpeedrun.PrintScoreReasons()

  elseif command == "lastscore" then
    RegularSizedSpeedrun.PrintLastScoreReasons()

  -- Travel -----------------------------------------------------------------
  elseif command == "home" then
    RequestJumpToHouse(GetHousingPrimaryHouse(), false)

  elseif (command == "h" and GetDisplayName() == "@nogetrandom") then
    RequestJumpToHouse(38)

  elseif (command == "bisse" and GetDisplayName() == "@Mille_W") then
    JumpToSpecificHouse("@nogetrandom", 70)

  -- Default ----------------------------------------------------------------
  else
    d(RegularSizedSpeedrun.prefix .. " Command not recognized!\n[ |cffffff/speed|r (|cffffffcommand|r) ] options are:\n[ |cffffffshow|r or |cffffffhide|r ]: To toggle UI.\n[ |cffffffmove|r or |cfffffflock|r ]: Both will toggle the UI's current lock state.\n[ |cfffffftrack (|cffffff0|r - |cffffff3|r) ]: Chat notification.\n(|cffffff0|r): Only settings change confirmations.\n(|cffffff1|r): Trial checkpoint updates.\n(|cffffff2|r): Checkpoint and internal function updates.\n(|cffffff3|r): Everything the addon is set to register (|cff0000Spam Warning|r).\n[ |cffffffhg|r ] or [ |cffffffhidegroup|r ]: Toggle function on/off.\n[ |cffffffscore|r ]: List current trial score variables in chat.\n[ |cfffffflastscore|r ]: List previous trial score variables in chat (only stores 1 trial, and only if completed).")
  end
end

function RegularSizedSpeedrun.LoadUtils()
  sV = RegularSizedSpeedrun.savedVariables
  cV = RegularSizedSpeedrun.savedSettings

  RegularSizedSpeedrun.trialDifficulty = ZO_GetEffectiveDungeonDifficulty()

  SLASH_COMMANDS[RegularSizedSpeedrun.slash] = RegularSizedSpeedrun.SlashCommand

  if WritCreater then WritCreater.hidePets = function() return end end

  RegularSizedSpeedrun.ConfigureNameplates()
  RegularSizedSpeedrun.ConfigureHideGroup()
  RegularSizedSpeedrun.UpdateNecroMode()
  RegularSizedSpeedrun.ConfigureCombatInteractBlocker()
  RegularSizedSpeedrun.RegisterDifficultyChange()

  -- if GetDisplayName() == "@nogetrandom" then
    -- EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Subzone",  EVENT_CURRENT_SUBZONE_LIST_CHANGED, OnSubzoneChanged)
  -- end
end

function RegularSizedSpeedrun:dbg( debugLevel, ... )
  if debugLevel <= RegularSizedSpeedrun.savedSettings.debugMode then
    local message = zo_strformat( ...)
    d( RegularSizedSpeedrun.prefix .. message )
  end
end

function RegularSizedSpeedrun:post( ... )
  local message = zo_strformat( ... )
  d( message )
end

local lastUpdate = ""
function RegularSizedSpeedrun.GetDifficulty(string)
  local diff
  local isVet = RegularSizedSpeedrun.ResolveTrialDiffculty()
  if string == true then diff = isVet == true and "Veteran" or "Normal"
  else diff = isVet == true and 2 or 1 end
  return diff
end

function RegularSizedSpeedrun.UpdateDifficulty(difficulty)
  RegularSizedSpeedrun.UpdateDifficultySwitch()

  local changed = false

  if difficulty ~= nil and difficulty ~= RegularSizedSpeedrun.trialDifficulty then
    changed = true
    RegularSizedSpeedrun.trialDifficulty = difficulty
    changes = 0
  end

  if changed then
    local d = RegularSizedSpeedrun.GetDifficulty(true)
    lastUpdate = d
    if sV.printDiffChange == true then RegularSizedSpeedrun:dbg(0, "Difficulty changed to: |cffffff<<1>>|r.", d) end
  end
end

function RegularSizedSpeedrun.RegisterDifficultyChange()

  local function OnGroupJoined(eventCode, characterName, displayName, isPlayer)
    if not isPlayer then return end
    RegularSizedSpeedrun.UpdateDifficulty(RegularSizedSpeedrun.GetDifficulty(false))
  end

  local function OnGroupLeft(eventCode, characterName, reason, isPlayer, isLeader, displayName, requiredVote)
    if not isPlayer then return end
    RegularSizedSpeedrun.UpdateDifficulty(RegularSizedSpeedrun.GetDifficulty(false))
  end

  local function OnVeteranDifficultyChanged(eventCode, unitTag, isDifficult)

    if AreUnitsEqual("player", unitTag) then return end

    if deactivated then
      if isDifficult then
        vets = vets + 1
      else
        normals = normals + 1
      end
      changes = changes + 1
    end

    local diff = isDifficult and 2 or 1
    -- if diff ~= RegularSizedSpeedrun.trialDifficulty then
      RegularSizedSpeedrun.UpdateDifficulty(diff)
    -- end

    -- RegularSizedSpeedrun:dbg(2, "Changed by |cffffff<<1>>|r(|cffffff<<3>>|r) to |cffffff<<2>>|r.", GetUnitDisplayName(unitTag), isDifficult and "Veteran" or "Normal", unitTag)
  end

  local function OnGroupVeteranDifficultyChanged(_, isVeteranDifficulty)

    RegularSizedSpeedrun.UpdateDifficulty(isVeteranDifficulty)

    if deactivated then
      if isVeteranDifficulty then
        vets = vets + 1
      else
        normals = normals + 1
      end
      changes = changes + 1
    end
    -- RegularSizedSpeedrun:dbg(2, "Changed to |cffffff<<1>>|r.", isVeteranDifficulty and "Veteran" or "Normal")
  end

  local function OnDeactivated()
    deactivated  = true
    loadingStart = GetGameTimeMilliseconds()
  end

  EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Deactivated", EVENT_PLAYER_DEACTIVATED, OnDeactivated)

  EM:RegisterForEvent( RegularSizedSpeedrun.name .. "IsVet1",      EVENT_VETERAN_DIFFICULTY_CHANGED, OnVeteranDifficultyChanged)
  EM:RegisterForEvent( RegularSizedSpeedrun.name .. "IsVet2",      EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, OnGroupVeteranDifficultyChanged)
  EM:RegisterForEvent( RegularSizedSpeedrun.name .. "JoinedGroup", EVENT_GROUP_MEMBER_JOINED, OnGroupJoined)
  EM:AddFilterForEvent(RegularSizedSpeedrun.name .. "JoinedGroup", EVENT_GROUP_MEMBER_JOINED, REGISTER_FILTER_UNIT_TAG, "player")
  EM:RegisterForEvent( RegularSizedSpeedrun.name .. "LeftGroup",   EVENT_GROUP_MEMBER_LEFT, OnGroupLeft)
  EM:AddFilterForEvent(RegularSizedSpeedrun.name .. "LeftGroup",   EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")
end

-- SetVeteranDifficulty(boolean isVeteranDifficulty)

local function ShouldHideGroup()
  if not cV.groupHidden then return false end
  if (not RegularSizedSpeedrun.IsInTrialZone() and sV.hgTrialOnly) then return false end
  -- if cV.hgNecro then return wasDeativated == true and wasDeactiveted or (not IsUnitInCombat("player")) end
  return true
end

function RegularSizedSpeedrun.IsActivated( _, initial )

  if initial then
    zo_callLater(function()
      RegularSizedSpeedrun.trialDifficulty = RegularSizedSpeedrun.GetDifficulty(false)
    end, 1000)
  end

  RegularSizedSpeedrun.ChaosIsABellend()
  RegularSizedSpeedrun.groupIsHidden  = false
  shouldChange            = true
  RegularSizedSpeedrun.ConfigureHideGroup()

  zo_callLater(function()
    RegularSizedSpeedrun.UpdateDifficultySwitch()
  end, 1000)

  if deactivated then
    deactivated = false
    -- RegularSizedSpeedrun:dbg(2, "Was Deactivated")

    loadingEnd = GetGameTimeMilliseconds()
    local time = string.format("%.2f",(loadingEnd - loadingStart) / 1000)
    RegularSizedSpeedrun:dbg(2, "Load Time: <<1>> sec.", time)
    if changes == 0 then
      RegularSizedSpeedrun:dbg(2, "No changes.")
    else
      if sV.printDiffChange == true then
        RegularSizedSpeedrun:dbg(0, "Instances have been reset. Difficulty is currently set to: |cffffff<<1>>|r.", RegularSizedSpeedrun.GetDifficulty(true))
      end
      RegularSizedSpeedrun:dbg(2, "Normal = <<1>>. Vet = <<2>>", normals, vets)
    end
    normals = 0
    vets    = 0
    changes = 0
  end
end

local function StoreNameplateSettings()
  if not RegularSizedSpeedrun.npChanged then
    sV.nameplates = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES)
  end

  if not RegularSizedSpeedrun.npHlChanged then
    sV.nameplatesHL = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT)
  end

  if not RegularSizedSpeedrun.hbChanged then
    sV.healthBars = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
  end

  if not RegularSizedSpeedrun.hbHlChanged then
    sV.healthBarsHL = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT)
  end
end

function RegularSizedSpeedrun.AlterNameplateSettings()
  if cV.groupHidden and sV.changeNameplates == true then
    RegularSizedSpeedrun.ApplyNameplateGroupHiddenChoice()
    RegularSizedSpeedrun.ApplyNameplateHighlightGroupHiddenChoice()
    RegularSizedSpeedrun.npChanged = true
  end
end

function RegularSizedSpeedrun.AlterHealthBarSettings()
  if cV.groupHidden and sV.changeHealthBars == true then
    RegularSizedSpeedrun.ApplyHealthbarGroupHiddenChoice()
    RegularSizedSpeedrun.ApplyHealthbarHighlightGroupHiddenChoice()
    RegularSizedSpeedrun.hbChanged = true
  end
end

function RegularSizedSpeedrun.RestoreNameplateSettings()
  if cV.groupHidden and sV.changeNameplates then return end
  if RegularSizedSpeedrun.npChanged then
    RegularSizedSpeedrun.isLocalChange = true
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(sV.nameplates))
    RegularSizedSpeedrun.npChanged = false
  end

  if RegularSizedSpeedrun.npHlChanged then
    RegularSizedSpeedrun.isLocalChange = true
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT, tostring(sV.nameplatesHL))
    RegularSizedSpeedrun.npHlChanged = false
  end
end

function RegularSizedSpeedrun.RestoreHealthBarSettings()
  if cV.groupHidden and sV.changeHealthBars then return end
  if RegularSizedSpeedrun.hbChanged then
    RegularSizedSpeedrun.isLocalChange = true
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(sV.healthBars))
    RegularSizedSpeedrun.hbChanged = false
  end

  if RegularSizedSpeedrun.hbHlChanged then
    RegularSizedSpeedrun.isLocalChange = true
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT, tostring(sV.healthBarsHL))
    RegularSizedSpeedrun.hbHlChanged = false
  end
end

local function ShowGroup()
  SetCrownCrateNPCVisible(false)
  RegularSizedSpeedrun.RestoreNameplateSettings()
  RegularSizedSpeedrun.RestoreHealthBarSettings()
  if RegularSizedSpeedrun.isLocalChange == true then
    zo_callLater(function() RegularSizedSpeedrun.isLocalChange = false end, 500)
  end
  if not cV.hgNecro then
    RegularSizedSpeedrun:dbg(0, "Showing Group Members")
  end
end

local function ForceGroupVisible()
  if not IsPlayerActivated() then return end
  local scene = SM.currentScene:GetName()

  if scene == "stats" then ShowGroup() return end

  SM:Show("stats")

  zo_callLater(function()
    ShowGroup()
    if scene == "hudui" then SM:Show("hud")
    else
      if scene ~= "" then SM:Show(scene) end
    end
  end, 20)
end

-- currently not used. no good results
-- local function NecroModePortal(_, result, _, _, _, _, _, _, _, targetType, _, _, _, _, _, _, abilityId)
--   local shouldToggle = false
--   if (result == ACTION_RESULT_EFFECT_GAINED and not inPortal) then
--     inPortal = true
--     if not RegularSizedSpeedrun.groupIsHidden and not changedInPortal then
--       changedInPortal = true
--       shouldToggle = true
--     end
--   elseif (result == ACTION_RESULT_EFFECT_FADED and inPortal) then
--     inPortal = false
--     if RegularSizedSpeedrun.groupIsHidden and not changedOutOfPortal then
--       changedOutOfPortal = true
--       shouldToggle = true
--     end
--   end
--
--   if shouldToggle then
--     SetCrownCrateNPCVisible(true)
--     RegularSizedSpeedrun.groupIsHidden = true
--
--     zo_callLater(function()
--       -- Manually show group again once inside.
--       SetCrownCrateNPCVisible(false)
--       RegularSizedSpeedrun.groupIsHidden = false
--       if inPortal then
--         changedOutOfPortal = false
--       else
--         changedInPortal = false
--       end
--     end, 500)
--   end
--
--   --
--   --   -- Effect of being transported gained. Show cat.
--   --   -- Don't hide group if they are already hidden.
--   --   if (--[[RegularSizedSpeedrun.groupIsHidden == false and]] result == ACTION_RESULT_EFFECT_GAINED) then
--   --
--   --       -- Show cat when transport effect is gained regardless of enter or exit to keep group members hidden.
--   --       -- groupHidden will be updated in the function itself to filter duplicate events.
--   --       -- RegularSizedSpeedrun.HideGroup(true)
--   --       SetCrownCrateNPCVisible(true)
--   --       RegularSizedSpeedrun.groupIsHidden = true
--   --       RegularSizedSpeedrun:dbg(2, "In Portal")
--   --
--   --       zo_callLater(function()
--   --           -- Manually show group again once inside.
--   --           SetCrownCrateNPCVisible(false)
--   --           RegularSizedSpeedrun.groupIsHidden = false
--   --           -- RegularSizedSpeedrun.HideGroup(false)
--   --       end, 500)
--   --
--   --       -- Id matching one that puts player inside the portal.
--   --       -- Players can't enter portal if they are already inside portal.
--   --       if inPortal == false and abilityId == 103489 or abilityId == 121213 or abilityId == 153423 then
--   --
--   --           -- Prevent duplicate events from interfering.
--   --           inPortal = true
--   --
--   --           -- No effect or id found for being transported inside the portal in Rockgrove.
--   --           -- if abilityId == 153423 then
--   --           --     zo_callLater(function()
--   --           --       -- Manually show group again once inside.
--   --           --       SetCrownCrateNPCVisible(false)
--   --           --       RegularSizedSpeedrun.groupIsHidden = false
--   --           --       -- RegularSizedSpeedrun.HideGroup(false)
--   --           --     end, 1000)
--   --           -- end
--   --       end
--   --
--   --   -- Effect of being transported fades. Hide cat.
--   -- -- elseif (--[[RegularSizedSpeedrun.groupIsHidden == true and]] result == ACTION_RESULT_EFFECT_FADED) then
--   --
--   --     -- SetCrownCrateNPCVisible(true)
--   --     -- RegularSizedSpeedrun.groupIsHidden = true
--   --     -- RegularSizedSpeedrun:dbg(2, "Out of Portal")
--   --     --
--   --     -- zo_callLater(function()
--   --     --     -- Manually show group again once inside.
--   --     --     SetCrownCrateNPCVisible(false)
--   --     --     RegularSizedSpeedrun.groupIsHidden = false
--   --     --     -- RegularSizedSpeedrun.HideGroup(false)
--   --     -- end, 1000)
--   --
--   --   --
--   --   --     -- Transportation complete. Hide cat to enable use of corpses.
--   --   --     RegularSizedSpeedrun.HideGroup(false)
--   --   --
--   --   --     -- Id matching one that brings player back from the portal.
--   --   --     if inPortal == true and abilityId == 105218 or abilityId == 121254 then
--   --   --         inPortal = false
--   --   --     end
--   --   end
-- end

local function RefreshHideGroupForNecroMode( delay )
  SetCrownCrateNPCVisible(true)
  RegularSizedSpeedrun.groupIsHidden = true

  zo_callLater(function()
    SetCrownCrateNPCVisible(false)
    RegularSizedSpeedrun.groupIsHidden = false
  end, delay)
end

local function OnNecroEffectChanged( eventCode, change, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  if abilityId == 105218 or abilityId == 103489 then
    if change ~= EFFECT_RESULT_FADED then
      RegularSizedSpeedrun:dbg(2, "[<<1>>] change = <<2>> at: <<3>>.", effectName, tostring(change), GetGameTimeSeconds())
    else
      RegularSizedSpeedrun:dbg(2, "[<<1>>] Faded at: <<2>>.", effectName, GetGameTimeSeconds())
    end
    return
  end

  if change == EFFECT_RESULT_GAINED then
    if not hasEffect then
      hasEffect = true
      RegularSizedSpeedrun:dbg(2, "[<<1>>] Gained at: <<2>>. Hiding Group", effectName, GetGameTimeSeconds())
      RefreshHideGroupForNecroMode( 1500 )
    end

  elseif change == EFFECT_RESULT_FADED then
    if hasEffect then
      hasEffect = false
      RegularSizedSpeedrun:dbg(2, "[<<1>>] Faded at: <<2>>.", effectName, GetGameTimeSeconds())
      RefreshHideGroupForNecroMode( 1500 )
    end
  end
end

local function OnPortalDeath( eventCode, unitTag, isDead )
  if not AreUnitsEqual("player", unitTag) or not hasEffect then return end

  local dead = IsUnitDead("player")

  if dead then
    died = true
    RegularSizedSpeedrun:dbg(2, "[<<1>>] at: <<2>>.", dead and "Dead" or "Alive", GetGameTimeSeconds())
    RefreshHideGroupForNecroMode( 5000 )

  elseif died and not dead then
    died = false
    RegularSizedSpeedrun:dbg(2, "[<<1>>] at: <<2>>.", dead and "Dead" or "Alive", GetGameTimeSeconds())
    RefreshHideGroupForNecroMode( 5000 )
  end
end

-- debug function for finding solution to trial portals
-- EVENT_PLAYER_COMBAT_STATE seemed to be the better option for non-portal situations.
-- will keep testing for finding better triggers
local function NecroBossChanged( eventCode, forceReset )
  if cV.debugMode < 2 then return end

  local exist = DoesUnitExist("boss1")
  if isBoss ~= exist then
    isBoss = exist
    local r = forceReset
    if isReset ~= r then
      isReset = r
      RegularSizedSpeedrun:dbg(2, "Necro Mode Boss Changed: <<1>>, <<2>>", DoesUnitExist("boss1") and "true" or "false", r and "true" or "false")
    end
  end

  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local n = GetUnitName("boss" .. i)
      if not bChanges[n] then
        bChanges[n] = n
        RegularSizedSpeedrun:post("[<<1>>] detected", n)
      end
    end
  end
end

local function ToggleInPortal( time )
  SetCrownCrateNPCVisible(true)
  RegularSizedSpeedrun.groupIsHidden = true
  portalTime             = time + 500
  hasChanged             = true
end

-- debug function for finding solution to trial portals
local function NecroBossUpdate()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local n = GetUnitName("boss" .. i)

      if not IsUnitDead("boss" .. i) then
        local current, max, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

        if current < max and IsUnitInCombat("player") then
          if not bosses[n] then
            bossesReset = false
            bossFightStart = GetGameTimeMilliseconds()
            local b = { name = n, hp = current }
            bosses[n] = b
            currentBosses = currentBosses + 1
            RegularSizedSpeedrun:dbg(2, "Boss [<<1>>] added. Active: <<2>>", n, currentBosses)
          end

        elseif current == max and not IsUnitInCombat("player") then
          if not bossesReset then
            bossesReset = true
            bosses = {}
            currentBosses = 0
            RegularSizedSpeedrun:dbg(2, "Bosses reset.")
          end
        end

      else
        if bosses[n] then
          local boss = bosses[n].name
          bosses[n] = nil
          currentBosses = currentBosses - 1
          RegularSizedSpeedrun:dbg(2, "Boss [<<1>>] removed. Active: <<2>>", boss, currentBosses)
        end
      end
    end

    if currentBosses >= 1 and not IsUnitInCombat("player") and not RegularSizedSpeedrun.groupIsHidden then
      if hasEffect then return end
      local t = GetGameTimeMilliseconds()
      local timer = string.format("%0.3s", (t - bossFightStart) / 1000)
      RegularSizedSpeedrun:dbg(2, "In Portal Update: <<1>>.", timer)
      -- ToggleInPortal( t )

      -- if t > portalTime then
      --     RegularSizedSpeedrun:dbg(2, "In Portal: Showing Group.")
      --     SetCrownCrateNPCVisible(false)
      --     RegularSizedSpeedrun.groupIsHidden = false
      -- end
    end

    --[[
    if not atBoss then RegularSizedSpeedrun:dbg(2, "At Boss") end
    atBoss = true
    if IsUnitInCombat("player") then
      if not inBossFight then
        RegularSizedSpeedrun:dbg(2, "In Boss Fight")
        inBossFight = true
      end
    else
      if inBossFight then
        RegularSizedSpeedrun:dbg(2, "Not In Boss Fight")
        inBossFight = false
      end
    end
  else
    if atBoss then RegularSizedSpeedrun:dbg(2, "Not At Boss") end
    atBoss = false
  end

  if inBossFight then
    local t = GetGameTimeMilliseconds()
    for i = 1, GetNumBuffs("player"), 1 do
      local buffName = GetUnitBuffInfo(unitTag, i) -- abilityId = 102271
      if (buffName == "Shadow World" or buffName == "Time Breach" or buffName == "Bitter Marrow") then
        if not inPortal then
          RegularSizedSpeedrun:dbg(2, "In Portal")
          inPortal = true
          shouldChange = true
        end
      else
        if inPortal then
          RegularSizedSpeedrun:dbg(2, "Not in Portal")
          inPortal = false
          shouldChange = true
        end
      end
    end

    if shouldChange then
      if not hasChanged then
        RegularSizedSpeedrun:dbg(2, "Hiding")
        ToggleInPortal( t )
      else
        RegularSizedSpeedrun:dbg(2, "Unhiding")
        if t > portalTime then
          SetCrownCrateNPCVisible(false)
          RegularSizedSpeedrun.groupIsHidden = false
          hasChanged = false
          shouldChange = false
        end
      end
    end
    ]]

    --[[
    if not atBoss then
      if not RegularSizedSpeedrun.groupIsHidden and not inPortal then
        inPortal = true
        SetCrownCrateNPCVisible(true)
        RegularSizedSpeedrun.groupIsHidden = true
        RegularSizedSpeedrun:dbg(2, "In Portal")
        portalTime = t + 500
      end

      if inPortal and RegularSizedSpeedrun.groupIsHidden then
        if t > portalTime then
          SetCrownCrateNPCVisible(false)
          RegularSizedSpeedrun.groupIsHidden = false
        end
      end

    else
      if RegularSizedSpeedrun.groupIsHidden and inPortal then
        inPortal = false
        SetCrownCrateNPCVisible(true)
        RegularSizedSpeedrun.groupIsHidden = true
        RegularSizedSpeedrun:dbg(2, "Out of Portal")
        portalTime = t + 500
      end

      if not inPortal and RegularSizedSpeedrun.groupIsHidden then
        if t > portalTime then
          SetCrownCrateNPCVisible(false)
          RegularSizedSpeedrun.groupIsHidden = false
        end
      end
    end
    ]]
  end
end

local function RegisterNecroEvents()
  -- if hide group is enabled: turn it off when entering combat.
  -- turn it on again when needed.
  EM:RegisterForEvent( RegularSizedSpeedrun.name .. "NecroCombat", EVENT_PLAYER_COMBAT_STATE, function()

    local inCombat = IsUnitInCombat("player")

    -- only do something if needed
    if inCombat and shouldChange and RegularSizedSpeedrun.groupIsHidden then
      shouldChange = false
      SetCrownCrateNPCVisible(false)
      RegularSizedSpeedrun.groupIsHidden = false
    end

    -- for testing how to work around portals in trials
    if currentBosses >= 1 and not inCombat then  -- can only be true in CR, SS and RG
      RegularSizedSpeedrun:dbg(2, "Portal Trasition at: <<1>>.", GetGameTimeMilliseconds())
    end
  end )

  local zone =  GetZoneId(GetUnitZoneIndex("player"))

  -- if setting is on: hide group on death before being brought back to the group
  if zone == 1051 or zone == 1263 then
    -- CR and RG (you don't get ported out on death in SS, so ignore)
    EM:RegisterForEvent(   RegularSizedSpeedrun.name .. "PortalDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnPortalDeath )
    EM:AddFilterForEvent(  RegularSizedSpeedrun.name .. "PortalDeath", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER )
  end

  -- very messy testing. no good answers yet
  if GetDisplayName() ~= "@nogetrandom" then return end

  EM:UnregisterForEvent(  RegularSizedSpeedrun.name .. "NecroBossChanged", EVENT_BOSSES_CHANGED )
  EM:UnregisterForUpdate( RegularSizedSpeedrun.name .. "NecroBossUpdate" )

  for id, effect in pairs(portalZones) do
    for i = 1, #portalZones[id] do
      local e = portalZones[id][i]
      if e then
        EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "NecroEffectChanged" .. e, EVENT_EFFECT_CHANGED)
        -- EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "Portal" .. e, EVENT_COMBAT_EVENT)
      end
    end

    if id == zone then
      inPortalZone = true
      for i = 1, #portalZones[id] do
        local e = portalZones[id][i]
        if e then
          EM:RegisterForEvent(RegularSizedSpeedrun.name .. "NecroEffectChanged" .. e, EVENT_EFFECT_CHANGED, OnNecroEffectChanged)
          EM:AddFilterForEvent(RegularSizedSpeedrun.name .. "NecroEffectChanged" .. e, EVENT_EFFECT_CHANGED,
          REGISTER_FILTER_ABILITY_ID, e)
          -- REGISTER_FILTER_UNIT_TAG_PREFIX, "player",

          -- EM:RegisterForEvent(  RegularSizedSpeedrun.name .. "Portal" .. e, EVENT_COMBAT_EVENT, NecroModePortal )
          -- EM:AddFilterForEvent( RegularSizedSpeedrun.name .. "Portal" .. e, EVENT_COMBAT_EVENT,
          --     REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
          --     REGISTER_FILTER_ABILITY_ID, e )
        end
        RegularSizedSpeedrun:dbg(2, "Necro Mode check for: <<1>>", GetAbilityName(e))
      end
    end
  end

  if inPortalZone then
    EM:RegisterForEvent( RegularSizedSpeedrun.name .. "NecroBossChanged", EVENT_BOSSES_CHANGED, NecroBossChanged)
    EM:RegisterForUpdate( RegularSizedSpeedrun.name .. "NecroBossUpdate", 50, NecroBossUpdate )
  end
end

function RegularSizedSpeedrun.UpdateNecroMode()
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "PortalDeath", EVENT_UNIT_DEATH_STATE_CHANGED )
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "NecroCombat", EVENT_PLAYER_COMBAT_STATE )

  if cV.hgNecro then
    RegisterNecroEvents()
    if not necromodeOn then necromodeOn = true end
  else
    if necromodeOn then necromodeOn = false

      -- currently for testing
      if GetDisplayName() == "@nogetrandom" then
        for id, effect in pairs(portalZones) do
          for i = 1, #portalZones[id] do
            local e = portalZones[id][i]
            if e then EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "Portal" .. e, EVENT_COMBAT_EVENT ) end
          end
        end
      end
    end
  end
end

function RegularSizedSpeedrun.ConfigureHideGroup()
  RegularSizedSpeedrun.HideGroup(ShouldHideGroup())
  if cV.hgNecro then RegularSizedSpeedrun.UpdateNecroMode() end
end

function RegularSizedSpeedrun.HideGroupToggle()
  cV.groupHidden = not cV.groupHidden
  RegularSizedSpeedrun.HideGroup(cV.groupHidden)
end

function RegularSizedSpeedrun.HideGroup(hide) --copied from HideGroup by Wheels - thanks!
  if hide == true then
    SetCrownCrateNPCVisible(true)
    if RegularSizedSpeedrun.groupIsHidden ~= hide then StoreNameplateSettings() end
    if cV.groupHidden ~= hide then RegularSizedSpeedrun:dbg(0, "Hiding Group Members") end
    if sV.changeNameplates then RegularSizedSpeedrun.AlterNameplateSettings() end
    if sV.changeHealthBars then RegularSizedSpeedrun.AlterHealthBarSettings() end
  else
    if RegularSizedSpeedrun.groupIsHidden ~= hide then
      if not cV.hgNecro and cV.hgAutoShow then ForceGroupVisible()
      else ShowGroup() end
    end
  end
  RegularSizedSpeedrun.groupIsHidden = hide
end

function RegularSizedSpeedrun.ConfigureCombatInteractBlocker()
  ZO_PreHook(PLAYER_TO_PLAYER, "ShowPlayerInteractMenu", function(shouldBlock)
    if IsUnitInCombat("player") then
      local block = false
      if cV.interactBlockAny then
        block = cV.interactBlockAny
      else
        if (IsInCampaign() or IsActiveWorldBattleground()) then
          block = cV.interactBlockPvP
        elseif RegularSizedSpeedrun.IsInTrialZone() then
          block = cV.interactBlockTrial
        end
      end

      if block then
        return true
      end
    end
  end)
end

function RegularSizedSpeedrun.PrintScoreReasons()
  RegularSizedSpeedrun:dbg(0, "[|cffffffCurrent Trial|r |cdf4242Score|r |cffffffFactors|r]")
  for k, v in pairs(RegularSizedSpeedrun.scores) do

    local score = RegularSizedSpeedrun.scores[k]
    if score.id ~= RAID_POINT_REASON_LIFE_REMAINING then

      if score.times > 0 then
        RegularSizedSpeedrun:post('|cdf4242' .. score.name .. '|r' .. ' x ' .. score.times .. ' = ' .. score.total .. ' points.')
      end
    else
      zo_callLater(function()
        if score.times > 0 then RegularSizedSpeedrun:post('|cdf4242' .. score.name .. '|r' .. ' x ' .. score.times) end
      end, 50)
    end
  end
end

function RegularSizedSpeedrun.UpdateScoreFactors(profile, raid)
  for k, v in pairs(RegularSizedSpeedrun.scores) do
    local score = RegularSizedSpeedrun.scores[k]
    if (score.id ~= RAID_POINT_REASON_LIFE_REMAINING and score.times > 0) then
      if sV.profiles[profile].raidList[raid].scoreFactors.scoreReasons[k] == nil then
        sV.profiles[profile].raidList[raid].scoreFactors.scoreReasons[k] = score

      else
        local factor = sV.profiles[profile].raidList[raid].scoreFactors.scoreReasons[k]
        if (factor.times < score.times) then
          factor.times = score.times
          sV.profiles[profile].raidList[raid].scoreFactors.scoreReasons[k].times = factor.times
        end

        if factor.total < score.total then
          factor.total = score.total
          sV.profiles[profile].raidList[raid].scoreFactors.scoreReasons[k].total = factor.total
        end
      end
    end
  end

  local best = sV.profiles[profile].raidList[raid].scoreFactors

  if ((best.bestTime == nil) or (best.bestTime > sV.totalTime)) then
    best.bestTime = sV.totalTime
  end

  if ((best.bestScore == nil) or (best.bestScore < sV.finalScore)) then
    best.bestScore = sV.finalScore
  end

  if not RegularSizedSpeedrun.IsInTrialZone() then return end

  local vit = GetRaidReviveCountersRemaining()

  if vit > 0 then
    if ((best.vitality < vit) or (best.vitality == nil)) then
      best.vitality = vit
    end
  end
end

function RegularSizedSpeedrun.GetTrialMaxVitality(raidID)
  local vitality
  -- TODO poopcode
  if raidID == 638 or raidID == 636 or raidID == 639 or raidID == 1082 or raidID == 635 then
    vitality = 24

  elseif raidID == 725 or raidID ==  975 or raidID == 1000 or raidID == 1051 or raidID == 1121 or raidID == 1196 or raidID == 1263 or raidID == 1344 or raidID == 1427 or raidID == 1478 then
    vitality = 36

  elseif raidID == 677 or raidID == 1227 then
    vitality = 15

  else
    viatality = 0
  end
  return vitality
end

function RegularSizedSpeedrun.ResolveTrialDiffculty()
  local inTrial = false
  local zone    = GetZoneId(GetUnitZoneIndex("player"))

  if RegularSizedSpeedrun.Data.raidList[zone] ~= nil then inTrial = true end
  --for id in pairs(RegularSizedSpeedrun.Data.raidList) do
  --  if id == zone then inTrial = true end
  --end

  if inTrial then
    if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
      return true
    else
      return false
    end
  else
    if IsUnitGrouped("player") then return IsGroupUsingVeteranDifficulty()
    else return IsUnitUsingVeteranDifficulty("player") end
  end
end

function RegularSizedSpeedrun.BestPossible(raidID)
  local timer = 0
  local vitality = RegularSizedSpeedrun.GetTrialMaxVitality(raidID)

  for i, x in pairs(RegularSizedSpeedrun.customTimerSteps[raidID]) do
    if RegularSizedSpeedrun.GetSavedTimer(raidID, i) then
      timer = RegularSizedSpeedrun.GetSavedTimer(raidID, i) + timer
    end
  end

  local t = timer > 0 and (timer / 1000) or 0

  local score = math.floor(RegularSizedSpeedrun.GetScore(t, vitality, raidID))	--= 0

  if score <= 0 then return "0" end

  local scoreString = RegularSizedSpeedrun.FormatRaidScore(score)

  -- TODO Calculate the score using saved score factors if any exists.
  RegularSizedSpeedrun.isScoreSet = true
  return scoreString
end

-- functions for debugging and maybe useful for new functions
function RegularSizedSpeedrun.SetLastTrial()
  RegularSizedSpeedrun.ResetLastTrial()
  sV.lastScores 		= RegularSizedSpeedrun.scores
  sV.lastRaidID 		= sV.raidID
  sV.lastRaidTimer 	= RegularSizedSpeedrun.currentRaidTimer
  RegularSizedSpeedrun.scores		= RegularSizedSpeedrun.GetDefaultScores()
  sV.scores 				= RegularSizedSpeedrun.scores
end

function RegularSizedSpeedrun.GetLastTrial(score, id, timer)
  local t = {}
  if score then t.score = sV.lastScores    end
  if id    then t.id    = sV.lastRaidID    end
  if timer then t.timer = sV.lastRaidTimer end
  return t
end

function RegularSizedSpeedrun.ResetLastTrial()
  sV.lastScores    = {}
  sV.lastRaidID    = 0
  sV.lastRaidTimer = {}
end

function RegularSizedSpeedrun.PrintLastScoreReasons()
  RegularSizedSpeedrun:dbg(0, "[|cffffffLast Trial|r |cdf4242Score|r |cffffffFactors|r]")
  for k, v in pairs(sV.lastScores) do

    local lastScore = sV.lastScores[k]
    if lastScore.id ~= RAID_POINT_REASON_LIFE_REMAINING then
      if lastScore.times > 0 then
        RegularSizedSpeedrun:post('|cdf4242' .. lastScore.name .. '|r' .. ' x ' .. lastScore.times .. ' = ' .. lastScore.total .. ' points.')
      end
    else
      zo_callLater(function()
        RegularSizedSpeedrun:post('|cdf4242' .. lastScore.name .. '|r' .. ' x ' .. lastScore.times)
      end, 100)
    end
  end
end

-- From RaidNotifier (slightly modified)
local nextReminder = 0
local hideReminder = 0
local foodActive   = false
local isReminding  = false
local blackList    = {
  [43752] = true,
  [21263] = true,
  [92232] = true,
  [64210] = true,
  [66776] = true,
  [77123] = true,
  [85501] = true,
  [85502] = true,
  [85503] = true,
  [86755] = true,
  [88445] = true,
  [89683] = true,
  [91369] = true,
}
function RegularSizedSpeedrun.RemindFood()
  SpeedRun_Food:SetHidden(false)
  isReminding = true

  -- if (sV.food.time == 0) then return end

  if (not foodActive and sV.food.expireStay) then return end

  EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "FoodUI", 5000, function()
    EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "FoodUI")
    isReminding = false
    SpeedRun_Food:SetHidden(true)
    SpeedRun_Food_Label:SetText("Food Reminder")
  end)
end

local function GetActiveFoodBuff(abilityId)
  if blackList[abilityId] ~= nil then
    return false
  end
  if DoesAbilityExist(abilityId) then
    if GetAbilityTargetDescription(abilityId) ~= GetString(SI_TARGETTYPE2)
    or GetAbilityEffectDescription(abilityId) ~= ""
    or GetAbilityRadius(abilityId) > 0
    or GetAbilityAngleDistance(abilityId) > 0
    or GetAbilityDuration(abilityId) < 600000 then
      return false
    end
    local cost, mechanic = GetAbilityCost(abilityId)
    local channeled, castTime = GetAbilityCastInfo(abilityId)
    local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
    if cost > 0 or mechanic > 0 or channeled or castTime > 0 or minRangeCM > 0 or maxRangeCM > 0 or GetAbilityDescription(abilityId) == "" then
      return false
    end
    return true
  end
end

local function shouldUpdate()
  local update = true

  if (not sV.food.show or RegularSizedSpeedrun.foodUnlocked) then update = false end
  if isReminding and (not foodActive and sV.food.expireStay) then update = false end

  return update
end

local function CheckFoodBuffs()
  if (not sV.food.show or RegularSizedSpeedrun.foodUnlocked) then return end

  -- if not shouldUpdate() then return end

  local t = GetGameTimeMilliseconds() / 1000

  if (nextReminder - t) > 0 then
    if not isReminding then SpeedRun_Food:SetHidden(true) end
    return
  end

  RegularSizedSpeedrun.UpdateFoodReminderInterval(t, sV.food.time)

  local c = SpeedRun_Food
  local l = c:GetNamedChild("_Label")

  local buffFoodFound = false
  local numBuffs = GetNumBuffs("player")
  if numBuffs > 0 then
    for i = 1, numBuffs do
      local name, _, finish, _, _, _, _, _, _, _, abilityId, canClickOff = GetUnitBuffInfo("player", i)
      if GetActiveFoodBuff(abilityId) and canClickOff then
        buffFoodFound = true
        local bufffood_remaining = finish - t

        -- local testTimer = bufffood_remaining - 2580
        --
        -- if testTimer <= 0 then buffFoodFound = false
        -- else
        --   local formatedTime       = ZO_FormatTime(testTimer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
        --   if testTimer <= 600 then
        --     l:SetText(zo_strformat("Your '|cffff99<<1>>|r' food expires in |cbd0000<<2>>|r minutes!", name, formatedTime))
        --     RegularSizedSpeedrun.RemindFood()
        --   end
        -- end

        local formatedTime       = ZO_FormatTime(bufffood_remaining, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)

        if bufffood_remaining <= 600 then
          l:SetText(zo_strformat("Your |cffff99<<1>>|r food expires in |cbd0000<<2>>|r minutes!", name, formatedTime))
          RegularSizedSpeedrun.RemindFood()
        end
      end
    end
  end

  foodActive = buffFoodFound

  if buffFoodFound == false then
    l:SetText("|cff0000You have no food buff!|r")
    RegularSizedSpeedrun.RemindFood()
  end
end

function RegularSizedSpeedrun.UpdateFoodReminderInterval(time, interval)
  -- new set interval
  if (isReminding and interval > 0) then
    if not RegularSizedSpeedrun.foodUnlocked then SpeedRun_Food:SetHidden(true) end
  end
  nextReminder = time + interval
end

-- TODO: This should be called InTrial or to that effect and used elsewhere to remove replicated code.
local function shouldRemind()
  if not sV.food.show then return false end

  local inTrial = false
  local zone    = GetZoneId(GetUnitZoneIndex("player"))

  if RegularSizedSpeedrun.Data.raidList[zone] ~= nil then inTrial = true end
  --for id in pairs(RegularSizedSpeedrun.Data.raidList) do
  --  if id == zone then inTrial = true end
  --end

  return inTrial
end

function RegularSizedSpeedrun.ToggleFoodReminder()
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "Food")
  RegularSizedSpeedrun.ShowFoodReminder(false)
  if shouldRemind() then
    EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "Food", 2000, CheckFoodBuffs)
  end
end

-- SOUNDS.ABILITY_SYNERGY_READY = SOUNDS.NONE
