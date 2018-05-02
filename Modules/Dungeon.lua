--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio              "EskaTracker.Objectives.Dungeon"                         ""
--============================================================================--
import                             "EKT"
--============================================================================--
IsInInstance          = IsInInstance
IsInScenario          = C_Scenario.IsInScenario
GetInfo               = C_Scenario.GetInfo
GetStepInfo           = C_Scenario.GetStepInfo
GetCriteriaInfo       = C_Scenario.GetCriteriaInfo
GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo
--============================================================================--
function OnLoad(self)
  self._Enabled = false
end

function OnEnable(self)
  if not _Dungeon then
    _Dungeon = block "dungeon"
  end

  _Dungeon.isActive = true
  UpdateObjectives()
end


function OnDisable(self)
  if _Dungeon then
    _Dungeon.isActive = false
  end
end

__ActivatingOnEvent__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START" "SCENARIO_UPDATE"
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
      objective:SetMinMaxValues(0, 100)
      objective:SetProgress(quantity)
      objective:SetTextProgress(string.format("%i%%", quantity))
    else
      objective:HideProgress()
      objective.text = string.format("%i/%i %s", quantity, totalQuantity, description)
    end
  end
end

__SystemEvent__ "WORLD_MAP_UPDATE" "UPDATE_INSTANCE_INFO"
function UPDATE_TEXTURE()
  _Dungeon.texture = select(6, EJ_GetInstanceInfo(BFASupport:GetCurrentInstance()))
end
