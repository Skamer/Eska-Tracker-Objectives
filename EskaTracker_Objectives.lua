--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                        "EskaTracker.Objectives"                 "1.0.12"
--============================================================================--
import "EKT"
--============================================================================--
Blocks:RegisterCategory(BlockCategory("quests", "Quests", 50, "quests-basic"))
Blocks:RegisterCategory(BlockCategory("dungeon", "Dungeon", 10, "dungeon-basic"))
Blocks:RegisterCategory(BlockCategory("scenario", "Scenario", 5, "scenario-basic"))
Blocks:RegisterCategory(BlockCategory("achievements", "Achievements", 10, "achievements-basic"))
Blocks:RegisterCategory(BlockCategory("world-quests", "World Quests", 15, "world-quests-basic"))
Blocks:RegisterCategory(BlockCategory("bonus-objectives", "Bonus Objectives", 12, "bonus-objectives-basic"))
Blocks:RegisterCategory(BlockCategory("keystone", "Keystone", 5, "keystone-bfa"))


ActionBars:RegisterButtonCategory(ButtonCategory("quest-items", "Quest Items"))

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
