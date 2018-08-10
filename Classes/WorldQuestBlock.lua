--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                   "EskaTracker.Classes.WorldQuestBlock"                  ""
--============================================================================--
namespace                         "EKT"
--============================================================================--
__Block__ "world-quests-basic" "world-quests"
class "WorldQuestBlock" (function(_ENV)
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { WorldQuest }
  function AddWorldQuest(self, worldQuest)
    if not self.worldQuests:Contains(worldQuest) then
      worldQuest:SetParent(self.frame.content)

      worldQuest.OnHeightChanged = function(_, new, old)
        self.height = self.height + (new - old)
      end

      self.worldQuests:Insert(worldQuest)
      self:Draw()
    end
  end

  __Arguments__ { Number }
  function RemoveWorldQuest(self, worldQuestID)
    local worldQuest = self:GetWorldQuest(worldQuestID)
    if worldQuest then
      self:RemoveWorldQuest(worldQuest)
    end
  end

  __Arguments__ { WorldQuest }
  function RemoveWorldQuest(self, worldQuest)
    local found = self.worldQuests:Remove(worldQuest)
    if found then
      worldQuest:Recycle()
      self:Layout()
    end
  end

  __Arguments__ { Number }
  function GetWorldQuest(self, worldQuestID)
    for _, worldQuest in self.worldQuests:GetIterator() do
      if worldQuest.id == worldQuestID then
        return worldQuest
      end
    end
  end

  function OnLayout(self)
    local previousFrame
    for index, worldQuest in self.worldQuests:GetIterator() do
      worldQuest:Hide()
      worldQuest:ClearAllPoints()

      if index == 1 then
        worldQuest:SetPoint("TOP")
        worldQuest:SetPoint("LEFT")
        worldQuest:SetPoint("RIGHT")
      else
        worldQuest:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        worldQuest:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      previousFrame = worldQuest.frame
      worldQuest:Show()
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height =  self.baseHeight
    local offset = 5
    for index, worldQuest in self.worldQuests:GetIterator() do
      height = height + worldQuest.height + offset
    end

    self.height = height
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "block.world-quests" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function WorldQuestBlock(self)
    super(self)

    self.text = "World Quests"

    self.worldQuests = Array[WorldQuest]()
  end
end)
