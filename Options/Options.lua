--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio           "EskaTracker.Objectives.Options"                            ""
--============================================================================--
import                    "EKT"
--============================================================================--
_DEFAULT_SKIN_TEXT_FLAGS = Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE + Theme.SkinFlags.TEXT_COLOR + Theme.SkinFlags.TEXT_TRANSFORM


function OnLoad(self)
  self:AddObjectiveRecipes()
  self:AddQuestRecipes()
end


--------------------------------------------------------------------------------
--                         Objective                                          --
--------------------------------------------------------------------------------
function AddObjectiveRecipes(self)
  -- Create the objective tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("objective"):SetText("Objective"):SetBuildingGroup("objective/children"), "RootTree")
  -- Create the objective tabs
  OptionBuilder:AddRecipe(TabRecipe():SetBuildingGroup("objective/tabs"), "objective/children")
  -- Create the differents tabs
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("General"):SetID("general"):SetBuildingGroup("objective/general"), "objective/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Square"):SetID("square"):SetBuildingGroup("objective/square"), "objective/tabs")

  -- Create the states
  OptionBuilder:AddRecipe(StateSelectRecipe()
  :SetBuildingGroup("objective/general/states")
  :AddState("progress")
  :AddState("completed")
  :AddState("failed"), "objective/general")
  OptionBuilder:AddRecipe(StateSelectRecipe()
  :SetBuildingGroup("objective/square/states")
  :AddState("progress")
  :AddState("completed")
  :AddState("failed"), "objective/square")


  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("objective.frame"), "objective/general/states")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("objective.text")
  :ClearFlags()
  :AddFlag(Theme.SkinFlags.TEXT_SIZE)
  :AddFlag(Theme.SkinFlags.TEXT_COLOR)
  :AddFlag(Theme.SkinFlags.TEXT_FONT)
  :AddFlag(Theme.SkinFlags.TEXT_TRANSFORM)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "objective/general/states")

  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("objective.square"), "objective/square/states")
end
--------------------------------------------------------------------------------
--                             Quest                                          --
--------------------------------------------------------------------------------
function AddQuestRecipes(self)
  -- Create the quest tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("quest"):SetText("Quest"):SetBuildingGroup("quest/children"), "RootTree")
  -- Create the quest tabs
  OptionBuilder:AddRecipe(TabRecipe():SetBuildingGroup("quest/tabs"), "quest/children")
  -- Create the differents tabs
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("General"):SetID("general"):SetBuildingGroup("quest/general"), "quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Header"):SetID("header"):SetBuildingGroup("quest/header"), "quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("quest/name"), "quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Level"):SetID("level"):SetBuildingGroup("quest/level"), "quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Category"):SetID("category"):SetBuildingGroup("quest/category"), "quest/tabs")

  -- General Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("quest.frame"), "quest/general")

  -- Header tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("quest.header"), "quest/header")

  -- Name tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("quest.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "quest/name")

  -- level tab
  local showQuestLevelRecipe = CheckBoxRecipe()
  showQuestLevelRecipe:SetText("Show")
  showQuestLevelRecipe:BindOption("show-quest-level")
  OptionBuilder:AddRecipe(showQuestLevelRecipe, "quest/level")

  local useDifficultyForLevelRecipe = CheckBoxRecipe()
  useDifficultyForLevelRecipe:SetText("Use difficulty color")
  useDifficultyForLevelRecipe:BindOption("color-quest-level-by-difficulty")
  OptionBuilder:AddRecipe(useDifficultyForLevelRecipe, "quest/level")

  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("quest.level")
  :ClearFlags()
  :AddFlag(Theme.SkinFlags.TEXT_FONT)
  :AddFlag(Theme.SkinFlags.TEXT_COLOR)
  :AddFlag(Theme.SkinFlags.TEXT_SIZE), "quest/level")

  -- Category tab
  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Enable"):BindOption("quest-categories-enabled"), "quest/category")
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("quest-header.frame"), "quest/category")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("quest-header.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "quest/category")

end
