--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio         "EskaTracker.Objectives.GroupFinders"                         ""
--============================================================================--
namespace                     "EKT"
--============================================================================--
RemoveListing           = C_LFGList.RemoveListing
CreateListing           = C_LFGList.CreateListing
GetActivityIDForQuestID = C_LFGList.GetActivityIDForQuestID
--============================================================================--
GROUP_FINDER_ADDON_SELECTED_OPTION = "group-finder-addon-selected"
--============================================================================--
class "GroupFinderAddon" (function(_ENV)
  _Addons = {}
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  function JoinGroup(self, questID)
    Debug("Join group for the quest %i", questID)
  end

  __Arguments__ {}
  function LeaveGroup(self)
    Debug("Leave group for the quest")
    if IsInGroup() then
      LeaveParty()
    end
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    Debug("Create group for the quest #%i", questID)
  end

  __Arguments__ {}
  function DelistGroup()
    Debug("Delist the group")
    RemoveListing()
  end

  __Static__()
  function Register(self, name, addon)
    _Addons[name] = addon
  end

  __Static__()
  function Get(self, name)
    return _Addons[name]
  end

  __Static__() __Arguments__ { ClassType }
  function GetIterator()
    return pairs(_Addons)
  end

  __Static__() __Arguments__ { ClassType }
  function GetSelected(self)
    local selected = Settings:Get(GROUP_FINDER_ADDON_SELECTED_OPTION)
    local firstName   = ""
    local firstObject
    for name, groupFinder in self:GetIterator() do
      firstObject = groupFinder
      firstName   = name
      if name == selected then
        return groupFinder, name
      end
    end

    return firstObject, firstName
  end

  __Arguments__ { ClassType, String }
  __Static__() function SetSelected(self, addonName)
    Settings:Set(GROUP_FINDER_ADDON_SELECTED_OPTION, addonName)
  end
end)

--------------------------------------------------------------------------------
--                         Extend the API                                     --
--------------------------------------------------------------------------------
__Final__()
interface "GroupFinder" (function(_ENV)

  -- Create a group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function CreateGroup(self, id)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:CreateGroup(id)
    end
  end

  -- Leave the group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function LeaveGroup(self)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:LeaveGroup()
    end
  end

  -- Join a group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function JoinGroup(self, id)
    local addon, name = GroupFinderAddon:GetSelected()
    if addon then
      addon:JoinGroup(id)
    end
  end

  -- Delist the group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function DelistGroup(self)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:DelistGroup()
    end
  end

end)
--============================================================================--
--                      World Quest Group Finder
--        https://mods.curse.com/addons/wow/worldquestgroupfinder
--============================================================================--
class "WorldQuestGroupFinderAddon" (function(_ENV)
  inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    super.JoinGroup(self, questID)

    WorldQuestGroupFinder.InitSearchProcess(questID, false, false, true)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    super.CreateGroup(self, questID)

    WorldQuestGroupFinder.CreateGroup(questID)
  end
end)
--============================================================================--
--                      World Quest Assistant
--        https://mods.curse.com/addons/wow/266373-worldquestassistant
--============================================================================--
class "WorldQuestAssistantAddon" (function(_ENV)
  inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    WQA:FindQuestGroups(questID)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    WQA:CreateQuestGroup(questID)
  end

  __Arguments__ { Number }
  function LeaveGroup()
    WQA:MaybeLeaveParty()
  end
end)
--============================================================================--
--                      World Quest Tracker
--        https://mods.curse.com/addons/wow/266373-worldquestassistant
--============================================================================--
class "WorldQuestTrackerAddon" (function(_ENV)
  inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    _G["WorldQuestTrackerAddon"].FindGroupForQuest(questID)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    super.JoinGroup(self, questID)
    -- @NOTE World Quest Tracker addon doesn't provide a function could be called to create the group
    -- I put here the local function content.
    local questName
    local rarity

    if QuestUtils_IsQuestWorldQuest(questID) then
      questName  = C_TaskQuest.GetQuestInfoByQuestID(questID)
      rarity = select(4, GetQuestTagInfo(questID))
    else
      questName = GetQuestLogTitle(GetQuestLogIndexByID(questID))
    end

    local pvpType = GetZonePVPInfo()
    local pvpTag
    if (pvpType == "contested") then
      pvpTag = "@PVP"
    else
      pvpTag = ""
    end

    local groupDesc = "Doing world quest " .. questName .. ". Group created with World Quest Tracker. @ID" .. questID .. pvpTag

    local itemLevelRequired = 0
    local honorLevelRequired = 0
    local isAutoAccept = true
    local isPrivate = false

    CreateListing(GetActivityIDForQuestID(questID) or 469, "", itemLevelRequired, honorLevelRequired, "", groupDesc, isAutoAccept, isPrivate, questID)

    --> if is an epic quest, converto to raid
    if rarity and rarity == LE_WORLD_QUEST_QUALITY_EPIC then
      C_Timer.After (2, function() ConvertToRaid(); end) --print ("party converted")
    end

  end
end)
--------------------------------------------------------------------------------
--  Register the group finder addons when they are loaded                     --
--------------------------------------------------------------------------------
__Async__()
function RegisterWorldQuestGroupFinder(self)
  while NextEvent("ADDON_LOADED") ~= "WorldQuestGroupFinder" do end
  GroupFinderAddon:Register("WorldQuestGroupFinder", WorldQuestGroupFinderAddon())
end

__Async__()
function RegisterWorldQuestAssistant(self)
  while NextEvent("ADDON_LOADED") ~= "WorldQuestAssistant" do end
  GroupFinderAddon:Register("WorldQuestAssistant", WorldQuestAssistantAddon())
end

__Async__()
function RegisterWorldQuestTracker(self)
  while NextEvent("ADDON_LOADED") ~= "WorldQuestTracker" do end
  GroupFinderAddon:Register("WorldQuestTracker", WorldQuestTrackerAddon())
end

RegisterWorldQuestGroupFinder()
RegisterWorldQuestAssistant()
RegisterWorldQuestTracker()
--------------------------------------------------------------------------------
--  Create the group finder actions                                           --
--------------------------------------------------------------------------------
__Action__ "group-finder-create-group" "Create a group"
class "GroupFinderCreateGroupAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    GroupFinder:CreateGroup(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    GroupFinderCreateGroupAction.Exec(quest.id)
  end
end)

__Action__ "group-finder-join-group" "Join a group"
class "GroupFinderJoinGroupAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    GroupFinder:JoinGroup(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    GroupFinderJoinGroupAction.Exec(quest.id)
  end
end)
