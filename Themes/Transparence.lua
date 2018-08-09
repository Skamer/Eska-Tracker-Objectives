-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
import "EKT"
--============================================================================--
local TransparenceTheme = Themes:Get("Transparence")

if not TransparenceTheme then return end

-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon
TransparenceTheme:SetElementProperty("block.dungeon.frame", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.dungeon.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetElementProperty("block.dungeon.header.text", "text-size", 14)
TransparenceTheme:SetElementProperty("block.dungeon.header.text", "text-justify-v", "TOP")
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-size", 12)
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-transform", "uppercase")
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-justify-h", "CENTER")
-- Keystone
TransparenceTheme:SetElementProperty("block.keystone.frame", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.keystone.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetElementProperty("block.keystone.header.text", "text-size", 14)
TransparenceTheme:SetElementProperty("block.keystone.header.text", "text-justify-v", "TOP")
TransparenceTheme:SetElementProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("block.keystone.level", "text-size", 14)
TransparenceTheme:SetElementProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })
TransparenceTheme:SetElementProperty("block.keystone.timer", "text-font", "PT Sans Narrow")
TransparenceTheme:SetElementProperty("block.keystone.timer", "text-size", 22)
TransparenceTheme:SetElementProperty("block.keystone.timer", "text-justify-h", "CENTER")
TransparenceTheme:SetElementProperty("block.keystone.timeLimit2Key", "text-font", "PT Sans Narrow")
TransparenceTheme:SetElementProperty("block.keystone.timeLimit2Key", "text-size", 14)
TransparenceTheme:SetElementProperty("block.keystone.timeLimit3Key", "text-font", "PT Sans Narrow")
TransparenceTheme:SetElementProperty("block.keystone.timeLimit3Key", "text-size", 14)

-- Scenario
TransparenceTheme:SetElementProperty("block.scenario.frame", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.scenario.header.text", "text-size", 14)
TransparenceTheme:SetElementProperty("block.scenario.header.text", "text-justify-v", "TOP")
TransparenceTheme:SetElementProperty("block.scenario.name", "text-size", 12)
TransparenceTheme:SetElementProperty("block.scenario.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetElementProperty("block.scenario.name", "text-offsetY", -13)
TransparenceTheme:SetElementProperty("block.scenario.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetElementProperty("block.scenario.name", "text-transform", "uppercase")
  -- Stage frame
  TransparenceTheme:SetElementProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
  TransparenceTheme:SetElementProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
  -- Stage name
  TransparenceTheme:SetElementProperty("block.scenario.stage-name", "text-size", 11)
  TransparenceTheme:SetElementProperty("block.scenario.stage-name", "text-color", { r = 1, g = 1, b = 0 })
  -- Stage counter
  TransparenceTheme:SetElementProperty("block.scenario.stage-counter", "text-size", 12)
  TransparenceTheme:SetElementProperty("block.scenario.stage-counter", "text-font", "PT Sans Narrow Bold")
  TransparenceTheme:SetElementProperty("block.scenario.stage-counter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("quest.*", "text-size", 10)
TransparenceTheme:SetElementProperty("quest.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
TransparenceTheme:SetElementProperty("quest.name", "text-justify-h", "CENTER")
-- ========================================================================== --
-- == World Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("world-quest.frame[tracked]", "background-color", { r = 0.93, g = 0, b = 0.1, a = 0.13})
-- ========================================================================== --
-- == Bonus Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("bonus-quest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("bonus-quest.*", "text-size", 10)
TransparenceTheme:SetElementProperty("bonus-quest.*", "text-transform", "none")
-- TransparenceTheme:SetElementProperty("bonusQuest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("bonus-quest.*", "text-color", { r = 1.0, g = 106/255, b = 0})
TransparenceTheme:SetElementProperty("bonus-quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("bonus-quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("bonus-quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
TransparenceTheme:SetElementProperty("objective.*", "text-size", 13)
TransparenceTheme:SetElementProperty("objective.*", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("objective.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("objective.*", "text-location", "LEFT")
TransparenceTheme:SetElementProperty("objective.*", "text-offsetX", 5)
  -- completed color
  TransparenceTheme:SetElementProperty("objective.text[completed]", "text-color", { r = 0, g = 1, b = 0})
  TransparenceTheme:SetElementProperty("objective.square[completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  TransparenceTheme:SetElementProperty("objective.text[progress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
  TransparenceTheme:SetElementProperty("objective.square[progress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
  -- failed color
  TransparenceTheme:SetElementProperty("objective.text[failed]", "text-color", { r = 1, g = 0, b = 0 })
  TransparenceTheme:SetElementProperty("objective.square[failed]", "background-color", { r = 1, g = 0, b = 0 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("quest-header.name", "text-size", 12)
TransparenceTheme:SetElementProperty("quest-header.name", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("quest-header.name", "text-color", { r = 1, g = 0.38, b = 0 })
TransparenceTheme:SetElementProperty("quest-header.name", "text-transform", "uppercase")
TransparenceTheme:SetElementProperty("quest-header.name", "text-offsetX", 10)
-- ========================================================================== --
-- == Achievement properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("achievement.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("achievement.*", "text-size", 10)
TransparenceTheme:SetElementProperty("achievement.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("achievement.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("achievement.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("achievement.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("achievement.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
TransparenceTheme:SetElementProperty("achievement.icon", "background-color", { r = 1, g = 233/255, b = 127/255})
TransparenceTheme:SetElementProperty("achievement.description", "text-size", 11)
TransparenceTheme:SetElementProperty("achievement.description", "text-font", "PT Sans Bold")
TransparenceTheme:SetElementProperty("achievement.description", "text-color", { r = 1, g = 1, b = 1, a = 1 })
TransparenceTheme:SetElementProperty("achievement.description", "text-location", "LEFT")
-- change the description color when failed
TransparenceTheme:SetElementProperty("achievement.description[failed]", "text-color", { r = 1, g = 0, b = 0, a = 1})
