--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                "EskaTracker.Classes.QuestBlock"                          ""
--============================================================================--
namespace "EKT"
--============================================================================--
QUEST_CATEGORIES_ENABLED_OPTION = "quest-categories-enabled"
--============================================================================--
__Block__  "quests-basic" "quests"
class "QuestBlock" (function(_ENV)
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Quest }
  function AddQuest(self, quest)
    if not self.quests:Contains(quest) then
      -- TODO: Add Stuff about Quest Header
      if Settings:Get("quest-categories-enabled") then
        local header = self:GetHeader(quest.header)
        if not header then
          header = self:NewHeader(quest.header)
        end
        header:AddQuest(quest)
      else
        quest:SetParent(self.frame.content)
        quest.OnHeightChanged = function(_, new, old)
          self.height = self.height + (new - old)
        end

        quest.OnDistanceChanged = function() self:Layout() end
      end


      self.quests:Insert(quest)
      Scorpio.FireSystemEvent("EKT_QUESTBLOCK_QUEST_ADDED", quest)

      self:Draw()
    end
  end


  __Arguments__ { Quest }
  function RemoveQuestFromHeader(self, quest)
    local header = self:GetHeader(quest.header)
    if header then
      header:RemoveQuest(quest)
      if header:GetQuestNum() == 0 then
        self:RemoveHeader(quest.header)
      end
    end
  end

  __Arguments__ { Number }
  function RemoveQuest(self, questID)
    local quest = self:GetQuest(questID)
    if quest then
      self:RemoveQuest(quest)
    end
  end

  __Arguments__ { Quest, Variable.Optional(Boolean, true) }
  function RemoveQuest(self, quest, recycle)
    quest = self.quests:Remove(quest)

    if not quest then
      return
    end

    if Settings:Get("quest-categories-enabled") then
      self:RemoveQuestFromHeader(quest)
    end

    Scorpio.FireSystemEvent("EKT_QUESTBLOCK_QUEST_REMOVED", quest)

    if recycle then
      quest:Recycle()
    end

    self:Layout()
  end

  __Arguments__ { Number }
  function GetQuest(self, questID)
    for _, quest in self.quests:GetIterator() do
      if quest.id == questID then
        return quest
      end
    end
  end


  __Arguments__ { String }
  function GetHeader(self, name)
    return self.headers[name]
  end


  __Arguments__ { String }
  function NewHeader(self, name)
    local header = ObjectManager:Get(QuestHeader)
    header.name       = name
    header._sortIndex = nil
    header:SetParent(self.frame.content)

    header.OnHeightChanged = function(_, new, old)
      self.height = self.height + (new - old)
    end

    header.OnQuestDistanceChanged = function()
      self:Layout()
    end

    self.headers[name] = header

    return header
  end

  __Arguments__ { String }
  function RemoveHeader(self, name)
    local header = self.headers[name]
    header:Recycle()

    self.headers[name] = nil
  end

  function EnableCategories(self)
    for index, quest in self.quests:GetIterator() do
      local header = self:GetHeader(quest.header)

      -- Remove event register by the block
      quest.OnHeightChanged   = nil
      quest.OnDistanceChanged = nil
      quest:Hide()

      if not header then
        header = self:NewHeader(quest.header)
      end

      -- The quest header handles everything (anchor, register event, ...)
      header:AddQuest(quest)
    end

    -- Request a layout
    self:Layout()
  end

  function DisableCategories(self)
    for index, quest in self.quests:GetIterator() do
      self:RemoveQuestFromHeader(quest)

      -- Don't forget to change the parent
      quest:Hide()
      quest:SetParent(self.frame.content)

      -- Register events
      quest.OnHeightChanged = function(_, new, old)
        self.height = self.height + (new - old)
      end
      quest.OnDistanceChanged = function() self:Layout() end
    end

    -- Request a draw for displaying changes
    self:ForceLayout()
  end




  function OnLayout(self)
    local enableCategories = Settings:Get("quest-categories-enabled")
    local previousFrame

    if enableCategories then
      -- Header compare function
      local function HeaderSortMethod(a, b)
        if a.nearestQuestDistance ~= b.nearestQuestDistance then
          return a.nearestQuestDistance < b.nearestQuestDistance
        end
        return a.name < b.name
      end

      for index, header in self.headers.Values:ToList():Sort(HeaderSortMethod):GetIterator() do
        header:Hide()
        header:ClearAllPoints()

        if index == 1 then
          header:SetPoint("TOP")
          header:SetPoint("LEFT")
          header:SetPoint("RIGHT")
        else
          header:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2)
          header:SetPoint("RIGHT", previousFrame, "BOTTOMRIGHT")
        end
        header:Show()
        previousFrame = header.frame
      end
    else
      -- Quest compare function (Priorty : Distance > ID > Name)
      local function QuestSortMethod(a, b)
        if a.distance ~= b.distance then
          return a.distance < b.distance
        end

        if a.id ~= b.id then
          return a.id < b.id
        end
        return a.name < b.name
      end

      for index, quest in self.quests:Sort(QuestSortMethod):GetIterator() do
        quest:Hide()
        quest:ClearAllPoints()

        if index == 1 then
          quest:SetPoint("TOP")
          quest:SetPoint("LEFT")
          quest:SetPoint("RIGHT")
        else
          quest:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -10)
          quest:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
        end
        previousFrame = quest.frame
        quest:Show()
      end
    end
    self:CalculateHeight()
  end




--[[
  function OnLayout(self)
    local enableCategories = Settings:Get("quest-categories-enabled")

    -- Quest compare function (Priorty : Distance > ID > Name)
    local function QuestSortMethod(a, b)
      if a.distance ~= b.distance then
        return a.distance < b.distance
      end

      if a.id ~= b.id then
        return a.id < b.id
      end
      return a.name < b.name
    end

    for index, quest in self.quests:Sort(QuestSortMethod):GetIterator() do
      quest:Hide()
      quest:ClearAllPoints()

      if index == 1 then
        quest:SetPoint("TOP", 0, -5)
        quest:SetPoint("LEFT")
        quest:SetPoint("RIGHT")
      else
        quest:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -10)
        quest:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      previousFrame = quest.frame
      quest:Show()
    end

    self:CalculateHeight()
  end
--]]
  --[[function CalculateHeight(self)
    local height = self.baseHeight

    for index, quest in self.quests:GetIterator() do
      local offset = 10
      height = height + quest.height + offset
    end
    self.height = height
  end--]]

  function CalculateHeight(self)
    local enableCategories = Settings:Get(QUEST_CATEGORIES_ENABLED_OPTION)
    local height = self.baseHeight + self.contentMarginTop

    if enableCategories then
      local offset = 2
      for index, header in self.headers:GetIterator() do
        height = height + header.height + offset
      end
    else
      local offset = 10
      for index, quest in self.quests:GetIterator() do
        height = height + quest.height + offset
      end
    end

    self.height = height
  end

  __Arguments__ { String }
  function IsRegisteredSetting(self, id)
    if id == QUEST_CATEGORIES_ENABLED_OPTION then
      return true
    end

    return super.IsRegisteredSetting(self, id)
  end

    __Arguments__ { String, Variable.Optional(), Variable.Optional() }
    function OnSetting(self, id, new, old)
      if id == QUEST_CATEGORIES_ENABLED_OPTION then
        if new then
          self:EnableCategories()
        else
          self:DisableCategories()
        end
      end
    end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "quests" { DEFAULT = function() return Array[Quest]() end }
  property "headers" { DEFAULT = function() return Dictionary() end }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  -----------------------------------------------------------------------------
  function QuestBlock(self)
    super(self)

    self.text = "Quests"

    -- self.quests = Array[Quest]()
    -- self.headers = Dictionary()

  end
end)

__Block__ "instance-quests-basic" "instance-quests"
class "InstanceQuestBlock" (function(_ENV)
  inherit "QuestBlock"
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function InstanceQuestBlock(self)
    super(self)

    self.text = "Instance Quests"
  end

end)

function OnLoad(self)
  Settings:Register("quest-categories-enabled", true)
end


Blocks:Register(QuestBlock)
