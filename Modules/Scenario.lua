--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                   "EskaTracker.Objectives.Scenario"                      ""
--============================================================================--
import                            "EKT"
--============================================================================--
_Active                           = false
--============================================================================--
IsInScenario                      = C_Scenario.IsInScenario
GetInfo                           = C_Scenario.GetInfo
GetStepInfo                       = C_Scenario.GetStepInfo
GetCriteriaInfo                   = C_Scenario.GetCriteriaInfo
GetBonusSteps                     = C_Scenario.GetBonusSteps
GetCriteriaInfoByStep             = C_Scenario.GetCriteriaInfoByStep
GetBasicCurrencyInfo              = C_CurrencyInfo.GetBasicCurrencyInfo
IsHorrificVisionInstance          = Utils.Instance.IsHorrificVisionInstance
IsInInstance                      = IsInInstance
--============================================================================--
HasTimer                          = false
CURRENCY_WARFRONT_WOOD            = 1540
CURRENCY_WARFRONT_IRON            = 1541
CURRENCY_WARFRONT_IRON_IN_CHEST   = 1705 -- the iron you get passively from chest

CURRENCY_CORRUPTED_MEMENTO = 1744
CURRENCY_CORRUPTED_MEMENTO_PERMANENT = 1719 -- This is not the corrupted memento used in the scenario
--============================================================================--
function OnActive(self)
  if not _Scenario then
    _Scenario = block "scenario"
  end

  _Scenario.isActive = true

  self:UpdateScenario()
  self:UpdateObjectives()

  _Scenario:AddIdleCountdown(nil, nil, true)
end

function OnInactive(self)
  if _Scenario then
    _Scenario.isActive = false
    _Scenario:Reset()
    _Scenario:ResumeIdleCountdown()
  end
end

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE"
function ActiveOn(self)
  -- Prevent the scenario module to be loaded in dungeon
  local inInstance, type = IsInInstance()
  if inInstance and (type == "party") then
    return false
  end

  return IsInScenario()
end

function UpdateObjectives(self)
  local stageName, stageDescription, numObjectives, _, _, _, _, numSpells, spellInfo, weightedProgress, _, widgetSetID = GetStepInfo()
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

  -- TODO Works the scenario spell
  --[[for index, spellData in pairs(spellInfo) do
    if not ActionBars:HasButton(spellData.spellID, "quest-items") then
      local spellButton = ObjectManager:Get(SpellButton)
      spellButton.spellID     = spellData.spellID
      spellButton.texture     = spellData.spellIcon
      spellButton.spellName   = spellData.spellName
      spellButton.category    = "quest-items"
      ActionBars:AddButton(spellButton)
    end
  end--]]
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

  local title, currentStage, numStages, flags, _, _, _, xp, money, scenarioType = GetInfo();
  _Scenario.name          = title
  _Scenario.currentStage  = currentStage
  _Scenario.numStages     = numStages
  _Scenario.isWarfront    = (scenarioType == LE_SCENARIO_TYPE_WARFRONT)


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

__SystemEvent__()
function CURRENCY_DISPLAY_UPDATE(currency, amount)
  if _Scenario.isWarfront then
    if currency == CURRENCY_WARFRONT_WOOD then
      _Scenario.wood = amount
    elseif currency == CURRENCY_WARFRONT_IRON then
      _Scenario.iron = amount
    elseif currency == CURRENCY_WARFRONT_IRON_IN_CHEST then
      _Scenario.ironInChest = amount
    end
  else 
    if currency and currency ~= CURRENCY_CORRUPTED_MEMENTO_PERMANENT then 
        _Scenario.hasCurrencies = true
        local currencyFrame, isNew = _Scenario.currencies:GetCurrency(currency)
        if isNew then 
          local currencyInfo = GetBasicCurrencyInfo(currency)
          currencyFrame.name = currencyInfo.name
          currencyFrame.desc = currencyInfo.description
          currencyFrame.icon = currencyInfo.icon
          currencyFrame.quality = currencyInfo.quality
        end 
          
        currencyFrame.displayAmount = amount
        currencyFrame.actualAmount = amount
    end 
  end 
end

__SystemEvent__()
function EKT_HARD_RELOAD_MODULES()
  _Active = false 

  local inInstance, type = IsInInstance()
  local isActive = (IsInScenario() and not (inInstance and (type == "party")))
  if isActive then 
    _Active = true
  end
end 


