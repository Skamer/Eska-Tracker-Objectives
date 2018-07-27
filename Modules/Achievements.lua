--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio              "EskaTracker.Objectives.Achievements"                    ""
--============================================================================--
import                             "EKT"
--============================================================================--
GetTrackedAchievements    = GetTrackedAchievements
GetAchievementInfo        = GetAchievementInfo
GetAchievementNumCriteria = GetAchievementNumCriteria
IsAchievementEligible     = IsAchievementEligible
-- ========================================================================== --
function OnLoad(self)
  _Enabled = self:HasAchievement()

  -- Register achievement options
  Settings:Register("achievement-max-criteria-displayed", 0, "achievements/updateAll")
  Settings:Register("achievement-hide-criteria-completed", false, "achievements/updateAll")
  Settings:Register("achievement-show-description", true, "achievements/updateAll")

  -- Callback
  CallbackHandlers:Register("achievements/updateAll", CallbackHandler(function() _M:UpdateAll() end))
end


function OnEnable(self)
  if not _AchievementBlock then
    _AchievementBlock = block "achievements"
    self:LoadAchievements()
  end

  _AchievementBlock.isActive = true
  _AchievementBlock:WakeUpTracker()
end

function OnDisable(self)
  if _AchievementBlock then
    _AchievementBlock.isActive = false
  end
end

__SafeActivatingOnEvent__ "TRACKED_ACHIEVEMENT_LIST_CHANGED"
function EnablingOn(self, event, ...)
  return self:HasAchievement()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_UPDATE(achievementID)
  if not _AchievementBlock then
    return
  end

  local achievement = _AchievementBlock:GetAchievement(achievementID)
  if achievement then
    _M:UpdateAchievement(achievement)
  end

  _AchievementBlock:WakeUpTracker()
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:UpdateAll()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_LIST_CHANGED(achievementID, isAdded)
  -- NOTE: When an achievement has failed, TRACKED_ACHIEVEMENT_LIST_CHANGED is triggered with
  -- achievementID and isAdded having a nil value
  if achievementID then
    if isAdded and not _AchievementBlock:GetAchievement(achievementID) then
      local achievement = ObjectManager:Get(Achievement)
      achievement.id =  achievementID
      _AchievementBlock:AddAchievement(achievement)
      _M:UpdateAchievement(achievement)
    elseif not isAdded then
      _AchievementBlock:RemoveAchievement(achievementID)
    end
  else
    -- NOTE: When an anchievement has failed, achievementID and isAdded have a nil value.
    -- We must update all for the achievement eligibility is correctly updated.
    -- Infortunnaly we don't know which achievement has an eligibility change.
    _M:UpdateAll()
  end

  _AchievementBlock:WakeUpTracker()
end

__Async__()
function LoadAchievements(self)
  local trackedAchievements = { GetTrackedAchievements() }
  for i = 1, #trackedAchievements do
    local achievementID = trackedAchievements[i]
    TRACKED_ACHIEVEMENT_LIST_CHANGED(achievementID, true)
  end
end

function UpdateAll(self)
  if not _AchievementBlock then
    return
  end

  local trackedAchievements = { GetTrackedAchievements() }
  for i = 1, #trackedAchievements do
    local achievementID = trackedAchievements[i]
    local achievement = _AchievementBlock:GetAchievement(achievementID)
    if achievement then
      _M:UpdateAchievement(achievement)
    end
  end
end

function UpdateAchievement(self, achievement)
  local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievement.id)
  achievement.name = achievementName
  achievement.icon = icon
  achievement.desc = description
  achievement.showDesc = Settings:Get("achievement-show-description")
  local numObjectives = GetAchievementNumCriteria(achievement.id)
  if numObjectives > 0 then
    local numShownCriteria = 0
    local maxCriteriaDisplayed = Settings:Get("achievement-max-criteria-displayed")
    for index = 1, numObjectives do
      local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievement.id, index)
      local mustBeShown = true
      if criteriaCompleted and Settings:Get("achievement-hide-criteria-completed") then
        mustBeShown = false
      end
      if maxCriteriaDisplayed > 0 and numShownCriteria == maxCriteriaDisplayed then
        mustBeShown = false
      end

      if mustBeShown then
        numShownCriteria = numShownCriteria + 1
        achievement.numObjectives = numShownCriteria

        local objective = achievement:GetObjective(numShownCriteria)
        objective.isCompleted = criteriaCompleted
        objective.text = criteriaString
        objective.failed = not eligible
        if ( description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
          objective:ShowProgress()
          objective.text = description
          achievement.showDesc = false
          objective:SetMinMaxProgress(0, totalQuantity)
          objective:SetProgress(quantity)
          objective:SetTextProgress(quantityString)
        end
      end
    end
    if maxCriteriaDisplayed > 0 and numObjectives > maxCriteriaDisplayed then
      achievement:ShowDotted()
    else
      achievement:HideDotted()
    end
  elseif numObjectives == 0 then
    achievement.numObjectives = 0
    achievement.failed = not IsAchievementEligible(achievement.id)
  end
end

function HasAchievement(self)
  local achievement = GetTrackedAchievements()
  if achievement ~= nil then
    return true
  else
    return false
  end
end
