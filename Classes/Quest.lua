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
QUEST_HEADER_LEFT_CLICK_ACTION_OPTION   = "quest-left-click-action"
QUEST_HEADER_MIDDLE_CLICK_ACTION_OPTION = "quest-middle-click-action"
QUEST_HEADER_RIGHT_CLICK_ACTION_OPTION  = "quest-right-click-action"
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
    elseif prop == "isTracked" then
      self:ForceSkin()
    elseif prop == "distance" then
      self.OnDistanceChanged(self, new)
    elseif prop == "isOnMap" then
      if new then
        self:WakeUpPermanently(true)
      else
        self:Idle()
      end
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function GetQuestItem(self)
    if not self.questItem then
      self.questItem = ObjectManager:Get(QuestItem)
      self.questItem:SetParent(self.frame)
    end

    return self.questItem
  end

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

      if self.questItem and not self.questItem:IsShown() then
        self.questItem:Show()
      end

      for index, obj in self.objectives:GetIterator() do
        obj:Hide()
        obj:ClearAllPoints()
        if index == 1 then
          obj:SetPoint("TOP", 0, -21)
          if self.questItem then
            self.questItem:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 5, -2)
            obj:SetPoint("LEFT", self.questItem.frame, "RIGHT")
          else
            obj:SetPoint("LEFT")
          end
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

  function GetCurrentState(self)
    if self.isTracked then
      return "tracked"
    end
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    local objectivesHeight = self:GetObjectivesHeight()

    if self.questItem then
      local itemHeight = self.questItem.height
      if objectivesHeight > itemHeight + 2 then
        height = height + objectivesHeight
      else
        height = height + itemHeight + 2
      end
    else
      height = height + objectivesHeight
    end

    -- offset
    height = height + 2

    self.height = height
  end

  function OnReset(self)
    super.OnReset(self)

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
    self.isCompleted    = nil

    -- Reset quest item if exists
    if self.questItem then
      self.questItem:Recycle()
      self.questItem = nil
    end
  end

  function OnRecycle(self)
    super.OnRecycle(self)

    -- Remvoe Event handlers
    self.OnDistanceChanged  = nil
    self.IsOnMapChanged     = nil
    self.IsCompletedChanged = nil
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

  function PrepareContextMenu(self)
    ContextMenu():ClearAll()
    ContextMenu():AnchorTo(self.frame.header):UpdateAnchorPoint()
    ContextMenu():AddAction("group-finder-create-group", self)
    ContextMenu():AddAction("group-finder-join-group", self)
    --- First seperator
    ContextMenu():AddItem(MenuItemSeparator())
    if not QuestUtils_IsQuestWorldQuest(self.id) then
      if GetSuperTrackedQuestID() == self.id then
        ContextMenu():AddAction("stop-super-tracking-quest")
      else
        ContextMenu():AddAction("super-track-quest", self)
      end
    end
    ContextMenu():AddAction("show-quest-details", self)
    ContextMenu():AddAction("link-quest-to-chat", self)
    -- Second seperator
    ContextMenu():AddItem(MenuItemSeparator())
    ContextMenu():AddAction("abandon-quest", self)
    -- Third separator
    -- TODO: Remove later (it's currently used for debug)
    ContextMenu():AddItem(MenuItemSeparator())
    ContextMenu():AddItem("[DEBUG] Info", nil, function() self:Print() end)
    ContextMenu():Finish()
  end

  function Print(self)
    print("------------")
    print("ID:", self.id)
    print("Name:", self.name)
    print("Level:", self.level)
    print("Header:", self.header)
    print("Distance:", self.distance)
    print("isBounty:", self.isBounty)
    print("isTask:", self.isTask)
    print("isHidden", self.isHidden)
    print("isOnMap", self.isOnMap)
    print("isInArea", self.isInArea)
    print("isTracked", self.isTracked)
    print("isCompleted", self.isCompleted)
    print("------------")
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
  property "isOnMap"    { TYPE = Boolean, DEFAULT = false, EVENT = "IsOnMapChanged", HANDLER = UpdateProps }
  property "isInArea"   { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  property "isTracked"  { TYPE = Boolean, DEFAULT = false }
  property "isCompleted" { TYPE = AnyBool, DEFAULT = false, EVENT = "IsCompletedChanged"}

  __Static__() property "_prefix" { DEFAULT = "quest" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Quest(self)
    super(self, CreateFrame("Frame"))
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
        local action = Options:Get(QUEST_HEADER_RIGHT_CLICK_ACTION_OPTION)
        Actions:Exec(action, self)
      elseif button == "LeftButton" then
        local action = Options:Get(QUEST_HEADER_LEFT_CLICK_ACTION_OPTION)
        Actions:Exec(action, self)
      elseif button == "MiddleButton" then
        local action = Options:Get(QUEST_HEADER_MIDDLE_CLICK_ACTION_OPTION)
        Actions:Exec(action, self)
      end
    end)

    headerFrame:SetScript("OnEnter", function()
      Theme:SkinFrame(headerFrame, nil, "hover")
      self:OnEnter()
    end)
    headerFrame:SetScript("OnLeave", function()
      Theme:SkinFrame(headerFrame)
      self:OnLeave()
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
  -- Register the options
  Options:Register(SHOW_QUEST_LEVEL_OPTION, true)
  Options:Register(COLOR_QUEST_LEVEL_BY_DIFFICULTY_OPTION, true)
  Options:Register(QUEST_HEADER_LEFT_CLICK_ACTION_OPTION, "show-quest-details-with-map")
  Options:Register(QUEST_HEADER_MIDDLE_CLICK_ACTION_OPTION, "none")
  Options:Register(QUEST_HEADER_RIGHT_CLICK_ACTION_OPTION, "toggle-context-menu")

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
    ShowQuestDetailsAction.Exec(quest.id)
  end
end)

__Action__ "show-quest-details-with-map" "Show details with map"
class "ShowQuestDetailsWithMapAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    BFASupport:ShowQuestDetailsWithMap(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    ShowQuestDetailsWithMapAction.Exec(quest.id)
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

__Action__ "stop-super-tracking-quest" "Stop supertracking"
class "StopSuperTrackingQuestAction" (function(_ENV)
  __Static__() function Exec()
    SetSuperTrackedQuestID(0)
    QuestSuperTracking_ChooseClosestQuest()
  end
end)

__Action__ "super-track-quest" "Supertrack quest"
class "SuperTrackQuestAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(questID)
    SetSuperTrackedQuestID(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    SuperTrackQuestAction.Exec(quest.id)
  end
end)

class "QuestPopupNotification" (function(_ENV)
  inherit "InteractiveNotification"

  stringQuestOffer    = string.format("%s\n|cff0fffff%s|r", L["QUEST_POPUP_QUEST_OFFER"], QUEST_WATCH_POPUP_CLICK_TO_VIEW)
  stringQuestComplete = string.format("%s\n|cff0fffff%s|r", L["QUEST_POPUP_QUEST_COMPLETE"], QUEST_WATCH_POPUP_CLICK_TO_COMPLETE)
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateType(self, new, old)
    if new == "OFFER" then
      self.title = QUEST_WATCH_POPUP_QUEST_DISCOVERED
      self.text = stringQuestOffer:format(self.questName)
    elseif new == "COMPLETE" then
      self.title = QUEST_WATCH_POPUP_QUEST_COMPLETE
      self.text  = stringQuestComplete:format(self.questName)
    end
  end

  local function UpdateName(self, new)
    UpdateType(self, self.type)
  end

  local function OnEnterHandler(self)
    self:SetColor(1, 0, 0)
  end

  local function OnLeaveHandler(self)
    self:SetColor(200/255, 0, 0)
  end

  local function OnClickHandler(self)
    if self.type == "OFFER" then
      ShowQuestOffer(GetQuestLogIndexByID(self.questID))
      RemoveAutoQuestPopUp(self.questID)
    elseif self.type == "COMPLETE" then
      ShowQuestComplete(GetQuestLogIndexByID(self.questID))
      RemoveAutoQuestPopUp(self.questID)
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  function SetQuestID(self, questID)
    self.questID = questID
    return self
  end

  __Arguments__ { String }
  function SetQuestName(self, questName)
    self.questName = questName
    return self
  end

  __Arguments__ { String }
  function SetType(self, type)
    self.type = type
    return self
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "questID"   { TYPE = Number }
  property "questName" { TYPE = String, DEFAULT = "", HANDLER = UpdateName }
  property "type"      { TYPE = String, DEFAULT = "OFFER", HANDLER = UpdateType } -- COMPLETE
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestPopupNotification(self)
    super(self)

    self:SetColor(204/255, 0, 0)

    self.frame.title:SetTextColor(1, 216/255, 0)

    UpdateType(self, self.type)

    self.OnEnter = OnEnterHandler
    self.OnLeave = OnLeaveHandler
    self.OnClick = self.OnClick + OnClickHandler
  end
end)
