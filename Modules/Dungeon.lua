--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                 "EskaTracker.Objectives.Dungeon"                         ""
--============================================================================--
import                              "EKT"
--============================================================================--
_Active                             = false
--============================================================================--
IsInInstance                        = IsInInstance
IsInScenario                        = C_Scenario.IsInScenario
GetInfo                             = C_Scenario.GetInfo
GetStepInfo                         = C_Scenario.GetStepInfo
GetCriteriaInfo                     = C_Scenario.GetCriteriaInfo
GetActiveKeystoneInfo               = C_ChallengeMode.GetActiveKeystoneInfo
--============================================================================--
function OnActive(self)
  if not _Dungeon then
    _Dungeon = block "dungeon"
  end

  _Dungeon.isActive = true
  UpdateObjectives()

  _Dungeon:AddIdleCountdown(nil, nil, true)

  self:UpdateDungeonIcon()
end


function OnInactive(self)
  if _Dungeon then
    _Dungeon:ResumeIdleCountdown()
    _Dungeon.isActive = false
    _Dungeon:ResumeIdleCountdown()
  end
end

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START" "SCENARIO_UPDATE" "ZONE_CHANGED"
function ActivatingOn(self, ...)
  local inInstance, type = IsInInstance()
  return inInstance and (type == "party") and IsInScenario() and GetActiveKeystoneInfo() == 0
end


__Async__()
__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function UpdateObjectives()
  local dungeonName, _, numObjectives = GetStepInfo()
  _Dungeon.name          = dungeonName
  _Dungeon.numObjectives = numObjectives

  for index = 1, numObjectives do
    local description, criteriaType, completed, quantity, totalQuantity,
    flags, assetID, quantityString, criteriaID, duration, elapsed,
    failed, isWeightProgress = GetCriteriaInfo(index)

    local objective = _Dungeon:GetObjective(index)
    objective.isCompleted = completed

    if isWeightProgress then
      objective.text = description
      objective:ShowProgress()
      objective:SetMinMaxProgress(0, 100)
      objective:SetProgress(quantity)
      objective:SetTextProgress(string.format("%i%%", quantity))
    else
      objective:HideProgress()
      objective.text = string.format("%i/%i %s", quantity, totalQuantity, description)
    end
  end
end

__Async__()
function UpdateDungeonIcon(self)
  -- We need to wait the next UPDATE_INSTANCE_INFO for getting a valid dungeon texture
  Wait("UPDATE_INSTANCE_INFO")

  local currentInstance = Utils.Instance.GetCurrentInstance()
  if currentInstance then
    local texture  = select(6, EJ_GetInstanceInfo(currentInstance))
    if texture then
      _Dungeon.texture = texture
    else
      Wait(1)
      _Dungeon.texture = select(6, EJ_GetInstanceInfo(currentInstance))
    end
  end
end
