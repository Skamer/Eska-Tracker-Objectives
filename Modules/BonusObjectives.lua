--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                 "EskaTracker.Objectives.BonusObjectives"                 ""
--============================================================================--
import                              "EKT"
--============================================================================--
_Active                             = false
--============================================================================--
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
IsQuestTask                         = IsQuestTask
GetTaskInfo                         = GetTaskInfo
GetTasksTable                       = GetTasksTable
GetQuestLogIndexByID                = GetQuestLogIndexByID
SelectQuestLogEntry                 = SelectQuestLogEntry 
GetQuestLogCompletionText           = GetQuestLogCompletionText
IsBlacklisted                       = Utils.Blacklist.IsBlacklistedForBonusObjectives
--============================================================================--
function OnActive(self)
  if not _BonusObjectives then
    _BonusObjectives = block "bonus-objectives"
  end

  _BonusObjectives.isActive = true
  self:LoadBonusQuests()

  _BonusObjectives:AddIdleCountdown(nil, nil, true)
end

function OnInactive(self)
  if _BonusObjectives then
    _BonusObjectives.isActive = false
    _BonusObjectives:ResumeIdleCountdown()

    -- In some case, some bonus objectives are not removed, so we meed remove them.
    _BonusObjectives:ClearBonusQuests()
  end
end

__ActiveOnEvents__ "QUEST_ACCEPTED" "PLAYER_ENTERING_WORLD"
function ActiveOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then
    local _, questID = ...
    return not IsBlacklisted(questID) and IsQuestTask(questID) and not IsWorldQuest(questID) and not IsWorldQuestWatched(questID)
  elseif event == "PLAYER_ENTERING_WORLD" then
    return self:HasBonusQuest()
  end

  return false
end

__InactiveOnEvents__ "EKT_BONUSQUEST_REMOVED" "PLAYER_ENTERING_WORLD"
function InactiveOn(self, event, ...)
  if event == "EKT_BONUSQUEST_REMOVED" then
    if _BonusObjectives then
      return _BonusObjectives.bonusQuests.Count == 0
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    return not self:HasBonusQuest()
  end
  return true
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  if IsBlacklisted(questID) and not IsQuestTask(questID) or IsWorldQuest(questID) or IsWorldQuestWatched(questID) or _BonusObjectives:GetBonusQuest(questID) then
    return
  end

  local bonusQuest = ObjectManager:Get(BonusQuest)
  bonusQuest.id = questID

  _M:UpdateBonusQuest(bonusQuest)

  _BonusObjectives:AddBonusQuest(bonusQuest)
  PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END)
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  _BonusObjectives:RemoveBonusQuest(questID)
  Scorpio.FireSystemEvent("EKT_BONUSQUEST_REMOVED")
end

function LoadBonusQuests(self)
  local tasksTable = GetTasksTable()
  for i = 1, #tasksTable do
    local questID = tasksTable[i]
    if not IsBlacklisted(questID) and not IsWorldQuest(questID) and not IsWorldQuestWatched(questID) and not _BonusObjectives:GetBonusQuest(questID) then
      local bonusQuest = ObjectManager:Get(BonusQuest)
      bonusQuest.id     = questID

      self:UpdateBonusQuest(bonusQuest)
      _BonusObjectives:AddBonusQuest(bonusQuest)

      PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END)
    end
  end
end

function UpdateBonusQuest(self, bonusQuest)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(bonusQuest.id)
  bonusQuest.isOnMap = true
  bonusQuest.name = taskName


  if numObjectives > 0 then
    bonusQuest.numObjectives = numObjectives
    
    local numObjectivesCompleted = 0
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(bonusQuest.id, index, false)
      local objective = bonusQuest:GetObjective(index)

      objective.isCompleted = finished
      objective.text = text

      if finished then 
        numObjectivesCompleted = numObjectivesCompleted + 1 
      end

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(bonusQuest.id)
        objective:ShowProgress()
        objective:SetMinMaxProgress(0, 100)
        objective:SetProgress(progress)
        objective:SetTextProgress(string.format("%i%%", progress))
      else
        objective:HideProgress()
      end
    end

    
     -- If all the objective has been completed, show the completed message as last objective
    if numObjectivesCompleted == numObjectives then 
      bonusQuest.numObjectives = bonusQuest.numObjectives + 1
      local objective = bonusQuest:GetObjective(bonusQuest.numObjectives)
      SelectQuestLogEntry(GetQuestLogIndexByID(bonusQuest.id))
      objective.text        = GetQuestLogCompletionText()
      objective.isCompleted = false
    end


  else 
      bonusQuest.numObjectives = 1
      local objective = bonusQuest:GetObjective(1)

      SelectQuestLogEntry(GetQuestLogIndexByID(bonusQuest.id))
      objective.text        = GetQuestLogCompletionText()
      objective.isCompleted = false
  end

end

__SystemEvent__()
function QUEST_LOG_UPDATE()
    for _, bonusQuest in _BonusObjectives.bonusQuests:GetIterator() do
      _M:UpdateBonusQuest(bonusQuest)
    end
end

function HasBonusQuest(self)
  local tasks = GetTasksTable()
  for i = 1, #tasks do
    local questID = tasks[i]
    if not IsBlacklisted(questID) and not IsWorldQuest(questID) and not IsWorldQuestWatched(questID) then
      local isInArea = GetTaskInfo(questID)
      if isInArea then
        return true
      end
    end
  end
  return false
end
