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
  self:AddGroupFinderRecipes()
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
  local function GetQuestActions()
        return {
        ["none"]  = "|cffff0000None|r",
        ["show-quest-details"] = "Show quest details",
        ["show-quest-details-with-map"] = "Open the map and show details",
        ["link-quest-to-chat"] = "Link quest to chat",
        ["abandon-quest"]      = "Abandon the quest",
        ["toggle-context-menu"] = "Toggle context menu",
        ["group-finder-create-group"] = "Create a group",
        ["group-finder-join-group"] = "Join a group",
        ["stop-super-tracking-quest"] = "Stop supertracking the quest",
        ["super-track-quest"] = "Supertrack the quest"
      }
  end

  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("quest.header"):SetOrder(10), "quest/header")
  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Left click Action"):SetOrder(20), "quest/header")
  OptionBuilder:AddRecipe(SelectRecipe():SetWidth(0.5):BindOption("quest-left-click-action"):SetList(GetQuestActions):SetText("Select an action"):SetOrder(21), "quest/header")

  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Middle click Action"):SetOrder(30), "quest/header")
  OptionBuilder:AddRecipe(SelectRecipe():SetWidth(0.5):BindOption("quest-middle-click-action"):SetList(GetQuestActions):SetText("Select an action"):SetOrder(31), "quest/header")

  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Right click Action"):SetOrder(40), "quest/header")
  OptionBuilder:AddRecipe(SelectRecipe():SetWidth(0.5):BindOption("quest-right-click-action"):SetList(GetQuestActions):SetText("Select an action"):SetOrder(41), "quest/header")

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

--------------------------------------------------------------------------------
--                          GroupFinder Addons                                --
--------------------------------------------------------------------------------
function AddGroupFinderRecipes(self)
  -- Create the quest tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("group-finder"):SetText("Group Finder"):SetBuildingGroup("group-finder/children"), "RootTree")

  local function GetGroupFinders()
    local list = {}
    for name in GroupFinderAddon:GetIterator() do
      list[name] = name
    end
    return list
  end

  local selectGFA = SelectRecipe()
  selectGFA:SetText("Select the groupfinder addon to use")
  selectGFA:SetList(GetGroupFinders)
  selectGFA:Get(function() return select(2,GroupFinderAddon:GetSelected()) end)
  selectGFA:Set(function(_, value) GroupFinderAddon:SetSelected(value) end)
  OptionBuilder:AddRecipe(selectGFA, "group-finder/children")
end
