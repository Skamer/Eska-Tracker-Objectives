--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio           "EskaTracker.Classes.Quest"                                 ""
--============================================================================--
namespace "EKT"
--============================================================================--
SHOW_QUEST_LEVEL_OPTION                 = "show-quest-level"
COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION  = "color-quest-level-by-difficulty"
--============================================================================--
__Recyclable__()
class "Quest" (function(_ENV)
  inherit "Frame" extend "IObjectiveHolder"
  _QuestCache = setmetatable({}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                              Events                                      --
  ------------------------------------------------------------------------------
  --- Fired when the distance has changed
  event "OnDistanceChanged"
  --- Fired when there is a change on OnMap
  event "IsOnMapChanged"
  --- Fired when the quest state has changed
  event "IsCompletedChanged"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      self:ForceSkin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.name))
    elseif prop == "level" then
      self:ForceSkin(Theme.SkinFlags.TEXT_COLOR, Theme:GetElementID(self.frame.level))
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function ShowLevel(self)
    self.frame.level:Show()
  end

  function HideLevel(self)
    self.frame.level:Hide()
  end


  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame, target) then
      Theme:SkinFrame(self.frame, flags, state)
    end

    if Theme:NeedSkin(self.frame.header, target) then
      Theme:SkinFrame(self.frame.header, flags, state)
    end

    if Theme:NeedSkin(self.frame.name, target) then
      Theme:SkinText(self.frame.name, flags, self.name, state)
    end

    if Theme:NeedSkin(self.frame.level, target) then
      if Options:Get(COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION) then
        local color = GetQuestDifficultyColor(self.level)
        self.frame.level:SetTextColor(color.r, color.g, color.b)
        Theme:SkinText(self.frame.level, API:RemoveFlag(flags, Theme.SkinFlags.TEXT_COLOR), self.level, state)
      else
        Theme:SkinText(self.frame.level, flags, self.level, state)
      end
    end
  end

  function OnLayout(self, layout)
      local previousFrame
      for index, obj in self.objectives:GetIterator() do
        obj:Hide()
        obj:ClearAllPoints()
        if index == 1 then
          obj:SetPoint("TOP", 0, -21)
          obj:SetPoint("LEFT")
          obj:SetPoint("RIGHT")
        else
          obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
          obj:SetPoint("RIGHT")
        end
        obj:Show()
        previousFrame = obj.frame
      end

      self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    local objectivesHeight = self:GetObjectivesHeight()

    height = height + objectivesHeight

    -- offset
    height = height + 2

    self.height = height
  end

  function Reset(self)
    self:ClearAllPoints()
    self:SetParent()
    self:Hide()

    -- Remove event handlers
    self.OnDistanceChanged  = nil
    self.IsOnMapChanged     = nil
    self.IsCompletedChanged = nil
    self.OnHeightChanged    = nil

    -- Reset properties
    self.numObjectives  = nil
    self.id             = nil
    self.level          = nil
    self.header         = nil
    self.distance       = nil
    self.isTask         = nil
    self.isHidden       = nil
    self.isOnMap        = nil
    self.isTracked      = nil
    self.isInArea       = nil

    self:Hide()
  end


  __Arguments__ { String }
  function IsRegisteredOption(self, option)
    if option == SHOW_QUEST_LEVEL_OPTION or option == COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION then
      return true
    end

    return super.IsRegisteredOption(self, option)
  end

  __Arguments__ { String, Variable.Optional(), Variable.Optional() }
  function OnOption(self, option, new, old)
    if option == SHOW_QUEST_LEVEL_OPTION then
      if new then
        self:ShowLevel()
      else
        self:HideLevel()
      end
    elseif option == COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION then
        self:ForceSkin(Theme.SkinFlags.TEXT_COLOR, Theme:GetElementID(self.frame.level))
    end
  end


  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".frame", self.frame, "quest.frame")
    Theme:RegisterFrame(prefix..".header", self.frame.header, "quest.header")
    Theme:RegisterText(prefix..".name", self.frame.name, "quest.name")
    Theme:RegisterText(prefix..".level", self.frame.level, "quest.level")

    -- Then skin them
    Theme:SkinFrame(self.frame, nil, state)
    Theme:SkinFrame(self.frame.header, nil, state)
    Theme:SkinText(self.frame.name, nil, self.name, state)
    Theme:SkinText(self.frame.level, API:RemoveFlag(Theme.DefaultSkinFlags, Theme.SkinFlags.TEXT_COLOR), self.level, state)

    -- Load options
    self:LoadOption(SHOW_QUEST_LEVEL_OPTION)
    self:LoadOption(COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION)
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id"         { TYPE = Number, DEFAULT = -1 }
  property "name"       { TYPE = String, HANDLER = UpdateProps, DEFAULT =  "" }
  property "level"      { TYPE = Number, DEFAULT = 0, HANDLER = UpdateProps }
  property "header"     { TYPE = String, DEFAULT = "Misc" }
  property "distance"   { TYPE = Number, DEFAULT = -1, HANDLER = UpdateProps }
  property "isBounty"   { TYPE = Boolean, DEFAULT = false }
  property "isTask"     { TYPE = Boolean, DEFAULT = false }
  property "isHidden"   { TYPE = Boolean, DEFAULT = false }
  property "isOnMap"    { TYPE = Boolean, DEFAULT = false, EVENT = "IsOnMapChanged" }
  property "isInArea"   { TYPE = Boolean, DEFAULT = false }
  property "isTracked"  { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  __Static__() property "_prefix" { DEFAULT = "quest" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Quest(self)
    super(self)

    self.frame = CreateFrame("Frame")
    self.frame:SetBackdrop(_Backdrops.Common)
    self.frame:SetBackdropBorderColor(0, 0, 0, 0)

    local headerFrame = CreateFrame("Button", nil, self.frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetBackdropBorderColor(0, 0, 0, 0)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetHeight(21)
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    self.frame.header = headerFrame

    -- Script
    headerFrame:SetScript("OnClick", function(_, button, down)
      if button == "RightButton" then
        ContextMenu():Toggle()
        if ContextMenu():IsShown() then
          ContextMenu():ClearAll()
          ContextMenu():AnchorTo(headerFrame):UpdateAnchorPoint()
          --ContextMenu():AddItem("Create a group", nil, function() print("Test") end)
          --ContextMenu():AddAction("join-a-group", 50)
          --ContextMenu():AddAction("new-action", 98)
          ContextMenu():AddAction("show-quest-details", self)
          --ContextMenu():AddAction("join-a-group", self)
          ContextMenu():AddAction("link-quest-to-chat", self)
          ContextMenu():AddAction("abandon-quest", self)
          ContextMenu():Finish()
        end
      elseif button == "LeftButton" then
        BFASupport:ShowQuestDetailsWithMap(self.id)
      end
    end)

    local name = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:GetFontObject():SetShadowOffset(0.5, 0)
    name:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    name:SetPoint("LEFT", 10, 0)
    name:SetPoint("RIGHT")
    name:SetPoint("TOP")
    name:SetPoint("BOTTOM")
    self.frame.name = name

    local level = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    level:GetFontObject():SetShadowOffset(0.5, 0)
    level:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    level:SetPoint("RIGHT", -2)
    self.frame.level = level

    self.baseHeight = 21
    self.height = self.baseHeight

    -- Keep it in the cache for later.
    _QuestCache[self] = true
    -- Init things (register, skin elements)
    Init(self)
  end
end)


--__Action__ "new-action" "It a new action"
class "NewAction" (function(_ENV)

  property "id"  { STATIC = true, TYPE = String, DEFAULT = "new-action", SET = false }
  property "text" { STATIC = true, TYPE = String, DEFAULT = "It a new action" }

  __Arguments__ { Number }
  __Static__() function Exec(num)
    --print("Execute the new action by this number", num)
  end

end)

Actions:Add(NewAction)

--print("Nouvelle action", NewAction.Exec(162))
--------------------------------------------------------------------------------
--                          Scorpio OnLoad                                    --
--------------------------------------------------------------------------------
function OnLoad(self)
  -- Register the class in the object manager
  --ObjectManager:Register(Quest)

  Options:Register(SHOW_QUEST_LEVEL_OPTION, true)
  Options:Register(COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION, true)
end

--------------------------------------------------------------------------------
--                         Actions
--------------------------------------------------------------------------------
__Action__ "show-quest-details" "Show details"
class "ShowQuestDetailsAction" (function(_ENV)

  __Arguments__ { Number }
  __Static__() function Exec(questID)
      local questLogIndex = GetQuestLogIndexByID(questID)
      if IsQuestComplete(questID) and GetQuestLogIsAutoComplete(questLogIndex) then
        ShowQuestComplete(questLogIndex)
      else
        QuestLogPopupDetailFrame_Show(questLogIndex)
      end
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    QuestShowDetailsAction.Exec(quest.id)
  end
end)


__Action__ "link-quest-to-chat" "Link to chat"
class "LinkQuestToChatAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    ChatFrame_OpenChat(GetQuestLink(questID))
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    LinkQuestToChatAction.Exec(quest.id)
  end
end)

__Action__ "abandon-quest" "Abandon"
class "AbandonQuestAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    QuestMapQuestOptions_AbandonQuest(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    AbandonQuestAction.Exec(quest.id)
  end
end)
