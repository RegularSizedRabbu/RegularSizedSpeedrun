RabbusSpeedrun              = RabbusSpeedrun or {}
local RabbusSpeedrun        = RabbusSpeedrun
local WM              = GetWindowManager()
local EM              = EVENT_MANAGER
local LAM             = LibAddonMenu2
local sV
local cV
local defaultDisplay  = {
  [1] = "BOSS 1",
  [2] = "BOSS 1 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
  [3] = "BOSS 2",
  [4] = "BOSS 2 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
  [5] = "BOSS 3",
  [6] = "BOSS 3 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
}
local profilesIcon    = "|cffdf80|t20:20:esoui\\art\\contacts\\social_status_online.dds|t|r"
local colorEnabled    = {.6, .57, .46, 1}
local colorDisabled   = {.3, .3 , .2 , 1}
local normalIcon      = "/esoui/art/lfg/gamepad/lfg_menuicon_normaldungeon.dds"
local vetIcon         = "/esoui/art/lfg/gamepad/lfg_menuicon_veteranldungeon.dds"

-- esoui\art\lfg\gamepad\lfg_roleicon_dps.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_dps_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_dps_up.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer_up.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank_up.dds
-- art\icons\poi\poi_areaofinterest_complete.dds
-- art\icons\poi\poi_group_house_glow.dds
-- art\icons\poi\poi_group_house_owned.dds
-- art\icons\poi\poi_group_house_unowned.dds

-------------------------
---- Variables    -------
-------------------------
local globalTimer
local previousSegment
local currentRaid
local bestPossibleTime
local uiTracked         = false
local numActiveSegments = 0
local hudHidden         = true
local huduiHidden       = true
local combatState       = false
-------------------------
---- Functions 		-------
-------------------------
local function SortProfileNames(a, b)
  return a < b
end

local function AddTooltipLine(control, tooltipControl, tooltip)
  local tooltipTextType = type(tooltip)
  if tooltipTextType == "string" then
    if tooltip == "" then ZO_Options_OnMouseExit(control) return end

  elseif tooltipTextType == "number" then	tooltip = GetString(tooltip)
  elseif tooltipTextType == "function" then tooltip = tooltip()
  else ZO_Options_OnMouseExit(control) return end

  SetTooltipText(tooltipControl, tooltip)
end

function RabbusSpeedrun.OnMouseEnter(control) --copy from ZO_Options_OnMouseEnter but modified to support multiple tooltip lines
  local tooltipText = control.tooltip
  if tooltipText ~= nil and #tooltipText > 0 then
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
    if type(tooltipText) == "table" then
      for i = 1, #tooltipText do
        AddTooltipLine(control, InformationTooltip, tooltipText[i])
      end
    else
      AddTooltipLine(control, InformationTooltip, tooltipText)
    end
  end
end

do
  local function lockUI()
    RabbusSpeedrun.ToggleUILocked()
  end

  local function hideGroup()
    RabbusSpeedrun.HideGroupToggle()
  end

  local function loadProfile(name)
    RabbusSpeedrun.LoadProfile(name)
  end

  local function portHome(outside)
    RequestJumpToHouse(GetHousingPrimaryHouse(), outside)
  end

  local function openMenu()
    LAM:OpenToPanel(RabbusSpeedrun_Settings)
  end

  local function testingHouse()
    RequestJumpToHouse(38)
  end

  function RabbusSpeedrun.Submenu( button, upInside )
    if not upInside then return end

    local sV            = RabbusSpeedrun.savedVariables
    local cV            = RabbusSpeedrun.savedSettings

    local lockString    = sV.unlockUI    and "Lock UI"      or "Unlock UI"
    local hgString      = cV.groupHidden and "Unhide Group" or "Hide Group"
    local profileString = "Load Profile"
    local homeString    = "Port Home"
    local menuString    = "Open Settings"

    local portOptions = {
      { label = "Inside",  callback = function() portHome(false) end },
      { label = "Outside", callback = function() portHome(true)  end }
    }

    RabbusSpeedrun.UpdateProfileList()
    ClearMenu()

    AddCustomMenuItem(hgString, hideGroup)

    if GetDisplayName() == "@nogetrandom" then AddCustomMenuItem(homeString, testingHouse)
    else AddCustomSubMenuItem(homeString, portOptions) end

    AddCustomSubMenuItem(profileString, RabbusSpeedrun.profileNames)
    AddCustomMenuItem(lockString, lockUI)
    AddCustomMenuItem(menuString, openMenu)

    ShowMenu(button)
    AnchorMenu(button)
  end

  function RabbusSpeedrun.UpdateProfileList()
    RabbusSpeedrun.profileNames	= {}
    local profileList     = {}
    local profileNames    = RabbusSpeedrun:GetProfileNames()

    table.sort(profileNames, SortProfileNames)

    for i = 1, #profileNames do
      if profileNames[i] ~= RabbusSpeedrun.activeProfile then
        local profile = profileNames[i]
        local function callbackfunc() loadProfile(profile) end
        table.insert(RabbusSpeedrun.profileNames, {label = profile, callback = callbackfunc})
      end
    end
  end
end

function RabbusSpeedrun.SaveLoc_Panel()
  sV["speedrun_panel_OffsetX"] = SpeedRun_Panel:GetLeft()
  sV["speedrun_panel_OffsetY"] = SpeedRun_Panel:GetTop()
end

function RabbusSpeedrun.SaveLoc_Food()
  sV.food.x = SpeedRun_Food:GetLeft()
  sV.food.y = SpeedRun_Food:GetTop()
end

function RabbusSpeedrun.GetActiveProfileDisplay()
  local profileDisplay = zo_strformat("|cffffff[ |cffdf80" .. RabbusSpeedrun.activeProfile .. " |cffffff]|r")
  return profileDisplay
end

function RabbusSpeedrun:GetProfileNames()
  local sV = RabbusSpeedrun.savedVariables
  local profiles = {}
  for name, v in pairs(sV.profiles) do table.insert(profiles, name) end
  return profiles
end

function RabbusSpeedrun.ResetUI()
  RabbusSpeedrun:dbg(2, "Resetting UI.")

  SpeedRun_Timer_Container:SetHeight(0)
  SpeedRun_TotalTimer_Title:SetText(" ")
  SpeedRun_Vitality_Label:SetText("  ")
  SpeedRun_Advanced_PreviousSegment:SetText(" ")
  SpeedRun_Advanced_PreviousSegment:SetColor(unpack { 1, 1, 1 })
  SpeedRun_Advanced_BestPossible_Value:SetText(" ")
  SpeedRun_Score_Label:SetText(" ")

  if RabbusSpeedrun.segments then
    for i,x in ipairs(RabbusSpeedrun.segments) do
      local name = WM:GetControlByName(x:GetName())
      x:SetHidden(true)
      name:GetNamedChild("_Name"):SetText(" ")
      name:GetNamedChild("_Best"):SetText(" ")
      name:GetNamedChild("_Diff"):SetText(" ")
    end
  end

  RabbusSpeedrun.ResetAddsUI()
  if RabbusSpeedrun.zone == 1227 then RabbusSpeedrun.UpdateAdds() end
  RabbusSpeedrun.isUIDrawn = false
  RabbusSpeedrun.isScoreSet = false
end

function RabbusSpeedrun.ResetAddsUI()
  SpeedRun_Adds_SA:SetText(" ")
  SpeedRun_Adds_SA_Counter:SetText(" ")
  SpeedRun_Adds_LA:SetText(" ")
  SpeedRun_Adds_LA_Counter:SetText(" ")
  SpeedRun_Adds_EA:SetText(" ")
  SpeedRun_Adds_EA_Counter:SetText(" ")
end

function RabbusSpeedrun.ResetAnchors()
  SpeedRun_Panel:ClearAnchors()
  SpeedRun_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV["speedrun_panel_OffsetX"], sV["speedrun_panel_OffsetY"])
  SpeedRun_Timer_Container:ClearAnchors()
  SpeedRun_Timer_Container:SetAnchor(TOPLEFT, SpeedRun_Panel, BOTTOMLEFT, 0, 0)
end

function RabbusSpeedrun.SetDefaultUI()
  SpeedRun_Timer_Container_Profile:SetText(RabbusSpeedrun.GetActiveProfileDisplay())

  numActiveSegments = 0

  for i, x in ipairs(defaultDisplay) do
    local segmentRow
    if WM:GetControlByName("SpeedRun_Segment", i) then
      segmentRow = WM:GetControlByName("SpeedRun_Segment", i)
    else
      segmentRow = WM:CreateControlFromVirtual("SpeedRun_Segment", SpeedRun_Timer_Container, "SpeedRun_Segment", i)
    end
    segmentRow:GetNamedChild('_Name'):SetText(x);

    if i == 1 then
      RabbusSpeedrun.segmentTimer[i] = 0
      segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, 40)
    else
      RabbusSpeedrun.segmentTimer[i] = 0 + RabbusSpeedrun.segmentTimer[i - 1]
      segmentRow:SetAnchor(TOPLEFT, RabbusSpeedrun.segments[i - 1], TOPLEFT, 0, 20)
    end
    segmentRow:GetNamedChild('_Best'):SetText(" ")

    segmentRow:SetHidden(false)
    RabbusSpeedrun.segments[i] = segmentRow;

    numActiveSegments = numActiveSegments + 1
  end
  SpeedRun_Vitality_Label:SetText(RabbusSpeedrun.FormatVitality(false, 36, 36))
  SpeedRun_TotalTimer_Title:SetText("--:--")
  SpeedRun_Score_Label:SetText("--'--")
  RabbusSpeedrun.SetSimpleUI(sV.uiSimple)
end

function RabbusSpeedrun.ToggleUILocked()
  sV.unlockUI = not sV.unlockUI
  SpeedRun_Panel:SetMovable(sV.unlockUI)
end

function RabbusSpeedrun.ToggleUIVisibility()
  sV.showUI = not sV.showUI
  RabbusSpeedrun.UpdateUIConfiguration()
end

function RabbusSpeedrun.SetUIHidden(hide)
  SpeedRun_Timer_Container:SetHidden(hide)
  SpeedRun_TotalTimer_Title:SetHidden(hide)
  SpeedRun_Vitality_Label:SetHidden(hide)
  SpeedRun_Score_Label:SetHidden(hide)

  local hideAdvanced = hide == true and hide or (not sV.showAdvanced)
  local hideAdds
  if RabbusSpeedrun.inMenu and RabbusSpeedrun.currentTrialMenu == 1227 then
    hideAdds = hide == true and hide or (not sV.showAdds)
  else
    if GetZoneId(GetUnitZoneIndex("player")) == 1227 then
      hideAdds = hide == true and hide or (not sV.showAdds)
    else
      hideAdds = true
    end
  end
  SpeedRun_Advanced:SetHidden(hideAdvanced)
  SpeedRun_Adds:SetHidden(hideAdds)
end

function RabbusSpeedrun.UpdateAlpha()
  local alpha
  if RabbusSpeedrun.inMenu then alpha = 1
  else
    if combatState then
      if sV.combatAlpha == 0
      then alpha = 0
      else alpha = (sV.combatAlpha / 100) end
    else alpha = 1 end
  end

  SpeedRun_Timer_Container:SetAlpha(alpha)
  SpeedRun_TotalTimer_Title:SetAlpha(alpha)
  SpeedRun_Vitality_Label:SetAlpha(alpha)
  SpeedRun_Score_Label:SetAlpha(alpha)
  SpeedRun_Advanced:SetAlpha(alpha)
  SpeedRun_Adds:SetAlpha(alpha)
end


function RabbusSpeedrun.ShowInMenu()
  local hide = not RabbusSpeedrun.inMenu
  SpeedRun_Timer_Container:SetHidden(hide)
  SpeedRun_TotalTimer_Title:SetHidden(hide)
  SpeedRun_Vitality_Label:SetHidden(hide)
  SpeedRun_Score_Label:SetHidden(hide)
  SpeedRun_Advanced:SetHidden(not sV.showAdvanced)
  if not hide and RabbusSpeedrun.currentTrialMenu == 1227 then
    SpeedRun_Adds:SetHidden(not sV.showAdds)
  end
end

function RabbusSpeedrun.UpdateAnchors()
  SpeedRun_Adds:ClearAnchors()
  if not sV.showAdvanced then
    SpeedRun_Adds:SetAnchor(TOPRIGHT, SpeedRun_TotalTimer, BOTTOMRIGHT, 0, 30)
  else
    SpeedRun_Adds:SetAnchor(TOPRIGHT, SpeedRun_TotalTimer, BOTTOMRIGHT, 0, 80)
  end
end

function RabbusSpeedrun.UpdateDifficultySwitch()
  local isVet = RabbusSpeedrun.ResolveTrialDiffculty()

  -- was changed from normal to veteran
  if isVet then	SpeedRun_Panel_Difficulty_Switch:SetTexture(vetIcon)
    -- was changed from veteran to normal
  else SpeedRun_Panel_Difficulty_Switch:SetTexture(normalIcon) end

  local canChange = CanPlayerChangeGroupDifficulty() and colorEnabled or colorDisabled
  SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(canChange))

  if ZO_GroupListVeteranDifficultySettings then
    ZO_GroupListVeteranDifficultySettings.veteranModeButton:SetState(isVet and BSTATE_PRESSED or BSTATE_NORMAL )
    ZO_GroupListVeteranDifficultySettings.normalModeButton:SetState (isVet and BSTATE_NORMAL  or BSTATE_PRESSED)
  end
end

function RabbusSpeedrun.ToggleDifficulty()
  -- do nothing if setting is unavailable
  if not CanPlayerChangeGroupDifficulty() then SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorDisabled)) return end

  local vet = IsUnitUsingVeteranDifficulty('player')
  SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorEnabled))
  SetVeteranDifficulty(not vet)
  RabbusSpeedrun.UpdateDifficultySwitch(not vet)
end

function RabbusSpeedrun.DifficultyOnMouseEnter()
  if CanPlayerChangeGroupDifficulty() then
    -- highlight button on mouseover
    SpeedRun_Panel_Difficulty_Switch:SetColor(.9, .9, .8, 1)
  end
end

function RabbusSpeedrun.DifficultyOnMouseExit()
  -- set brightness to reflect availability of setting
  if CanPlayerChangeGroupDifficulty() then
    SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorEnabled))
  else
    SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorDisabled))
  end
end

local function UpdateSimpleUISwitch(simple)
  if simple then
    SpeedRun_Timer_Container_Segments_Switch:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")
  else
    SpeedRun_Timer_Container_Segments_Switch:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")
  end
end

function RabbusSpeedrun.ToggleSimpleUI()
  sV.uiSimple = not sV.uiSimple
  RabbusSpeedrun.SetSimpleUI(sV.uiSimple)
end

function RabbusSpeedrun.ResetSegments()
  for i,x in ipairs(RabbusSpeedrun.segments) do
    local name = WM:GetControlByName(x:GetName())
    x:SetHidden(true)
    x:SetHeight(0)
    name:GetNamedChild("_Name"):SetText(" ")
    name:GetNamedChild("_Best"):SetText(" ")
    name:GetNamedChild("_Diff"):SetText(" ")
    name:GetNamedChild("_Name"):SetHeight(0)
    name:GetNamedChild("_Best"):SetHeight(0)
    name:GetNamedChild("_Diff"):SetHeight(0)
  end
end

function RabbusSpeedrun.SetSimpleUI(simple)
  for i = 1, numActiveSegments do
    local segment = WM:GetControlByName(RabbusSpeedrun.segments[i]:GetName())
    if segment then
      local n = segment:GetNamedChild('_Name')
      local d = segment:GetNamedChild('_Diff')
      local b = segment:GetNamedChild('_Best')
      local h = simple == true and 0 or 23
      local H = simple == true and 0 or 5
      n:SetHeight(h)
      d:SetHeight(h)
      b:SetHeight(h)
      segment:SetHidden(simple)
      segment:SetHeight(H)

      if simple then
        h = 49
      else
        h = 49 + (20 * numActiveSegments)
      end
      SpeedRun_Timer_Container:SetHeight(h)
    end
  end
  UpdateSimpleUISwitch(simple)
end

function RabbusSpeedrun.CreateRaidSegmentFromMenu(raidID)
  RabbusSpeedrun.CreateRaidSegment(raidID)
  SpeedRun_Score_Label:SetText(RabbusSpeedrun.BestPossible(raidID))
  -- SpeedRun_TotalTimer_Title:SetText("00:00")
  SpeedRun_TotalTimer_Title:SetText("--:--")
  local v = RabbusSpeedrun.GetTrialMaxVitality(raidID)
  SpeedRun_Vitality_Label:SetText(RabbusSpeedrun.FormatVitality(false, v, v))
end

function RabbusSpeedrun.FormatVitality(chat, current, max)
  local displayVitality = ""
  if current and max then
    if chat then
      if current == max then
        displayVitality = "[Vitality: |c00ff00" .. current .. "|r / " .. "|c00ff00" .. max .. "|r]"
      elseif current <= 0 then
        displayVitality = "[Vitality: |cff0000" .. current .. "|r / " .. "|cff0000" .. max .. "|r]"
      elseif current > 0 and current < max then
        displayVitality = "[Vitality: |cffffff" .. current .. "|r / " .. "|cffffff" .. max .. "|r]"
      end
    else
      if current == max then
        displayVitality = "|c00ff00" .. current .. "|r / " .. "|c00ff00" .. max .. "|r"
      elseif current <= 0 then
        displayVitality = "|cff0000" .. current .. "|r / " .. "|cff0000" .. max .. "|r"
      elseif current > 0 and current < max then
        displayVitality = "|cffffff" .. current .. "|r / " .. "|cffffff" .. max .. "|r"
      end
    end
  end
  return displayVitality
end

function RabbusSpeedrun.UpdateGlobalTimer()
  if (not RabbusSpeedrun.IsInTrialZone()) then return end
  local timer
  if RabbusSpeedrun.FormatRaidTimer(GetRaidDuration(), true) ~= nil
  then timer = RabbusSpeedrun.FormatRaidTimer(GetRaidDuration(), true)
  else timer = "00:00" end
  -- GetRaidTargetTime()
  SpeedRun_TotalTimer_Title:SetText(timer)
  -- if (bestPossibleTime == nil or RabbusSpeedrun.segmentTimer[RabbusSpeedrun.Step] == RabbusSpeedrun.segmentTimer[RabbusSpeedrun.Step + 1]) then
  RabbusSpeedrun.UpdateCurrentScore()
  -- end
end

function RabbusSpeedrun.UpdateCurrentVitality()
  local mVitality = GetCurrentRaidStartingReviveCounters()
  local cVitality = GetRaidReviveCountersRemaining()
  if not mVitality then return end
  SpeedRun_Vitality_Label:SetText(RabbusSpeedrun.FormatVitality(false, cVitality, mVitality))
end

function RabbusSpeedrun.UpdateCurrentScore()
  -- local timer
  -- if bestPossibleTime then
  --   if RabbusSpeedrun.segmentTimer[RabbusSpeedrun.Step] == RabbusSpeedrun.segmentTimer[RabbusSpeedrun.Step + 1] or RabbusSpeedrun.segmentTimer[RabbusSpeedrun.Step + 1] == nil  then
  --     timer = GetRaidDuration() / 1000
  --   else timer = bestPossibleTime / 1000 end
  -- else timer = GetRaidDuration() / 1000 end

  local scoreString
  if RabbusSpeedrun.isComplete == false then
    if IsRaidInProgress() then
      local timer = GetRaidDuration() / 1000
      local score = math.floor(RabbusSpeedrun.GetScore(timer, GetRaidReviveCountersRemaining(), RabbusSpeedrun.raidID))
      if score <= 0
      then scoreString = "0"
      else scoreString = RabbusSpeedrun.FormatRaidScore(score)
      end
    else
      scoreString = RabbusSpeedrun.BestPossible(RabbusSpeedrun.zone)
    end
  else
    -- in case trial is completed but player is only moving between areas inside the trial.
    scoreString = RabbusSpeedrun.FormatRaidScore(sV.finalScore)
  end
  SpeedRun_Score_Label:SetText(scoreString)
end

function RabbusSpeedrun.UpdateWindowPanel(waypoint, raid)
  waypoint = waypoint or 1
  raid = raid or nil

  if waypoint and raid then RabbusSpeedrun.UpdateSegment(waypoint, raid) end
  RabbusSpeedrun.UpdateGlobalTimer()
end

local function SetSegment(row, step)
  row:GetNamedChild('_Best'):SetText(RabbusSpeedrun.FormatRaidTimer(RabbusSpeedrun.segmentTimer[step], true))
  bestPossibleTime = RabbusSpeedrun.segmentTimer[step]

  local bestTime = RabbusSpeedrun.FormatRaidTimer(RabbusSpeedrun.segmentTimer[step], true)
  SpeedRun_Advanced_BestPossible_Value:SetText(bestTime)
end

function RabbusSpeedrun.CreateRaidSegment(id, same)
  --Reset segment control
  RabbusSpeedrun.segmentTimer = {}
  numActiveSegments     = 0
  RabbusSpeedrun.ResetSegments()

  SpeedRun_Timer_Container_Profile:SetText(RabbusSpeedrun.GetActiveProfileDisplay())
  SpeedRun_Timer_Container_Raid:SetText("|ce6b800" .. zo_strformat(SI_ZONE_NAME, GetZoneNameById(id)).. "|r")

  for i, x in ipairs(RabbusSpeedrun.Data.stepList[id]) do
    local segmentRow

    if WM:GetControlByName("SpeedRun_Segment", i) then segmentRow = WM:GetControlByName("SpeedRun_Segment", i)
    else segmentRow = WM:CreateControlFromVirtual("SpeedRun_Segment", SpeedRun_Timer_Container, "SpeedRun_Segment", i) end

    segmentRow:GetNamedChild('_Name'):SetText(x);

    if same and RabbusSpeedrun.Step > 1 then
      if RabbusSpeedrun.currentRaidTimer[i] then
        if i == 1 then
          RabbusSpeedrun.segmentTimer[i] = RabbusSpeedrun.currentRaidTimer[i]
        else
          RabbusSpeedrun.segmentTimer[i] = RabbusSpeedrun.currentRaidTimer[i] + RabbusSpeedrun.segmentTimer[i - 1]
        end
        SetSegment(segmentRow, i)
      else
        if RabbusSpeedrun.GetSavedTimer(id, i) then
          RabbusSpeedrun.segmentTimer[i] = RabbusSpeedrun.GetSavedTimer(id, i) + RabbusSpeedrun.segmentTimer[i - 1]
          SetSegment(segmentRow, i)
        else
          RabbusSpeedrun.segmentTimer[i] = 0 + RabbusSpeedrun.segmentTimer[i - 1]
          segmentRow:GetNamedChild('_Best'):SetText(" ")
          bestPossibleTime = 0
          SpeedRun_Advanced_BestPossible_Value:SetText(" ")
        end
      end
    else
      if RabbusSpeedrun.GetSavedTimer(id, i) then
        if i == 1 then RabbusSpeedrun.segmentTimer[i] = RabbusSpeedrun.GetSavedTimer(id, i)
        else RabbusSpeedrun.segmentTimer[i] = RabbusSpeedrun.GetSavedTimer(id, i) + RabbusSpeedrun.segmentTimer[i - 1] end

        SetSegment(segmentRow, i)

        -- segmentRow:GetNamedChild('_Best'):SetText(RabbusSpeedrun.FormatRaidTimer(RabbusSpeedrun.segmentTimer[i], true))
        -- bestPossibleTime = RabbusSpeedrun.segmentTimer[i]
        --
        -- local bestTime = RabbusSpeedrun.FormatRaidTimer(RabbusSpeedrun.segmentTimer[i], true)
        -- SpeedRun_Advanced_BestPossible_Value:SetText(bestTime)
      else
        if i == 1 then RabbusSpeedrun.segmentTimer[i] = 0
        else RabbusSpeedrun.segmentTimer[i] = 0 + RabbusSpeedrun.segmentTimer[i - 1] end
        segmentRow:GetNamedChild('_Best'):SetText(" ")
        bestPossibleTime = 0
        SpeedRun_Advanced_BestPossible_Value:SetText(" ")
      end
    end

    if i == 1 then
      segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, 40)
    else
      -- segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, (i * 20) + 20)
      segmentRow:SetAnchor(TOPLEFT, RabbusSpeedrun.segments[i - 1], TOPLEFT, 0, 20)
    end

    segmentRow:SetHidden(false)
    RabbusSpeedrun.segments[i] = segmentRow;
    numActiveSegments    = numActiveSegments + 1
  end

  SpeedRun_Timer_Container_Raid:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  RabbusSpeedrun.UpdateGlobalTimer()
  RabbusSpeedrun.isUIDrawn = true
  RabbusSpeedrun.SetSimpleUI(sV.uiSimple)
  RabbusSpeedrun.SetUIHidden(not sV.showUI)

  if (id == 677 or id == 1227) and cV.individualArenaTimers then
    RabbusSpeedrun:dbg(1, "|cffdf80<<1>>'s|r individual |ce6b800<<2>> |cfffffftimers loaded|r.", GetUnitName('player'), GetZoneNameById(id))
  else
    RabbusSpeedrun:dbg(1, "<<1>> |ce6b800<<2>> |cfffffftimers loaded|r.", RabbusSpeedrun.GetActiveProfileDisplay(), GetZoneNameById(id))
  end
end

function RabbusSpeedrun.UpdateSegment(step, raid)
  --TODO Divide into multiple function
  -- if raid == nil then
  --     raid = GetZoneId(GetUnitZoneIndex("player"))
  -- end

  local difference
  if (RabbusSpeedrun.segmentTimer[step] ~= nil and RabbusSpeedrun.segmentTimer[step] ~= RabbusSpeedrun.segmentTimer[step + 1])  then
    difference = RabbusSpeedrun.currentRaidTimer[step] - RabbusSpeedrun.segmentTimer[step]
  else difference = 0 end

  --TODO correct previousSegementDif
  local previousSegementDif = 0
  if step > 1 then
    if RabbusSpeedrun.GetSavedTimer(RabbusSpeedrun.raidID, step) then
      if RabbusSpeedrun.currentRaidTimer[step - 1] ~= nil then
        previousSegementDif = RabbusSpeedrun.currentRaidTimer[step] - RabbusSpeedrun.currentRaidTimer[step - 1] - RabbusSpeedrun.GetSavedTimer(RabbusSpeedrun.raidID, step)
      else
        previousSegementDif = 0
      end
    end

  elseif step == 1 then
    if RabbusSpeedrun.GetSavedTimer(RabbusSpeedrun.raidID, step) then
      previousSegementDif = RabbusSpeedrun.currentRaidTimer[step] - RabbusSpeedrun.GetSavedTimer(RabbusSpeedrun.raidID, step)
    else
      previousSegementDif = 0
    end
  end

  --TODO IF NO PRESAVED TIME
  if RabbusSpeedrun.segmentTimer[table.getn(RabbusSpeedrun.segmentTimer)] then
    bestPossibleTime = difference + RabbusSpeedrun.segmentTimer[table.getn(RabbusSpeedrun.segmentTimer)]
    SpeedRun_Advanced_BestPossible_Value:SetText(RabbusSpeedrun.FormatRaidTimer(bestPossibleTime))
  else
    SpeedRun_Advanced_BestPossible_Value:SetText(" ")
  end

  SpeedRun_Advanced_PreviousSegment:SetText(RabbusSpeedrun.FormatRaidTimer(previousSegementDif))

  if RabbusSpeedrun.Step and RabbusSpeedrun.currentRaidTimer[RabbusSpeedrun.Step] and RabbusSpeedrun.segments[RabbusSpeedrun.Step] then
    RabbusSpeedrun.segments[RabbusSpeedrun.Step]:GetNamedChild('_Best'):SetText(RabbusSpeedrun.FormatRaidTimer(RabbusSpeedrun.currentRaidTimer[RabbusSpeedrun.Step]))
  end

  local segment = RabbusSpeedrun.segments[RabbusSpeedrun.Step]:GetNamedChild('_Diff')
  segment:SetText(RabbusSpeedrun.FormatRaidTimer(difference, true))
  RabbusSpeedrun.DifferenceColor(difference, segment)
  RabbusSpeedrun.DifferenceColor(previousSegementDif, SpeedRun_Advanced_PreviousSegment)
end

function RabbusSpeedrun.DifferenceColor(diff, segment)
  if diff > (-0.001) then
    segment:SetColor(unpack { 1, 0, 0 })
  else
    segment:SetColor(unpack { 0, 1, 0 })
  end
end

function RabbusSpeedrun.ShowFoodReminder(show)
  SpeedRun_Food:SetHidden(not show)
  SpeedRun_Food:SetMouseEnabled(show)
  SpeedRun_Food:SetMovable(show)
end

function RabbusSpeedrun.UpdateFoodReminderSize()
  local path = "EsoUI/Common/Fonts/univers67.otf"
  local outline = "soft-shadow-thick"
  SpeedRun_Food_Label:SetFont(path .. "|" .. sV.food.size .. "|" .. outline)
end

local function shouldHideUI()
  if RabbusSpeedrun.inMenu then return false end
  if (hudHidden and huduiHidden) then return true end
  if (sV.showUI ~= true) or (cV.isTracking ~= true) then return true end
  if not RabbusSpeedrun.IsInTrialZone() then return true end
  -- if (sV.hideInCombat and IsUnitInCombat("player")) then return true end
  return false
end

local function shouldHidePanel()
  if not sV.showPanelAlways then return shouldHideUI() end
  if RabbusSpeedrun.inMenu then return false end
  if (hudHidden and huduiHidden) then return true end
  return false
end

function RabbusSpeedrun.UpdateVisibility()
  local hidden = SpeedRun_Timer_Container:IsHidden()
  local hide   = shouldHideUI()
  if (hidden ~= hide) then RabbusSpeedrun.SetUIHidden(hide) end
  SpeedRun_Panel:SetHidden(shouldHidePanel())
  RabbusSpeedrun.UpdateAlpha()
end

function RabbusSpeedrun.UpdateUIConfiguration()
  local h = SCENE_MANAGER:GetScene("hud")
  local hUI = SCENE_MANAGER:GetScene("hudui")

  local function OnStateChangedHud(oldState, newState)


    -- if (sV.showUI ~= true) or (cV.isTracking ~= true) then
    --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    --   RabbusSpeedrun.SetUIHidden(true)
    --   return
    -- end

    if newState == SCENE_SHOWN then
      hudHidden = false
      -- if RabbusSpeedrun.IsInTrialZone() then
      --   SpeedRun_Panel:SetHidden(false)
      --   RabbusSpeedrun.SetUIHidden(false)
      -- else
      --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
      --   RabbusSpeedrun.SetUIHidden(true)
      -- end
    else
      hudHidden = true
      -- SpeedRun_Panel:SetHidden(true)
      -- RabbusSpeedrun.SetUIHidden(true)
    end
    RabbusSpeedrun.UpdateVisibility()
  end

  local function OnStateChangedHudUI(oldState, newState)

    -- if (sV.showUI ~= true) or (cV.isTracking ~= true) then
    --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    --   RabbusSpeedrun.SetUIHidden(true)
    --   return
    -- end

    if newState == SCENE_SHOWN then
      huduiHidden = false
      -- if RabbusSpeedrun.IsInTrialZone() then
      --   SpeedRun_Panel:SetHidden(false)
      --   RabbusSpeedrun.SetUIHidden(false)
      -- else
      --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
      --   RabbusSpeedrun.SetUIHidden(true)
      -- end
    else
      huduiHidden = true
      -- SpeedRun_Panel:SetHidden(true)
      -- RabbusSpeedrun.SetUIHidden(true)
    end

    RabbusSpeedrun.UpdateVisibility()
  end

  EM:UnregisterForEvent(RabbusSpeedrun.name .. "HideInCombat", EVENT_PLAYER_COMBAT_STATE)

  local function enableUI()
    if not RabbusSpeedrun.isUIDrawn then RabbusSpeedrun.SetDefaultUI() end

    h:RegisterCallback("StateChange", OnStateChangedHud)
    hUI:RegisterCallback("StateChange", OnStateChangedHudUI)


    -- if (not RabbusSpeedrun.inMenu) then RabbusSpeedrun.SetUIHidden(shouldHideUI()) end

    RabbusSpeedrun.UpdateVisibility()

    uiTracked = true
  end

  local function disableUI()
    h:UnregisterCallback("StateChange")
    hUI:UnregisterCallback("StateChange")

    RabbusSpeedrun.UpdateVisibility()
    -- SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    -- RabbusSpeedrun.SetUIHidden(true)
    uiTracked = false
  end

  if not sV.showPanelAlways then
    if (not sV.showUI) or (not cV.isTracking) then disableUI() return end
  end

  if sV.changeAlpha then
    EM:RegisterForEvent(RabbusSpeedrun.name .. "HideInCombat", EVENT_PLAYER_COMBAT_STATE, function()
      combatState = IsUnitInCombat("player")
      RabbusSpeedrun.UpdateVisibility()
    end)
  end

  if uiTracked == false then enableUI() end
end

function InitiatePanelOptions(p)
  p:SetHidden(false)
  p.tooltip = "Open dropdown"
end

function RabbusSpeedrun.InitiateUI()
  sV = RabbusSpeedrun.savedVariables
  cV = RabbusSpeedrun.savedSettings

  RabbusSpeedrun.SetUIHidden(true)
  RabbusSpeedrun.ResetUI()
  RabbusSpeedrun.ResetAnchors()
  RabbusSpeedrun.SetDefaultUI()
  RabbusSpeedrun.UpdateAnchors()
  SpeedRun_Panel:SetMovable(sV.unlockUI)

  local food = SpeedRun_Food
  food:ClearAnchors()

  if (sV.food.x == 0 and sV.food.y == 0)
  then food:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  else food:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.food.x, sV.food.y) end

  RabbusSpeedrun.UpdateFoodReminderSize()
  RabbusSpeedrun.UpdateFoodReminderInterval(GetGameTimeMilliseconds() / 1000, 0)

  local options = SpeedRun_Panel:GetNamedChild("_Options")
  InitiatePanelOptions(options)
  RabbusSpeedrun.UpdateDifficultySwitch()

  if (not sV.showPanelAlways and ((sV.showUI ~= true) or (cV.isTracking ~= true))) then return end

  RabbusSpeedrun.UpdateUIConfiguration()
  EM:RegisterForEvent(RabbusSpeedrun.name .. "Leader", EVENT_LEADER_UPDATE, RabbusSpeedrun.UpdateDifficultySwitch)
  EM:RegisterForEvent(RabbusSpeedrun.name .. "LeftGroup", EVENT_GROUP_MEMBER_LEFT, RabbusSpeedrun.UpdateDifficultySwitch)
  EM:AddFilterForEvent(RabbusSpeedrun.name .. "LeftGroup", EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")
end

--[[
	/script d(SCENE_MANAGER:GetHUDSceneName())
	/script d(SCENE_MANAGER.currentScene)
	/script d(SCENE_MANAGER:IsShowingBaseScene())
	/script d(IsReticleHidden())

	/script zo_callLater(function() d(SCENE_MANAGER:IsShowingBaseScene()) end, 1000)
]]
