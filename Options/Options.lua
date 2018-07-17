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
  self:AddWorldQuestRecipes()
  self:AddBonusQuestRecipes()
  self:AddAchievementRecipes()
  self:AddDungeonRecipes()
  self:AddKeystoneRecipes()
  self:AddQuestBlockRecipes()
  self:AddScenarioRecipes()
  self:AddGroupFinderRecipes()
end


--------------------------------------------------------------------------------
--                         Objective                                          --
--------------------------------------------------------------------------------
function AddObjectiveRecipes(self)
  -- Create the objective tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("objective"):SetText("Objective"):SetBuildingGroup("objective/children"):SetOrder(110), "RootTree")
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
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("quest"):SetText("Quest"):SetBuildingGroup("quest/children"):SetOrder(120), "RootTree")
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
--                             World Quest                                    --
--------------------------------------------------------------------------------
function AddWorldQuestRecipes(self)
  -- Create the world quest tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("world-quest"):SetText("World Quest"):SetPath("quest"):SetBuildingGroup("world-quest/children"), "RootTree")
  -- Create the  world quest tabs
  OptionBuilder:AddRecipe(TabRecipe():SetBuildingGroup("world-quest/tabs"):SetSaveChoiceVariable("worldquest_tab_selected"), "world-quest/children")
  -- Create the differents tabs
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("General"):SetID("general"):SetBuildingGroup("world-quest/general"), "world-quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Header"):SetID("header"):SetBuildingGroup("world-quest/header"), "world-quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("world-quest/name"), "world-quest/tabs")
  -- Create the state select
  local stateSelect = StateSelectRecipe()
  stateSelect:SetBuildingGroup("world-quest/:worldquest_tab_selected:/states")
  stateSelect:AddState("tracked")
  stateSelect:SetOrder(200)
  OptionBuilder:AddRecipe(stateSelect, "world-quest/general")
  OptionBuilder:AddRecipe(stateSelect, "world-quest/header")
  OptionBuilder:AddRecipe(stateSelect, "world-quest/name")

  -- General Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("world-quest.frame"):SetElementParentID("quest.frame"), "world-quest/general/states")

  -- Header Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("world-quest.header"):SetElementParentID("quest.header"), "world-quest/header/states")

  -- Name Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("world-quest.name")
  :SetElementParentID("quest.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "world-quest/name/states")
end

--------------------------------------------------------------------------------
--                             Bonus Quest                                    --
--------------------------------------------------------------------------------
function AddBonusQuestRecipes(self)
  -- Create the bonus quest tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("bonus-quest"):SetText("Bonus Quest"):SetPath("quest"):SetBuildingGroup("bonus-quest/children"), "RootTree")
  -- Create the  world quest tabs
  OptionBuilder:AddRecipe(TabRecipe():SetBuildingGroup("bonus-quest/tabs"):SetSaveChoiceVariable("bonusquest_tab_selected"), "bonus-quest/children")
  -- Create the differents tabs
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("General"):SetID("general"):SetBuildingGroup("bonus-quest/general"), "bonus-quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Header"):SetID("header"):SetBuildingGroup("bonus-quest/header"), "bonus-quest/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("bonus-quest/name"), "bonus-quest/tabs")

  -- General Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("bonus-quest.frame"):SetElementParentID("quest.frame"), "bonus-quest/general")

  -- Header Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("bonus-quest.header"):SetElementParentID("quest.header"), "bonus-quest/header")

  -- Name Tab
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("bonus-quest.name")
  :SetElementParentID("quest.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "bonus-quest/name")
end
--------------------------------------------------------------------------------
--                                 Achievement                                --
--------------------------------------------------------------------------------
function AddAchievementRecipes(self)
  -- Create the achievement tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("achievement"):SetText("Achievement"):SetBuildingGroup("achievement/children"):SetOrder(130), "RootTree")

  -- Create the Achievement tabs
  OptionBuilder:AddRecipe(TabRecipe():SetBuildingGroup("achievement/tabs"):SetSaveChoiceVariable("achievement_tab_selected"), "achievement/children")
  -- Create the differents tabs
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("General"):SetID("general"):SetBuildingGroup("achievement/general"):SetOrder(10), "achievement/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Header"):SetID("header"):SetBuildingGroup("achievement/header"):SetOrder(20), "achievement/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("achievement/name"):SetOrder(30), "achievement/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Description"):SetID("description"):SetBuildingGroup("achievement/description"):SetOrder(40), "achievement/tabs")
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Icon"):SetID("icon"):SetBuildingGroup("achievement/icon"):SetOrder(50), "achievement/tabs")


  -- Create the states
  local stateSelect = StateSelectRecipe()
  stateSelect:SetBuildingGroup("achievement/:achievement_tab_selected:/states")
  stateSelect:AddState("failed")
  stateSelect:SetOrder(200)
  OptionBuilder:AddRecipe(stateSelect, "achievement/general")
  OptionBuilder:AddRecipe(stateSelect, "achievement/header")
  OptionBuilder:AddRecipe(stateSelect, "achievement/name")
  OptionBuilder:AddRecipe(stateSelect, "achievement/description")
  OptionBuilder:AddRecipe(stateSelect, "achievement/icon")

    -- General Tab
    OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Hide completed criteria"):BindOption("achievement-hide-criteria-completed"):SetOrder(10), "achievement/general")
    OptionBuilder:AddRecipe(RangeRecipe():SetRange(0, 20):SetText("Max criteria displayed"):BindOption("achievement-max-criteria-displayed"):SetOrder(15), "achievement/general")
    OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("achievement.frame"), "achievement/general/states")

    -- Header Tab
    OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("achievement.header"), "achievement/header/states")

    -- Name Tab
    OptionBuilder:AddRecipe(ThemePropertyRecipe()
    :SetElementID("achievement.name")
    :ClearFlags()
    :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
    :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL), "achievement/name/states")

    -- Description Tab
    OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show"):BindOption("achievement-show-description"), "achievement/description")
    OptionBuilder:AddRecipe(ThemePropertyRecipe()
    :SetElementID("achievement.description")
    :ClearFlags()
    :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
    :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL), "achievement/description/states")

    -- Icon Tab
    OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("achievement.icon"), "achievement/icon/states")

  --OptionBuilder:AddRecipe(HeadingRecipe():SetText("General"), "achievement/general/states")
  --OptionBuilder:AddRecipe(HeadingRecipe():SetText("Name"), "achievement/name/states")

end

--------------------------------------------------------------------------------
--                                Dungeon                                     --
--------------------------------------------------------------------------------
function AddDungeonRecipes(self)
  -- Name Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("dungeon-block-category/name"):SetOrder(110), "dungeon-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.dungeon.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "dungeon-block-category/name")

  -- Icon Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Icon"):SetID("icon"):SetBuildingGroup("dungeon-block-category/icon"):SetOrder(120), "dungeon-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("block.dungeon.icon"), "dungeon-block-category/icon")
end
--------------------------------------------------------------------------------
--                                Keystone                                    --
--------------------------------------------------------------------------------
function AddKeystoneRecipes(self)
  -- General
  OptionBuilder:AddRecipe(CheckBoxRecipe()
  :SetText("Show Timer bar")
  :SetOrder(200)
  :BindOption("keystone-show-timer-bar"), "keystone-block-category/general")

  OptionBuilder:AddRecipe(CheckBoxRecipe()
  :SetText("Show Death count")
  :SetOrder(201)
  :BindOption("keystone-show-death-count"), "keystone-block-category/general")


  local enemyForcesFormats = {
    [1] = "57%",
    [2] = "152",
    [3] = "152/268",
    [4] = "152/268 (57%)",
  }

  OptionBuilder:AddRecipe(SelectRecipe()
  :SetText("Enemy Forces format")
  :SetList(enemyForcesFormats)
  :SetOrder(202)
  :BindOption("keystone-enemy-forces-format"), "keystone-block-category/general")

  local percentageFormats = {
    [0] = "57%",
    [1] = "57.5%",
    [2] = "57.54%",
  }

  OptionBuilder:AddRecipe(SelectRecipe()
  :SetText("Percentage format")
  :SetList(percentageFormats)
  :SetOrder(283)
  :BindOption("keystone-percentage-format"), "keystone-block-category/general")

  -- Name Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("keystone-block-category/name"):SetOrder(110), "keystone-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.keystone.name")
  :SetElementParentID("block.dungeon.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "keystone-block-category/name")

  -- Icon Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Icon"):SetID("icon"):SetBuildingGroup("keystone-block-category/icon"):SetOrder(120), "keystone-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("block.keystone.icon"), "keystone-block-category/icon")

  -- Level tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Level"):SetID("level"):SetBuildingGroup("keystone-block-category/level"):SetOrder(130), "keystone-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.keystone.level")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "keystone-block-category/level")
end
--------------------------------------------------------------------------------
--                                QuestBlock                                --
--------------------------------------------------------------------------------
function AddQuestBlockRecipes(self)
  OptionBuilder:AddRecipe(InlineGroupRecipe():SetText(""):SetOrder(80):SetBuildingGroup("quests-block-category/general/top-options"), "quests-block-category/general")
  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show only quests in the current zone"):SetOrder(80):SetWidth(1.0):BindOption("show-only-quests-in-zone"), "quests-block-category/general/top-options")
  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Sort quests by distance"):SetOrder(81):SetWidth(1.0):BindOption("sort-quests-by-distance"), "quests-block-category/general/top-options")

end
--------------------------------------------------------------------------------
--                                Scenario                                    --
--------------------------------------------------------------------------------
function AddScenarioRecipes(self)
  -- Name Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Name"):SetID("name"):SetBuildingGroup("scenario-block-category/name"):SetOrder(110), "scenario-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.scenario.name")
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "scenario-block-category/name")

  -- Stage Tab
  OptionBuilder:AddRecipe(TabItemRecipe():SetText("Stage"):SetID("stage"):SetBuildingGroup("scenario-block-category/stage"):SetOrder(110), "scenario-block-category/tabs")
  OptionBuilder:AddRecipe(ThemePropertyRecipe():SetElementID("block.scenario.stage"):SetOrder(110), "scenario-block-category/stage")
  -- Stage name
  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Stage Name"):SetOrder(120), "scenario-block-category/stage")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.scenario.stage-name")
  :SetOrder(130)
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "scenario-block-category/stage")
  -- Stage counter
  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Stage Counter"):SetOrder(140), "scenario-block-category/stage")
  OptionBuilder:AddRecipe(ThemePropertyRecipe()
  :SetElementID("block.scenario.stage-counter")
  :SetOrder(150)
  :ClearFlags()
  :SetFlags(_DEFAULT_SKIN_TEXT_FLAGS)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL)
  :AddFlag(Theme.SkinFlags.TEXT_JUSTIFY_VERTICAL), "scenario-block-category/stage")
end

--------------------------------------------------------------------------------
--                          GroupFinder Addons                                --
--------------------------------------------------------------------------------
function AddGroupFinderRecipes(self)
  -- Create the quest tree item
  OptionBuilder:AddRecipe(TreeItemRecipe():SetID("group-finder"):SetText("Group Finder"):SetBuildingGroup("group-finder/children"):SetOrder(140), "RootTree")

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
