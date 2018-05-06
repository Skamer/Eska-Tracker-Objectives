--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Classes.Dungeon"                          ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
__Block__ "dungeon-basic" "dungeon"
class "DungeonBlock" (function(_ENV)
  extend "IObjectiveHolder"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      self:ForceSkin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.name))
    elseif prop == "texture" then
      self.frame.ftex.texture:SetTexture(new)
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  function OnLayout(self)
    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:Hide()
      obj:ClearAllPoints()
      if index == 1 then
        obj:SetPoint("TOP", self.frame.header, "BOTTOM")
        obj:SetPoint("LEFT", self.frame.ftex, "RIGHT")
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

    -- Get the icon height
    local iconHeight = 92
    -- Get the objectives height
    local objectivesHeight = self:GetObjectivesHeight()

    height = height + max(iconHeight, objectivesHeight) + 8

    self.height = height
  end

  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    -- Get the current state
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame.ftex, target) then
      Theme:SkinFrame(self.frame.ftex, flags, state)
    end

    if Theme:NeedSkin(self.frame.name, target) then
      Theme:SkinText(self.frame.name, flags, self.name, state)
    end
  end

  function Init(self)
    local prefix = self:GetClassPrefix()
    local state = self:GetCurrentState()


    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".icon", self.frame.ftex, "block;dungeon.icon")
    Theme:RegisterText(prefix..".name", self.frame.name, "block.dungeon.name")

    -- Then skin them
    Theme:SkinFrame(self.frame.ftex, nil, state)
    Theme:SkinText(self.frame.name, nil, self.name, state)
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "name"     { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "texture"  { TYPE = String + Number, DEFAULT = nil, HANDLER = UpdateProps}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function DungeonBlock(self)
    super(self)
    self.text = "Dungeon"

    local header     = self.frame.header
    local headerText = header.text

    -- Dungeon name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("LEFT")
    name:SetPoint("RIGHT")
    name:SetPoint("BOTTOM")
    name:SetPoint("TOP", 0, -8)
    self.frame.name = name

    -- Dungeon Texture
    local ftex = CreateFrame("Frame", nil, self.frame)
    ftex:SetBackdrop(_Backdrops.Common)
    ftex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 4, -4)
    ftex:SetHeight(92)
    ftex:SetWidth(92)
    self.frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(92-2)
    texture:SetWidth(92-2)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    ftex.texture = texture

    -- Init things (register, skin elements)
    Init(self)
  end
end)


Blocks:Register(DungeonBlock)
