--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Classes.BonusObjective"                   ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
__Recyclable__()
class "BonusQuest" (function(_ENV)
  inherit "Quest"
  _BonusQuestCache = setmetatable( {}, { __mode = "k" })
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "bonus-quest"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function BonusQuest(self)
      super(self)

      -- Keep it in the cache
      _BonusQuestCache[self] = true
  end
end)

__Block__ "bonus-objectives-basic" "bonus-objectives"
class "BonusObjectivesBlock" (function(_ENV)
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { BonusQuest }
  function AddBonusQuest(self, bonusQuest)
    if not self.bonusQuests:Contains(bonusQuest) then
      self.bonusQuests:Insert(bonusQuest)
      bonusQuest:SetParent(self.frame.content)

      bonusQuest.OnHeightChanged = function(_, new, old)
        self.height = self.height + (new - old)
      end

      self:Draw()
    end
  end

  __Arguments__ { Number }
  function RemoveBonusQuest(self, bonusQuestID)
    local bonusQuest = self:GetBonusQuest(bonusQuestID)
    if bonusQuest then
      self:RemoveBonusQuest(bonusQuest)
    end
  end

  __Arguments__ { BonusQuest }
  function RemoveBonusQuest(self, bonusQuest)
    local found = self.bonusQuests:Remove(bonusQuest)
    if found then
      bonusQuest:Recycle()
      self:Layout()
    end
  end

  __Arguments__ { Number }
  function GetBonusQuest(self, bonusQuestID)
    for _, bonusQuest in self.bonusQuests:GetIterator() do
      if bonusQuest.id == bonusQuestID then
        return bonusQuest
      end
    end
  end

  function OnLayout(self)
    local previousFrame
    for index, bonusQuest in self.bonusQuests:GetIterator() do
      bonusQuest:Hide()
      bonusQuest:ClearAllPoints()

      if index == 1 then
        bonusQuest:SetPoint("TOP")
        bonusQuest:SetPoint("LEFT")
        bonusQuest:SetPoint("RIGHT")
      else
        bonusQuest:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        bonusQuest:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      previousFrame = bonusQuest.frame
      bonusQuest:Show()
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight
    local offset = 5
    for index, bonusQuest in self.bonusQuests:GetIterator() do
      height = height + bonusQuest.height + offset
    end

    self.height = height
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "block.bonus-objectives" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function BonusObjectivesBlock(self)
    super(self)

    self.text = "Bonus Objectives"
    self.bonusQuests = Array[BonusQuest]()
  end
end)
