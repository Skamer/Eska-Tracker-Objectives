--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                        "EskaTracker.Objectives"                  "1.0.0"
--============================================================================--
import "EKT"
--============================================================================--


function OnEnable(self)

end


Blocks:RegisterCategory(BlockCategory("quests", "Quests", 50, "quests-basic"))
Blocks:RegisterCategory(BlockCategory("dungeon", "Dungeon", 10, "dungeon-basic"))
Blocks:RegisterCategory(BlockCategory("scenario", "Scenario", 5, "scenario-basic"))
Blocks:RegisterCategory(BlockCategory("achievements", "Achievements", 10, "achievements-basic"))
Blocks:RegisterCategory(BlockCategory("world-quests", "World Quests", 15, "world-quests-basic"))
--[[
Blocks:RegisterCategory(BlockCategory("quests", "Quests", 50, "eska-quests"))
Blocks:RegisterCategory(BlockCategory("bonus-objectives", "Bonus objectives", 12, "eska-bonus-objectives"))
Blocks:RegisterCategory(BlockCategory("world-quests", "World quests", 15, "eska-world-quests"))
Blocks:RegisterCategory(BlockCategory("achievements", "Achievements", 10, "eska-achievements"))
Blocks:RegisterCategory(BlockCategory("dungeon", "Dungeon", 10, "eska-dungeon"))
Blocks:RegisterCategory(BlockCategory("keystone", "Keystone", 5, "eska-keystone"))
Blocks:RegisterCategory(BlockCategory("scenario", "Scenario", 10, "eska-scenario"))

--]]


-- @NOTE Transform the two hooks to event for the World quest module. Remove it when the __EnableOnHook_ is implememented.
__SecureHook__()
function BonusObjectiveTracker_TrackWorldQuest(questID, hardWatch)
  if Options:Get("show-tracked-world-quests") then
    Scorpio.FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, true, hardWatch)
  end
end

__SecureHook__()
function BonusObjectiveTracker_UntrackWorldQuest(questID)
  if Options:Get("show-tracked-world-quests") then
    Scorpio.FireSystemEvent("EKT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, false)
  end
end
