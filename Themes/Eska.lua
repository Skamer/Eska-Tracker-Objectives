-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
import "EKT"
--============================================================================--
local EskaTheme = Themes:Get("Eska")

if not EskaTheme then return end

-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon & Keystone
EskaTheme:SetElementProperty("block.dungeon.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("block.dungeon.header.text", "text-size", 14)
EskaTheme:SetElementProperty("block.dungeon.header.text", "text-justify-v", "TOP")
EskaTheme:SetElementProperty("block.dungeon.name", "text-size", 12)
EskaTheme:SetElementProperty("block.dungeon.name", "text-font", "PT Sans Caption Bold")
EskaTheme:SetElementProperty("block.dungeon.name", "text-color", { r = 1, g = 0.42, b = 0})
EskaTheme:SetElementProperty("block.dungeon.name", "text-transform", "uppercase")
EskaTheme:SetElementProperty("block.dungeon.name", "text-justify-h", "CENTER")
EskaTheme:SetElementProperty("block.dungeon.icon", "border-color", { r = 0, g = 0, b = 0 })

EskaTheme:SetElementProperty("block.keystone.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("block.keystone.header.text", "text-size", 14)
EskaTheme:SetElementProperty("block.keystone.header.text", "text-justify-v", "TOP")
EskaTheme:SetElementProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("block.keystone.level", "text-size", 14)
EskaTheme:SetElementProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })

-- Scenario
EskaTheme:SetElementProperty("block.scenario.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})

-- Scenario
EskaTheme:SetElementProperty("block.scenario.header.text", "text-size", 14)
EskaTheme:SetElementProperty("block.scenario.header.text", "text-justify-v", "TOP")
EskaTheme:SetElementProperty("block.scenario.name", "text-size", 12)
EskaTheme:SetElementProperty("block.scenario.name", "text-font", "PT Sans Caption Bold")
EskaTheme:SetElementProperty("block.scenario.name", "text-offsetY", -13)
EskaTheme:SetElementProperty("block.scenario.name", "text-color", { r = 1, g = 0.42, b = 0})
EskaTheme:SetElementProperty("block.scenario.name", "text-transform", "uppercase")
EskaTheme:SetElementProperty("block.scenario.name", "text-justify-h", "CENTER")

   -- Stage frame
   EskaTheme:SetElementProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
   EskaTheme:SetElementProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
   -- Stage name
   EskaTheme:SetElementProperty("block.scenario.stage-name", "text-size", 11)
   EskaTheme:SetElementProperty("block.scenario.stage-name", "text-color", { r = 1, g = 1, b = 0 })
   -- Stage counter
   EskaTheme:SetElementProperty("block.scenario.stage-counter", "text-size", 12)
   EskaTheme:SetElementProperty("block.scenario.stage-counter", "text-font", "PT Sans Narrow Bold")
   EskaTheme:SetElementProperty("block.scenario.stage-counter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("quest.*", "text-size", 10)
EskaTheme:SetElementProperty("quest.*", "text-transform", "none")
EskaTheme:SetElementProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
EskaTheme:SetElementProperty("quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
EskaTheme:SetElementProperty("quest.name", "text-justify-h", "CENTER")
-- ========================================================================== --
-- == World Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("world-quest.frame[tracked]", "background-color", { r = 0.22, g = 0, b = 0, a = 0.58})

-- ========================================================================== --
-- == Bonus Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("bonus-quest.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("bonus-quest.*", "text-size", 10)
EskaTheme:SetElementProperty("bonus-quest.*", "text-transform", "none")
EskaTheme:SetElementProperty("bonus-quest.*", "text-color", { r = 1.0, g = 106/255, b = 0})
EskaTheme:SetElementProperty("bonus-quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("bonus-quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("bonus-quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
EskaTheme:SetElementProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
EskaTheme:SetElementProperty("objective.*", "text-size", 13)
EskaTheme:SetElementProperty("objective.*", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("objective.*", "text-transform", "none")
EskaTheme:SetElementProperty("objective.*", "text-location", "LEFT")
EskaTheme:SetElementProperty("objective.*", "text-offsetX", 5)
  -- completed color
  EskaTheme:SetElementProperty("objective.text[completed]", "text-color", { r = 0, g = 1, b = 0})
  EskaTheme:SetElementProperty("objective.square[completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  EskaTheme:SetElementProperty("objective.text[progress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
  EskaTheme:SetElementProperty("objective.square[progress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
  -- faied color
  EskaTheme:SetElementProperty("objective.text[failed]", "text-color", { r = 1, g = 0, b = 0 })
  EskaTheme:SetElementProperty("objective.square[failed]", "background-color", { r = 1, g = 0, b = 0 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
EskaTheme:SetElementProperty("quest-header.name", "text-size", 12)
EskaTheme:SetElementProperty("quest-header.name", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("quest-header.name", "text-color", { r = 1, g = 0.38, b = 0 })
EskaTheme:SetElementProperty("quest-header.name", "text-transform", "uppercase")
EskaTheme:SetElementProperty("quest-header.name", "text-offsetX", 10)
-- ========================================================================== --
-- == Achievement properties
-- ========================================================================== --
EskaTheme:SetElementProperty("achievement.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("achievement.*", "text-size", 10)
EskaTheme:SetElementProperty("achievement.*", "text-transform", "none")
EskaTheme:SetElementProperty("achievement.*", "text-color", { r = 1.0, g = 191/255, b = 0})
EskaTheme:SetElementProperty("achievement.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("achievement.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("achievement.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
EskaTheme:SetElementProperty("achievement.icon", "background-color", { r = 0, g = 0, b = 0})
EskaTheme:SetElementProperty("achievement.description", "text-size", 11)
EskaTheme:SetElementProperty("achievement.description", "text-font", "PT Sans Bold")
EskaTheme:SetElementProperty("achievement.description", "text-color", { r = 1, g = 1, b = 1, a = 1 })
EskaTheme:SetElementProperty("achievement.description", "text-location", "LEFT")
-- change the description color when failed
EskaTheme:SetElementProperty("achievement.description[failed]", "text-color", { r = 1, g = 0, b = 0, a = 1})
