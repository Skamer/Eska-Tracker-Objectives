--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio              "EskaTracker.Objectives.Quests"                          ""
--============================================================================--
import                             "EKT"
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


end

__Async__()
function OnEnable(self)
  if not _QuestBlock then
    _QuestBlock = block "eska-quests"
  end

  self:LoadQuests()

  -- [FIX] Super track the closest quest for the players having not the blizzad objective quest.
  QuestSuperTracking_ChooseClosestQuest()
end

function OnDisable(self)
  if _QuestBlock then
    _QuestBlock.isActive = false
  end
end


__SystemEvent__ "QUEST_LOG_UPDATE" "ZONE_CHANGED" "EQT_SHOW_ONLY_QUESTS_IN_ZONE"
function QUESTS_UPDATE(...)
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_POI_UPDATE()
  QuestSuperTracking_OnPOIUpdate()
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

  -- @NOTE: World Quest Group Finder addon adds the world quests as watched when you joins.
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  if isAdded then
    QUESTS_CACHE[questID] = true
    _M:UpdateQuest(questID)
  else
    QUESTS_CACHE[questID] = nil
    _QuestBlock:RemoveQuest(questID)
    QuestSuperTracking_OnQuestUntracked()
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

  local qID, title, questLogIndex, numObjectives, requiredMoney,
  isComplete, startEvent, isAutoComplete, failureTime, timeElapsed,
  questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex)

  -- #######################################################################
  -- Is the player wants the quests are filered by zone ?
  --- --> Make stuffs here
  -- #######################################################################

  local quest = _QuestBlock:GetQuest(questID)
  local isNew = false
  if not quest then
    quest = ObjectManager:Get(Quest)
    isNew = true
  end

  quest.id          = questID
  quest.name        = title
  quest.header      = _M:GetQuestHeader(questID)
  quest.level       = select(2, GetQuestLogTitle(questLogIndex))
  quest.isOnMap     = isOnMap
  quest.isTask      = isTask
  quest.isBounty    = isBounty
  quest.isCompleted = isComplete


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







--[[
function OnLoad(self)
  print("BLOCK", BLOCK)
end

[module:RegisterBlockCategories("quests", "blocks")


function ReloadBlocks(...)

end

function ReloadBlocks(self)
  _QuestBlock = nil
  self:OnEnable()
end

function OnBlocksChange(self)
  _QuestBlock = nil
  self:OnEnable()
end

__BlocksReloader__ "quests"
function OnBlocksChange(self)

end

function OnEnable(self)
  if not _QuestBlock then
    --_QuestBlock = BLOCK("quests")
    _QuestBlock = block "quests"
  end


  --local quest = _ObjectManager:Get(Quest)
  --quest.id = 25030
  --quest.name = "First Quest Name"
  --quest.category = "Misc"
  --print(quest, System.Reflector.GetObjectClass(quest))
  --_QuestBlock:AddQuest(quest)

  local name = "Quest #"
  for i = 1, 10 do
    local quest = ObjectManager:Get(Quest)
    quest.id = i
    quest.name = name..i
    quest.category = "Misc"
    _QuestBlock:AddQuest(quest)

    quest.numObjectives = 2

    for i = 1,  quest.numObjectives do
      local obj = quest:GetObjective(i)
      obj.text = "Objective text #".. i
    end
  end
end

function OnDisable(self)

end
--]]
