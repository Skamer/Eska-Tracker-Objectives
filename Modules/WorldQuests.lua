--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                  "EskaTracker.Objectives.Worldquests"                 ""
--============================================================================--
import                            "EKT"
--============================================================================--
IsWorldQuest              = QuestUtils_IsQuestWorldQuest
GetTaskInfo               = GetTaskInfo
IsInInstance              = IsInInstance
IsWorldQuestHardWatched   = IsWorldQuestHardWatched
IsWorldQuestWatched       = IsWorldQuestWatched
GetSuperTrackedQuestID    = GetSuperTrackedQuestID
--============================================================================--
-- The black is used to hide weekly world quests (e.g, 2v2, 3v3, rbg quests)
-- TODO: With BFA, check if the blacklist is still needed.
WORLD_QUESTS_BLACKLIST = {
  [44891] = true, -- 2v2 Weekly quest
  [44908] = true, -- 3v3 Weekly quest
  [44909] = true, -- RBG Weekly quest
}
LAST_TRACKED_WORLD_QUEST = nil
--============================================================================--
SHOW_TRACKED_WORLD_QUESTS_OPTION = "show-tracked-world-quests"
--============================================================================--
function OnLoad(self)
  -- Register the options
  Options:Register(SHOW_TRACKED_WORLD_QUESTS_OPTION, true , "worldquests/enableTracking")
  CallbackHandlers:Register("worldquests/enableTracking",  CallbackHandler(function(enable) _M:EnableWorldQuestsTracking(enable) end))

  -- Check if the player is in a worldquest zone
  self._Enabled = self:HasWorldQuest()
end

function OnEnable(self)
  if not _WorldQuestBlock then
    _WorldQuestBlock = block "world-quests"
  end

  _WorldQuestBlock.isActive = true
  _WorldQuestBlock:WakeUpTracker()
  self:LoadWorldQuests()
end


function OnDisable(self)
  if _WorldQuestBlock then
    _WorldQuestBlock.isActive = false
  end
end

__EnablingOnEvent__ "QUEST_ACCEPTED" "PLAYER_ENTERING_WORLD" "EKT_WORLDQUEST_TRACKED_LIST_CHANGED"
function EnablingOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then
    local _, questID = ...
    return IsWorldQuest(questID) and not WORLD_QUESTS_BLACKLIST[questID]
  elseif event == "PLAYER_ENTERING_WORLD" then
    local inInstance, type = IsInInstance()
    if inInstance and type == "party" then
      return self:HasWorldQuest()
    end
  elseif event == "EKT_WORLDQUEST_TRACKED_LIST_CHANGED" then
    local _, isAdded = ...
    if isAdded then
      return true
    end
  end

  return false
end

__DisablingOnEvent__ "PLAYER_ENTERING_WORLD" "EKT_WORLDQUEST_REMOVED"
function DisablingOn(self, event, ...)
  if event == "EKT_WORLDQUEST_REMOVED" then
    if _WorldQuestBlock then
      return _WorldQuestBlock.worldQuests.Count == 0
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    return not self:HasWorldQuest()
  end

  return false
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID, isTracked)
  -- NOTE Fix WorldQuestGroupFinder addon
  if not isTracked and IsWorldQuest(questID) then
    ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED, questID)
  end

  -- if the quest isn't a worldquest or is blacklisted, stop here
  if not IsWorldQuest(questID) or WORLD_QUESTS_BLACKLIST[questID] or _WorldQuestBlock:GetWorldQuest(questID) then
    return
  end

  local worldQuest = ObjectManager:Get(WorldQuest)
  worldQuest.id         = questID
  worldQuest.isTracked  = isTracked

  _M:UpdateWorldQuest(worldQuest)

  _WorldQuestBlock:AddWorldQuest(worldQuest)
  _WorldQuestBlock:WakeUpTracker()
end

__SystemEvent__()
function QUEST_REMOVED(questID, fromTracking)
  -- if the quest isn't a worldquest, don't continue
  if not IsWorldQuest(questID) then
    return
  end

  if fromTracking then
    local worldQuest = _WorldQuestBlock:GetWorldQuest(questID)
    if worldQuest and WorldQuest.isInArea then
      return
    end
  end

  if Options:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    -- TODO Check this isTracked, two IsWorldQuestHardWatched
    local isTracked = IsWorldQuestHardWatched(questID) or IsWorldQuestHardWatched(questID) or GetSuperTrackedQuestID() == questID
    if isTracked then
      local worldQuest = _WorldQuestBlock:GetWorldQuest(questID)
      if worldQuest then
        worldQuest.isTracked = true
        return
      end
    end
  end

  _WorldQuestBlock:RemoveWorldQuest(questID)
  _WorldQuestBlock:WakeUpTracker()
  Scorpio.FireSystemEvent("EKT_WORLDQUEST_REMOVED")
end

local lastTrackedQuestID = nil
__SystemEvent__()
function EKT_WORLDQUEST_TRACKED_LIST_CHANGED(questID, isAdded, hardWatch)
  if isAdded then
    QUEST_ACCEPTED(nil, questID, true)
    if not hardWatch then
      if LAST_TRACKED_WORLD_QUEST and LAST_TRACKED_WORLD_QUEST ~= questID then
        QUEST_REMOVED(LAST_TRACKED_WORLD_QUEST, true)
      end
      LAST_TRACKED_WORLD_QUEST = questID
    end
  else
    QUEST_REMOVED(questID, true)
  end

  _WorldQuestBlock:WakeUpTracker()
end

__Async__()
function LoadWorldQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if IsWorldQuest(questID) and not _WorldQuestBlock:GetWorldQuest(questID) then
      local worldQuest = ObjectManager:Get(WorldQuest)
      worldQuest.id   = questID
      worldQuest.name = title

      self:UpdateWorldQuest(worldQuest)

      _WorldQuestBlock:AddWorldQuest(worldQuest)
    end
  end

  if Options:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    for i = 1, GetNumWorldQuestWatches() do
      local questID = GetWorldQuestWatchInfo(i)
      if questID and not _WorldQuestBlock:GetWorldQuest(questID) then
        local worldQuest = ObjectManager:Get(WorldQuest)
        worldQuest.id   = questID
        worldQuest.name = title

        self:UpdateWorldQuest(worldQuest)

        _WorldQuestBlock:AddWorldQuest(worldQuest)
      end
    end
  end
end

function UpdateWorldQuest(self, worldQuest)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(worldQuest.id)
  worldQuest.isOnMap  = true
  worldQuest.name     = taskName
  worldQuest.isInArea = isInArea

  if Options:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    -- TODO Check this isTracked, two IsWorldQuestHardWatched
    local isTracked = IsWorldQuestHardWatched(worldQuest.id) or IsWorldQuestHardWatched(worldQuest.id) or GetSuperTrackedQuestID() == worldQuest.id
    if isInArea and worldQuest.isTracked then
      worldQuest.isTracked = false
    elseif not isInArea and isTracked then
      worldQuest.isTracked = true
    end
  end

  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(GetQuestLogIndexByID(worldQuest.id))
  if itemLink and itemTexture then
    local itemQuest  = worldQuest:GetQuestItem()
    itemQuest.link = itemLink
    itemQuest.texture = itemTexture
    -- TODO Add the item when the new item API is availaible
    --_Addon.ItemBar:AddItem(worldQuest.id, itemLink, itemTexture)
  end

  if numObjectives then
    worldQuest.numObjectives = numObjectives
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(worldQuest.id, index, false)
      local objective = worldQuest:GetObjective(index)

      objective.isCompleted = finished
      objective.text = text

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(worldQuest.id)
        objective:ShowProgress()
        objective:SetMinMaxProgress(0, 100)
        objective:SetProgress(progress)
        objective:SetTextProgress(string.format("%i%%", progress))
      else
        objective:HideProgress()
      end
    end

  end
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for _, worldQuest in _WorldQuestBlock.worldQuests:GetIterator() do
    _M:UpdateWorldQuest(worldQuest)
  end

  _WorldQuestBlock:WakeUpTracker()
end



function HasWorldQuest(self)
  for i = 1, GetNumQuestLogEntries() do
    local questID = select(8, GetQuestLogTitle(i))
    if IsWorldQuest(questID) and not WORLD_QUESTS_BLACKLIST[questID] then
      return true
    end
  end

  if Options:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    for i = 1, GetNumWorldQuestWatches() do
      return true
    end
  end

  return false
end

function EnableWorldQuestsTracking(self, enable)
  for i = 1, GetNumWorldQuestWatches() do
    local questID = GetWorldQuestWatchInfo(i)
    local hardWatched = IsWorldQuestHardWatched(questID)
    if enable then
      self:FireSystemEvent("EQT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, true, hardWatched)
    else
      self:FireSystemEvent("EQT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, false, hardWatched)
    end
  end
end
