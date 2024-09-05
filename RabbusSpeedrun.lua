-----------------
---- Globals ----
-----------------
RabbusSpeedrun = RabbusSpeedrun or {}
local RabbusSpeedrun = RabbusSpeedrun
local EM = EVENT_MANAGER
local sV
local cV
RabbusSpeedrun.name               = "RabbusSpeedrun"
RabbusSpeedrun.version            = "0.1.9.6"
RabbusSpeedrun.activeProfile      = ""
RabbusSpeedrun.raidID             = 0
RabbusSpeedrun.zone               = 0
RabbusSpeedrun.raidList           = {}
RabbusSpeedrun.stepList           = {}
RabbusSpeedrun.customTimerSteps   = {}
RabbusSpeedrun.segments           = {}
RabbusSpeedrun.segmentTimer       = {}
RabbusSpeedrun.currentRaidTimer   = {}
RabbusSpeedrun.displayVitality    = ""
RabbusSpeedrun.lastBossName       = ""
RabbusSpeedrun.currentBossName    = ""
RabbusSpeedrun.isBossDead         = true
RabbusSpeedrun.Step               = 1
RabbusSpeedrun.arenaRound         = 1
RabbusSpeedrun.timeStarted        = nil
RabbusSpeedrun.totalScore         = 0
-- RabbusSpeedrun.slain							= {}
RabbusSpeedrun.inCombat           = false
RabbusSpeedrun.fightBegin         = 0
RabbusSpeedrun.isNormal           = false
RabbusSpeedrun.isComplete         = false
RabbusSpeedrun.trialState         = -1 -- not in trial: -1, in trial: 0 = not started, 1 = active, 2 = complete.
RabbusSpeedrun.isUIDrawn          = false
RabbusSpeedrun.isScoreSet         = false
RabbusSpeedrun.inMenu             = false
RabbusSpeedrun.currentTrialMenu   = nil
RabbusSpeedrun.profileToImportTo  = ""
RabbusSpeedrun.profileNames       = {}
RabbusSpeedrun.foodUnlocked       = false
local crMindblast           = 104515
local crAmulet              = 106023
local confirmedST           = false
-------------------
---- Functions ----
-------------------
function RabbusSpeedrun.GetSavedTimer(raidID, step)
  local cStep = RabbusSpeedrun.GetCustomTimerStep(raidID, step)
  if cStep and cStep ~= "" then
    cStep = tonumber(cStep)
    return cStep * 1000
  end

  local tStep = RabbusSpeedrun.GetSavedTimerStep(raidID, step)
  if tStep then return tStep end

  -- return 0
end

function RabbusSpeedrun.FormatRaidTimer(timer, ms)
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

function RabbusSpeedrun.FormatTimerForChatUpdate(timer)
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

function RabbusSpeedrun.FormatRaidScore(score)
  score = tostring(score)
  local fScore = string.sub(score,string.len(score)-2,string.len(score))
  local dScore = string.gsub(score,fScore,"")
  local string = dScore .. "'" .. fScore
  return string
end

-- Trial Score = (Base Score + Vitality x 1000) x (1 + (Par time - Your time(sec)) /10000)
function RabbusSpeedrun.GetScore(timer, vitality, raidID)
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
    if RabbusSpeedrun.addsOnCR == false then return (85750 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    else return (88000 + (1000 * vitality)) * (1 + (1200 - timer) / 10000) end
    --BRP
  elseif raidID == 1082 then return (75000  + (1000 * vitality)) * (1 + (2400 - timer) / 10000)
    --MA
  elseif raidID == 677  then return (426000 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    --DSA
  elseif raidID == 635  then return (20000  + (1000 * vitality)) * (1 + (3600 - timer) / 10000)
    --SS
  elseif raidID == 1121 then
    if RabbusSpeedrun.hmOnSS == 1 then return (87250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RabbusSpeedrun.hmOnSS == 2 then return (127250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RabbusSpeedrun.hmOnSS == 3 then return (167250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif RabbusSpeedrun.hmOnSS == 4 then return (207250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000) end
    --KA
  elseif raidID == 1196 then return (205950 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    --VH
  elseif raidID == 1227 then return (205450 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    -- RG
  elseif raidID == 1263 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    -- SE TODO
  elseif raidID == 1427 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    -- LC TODO
  elseif raidID == 1478 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)

  else return 0 end
end

function RabbusSpeedrun.UpdateWaypointNew(raidDuration)
  local raid = RabbusSpeedrun.raidList[RabbusSpeedrun.raidID]
  local waypoint = RabbusSpeedrun.Step

  if raid then

    if not RabbusSpeedrun.Data.stepList[raid.id][waypoint] or raidDuration < 1 then return end

    RabbusSpeedrun.currentRaidTimer[waypoint] = math.floor(raidDuration)
    sV.currentRaidTimer[waypoint] = RabbusSpeedrun.currentRaidTimer[waypoint]
    RabbusSpeedrun.UpdateWindowPanel(waypoint, RabbusSpeedrun.raidID)

    local timerWaypoint = 0
    if RabbusSpeedrun.currentRaidTimer[waypoint - 1] then
      timerWaypoint = RabbusSpeedrun.currentRaidTimer[waypoint] - RabbusSpeedrun.currentRaidTimer[waypoint - 1]
    else
      timerWaypoint = RabbusSpeedrun.currentRaidTimer[waypoint]
    end

    if (raid.timerSteps[waypoint] == nil or raid.timerSteps[waypoint] <= 0 or raid.timerSteps[waypoint] > timerWaypoint) then
      raid.timerSteps[waypoint] = timerWaypoint
      RabbusSpeedrun.SaveTimerStep(raid.id, waypoint, timerWaypoint)
    end

    if RabbusSpeedrun.raidID == 1082 then -- BRP
      RabbusSpeedrun:dbg(2, "Stage: <<1>>, Round: <<2>>, Step: <<3>>.", RabbusSpeedrun.GetBRPStage(), RabbusSpeedrun.arenaRound, RabbusSpeedrun.GetBRPStep())
    end

    RabbusSpeedrun.Step = RabbusSpeedrun.Step + 1
    sV.Step = RabbusSpeedrun.Step

    if (sV.printStepUpdate) then
      RabbusSpeedrun:dbg(0, '[|ce6b800<<1>>|r] |c00ff00Step <<2>>|r at |cffffff<<3>>|r.', GetUnitZone('player'), waypoint, RabbusSpeedrun.FormatTimerForChatUpdate(GetRaidDuration() / 1000))
    end
  end
end

RabbusSpeedrun.ScoreUpdate = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  RabbusSpeedrun.totalScore = totalScore
  sV.totalScore       = RabbusSpeedrun.totalScore
  local scoreTimer    = GetRaidDuration()
  local sT            = RabbusSpeedrun.FormatRaidTimer(scoreTimer, true)

  for k, v in pairs(RabbusSpeedrun.scores) do

    if RabbusSpeedrun.scores[k] == scoreUpdateReason or RabbusSpeedrun.scores[k].id == scoreUpdateReason then
      RabbusSpeedrun.scores[k].times = RabbusSpeedrun.scores[k].times + 1
      RabbusSpeedrun.scores[k].total = RabbusSpeedrun.scores[k].total + scoreAmount
      sV.scores[k].times       = RabbusSpeedrun.scores[k].times
      sV.scores[k].total       = RabbusSpeedrun.scores[k].total

      if scoreUpdateReason ~= 9 then
        RabbusSpeedrun:dbg(3, '[|cffffff<<4>>|r] +|cffffff<<2>>|r (|cffffff<<1>>|r) - Total: |cffffff<<3>>|r - |cffffff<<5>>|r.', RabbusSpeedrun.scores[k].name, scoreAmount, totalScore, sT, GetMapName())
      end
    end
  end

  if RabbusSpeedrun.raidID == 1227 then
    RabbusSpeedrun.UpdateAdds()

  elseif RabbusSpeedrun.raidID == 636 and RabbusSpeedrun.Step <= 4 then
    local b = RabbusSpeedrun.scores[5].times
    if ((RabbusSpeedrun.Step == 2) and (b == 1)) or ((RabbusSpeedrun.Step == 4) and (b == 3)) then
      RabbusSpeedrun.lastBossName 		= RabbusSpeedrun.currentBossName
      sV.lastBossName 					= RabbusSpeedrun.lastBossName
      RabbusSpeedrun.currentBossName  = ""
      sV.currentBossName 				= RabbusSpeedrun.currentBossName
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
      EM:RegisterForUpdate(RabbusSpeedrun.name .. "HelRaCitadel", 1000, RabbusSpeedrun.MainHRC)
    end
  end
  RabbusSpeedrun.UpdateCurrentScore()
end

function RabbusSpeedrun.UpdateAdds()
  if not GetZoneId(GetUnitZoneIndex("player")) == 1227 then return end

  for k, v in pairs(RabbusSpeedrun.scores) do
    local score = RabbusSpeedrun.scores[k]

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
function RabbusSpeedrun.GetBRPStage()
  local x, y = GetMapPlayerPosition('player');
  if (x > 0.54 and x < 0.64 and y > 0.79 and y < 0.89) then return 1
  elseif (x > 0.3  and x < 0.4  and y > 0.69 and y < 0.8 ) then return 2
  elseif (x > 0.41 and x < 0.52 and y > 0.43 and y < 0.53) then return 3
  elseif (x > 0.63 and x < 0.73 and y > 0.22 and y < 0.32) then return 4
  elseif (x > 0.4  and x < 0.5  and y > 0.08 and y < 0.18) then return 5
  else return 0 end
end

function RabbusSpeedrun.GetBRPStep()
  local step = ((RabbusSpeedrun.GetBRPStage() * 5) - 5) + RabbusSpeedrun.arenaRound
  return step
end

function RabbusSpeedrun.Announcement(_, title, _)
  if title == 'Final Round' or title == 'Letzte Runde' or title == 'Dernière manche' or title == 'Последний раунд' or title == '最終ラウンド' then
    RabbusSpeedrun.arenaRound = 5
    sV.arenaRound 			= RabbusSpeedrun.arenaRound
  else
    local round = string.match(title, '^.+%s(%d)$')
    if round then
      RabbusSpeedrun.arenaRound = tonumber(round)
      sV.arenaRound 			= RabbusSpeedrun.arenaRound
    end
  end
end

function RabbusSpeedrun.PortalSpawnBRP(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

  if result == ACTION_RESULT_EFFECT_GAINED then
    local t = GetGameTimeMilliseconds()
    if t - lastPortal > 2000 then brpWave = brpWave + 1 end
    lastPortal = t
  end
end

RabbusSpeedrun.MainArena = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  if (RabbusSpeedrun.raidID == 677) then --MA
    if RabbusSpeedrun.Step <= 8 and scoreUpdateReason == 17 then
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_SOLO_ARENA_COMPLETE) then
      RabbusSpeedrun.isBossDead = true
      sV.isBossDead       = RabbusSpeedrun.isBossDead
    end

  elseif RabbusSpeedrun.raidID == 1082 then --BRP
    if (RabbusSpeedrun.Step <= 24 and (scoreUpdateReason >= 13 and scoreUpdateReason <= 16) or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE) then
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
      RabbusSpeedrun.isBossDead = true
      sV.isBossDead       = RabbusSpeedrun.isBossDead
    end

  elseif RabbusSpeedrun.raidID == 635 then --DSA
    if (scoreUpdateReason == RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM) then
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
      RabbusSpeedrun.isBossDead = true
      sV.isBossDead       = RabbusSpeedrun.isBossDead
    end
  end
end

local lastPrint = ""
local sideBoss  = ""
function RabbusSpeedrun.MainVH()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then

      --zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = GetUnitName("boss" .. i)
      RabbusSpeedrun.currentBossName = string.lower(boss)

      if lastPrint ~= RabbusSpeedrun.currentBossName then
        lastPrint = RabbusSpeedrun.currentBossName
        RabbusSpeedrun:dbg(2, "<<1>> Detected!", boss)
      end

      -- local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if RabbusSpeedrun.Step <= 6 then

        if ((RabbusSpeedrun.currentBossName == RabbusSpeedrun.lastBossName) or not IsUnitInCombat("player")) then return end

        if (string.find("leptfire", RabbusSpeedrun.currentBossName) or string.find("xobutar", RabbusSpeedrun.currentBossName) or string.find("mynar", RabbusSpeedrun.currentBossName)) then
          if RabbusSpeedrun.isSideBoss == false then
            RabbusSpeedrun.isSideBoss = true
            sideBoss            = boss
          end
        else
          RabbusSpeedrun.isSideBoss = false
          sideBoss            = ""
        end

        if (RabbusSpeedrun.isSideBoss == true and IsUnitInCombat("player")) then
          EM:UnregisterForUpdate(RabbusSpeedrun.name .. "SideBoss")
          EM:RegisterForUpdate(RabbusSpeedrun.name .. "SideBoss", 100, RabbusSpeedrun.SideBoss)
          return
        end

        if IsUnitInCombat("player") then
          if RabbusSpeedrun.lastBossName ~= RabbusSpeedrun.currentBossName then
            EM:RegisterForEvent(RabbusSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RabbusSpeedrun.arenaBoss)
          else
            return
          end
        end
      end
    end
  end
end

function RabbusSpeedrun.SideBoss()
  local current, max, effmax = GetUnitPower("boss1", POWERTYPE_HEALTH)

  if current <= 0 then
    EM:UnregisterForUpdate(RabbusSpeedrun.name .. "SideBoss")
    RabbusSpeedrun:dbg(1, "|cdf4242<<1>>|r killed at |cffff00<<2>>|r", sideBoss, RabbusSpeedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    RabbusSpeedrun.lastBossName = RabbusSpeedrun.currentBossName
    sV.lastBossName       = RabbusSpeedrun.lastBossName
  end
end

RabbusSpeedrun.arenaBoss = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  if scoreUpdateReason == 13 or scoreUpdateReason == 14 or scoreUpdateReason == 15 or scoreUpdateReason == 16 or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE then

    RabbusSpeedrun.lastBossName     = RabbusSpeedrun.currentBossName
    sV.lastBossName           = RabbusSpeedrun.lastBossName
    RabbusSpeedrun.currentBossName  = ""
    RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
    EM:UnregisterForEvent(RabbusSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)

    zo_callLater(function()
      EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VHBoss")
      EM:RegisterForUpdate(RabbusSpeedrun.name .. "VHBoss", 1000, RabbusSpeedrun.MainVH)
    end, 2000)
  end
end
----------------
---- Trials ----
----------------
-- function RabbusSpeedrun.MiniTrial()

local zmaja   = {}
local isZmaja = false

function RabbusSpeedrun.OnCombatEnd()
  if IsUnitInCombat("player") then return end
  zo_callLater(function()
    if (not IsUnitInCombat("player") and not RabbusSpeedrun.isComplete) then
      RabbusSpeedrun.inCombat         = false
      RabbusSpeedrun.currentRaidTimer = {}
      sV.currentRaidTimer       = RabbusSpeedrun.currentRaidTimer
      RabbusSpeedrun.isBossDead       = true
      sV.isBossDead             = RabbusSpeedrun.isBossDead
      RabbusSpeedrun.Step             = 1
      sV.Step                   = RabbusSpeedrun.Step
      if RabbusSpeedrun.raidID == 1051 then
        zmaja   = {}
        isZmaja = false
        EM:UnregisterForUpdate(RabbusSpeedrun.name .. "CombatEnded")
        EM:UnregisterForUpdate(RabbusSpeedrun.name .. "MiniTrial")
        EM:UnregisterForEvent( RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end, 3000)
end

function RabbusSpeedrun.CombatCR()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local current, max, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      if (max > 64000000 and IsUnitAttackable("boss" .. i)) then
        if IsUnitInCombat("player") then
          -- zmaja name: ["Z'Maja"], ["З'Маджа"], ["ズマジャ"]
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          RabbusSpeedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = RabbusSpeedrun.currentBossName
          local z = {
            index     = i,
            name      = RabbusSpeedrun.currentBossName,
            hpMax	    = max,
            hpCurrent = current,
          }
          zmaja   = z
          isZmaja = true
          if RabbusSpeedrun.Step == 1 then
            RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
            EM:UnregisterForUpdate(RabbusSpeedrun.name .. "MiniTrial")
            EM:RegisterForUpdate(	RabbusSpeedrun.name .. "MiniTrial", 333, RabbusSpeedrun.MainCloudrest)
          end
          RabbusSpeedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(RabbusSpeedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(RabbusSpeedrun.name .. "CombatEnded", 4000, RabbusSpeedrun.OnCombatEnd)
          end, 1000)
        end

      else
        isZmaja = false
      end
    end
  end
end

function RabbusSpeedrun.ZmajaShade()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = string.lower(GetUnitName("boss" .. i))
      if (boss ~= zmaja.name and RabbusSpeedrun.Step == 5) then
        -- if (boss ~= RabbusSpeedrun.currentBossName and RabbusSpeedrun.Step == 5) then
        RabbusSpeedrun.currentBossName  = boss
        sV.currentBossName        = RabbusSpeedrun.currentBossName
        RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForEvent(RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end
end

-- IsUnitActivelyEngaged(string unitTag)
-- Returns: boolean isActivelyEngaged

-- IsUnitAttackable(string unitTag)
-- Returns: boolean attackable

function RabbusSpeedrun.MainCloudrest()
  if isZmaja then
    local current, max, effectiveMax = GetUnitPower("boss" .. zmaja.index, POWERTYPE_HEALTH)
    local percentageHP = current / max

    -- check for highest possible step in case 1 or 2 steps were passed while player was in portal
    if (percentageHP <= 0.06) then
      -- if RabbusSpeedrun.Step < 5 then
      RabbusSpeedrun.Step = 4
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
      EM:UnregisterForEvent(RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      EM:RegisterForEvent(RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, RabbusSpeedrun.ZmajaShade)
      EM:UnregisterForUpdate(RabbusSpeedrun.name .. "MiniTrial")
      return
      -- end
    elseif (percentageHP <= 0.25 and percentageHP >= 0.06) then
      if RabbusSpeedrun.Step < 4 then
        RabbusSpeedrun.Step = 3
        RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
        -- EM:UnregisterForEvent(RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
        -- EM:RegisterForEvent(RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, RabbusSpeedrun.ZmajaShade)
        return
      end

    elseif (percentageHP <= 0.5 and percentageHP > 0.25) then
      if RabbusSpeedrun.Step < 3 then
        RabbusSpeedrun.Step = 2
        RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end

    elseif (percentageHP <= 0.75 and percentageHP > 0.5) then
      if RabbusSpeedrun.Step < 2 then
        RabbusSpeedrun.Step = 1
        RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end
    end

  else
    EM:UnregisterForUpdate(RabbusSpeedrun.name .. "MiniTrial")
  end
end

function RabbusSpeedrun.CombatAS()
  if IsUnitInCombat("player") then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if maxTargetHP > 99000000 then
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          RabbusSpeedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = RabbusSpeedrun.currentBossName
          RabbusSpeedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(RabbusSpeedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(RabbusSpeedrun.name .. "CombatEnded", 4000, RabbusSpeedrun.OnCombatEnd)
          end, 1000)
        end
      end
    end
  end
end

function RabbusSpeedrun.MainAsylum()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      local percentageHP = currentTargetHP / maxTargetHP
      --start fight with boss
      if RabbusSpeedrun.inCombat and RabbusSpeedrun.isBossDead == true then
        --Olms got more than 99Million HP
        if (RabbusSpeedrun.Step == 1    and maxTargetHP   >= 99000000) then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.9  and RabbusSpeedrun.Step == 2       ) then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.75 and RabbusSpeedrun.Step == 3       ) then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.5  and RabbusSpeedrun.Step == 4       ) then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.25 and RabbusSpeedrun.Step == 5       ) then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) end
      -- else
      --   if (currentTargetHP > 0 and RabbusSpeedrun.Step <= 6) then
      --     RabbusSpeedrun.currentRaidTimer = {}
      --     sV.currentRaidTimer = RabbusSpeedrun.currentRaidTimer
      --     RabbusSpeedrun.Step = 1
      --     sV.Step = RabbusSpeedrun.Step
      --   elseif currentTargetHP <= 0 then
      --     -- not in HM
      --     RabbusSpeedrun.isBossDead = false
      --     sV.isBossDead = RabbusSpeedrun.isBossDead
        -- end
      end
    end
  end
end

function RabbusSpeedrun.MainHRC()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      RabbusSpeedrun.currentBossName   = string.lower(GetUnitName("boss" .. i))
      if (RabbusSpeedrun.lastBossName == RabbusSpeedrun.currentBossName) then return end
      if IsUnitInCombat("player") then
        RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForUpdate(RabbusSpeedrun.name .. "HelRaCitadel")
      end
    else return end
  end
end

function RabbusSpeedrun.LastArchive()
  if IsUnitInCombat("player") and RabbusSpeedrun.Step == 6 then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if currentTargetHP > 0 then
          RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
          --Unregister for update then register again on update for UI panel
          EM:UnregisterForUpdate(RabbusSpeedrun.name .. "LastAA")
        end
      end
    end
  end
end

function RabbusSpeedrun.BossFightBegin()
  for i = 1, MAX_BOSSES do
    local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
    if IsUnitInCombat("player") and (current < max) then
      EM:UnregisterForUpdate(RabbusSpeedrun.name .. "BossFight")
      RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())
      -- RabbusSpeedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), RabbusSpeedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    end
  end
end

function RabbusSpeedrun.MainBoss()
  if RabbusSpeedrun.Step == 6 and RabbusSpeedrun.raidID == 638 then
    --to trigger the mage
    EM:RegisterForUpdate(RabbusSpeedrun.name .. "LastAA", 333, RabbusSpeedrun.LastArchive)
  end

  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))

      local name = GetUnitName("boss" .. i)

      if string.lower(name) ~= RabbusSpeedrun.currentBossName then
        if RabbusSpeedrun.fightBegin == 0 and IsUnitInCombat("boss" .. i) then

          RabbusSpeedrun.fightBegin = GetRaidDuration()
          RabbusSpeedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), RabbusSpeedrun.FormatTimerForChatUpdate(RabbusSpeedrun.fightBegin / 1000))
        else
          RabbusSpeedrun.fightBegin = 0
        end
      end

      RabbusSpeedrun.currentBossName  = string.lower(name)
      sV.currentBossName 				= RabbusSpeedrun.currentBossName


      if RabbusSpeedrun.raidID == 1263 then
        if (string.find(RabbusSpeedrun.currentBossName, "snakes") or string.find(RabbusSpeedrun.currentBossName, "titan")) then return end
      end

      if RabbusSpeedrun.currentBossName == RabbusSpeedrun.lastBossName then return end

      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if RabbusSpeedrun.isBossDead == true and currentTargetHP > 0 then
        -- boss encounter begins
        RabbusSpeedrun.isBossDead = false
        sV.isBossDead 			= RabbusSpeedrun.isBossDead

        -- for Nahviintaas (to set time when in combat with the adds since they are relevant to the boss fight)
        if RabbusSpeedrun.raidID == 1121 and RabbusSpeedrun.Step == 5 then
          if IsUnitInCombat("player") then RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration()) return end
        end

        EM:UnregisterForUpdate(RabbusSpeedrun.name .. "BossFightBegin")
        EM:RegisterForUpdate(RabbusSpeedrun.name .. "BossFight", 50, RabbusSpeedrun.BossFightBegin)
      end
    end
  end
end

local function BossMainZoneCheck(zone)
  local mbZones = { [638] = true, [639] = true, [725] = true, [975] = true, [1121] = true, [1196] = true, [1263] = true, [1427] = true, [1478] = true }
  if mbZones[zone] then return true end
  return false
end

RabbusSpeedrun.BossDead = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  local timer

  -- if scoreUpdateReason == RAID_POINT_REASON_KILL_MINIBOSS then
  --   timer = (GetRaidDuration() - RabbusSpeedrun.fightBegin) / 1000
  --   RabbusSpeedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", RabbusSpeedrun.currentBossName, RabbusSpeedrun.FormatTimerForChatUpdate(timer))
  --   return
  -- end

  if scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS then

    timer = (GetRaidDuration() - RabbusSpeedrun.fightBegin) / 1000

    -- RabbusSpeedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", RabbusSpeedrun.currentBossName, RabbusSpeedrun.FormatTimerForChatUpdate(timer))

    RabbusSpeedrun.lastBossName     = RabbusSpeedrun.currentBossName
    sV.lastBossName           = RabbusSpeedrun.lastBossName
    RabbusSpeedrun.currentBossName  = ""
    sV.currentBossName        = RabbusSpeedrun.currentBossName
    RabbusSpeedrun.isBossDead       = true
    sV.isBossDead             = RabbusSpeedrun.isBossDead
    RabbusSpeedrun.UpdateWaypointNew(GetRaidDuration())

    -- if BossMainZoneCheck(GetZoneId(GetUnitZoneIndex("player"))) then
    -- 		EM:RegisterForEvent(RabbusSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, RabbusSpeedrun.MainBoss)
    -- 		EM:RegisterForEvent(RabbusSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, RabbusSpeedrun.MainBoss)
    -- end
  end
end

function RabbusSpeedrun.OnTrialStarted()
  RabbusSpeedrun.scores 			= RabbusSpeedrun.GetDefaultScores()
  sV.scores 						= RabbusSpeedrun.scores
  RabbusSpeedrun.RegisterTrialsEvents()
  RabbusSpeedrun.UpdateCurrentVitality()
  RabbusSpeedrun.trialState 	= 1
  RabbusSpeedrun.timeStarted 	= GetGameTimeSeconds()
  sV.timeStarted 				= RabbusSpeedrun.timeStarted
  RabbusSpeedrun:dbg(1, "Trial: |ce6b800<<1>>|r Started!", GetUnitZone('player'))
end

RabbusSpeedrun.OnTrialComplete = function(eventCode, trialName, score, totalTime)
  -- for mini-trials and HRC
  if RabbusSpeedrun.raidID == 636 or RabbusSpeedrun.raidID == 1000 or RabbusSpeedrun.raidID == 1082 or RabbusSpeedrun.raidID == 677 or RabbusSpeedrun.raidID == 1227 then
    RabbusSpeedrun.UpdateWaypointNew(totalTime)
  end
  -- for CR
  if RabbusSpeedrun.raidID == 1051 then
    if RabbusSpeedrun.Step ~= 6 then
      RabbusSpeedrun.Step = 6
      sV.Step = RabbusSpeedrun.Step
    end
    RabbusSpeedrun.UpdateWaypointNew(totalTime)
  end
  -- save data before resetting in case we need it
  sV.finalScore = score
  sV.totalTime  = totalTime

  if (GetDisplayName() == "@nogetrandom") then RabbusSpeedrun.UpdateScoreFactors(RabbusSpeedrun.activeProfile, RabbusSpeedrun.raidID) end
  RabbusSpeedrun.SetLastTrial()

  local scoreString = RabbusSpeedrun.FormatRaidScore(sV.finalScore)
  SpeedRun_Score_Label:SetText(scoreString)
  SpeedRun_TotalTimer_Title:SetText(RabbusSpeedrun.FormatRaidTimer(sV.totalTime, true))
  RabbusSpeedrun.trialState = 2
  RabbusSpeedrun.isComplete = true

  RabbusSpeedrun.UnregisterTrialsEvents()
  if (sV.printStepUpdate) then
    RabbusSpeedrun:dbg(1, "|ce6b800<<1>>|r |c00ff00Complete|r!\n[Time: |cffffff<<2>>|r]  [Score: |cffffff<<3>>|r] <<4>>", GetUnitZone('player'), RabbusSpeedrun.FormatTimerForChatUpdate(totalTime / 1000), scoreString, RabbusSpeedrun.FormatVitality(true, GetRaidReviveCountersRemaining(), GetCurrentRaidStartingReviveCounters()))
  end
end

function RabbusSpeedrun.OnTrialFailed(eventCode, trialName, score)
    -- RabbusSpeedrun.Reset()
    -- RabbusSpeedrun.ResetUI()
    RabbusSpeedrun.UnregisterTrialsEvents()
		RabbusSpeedrun:dbg(1, '|ce6b800<<1>>|r |cff0000Failed|r.', trialName)
end
-----------------------
---- Base & Events ----
-----------------------
function RabbusSpeedrun.Reset()
  RabbusSpeedrun.isComplete 			= false
  sV.isComplete							= RabbusSpeedrun.isComplete
  RabbusSpeedrun.scores 					= {}
  sV.scores 								= {}
  RabbusSpeedrun.scores 					= RabbusSpeedrun.GetDefaultScores()
  sV.scores 								= RabbusSpeedrun.scores
  RabbusSpeedrun.totalScore				= 0
  sV.totalScore							= RabbusSpeedrun.totalScore
  RabbusSpeedrun.displayVitality 	= ""
  RabbusSpeedrun.currentRaidTimer = {}
  sV.currentRaidTimer 			= RabbusSpeedrun.currentRaidTimer
  RabbusSpeedrun.Step 						= 1
  sV.Step 									= RabbusSpeedrun.Step
  RabbusSpeedrun.arenaRound				= 0
  sV.arenaRound							= RabbusSpeedrun.arenaRound
  RabbusSpeedrun.isBossDead 			= true
  sV.isBossDead 						= RabbusSpeedrun.isBossDead
  RabbusSpeedrun.lastBossName 		= ""
  sV.lastBossName 					= RabbusSpeedrun.lastBossName
  RabbusSpeedrun.currentBossName 	= ""
  sV.currentBossName 				= RabbusSpeedrun.currentBossName
  RabbusSpeedrun.isUIDrawn 				= false
  RabbusSpeedrun.fightBegin       = 0
  RabbusSpeedrun:dbg(2, "Resetting Variables.")
end

function RabbusSpeedrun.UnregisterTrialsEvents()
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE)
  EM:UnregisterForEvent( RabbusSpeedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT)
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "Update")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "MiniTrial")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "LastAA")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VHBoss")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "VHSideBoss")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "HelRaCitadel")
  EM:UnregisterForUpdate(RabbusSpeedrun.name .. "BossFight")
end

function RabbusSpeedrun.RegisterTrialsEvents()
  --AS
  if RabbusSpeedrun.raidID == 1000 then
    EM:RegisterForEvent( 	RabbusSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, RabbusSpeedrun.CombatAS)
    EM:RegisterForUpdate( RabbusSpeedrun.name .. "MiniTrial", 333, RabbusSpeedrun.MainAsylum)

  --CR
  elseif RabbusSpeedrun.raidID == 1051 then
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, RabbusSpeedrun.CombatCR)
    EM:RegisterForUpdate(	RabbusSpeedrun.name .. "MiniTrial", 333, RabbusSpeedrun.MainCloudrest)
    -- EM:RegisterForEvent(	RabbusSpeedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, RabbusSpeedrun.CloudrestExecute)
    -- EM:AddFilterForEvent(	RabbusSpeedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023)

  --BRP
  elseif RabbusSpeedrun.raidID == 1082 then
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RabbusSpeedrun.MainArena)
    EM:RegisterForEvent(  RabbusSpeedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT, RabbusSpeedrun.Announcement)

  -- MA, DSA
  elseif RabbusSpeedrun.raidID == 677 or RabbusSpeedrun.raidID == 635 then
    EM:RegisterForEvent( 	RabbusSpeedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, RabbusSpeedrun.MainArena)

  --VH
  elseif GetZoneId(GetUnitZoneIndex("player")) == 1227 then
    EM:RegisterForUpdate(	RabbusSpeedrun.name .. "VHBoss", 1000, RabbusSpeedrun.MainVH)

  -- HRC
  elseif RabbusSpeedrun.raidID == 636 then
    EM:RegisterForUpdate(	RabbusSpeedrun.name .. "HelRaCitadel", 1000, RabbusSpeedrun.MainHRC)

  -- other raids
  else
    EM:RegisterForEvent( RabbusSpeedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, RabbusSpeedrun.MainBoss)
    EM:RegisterForEvent( RabbusSpeedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, RabbusSpeedrun.MainBoss)
    EM:RegisterForEvent( RabbusSpeedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE, RabbusSpeedrun.BossDead)
  end

  EM:RegisterForUpdate(	RabbusSpeedrun.name .. "Update", 900, RabbusSpeedrun.UpdateWindowPanel)
  EM:RegisterForEvent( 	RabbusSpeedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE, RabbusSpeedrun.UpdateCurrentVitality)
  EM:RegisterForEvent( 	RabbusSpeedrun.name .. "ScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE, RabbusSpeedrun.ScoreUpdate)
  EM:RegisterForEvent( 	RabbusSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, RabbusSpeedrun.OnTrialStarted)
  EM:RegisterForEvent( 	RabbusSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, RabbusSpeedrun.OnTrialComplete)
  EM:RegisterForEvent( 	RabbusSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, RabbusSpeedrun.OnTrialFailed)
end

function RabbusSpeedrun.OnPlayerActivated( eventCode, initial )
  RabbusSpeedrun.IsActivated(initial)

  if cV.isTracking == false then return end

  if RabbusSpeedrun.IsInTrialZone() then
    local same = RabbusSpeedrun.CheckTrial()

    if not RabbusSpeedrun.isUIDrawn then
      RabbusSpeedrun.CreateRaidSegment(RabbusSpeedrun.raidID, same)
      SpeedRun_TotalTimer_Title:SetText(RabbusSpeedrun.FormatRaidTimer(GetRaidDuration(), true))
    end

    RabbusSpeedrun.UpdateCurrentScore()
    RabbusSpeedrun.UpdateCurrentVitality()
    RabbusSpeedrun.RegisterTrialsEvents()
    -- RabbusSpeedrun.SetUIHidden(not sV.showUI)
  else
    -- Player is not in a trial. Disable tracking.
    RabbusSpeedrun.trialState = -1
    sV.trialState       = RabbusSpeedrun.trialState
    RabbusSpeedrun.scores     = RabbusSpeedrun.GetDefaultScores()
    sV.scores           = RabbusSpeedrun.scores
    -- RabbusSpeedrun.SetUIHidden(true)
    RabbusSpeedrun.UnregisterTrialsEvents()
  end
  RabbusSpeedrun.UpdateVisibility()
  RabbusSpeedrun.ToggleFoodReminder()
end

-- IsPlayerInRaidStagingArea()
-- IsPlayerInReviveCounterRaid()
-- HasRaidEnded()

-- GetUnitCaption(string unitTag)

function RabbusSpeedrun.IsInTrialZone()
  RabbusSpeedrun.zone = GetZoneId(GetUnitZoneIndex("player"))
  for k, v in pairs(RabbusSpeedrun.Data.raidList) do
    if RabbusSpeedrun.Data.raidList[k].id == RabbusSpeedrun.zone then

      -- if not IsUnitUsingVeteranDifficulty("player") then
      -- if ZO_GetEffectiveDungeonDifficulty() < 2 then
      if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN then
        if RabbusSpeedrun.isNormal == false then
          RabbusSpeedrun.isNormal = true
          RabbusSpeedrun:dbg(2, "Difficulty: Normal. Hiding UI")
        end
        return false
      end
      RabbusSpeedrun.isNormal = false
      return true
    end
  end
  return false
end

function RabbusSpeedrun.CheckTrial()
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
    if RabbusSpeedrun.zone ~= RabbusSpeedrun.raidID then return false end
    if (state ~= 1) then return false end

    if RabbusSpeedrun.Step == 1 then
      RabbusSpeedrun.isBossDead   = true
      sV.isBossDead         = RabbusSpeedrun.isBossDead
      RabbusSpeedrun.lastBossName = ""
      sV.lastBossName       = RabbusSpeedrun.lastBossName
    end

    -- Check if trial was started at the same time as players currently active trial.
    -- Not sure yet if we need a +/- 10 sec buffer for this. probably not...
    local time = GetGameTimeSeconds() - RabbusSpeedrun.timeStarted
    local duration = GetRaidDuration() / 1000
    if ((time <= (duration + 10)) and (time >= (duration - 10))) then return true end
    return false
  end

  -- In trial but it's complete.
  -- Setup UI in case it was reloaded, or leave as is until next reset.
  if CompletedTrialCheck() then
    if not RabbusSpeedrun.isUIDrawn then RabbusSpeedrun.CreateRaidSegment(RabbusSpeedrun.zone) end
    SpeedRun_Score_Label:SetText(RabbusSpeedrun.FormatRaidScore(sV.finalScore))
    SpeedRun_TotalTimer_Title:SetText(RabbusSpeedrun.FormatRaidTimer(sV.totalTime, true))
    RabbusSpeedrun.isComplete = true
    RabbusSpeedrun.trialState = 2
    RabbusSpeedrun:dbg(3, "Trial is Complete. Returning.")
    return
  end

  -- Trial Variables are no longer reset when leaving an unfinished trial.
  -- Check if player is returning to their active unfinished trial else reset.
  if NewTrialCheck() then
    RabbusSpeedrun:dbg(3, "New Trial.")
    shouldReset = true
  else
    if IsActiveTrialOldTrial() then
      RabbusSpeedrun:dbg(3, "Same Trial.")
      isSame = true
    else
      RabbusSpeedrun:dbg(3, "Trial active (not same).")
      shouldReset = true
    end
  end

  if shouldReset == true then
    RabbusSpeedrun.Reset()
    RabbusSpeedrun.ResetUI()

    -- Set current game time as reference in case player will port out and re-enter.
    if IsRaidInProgress() then
      RabbusSpeedrun.timeStarted  = GetGameTimeSeconds() - (GetRaidDuration() / 1000)
      sV.timeStarted        = RabbusSpeedrun.timeStarted

      -- GetTimeStamp()
      -- Returns: id64 timestamp
      -- GetTimeString()
      -- Returns: string currentTimeString

    end
  end
  RabbusSpeedrun.raidID     = RabbusSpeedrun.zone
  sV.raidID           = RabbusSpeedrun.raidID
  RabbusSpeedrun.trialState = state
  sV.trialState       = RabbusSpeedrun.trialState
  return isSame
end

function RabbusSpeedrun.ToggleTracking()
  RabbusSpeedrun.Tracking(not cV.isTracking)
end

function RabbusSpeedrun.Tracking(track)
  if track ~= true then
    -- take no action if not already registered
    if cV.isTracking == false then return end
    -- shut down everything trial related
    EM:UnregisterForEvent(RabbusSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED)
    EM:UnregisterForEvent(RabbusSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
    EM:UnregisterForEvent(RabbusSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED)
    RabbusSpeedrun.UnregisterTrialsEvents()
    RabbusSpeedrun.SetUIHidden(true)
    -- RabbusSpeedrun.Reset()
    RabbusSpeedrun:dbg(0, "Score and Time tracking set to: |cffffffOFF|r")
  else
    -- only if tracking was previously off
    if cV.isTracking ~= track then
      RabbusSpeedrun.Reset()
      RabbusSpeedrun.ResetUI()
      RabbusSpeedrun.ResetAnchors()
      RabbusSpeedrun.OnPlayerActivated()
      RabbusSpeedrun:dbg(0, "Score and Time tracking set to: |cffffffON|r")
    end
    -- global trial events
    -- EM:RegisterForEvent(RabbusSpeedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, RabbusSpeedrun.OnTrialStarted)
    -- EM:RegisterForEvent(RabbusSpeedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, RabbusSpeedrun.OnTrialComplete)
    -- EM:RegisterForEvent(RabbusSpeedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, RabbusSpeedrun.OnTrialFailed)
  end
  cV.isTracking = track
  RabbusSpeedrun.UpdateUIConfiguration()
end

function RabbusSpeedrun:Initialize()

  confirmedST = RabbusSpeedrun.StressTestedCheck()

  RabbusSpeedrun.savedSettings 	= ZO_SavedVars:NewCharacterIdSettings("RabbusSpeedrunVariables", 2, nil, RabbusSpeedrun.Default_Character)
  -- Keep tables and recorded data available accountwide
  RabbusSpeedrun.savedVariables = ZO_SavedVars:NewAccountWide("RabbusSpeedrunVariables", 2, nil, RabbusSpeedrun.Default_Account)
  sV 											= RabbusSpeedrun.savedVariables
  cV 											= RabbusSpeedrun.savedSettings
  RabbusSpeedrun.stepList 			= RabbusSpeedrun.Data.stepList

  RabbusSpeedrun.LoadVariables()
  -- keybinds
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_HIDEGROUP", "Toggle Hide Group")
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_UI", "Toggle UI")
  ZO_CreateStringId("SI_BINDING_NAME_SR_CANCEL_CAST", "Cancel Cast")
  -- UI
  RabbusSpeedrun.InitiateUI()
  -- Configure Data
  RabbusSpeedrun.LoadUtils()
  -- Setup Menu
  RabbusSpeedrun.CreateSettingsWindow()
  -- Check settings for tracking
  RabbusSpeedrun.Tracking(cV.isTracking)

  -- if writCreator then cV.writHidePets = WritCreater:GetSettings().petBegone end

  EM:RegisterForEvent(RabbusSpeedrun.name .. "Activated", EVENT_PLAYER_ACTIVATED, RabbusSpeedrun.OnPlayerActivated)
  EM:UnregisterForEvent(RabbusSpeedrun.name .. "Loaded", EVENT_ADD_ON_LOADED)
end

function RabbusSpeedrun.OnAddOnLoaded(event, addonName)
  if addonName ~= RabbusSpeedrun.name then return end
  -- Parse defaults
  RabbusSpeedrun:GenerateDefaults()
  RabbusSpeedrun:Initialize()
end

EM:RegisterForEvent(RabbusSpeedrun.name .. "Loaded", EVENT_ADD_ON_LOADED, RabbusSpeedrun.OnAddOnLoaded)

--[[	Possible filter for "PlayerActivated" ?

-- In case addon is loaded while inside an active or completed trial
if RabbusSpeedrun.IsInTrialZone() and RabbusSpeedrun.raidID == zoneID then
		RabbusSpeedrun.LoadTrial()
end

function RabbusSpeedrun.LoadTrial()
		local zoneID = GetZoneId(GetUnitZoneIndex("player"))
		--for MA and VH to save timers for each character individualy.
		if zoneID == 677 or zoneID == 1227 then
				zoneID = zoneID .. GetUnitName("player")
		end

		RabbusSpeedrun.CreateRaidSegment(zoneID)

		if not IsRaidInProgress() then
				if GetRaidDuration() <= 0 then
						SpeedRun_Score_Label:SetText(RabbusSpeedrun.BestPossible(RabbusSpeedrun.raidID))
				elseif RabbusSpeedrun.isComplete == true then
						SpeedRun_Score_Label:SetText(sV.finalScore)
						SpeedRun_TotalTimer_Title:SetText(RabbusSpeedrun.FormatRaidTimer(sV.totalTime, true))
				end
		end
end

]]
