--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                           "EskaTracker.Objectives"                       ""
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
