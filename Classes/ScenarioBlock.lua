--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                    "EskaTracker.Classes.Scenario"                     ""
--============================================================================--
namespace                   "EKT"
--============================================================================--
__Block__ "scenario-basic" "scenario"
class "ScenarioBlock" (function(_ENV)
  extend "IObjectiveHolder"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      self:ForceSkin(nil, self.frame.name.elementID)
    elseif prop == "currentStage" or prop == "numStages" then
      self:ForceSkin(nil, self.frame.stageCounter.elementID)
    elseif prop == "stageName" then
      self:ForceSkin(nil, self.frame.stageName.elementID)
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    -- Get the current state
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame.stage, target) then
      Theme:SkinFrame(self.frame.stage, flags, state)
    end

    if Theme:NeedSkin(self.frame.name, target) then
      Theme:SkinText(self.frame.name, flags, self.name, state)
    end

    if Theme:NeedSkin(self.frame.stageName, target) then
      Theme:SkinText(self.frame.stageName, flags, self.stageName, state)
    end

    if Theme:NeedSkin(self.frame.stageCounter, target) then
      Theme:SkinText(self.frame.stageCounter, flags, string.format("%i/%i", self.currentStage, self.numStages), state)
    end
  end

  function OnLayout(self)
    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:Hide()
      obj:ClearAllPoints()

      if index == 1 then
        obj:SetPoint("TOP", self.frame.stage, "BOTTOM")
        obj:SetPoint("LEFT")
        obj:SetPoint("RIGHT")
      else
        obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        obj:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      obj:Show()

      previousFrame = obj.frame
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    local objectivesHeight = self:GetObjectivesHeight()

    self.height = height + objectivesHeight + self.frame.stage:GetHeight()
  end


  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".stage", self.frame.stage)
    Theme:RegisterText(prefix..".name", self.frame.name)
    Theme:RegisterText(prefix..".stageName", self.frame.stageName)
    Theme:RegisterText(prefix..".stageCounter", self.frame.stageCounter)

    -- Then skin them
    Theme:SkinFrame(self.frame.stage, nil, state)
    Theme:SkinText(self.frame.name, nil, self.name, state)
    Theme:SkinText(self.frame.stageName, nil, self.stageName, state)
    Theme:SkinText(self.frame.stageCounter, nil, string.format("%i/%i", self.currentStage, self.numStages), state)
  end

  function Reset(self)
    -- Reset properties
    self.name           = nil
    self.currentStage   = nil
    self.numStages      = nil
    self.stageName      = nil
    self.numObjectives  = nil

  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "name"               { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "currentStage"       { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "numStages"          { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "stageName"          { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "numBonusObjectives" { TYPE = Number, DEFAULT = 0 }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function ScenarioBlock(self)
    super(self)
    self.text = "Scenario"

    local header     = self.frame.header
    local headerText = header.text

    -- Scenario name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("LEFT")
    name:SetPoint("RIGHT")
    name:SetPoint("BOTTOM")
    name:SetPoint("TOP", 0, -8)
    self.frame.name = name

    -- Stage frame
    local stage = CreateFrame("Frame", nil, self.frame.content)
    stage:SetPoint("TOPLEFT")
    stage:SetPoint("TOPRIGHT")
    stage:SetBackdrop(_Backdrops.Common)
    stage:SetHeight(22)
    self.frame.stage = stage

    -- Stage counter
    local stageCounter = stage:CreateFontString(nil, "OVERLAY")
    stageCounter:SetPoint("TOPLEFT")
    stageCounter:SetPoint("BOTTOMLEFT")
    stageCounter:SetWidth(50)
    self.frame.stageCounter = stageCounter

    -- Stage name
    local stageName = stage:CreateFontString(nil, "OVERLAY")
    stageName:SetPoint("TOPRIGHT")
    stageName:SetPoint("TOPLEFT", stageCounter, "TOPRIGHT")
    stageName:SetPoint("BOTTOMRIGHT")
    stageName:SetPoint("BOTTOMLEFT", stageCounter, "BOTTOMRIGHT")
    self.frame.stageName = stageName

    -- Init things (register and skin elements)
    Init(self)
  end
end)

Blocks:Register(ScenarioBlock)
