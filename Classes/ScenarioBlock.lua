--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                       "EskaTracker.Classes.Scenario"                     ""
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
    elseif prop == "isWarfront" then
      if new then
        self:ShowWarfrontResources()
      else
        self:HideWarfrontResources()
      end
    elseif prop == "iron" or prop == "ironInChest" then
      if self.frame.warfrontResources then
        local ironText = self.frame.warfrontResources.iron.text
        if self.iron >= 200 then
          ironText:SetFormattedText("|cffff0000%i|r (+%i)", self.iron, self.ironInChest)
        else
          ironText:SetFormattedText("|cffffd005%i|r (+%i)", self.iron, self.ironInChest)
        end
      end
    elseif prop == "wood" then
      if self.frame.warfrontResources then
        local woodText = self.frame.warfrontResources.wood.text
        if new >= 100 then
          woodText:SetFormattedText("|cffff0000%i|r", new)
        else
          woodText:SetFormattedText("|cffffd005%i|r", new)
        end
      end
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
    -- Warfront resources
    if self.isWarfront then
      self.frame.warfrontResources:SetPoint("TOP", self.frame.stage, "BOTTOM")
      self.frame.warfrontResources:SetPoint("LEFT")
      self.frame.warfrontResources:SetPoint("RIGHT")
    end

    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:Hide()
      obj:ClearAllPoints()

      if index == 1 then
        if self.isWarfront then
          obj:SetPoint("TOP", self.frame.warfrontResources, "BOTTOM")
        else
          obj:SetPoint("TOP", self.frame.stage, "BOTTOM")
        end
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

    if self.isWarfront then
      height = height + 22
    end

    local objectivesHeight = self:GetObjectivesHeight()

    self.height = height + objectivesHeight + self.frame.stage:GetHeight()
  end


  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".stage", self.frame.stage)
    Theme:RegisterText(prefix..".name", self.frame.name)
    Theme:RegisterText(prefix..".stage-name", self.frame.stageName)
    Theme:RegisterText(prefix..".stage-counter", self.frame.stageCounter)

    -- Then skin them
    Theme:SkinFrame(self.frame.stage, nil, state)
    Theme:SkinText(self.frame.name, nil, self.name, state)
    Theme:SkinText(self.frame.stageName, nil, self.stageName, state)
    Theme:SkinText(self.frame.stageCounter, nil, string.format("%i/%i", self.currentStage, self.numStages), state)
  end

  function OnReset(self)
    super.OnReset(self)

    -- Reset properties
    self.name           = nil
    self.currentStage   = nil
    self.numStages      = nil
    self.stageName      = nil
    self.numObjectives  = nil
    self.isWarfront     = nil
    self.wood           = nil
    self.iron           = nil
    self.ironInChest    = nil
  end

  function ShowWarfrontResources(self)
    if not self.frame.warfrontResources then
      local warfrontResources = CreateFrame("Frame", nil, self.frame.content)
      warfrontResources:SetBackdrop(_Backdrops.Common)
      warfrontResources:SetBackdropColor(0.2, 0.2, 0.2, 0.5)
      warfrontResources:SetHeight(22)
      self.frame.warfrontResources = warfrontResources

      local iron = CreateFrame("Frame", nil, warfrontResources)
      iron:SetPoint("RIGHT", warfrontResources, "CENTER")
      iron:SetPoint("TOP")
      iron:SetPoint("BOTTOM")
      iron:SetPoint("LEFT")
      warfrontResources.iron = iron

      local ironIcon = iron:CreateTexture()
      ironIcon:SetTexture(133232)
      ironIcon:SetWidth(16)
      ironIcon:SetHeight(16)
      ironIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      ironIcon:SetPoint("CENTER", -16, 0)
      iron.icon = ironIcon

      local ironText = iron:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      ironText:SetPoint("LEFT", ironIcon, "RIGHT", 2, 0)
      ironText:SetPoint("TOP")
      ironText:SetPoint("BOTTOM")
      iron.text = ironText

      local wood = CreateFrame("Frame", nil, warfrontResources)
      wood:SetPoint("LEFT", warfrontResources, "CENTER")
      wood:SetPoint("BOTTOM")
      wood:SetPoint("TOP")
      wood:SetPoint("RIGHT")
      warfrontResources.wood = wood

      local woodIcon = wood:CreateTexture()
      woodIcon:SetTexture(135435)
      woodIcon:SetWidth(16)
      woodIcon:SetHeight(16)
      woodIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      woodIcon:SetPoint("CENTER", -16, 0)
      wood.icon = woodIcon

      local woodText = wood:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      woodText:SetPoint("LEFT", woodIcon, "RIGHT", 2, 0)
      woodText:SetPoint("TOP")
      woodText:SetPoint("BOTTOM")
      wood.text = woodText

      UpdateProps(self, self.iron, nil, "iron")
      UpdateProps(self, self.wood, nil, "wood")
    end

    self.frame.warfrontResources:Show()

    self:Layout()
  end

  function HideWarfrontResources(self)
    if self.frame.warfrontResources then
      self.frame.warfrontResources:Hide()
    end

    self:Layout()
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "name"               { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "currentStage"       { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "numStages"          { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "stageName"          { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "numBonusObjectives" { TYPE = Number, DEFAULT = 0 }
  property "isWarfront"         { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  -- Warfront specific properties
  property "wood"               { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "iron"               { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "ironInChest"        { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
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
