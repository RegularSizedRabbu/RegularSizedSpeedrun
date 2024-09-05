RabbusSpeedrun              = RabbusSpeedrun or {}
local RabbusSpeedrun              = RabbusSpeedrun
local LAM                   = LibAddonMenu2
local wm                    = WINDOW_MANAGER
local EM                    = EVENT_MANAGER
local CM                    = CALLBACK_MANAGER
local sV
local cV
local isST                  = false
local profileToAdd          = ""
local profileToLoad         = ""
local profileToDelete       = ""
-- local profileToCopyFrom     = ""
-- local profileToCopyTo       = ""
local trialMenuTimers       = {
  [635]   = {},
  [636]   = {},
  [638]   = {},
  [639]   = {},
  [677]   = {},
  [725]   = {},
  [975]   = {},
  [1000]  = {},
  [1051]  = {},
  [1082]  = {},
  [1121]  = {},
  [1196]  = {},
  [1227]  = {},
  [1263]  = {},
  [1427]  = {},
  [1478]  = {}
}
local trialSubmenus         = {
  [635]  = {},
  [636]  = {},
  [638]  = {},
  [639]  = {},
  [677]  = {},
  [725]  = {},
  [975]  = {},
  [1000] = {},
  [1051] = {},
  [1082] = {},
  [1121] = {},
  [1196] = {},
  [1227] = {},
  [1263] = {},
  [1427] = {},
  [1478] = {}
}
local NAMEPLATE_CHOICE_NEVER                = NAMEPLATE_CHOICE_NEVER
local NAMEPLATE_CHOICE_ALWAYS               = NAMEPLATE_CHOICE_ALWAYS
local NAMEPLATE_CHOICE_INJURED              = NAMEPLATE_CHOICE_INJURED
local NAMEPLATE_CHOICE_TARGETED             = NAMEPLATE_CHOICE_TARGETED
local NAMEPLATE_CHOICE_INJURED_OR_TARGETED  = NAMEPLATE_CHOICE_INJURED_OR_TARGETED
local npGroupHiddenSettings  = {
  ["never"]   = NAMEPLATE_CHOICE_NEVER,    -- 1
  ["always"]  = NAMEPLATE_CHOICE_ALWAYS,   -- 2
  ["injured"] = NAMEPLATE_CHOICE_INJURED   -- 3
}
local npGroupShownSettings   = {
  ["never"]               = NAMEPLATE_CHOICE_NEVER,                -- 1
  ["always"]              = NAMEPLATE_CHOICE_ALWAYS,               -- 2
  ["injured"]             = NAMEPLATE_CHOICE_INJURED,              -- 3
  ["targeted"]            = NAMEPLATE_CHOICE_TARGETED,             -- 8
  ["injured or targeted"] = NAMEPLATE_CHOICE_INJURED_OR_TARGETED   -- 9 NAMEPLATE_CHOICE_HURT,
}
local npGroupHiddenOptions            = {
  [NAMEPLATE_CHOICE_NEVER]                = "never",
  [NAMEPLATE_CHOICE_ALWAYS]               = "always",
  [NAMEPLATE_CHOICE_INJURED]              = "injured",
}
local npGroupShownOptions  = {
  [NAMEPLATE_CHOICE_NEVER]                = "never",                -- 1
  [NAMEPLATE_CHOICE_ALWAYS]               = "always",               -- 2
  [NAMEPLATE_CHOICE_INJURED]              = "injured",              -- 3
  [NAMEPLATE_CHOICE_TARGETED]             = "targeted",             -- 8
  [NAMEPLATE_CHOICE_INJURED_OR_TARGETED]  = "injured or targeted"   -- 9 NAMEPLATE_CHOICE_HURT,
}
local isChangingToFalse = false
----------------------------------------------------------------------------------------------------------
------------------------------------[   NAMEPLATES   ]----------------------------------------------------
----------------------------------------------------------------------------------------------------------
local function OnNameplatesChanged(eventCode, type, id)
  -- 18           = NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES
  -- 19           = NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS
  -- 20           = NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT
  -- 21           = NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT
  -- nameplates   = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES),
  -- healthBars   = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS),
  -- nameplatesHL = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT),
  -- healthBarsHL = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT),
  if RabbusSpeedrun.isLocalChange == false and type == SETTING_TYPE_NAMEPLATES then
    if id == NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES then
      sV.nameplates = GetSetting(type, id)
    elseif id == NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS then
      sV.healthBars = GetSetting(type, id)
    elseif id == NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT then
      sV.nameplatesHL = GetSetting(type, id)
    elseif id == NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT then
      sV.healthBarsHL = GetSetting(type, id)
    end
  end
  if RabbusSpeedrun.isLocalChange == true and isChangingToFalse == false then
    isChangingToFalse = true
    zo_callLater(function()
      RabbusSpeedrun.isLocalChange = false
      isChangingToFalse = false
      CM:FireCallbacks("LAM-RefreshPanel", RabbusSpeedrun_Settings)
    end, 500)
  end
end

function RabbusSpeedrun.GetSavedNameplateSetting(value)
  local option = npGroupShownOptions[value]
  if option then return option end
end

local function GetNameplateChoice(value)
  local choice = npGroupShownSettings[value]
  if choice then return choice end
end

function RabbusSpeedrun.GetNameplateGroupHiddenOptions()
  local h = {}
  for option in pairs(npGroupHiddenSettings) do table.insert(h, option) end
  return h
end

function RabbusSpeedrun.GetNameplateGroupShownOptions()
  local s = {}
  for option in pairs(npGroupShownSettings) do table.insert(s, option) end
  return s
end

function RabbusSpeedrun.ApplyNameplateGroupHiddenChoice()
  if cV.groupHidden and sV.changeNameplates then
    RabbusSpeedrun.isLocalChange = true
    local setting = npGroupHiddenSettings[sV.nameplatesHidden]
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(setting))
    RabbusSpeedrun.npChanged = true
    zo_callLater(function() RabbusSpeedrun.isLocalChange = false end, 500)
  end
end

function RabbusSpeedrun.ApplyHealthbarGroupHiddenChoice()
  if cV.groupHidden and sV.changeHealthBars then
    RabbusSpeedrun.isLocalChange = true
    local setting = npGroupHiddenSettings[sV.healthBarsHidden]
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(setting))
    RabbusSpeedrun.hbChanged = true
  end
end

function RabbusSpeedrun.ApplyNameplateHighlightGroupHiddenChoice()
  if cV.groupHidden and sV.changeNameplates then
    RabbusSpeedrun.isLocalChange = true
    local setting = npGroupHiddenSettings[sV.nameplatesHiddenHL]
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT, tostring(setting))
    RabbusSpeedrun.npHlChanged = true
  end
end

function RabbusSpeedrun.ApplyHealthbarHighlightGroupHiddenChoice()
  if cV.groupHidden and sV.changeHealthBars then
    RabbusSpeedrun.isLocalChange = true
    local setting = npGroupHiddenSettings[sV.healthBarsHiddenHL]
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT, tostring(setting))
    RabbusSpeedrun.hbHlChanged = true
  end
end
----------------------------------------------------------------------------------------------------------
------------------------------------[    PROFILE     ]----------------------------------------------------
----------------------------------------------------------------------------------------------------------
function RabbusSpeedrun.CreateProfileDescriptionTitle()
  local parent = RabbusSpeedrun_ProfileSubmenu
  local data = { type = "description" }
  local name = "RabbusSpeedrun_ActiveProfileDecriptionTitle"
  local control = LAM.util.CreateBaseControl(parent, data, name)
  -- local control = wm:CreateControl(name, parent, CT_CONTROL)
  local width = (parent:GetWidth() - 60) / 2	--225

  control:SetWidth(width)
  control:SetResizeToFitDescendents(true)
  control:SetDimensionConstraints(width, 0, width, 0)

  control.title =	wm:CreateControl(nil, control, CT_LABEL)
  local title = control.title
  title:SetWidth(width)
  title:SetAnchor(TOPLEFT, control, TOPLEFT)
  title:SetFont("ZoFontWinH4")
  title:SetText("Currently Active Profile:")
  return control
end

function RabbusSpeedrun.CreateProfileDescriptionDisplay()
  local parent = "RabbusSpeedrun_ProfileSubmenu"
  local name = "RabbusSpeedrun_ActiveProfileDecriptionName"
  local control = wm:CreateControl(name, parent, CT_CONTROL)
  local width = 225

  control:SetWidth(width)
  control:SetResizeToFitDescendents(true)
  control:SetDimensionConstraints(width, 0, width, 0)

  local title = wm:CreateControl(nil, control, CT_LABEL)
  title:SetWidth(width)
  title:SetAnchor(TOPRIGHT, control, TOPRIGHT)
  title:SetFont("ZoFontWinH4")
  title:SetText(RabbusSpeedrun.GetActiveProfileDisplay())
  return control
end

function RabbusSpeedrun:GetProfileNames()
  local profiles 				= {}
  RabbusSpeedrun.numProfiles  = 0

  for name, v in pairs(sV.profiles) do
    table.insert(profiles, name)
    RabbusSpeedrun.numProfiles = RabbusSpeedrun.numProfiles	+ 1
  end
  return profiles
end

function RabbusSpeedrun:GetProfileNamesToCopyTo()
  local profilesToCopyTo = {}
  for name, v in pairs(sV.profiles) do
    if name ~= profileToCopyFrom then table.insert(profilesToCopyTo, name) end
  end
  return profilesToCopyTo
end

function RabbusSpeedrun.AddProfile()
  local name = RabbusSpeedrun_ProfileEditbox.editbox:GetText()
  RabbusSpeedrun:dbg(0, "Adding new profile [<<1>>]", name)

  if name == "Default" then return end
  if sV.profiles[name] ~= nil then RabbusSpeedrun:dbg(0, "Profile [".. name .."] Already Exist!") return end

  if (name ~= "") then
    sV.profiles[name] = RabbusSpeedrun.GetDefaultProfile()
    RabbusSpeedrun.activeProfile = name
    cV.activeProfile = RabbusSpeedrun.activeProfile
    RabbusSpeedrun.LoadProfile(name)
    -- RabbusSpeedrun.UpdateDropdowns()

  else RabbusSpeedrun:dbg(0, "Failed to add profile!") end
  profileToAdd = ""
end

function RabbusSpeedrun.CopyProfile(from, to)
  for k, v in pairs(sV.profiles) do
    if sV.profiles[k] == to then
      sV.profiles[k]  = {}
      sV.profiles[k]  = sV.profiles[from]
    end
  end
  if (sV.profiles[to] == RabbusSpeedrun.activeProfile and RabbusSpeedrun.IsInTrialZone()) then ReloadUI("ingame") end
  profileToCopyFrom = ""
  profileToCopyTo   = ""
end

function RabbusSpeedrun.DeleteProfile(name)
  local name = profileToDelete	-- = RabbusSpeedrun_ProfileDeleteDropdown.data.getFunc() -- profileToDelete
  local setDefault = profileToDelete == RabbusSpeedrun.activeProfile and true or false

  -- "Default" profile can't be deleted
  if name == "Default" then
    RabbusSpeedrun:dbg(0, "[Default] can't be deleted!")
    return
  end

  RabbusSpeedrun:dbg(0, "Deleting profile: [<<1>>]", name)

  -- update profile vars
  local new_list = { }
  for k, v in pairs(sV.profiles) do
    if name ~= k then new_list[k] = v end
  end
  sV.profiles = new_list

  -- set "Default" as active if deleted profile was active
  if setDefault == true then RabbusSpeedrun.LoadProfile("Default")
  else RabbusSpeedrun.UpdateDropdowns() end
  profileToDelete = ""
end

function RabbusSpeedrun.LoadProfile(name)
  if sV.profiles[name] == nil then RabbusSpeedrun:dbg(0, "ERROR! Profile: [<<1>>] not found.", name) return end
  if sV.profiles[name] == RabbusSpeedrun.activeProfile then RabbusSpeedrun:dbg(0, "Profile: [<<1>>] is already active.", name) return end

  RabbusSpeedrun.activeProfile = name
  cV.activeProfile = RabbusSpeedrun.activeProfile

  RabbusSpeedrun:dbg(0, "Loading profile: <<1>>", RabbusSpeedrun.GetActiveProfileDisplay())

  -- profileToLoad = ""

  RabbusSpeedrun.ValidateProfile(RabbusSpeedrun.activeProfile)
  RabbusSpeedrun.RefreshProfileSettings()

  if RabbusSpeedrun.IsInTrialZone() then
    RabbusSpeedrun.ResetUI()
    RabbusSpeedrun.CreateRaidSegment(RabbusSpeedrun.raidID)
    if GetRaidDuration() <= 0 and not IsRaidInProgress() then SpeedRun_Score_Label:SetText(RabbusSpeedrun.BestPossible(RabbusSpeedrun.raidID)) end
    RabbusSpeedrun.UpdateCurrentVitality()
  else
    if RabbusSpeedrun.inMenu then
      if RabbusSpeedrun.currentTrialMenu ~= nil then RabbusSpeedrun.CreateRaidSegment(RabbusSpeedrun.currentTrialMenu)
      else
        if RabbusSpeedrun.isUIDrawn then RabbusSpeedrun.CreateRaidSegment(RabbusSpeedrun.raidID)
        else SpeedRun_Timer_Container_Profile:SetText(RabbusSpeedrun.GetActiveProfileDisplay()) end
      end
    else SpeedRun_Timer_Container_Profile:SetText(RabbusSpeedrun.GetActiveProfileDisplay()) end
  end
end

function RabbusSpeedrun.UpdateDropdowns()
  if RabbusSpeedrun.inMenu then
    local profileNames = RabbusSpeedrun:GetProfileNames()
    RabbusSpeedrun_ProfileDropdown:UpdateChoices(profileNames)
    RabbusSpeedrun_ProfileDeleteDropdown:UpdateChoices(profileNames)

    -- RabbusSpeedrun_ProfileCopyFrom:UpdateChoices(profileNames)
    -- RabbusSpeedrun_ProfileCopyTo:UpdateChoices(RabbusSpeedrun:GetProfileNamesToCopyTo())
    RabbusSpeedrun_ProfileImportTo:UpdateChoices(profileNames)
  end
  -- RabbusSpeedrun.UpdateProfileList()
end

function RabbusSpeedrun.RefreshProfileSettings()
  RabbusSpeedrun:dbg(2, "Updating Menu")
  RabbusSpeedrun.addsOnCR	= sV.profiles[RabbusSpeedrun.activeProfile].addsOnCR
  RabbusSpeedrun.hmOnSS 	= sV.profiles[RabbusSpeedrun.activeProfile].hmOnSS
  RabbusSpeedrun.LoadRaidlist(RabbusSpeedrun.activeProfile)
  RabbusSpeedrun.LoadCustomTimers(RabbusSpeedrun.activeProfile)
  RabbusSpeedrun.UpdateDropdowns()

  RabbusSpeedrun.RefreshTrialTimers()

  if RabbusSpeedrun.currentTrialMenu and RabbusSpeedrun.stepList[RabbusSpeedrun.currentTrialMenu]
  then RabbusSpeedrun.CreateRaidSegmentFromMenu(RabbusSpeedrun.currentTrialMenu) end
end
----------------------------------------------------------------------------------------------------------
------------------------------------[  FOOD REMINDER  ]---------------------------------------------------
----------------------------------------------------------------------------------------------------------
function RabbusSpeedrun.CreateFoodReminderSettings()
  local settings = {
    { type = "submenu",     name = "Food Reminder",
      controls = {

        { type = "description",  text = "The food reminder will let you know when there is less than 10 minutes left of your food buff, and will keep informing you in intervals.\nOnly in trials."
        },

        { type = "checkbox",    name = "Enable",
          tooltip = "Enable food reminder.",
          default = false,
          getFunc = function() return sV.food.show end,
          setFunc = function(newValue)
            sV.food.show = newValue
            RabbusSpeedrun.ToggleFoodReminder()
          end,
          width   = "half"
        },

        { type = "checkbox",    name = "Unlock",
          default = false,
          getFunc = function() return RabbusSpeedrun.foodUnlocked end,
          setFunc = function(newValue)
            RabbusSpeedrun.foodUnlocked = newValue
            RabbusSpeedrun.ShowFoodReminder(newValue)
          end,
          width   = "half"
        },

        { type = "slider",      name = "Size",
          getFunc = function() return sV.food.size end,
          setFunc = function(newValue)
            sV.food.size = newValue
            RabbusSpeedrun.UpdateFoodReminderSize()
          end,
          min = 17,
          max = 50,
          default = 30,
          width = "half"
        },

        { type = "slider",      name = "Reminder Interval",
          tooltip = "How often you want to be reminded when your food buff has expired (in seconds).\n0 = Always show if no food is active.",
          getFunc = function() return sV.food.time end,
          setFunc = function(newValue)
            sV.food.time = newValue
            if sV.food.show then
              RabbusSpeedrun.UpdateFoodReminderInterval((GetGameTimeMilliseconds() / 1000), sV.food.time)
            end
          end,
          min = 30,
          max = 300,
          default = 120,
          width = "half"
        }
      }
    }
  }
  return settings
end



----------------------------------------------------------------------------------------------------------
------------------------------------[ 		TRIAL    ]------------------------------------------------------
----------------------------------------------------------------------------------------------------------
local function SubmenuMouseEnter(id)
  RabbusSpeedrun.currentTrialMenu = id
end

-- local function SubmenuMouseExit(id)
--   RabbusSpeedrun.currentTrialMenu = nil
-- end
--
-- function RabbusSpeedrun.GetTime(seconds)
--   if seconds then
--     if seconds > 10 then
--       return "|cffffff" .. seconds .. " seconds|r"
--     elseif seconds < 60 then
--       return "|cffffff" .. string.format("%02d", seconds % 60) .. " seconds|r"
--     elseif seconds < 3600 then
--       return "|cffffff" .. string.format("%02d:%02d", math.floor((seconds / 60) % 60), seconds % 60) .. "|r"
--     else
--       return "|cffffff" .. string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor((seconds / 60) % 60), seconds % 60) .. "|r"
--     end
--   end
-- end

function RabbusSpeedrun.GetTime(seconds)
  if seconds then
    if seconds < 3600
    then return "|cffffff"..string.format("%02d:%02d", math.floor((seconds / 60) % 60), seconds % 60).."|r"
    else return "|cffffff"..string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor((seconds / 60) % 60), seconds % 60).."|r" end
  end
end

function RabbusSpeedrun.GetTooltip(timer)
  if timer then
    local t = "|cffffff" .. string.format(math.floor(timer / 1000)) .. "|r"
    return zo_strformat(SI_SPEEDRUN_STEP_DESC_EXIST, t, RabbusSpeedrun.GetTime(math.floor(timer / 1000)))
  else
    return zo_strformat(SI_SPEEDRUN_STEP_DESC_NULL)
  end
end

function RabbusSpeedrun.Simulate(raidID)
  local timer = 0
  for i, x in pairs(RabbusSpeedrun.Data.customTimerSteps[raidID]) do
    local s = RabbusSpeedrun.GetSavedTimer(raidID, i)
    if s then
      timer = s + timer
      RabbusSpeedrun:dbg(2, "[<<1>>]: <<2>>.", i, string.format("%.2f", s / 1000))
    end
  end

  local r = 0
  if timer > 0 then if (timer % 1000) >= 500 then r = 1 end end

  local t = math.floor(timer / 1000) + r

  local vitality = RabbusSpeedrun.GetTrialMaxVitality(raidID)

  local score = tostring(math.floor(RabbusSpeedrun.GetScore(t, vitality, raidID)))
  local fScore = string.sub(score,string.len(score)-2,string.len(score))
  local dScore = string.gsub(score,fScore,"")
  score = dScore .. "'" .. fScore

  d("|cdf4242" .. zo_strformat(SI_ZONE_NAME,GetZoneNameById(raidID)) .. "|r")
  d(zo_strformat(SI_SPEEDRUN_SIMULATE_FUNCTION, RabbusSpeedrun.GetTime(t), score))
end

function RabbusSpeedrun.Overwrite(raidID)
  for k, v in pairs(RabbusSpeedrun.customTimerSteps[raidID]) do
    if RabbusSpeedrun.customTimerSteps[raidID][k] ~= "" then
      if RabbusSpeedrun.GetCustomTimerStep(raidID, k) == "0"
      then RabbusSpeedrun.SaveTimerStep(raidID, k, nil)
      else RabbusSpeedrun.SaveTimerStep(raidID, k, tonumber(RabbusSpeedrun.GetCustomTimerStep(raidID, k)) * 1000) end
      RabbusSpeedrun.SaveCustomStep(raidID, k, "")
    end
  end

  if RabbusSpeedrun.IsInTrialZone() then
    ReloadUI("ingame")
    RabbusSpeedrun.ResetUI()
    RabbusSpeedrun.CreateRaidSegment(raidID)
    if GetRaidDuration() <= 0 and not IsRaidInProgress()
    then SpeedRun_Score_Label:SetText(RabbusSpeedrun.BestPossible(RabbusSpeedrun.raidID)) end
  else
    RabbusSpeedrun.RefreshTrial(raidID)
    RabbusSpeedrun.CreateRaidSegmentFromMenu(raidID)
  end
end

function RabbusSpeedrun.ResetData(raidID)
  -- For MA and VH
  if raidID == 677 or raidID == 1227 then
    if cV.individualArenaTimers then
      if cV.arenaList[raidID].timerSteps then cV.arenaList[raidID].timerSteps = {} end
    else
      if sV.profiles[RabbusSpeedrun.activeProfile].raidList[raidID].timerSteps
      then sV.profiles[RabbusSpeedrun.activeProfile].raidList[raidID].timerSteps = {} end
    end
  else
    if RabbusSpeedrun.raidList[raidID].timerSteps then
      RabbusSpeedrun.raidList[raidID].timerSteps = {}
      sV.profiles[RabbusSpeedrun.activeProfile].raidList = RabbusSpeedrun.raidList
    end
  end

  -- ReloadUI("ingame")

  if RabbusSpeedrun.IsInTrialZone() then
    RabbusSpeedrun.ResetUI()
    RabbusSpeedrun.CreateRaidSegment(raidID)
  else
    RabbusSpeedrun.RefreshTrial(raidID)
    RabbusSpeedrun.CreateRaidSegmentFromMenu(raidID)
  end
end

function RabbusSpeedrun.CreateOptionTable(raidID, step)
  local settingsTimer = {
    saved   = RabbusSpeedrun.GetSavedTimerStep(raidID, step),
    custom  = RabbusSpeedrun.GetCustomTimerStep(raidID, step),
    toolTip = ""
  }
  trialMenuTimers[raidID][step] = settingsTimer
  trialMenuTimers[raidID][step].toolTip = RabbusSpeedrun.GetTooltip(RabbusSpeedrun.GetSavedTimerStep(raidID, step))

  return
  { type    = "editbox",
    name    = zo_strformat(SI_SPEEDRUN_STEP_NAME, RabbusSpeedrun.Data.stepList[raidID][step]),
    tooltip = function() return trialMenuTimers[raidID][step].toolTip end,
    default = "",
    getFunc = function() return trialMenuTimers[raidID][step].custom end,
    setFunc = function(newValue)
      RabbusSpeedrun.SaveCustomStep(raidID, step, newValue)
      trialMenuTimers[raidID][step].custom = newValue
    end,
    reference = "SpeedRun_Editbox_" .. raidID .. step
  }
end

function RabbusSpeedrun.CreateRaidMenu(raidID)
  local raidMenu = {}

  table.insert(raidMenu, { type = "description", text = zo_strformat(SI_SPEEDRUN_RAID_DESC) })

  if raidID == 1051 then
    table.insert(raidMenu,
      { type    = "checkbox",
        name    = zo_strformat(SI_SPEEDRUN_ADDS_CR_NAME),
        tooltip = zo_strformat(SI_SPEEDRUN_ADDS_CR_DESC),
        default = true,
        getFunc = function() return RabbusSpeedrun.addsOnCR end,
        setFunc = function(newValue)
          RabbusSpeedrun.addsOnCR = newValue
          sV.profiles[RabbusSpeedrun.activeProfile].addsOnCR = RabbusSpeedrun.addsOnCR
        end
      }
    )
  end

  if raidID == 1121 then
    local choices = {
      [1] = zo_strformat(SI_SPEEDRUN_ZERO),
      [2] = zo_strformat(SI_SPEEDRUN_ONE),
      [3] = zo_strformat(SI_SPEEDRUN_TWO),
      [4] = zo_strformat(SI_SPEEDRUN_THREE),
    }

    table.insert(raidMenu,
      { type    = "dropdown",
        name    = zo_strformat(SI_SPEEDRUN_HM_SS_NAME),
        tooltip = zo_strformat(SI_SPEEDRUN_HM_SS_DESC),
        choices = choices,
        default = choices[4],
        getFunc = function() return choices[RabbusSpeedrun.hmOnSS] end,
        setFunc = function(selected)
          for index, name in ipairs(choices) do
            if name == selected then
              RabbusSpeedrun.hmOnSS = index
              sV.profiles[RabbusSpeedrun.activeProfile].hmOnSS = RabbusSpeedrun.hmOnSS
              break
            end
          end
        end,
      }
    )
  end

  for i, x in ipairs(RabbusSpeedrun.Data.stepList[raidID]) do
    table.insert(raidMenu, RabbusSpeedrun.CreateOptionTable(raidID, i))
  end

  table.insert(raidMenu,
    { type    = "button",
      name    = zo_strformat(SI_SPEEDRUN_SIMULATE_NAME),
      tooltip = zo_strformat(SI_SPEEDRUN_SIMULATE_DESC),
      func    = function()
        RabbusSpeedrun.Simulate(raidID)
        RabbusSpeedrun.currentTrialMenu = raidID
      end,
      width   = "half"
    }
  )

  table.insert(raidMenu,
    { type     = "button",
      name     = "Apply to UI",
      tooltip  = "If you are not currently inside a trial, this button will make the SpeedRun UI window display your currently saved steps for this trial.",
      func     = function()
        RabbusSpeedrun.currentTrialMenu = raidID
        RabbusSpeedrun.CreateRaidSegmentFromMenu(raidID)
      end,
      disabled = function() return RabbusSpeedrun.IsInTrialZone() end,
      width    = "half"
    }
  )

  table.insert(raidMenu,
    { type        = "button",
      name        = "Apply Times",
      tooltip     = "Overwrite current saved times with entered custom times.\nEntering '0' to a field will delete your saved time for that step when this button is pressed.\nFields left blank wont be changed.",
      func        = function()
        RabbusSpeedrun.Overwrite(raidID)
        RabbusSpeedrun.currentTrialMenu = raidID
      end,
      width       = "half",
      isDangerous = true,
      warning     = "Confirm Changes.",
    }
  )

  table.insert(raidMenu,
    { type        = "button",
      name        = zo_strformat(SI_SPEEDRUN_RESET_NAME),
      tooltip     = zo_strformat(SI_SPEEDRUN_RESET_DESC),
      func        = function()
        RabbusSpeedrun.ResetData(raidID)
        RabbusSpeedrun.currentTrialMenu = raidID
      end,
      width       = "half",
      isDangerous = true,
      warning     = zo_strformat(SI_SPEEDRUN_RESET_WARNING)
    }
  )

  local menu = { id = raidID, control = "SpeedRun_TrialMenu_" .. raidID }

  trialSubmenus[raidID] = menu

  local trialControls = {
    type      = "submenu",
    name      = (zo_strformat(SI_ZONE_NAME, GetZoneNameById(raidID))),
    controls  = raidMenu,
    reference = "SpeedRun_TrialMenu_" .. raidID,
  }
  return trialControls
end

function RabbusSpeedrun.SetTrialMenuHandlers()
  for i, x in pairs(trialSubmenus) do
    local m = trialSubmenus[i]
    local s = wm:GetControlByName("SpeedRun_TrialMenu_" .. m.control)
    if s then
      s:SetHandler("OnMouseEnter", function() SubmenuMouseEnter(m.id) end)
      -- s:SetHandler("OnMouseExit" , function() SubmenuMouseExit(m.id) end)
    end
  end
end

function RabbusSpeedrun.RefreshTrial(raidID)
  trialMenuTimers[raidID] = {}

  for i, x in pairs(RabbusSpeedrun.Data.customTimerSteps[raidID]) do
    if RabbusSpeedrun.Data.customTimerSteps[raidID][i] then
      local settingsTimer = {
        saved   = RabbusSpeedrun.GetSavedTimerStep(raidID, i),
        custom  = RabbusSpeedrun.GetCustomTimerStep(raidID, i),
        toolTip = ""
      }
      trialMenuTimers[raidID][i] = settingsTimer
      trialMenuTimers[raidID][i].toolTip = RabbusSpeedrun.GetTooltip(RabbusSpeedrun.GetSavedTimerStep(raidID, i))
      local editbox = wm:GetControlByName("SpeedRun_Editbox_" .. raidID .. i)
      if editbox then editbox.data.tooltipText = trialMenuTimers[raidID][i].toolTip end
    end
  end
end

function RabbusSpeedrun.RefreshTrialTimers()
  for i, x in pairs(RabbusSpeedrun.Data.customTimerSteps) do
    if RabbusSpeedrun.Data.customTimerSteps[i] then RabbusSpeedrun.RefreshTrial(i) end
  end
end

function RabbusSpeedrun.StressTestedConfirmed()
  isST = true
end

local ka = {
  -- adds
  wrathOfTides  = {
    id            = 134050,
    options       = { -3, 0, false, { 1, 0, 0.6, 0.4 }, { 1, 0, 0.6, 0.8 } }
  },

  -- yandir
  yandirName    = "yandir",
  chaurus       = {
    id            = 133515,
    name          = 133559,
    options       = { -3, 0, false, { 0, 0.8, 0, 0.4 }, { 0, 0.8, 0, 0.8 } }
  },
  gargoyle      = {
    id            = 133546,
    options       = { -3, 0, false, { 0.6, 0.4, 0.2, 0.4 }, { 0.6, 0.4, 0.2, 0.8 } }
  },

  -- vrol
  vrolName      = "vrol",
  portalTime    = 0,
  conjurer      = 136941, -- conjurer spawn
  portal1       = 133994, -- portal summon
  portal2       = 134004, -- portal synergy taken

  -- falgravn
  falgravName   = "falgrav",
  bloodCleave   = {
    id            = 136976,
    options       = { -3, 0, false, { 1, 0, 0.6, 0.4 }, { 1, 0, 0.6, 0.8 } }
  },
  uppercut      = 136961,
  units         = {}
}

local function StopVrolPortal()
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VrolPortal")
  CombatAlerts.panel.rows[2]:SetHidden(true)
  CombatAlerts.panel.rows[2].label:SetText("")
  CombatAlerts.panel.rows[2].data:SetText("")
  CombatAlerts.panel.rows[2].label:SetColor(1, 1, 1, 1)
  CombatAlerts.panel.rows[2].data:SetColor(1, 1, 1, 1)
end

local function VrolPortal()
  local t    = GetGameTimeMilliseconds() / 1000
  local time = ka.portalTime - t

  if time > 0 then
    CombatAlerts.panel.rows[2]:SetHidden(false)
    if time >= 4 then
      CombatAlerts.panel.rows[2].label:SetColor(1, 0.6, 0.2, 1)
      CombatAlerts.panel.rows[2].data:SetColor(1, 0.6, 0.2, 1)
      CombatAlerts.panel.rows[2].data:SetText(string.format("%0.1f", time - 4))
    else
      CombatAlerts.panel.rows[2].label:SetColor(1, 0, 0, 1)
      CombatAlerts.panel.rows[2].data:SetColor(1, 0, 0, 1)
      CombatAlerts.panel.rows[2].label:SetText("Portal Closing")
      CombatAlerts.panel.rows[2].data:SetText(string.format("%0.1f", time))
    end
  else StopVrolPortal() end
end

function RabbusSpeedrun.KynesAegisAlerts( _, result, _, _, _, _, sName, _, _, tType, hValue, _, _, _, sId, tId, abilityId, _)
  -- Wrath of Tides
  if (result == ACTION_RESULT_BEGIN and tType ~= COMBAT_UNIT_TYPE_PLAYER and abilityId == ka.wrathOfTides.id) then
    local id = CombatAlerts.AlertCast(ka.wrathOfTides.id, sName, hValue, ka.wrathOfTides.options )
    if (tId and tId ~= 0) then
      CombatAlerts.castAlerts.sources[tId] = id
    end

    --Chaurus Totem
  elseif (result == ACTION_RESULT_BEGIN and abilityId == ka.chaurus.id) then
    -- local id = CombatAlerts.StartBanner(nil, GetFormattedAbilityName(ka.chaurus.name), 0x33FF00FF, ka.chaurus.name, true, nil)
    -- EM:UnregisterForUpdate(CombatAlerts.banners[id].name)
  	-- EM:RegisterForUpdate(CombatAlerts.banners[id].name, 4250, function()
    --   CombatAlerts.DisableBanner(id)
    -- end)

    local id = CombatAlerts.AlertCast(ka.chaurus.name, sName, 4250, ka.chaurus.options )

  elseif result == ACTION_RESULT_BEGIN and abilityId == ka.chaurus.name then
    CombatAlerts.AlertCast( abilityId, sName, hValue, ka.chaurus.options )

    -- Gargoyle Totem
  elseif (result == ACTION_RESULT_BEGIN and abilityId == ka.gargoyle.id) then
    local id = CombatAlerts.AlertCast(ka.gargoyle.id, sName, hValue, ka.gargoyle.options )
    if (sId and sId ~= 0) then
      CombatAlerts.castAlerts.sources[sId] = id
    end

    -- conjurer spawn
  elseif (result == ACTION_RESULT_BEGIN and abilityId == ka.conjurer) then
    local t = ( GetGameTimeMilliseconds() / 1000 )
    CombatAlerts.panel.rows[2].label:SetColor(1, 0.6, 0, 1)
    CombatAlerts.panel.rows[2].data:SetFont("$(BOLD_FONT)|$(KB_28)|soft-shadow-thick")
    if CombatAlerts.panel.enabled ~= true then
      CombatAlerts.ka.panelMode = 1
      CombatAlerts.TogglePanel(true, {GetFormattedAbilityName(CombatAlertsData.ka.shockingHarpoon), "Conjurer Spawned"}, true, true)
    else
      CombatAlerts.panel.rows[2].label:SetText("Conjurer Spawned")
      CombatAlerts.panel.rows[2].data:SetText("")
      CombatAlerts.panel.rows[2]:SetHidden(false)
    end

    -- summon portal
  elseif (result == ACTION_RESULT_BEGIN and abilityId == ka.portal1) then
    if ka.portalTime - ( GetGameTimeMilliseconds() / 1000 ) > 0 then return end
    ka.portalTime = ( GetGameTimeMilliseconds() / 1000 ) + 7.1
    if CombatAlerts.panel.enabled ~= true then
      CombatAlerts.ka.panelMode = 1
      CombatAlerts.TogglePanel(true, {GetFormattedAbilityName(CombatAlertsData.ka.shockingHarpoon), "Portal Opening"}, true, true)
    else
      CombatAlerts.panel.rows[2].label:SetText("Portal Opening")
      CombatAlerts.panel.rows[2]:SetHidden(false)
    end
    VrolPortal()
    EM:RegisterForUpdate(RabbusSpeedrun.name .. "VrolPortal", 100, VrolPortal)

    -- portal synergy taken
  elseif (result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == ka.portal2) then
    if ka.portalTime - ( GetGameTimeMilliseconds() / 1000 ) > 0 then
      ka.portalTime = 0
      StopVrolPortal()
    end

    -- Blood Cleave
  elseif (result == ACTION_RESULT_BEGIN and abilityId == ka.bloodCleave.id) then
    local id = CombatAlerts.AlertCast(ka.bloodCleave.id, sName, hValue, ka.bloodCleave.options )
    if (tId and tId ~= 0) then
      CombatAlerts.castAlerts.sources[tId] = id
    end

  elseif (result == ACTION_RESULT_BEGIN and tType == COMBAT_UNIT_TYPE_PLAYER and abilityId == ka.uppercut) then
    CombatAlerts.Alert(nil, GetFormattedAbilityName(136961), 0xFF6600FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hValue)
    -- CombatAlerts.AlertCast( abilityId, "Dodge!", hValue, { hValue, "Dodge!", 1, 0.4, 0, 0.5, nil } )
    CombatAlerts.CastAlertsStart(136961, "", hValue, nil, nil, { hValue, "Dodge!", 1, 0.4, 0, 0.5, nil })
  end
end

local function ValenIsACutiePie()
  if not DoesUnitExist("boss1") then
    RabbusSpeedrun.ValenIsStillCuteButStopTrackingKA(false)
    CombatAlerts.panel.rows[2].data:SetFont("$(MEDIUM_FONT)|$(KB_28)|soft-shadow-thick")
    return
  end

  local boss     = string.lower( GetUnitName( "boss1" ) )
  local yandir   = string.find ( boss, ka.yandirName  )
  local vrol     = string.find ( boss, ka.vrolName    )
  local falgravn = string.find ( boss, ka.falgravName )

  if yandir then
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Chaurus", EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Chaurus", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 133515 )
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Stone",   EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Stone",   EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 133546 )
  else
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Chaurus", EVENT_COMBAT_EVENT )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Stone",   EVENT_COMBAT_EVENT )
  end

  if vrol then
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Vrol1",   EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Vrol1",   EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 136941 )
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Vrol2",   EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Vrol2",   EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 133994 )
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Vrol3",   EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Vrol3",   EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 134004 )
    CombatAlerts.panel.rows[2].data:SetFont("$(BOLD_FONT)|$(KB_28)|soft-shadow-thick")
  else
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol1",   EVENT_COMBAT_EVENT )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol2",   EVENT_COMBAT_EVENT )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol3",   EVENT_COMBAT_EVENT )
    EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VrolPortal")
    CombatAlerts.panel.rows[2].data:SetFont("$(MEDIUM_FONT)|$(KB_28)|soft-shadow-thick")
  end

  if falgravn then
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "BloodCleave",     EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "BloodCleave",     EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 136976 )
    EM:RegisterForEvent(   RabbusSpeedrun.name .. "Uppercut",        EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent(  RabbusSpeedrun.name .. "Uppercut",        EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 136961 )
  else
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "BloodCleave",     EVENT_COMBAT_EVENT )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "Uppercut",        EVENT_COMBAT_EVENT )
  end
end

function RabbusSpeedrun.ValenIsStillCuteButStopTrackingKA(stopAll)
  if stopAll then
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "ValenIsACutiepie", EVENT_PLAYER_COMBAT_STATE )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "ValenIsACutiepie", EVENT_BOSSES_CHANGED )
    EM:UnregisterForEvent( RabbusSpeedrun.name .. "WrathOfTides",     EVENT_COMBAT_EVENT )
  end
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Chaurus",          EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Stone",            EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol1",            EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol2",            EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Vrol3",            EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "BloodCleave",      EVENT_COMBAT_EVENT )
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Uppercut",         EVENT_COMBAT_EVENT )
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VrolPortal" )
end

function RabbusSpeedrun.ChaosIsABellend()
  if (not isST or not sV.valenFinallyGotGH) then return end

  if CombatAlerts and GetZoneId(GetUnitZoneIndex("player")) == 1196 then
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "ValenIsACutiepie", EVENT_PLAYER_COMBAT_STATE, ValenIsACutiePie )
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "ValenIsACutiepie", EVENT_BOSSES_CHANGED, ValenIsACutiePie )
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "WrathOfTides",     EVENT_COMBAT_EVENT, RabbusSpeedrun.KynesAegisAlerts )
    EM:AddFilterForEvent( RabbusSpeedrun.name .. "WrathOfTides",     EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 134050 )
  else RabbusSpeedrun.ValenIsStillCuteButStopTrackingKA(true) end
end
----------------------------------------------------------------------------------------------------------
-----------------------------------[ 		SETTINGS WINDOW    ]----------------------------------------------
----------------------------------------------------------------------------------------------------------

-- function RabbusSpeedrun.BuildSettingsTable()
-- 		local p = RabbusSpeedrun.activeProfile
-- 		local c = sV.profiles[p].customTimerSteps
-- 		local r = sV.profiles[p].raidList
function RabbusSpeedrun.RegisterNameplateSettingChanges()
  EM:UnregisterForEvent(RabbusSpeedrun.name .. "Nameplate", EVENT_INTERFACE_SETTING_CHANGED)
  if (sV.changeNamePlates or sV.changeHealthBars) then
    EM:RegisterForEvent(RabbusSpeedrun.name .. "Nameplate", EVENT_INTERFACE_SETTING_CHANGED, OnNameplatesChanged) EM:AddFilterForEvent(RabbusSpeedrun.name .. "Nameplate", EVENT_INTERFACE_SETTING_CHANGED,
      REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_NAMEPLATES)
    end
end

function RabbusSpeedrun.ConfigureNameplates()
  sV = RabbusSpeedrun.savedVariables
  cV = RabbusSpeedrun.savedSettings

  if sV.nameplatesHidden == "" then
    if sV.hideNameplates ~= nil then
      if sV.hideNameplates == true then sV.nameplatesHidden = "always"
      else sV.nameplatesHidden = npGroupHiddenOptions[sV.nameplates] end
      sV.hideNameplates = nil
    else sV.nameplatesHidden = npGroupHiddenOptions[sV.nameplates] end
  end

  if sV.healthBarsHidden == "" then
    if sV.hideHealthBars ~= nil then
      if sV.healthBars == true then sV.healthBarsHidden = "always"
      else sV.healthBarsHidden = npGroupHiddenOptions[sV.healthBars] end
      sV.hideHealthBars = nil
    else sV.healthBarsHidden = npGroupHiddenOptions[sV.healthBars] end
  end

  if sV.nameplatesHiddenHL == "" then sV.nameplatesHiddenHL = npGroupHiddenOptions[sV.nameplatesHL] end
  if sV.healthBarsHiddenHL == "" then sV.healthBarsHiddenHL = npGroupHiddenOptions[sV.healthBarsHL] end
  RabbusSpeedrun.RegisterNameplateSettingChanges()
end

function RabbusSpeedrun.CreateSettingsWindow()
  local panelData = {
    type               = "panel",
    name               = "Rabbu's SpeedRun",
    displayName        = "Rabbu's Speed|cdf4242Run|r",
    author             = "RegularSizedRabbu @RegularSizedRabbu [PC NA]; Floliroy, Panaa, @nogetrandom [PC EU]",
    version            = RabbusSpeedrun.version,
    slashCommand       = "/speed menu",
    registerForRefresh = true
  }

  local cntrlOptionsPanel = LAM:RegisterAddonPanel("RabbusSpeedrun_Settings", panelData)

  -- RabbusSpeedrun.RefreshTrialTimers()

  CM:RegisterCallback("LAM-PanelOpened", function(panel)
    if panel ~= cntrlOptionsPanel then return end
    RabbusSpeedrun.inMenu = true
    RabbusSpeedrun.UpdateVisibility()
    -- SpeedRun_Panel:SetHidden(false)
    -- RabbusSpeedrun.ShowInMenu()
  end)
  CM:RegisterCallback("LAM-PanelClosed", function(panel)
    if panel ~= cntrlOptionsPanel then return end
    RabbusSpeedrun.inMenu = false
    RabbusSpeedrun.currentTrialMenu = nil
    RabbusSpeedrun.UpdateVisibility()
    -- SpeedRun_Panel:SetHidden(true)
    -- RabbusSpeedrun.SetUIHidden(true)
  end)

  local function WalkInLava()
    local ChaosMadeMeDoThis = nil
    if (CombatAlerts and isST) then
      ChaosMadeMeDoThis = {
        type    = "checkbox", name = "Valen is a |cFF99CCC|cF989B7u|cF47AA3t|cEF6B8Ei|cEA5B7Ae|cE54C66p|cE03D51i|cDB2D3De|r",
        tooltip = "Walk in Lava",
        default = false,
        getFunc = function() return sV.valenFinallyGotGH end,
        setFunc = function() sV.valenFinallyGotGH = not sV.valenFinallyGotGH end
      }
    end
    return ChaosMadeMeDoThis
  end

  local optionsData = {
    { type = "divider" },

    { type    = "checkbox",   name = "Enable Tracking",          --zo_strformat(SI_SPEEDRUN_ENABLE_NAME),
      tooltip = "Turn trial time and score tracking on / off",	--zo_strformat(SI_SPEEDRUN_ENABLE_DESC),
      default = true,
      getFunc = function() return cV.isTracking end,
      setFunc = function(newValue) RabbusSpeedrun.ToggleTracking() end
    },

    { type    = "checkbox",   name = "Use Character unique timers for MA & VH",
      tooltip = "On = Will only save and load times set on your current character.\nOff = Will save times to your current profile and will load times set by any of your characters while this setting was off.\n(Only applies to Maelstrom Arena and Vateshran Hollows).",
      default = true,
      getFunc = function() return cV.individualArenaTimers end,
      setFunc = function(newValue)
        cV.individualArenaTimers = newValue
        RabbusSpeedrun.RefreshProfileSettings()
      end
    },

    { type    = "submenu",    name = "UI Options",
      controls = {

        { type    = "checkbox",   name = "Panel Always Active",
          tooltip = "The panel at the top of the |cffffffSpeed|r|cdf4242Run|r window will be visible outside of trials.",
          default = true,
          getFunc = function() return sV.showPanelAlways end,
          setFunc = function()
            sV.showPanelAlways = not sV.showPanelAlways
            RabbusSpeedrun.UpdateUIConfiguration()
          end,
          width = "half"
        },

        { type    = "checkbox",   name = "Unlock UI", --zo_strformat(SI_SPEEDRUN_LOCK_NAME),
          tooltip = zo_strformat(SI_SPEEDRUN_LOCK_DESC),
          default = true,
          getFunc = function() return sV.unlockUI end,
          setFunc = function() RabbusSpeedrun.ToggleUILocked() end,
          width = "half"
        },

        { type    = "checkbox",   name = zo_strformat(SI_SPEEDRUN_ENABLEUI_NAME),
          tooltip = zo_strformat(SI_SPEEDRUN_ENABLEUI_DESC),
          default = true,
          getFunc = function() return sV.showUI end,
          setFunc = function(value)
            sV.showUI = value
            RabbusSpeedrun.UpdateUIConfiguration()
          end,
          width = "half"
        },

        { type = "description",	width = "half"	},

        { type    = "checkbox",   name = "Change Opacity",
          tooltip = "Lower opacity of the |cffffffSpeed|r|cdf4242Run|r window while in combat in trials.",
          default = false,
          getFunc = function() return sV.changeAlpha end,
          setFunc = function(value)
            sV.changeAlpha = value
            RabbusSpeedrun.UpdateUIConfiguration()
          end,
          width = "half"
        },

        { type    = "slider",     name  = "UI Combat Opacity",
          disabled = function() return not sV.changeAlpha end,
          getFunc = function() return sV.combatAlpha end,
          setFunc = function(value)
            sV.combatAlpha = value
            RabbusSpeedrun.UpdateAlpha()
          end,
          default = 100,
          min     = 0,
          max     = 100,
          step    = 1,
          width = "half"
        },

        -- { type    = "checkbox",  name = "Simple Display",
        --   tooltip = "Display only score, vitality and timer",
        --   default = false,
        --   getFunc = function() return sV.uiSimple end,
        --   setFunc = function(newValue)
        --     sV.uiSimple = newValue
        --     RabbusSpeedrun.SetSimpleUI(sV.uiSimple)
        --   end,
        --   reference = "RabbusSpeedrun_SimpleUI_Checkbox"
        -- },

        { type    = "checkbox",  name = "Best Possible & Gain On Last",
          tooltip = "Enable the Best Possible & Gain On Last UI section",
          default = true,
          getFunc = function() return sV.showAdvanced end,
          setFunc = function(newValue)
            sV.showAdvanced = newValue
            RabbusSpeedrun.UpdateAnchors()
            SpeedRun_Advanced:SetHidden(not newValue)
          end
        },

        { type    = "checkbox",  name = "Vateshran Hollows add tracker",
          tooltip = "Enable the monster kill counter UI section for Vateshran Hollows.",
          default = true,
          getFunc = function() return sV.showAdds end,
          setFunc = function(newValue)
            RabbusSpeedrun.currentTrialMenu = 1227
            sV.showAdds = newValue
            SpeedRun_Adds:SetHidden(not newValue)
          end
        }
      }
    },

    { type    = "submenu",    name = "Profile Options",
      reference = "RabbusSpeedrun_ProfileSubmenu",
      controls = {

        { type      = "description",  title = "Currently Active Profile:",
          width     = "half",
          reference = "RabbusSpeedrun_ActiveProfileDescriptionTitle"
        },

        { type      = "description",  title = function() return RabbusSpeedrun.GetActiveProfileDisplay() end,
          text      = "",
          width     = "half",
          reference = "RabbusSpeedrun_ActiveProfileDescriptionName"
        },

        { type      = 'dropdown',     name = "Select Profile To Use",
          choices   = RabbusSpeedrun:GetProfileNames(),
          sort      = "name-up",
          getFunc   = function() return profileToLoad end,
          setFunc   = function(value) profileToLoad = value end,
          scrollable = 12,
          reference = "RabbusSpeedrun_ProfileDropdown"
        },

        { type      = "button",       name = "Load Profile",
          func = function()
            RabbusSpeedrun.LoadProfile(profileToLoad)
            SpeedRun_Timer_Container_Profile:SetText(RabbusSpeedrun.GetActiveProfileDisplay())
          end,
          disabled = function() return profileToLoad == "" and true or false end
        },

        { type      = "divider"  },

        { type      = "editbox",      name = "Create New Profile",
          tooltip   = "Enter the new profile name and click the Save button to confirm",
          getFunc   = function() return "" end,
          setFunc   = function(value) profileToAdd = value end,
          reference = "RabbusSpeedrun_ProfileEditbox"
        },

        { type      = "button",       name = "Save",
          func = RabbusSpeedrun.AddProfile,
          disabled = function() return profileToAdd == "" and true or false end
        },

        { type      = "divider" },

        { type      = 'dropdown',     name = "Select Profile To Delete",
          choices   = RabbusSpeedrun:GetProfileNames(),
          getFunc   = function() return "" end,
          setFunc   = function(value) profileToDelete = value end,
          scrollable = 12,
          reference = "RabbusSpeedrun_ProfileDeleteDropdown"
        },

        { type      = "button",       name = "Delete Profile",
          func      = RabbusSpeedrun.DeleteProfile,
          disabled  = function() return profileToDelete == "" and true or false end,
          isDangerous = true,
          warning   = "This can't be undone."
        },

        -- {		type = "divider"	},
        --
        -- {		type = "description",			title = "Copy Data",
        -- text = "Below you can copy data from one profile to another.\nIf you used this addon before profiles were intruduced, then you can copy that data on to selected profile.\n|cdf4242NOTICE!|r This will wipe any new data collected on targeted profile."	},
        --
        --   {		type = 'dropdown',				name = "Profile To Copy From",
        --   choices = RabbusSpeedrun:GetProfileNames(),
        --   getFunc = function() return "" end,
        --   setFunc = function(value)
        --     profileToCopyFrom = value
        --   end,
        --   scrollable = 12,
        --   reference = "RabbusSpeedrun_ProfileCopyFrom"	},
        --
        --   {		type = 'dropdown',				name = "Profile To Copy To",
        --   choices = RabbusSpeedrun:GetProfileNamesToCopyTo(),
        --   getFunc = function() return "" end,
        --   setFunc = function(value)
        --     profileToCopyTo = value
        --   end,
        --   scrollable = 12,
        --   reference = "RabbusSpeedrun_ProfileCopyTo"	},
        --
        --   {		type = "button",					name = "Confirm Copy",
        --   func = RabbusSpeedrun.CopyProfile(profileToCopyFrom, profileToCopyTo),
        --   disabled = function() return (profileToCopyTo ~= "" and profileToCopyFrom ~= "") and false or true end,
        --   isDangerous = true,
        --   warning = "This can't be undone. Are you sure?\n|cdf4242NOTICE!|r If you are currently in a trial and [Profile To Copy To] is currently set as active, then this will reload UI."	},

        { type    = "divider"    },

        { type    = "description",		title = "Import Data From Old",
          text = "If you used this addon before profiles were intruduced you can then copy that data on to selected profile.\n|cdf4242NOTICE!|r This will wipe any new data collected on targeted profile."
        },

        { type    = 'dropdown',       name = "Profile To Import To",
          choices = RabbusSpeedrun:GetProfileNames(),
          getFunc = function() return "" end,
          setFunc = function(value) RabbusSpeedrun.profileToImportTo = value end,
          scrollable = 12,
          reference = "RabbusSpeedrun_ProfileImportTo"
        },

        { type    = "button",         name = "Confirm Import",
          disabled = function() return RabbusSpeedrun.profileToImportTo == "" and true or false end,
          isDangerous = true,
          func = function() RabbusSpeedrun.ImportVariables() end,
          warning = "This can't be undone.\n|cdf4242NOTICE!|r If you are currently in a trial and [Profile To Import To] is currently set as active, then this will reload UI."
        }
      }
    },

    { type    = "header",     name = "Score Simulator and Records"	},

    { type    = "submenu",    name = "info",
      controls = {

        { type = "description", text = zo_strformat(SI_SPEEDRUN_GLOBAL_DESC)	},

        { type = "divider"  },

        { type = "description",
          text = "Available [/speed] commands are:\n[ show ] or [ hide ]: to show or hide the display.\n[ track 0 - 3 ] To get trial updates in chat.\n    [ 0 ]: Only settings change confirmations.\n    [ 1 ]: Trial Checkpoint Updates.\n    [ 2 ]: Internal addon updates.\n    [ 3 ]: All tracked event updates (a lot of spam in trial).\n[ hg ] or [ hidegroup ]: Toggle function on/off. More options available in 'Extra'.\n[ score ]: List score point factors of your current trial in chat"
        }
      }
    },

    { type    = "submenu",    name = "Trials",
      controls = {

        RabbusSpeedrun.CreateRaidMenu(638),
        RabbusSpeedrun.CreateRaidMenu(636),
        RabbusSpeedrun.CreateRaidMenu(639),
        RabbusSpeedrun.CreateRaidMenu(725),
        RabbusSpeedrun.CreateRaidMenu(975),
        RabbusSpeedrun.CreateRaidMenu(1000),
        RabbusSpeedrun.CreateRaidMenu(1051),
        RabbusSpeedrun.CreateRaidMenu(1121),
        RabbusSpeedrun.CreateRaidMenu(1196),
        RabbusSpeedrun.CreateRaidMenu(1263),
        RabbusSpeedrun.CreateRaidMenu(1427),
        RabbusSpeedrun.CreateRaidMenu(1478)
      },
      reference = "RabbusSpeedrun_Trial_Menu"
    },

    { type    = "submenu",    name = "Arenas",
      controls = {
        RabbusSpeedrun.CreateRaidMenu(635),
        RabbusSpeedrun.CreateRaidMenu(1082),
        RabbusSpeedrun.CreateRaidMenu(677),
        RabbusSpeedrun.CreateRaidMenu(1227)
      }
    },

    { type    = "submenu",    name = "Extra",
      controls = {

        { type = "description", title = "CHAT UPDATES"
        },

        { type = "checkbox",    name = "Difficulty Changed",
          tooltip = "Print notification in chat when trial difficulty changes.",
          default = true,
          getFunc = function() return sV.printDiffChange end,
          setFunc = function(newValue) sV.printDiffChange = newValue end,
          width   = "half"
        },

        { type = "checkbox",    name = "Trial Timers",
          tooltip = "Print notification in chat when timer step is updated (if you want to hide the UI but still be able to see your time).",
          default = true,
          getFunc = function() return sV.printStepUpdate end,
          setFunc = function(newValue) sV.printStepUpdate = newValue end,
          width   = "half"
        },

        { type = "divider" },

        { type = "submenu",     name = "Hide Group Options",
          controls = {

            { type = "description", title = "Set the behaviour of |cffffffSpeed|r|cdf4242Run|r's Hide Group when it's enabled."
            },

            { type    = "checkbox",  name = "Auto-Show Group",
              tooltip = "Instantly make group visible when turning hide group off from any menu.",
              default = false,
              getFunc = function() return cV.hgAutoShow end,
              setFunc = function(newValue) cV.hgAutoShow = newValue end,
              width = "half"
            },

            { type    = "checkbox",  name = "Necromancer Mode",
              tooltip = "This will automatically disable hide group when you enter combat and turn it on again outside of combat.\nThis will prevent Auto-Show Group option from taking effect.",
              default = false,
              getFunc = function() return cV.hgNecro end,
              setFunc = function(newValue)
                cV.hgNecro = newValue
                RabbusSpeedrun.UpdateNecroMode()
              end,
              width = "half"
            },

            { type = "checkbox",    name = "Only in Trials",
              tooltip = "Choose how you want hide group to automatically handle zone changes if it's enabled.\n\nOn = group will only be hidden inside trial zones.\nOff = group will be hidden in all zones.",
              default = false,
              getFunc = function() return sV.hgTrialOnly end,
              setFunc = function(newValue)
                sV.hgTrialOnly = newValue
                RabbusSpeedrun.ConfigureHideGroup()
              end,
              width = "half"
            },

            { type = "description"  },

            { type = "divider"      },

            { type = "description",   text = "Set the behaviour of group member nameplates and healthbars when the Hide Group toggle is enabled.\n|cdf4242N.B.|r Settings for nameplates wont change the setting that enables / disables all namesplates, and the same applies to healthbars"
            },

            {		type = "checkbox",		name = "Enable Nameplate changes",
            		tooltip = "Name plate display settings will be changed according to the active state of Hide Group.",
            		default = false,
            		getFunc = function() return sV.changeNameplates end,
                setFunc = function(value)
                  sV.changeNameplates = value
                  if RabbusSpeedrun.groupIsHidden then
                    if value == true then
                      RabbusSpeedrun.AlterNameplateSettings()
                    else
                      RabbusSpeedrun.RestoreNameplateSettings()
                    end
                  end
                  RabbusSpeedrun.RegisterNameplateSettingChanges()
                end,
            		width = "half"
            },

            {		type = "checkbox",		name = "Enable Healthbar Changes",
            		tooltip = "Healthbar display settings will be changed according to the active state of Hide Group.",
            		default = false,
            		getFunc = function() return sV.changeHealthBars end,
                setFunc = function(value)
                  sV.changeHealthBars = value
                  if RabbusSpeedrun.groupIsHidden then
                    if value == true then
                      RabbusSpeedrun.AlterHealthBarSettings()
                    else
                      RabbusSpeedrun.RestoreHealthBarSettings()
                    end
                  end
                  RabbusSpeedrun.RegisterNameplateSettingChanges()
                end,
            		width = "half"
            },

            { type = "divider"      },

            { type = "description", text = "Select the setting you want applied to group member nameplates and healthbars when Hide Group toggle is enabled."
            },

            {		type = 'dropdown',		name = "Nameplate Choice",
            		choices = RabbusSpeedrun.GetNameplateGroupHiddenOptions(),
            		getFunc = function() return sV.nameplatesHidden end,
            		setFunc = function(value)
                  sV.nameplatesHidden = value
                  RabbusSpeedrun.ApplyNameplateGroupHiddenChoice()
                  -- RabbusSpeedrun.ApplyNameplateGroupHiddenSetting(sV.nameplatesHidden, sV.nameplates, value, RabbusSpeedrun.npChanged, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES)
                end,
            		scrollable = 6,
                -- disabled = function() return not sV.hideNameplates end,
                width = "half"
            },

            {		type = 'dropdown',		name = "Healthbar Choice",
            		choices = RabbusSpeedrun.GetNameplateGroupHiddenOptions(),
            		getFunc = function() return sV.healthBarsHidden end,
            		setFunc = function(value)
                  sV.healthBarsHidden = value
                  RabbusSpeedrun.ApplyHealthbarGroupHiddenChoice()
                  RabbusSpeedrun.ApplyNameplateGroupHiddenSetting(sV.healthBarsHidden, sV.healthBars, value, RabbusSpeedrun.hbChanged, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
                end,
            		scrollable = 6,
                -- disabled = function() return not sV.hideHealthbars end,
                width = "half"
            },

            {		type = 'dropdown',		name = "Nameplate Highlight",
            		choices = RabbusSpeedrun.GetNameplateGroupHiddenOptions(),
            		getFunc = function() return sV.nameplatesHiddenHL end,
            		setFunc = function(value)
                  sV.nameplatesHiddenHL = value
                  RabbusSpeedrun.ApplyNameplateHighlightGroupHiddenChoice()
                  -- RabbusSpeedrun.ApplyNameplateGroupHiddenSetting(sV.nameplatesHiddenHL, sV.nameplatesHL, value, RabbusSpeedrun.npHlChanged, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT)
                end,
            		scrollable = 5,
                -- disabled = function() return sV.nameplatesHidden == "never" and true or false end,
                width = "half"
            },

            {		type = 'dropdown',		name = "Healthbar Highlight",
            		choices = RabbusSpeedrun.GetNameplateGroupHiddenOptions(),
            		getFunc = function() return sV.healthBarsHiddenHL end,
            		setFunc = function(value)
                  sV.healthBarsHiddenHL = value
                  RabbusSpeedrun.ApplyHealthbarHighlightGroupHiddenChoice()
                  -- RabbusSpeedrun.ApplyNameplateGroupHiddenSetting(sV.healthBarsHiddenHL, sV.healthBarsHL, value, RabbusSpeedrun.hbHlChanged, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT)
                end,
            		scrollable = 5,
                -- disabled = function() return sV.healthBarsHidden == "never" and true or false end,
                width = "half"
            },

            { type = "divider"      },

            -- {		type = "description",	text = "In case your preferences for nameplates and healthbars when not using hide group has been saved incorrectly for any reason, you can correct them here."
            -- },

            {		type = "description",	text = "For now you have to specify these if you're using Hide Group to make sure your settings are being restored correctly when Hide Group is turned off. Not needed if you don't use it at all.\nI'm working on making it update correctly on its own."
            },

            {		type = 'dropdown',		name = "Backup Nameplate Setting",
            		choices = RabbusSpeedrun.GetNameplateGroupShownOptions(),
            		getFunc = function() return RabbusSpeedrun.GetSavedNameplateSetting(sV.nameplates) end,
            		setFunc = function(value)
                  local choice = GetNameplateChoice(value)
                  sV.nameplates = choice
                  if cV.groupHidden == false then RabbusSpeedrun.RestoreNameplateSettings() end
                end,
            		scrollable = 6,
                width = "half"
            },

            {		type = 'dropdown',		name = "Backup Healthbar Setting",
            		choices = RabbusSpeedrun.GetNameplateGroupShownOptions(),
            		getFunc = function() return npGroupShownOptions[sV.healthBars] end,
            		setFunc = function(value)
                  local choice = GetNameplateChoice(value)
                  sV.healthBars = choice
                  if cV.groupHidden == false then RabbusSpeedrun.RestoreHealthBarSettings() end
                end,
            		scrollable = 6,
                width = "half"
            },

            {		type = 'dropdown',		name = "Backup Nameplate Highlight",
            		choices = RabbusSpeedrun.GetNameplateGroupShownOptions(),
            		getFunc = function() return npGroupShownOptions[sV.nameplatesHL] end,
            		setFunc = function(value)
                  local choice = GetNameplateChoice(value)
                  sV.nameplatesHL = choice
                  if cV.groupHidden == false then RabbusSpeedrun.RestoreNameplateSettings() end
                end,
            		scrollable = 5,
                width = "half"
            },

            {		type = 'dropdown',		name = "Backup Healthbar Highlight",
            		choices = RabbusSpeedrun.GetNameplateGroupShownOptions(),
            		getFunc = function() return npGroupShownOptions[sV.healthBarsHL] end,
            		setFunc = function(value)
                  local choice = GetNameplateChoice(value)
                  sV.healthBarsHL = choice
                  if cV.groupHidden == false then RabbusSpeedrun.RestoreHealthBarSettings() end
                end,
                scrollable = 5,
                width = "half"
            }
          }
        },

        { type = "divider"	},

        -- RabbusSpeedrun.CreateFoodReminderSettings(),

        { type = "submenu",     name = "Food Reminder",
          controls = {

            { type = "description",  text = "The food reminder will let you know when there is less than 10 minutes left of your food buff, and will keep informing you in intervals.\nOnly in trials."
            },

            { type = "checkbox",    name = "Enable",
              tooltip = "Enable food reminder.",
              default = false,
              getFunc = function() return sV.food.show end,
              setFunc = function(newValue)
                sV.food.show = newValue
                RabbusSpeedrun.ToggleFoodReminder()
              end,
              width   = "half"
            },

            { type = "checkbox",    name = "Unlock",
              default = false,
              getFunc = function() return RabbusSpeedrun.foodUnlocked end,
              setFunc = function(newValue)
                RabbusSpeedrun.foodUnlocked = newValue
                RabbusSpeedrun.ShowFoodReminder(newValue)
              end,
              width   = "half"
            },

            { type = "slider",      name = "Size",
              getFunc = function() return sV.food.size end,
              setFunc = function(newValue)
                sV.food.size = newValue
                RabbusSpeedrun.UpdateFoodReminderSize()
              end,
              min = 17,
              max = 50,
              default = 30,
              width = "half"
            },

            { type = "slider",      name = "Reminder Interval",
              tooltip = "How often you want to be reminded when your food buff has expired (in seconds).\n0 = Always show if no food is active.",
              getFunc = function() return sV.food.time end,
              setFunc = function(newValue)
                sV.food.time = newValue
                if sV.food.show then
                  RabbusSpeedrun.UpdateFoodReminderInterval((GetGameTimeMilliseconds() / 1000), sV.food.time)
                end
              end,
              min = 30,
              max = 300,
              default = 120,
              width = "half"
            },
          }
        },

        { type = "divider"  },

        { type = "description",
          text = "Block the interaction choice pop-up with other players while in combat and in a location matching the setting's name, allowing you to only use the ressurect option if available.",
          width = "full"
        },

        { type = "checkbox",		name = "Block Always",
          tooltip = "Will apply while in combat in any location.",
          default = false,
          getFunc = function() return sV.interactBlockAny end,
          setFunc = function(newValue)
            sV.interactBlockAny = newValue
          end,
          width = "half"
        },

        { type = "description",	width = "half"	},

        { type = "checkbox",		name = "Block in Trials",
          tooltip = "Will apply while in combat in any Trial.",
          default = false,
          getFunc = function() return sV.interactBlockTrial end,
          setFunc = function(newValue)
            sV.interactBlockTrial = newValue
          end,
          disabled = function() return sV.interactBlockAny end,
          width = "half"
        },

        { type = "checkbox",		name = "Block in PvP",
          tooltip = "Will apply while in combat in Cyrodiil, Imperial City and Battlegrounds.",
          default = false,
          getFunc = function() return sV.interactBlockPvP end,
          setFunc = function(newValue)
            sV.interactBlockPvP = newValue
          end,
          disabled = function() return sV.interactBlockAny end,
          width = "half"
        },

        { type = "divider"	},

        WalkInLava()

      },
    },
  }

  RabbusSpeedrun.SetTrialMenuHandlers()

  LAM:RegisterOptionControls("RabbusSpeedrun_Settings", optionsData)
end
