--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio              "EskaTracker.Objectives.Quests"                          ""
--============================================================================--
namespace                             "EKT"
--============================================================================--
GetNumQuestLogEntries      = GetNumQuestLogEntries
GetQuestLogTitle           = GetQuestLogTitle
GetNumQuestLogEntries      = GetNumQuestLogEntries
GetQuestLogTitle           = GetQuestLogTitle
GetQuestLogIndexByID       = GetQuestLogIndexByID
GetQuestWatchIndex         = GetQuestWatchIndex
GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
GetQuestObjectiveInfo      = GetQuestObjectiveInfo
GetDistanceSqToQuest       = GetDistanceSqToQuest
AddQuestWatch              = AddQuestWatch
SelectQuestLogEntry        = SelectQuestLogEntry
IsWorldQuest               = QuestUtils_IsQuestWorldQuest
IsQuestBounty              = IsQuestBounty
--============================================================================--
QUEST_HEADERS_CACHE = {}
QUESTS_CACHE        = {}

function OnLoad(self)
  -- Register the options
  Options:Register("sort-quests-by-distance", true, "quests/sortingByDistance")
  Options:Register("show-only-quests-in-zone", false, "quests/showOnlyQuestInZone")
  Options:Register("quest-popup-location", "TOP")
  Options:Register("quest-idle-mode-ignore-map-frame", false, "quests/updateAll")

  CallbackHandlers:Register("quests/sortingByDistance", CallbackHandler(function(enabled) if enabled then self:UpdateDistance() end end))
  CallbackHandlers:Register("quests/showOnlyQuestInZone", CallbackHandler(EKT_SHOW_ONLY_QUESTS_IN_ZONE))
  CallbackHandlers:Register("quests/updateAll", CallbackHandler(function()
    for questID in pairs(QUESTS_CACHE) do
      _M:UpdateQuest(questID)
    end
  end))

  if BFASupport.isBFA then
    WorldMapFrame:HookScript("OnHide", function() CallbackHandlers:Call("quests/updateAll") end)
  end
end

-- TODO: Remove this condition when Battle for Azeroth is released.
if BFASupport.isBFA then
  __SecureHook__(WorldMapFrame, "SetMapID")
  function UpdateMapID(worldMapFrame, mapID)
    if not Options:Get("quest-idle-mode-ignore-map-frame") then
      for questID in pairs(QUESTS_CACHE) do
        local quest = _QuestBlock:GetQuest(questID)
        if quest then
          quest.isOnMap = BFASupport:IsQuestOnMap(questID, mapID)
        end
      end
    end
  end
end

__Async__()
function OnEnable(self)
  if not _QuestBlock then
    _QuestBlock = block "quests"
    Wait("QUEST_LOG_UPDATE")
  end

  self:LoadQuests()
  self:UpdateDistance()
  EKT_SHOW_ONLY_QUESTS_IN_ZONE()
  UPDATE_BLOCK_VISIBILITY()

  -- [FIX] Super track the closest quest for the players having not the blizzad objective quest.
  QuestSuperTracking_ChooseClosestQuest()
end

function OnDisable(self)
  if _QuestBlock then
    _QuestBlock.isActive = false
  end
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


__SystemEvent__  "EKT_QUESTBLOCK_QUEST_ADDED" "EKT_QUESTBLOCK_QUEST_REMOVED"
function UPDATE_BLOCK_VISIBILITY(quest)
  if _QuestBlock then
    _QuestBlock.isActive = _QuestBlock.quests.Count > 0
  end
end


__SystemEvent__ "QUEST_LOG_UPDATE" "ZONE_CHANGED" "EKT_SHOW_ONLY_QUESTS_IN_ZONE"
function QUESTS_UPDATE(...)
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end

  _M:RefreshPopups()
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  QuestSuperTracking_OnPOIUpdate()
end

do
  local alreadyHooked = false
  local needUpdate = false

  function RunQuestLogUpdate()
    if Options:Get("show-only-quests-in-zone") then
      QUESTS_UPDATE()
      needUpdate = false
    end
  end

  __SystemEvent__()
  function ZONE_CHANGED()
    -- @NOTE This seems that GetQuestWorldMapAreaID() uses SetMapToCurrentZone so we
    -- need to wait the WorldMapFrame is hidden to continue
    if Options:Get("show-only-quests-in-zone") then
      if WorldMapFrame:IsShown() then
        needUpdate = true
      else
        QUESTS_UPDATE()
      end
    end
  end

  __SystemEvent__()
  function EKT_SHOW_ONLY_QUESTS_IN_ZONE()
    if Options:Get("show-only-quests-in-zone") then
      if not alreadyHooked then
        WorldMapFrame:HookScript("OnHide", RunQuestLogUpdate)
        alreadyHooked = true
      end

      if WorldMapFrame:IsShown() then
        needUpdate = true
        return
      end
    end

    QUESTS_UPDATE()
  end
end

__Async__()
__SystemEvent__()
function QUEST_ACCEPTED(index, questID)
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  -- @HACK : Set a little delay to get a valid quest item
  Delay(0.1)

  -- Add it in the quest watched
  AddQuestWatch(index)

  QuestSuperTracking_OnQuestTracked(questID)
end

__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then
    return
  end

  _M:RefreshPopups()

  -- @NOTE: World Quest Group Finder addon adds the world quests as watched when you joins.
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  if isAdded then
    QUESTS_CACHE[questID] = true
    _M:UpdateQuest(questID)
  else
    QUESTS_CACHE[questID] = nil
    _QuestBlock:RemoveQuest(questID)
    ActionBars:RemoveButton(questID, "quest-items")

    QuestSuperTracking_OnQuestUntracked()
  end

  -- Wake up the tracker (idle mode feature)
  _QuestBlock:WakeUp()
end

function ShowPopup(self, questID, popupType)
  local notification = Notifications():Get(questID)
  if not notification then
    local questName = GetQuestLogTitle(GetQuestLogIndexByID(questID))
    notification = QuestPopupNotification()
    notification.type       = popupType
    notification.questID    = questID
    notification.questName  = questName
    notification.id         = questID
    Notifications():Add(notification)
  else
    if notification.questName == "" then
      notification.questName = GetQuestLogTitle(GetQuestLogIndexByID(questID))
    end
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

function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"

  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if not isTask and not _QuestBlock:GetQuest(questID) then
      if isHeader then
        currentHeader = title
      elseif not isHeader and not isHidden and IsQuestWatched(i) then
        QUESTS_CACHE[questID] = true
        self:UpdateQuest(questID)
      end
    end
  end
end


function UpdateQuest(self, questID)
  local questLogIndex = GetQuestLogIndexByID(questID)
  local questWatchIndex = GetQuestWatchIndex(questLogIndex)

  if not questWatchIndex then
    Trace("questWatchIndex is nil")
    return
  end

  local qID, title, questLogIndex, numObjectives, requiredMoney,
  isComplete, startEvent, isAutoComplete, failureTime, timeElapsed,
  questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex)
  -- #######################################################################
  -- Is the player wants the quests are filered by zone ?
  if Options:Get("show-only-quests-in-zone") then

    -- @NOTE This seems that GetQuestWorldMapAreaID() uses SetMapToCurrentZone so we
    -- need to wait the WorldMapFrame is hidden to continue
    if WorldMapFrame:IsShown() then
      return
    end

    local isLocal
    -- TODO Change that when Battle for Azeroth is released
    if BFASupport.isBFA then
      isLocal = BFASupport:IsQuestOnMap(questID)
    else
      local mapID = GetQuestWorldMapAreaID(questID)
      local currentMapID = GetCurrentMapAreaID()
      isLocal = (((mapID ~= 0) and mapID == currentMapID) or (mapID == 0 and isOnMap))
    end

    if not isLocal then
      _QuestBlock:RemoveQuest(questID)
      return
    end
  end
  -- #######################################################################

  local quest = _QuestBlock:GetQuest(questID)
  local isNew = false
  if not quest then
    quest = ObjectManager:Get(Quest)
    isNew = true
  end

  quest.id              = questID
  quest.name            = title
  quest.header          = _M:GetQuestHeader(questID)
  quest.level           = select(2, GetQuestLogTitle(questLogIndex))
  quest.isTask          = isTask
  quest.isBounty        = isBounty
  quest.isCompleted     = isComplete
  if BFASupport.isBFA then
    if WorldMapFrame:IsShown() and not Options:Get("quest-idle-mode-ignore-map-frame") then
      quest.isOnMap = BFASupport:IsQuestOnMap(questID, WorldMapFrame:GetMapID())
    else
      quest.isOnMap = BFASupport:IsQuestOnMap(questID)
    end
  else
    quest.isOnMap = isOnMap
  end

  -- is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
  if itemLink and itemTexture then
    local itemQuest = quest:GetQuestItem()
    itemQuest.link = itemLink
    itemQuest.texture = itemTexture

    if not ActionBars:HasButton(questID, "quest-items") then
      local itemButton = ObjectManager:Get(ItemButton)
      itemButton.id       = questID
      itemButton.link     = itemLink
      itemButton.texture  = itemTexture
      itemButton.category = "quest-items"
      ActionBars:AddButton(itemButton)
    end
  end


  -- Update the objective
  if numObjectives > 0 then
    quest.numObjectives = numObjectives
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(quest.id, index, false)
      local objective = quest:GetObjective(index)

      objective.text = text
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
    end
  else
    quest.numObjectives = 1
    local objective = quest:GetObjective(1)
    SelectQuestLogEntry(questLogIndex)

    objective.text = GetQuestLogCompletionText()
    objective.isCompleted = false
  end

  if isNew then
    _QuestBlock:AddQuest(quest)
    quest.IsCompletedChanged = function() QuestSuperTracking_OnQuestCompleted() end
  end
end


do
  local function IsLegionAssaultQuest(questID)
    return (questID == 45812) -- Assault on Val'sharah
        or (questID == 45838) -- Assault on Azsuna
        or (questID == 45840) -- Assault on Highmountain
        or (questID == 45839) -- Assault on StormHeim
        or (questID == 45406) -- StomHeim : The Storm's Fury
        or (questID == 46110) -- StomHeim : Battle for Stormheim
  end


  __Async__()
  function UpdateDistance()
    while Options:Get("sort-quests-by-distance") do
      for index, quest in _QuestBlock.quests:GetIterator() do
        -- If the quest is a legion assault, set it in first.
        if IsLegionAssaultQuest(quest.id) then
            quest.distance = 0
        else
            local questLogIndex = GetQuestLogIndexByID(quest.id)
            local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)

            quest.distance = distanceSq and math.sqrt(distanceSq) or nil
        end
      end
      Delay(1) -- @TODO Create an option to change the refresh rate.
    end
  end
end

debugQuest = nil
__SlashCmd__ "qdebug"
function DebugNewQuest(self)
  if not debugQuest then
    debugQuest = ObjectManager:Get(Quest)
    debugQuest.level = 100
    debugQuest.name  = "Debug Quest #1"
    debugQuest.header = "Debug"
    _QuestBlock:AddQuest(debugQuest)
  end
end

__SlashCmd__ "odebug"
function DebugNewObjective(completed)
  if debugQuest then
    debugQuest.numObjectives = debugQuest.numObjectives + 1
    local objective = debugQuest:GetObjective(debugQuest.numObjectives)
    objective.text = "Debug Objective #" .. debugQuest.numObjectives
    objective.isCompleted = completed

    debugQuest:WakeUp(true)
  end
end

__SlashCmd__ "wodebug"
function DebugWakeUpObjective(index)
  if debugQuest then
    local obj = debugQuest:GetObjective(tonumber(index))
    if obj then
      obj:WakeUp()
    end
  end
end

__SlashCmd__ "idletest"
function DebugIdleTest()
  DebugNewQuest()
  DebugNewObjective()
  DebugNewObjective(true)
  DebugNewObjective()
end
