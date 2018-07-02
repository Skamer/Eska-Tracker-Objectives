--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio             "EskaTracker.Classes.QuestHeader"                         ""
--============================================================================--
namespace                        "EKT"
--============================================================================--
__Recyclable__()
class "QuestHeader" (function(_ENV)
  inherit "Frame"
  _QuestHeaderCache = setmetatable({}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                              Events                                      --
  ------------------------------------------------------------------------------
  event "OnQuestDistanceChanged"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetName(self, new)
    self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, self.frame.name.elementID)
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Quest }
  function AddQuest(self, quest)
    if not self.quests:Contains(quest) then
      quest._sortIndex = nil
      self.quests:Insert(quest)
      quest:SetParent(self.frame)

      quest.OnHeightChanged = function(_, new, old)
        self.height = self.height + (new - old)
      end

      quest.OnDistanceChanged = function()
        self:Layout()
        self:OnQuestDistanceChanged()
      end

      self:Layout()

      self:AddChildObject(quest)
    end
  end

  __Arguments__ { Quest }
  function RemoveQuest(self, quest)
    local found = self.quests:Remove(quest)
    if found then
      -- We don't call the recycle method because it's QuestBlock must to do it if needed
      quest.OnHeightChanged   = nil
      quest.OnDistanceChanged = nil
      self:Layout()
      self:RemoveChildObject(quest)
    end
  end

  __Arguments__ {}
  function GetQuestNum(self)
    return self.quests.Count
  end

  function OnLayout(self)
    local previousFrame

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

    local mustBeAnchored = false
    for index, quest in self.quests:Sort(QuestSortMethod):GetIterator() do
      -- if the sort index don't existant (the quest is new in the quest header )
      -- or the quest has changed position, it need to be redrawn
      if index == 1 then
        self.nearestQuest = quest
      end

      if (not quest._sortIndex) or (quest._sortIndex ~= index) then
        mustBeAnchored = true
      end

      if mustBeAnchored then
        quest:Hide()

        if index == 1 then
          quest:SetPoint("TOPLEFT", 0, -36)
          quest:SetPoint("TOPRIGHT", 0, -36)
        else
          quest:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -10)
          quest:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
        end

        quest:Show()
      end
      quest._sortIndex = index
      previousFrame = quest.frame
    end

    self:CalculateHeight()
  end


  function CalculateHeight(self)
    local height = self.baseHeight

    for index, quest in self.quests:GetIterator() do
      height = height + quest.height + 10
    end

    self.height = height
  end



  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String)}
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    -- Get the current state
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame, target) then
      Theme:SkinFrame(self.frame, flags, state)
    end

    if Theme:NeedSkin(self.frame.name, target) then
      Theme:SkinText(self.frame.name, flags, self.name, state)
    end
  end

  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".frame", self.frame)
    Theme:RegisterText(prefix..".name", self.frame.name)

    -- Then skin them
    Theme:SkinFrame(self.frame, nil, state)
    Theme:SkinText(self.frame.name, nil, self.name, state)

  end

  function OnReset(self)
    super.OnReset(self)

    -- Reset properties
    self.name = nil
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "name"     { TYPE = String, DEFAULT = "Misc", HANDLER = SetName }
  property "isActive" { TYPE = Boolean, DEFAULT = true }
  property "nearestQuestDistance" {
    GET = function(self)
      if self.nearestQuest then
        return self.nearestQuest.distance
      else
        return 99999
      end
    end
  }
  __Static__() property "_prefix" { DEFAULT = "quest-header"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestHeader(self)
    super(self, CreateFrame("Frame"))
    self.frame:SetBackdrop(_Backdrops.Common)
    self.frame:SetBackdropBorderColor(0, 0, 0, 0)

    local name = self.frame:CreateFontString(nil, "OVERLAY")
    name:SetHeight(29)
    name:SetPoint("TOPLEFT", 10, 0)
    name:SetPoint("RIGHT")
    self.frame.name = name

    self.height     = 29
    self.baseHeight = self.height
    self.quests     = Array[Quest]()

    -- Keep it in the cache
    _QuestHeaderCache[self] = true

    -- Init things (register, skin elements)
    Init(self)

  end

end)
