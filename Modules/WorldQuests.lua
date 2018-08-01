--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                   "EskaTracker.Objectives.WorldQuests"                ""
--============================================================================--
import                              "EKT"
--============================================================================--
_Enabled                            = false
--============================================================================--
IsWorldQuest                        = QuestUtils_IsQuestWorldQuest
GetTasksTable                       = GetTasksTable
IsWorldQuestHardWatched             = IsWorldQuestHardWatched
IsWorldQuestWatched                 = IsWorldQuestWatched
GetSuperTrackedQuestID              = GetSuperTrackedQuestID
--============================================================================--
SHOW_TRACKED_WORLD_QUESTS_OPTION    = "show-tracked-world-quests"
--============================================================================--
LAST_TRACKED_WORLD_QUEST            = nil
--============================================================================--
__EnablingOnEvent__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "EKT_WORLDQUEST_TRACKED_LIST_CHANGED"
function EnablingOn(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    return self:HasWorldQuest()
  elseif event == "QUEST_ACCEPTED" then
    local _, questID = ...
    return IsWorldQuest(questID)
  elseif event == "EKT_WORLDQUEST_TRACKED_LIST_CHANGED" then
    local _, isAdded = ...
    if isAdded then
      return true
    end
  end

  return false
end

__SafeDisablingOnEvent__  "QUEST_REMOVED" "PLAYER_ENTERING_WORLD" "EKT_WORLDQUEST_TRACKED_LIST_CHANGED"
function DisablingOn(self, event, ...)
  return not self:HasWorldQuest()
end
--============================================================================--
function OnLoad(self)
  -- Register the options
  Settings:Register(SHOW_TRACKED_WORLD_QUESTS_OPTION, true, "worldquests/enableTracking")
  CallbackHandlers:Register("worldquests/enableTracking",  CallbackHandler(function(enable) _M:EnableWorldQuestsTracking(enable) end))
end

function OnEnable(self)
  if not _WorldQuestBlock then
    _WorldQuestBlock = block "world-quests"
  end

  _WorldQuestBlock.isActive = true

  LAST_TRACKED_WORLD_QUEST = GetSuperTrackedQuestID()

  if _EnablingEvent == "EKT_WORLDQUEST_TRACKED_LIST_CHANGED" then
    EKT_WORLDQUEST_TRACKED_LIST_CHANGED(unpack(_EnablingEventArgs))
  end

  _WorldQuestBlock:AddIdleCountdown(nil, nil, true)
end

function OnDisable(self)
  if _WorldQuestBlock then
    _WorldQuestBlock.isActive = false
    _WorldQuestBlock.worldQuests:Clear()

    _WorldQuestBlock:ResumeIdleCountdown()
  end
end
--============================================================================--
__ForceSecureHook__()
function BonusObjectiveTracker_TrackWorldQuest(questID, hardWatch)
  if Settings:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    Scorpio.FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, true, hardWatch)
  end
end

__SecureHook__()
function BonusObjectiveTracker_UntrackWorldQuest(questID)
  if Settings:Get("show-tracked-world-quests") then
    Scorpio.FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, false)
  end
end


__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:LoadWorldQuests()
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID, isTracked)
  if not IsWorldQuest(questID) or _WorldQuestBlock:GetWorldQuest(questID) then
    return
  end

  local worldQuest = ObjectManager:Get(WorldQuest)
  worldQuest.id = questID

  _M:UpdateWorldQuest(worldQuest)
  _WorldQuestBlock:AddWorldQuest(worldQuest)

  if not isTracked then
    PlaySound(SOUNDKIT.UI_WORLDQUEST_START)
  end
end

--- Load the world quests, this function is used after the loading.
function LoadWorldQuests(self)
  local tasks = GetTasksTable()
  for i = 1, #tasks do
    local questID = tasks[i]
    local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID)
     if isInArea and not _WorldQuestBlock:GetWorldQuest(questID) then
       local worldQuest = ObjectManager:Get(WorldQuest)
       worldQuest.id = questID

       local cache = { isInArea = isInArea, isOnMap = isOnMap, numObjectives = numObjectives, taskName = taskName, displayAsObjective = displayAsObjective }
       self:UpdateWorldQuest(worldQuest, cache)

       _WorldQuestBlock:AddWorldQuest(worldQuest)
     end
  end

  if Settings:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    for i = 1, GetNumWorldQuestWatches() do
      local questID = GetWorldQuestWatchInfo(i)
      if questID and not _WorldQuestBlock:GetWorldQuest(questID) then
        local worldQuest = ObjectManager:Get(WorldQuest)
        worldQuest.id = questID

        self:UpdateWorldQuest(worldQuest)

        _WorldQuestBlock:AddWorldQuest(worldQuest)
      end
    end
  end
end

-- The cache is used to avoid a useless GetTaskInfo call after LoadWorldQuests
function UpdateWorldQuest(self, worldQuest, cache)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective
  if cache then
    isInArea            = cache.isInArea
    isOnMap             = cache.isOnMap
    numObjectives       = cache.numObjectives
    taskName            = cache.taskName
    displayAsObjective  = cache.taskName
  else
    isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(worldQuest.id)
  end

  worldQuest.name = taskName
  worldQuest.isInArea = isInArea
  worldQuest.isOnMap  = isOnMap

  if Settings:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    local isTracked = IsWorldQuestWatched(worldQuest.id) or IsWorldQuestHardWatched(worldQuest.id) or GetSuperTrackedQuestID() == worldQuest.id
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

    if not ActionBars:HasButton(worldQuest.id, "quest-items") then
      local itemButton = ObjectManager:Get(ItemButton)
      itemButton.id = worldQuest.id
      itemButton.link = itemLink
      itemButton.texture = itemTexture
      itemButton.category = "quest-items"
      ActionBars:AddButton(itemButton)
    end
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
function QUEST_REMOVED(questID, fromTracking)
  if not IsWorldQuest(questID) then
    return
  end

  local worldQuest = _WorldQuestBlock:GetWorldQuest(questID)
  if not worldQuest then
    return
  end

  if fromTracking and worldQuest.isInArea then
    return
  end

  if Settings:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
    local isTracked = IsWorldQuestWatched(questID) or IsWorldQuestHardWatched(questID) or GetSuperTrackedQuestID() == questID
    if isTracked then
      worldQuest.isTracked = true
      return
    end
  end

  _WorldQuestBlock:RemoveWorldQuest(worldQuest)
  ActionBars:RemoveButton(questID, "quest-items")
end


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
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for _, worldQuest in _WorldQuestBlock.worldQuests:GetIterator() do
    _M:UpdateWorldQuest(worldQuest)
  end
end

function HasWorldQuest(self)
  local tasks = GetTasksTable()
  for i = 1, #tasks do
    local questID = tasks[i]
    local isInArea = GetTaskInfo(questID)
    if IsWorldQuest(questID) and isInArea then
      return true
    end
  end

  if Settings:Get(SHOW_TRACKED_WORLD_QUESTS_OPTION) then
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
      self:FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, true, hardWatched)
    else
      self:FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, false, hardWatched)
    end
  end
end
