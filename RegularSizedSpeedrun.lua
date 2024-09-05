-----------------
---- Globals ----
-----------------
RegularSizedSpeedrun = RegularSizedSpeedrun or {}
local RegularSizedSpeedrun = RegularSizedSpeedrun
local EM = EVENT_MANAGER
local sV
local cV
RegularSizedSpeedrun.name               = "RegularSizedSpeedrun"
RegularSizedSpeedrun.version            = "0.1.9.6"
RegularSizedSpeedrun.activeProfile      = ""
RegularSizedSpeedrun.raidID             = 0
RegularSizedSpeedrun.zone               = 0
RegularSizedSpeedrun.raidList           = {}
RegularSizedSpeedrun.stepList           = {}
RegularSizedSpeedrun.customTimerSteps   = {}
RegularSizedSpeedrun.segments           = {}
RegularSizedSpeedrun.segmentTimer       = {}
RegularSizedSpeedrun.currentRaidTimer   = {}
RegularSizedSpeedrun.displayVitality    = ""
RegularSizedSpeedrun.lastBossName       = ""
RegularSizedSpeedrun.currentBossName    = ""
RegularSizedSpeedrun.isBossDead         = true
RegularSizedSpeedrun.Step               = 1
RegularSizedSpeedrun.arenaRound         = 1
RegularSizedSpeedrun.timeStarted        = nil
RegularSizedSpeedrun.totalScore         = 0
-- RegularSizedSpeedrun.slain							= {}
RegularSizedSpeedrun.inCombat           = false
RegularSizedSpeedrun.fightBegin         = 0
RegularSizedSpeedrun.isNormal           = false
RegularSizedSpeedrun.isComplete         = false
RegularSizedSpeedrun.trialState         = -1 -- not in trial: -1, in trial: 0 = not started, 1 = active, 2 = complete.
RegularSizedSpeedrun.isUIDrawn          = false
RegularSizedSpeedrun.isScoreSet         = false
RegularSizedSpeedrun.inMenu             = false
RegularSizedSpeedrun.currentTrialMenu   = nil
RegularSizedSpeedrun.profileToImportTo  = ""
RegularSizedSpeedrun.profileNames       = {}
RegularSizedSpeedrun.foodUnlocked       = false
local crMindblast           = 104515
local crAmulet              = 106023
local confirmedST           = false
-------------------
---- Functions ----
-------------------
function RegularSizedSpeedrun.GetSavedTimer(raidID, step)
  local cStep = RegularSizedSpeedrun.GetCustomTimerStep(raidID, step)
  if cStep and cStep ~= "" then
    cStep = tonumber(cStep)
    return cStep * 1000
  end

  local tStep = RegularSizedSpeedrun.GetSavedTimerStep(raidID, step)
  if tStep then return tStep end

  -- return 0
end

function RegularSizedSpeedrun.FormatRaidTimer(timer, ms)
  ms = ms or true
  local raidDurationSec
  local r = 0
  local timerFormat = ""

  if ms then
    if timer == 0 then raidDurationSec = math.floor(timer / 1000)
    else
      if timer > 0 then
        if (timer % 1000) >= 500 then r = 1 end
      end
      raidDurationSec = math.floor(timer / 1000) + r
    end
  else
    if timer >= 0 then raidDurationSec = timer
    else raidDurationSec = 0 end
  end

  if raidDurationSec then
    local returnedString = ""

    if raidDurationSec < 0 then returnedString = "-" end

    if raidDurationSec < 3600 and raidDurationSec > -3600 then
      timerFormat = returnedString .. string.format("%02d:%02d",
      math.floor((math.abs(raidDurationSec) / 60) % 60),
      math.abs(raidDurationSec) % 60)
    else
      timerFormat = returnedString .. string.format("%02d:%02d:%02d",
      math.floor(math.abs(raidDurationSec) / 3600),
      math.floor((math.abs(raidDurationSec) / 60) % 60),
      math.abs(raidDurationSec) % 60)
    end
    return timerFormat
  end
end

function RegularSizedSpeedrun.FormatTimerForChatUpdate(timer)
  -- local h = ""
  -- local seconds = timer / 1000
  -- if seconds >= 3600 then
  --   h = string.format("%02d", math.floor(seconds / 3600)) .. ":"
  -- end
  -- local m  = string.format("%02d", math.floor(seconds / 60) % 60)
  -- local s  = string.format("%02d", math.floor(seconds) % 60)
  -- local ms = string.format("%02d", math.floor(zo_round(timer / 10)) % 100)
  -- local chatString = h .. m .. ":" .. s .. "." .. ms

  local chatString = ZO_FormatTime(timer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS)
  return chatString
end

function RegularSizedSpeedrun.FormatRaidScore(score)
  score = tostring(score)
  local fScore = string.sub(score,string.len(score)-2,string.len(score))
  local dScore = string.gsub(score,fScore,"")
  local string = dScore .. "'" .. fScore
  return string
end

-- Trial Score = (Base Score + Vitality x 1000) x (1 + (Par time - Your time(sec)) /10000)
function RegularSizedSpeedrun.GetScore(timer, vitality, raidID)
  --AA
  if     raidID == 638  then return (124300 + (1000 * vitality)) * (1 + (900 - timer) / 10000)
    --HRC
  elseif raidID == 636  then return (133100 + (1000 * vitality)) * (1 + (900 - timer) / 10000)
    --SO
  elseif raidID == 639  then return (142700 + (1000 * vitality)) * (1 + (1500 - timer) / 10000)
    --MoL
  elseif raidID == 725  then return (108150 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    --HoF
  elseif raidID == 975  then return (160100 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    --AS
  elseif raidID == 1000 then return (70000  + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    --CR
  elseif raidID == 1051 then
    if RegularSizedSpeedrun.addsOnCR == false then return (85750 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    else return (88000 + (1000 * vitality)) * (1 + (1200 - timer) / 10000) end
    --BRP
  elseif raidID == 1082 then return (75000  + (1000 * vitality)) * (1 + (2400 - timer) / 10000)
    --MA
  elseif raidID == 677  then return (426000 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    --DSA
  elseif raidID == 635  then return (20000  + (1000 * vitality)) * (1 + (3600 - timer) / 10000)
    --SS
  elseif raidID == 1121 then
    if RegularSizedSpeedrun.hmOnSS == 1 then return (87250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RegularSizedSpeedrun.hmOnSS == 2 then return (127250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RegularSizedSpeedrun.hmOnSS == 3 then return (167250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RegularSizedSpeedrun.hmOnSS == 4 then return (207250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000) end
    --KA
  elseif raidID == 1196 then return (205950 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    --VH
  elseif raidID == 1227 then return (205450 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    -- RG
  elseif raidID == 1263 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    -- DSR TODO
  elseif raidID == 1344 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    -- SE TODO
  elseif raidID == 1427 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    -- LC TODO
  elseif raidID == 1478 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)

  else return 0 end
end

function RegularSizedSpeedrun.UpdateWaypointNew(raidDuration)
  local raid = RegularSizedSpeedrun.raidList[RegularSizedSpeedrun.raidID]
  local waypoint = RegularSizedSpeedrun.Step

  if raid then

    if not RegularSizedSpeedrun.Data.stepList[raid.id][waypoint] or raidDuration < 1 then return end

    RegularSizedSpeedrun.currentRaidTimer[waypoint] = math.floor(raidDuration)
    sV.currentRaidTimer[waypoint] = RegularSizedSpeedrun.currentRaidTimer[waypoint]
    RegularSizedSpeedrun.UpdateWindowPanel(waypoint, RegularSizedSpeedrun.raidID)

    local timerWaypoint = 0
    if RegularSizedSpeedrun.currentRaidTimer[waypoint - 1] then
      timerWaypoint = RegularSizedSpeedrun.currentRaidTimer[waypoint] - RegularSizedSpeedrun.currentRaidTimer[waypoint - 1]
    else
      timerWaypoint = RegularSizedSpeedrun.currentRaidTimer[waypoint]
    end

    if (raid.timerSteps[waypoint] == nil or raid.timerSteps[waypoint] <= 0 or raid.timerSteps[waypoint] > timerWaypoint) then
      raid.timerSteps[waypoint] = timerWaypoint
      RegularSizedSpeedrun.SaveTimerStep(raid.id, waypoint, timerWaypoint)
    end

    if RegularSizedSpeedrun.raidID == 1082 then -- BRP
      RegularSizedSpeedrun:dbg(2, "Stage: <<1>>, Round: <<2>>, Step: <<3>>.", RegularSizedSpeedrun.GetBRPStage(), RegularSizedSpeedrun.arenaRound, RegularSizedSpeedrun.GetBRPStep())
    end

    RegularSizedSpeedrun.Step = RegularSizedSpeedrun.Step + 1
    sV.Step = RegularSizedSpeedrun.Step

    if (sV.printStepUpdate) then
      RegularSizedSpeedrun:dbg(0, '[|ce6b800<<1>>|r] |c00ff00Step <<2>>|r at |cffffff<<3>>|r.', GetUnitZone('player'), waypoint, RegularSizedSpeedrun.FormatTimerForChatUpdate(GetRaidDuration() / 1000))
    end
  end
end

RegularSizedSpeedrun.ScoreUpdate = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  RegularSizedSpeedrun.totalScore = totalScore
  sV.totalScore       = RegularSizedSpeedrun.totalScore
  local scoreTimer    = GetRaidDuration()
  local sT            = RegularSizedSpeedrun.FormatRaidTimer(scoreTimer, true)

  for k, v in pairs(RegularSizedSpeedrun.scores) do

    if RegularSizedSpeedrun.scores[k] == scoreUpdateReason or RegularSizedSpeedrun.scores[k].id == scoreUpdateReason then
      RegularSizedSpeedrun.scores[k].times = RegularSizedSpeedrun.scores[k].times + 1
      RegularSizedSpeedrun.scores[k].total = RegularSizedSpeedrun.scores[k].total + scoreAmount
      sV.scores[k].times       = RegularSizedSpeedrun.scores[k].times
      sV.scores[k].total       = RegularSizedSpeedrun.scores[k].total

      if scoreUpdateReason ~= 9 then
        RegularSizedSpeedrun:dbg(3, '[|cffffff<<4>>|r] +|cffffff<<2>>|r (|cffffff<<1>>|r) - Total: |cffffff<<3>>|r - |cffffff<<5>>|r.', RegularSizedSpeedrun.scores[k].name, scoreAmount, totalScore, sT, GetMapName())
      end
    end
  end

  if RegularSizedSpeedrun.raidID == 1227 then
    RegularSizedSpeedrun.UpdateAdds()

  elseif RegularSizedSpeedrun.raidID == 636 and RegularSizedSpeedrun.Step <= 4 then
    local b = RegularSizedSpeedrun.scores[5].times
    if ((RegularSizedSpeedrun.Step == 2) and (b == 1)) or ((RegularSizedSpeedrun.Step == 4) and (b == 3)) then
      RegularSizedSpeedrun.lastBossName 		= RegularSizedSpeedrun.currentBossName
      sV.lastBossName 					= RegularSizedSpeedrun.lastBossName
      RegularSizedSpeedrun.currentBossName  = ""
      sV.currentBossName 				= RegularSizedSpeedrun.currentBossName
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
      EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "HelRaCitadel", 1000, RegularSizedSpeedrun.MainHRC)
    end
  end
  RegularSizedSpeedrun.UpdateCurrentScore()
end

function RegularSizedSpeedrun.UpdateAdds()
  if not GetZoneId(GetUnitZoneIndex("player")) == 1227 then return end

  for k, v in pairs(RegularSizedSpeedrun.scores) do
    local score = RegularSizedSpeedrun.scores[k]

    if score == 1 or score.id == RAID_POINT_REASON_KILL_NORMAL_MONSTER then
      SpeedRun_Adds_SA:SetText(score.name .. ":")
      SpeedRun_Adds_SA_Counter:SetText(score.times .. " / 68")

      if score.times == 68 then
        SpeedRun_Adds_SA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_SA_Counter:SetColor(1, 1, 1, 1)
      end

    elseif score == 2 or score.id == RAID_POINT_REASON_KILL_BANNERMEN then
      SpeedRun_Adds_LA:SetText(score.name .. ":")
      SpeedRun_Adds_LA_Counter:SetText(score.times .. " / 33")

      if score.times == 33 then
        SpeedRun_Adds_LA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_LA_Counter:SetColor(1, 1, 1, 1)
      end

    elseif score == 3 or score.id == RAID_POINT_REASON_KILL_CHAMPION then
      SpeedRun_Adds_EA:SetText(score.name .. ":")
      SpeedRun_Adds_EA_Counter:SetText(score.times .. " / 15")

      if score.times == 15 then
        SpeedRun_Adds_EA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_EA_Counter:SetColor(1, 1, 1, 1)
      end
    end
  end
end
----------------
---- Arenas ----
----------------
function RegularSizedSpeedrun.GetBRPStage()
  local x, y = GetMapPlayerPosition('player');
  if (x > 0.54 and x < 0.64 and y > 0.79 and y < 0.89) then return 1
  elseif (x > 0.3  and x < 0.4  and y > 0.69 and y < 0.8 ) then return 2
  elseif (x > 0.41 and x < 0.52 and y > 0.43 and y < 0.53) then return 3
  elseif (x > 0.63 and x < 0.73 and y > 0.22 and y < 0.32) then return 4
  elseif (x > 0.4  and x < 0.5  and y > 0.08 and y < 0.18) then return 5
  else return 0 end
end

function RegularSizedSpeedrun.GetBRPStep()
  local step = ((RegularSizedSpeedrun.GetBRPStage() * 5) - 5) + RegularSizedSpeedrun.arenaRound
  return step
end

function RegularSizedSpeedrun.Announcement(_, title, _)
  if title == 'Final Round' or title == 'Letzte Runde' or title == 'Dernière manche' or title == 'Последний раунд' or title == '最終ラウンド' then
    RegularSizedSpeedrun.arenaRound = 5
    sV.arenaRound 			= RegularSizedSpeedrun.arenaRound
  else
    local round = string.match(title, '^.+%s(%d)$')
    if round then
      RegularSizedSpeedrun.arenaRound = tonumber(round)
      sV.arenaRound 			= RegularSizedSpeedrun.arenaRound
    end
  end
end

function RegularSizedSpeedrun.PortalSpawnBRP(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

  if result == ACTION_RESULT_EFFECT_GAINED then
    local t = GetGameTimeMilliseconds()
    if t - lastPortal > 2000 then brpWave = brpWave + 1 end
    lastPortal = t
  end
end

RegularSizedSpeedrun.MainArena = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  if (RegularSizedSpeedrun.raidID == 677) then --MA
    if RegularSizedSpeedrun.Step <= 8 and scoreUpdateReason == 17 then
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_SOLO_ARENA_COMPLETE) then
      RegularSizedSpeedrun.isBossDead = true
      sV.isBossDead       = RegularSizedSpeedrun.isBossDead
    end

  elseif RegularSizedSpeedrun.raidID == 1082 then --BRP
    if (RegularSizedSpeedrun.Step <= 24 and (scoreUpdateReason >= 13 and scoreUpdateReason <= 16) or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE) then
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
      RegularSizedSpeedrun.isBossDead = true
      sV.isBossDead       = RegularSizedSpeedrun.isBossDead
    end

  elseif RegularSizedSpeedrun.raidID == 635 then --DSA
    if (scoreUpdateReason == RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM) then
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
      RegularSizedSpeedrun.isBossDead = true
      sV.isBossDead       = RegularSizedSpeedrun.isBossDead
    end
  end
end

local lastPrint = ""
local sideBoss  = ""
function RegularSizedSpeedrun.MainVH()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then

      --zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = GetUnitName("boss" .. i)
      RegularSizedSpeedrun.currentBossName = string.lower(boss)

      if lastPrint ~= RegularSizedSpeedrun.currentBossName then
        lastPrint = RegularSizedSpeedrun.currentBossName
        RegularSizedSpeedrun:dbg(2, "<<1>> Detected!", boss)
      end

      -- local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if RegularSizedSpeedrun.Step <= 6 then

        if ((RegularSizedSpeedrun.currentBossName == RegularSizedSpeedrun.lastBossName) or not IsUnitInCombat("player")) then return end

        if (string.find("leptfire", RegularSizedSpeedrun.currentBossName) or string.find("xobutar", RegularSizedSpeedrun.currentBossName) or string.find("mynar", RegularSizedSpeedrun.currentBossName)) then
          if RegularSizedSpeedrun.isSideBoss == false then
            RegularSizedSpeedrun.isSideBoss = true
            sideBoss            = boss
          end
        else
          RegularSizedSpeedrun.isSideBoss = false
          sideBoss            = ""
        end

        if (RegularSizedSpeedrun.isSideBoss == true and IsUnitInCombat("player")) then
          EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "SideBoss")
          EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "SideBoss", 100, RegularSizedSpeedrun.SideBoss)
          return
        end

        if IsUnitInCombat("player") then
          if RegularSizedSpeedrun.lastBossName ~= RegularSizedSpeedrun.currentBossName then
            EM:RegisterForEvent(RegularSizedSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RegularSizedSpeedrun.arenaBoss)
          else
            return
          end
        end
      end
    end
  end
end

function RegularSizedSpeedrun.SideBoss()
  local current, max, effmax = GetUnitPower("boss1", POWERTYPE_HEALTH)

  if current <= 0 then
    EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "SideBoss")
    RegularSizedSpeedrun:dbg(1, "|cdf4242<<1>>|r killed at |cffff00<<2>>|r", sideBoss, RegularSizedSpeedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    RegularSizedSpeedrun.lastBossName = RegularSizedSpeedrun.currentBossName
    sV.lastBossName       = RegularSizedSpeedrun.lastBossName
  end
end

RegularSizedSpeedrun.arenaBoss = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  if scoreUpdateReason == 13 or scoreUpdateReason == 14 or scoreUpdateReason == 15 or scoreUpdateReason == 16 or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE then

    RegularSizedSpeedrun.lastBossName     = RegularSizedSpeedrun.currentBossName
    sV.lastBossName           = RegularSizedSpeedrun.lastBossName
    RegularSizedSpeedrun.currentBossName  = ""
    RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
    EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)

    zo_callLater(function()
      EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "VHBoss")
      EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "VHBoss", 1000, RegularSizedSpeedrun.MainVH)
    end, 2000)
  end
end
----------------
---- Trials ----
----------------
-- function RegularSizedSpeedrun.MiniTrial()

local zmaja   = {}
local isZmaja = false

function RegularSizedSpeedrun.OnCombatEnd()
  if IsUnitInCombat("player") then return end
  zo_callLater(function()
    if (not IsUnitInCombat("player") and not RegularSizedSpeedrun.isComplete) then
      RegularSizedSpeedrun.inCombat         = false
      RegularSizedSpeedrun.currentRaidTimer = {}
      sV.currentRaidTimer       = RegularSizedSpeedrun.currentRaidTimer
      RegularSizedSpeedrun.isBossDead       = true
      sV.isBossDead             = RegularSizedSpeedrun.isBossDead
      RegularSizedSpeedrun.Step             = 1
      sV.Step                   = RegularSizedSpeedrun.Step
      if RegularSizedSpeedrun.raidID == 1051 then
        zmaja   = {}
        isZmaja = false
        EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "CombatEnded")
        EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "MiniTrial")
        EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end, 3000)
end

function RegularSizedSpeedrun.CombatCR()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local current, max, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      if (max > 64000000 and IsUnitAttackable("boss" .. i)) then
        if IsUnitInCombat("player") then
          -- zmaja name: ["Z'Maja"], ["З'Маджа"], ["ズマジャ"]
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          RegularSizedSpeedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = RegularSizedSpeedrun.currentBossName
          local z = {
            index     = i,
            name      = RegularSizedSpeedrun.currentBossName,
            hpMax	    = max,
            hpCurrent = current,
          }
          zmaja   = z
          isZmaja = true
          if RegularSizedSpeedrun.Step == 1 then
            RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
            EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "MiniTrial")
            EM:RegisterForUpdate(	RegularSizedSpeedrun.name .. "MiniTrial", 333, RegularSizedSpeedrun.MainCloudrest)
          end
          RegularSizedSpeedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "CombatEnded", 4000, RegularSizedSpeedrun.OnCombatEnd)
          end, 1000)
        end

      else
        isZmaja = false
      end
    end
  end
end

function RegularSizedSpeedrun.ZmajaShade()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = string.lower(GetUnitName("boss" .. i))
      if (boss ~= zmaja.name and RegularSizedSpeedrun.Step == 5) then
        -- if (boss ~= RegularSizedSpeedrun.currentBossName and RegularSizedSpeedrun.Step == 5) then
        RegularSizedSpeedrun.currentBossName  = boss
        sV.currentBossName        = RegularSizedSpeedrun.currentBossName
        RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end
end

-- IsUnitActivelyEngaged(string unitTag)
-- Returns: boolean isActivelyEngaged

-- IsUnitAttackable(string unitTag)
-- Returns: boolean attackable

function RegularSizedSpeedrun.MainCloudrest()
  if isZmaja then
    local current, max, effectiveMax = GetUnitPower("boss" .. zmaja.index, POWERTYPE_HEALTH)
    local percentageHP = current / max

    -- check for highest possible step in case 1 or 2 steps were passed while player was in portal
    if (percentageHP <= 0.06) then
      -- if RegularSizedSpeedrun.Step < 5 then
      RegularSizedSpeedrun.Step = 4
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
      EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      EM:RegisterForEvent(RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, RegularSizedSpeedrun.ZmajaShade)
      EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "MiniTrial")
      return
      -- end
    elseif (percentageHP <= 0.25 and percentageHP >= 0.06) then
      if RegularSizedSpeedrun.Step < 4 then
        RegularSizedSpeedrun.Step = 3
        RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
        -- EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
        -- EM:RegisterForEvent(RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, RegularSizedSpeedrun.ZmajaShade)
        return
      end

    elseif (percentageHP <= 0.5 and percentageHP > 0.25) then
      if RegularSizedSpeedrun.Step < 3 then
        RegularSizedSpeedrun.Step = 2
        RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end

    elseif (percentageHP <= 0.75 and percentageHP > 0.5) then
      if RegularSizedSpeedrun.Step < 2 then
        RegularSizedSpeedrun.Step = 1
        RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end
    end

  else
    EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "MiniTrial")
  end
end

function RegularSizedSpeedrun.CombatAS()
  if IsUnitInCombat("player") then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if maxTargetHP > 99000000 then
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          RegularSizedSpeedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = RegularSizedSpeedrun.currentBossName
          RegularSizedSpeedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "CombatEnded", 4000, RegularSizedSpeedrun.OnCombatEnd)
          end, 1000)
        end
      end
    end
  end
end

function RegularSizedSpeedrun.MainAsylum()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      local percentageHP = currentTargetHP / maxTargetHP
      --start fight with boss
      if RegularSizedSpeedrun.inCombat and RegularSizedSpeedrun.isBossDead == true then
        --Olms got more than 99Million HP
        if (RegularSizedSpeedrun.Step == 1    and maxTargetHP   >= 99000000) then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.9  and RegularSizedSpeedrun.Step == 2       ) then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.75 and RegularSizedSpeedrun.Step == 3       ) then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.5  and RegularSizedSpeedrun.Step == 4       ) then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.25 and RegularSizedSpeedrun.Step == 5       ) then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
      -- else
      --   if (currentTargetHP > 0 and RegularSizedSpeedrun.Step <= 6) then
      --     RegularSizedSpeedrun.currentRaidTimer = {}
      --     sV.currentRaidTimer = RegularSizedSpeedrun.currentRaidTimer
      --     RegularSizedSpeedrun.Step = 1
      --     sV.Step = RegularSizedSpeedrun.Step
      --   elseif currentTargetHP <= 0 then
      --     -- not in HM
      --     RegularSizedSpeedrun.isBossDead = false
      --     sV.isBossDead = RegularSizedSpeedrun.isBossDead
        -- end
      end
    end
  end
end

function RegularSizedSpeedrun.MainHRC()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      RegularSizedSpeedrun.currentBossName   = string.lower(GetUnitName("boss" .. i))
      if (RegularSizedSpeedrun.lastBossName == RegularSizedSpeedrun.currentBossName) then return end
      if IsUnitInCombat("player") then
        RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "HelRaCitadel")
      end
    else return end
  end
end

function RegularSizedSpeedrun.LastArchive()
  if IsUnitInCombat("player") and RegularSizedSpeedrun.Step == 6 then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if currentTargetHP > 0 then
          RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
          --Unregister for update then register again on update for UI panel
          EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "LastAA")
        end
      end
    end
  end
end

function RegularSizedSpeedrun.BossFightBegin()
  for i = 1, MAX_BOSSES do
    local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
    if IsUnitInCombat("player") and (current < max) then
      EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "BossFight")
      RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())
      -- RegularSizedSpeedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), RegularSizedSpeedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    end
  end
end

function RegularSizedSpeedrun.MainBoss()
  if RegularSizedSpeedrun.Step == 6 and RegularSizedSpeedrun.raidID == 638 then
    --to trigger the mage
    EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "LastAA", 333, RegularSizedSpeedrun.LastArchive)
  end

  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))

      local name = GetUnitName("boss" .. i)

      if string.lower(name) ~= RegularSizedSpeedrun.currentBossName then
        if RegularSizedSpeedrun.fightBegin == 0 and IsUnitInCombat("boss" .. i) then

          RegularSizedSpeedrun.fightBegin = GetRaidDuration()
          RegularSizedSpeedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), RegularSizedSpeedrun.FormatTimerForChatUpdate(RegularSizedSpeedrun.fightBegin / 1000))
        else
          RegularSizedSpeedrun.fightBegin = 0
        end
      end

      RegularSizedSpeedrun.currentBossName  = string.lower(name)
      sV.currentBossName 				= RegularSizedSpeedrun.currentBossName


      if RegularSizedSpeedrun.raidID == 1263 then
        if (string.find(RegularSizedSpeedrun.currentBossName, "snakes") or string.find(RegularSizedSpeedrun.currentBossName, "titan")) then return end
      end

      if RegularSizedSpeedrun.currentBossName == RegularSizedSpeedrun.lastBossName then return end

      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if RegularSizedSpeedrun.isBossDead == true and currentTargetHP > 0 then
        -- boss encounter begins
        RegularSizedSpeedrun.isBossDead = false
        sV.isBossDead 			= RegularSizedSpeedrun.isBossDead

        -- for Nahviintaas (to set time when in combat with the adds since they are relevant to the boss fight)
        if RegularSizedSpeedrun.raidID == 1121 and RegularSizedSpeedrun.Step == 5 then
          if IsUnitInCombat("player") then RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration()) return end
        end

        EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "BossFightBegin")
        EM:RegisterForUpdate(RegularSizedSpeedrun.name .. "BossFight", 50, RegularSizedSpeedrun.BossFightBegin)
      end
    end
  end
end

local function BossMainZoneCheck(zone)
  local mbZones = { [638] = true, [639] = true, [725] = true, [975] = true, [1121] = true, [1196] = true, [1263] = true, [1344] = true, [1427] = true, [1478] = true }
  if mbZones[zone] then return true end
  return false
end

RegularSizedSpeedrun.BossDead = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  local timer

  -- if scoreUpdateReason == RAID_POINT_REASON_KILL_MINIBOSS then
  --   timer = (GetRaidDuration() - RegularSizedSpeedrun.fightBegin) / 1000
  --   RegularSizedSpeedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", RegularSizedSpeedrun.currentBossName, RegularSizedSpeedrun.FormatTimerForChatUpdate(timer))
  --   return
  -- end

  if scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS then

    timer = (GetRaidDuration() - RegularSizedSpeedrun.fightBegin) / 1000

    -- RegularSizedSpeedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", RegularSizedSpeedrun.currentBossName, RegularSizedSpeedrun.FormatTimerForChatUpdate(timer))

    RegularSizedSpeedrun.lastBossName     = RegularSizedSpeedrun.currentBossName
    sV.lastBossName           = RegularSizedSpeedrun.lastBossName
    RegularSizedSpeedrun.currentBossName  = ""
    sV.currentBossName        = RegularSizedSpeedrun.currentBossName
    RegularSizedSpeedrun.isBossDead       = true
    sV.isBossDead             = RegularSizedSpeedrun.isBossDead
    RegularSizedSpeedrun.UpdateWaypointNew(GetRaidDuration())

    -- if BossMainZoneCheck(GetZoneId(GetUnitZoneIndex("player"))) then
    -- 		EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, RegularSizedSpeedrun.MainBoss)
    -- 		EM:RegisterForEvent(RegularSizedSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, RegularSizedSpeedrun.MainBoss)
    -- end
  end
end

function RegularSizedSpeedrun.OnTrialStarted()
  RegularSizedSpeedrun.scores 			= RegularSizedSpeedrun.GetDefaultScores()
  sV.scores 						= RegularSizedSpeedrun.scores
  RegularSizedSpeedrun.RegisterTrialsEvents()
  RegularSizedSpeedrun.UpdateCurrentVitality()
  RegularSizedSpeedrun.trialState 	= 1
  RegularSizedSpeedrun.timeStarted 	= GetGameTimeSeconds()
  sV.timeStarted 				= RegularSizedSpeedrun.timeStarted
  RegularSizedSpeedrun:dbg(1, "Trial: |ce6b800<<1>>|r Started!", GetUnitZone('player'))
end

RegularSizedSpeedrun.OnTrialComplete = function(eventCode, trialName, score, totalTime)
  -- for mini-trials and HRC
  if RegularSizedSpeedrun.raidID == 636 or RegularSizedSpeedrun.raidID == 1000 or RegularSizedSpeedrun.raidID == 1082 or RegularSizedSpeedrun.raidID == 677 or RegularSizedSpeedrun.raidID == 1227 then
    RegularSizedSpeedrun.UpdateWaypointNew(totalTime)
  end
  -- for CR
  if RegularSizedSpeedrun.raidID == 1051 then
    if RegularSizedSpeedrun.Step ~= 6 then
      RegularSizedSpeedrun.Step = 6
      sV.Step = RegularSizedSpeedrun.Step
    end
    RegularSizedSpeedrun.UpdateWaypointNew(totalTime)
  end
  -- save data before resetting in case we need it
  sV.finalScore = score
  sV.totalTime  = totalTime

  if (GetDisplayName() == "@nogetrandom") then RegularSizedSpeedrun.UpdateScoreFactors(RegularSizedSpeedrun.activeProfile, RegularSizedSpeedrun.raidID) end
  RegularSizedSpeedrun.SetLastTrial()

  local scoreString = RegularSizedSpeedrun.FormatRaidScore(sV.finalScore)
  SpeedRun_Score_Label:SetText(scoreString)
  SpeedRun_TotalTimer_Title:SetText(RegularSizedSpeedrun.FormatRaidTimer(sV.totalTime, true))
  RegularSizedSpeedrun.trialState = 2
  RegularSizedSpeedrun.isComplete = true

  RegularSizedSpeedrun.UnregisterTrialsEvents()
  if (sV.printStepUpdate) then
    RegularSizedSpeedrun:dbg(1, "|ce6b800<<1>>|r |c00ff00Complete|r!\n[Time: |cffffff<<2>>|r]  [Score: |cffffff<<3>>|r] <<4>>", GetUnitZone('player'), RegularSizedSpeedrun.FormatTimerForChatUpdate(totalTime / 1000), scoreString, RegularSizedSpeedrun.FormatVitality(true, GetRaidReviveCountersRemaining(), GetCurrentRaidStartingReviveCounters()))
  end
end

function RegularSizedSpeedrun.OnTrialFailed(eventCode, trialName, score)
    -- RegularSizedSpeedrun.Reset()
    -- RegularSizedSpeedrun.ResetUI()
    RegularSizedSpeedrun.UnregisterTrialsEvents()
		RegularSizedSpeedrun:dbg(1, '|ce6b800<<1>>|r |cff0000Failed|r.', trialName)
end
-----------------------
---- Base & Events ----
-----------------------
function RegularSizedSpeedrun.Reset()
  RegularSizedSpeedrun.isComplete 			= false
  sV.isComplete							= RegularSizedSpeedrun.isComplete
  RegularSizedSpeedrun.scores 					= {}
  sV.scores 								= {}
  RegularSizedSpeedrun.scores 					= RegularSizedSpeedrun.GetDefaultScores()
  sV.scores 								= RegularSizedSpeedrun.scores
  RegularSizedSpeedrun.totalScore				= 0
  sV.totalScore							= RegularSizedSpeedrun.totalScore
  RegularSizedSpeedrun.displayVitality 	= ""
  RegularSizedSpeedrun.currentRaidTimer = {}
  sV.currentRaidTimer 			= RegularSizedSpeedrun.currentRaidTimer
  RegularSizedSpeedrun.Step 						= 1
  sV.Step 									= RegularSizedSpeedrun.Step
  RegularSizedSpeedrun.arenaRound				= 0
  sV.arenaRound							= RegularSizedSpeedrun.arenaRound
  RegularSizedSpeedrun.isBossDead 			= true
  sV.isBossDead 						= RegularSizedSpeedrun.isBossDead
  RegularSizedSpeedrun.lastBossName 		= ""
  sV.lastBossName 					= RegularSizedSpeedrun.lastBossName
  RegularSizedSpeedrun.currentBossName 	= ""
  sV.currentBossName 				= RegularSizedSpeedrun.currentBossName
  RegularSizedSpeedrun.isUIDrawn 				= false
  RegularSizedSpeedrun.fightBegin       = 0
  RegularSizedSpeedrun:dbg(2, "Resetting Variables.")
end

function RegularSizedSpeedrun.UnregisterTrialsEvents()
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE)
  EM:UnregisterForEvent( RegularSizedSpeedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT)
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "Update")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "MiniTrial")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "LastAA")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "VHBoss")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "VHSideBoss")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "HelRaCitadel")
  EM:UnregisterForUpdate(RegularSizedSpeedrun.name .. "BossFight")
end

function RegularSizedSpeedrun.RegisterTrialsEvents()
  --AS
  if RegularSizedSpeedrun.raidID == 1000 then
    EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, RegularSizedSpeedrun.CombatAS)
    EM:RegisterForUpdate( RegularSizedSpeedrun.name .. "MiniTrial", 333, RegularSizedSpeedrun.MainAsylum)

  --CR
  elseif RegularSizedSpeedrun.raidID == 1051 then
    EM:RegisterForEvent(  RegularSizedSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, RegularSizedSpeedrun.CombatCR)
    EM:RegisterForUpdate(	RegularSizedSpeedrun.name .. "MiniTrial", 333, RegularSizedSpeedrun.MainCloudrest)
    -- EM:RegisterForEvent(	RegularSizedSpeedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, RegularSizedSpeedrun.CloudrestExecute)
    -- EM:AddFilterForEvent(	RegularSizedSpeedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023)

  --BRP
  elseif RegularSizedSpeedrun.raidID == 1082 then
    EM:RegisterForEvent(  RegularSizedSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RegularSizedSpeedrun.MainArena)
    EM:RegisterForEvent(  RegularSizedSpeedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT, RegularSizedSpeedrun.Announcement)

  -- MA, DSA
  elseif RegularSizedSpeedrun.raidID == 677 or RegularSizedSpeedrun.raidID == 635 then
    EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RegularSizedSpeedrun.MainArena)

  --VH
  elseif GetZoneId(GetUnitZoneIndex("player")) == 1227 then
    EM:RegisterForUpdate(	RegularSizedSpeedrun.name .. "VHBoss", 1000, RegularSizedSpeedrun.MainVH)

  -- HRC
  elseif RegularSizedSpeedrun.raidID == 636 then
    EM:RegisterForUpdate(	RegularSizedSpeedrun.name .. "HelRaCitadel", 1000, RegularSizedSpeedrun.MainHRC)

  -- other raids
  else
    EM:RegisterForEvent( RegularSizedSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, RegularSizedSpeedrun.MainBoss)
    EM:RegisterForEvent( RegularSizedSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, RegularSizedSpeedrun.MainBoss)
    EM:RegisterForEvent( RegularSizedSpeedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE, RegularSizedSpeedrun.BossDead)
  end

  EM:RegisterForUpdate(	RegularSizedSpeedrun.name .. "Update", 900, RegularSizedSpeedrun.UpdateWindowPanel)
  EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE, RegularSizedSpeedrun.UpdateCurrentVitality)
  EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "ScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE, RegularSizedSpeedrun.ScoreUpdate)
  EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, RegularSizedSpeedrun.OnTrialStarted)
  EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, RegularSizedSpeedrun.OnTrialComplete)
  EM:RegisterForEvent( 	RegularSizedSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, RegularSizedSpeedrun.OnTrialFailed)
end

function RegularSizedSpeedrun.OnPlayerActivated( eventCode, initial )
  RegularSizedSpeedrun.IsActivated(initial)

  if cV.isTracking == false then return end

  if RegularSizedSpeedrun.IsInTrialZone() then
    local same = RegularSizedSpeedrun.CheckTrial()

    if not RegularSizedSpeedrun.isUIDrawn then
      RegularSizedSpeedrun.CreateRaidSegment(RegularSizedSpeedrun.raidID, same)
      SpeedRun_TotalTimer_Title:SetText(RegularSizedSpeedrun.FormatRaidTimer(GetRaidDuration(), true))
    end

    RegularSizedSpeedrun.UpdateCurrentScore()
    RegularSizedSpeedrun.UpdateCurrentVitality()
    RegularSizedSpeedrun.RegisterTrialsEvents()
    -- RegularSizedSpeedrun.SetUIHidden(not sV.showUI)
  else
    -- Player is not in a trial. Disable tracking.
    RegularSizedSpeedrun.trialState = -1
    sV.trialState       = RegularSizedSpeedrun.trialState
    RegularSizedSpeedrun.scores     = RegularSizedSpeedrun.GetDefaultScores()
    sV.scores           = RegularSizedSpeedrun.scores
    -- RegularSizedSpeedrun.SetUIHidden(true)
    RegularSizedSpeedrun.UnregisterTrialsEvents()
  end
  RegularSizedSpeedrun.UpdateVisibility()
  RegularSizedSpeedrun.ToggleFoodReminder()
end

-- IsPlayerInRaidStagingArea()
-- IsPlayerInReviveCounterRaid()
-- HasRaidEnded()

-- GetUnitCaption(string unitTag)

function RegularSizedSpeedrun.IsInTrialZone()
  RegularSizedSpeedrun.zone = GetZoneId(GetUnitZoneIndex("player"))
  for k, v in pairs(RegularSizedSpeedrun.Data.raidList) do
    if RegularSizedSpeedrun.Data.raidList[k].id == RegularSizedSpeedrun.zone then

      -- if not IsUnitUsingVeteranDifficulty("player") then
      -- if ZO_GetEffectiveDungeonDifficulty() < 2 then
      if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN then
        if RegularSizedSpeedrun.isNormal == false then
          RegularSizedSpeedrun.isNormal = true
          RegularSizedSpeedrun:dbg(2, "Difficulty: Normal. Hiding UI")
        end
        return false
      end
      RegularSizedSpeedrun.isNormal = false
      return true
    end
  end
  return false
end

function RegularSizedSpeedrun.CheckTrial()
  local shouldReset = false
  local isSame      = false
  local state       = -1

  local function CompletedTrialCheck()
    -- HasRaidEnded()
    if GetRaidDuration() > 0 and (not IsRaidInProgress()) then
      state = 2
      return true
    end
    return false
  end

  local function NewTrialCheck()
    -- using only GetRaidDuration <= 0 can mess up when trial is started.
    -- New instance. Reset variables from last trial
    if GetRaidDuration() <= 0 and (not IsRaidInProgress()) then
      state = 0
      return true
    end
    -- We can only get to here if trial is currently in progress.
    state = 1
    return false
  end

  -- Use active raid timer to evaluate if player is returning to the same active trial instance.
  local function IsActiveTrialOldTrial()
    if RegularSizedSpeedrun.zone ~= RegularSizedSpeedrun.raidID then return false end
    if (state ~= 1) then return false end

    if RegularSizedSpeedrun.Step == 1 then
      RegularSizedSpeedrun.isBossDead   = true
      sV.isBossDead         = RegularSizedSpeedrun.isBossDead
      RegularSizedSpeedrun.lastBossName = ""
      sV.lastBossName       = RegularSizedSpeedrun.lastBossName
    end

    -- Check if trial was started at the same time as players currently active trial.
    -- Not sure yet if we need a +/- 10 sec buffer for this. probably not...
    local time = GetGameTimeSeconds() - RegularSizedSpeedrun.timeStarted
    local duration = GetRaidDuration() / 1000
    if ((time <= (duration + 10)) and (time >= (duration - 10))) then return true end
    return false
  end

  -- In trial but it's complete.
  -- Setup UI in case it was reloaded, or leave as is until next reset.
  if CompletedTrialCheck() then
    if not RegularSizedSpeedrun.isUIDrawn then RegularSizedSpeedrun.CreateRaidSegment(RegularSizedSpeedrun.zone) end
    SpeedRun_Score_Label:SetText(RegularSizedSpeedrun.FormatRaidScore(sV.finalScore))
    SpeedRun_TotalTimer_Title:SetText(RegularSizedSpeedrun.FormatRaidTimer(sV.totalTime, true))
    RegularSizedSpeedrun.isComplete = true
    RegularSizedSpeedrun.trialState = 2
    RegularSizedSpeedrun:dbg(3, "Trial is Complete. Returning.")
    return
  end

  -- Trial Variables are no longer reset when leaving an unfinished trial.
  -- Check if player is returning to their active unfinished trial else reset.
  if NewTrialCheck() then
    RegularSizedSpeedrun:dbg(3, "New Trial.")
    shouldReset = true
  else
    if IsActiveTrialOldTrial() then
      RegularSizedSpeedrun:dbg(3, "Same Trial.")
      isSame = true
    else
      RegularSizedSpeedrun:dbg(3, "Trial active (not same).")
      shouldReset = true
    end
  end

  if shouldReset == true then
    RegularSizedSpeedrun.Reset()
    RegularSizedSpeedrun.ResetUI()

    -- Set current game time as reference in case player will port out and re-enter.
    if IsRaidInProgress() then
      RegularSizedSpeedrun.timeStarted  = GetGameTimeSeconds() - (GetRaidDuration() / 1000)
      sV.timeStarted        = RegularSizedSpeedrun.timeStarted

      -- GetTimeStamp()
      -- Returns: id64 timestamp
      -- GetTimeString()
      -- Returns: string currentTimeString

    end
  end
  RegularSizedSpeedrun.raidID     = RegularSizedSpeedrun.zone
  sV.raidID           = RegularSizedSpeedrun.raidID
  RegularSizedSpeedrun.trialState = state
  sV.trialState       = RegularSizedSpeedrun.trialState
  return isSame
end

function RegularSizedSpeedrun.ToggleTracking()
  RegularSizedSpeedrun.Tracking(not cV.isTracking)
end

function RegularSizedSpeedrun.Tracking(track)
  if track ~= true then
    -- take no action if not already registered
    if cV.isTracking == false then return end
    -- shut down everything trial related
    EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED)
    EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
    EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED)
    RegularSizedSpeedrun.UnregisterTrialsEvents()
    RegularSizedSpeedrun.SetUIHidden(true)
    -- RegularSizedSpeedrun.Reset()
    RegularSizedSpeedrun:dbg(0, "Score and Time tracking set to: |cffffffOFF|r")
  else
    -- only if tracking was previously off
    if cV.isTracking ~= track then
      RegularSizedSpeedrun.Reset()
      RegularSizedSpeedrun.ResetUI()
      RegularSizedSpeedrun.ResetAnchors()
      RegularSizedSpeedrun.OnPlayerActivated()
      RegularSizedSpeedrun:dbg(0, "Score and Time tracking set to: |cffffffON|r")
    end
    -- global trial events
    -- EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, RegularSizedSpeedrun.OnTrialStarted)
    -- EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, RegularSizedSpeedrun.OnTrialComplete)
    -- EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, RegularSizedSpeedrun.OnTrialFailed)
  end
  cV.isTracking = track
  RegularSizedSpeedrun.UpdateUIConfiguration()
end

function RegularSizedSpeedrun:Initialize()

  confirmedST = RegularSizedSpeedrun.StressTestedCheck()

  RegularSizedSpeedrun.savedSettings 	= ZO_SavedVars:NewCharacterIdSettings("RegularSizedSpeedrunVariables", 2, nil, RegularSizedSpeedrun.Default_Character)
  -- Keep tables and recorded data available accountwide
  RegularSizedSpeedrun.savedVariables = ZO_SavedVars:NewAccountWide("RegularSizedSpeedrunVariables", 2, nil, RegularSizedSpeedrun.Default_Account)
  sV 											= RegularSizedSpeedrun.savedVariables
  cV 											= RegularSizedSpeedrun.savedSettings
  RegularSizedSpeedrun.stepList 			= RegularSizedSpeedrun.Data.stepList

  RegularSizedSpeedrun.LoadVariables()
  -- keybinds
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_HIDEGROUP", "Toggle Hide Group")
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_UI", "Toggle UI")
  ZO_CreateStringId("SI_BINDING_NAME_SR_CANCEL_CAST", "Cancel Cast")
  -- UI
  RegularSizedSpeedrun.InitiateUI()
  -- Configure Data
  RegularSizedSpeedrun.LoadUtils()
  -- Setup Menu
  RegularSizedSpeedrun.CreateSettingsWindow()
  -- Check settings for tracking
  RegularSizedSpeedrun.Tracking(cV.isTracking)

  -- if writCreator then cV.writHidePets = WritCreater:GetSettings().petBegone end

  EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Activated", EVENT_PLAYER_ACTIVATED, RegularSizedSpeedrun.OnPlayerActivated)
  EM:UnregisterForEvent(RegularSizedSpeedrun.name .. "Loaded", EVENT_ADD_ON_LOADED)
end

function RegularSizedSpeedrun.OnAddOnLoaded(event, addonName)
  if addonName ~= RegularSizedSpeedrun.name then return end
  -- Parse defaults
  RegularSizedSpeedrun:GenerateDefaults()
  RegularSizedSpeedrun:Initialize()
end

EM:RegisterForEvent(RegularSizedSpeedrun.name .. "Loaded", EVENT_ADD_ON_LOADED, RegularSizedSpeedrun.OnAddOnLoaded)

--[[	Possible filter for "PlayerActivated" ?

-- In case addon is loaded while inside an active or completed trial
if RegularSizedSpeedrun.IsInTrialZone() and RegularSizedSpeedrun.raidID == zoneID then
		RegularSizedSpeedrun.LoadTrial()
end

function RegularSizedSpeedrun.LoadTrial()
		local zoneID = GetZoneId(GetUnitZoneIndex("player"))
		--for MA and VH to save timers for each character individualy.
		if zoneID == 677 or zoneID == 1227 then
				zoneID = zoneID .. GetUnitName("player")
		end

		RegularSizedSpeedrun.CreateRaidSegment(zoneID)

		if not IsRaidInProgress() then
				if GetRaidDuration() <= 0 then
						SpeedRun_Score_Label:SetText(RegularSizedSpeedrun.BestPossible(RegularSizedSpeedrun.raidID))
				elseif RegularSizedSpeedrun.isComplete == true then
						SpeedRun_Score_Label:SetText(sV.finalScore)
						SpeedRun_TotalTimer_Title:SetText(RegularSizedSpeedrun.FormatRaidTimer(sV.totalTime, true))
				end
		end
end

]]
