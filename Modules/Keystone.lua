--============================================================================--
--                          EskaTracker                                       --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker               --
--============================================================================--
Scorpio              "EskaTracker.Objectives.Keystone"                        ""
--============================================================================--
import                           "EKT"
--============================================================================--
_Enabled                      = false
--============================================================================--
GetPowerLevelDamageHealthMod  = C_ChallengeMode.GetPowerLevelDamageHealthMod
GetActiveKeystoneInfo         = C_ChallengeMode.GetActiveKeystoneInfo
GetAffixInfo                  = C_ChallengeMode.GetAffixInfo
GetMapInfo                    = C_ChallengeMode.GetMapUIInfo
GetActiveChallengeMapID       = C_ChallengeMode.GetActiveChallengeMapID
GetDeathCount                 = C_ChallengeMode.GetDeathCount
GetWorldElapsedTimers         = GetWorldElapsedTimers
GetWorldElapsedTime           = GetWorldElapsedTime
EJ_GetCurrentInstance         = EJ_GetCurrentInstance
EJ_GetInstanceInfo            = EJ_GetInstanceInfo
GetInfo                       = C_Scenario.GetInfo
GetStepInfo                   = C_Scenario.GetStepInfo
GetCriteriaInfo               = C_Scenario.GetCriteriaInfo
--============================================================================--
ENEMY_FORCES_FORMAT_OPTION    = "keystone-enemy-forces-format"
PERCENTAGE_FORMAT_OPTION      =  "keystone-percentage-format"
--============================================================================--
KEYSTONE_TIMER_STARTED        = false
--============================================================================--
enum "EnemyForcesFormat" {
  -- Displays only the percent -> 25%
  -- Example: 57%
  ONLY_PERCENT = 1,

  -- Displays current mob point -> 185
  -- Example: 152
  CURRENT_MOB_POINT = 2,

  -- Displays the current mob point and the mob point required
  -- Example: 152/268
  FULL_MOB_POINT_INFO = 3,

  -- Display the current mob point, the amount of mob point required and the
  -- current percent
  -- Example: 152/268 (57%)
  FULL_MOB_INFO_WITH_PERCENT = 4,
}
--============================================================================--
__ActivatingOnEvent__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START"
function ActivatingOn(self)
  return GetActiveKeystoneInfo() > 0
end
--============================================================================--
function OnLoad(self)
  Settings:Register(ENEMY_FORCES_FORMAT_OPTION, EnemyForcesFormat.ONLY_PERCENT, "keystone/updateAll")
  Settings:Register(PERCENTAGE_FORMAT_OPTION, 1, "keystone/updateAll")

  CallbackHandlers:Register("keystone/updateAll", CallbackHandler(UpdateObjectives))
end

function OnEnable(self)
  if not _Keystone then
    _Keystone = block "keystone"
  end

  UpdateObjectives()
  self:GetKeystoneInfo()

  if _EnablingEvent and _EnablingEvent == "PLAYER_ENTERING_WORLD" then
    _Keystone.isActive = true
    self:UpdateTimer()
  end
end

function OnDisable(self)
  if _Keystone then
    _Keystone.isActive = false
  end
end
--============================================================================--
__Async__()
__SystemEvent__()
function CHALLENGE_MODE_START()
  _Keystone.isActive = true
  _Keystone.timer = 0

  -- Represents the '10s' Blizzard countdown
  Delay(10)

  -- Start the timer
  _M:UpdateTimer()
end

local function GetPercentageString(current, total)
  local decimal = Settings:Get(PERCENTAGE_FORMAT_OPTION)

  if decimal == 0 then
    return string.format("%i%%", math.floor(current/total*100))
  elseif decimal == 1 then
    return string.format("%.1f%%", API:TruncateDecimal(current/total*100, 1))
  elseif decimal == 2 then
    return string.format("%.2f%%", API:TruncateDecimal(current/total*100, 2))
  end

  return string.format("%i", current/total*100)
end

__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_UPDATE" "SCENARIO_UPDATE"
function UpdateObjectives()
  local dungeonName, _, numObjectives = GetStepInfo()
  local completed = select(7, GetInfo())


  _Keystone.name = dungeonName
  _Keystone.numObjectives = numObjectives
  _Keystone.isCompleted = completed
  _Keystone:WakeUpTracker()

  for index = 1, numObjectives do
    local description, _, completed, c, totalQuantity, _, _, quantityString,
    _, _, _, _, isWeightProgress = GetCriteriaInfo(index)

    local objective = _Keystone:GetObjective(index)
    objective.isCompleted = completed
    objective.text = description

    if isWeightProgress then
      -- if there is weight progress, we can say this is 'Enemy Forces'
      local quantity = tonumber(strsub(quantityString, 1, -2))


      objective:ShowProgress()
      objective:SetMinMaxProgress(0, totalQuantity)
      objective:SetProgress(quantity)

      local enemyFormat = Settings:Get(ENEMY_FORCES_FORMAT_OPTION)
      if enemyFormat == EnemyForcesFormat.ONLY_PERCENT then
        objective:SetTextProgress(GetPercentageString(quantity, totalQuantity))
      elseif enemyFormat == EnemyForcesFormat.CURRENT_MOB_POINT then
        objective:SetTextProgress("%i", quantity)
      elseif enemyFormat == EnemyForcesFormat.FULL_MOB_POINT_INFO then
        objective:SetTextProgress("%i/%i", quantity, totalQuantity)
      elseif enemyFormat == EnemyForcesFormat.FULL_MOB_INFO_WITH_PERCENT then
        objective:SetTextProgress("%i/%i (%s)", quantity, totalQuantity, GetPercentageString(quantity, totalQuantity))
      else
        objective:SetTextProgress(GetPercentageString(quantity, totalQuantity))
      end
    else
      objective:HideProgress()
    end
  end
end

__SystemEvent__()
function CHALLENGE_MODE_DEATH_COUNT_UPDATED()
  local count, timeLost = GetDeathCount()
  _Keystone.deathCount  = count
  _Keystone.timeLost    = timeLost
end


__Async__()
function UpdateTimer(self)
  if KEYSTONE_TIMER_STARTED then
    return
  end

  KEYSTONE_TIMER_STARTED = true

  while not _Keystone.isCompleted do
    local _, elapsedTime = GetWorldElapsedTime(1)
    _Keystone.timer = elapsedTime
    Delay(0.1)
    _Keystone:WakeUpTracker()
  end

  KEYSTONE_TIMER_STARTED = false
end

__Async__()
function GetKeystoneInfo(self)
  local level, affixes, wasEnergized = GetActiveKeystoneInfo()
  _Keystone.level         = level
  _Keystone.wasEnergized  = wasEnergized
  _Keystone.numAffixes    = #affixes

  for i = 1, _Keystone.numAffixes do
    local affix = _Keystone:GetAffix(i)

    if i == 4 then
      affix.id = affixes[3]
    else
      affix.id = affixes[i]
    end

    local name, desc, texture = GetAffixInfo(affix.id)
    affix.name    = name
    affix.texture = texture
    affix.desc    = desc
  end

  -- If the module has been enabled by the PLAYER_ENTERING_WORLD, we need to wait
  -- the next 'UPDATE_INSTANCE_INFO' for getting a valid dungeon texture.
  if _EnablingEvent and _EnablingEvent == "PLAYER_ENTERING_WORLD" then
    Wait("UPDATE_INSTANCE_INFO")
  end

  local mapID = GetActiveChallengeMapID()
  if mapID then
    local _, _, timeLimit, texture = GetMapInfo(mapID)
    _Keystone.timeLimit = timeLimit
    _Keystone.texture   = texture
  end
end
