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
GetNumQuestLogEntries             = C_QuestLog.GetNumQuestLogEntries
GetQuestName                      = QuestUtils_GetQuestName
GetQuestLogTitle                  = C_QuestLog.GetQuestLogTitle
GetInfo                           = C_QuestLog.GetInfo
GetQuestLogIndexByID              = C_QuestLog.GetLogIndexForQuestID
GetQuestWatchIndex                = GetQuestWatchIndex
GetQuestLogSpecialItemInfo        = GetQuestLogSpecialItemInfo
GetQuestObjectiveInfo             = GetQuestObjectiveInfo
GetDistanceSqToQuest              = C_QuestLog.GetDistanceSqToQuest
AddQuestWatch                     = C_QuestLog.AddQuestWatch
IsWorldQuest                      = QuestUtils_IsQuestWorldQuest
IsQuestBounty                     = IsQuestBounty
IsQuestOnMap                      = Utils.Quest.IsQuestOnMap
IsLegionAssaultQuest              = Utils.Quest.IsLegionAssaultQuest
IsDungeonQuest                    = Utils.Quest.IsDungeonQuest
IsRaidQuest                       = Utils.Quest.IsRaidQuest
GetNumQuestWatches                = C_QuestLog.GetNumQuestWatches
IsQuestWatched                    = QuestUtils_IsQuestWatched
GetQuestDifficultyLevel           = C_QuestLog.GetQuestDifficultyLevel
GetNumQuestObjectives             = C_QuestLog.GetNumQuestObjectives
IsQuestBounty                     = C_QuestLog.IsQuestBounty
IsQuestTask                       = C_QuestLog.IsQuestTask
IsQuestComplete                   = C_QuestLog.IsComplete
SetSelectedQuest                  = C_QuestLog.SetSelectedQuest
GetQuestTagInfo                   = C_QuestLog.GetQuestTagInfo
GetRequiredMoney                  = C_QuestLog.GetRequiredMoney
GetSuggestedGroupSize             = C_QuestLog.GetSuggestedGroupSize
GetTimeAllowed                    = C_QuestLog.GetTimeAllowed
IsOnMap                           = C_QuestLog.IsOnMap
--============================================================================--
SORT_QUESTS_BY_DISTANCE_SETTING   = "sort-quests-by-distance"
SHOW_ONLY_QUESTS_IN_ZONE_SETTING  = "show-only-quests-in-zone"
DISPLAY_RAID_QUESTS_IN_SETTING    = "display-raid-quests-in"
DISPLAY_DUNGEON_QUESTS_IN_SETTING = "display-dungeon-quests-in"
QUESTS_LOADING_DELAY_SETTING      = "quests-loading-delay"
--============================================================================--
QUESTS_CACHE                      = {}
QUEST_HEADERS_CACHE               = {}
QUESTLOG_INDEX_CACHE              = {}
QUESTS_WITH_TIMER_CACHE           = {}
DISTANCE_UPDATER_ENABLED          = false
RAID_QUEST_BLOCK_USED             = "quest-block"
DUNGEON_QUEST_BLOCK_USED          = "quest-block"
--============================================================================--
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_ACCEPTED" "QUEST_WATCH_LIST_CHANGED"
function ActiveOn(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" or event == "QUEST_WATCH_LIST_CHANGED"  then
    return GetNumQuestWatches() > 0
  elseif event == "QUEST_ACCEPTED" then
    local questID = ...
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
  Settings:Register(QUESTS_LOADING_DELAY_SETTING, 5)
  Settings:Register(DISPLAY_RAID_QUESTS_IN_SETTING, "quest-block")
  Settings:Register(DISPLAY_DUNGEON_QUESTS_IN_SETTING, "quest-block")

  CallbackHandlers:Register("quests/updateAll", CallbackHandler(function()
    for questID in pairs(QUESTS_CACHE) do
      _M:UpdateQuest(questID)
    end
  end))

  RAID_QUEST_BLOCK_USED     = Settings:Get(DISPLAY_RAID_QUESTS_IN_SETTING)
  DUNGEON_QUEST_BLOCK_USED  = Settings:Get(DISPLAY_DUNGEON_QUESTS_IN_SETTING)
end

function OnActive(self)
  if not _QuestBlock then
    _QuestBlock = block "quests"
    _InstanceQuestBlock = block "instance-quests"
    _InstanceQuestBlock.isActive  = false
  end

  _QuestBlock.isActive = true

  -- [FIX] Super track the closest quest for the players having not the blizzad objective quest.
  QuestSuperTracking_ChooseClosestQuest()
end

function OnInactive(self)
  if _QuestBlock then
    _QuestBlock.isActive = false
  end

  if _InstanceQuestBlock then
    _InstanceQuestBlock.isActive = false
  end

  DISTANCE_UPDATER_LAUNCHED = false
end

function GetBlockByID(self, id)
  if id == "quest-block" then
    return _QuestBlock
  elseif id == "instance-quest-block" then
    return _InstanceQuestBlock
  end
end

__SystemEvent__()
function EKT_SETTING_CHANGED(setting, newValue, oldValue)
  if setting == DISPLAY_RAID_QUESTS_IN_SETTING then
    local previousBlock = _M:GetBlockByID(oldValue)
    local newBlock = _M:GetBlockByID(newValue)

    for questID in pairs(QUESTS_CACHE) do
      if IsRaidQuest(questID) then
        _M:MoveQuest(questID, previousBlock, newBlock)
      end
    end

    RAID_QUEST_BLOCK_USED = newValue
  elseif setting == DISPLAY_DUNGEON_QUESTS_IN_SETTING then
    local previousBlock = _M:GetBlockByID(oldValue)
    local newBlock = _M:GetBlockByID(newValue)

    for questID in pairs(QUESTS_CACHE) do
      if IsDungeonQuest(questID) then
        _M:MoveQuest(questID, previousBlock, newBlock)
      end
    end

    DUNGEON_QUEST_BLOCK_USED = newValue
  end
end

__Async__()
__SystemEvent__()
function PLAYER_ENTERING_WORLD(initialLogin, reloadingUI)
  if initialLogin then
    -- If it's the first login, we need to wait 'QUEST_LOG_UPDATE' is fired to
    -- get valid informations about quests.
    Wait("QUEST_LOG_UPDATE")

    -- Add a delay in the first loading.
    Delay(Settings:Get(QUESTS_LOADING_DELAY_SETTING))
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
function QUEST_ACCEPTED(questID)
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestTask(questID) or IsQuestBounty(questID) then return end

  -- Add it in the quest watched
  if AUTO_QUEST_WATCH == "1" and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
    AddQuestWatch(questID, Enum.QuestWatchType.Automatic)
    QuestSuperTracking_OnQuestTracked(questID)
  end
end


__Async__()
__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)

  if not questID then
    _M:LoadQuests()
    return
  end

  if IsWorldQuest(questID) or IsQuestBounty(questID) then
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

__SystemEvent__()
function QUEST_REMOVED(questID)
  if IsWorldQuest(questID) or IsQuestBounty(questID) then
    return
  end

  _M:RemoveQuest(questID)
end

function GetBlockUsedForQuest(self, questID)
  local blockUsed = "quest-block"
  if IsDungeonQuest(questID) then
    blockUsed = DUNGEON_QUEST_BLOCK_USED
  elseif IsRaidQuest(questID) then
    blockUsed = RAID_QUEST_BLOCK_USED
  end

  return blockUsed
end

function RemoveQuest(self, questID)
  QUESTS_CACHE[questID] = nil
  QUESTS_WITH_TIMER_CACHE[questID] = nil

  if self:GetBlockUsedForQuest(questID) == "instance-quest-block" then
    _InstanceQuestBlock:RemoveQuest(questID)
    _InstanceQuestBlock.isActive = _InstanceQuestBlock.quests.Count > 0
  else
    _QuestBlock:RemoveQuest(questID)
    _QuestBlock:ResumeIdleCountdown(questID)
    _QuestBlock.isActive = _QuestBlock.quests.Count > 0
  end

  ActionBars:RemoveButton(questID, "quest-items")

  QuestSuperTracking_OnQuestUntracked()
end

function GetQuest(self, questID)
  local blockUsed = self:GetBlockUsedForQuest(questID)
  local quest
  if blockUsed == "quest-block" then
    quest = _QuestBlock:GetQuest(questID)
  elseif blockUsed == "instance-quest-block" then
    quest = _InstanceQuestBlock:GetQuest(questID)
  end

  return quest, blockUsed
end

function MoveQuest(self, quest, fromBlock, toBlock)
  if fromBlock == toBlock then
    return
  end

  if type(quest) == "number" then
    quest = fromBlock:GetQuest(quest)
    if not quest then
      return
    end
  end

  fromBlock:RemoveQuest(quest, false)
  toBlock:AddQuest(quest)
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

  _M:UpdateDistance()
end

__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_ARED" "AREA_POIS_UPDATED"
function QUESTS_ON_MAP_UPDATE()
    QUESTS_UPDATE()

  _M:UpdateDistance()
end

__SystemEvent__ "EKT_QUESTBLOCK_QUEST_ADDED" "EKT_QUESTBLOCK_QUEST_REMOVED"
function UPDATE_BLOCK_VISIBILITY(questID)
  if _QuestBlock then
    _QuestBlock.isActive = _QuestBlock.quests.Count > 0
  end

  if _InstanceQuestBlock then
    _InstanceQuestBlock.isActive = _InstanceQuestBlock.quests.Count > 0
  end
end


function UpdateQuest(self, questID, cache)
  local isLocal = IsQuestOnMap(questID)
  local quest, blockUsed = self:GetQuest(questID)

  if Settings:Get(SHOW_ONLY_QUESTS_IN_ZONE_SETTING) and not isLocal and not blockUsed == "instance-quest-block" then
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

  local title             = GetQuestName(questID)
  local level             = GetQuestDifficultyLevel(questID)
  local header            = self:GetQuestHeader(questID)
  local questLogIndex     = GetQuestLogIndexByID(questID)
  local numObjectives     = GetNumQuestObjectives(questID)
  local isComplete        = IsQuestComplete(questID)
  local isTask            = IsQuestTask(questID)
  local isBounty          = IsQuestBounty(questID)
  local distance          = GetDistanceSqToQuest(questID) or 99999
  local isDungeon         = IsDungeonQuest(questID)
  local isRaid            = IsRaidQuest(questID)
  local requiredMoney     = GetRequiredMoney(questID)
  local suggestedGroup    = GetSuggestedGroupSize(questID)
  local tag               = GetQuestTagInfo(questID)

  local failureTime, timeElapsed = GetTimeAllowed(questID)
  local isOnMap, hasLocalPOI      = IsOnMap(questID)

  if isNew then
    local header = cache and cache.header or self:GetQuestHeader(questID)
    local level  = cache and cache.level or level

    quest.id          = questID
    if tag then 
      quest.tag = tag.tagID 
    end
    quest.header      = header
    quest.level       = level
    quest.name        = title
    quest.isBounty    = isBounty
    quest.isTask      = isTask

    if isLocal and not instanceBlock then
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
    if isLocal and not blockUsed == "instance-quest-block" then
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
    SetSelectedQuest(questID)

    objective.text        = GetQuestLogCompletionText()
    objective.isCompleted = false
  end

  if isNew then
    if blockUsed == "instance-quest-block"then
      if not _InstanceQuestBlock:GetQuest(questID) then
        _InstanceQuestBlock:AddQuest(quest)
      end
    else
      _QuestBlock:AddQuest(quest)
    end

    quest.IsCompletedChanged = function() QuestSuperTracking_OnQuestCompleted() end
  end
end

function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"



  local cache = {}

  for i = 1, numEntries do
    local questInfo = GetInfo(i)

    local questID   = questInfo.questID
    local isHeader  = questInfo.isHeader
    local isHidden  = questInfo.isHidden
    local isBounty  = questInfo.isBounty
    local isTask    = questInfo.isTask

    if not isTask and not _QuestBlock:GetQuest(questID) then
      if isHeader then
        currentHeader = questInfo.title
      elseif not isHeader and not isHidden and IsQuestWatched(questID) then
        QUESTS_CACHE[questID] = true
        QUEST_HEADERS_CACHE[questID] = currentHeader

        cache.level = questInfo.level
        cache.header = currentHeader
        cache.questLogIndex = questInfo.questLogIndex

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
      local data = GetInfo(i)
      if data.isHeader then
        currentHeader = data.title
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

__SystemEvent__()
function EKT_HARD_RELOAD_MODULES()
  -- Force the module to be inactive
  _M._Active = false 

  for questID in pairs(QUESTS_CACHE) do 
    _M:RemoveQuest(questID)
    QUESTS_CACHE[questID] = nil
  end 

  local isActive = GetNumQuestWatches() > 0
  if isActive then 
    _M._Active = true 
    _M:LoadQuests() 
    _M:UpdateDistance()
  end
end
