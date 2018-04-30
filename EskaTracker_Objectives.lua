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


Blocks:RegisterCategory(BlockCategory("eska-quests", "|cff0094FFEska|r Quests", 50, "eska-quests-basic"))
--[[
Blocks:RegisterCategory(BlockCategory("quests", "Quests", 50, "eska-quests"))
Blocks:RegisterCategory(BlockCategory("bonus-objectives", "Bonus objectives", 12, "eska-bonus-objectives"))
Blocks:RegisterCategory(BlockCategory("world-quests", "World quests", 15, "eska-world-quests"))
Blocks:RegisterCategory(BlockCategory("achievements", "Achievements", 10, "eska-achievements"))
Blocks:RegisterCategory(BlockCategory("dungeon", "Dungeon", 10, "eska-dungeon"))
Blocks:RegisterCategory(BlockCategory("keystone", "Keystone", 5, "eska-keystone"))
Blocks:RegisterCategory(BlockCategory("scenario", "Scenario", 10, "eska-scenario"))

--]]
