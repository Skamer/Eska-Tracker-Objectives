--============================================================================--
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
--============================================================================--
Scorpio             "EskaTracker.Interfaces.IObjectiveHolder"                 ""
--============================================================================--
namespace "EKT"
--============================================================================--
interface "IObjectiveHolder" (function(_ENV)
  ------------------------------------------------------------------------------
  --                             Handlers                                     --
  ------------------------------------------------------------------------------
  local function SetNumObjectives(self, new, old)
    if new > old then
      for i = 1, new - old do
        local objective = ObjectManager:Get(Objective)
        self:AddObjective(objective)
      end
    elseif new < old then
      for i = 1, old - new do
        local objective = self:GetObjective(new + 1)
        if objective then
          self.objectives:Remove(objective)
          objective:Recycle()
        end
      end
    end

    if Class.IsSubType(getmetatable(self), Frame) then
      if self._isUsed == nil or self._isUsed == true then
        self:Layout()
      end
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function AddObjective(self, objective)
    self.objectives:Insert(objective)

    if Class.IsSubType(getmetatable(self), Block) then
      objective:SetParent(self.frame.content)
    else
      objective:SetParent(self)
    end

    objective.OnHeightChanged = function(obj, new, old)
      self.height = self.height + (new - old)
    end
  end

  function GetObjective(self, index)
    return self.objectives[index]
  end

  function ShowDotted(self)
    if not self.dotted then
      self.dotted = ObjectManager:Get(DottedObjective)
    end

    if self.numObjectives > 0 then
      local obj = self.objectives[self.numObjectives]
      self.dotted:SetParent(self)
      self.dotted:SetPoint("TOPLEFT", obj, "BOTTOMLEFT")
      self.dotted:SetPoint("TOPRIGHT", obj, "BOTTOMRIGHT")
    end

    if not self.dotted:IsShown() then
      self.dotted:Show()
      self.height = self.height + self.dotted.height
    end
  end

  function HideDotted(self)
    if not self.dotted then
      return
    end

    if not self.dotted:IsShow() then
      return
    end

    self.dotted:Hide()
    self.height = self.height - self.dotted.height
    self.dotted:Recycle()
    self.dotted = nil
  end

  function GetObjectivesHeight(self)
    local totalHeight = 0
    if self.objectives then
      for index, objective in self.objectives:GetIterator() do totalHeight = totalHeight + objective.height end
    end

    -- include dotted height if shown
    if self.dotted and self.dotted:IsShown() then
      totalHeight = totalHeight + self.dotted.height
    end

    return totalHeight
  end

  function ClearObjectives(self)
    while(self.objectives.Count > 0) do self.objectives:RemoveByIndex(list.Count) end
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "numObjectives" { TYPE = Number, DEFAULT = 0, HANDLER = SetNumObjectives }
  property "objectivesSpacing" { TYPE = Number, DEFAULT = 0 }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function IObjectiveHolder(self)
    self.objectives = Array[Objective]()
  end

end)
