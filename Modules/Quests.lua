--============================================================================--
--                          EskaTracker                                       --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker               --
--============================================================================--
Eska                "EskaTracker.Objectives.Quests"                           ""
--============================================================================--
import                            "EKT"
--============================================================================--
_Active                           = false
--============================================================================--
GetNumQuestLogEntries             = GetNumQuestLogEntries
GetQuestLogTitle                  = GetQuestLogTitle
GetNumQuestLogEntries             = GetNumQuestLogEntries
GetQuestLogTitle                  = GetQuestLogTitle
GetQuestLogIndexByID              = GetQuestLogIndexByID
GetQuestWatchIndex                = GetQuestWatchIndex
GetQuestLogSpecialItemInfo        = GetQuestLogSpecialItemInfo
GetQuestObjectiveInfo             = GetQuestObjectiveInfo
GetDistanceSqToQuest              = GetDistanceSqToQuest
AddQuestWatch                     = AddQuestWatch
SelectQuestLogEntry               = SelectQuestLogEntry
IsWorldQuest                      = QuestUtils_IsQuestWorldQuest
IsQuestBounty                     = IsQuestBounty
GetQuestName                      = C_QuestLog.GetQuestInfo
IsQuestOnMap                      = Utils.Quest.IsQuestOnMap
IsLegionAssaultQuest              = Utils.Quest.IsLegionAssaultQuest
--============================================================================--
SORT_QUESTS_BY_DISTANCE_SETTING   = "sort-quests-by-distance"
SHOW_ONLY_QUESTS_IN_ZONE_SETTING  = "show-only-quests-in-zone"
--============================================================================--
QUESTS_CACHE                      = {}
QUEST_HEADERS_CACHE               = {}
QUESTLOG_INDEX_CACHE              = {}
QUESTS_WITH_TIMER_CACHE           = {}
DISTANCE_UPDATER_ENABLED          = false
--============================================================================--
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_WATCH_LIST_CHANGED"
function ActiveOn(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" or "QUEST_WATCH_LIST_CHANGED"  then
    return GetNumQuestWatches() > 0
  elseif event == "QUEST_ACCEPTED" then
    local _, questID = ...
    if IsWorldQuest(questID) or IsQuestBounty(questID) then
      return false
    end

    return true
  end

  return false
end

__InactiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function InactiveOn(self, event, ...)
  return GetNumQuestWatches() == 0
end
--============================================================================--
function OnLoad(self)
  -- Register the settings
  Settings:Register(SORT_QUESTS_BY_DISTANCE_SETTING, true)
  Settings:Register(SHOW_ONLY_QUESTS_IN_ZONE_SETTING, false, "quests/updateAll")

  CallbackHandlers:Register("quests/updateAll", CallbackHandler(function()
    for questID in pairs(QUESTS_CACHE) do
      _M:UpdateQuest(questID)
    end
  end))
end

function OnActive(self)
  if not _QuestBlock then
    _QuestBlock = block "quests"
  end

  _QuestBlock.isActive = true

  -- [FIX] Super track the closest quest for the players having not the blizzad objective quest.
  QuestSuperTracking_ChooseClosestQuest()
end

function OnInactive(self)
  if _QuestBlock then
    _QuestBlock.isActive = false
  end

  DISTANCE_UPDATER_LAUNCHED = false
end

__Async__()
__SystemEvent__()
function PLAYER_ENTERING_WORLD(initialLogin, reloadingUI)
  if initialLogin then
    -- If it's the first login, we need to wait 'QUEST_LOG_UPDATE' is fired to
    -- get valid informations about quests.
    Wait("QUEST_LOG_UPDATE")
  end

  _M:LoadQuests()
  UPDATE_BLOCK_VISIBILITY()
  _M:UpdateDistance()
end

__SystemEvent__()
function QUEST_AUTOCOMPLETE(questID)
  _M:ShowPopup(questID, "COMPLETE")
end

__SecureHook__()
function AutoQuestPopupTracker_AddPopUp(questID, popupType)
  _M:ShowPopup(questID, popupType)
end

__SecureHook__()
function AutoQuestPopupTracker_RemovePopUp(questID)
  _M:HidePopup(questID)
end


__SystemEvent__()
function QUEST_ACCEPTED(questLogIndex, questID)
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  -- Add it in the quest watched
  AddQuestWatch(questLogIndex)
end


__Async__()
__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID or IsWorldQuest(questID) or IsQuestBounty(questID) then
    return
  end

  if isAdded then
    QUESTS_CACHE[questID] = true

    if Settings:Get(SHOW_ONLY_QUESTS_IN_ZONE_SETTING) then
        -- We need to wait 'AREA_POIS_UPDATED' is fired to IsOnMap return a
        -- correct value
        Wait(0.3, "AREA_POIS_UPDATED")
    end

    _M:UpdateQuest(questID)

    QuestSuperTracking_OnQuestTracked(questID)
  else
    _M:RemoveQuest(questID)
  end

  _M:UpdateDistance()
end

function RemoveQuest(self, questID)
  QUESTS_CACHE[questID] = nil
  QUESTS_WITH_TIMER_CACHE[questID] = nil

  _QuestBlock:RemoveQuest(questID)
  _QuestBlock:ResumeIdleCountdown(questID)

  ActionBars:RemoveButton(questID, "quest-items")

  QuestSuperTracking_OnQuestUntracked()
end

__SystemEvent__ "QUEST_LOG_UPDATE"
function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  QuestSuperTracking_OnPOIUpdate()
end

__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_ARED" "AREA_POIS_UPDATED"
function QUESTS_ON_MAP_UPDATE()
    QUESTS_UPDATE()
end

__SystemEvent__ "EKT_QUESTBLOCK_QUEST_ADDED" "EKT_QUESTBLOCK_QUEST_REMOVED"
function UPDATE_BLOCK_VISIBILITY(questID)
  if _QuestBlock then
    _QuestBlock.isActive = _QuestBlock.quests.Count > 0
  end
end


function UpdateQuest(self, questID, cache)
  local isLocal = IsQuestOnMap(questID)
  local quest   = _QuestBlock:GetQuest(questID)

  if Settings:Get(SHOW_ONLY_QUESTS_IN_ZONE_SETTING) and not isLocal then
    if quest then
      _QuestBlock:ResumeIdleCountdown(questID)

      _QuestBlock:RemoveQuest(quest)
    end
    return
  end

  local isNew = false
  if not quest then
    quest = ObjectManager:Get(Quest)
    isNew = true
  end

  local questLogIndex   = GetQuestLogIndexByID(questID)
  local questWatchIndex = GetQuestWatchIndex(questLogIndex)

  if not questWatchIndex then
    self:RemoveQuest(questID)
    return
  end

  local _, title, questLogIndex, numObjectives, requiredMoney,
  isComplete, startEvent, isAutoComplete, failureTime, timeElapsed,
  questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex)

  if isNew then
    local header = cache and cache.header or self:GetQuestHeader(questID)
    local level  = cache and cache.level or select(2, GetQuestLogTitle(questLogIndex))

    quest.id          = questID
    quest.header      = header
    quest.level       = level
    quest.name        = title
    quest.isBounty    = isBounty
    quest.isStory     = isStory
    quest.isTask      = isTask

    if isLocal then
      _QuestBlock:AddIdleCountdown(questID, nil, true)
    end
  end

  if failureTime then
    QUESTS_WITH_TIMER_CACHE[questID] = true
    self:RunAndUpdateTimers()
  else
    QUESTS_WITH_TIMER_CACHE[questID] = nil
  end


  quest.isCompleted = isComplete

  -- The quest are on map will wake up permanently the tracker.
  if quest.isOnMap ~= isLocal then
    if isLocal then
      _QuestBlock:AddIdleCountdown(questID, nil, true)
    else
      _QuestBlock:ResumeIdleCountdown(questID)
    end
  end

  quest.isOnMap     = isLocal


  -- Is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  if itemLink and itemTexture then
    local itemQuest = quest:GetQuestItem()
    itemQuest.link      = itemLink
    itemQuest.texture   = itemTexture

    if not ActionBars:HasButton(questID, "quest-items") then
      local itemButton = ObjectManager:Get(ItemButton)
      itemButton.id         = questID
      itemButton.link       = itemLink
      itemButton.texture    = itemTexture
      itemButton.category   = "quest-items"
      ActionBars:AddButton(itemButton)
    end
  end

  -- Update the objectives
  if numObjectives > 0 then
    quest.numObjectives = numObjectives
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(quest.id, index, false)
      local objective = quest:GetObjective(index)

      objective.text        = text
      objective.isCompleted = finished

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(quest.id)
        objective:ShowProgress()
        objective:SetMinMaxProgress(0, 100)
        objective:SetProgress(progress)
        objective:SetTextProgress(PERCENTAGE_STRING:format(progress))
      else
        objective:HideProgress()
      end

      if failureTime then
        if index == numObjectives then
          objective:ShowTimer()
          objective:SetTimer(failureTime, timeElapsed)
        else
          objective:HideTimer()
        end
      end
    end
  else
    quest.numObjectives = 1
    local objective = quest:GetObjective(1)
    SelectQuestLogEntry(questLogIndex)

    objective.text        = GetQuestLogCompletionText()
    objective.isCompleted = false
  end

  if isNew then
    _QuestBlock:AddQuest(quest)
    quest.IsCompletedChanged = function() QuestSuperTracking_OnQuestCompleted() end
  end
end

function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"

  local cache = {}

  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if not isTask and not _QuestBlock:GetQuest(questID) then
      if isHeader then
        currentHeader = title
      elseif not isHeader and not isHidden and IsQuestWatched(i) then
        QUESTS_CACHE[questID] = true
        QUEST_HEADERS_CACHE[questID] = currentHeader

        cache.level = level
        cache.header = currentHeader
        cache.questLogIndex = questLogIndex

        self:UpdateQuest(questID, cache)
      end
    end
  end

  self:RefreshPopups()
end


function ShowPopup(self, questID, popupType)
  local notification = Notifications():Get(questID)
  if not notification then
    notification = QuestPopupNotification()
    notification.type       = popupType
    notification.questID    = questID
    notification.questName  = GetQuestName(questID)
    notification.id         = questID
    Notifications():Add(notification)
  end

  return notification
end

function HidePopup(self, questID)
  Notifications():Remove(questID)
end

function RefreshPopups(self)
  for i = 1, GetNumAutoQuestPopUps() do
    local questID, popupType = GetAutoQuestPopUp(i)
    if not IsQuestBounty(questID) then
      self:ShowPopup(questID, popupType)
    end
  end
end


function GetQuestHeader(self, qID)
    -- Check if the quest header is in the cache
    if QUEST_HEADERS_CACHE[qID] then
      return QUEST_HEADERS_CACHE[qID]
    end

    -- if no, fin the quest header
    local currentHeader = "Misc"
    local numEntries, numQuests = GetNumQuestLogEntries()

    for i = 1, numEntries do
      local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
      if isHeader then
        currentHeader = title
      elseif questID == qID then
        QUEST_HEADERS_CACHE[qID] = currentHeader
        return currentHeader
      end
    end
    return currentHeader
end


__Async__()
__SystemEvent__()
function PLAYER_STARTED_MOVING()
  DISTANCE_UPDATER_ENABLED = true
  while Settings:Get(SORT_QUESTS_BY_DISTANCE_SETTING) and DISTANCE_UPDATER_ENABLED do
    _M:UpdateDistance()

    -- TODO: Create an option for changing the refresh rate.
    Delay(1)
  end
end

__SystemEvent__()
function PLAYER_STOPPED_MOVING()
  DISTANCE_UPDATER_ENABLED = false

  _M:UpdateDistance()
end

IN_TAXI = false
__Async__()
__SystemEvent__()
function VEHICLE_ANGLE_SHOW()
  if IN_TAXI then
    return
  end

  IN_TAXI = true

  PLAYER_STARTED_MOVING()

  NextEvent("VEHICLE_ANGLE_SHOW")

  PLAYER_STOPPED_MOVING()

  Delay(0.2)

  IN_TAXI = false
end

function UpdateDistance()
  for index, quest in _QuestBlock.quests:GetIterator() do
    -- If the quest is a Legion assault, set it in first.
    if IsLegionAssaultQuest(quest.id) then
      quest.distance = 0
    else
      local questLogIndex = GetQuestLogIndexByID(quest.id)
      local distanceSq = GetDistanceSqToQuest(questLogIndex)
      quest.distance = distanceSq and math.sqrt(distanceSq) or nil
    end
  end
end

TIMER_TICKER_LAUNCHED = false
__Async__()
function RunAndUpdateTimers(self)
  if TIMER_TICKER_LAUNCHED then
    return
  end

  TIMER_TICKER_LAUNCHED = true

  while true do
    Next()

    local hasQuest = false
    for questID in pairs(QUESTS_WITH_TIMER_CACHE) do
      hasQuest = true
      _M:UpdateQuest(questID)
    end

    if not hasQuest then
      break
    end
  end

  TIMER_TICKER_LAUNCHED = false
end
