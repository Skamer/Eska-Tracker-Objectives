--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Objectives.Scenario"                      ""
--============================================================================--
import                              "EKT"
--============================================================================--
IsInScenario          = C_Scenario.IsInScenario
GetInfo               = C_Scenario.GetInfo
GetStepInfo           = C_Scenario.GetStepInfo
GetCriteriaInfo       = C_Scenario.GetCriteriaInfo
GetBonusSteps         = C_Scenario.GetBonusSteps
GetCriteriaInfoByStep = C_Scenario.GetCriteriaInfoByStep
IsInInstance          = IsInInstance
--============================================================================--
HasTimer = false
--============================================================================--
function OnLoad(self)
  self._Enabled = false
end

function OnEnable(self)
  if not _Scenario then
    _Scenario = block "scenario"
  end

  _Scenario.isActive = true

  self:UpdateScenario()
  self:UpdateObjectives()

  _Scenario:AddIdleCountdown(nil, nil, true)
end

function OnDisable(self)
  if _Scenario then
    _Scenario.isActive = false
    _Scenario:Reset()
    _Scenario:ResumeIdleCountdown()
  end
end

__ActivatingOnEvent__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE"
function ActivatingOn(self)
  -- Prevent the scenario module to be loaded in dungeon
  local inInstance, type = IsInInstance()
  if inInstance and (type == "party") then
    return false
  end

  return IsInScenario()
end

function UpdateObjectives(self)
  local stageName, stageDescription, numObjectives,  _, _, _, numSpells, spellInfo = GetStepInfo()
  local weightedProgress = select(10, C_Scenario.GetStepInfo())
  local needRunTimer = false

  _Scenario.stageName = stageName

  if weightedProgress then
    -- @NOTE : Some scenario (e.g : 7.2 Broken shode indroduction, invasion scenario)
    -- can have a objective progress even if it say numObjectives == 0 so we need to check if the
    -- step info has weightedProgress.
    -- If the stage has a weightedProgress, show only this one even if the numObjectives say >= 1.
    _Scenario.numObjectives = 1 -- Say to block there is 1 objective only (even if the game say 0)

    local objective = _Scenario:GetObjective(1) -- get the first objective

    objective.isCompleted = false
    objective.text = stageDescription

    -- progress
    objective:ShowProgress()
    objective:SetMinMaxProgress(0, 100)
    objective:SetProgress(weightedProgress)
    objective:SetTextProgress(PERCENTAGE_STRING:format(weightedProgress))

  else
    local tblBonusSteps = GetBonusSteps()
    local numBonusObjectives = #tblBonusSteps

    _Scenario.numObjectives = numObjectives + numBonusObjectives

    for index = 1, numObjectives do
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)


      local objective = _Scenario:GetObjective(index)
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

      if elapsed == 0 or duration == 0 then
        objective:HideTimer()
      end

    end

    -- Update the bonus objective
    -- @TODO Improve it later
    for index = 1, numBonusObjectives do
      local bonusStepIndex = tblBonusSteps[index];
      local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = GetStepInfo(bonusStepIndex);
      local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, 1);

      local objective = _Scenario:GetObjective(numObjectives + index)
      if objective then
        objective.text = criteriaString
        objective.completed = criteriaCompleted

        if duration > 0 then
          objective:ShowTimer()
          objective:SetTimer(duration, elapsed)
          needRunTimer = true

        else
          objective:HideTimer()
        end
      end
    end
  end

  if needRunTimer then
    if not HasTimer then
      HasTimer = true
      self:RunTimer()
    end
  else
    HasTimer = false
  end

end

__Async__()
function RunTimer(self)
  while HasTimer do
    self:UpdateObjectives()
    Delay(0.33)
  end
end

function UpdateScenario(self, isNewStage)
  if not IsInScenario() then return end

  local title, currentStage, numStages, flags, _, _, _, xp, money = GetInfo();
  _Scenario.name = title
  _Scenario.currentStage = currentStage
  _Scenario.numStages = numStages

  if isNewStage then
    LevelUpDisplay_PlayScenario()
    if currentStage > 1 and currentStage <= numStages then
      PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END)
    end
  end
end

__SystemEvent__ "SCENARIO_POI_UPDATE" "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_COMPLETED"
function OBJECTIVES_UPDATE()
  _M:UpdateObjectives()
end

__SystemEvent__()
function SCENARIO_UPDATE(...)
  _M:UpdateScenario(...)
  _M:UpdateObjectives()
end
