--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                       "EskaTracker.Classes.QuestItem"                    ""
--============================================================================--
namespace                   "EKT"
--============================================================================--
__Recyclable__()
class "QuestItem" (function(_ENV)
  inherit "Frame"
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  function GetLink(self)
    return self.__link
  end

  function SetLink(self, link)
    self.__link = link
    self:UpdateTooltip()
  end

  function GetTexture(self)
    return self.__texture
  end

  function SetTexture(self, texture)
    self.__texture = texture
    self.frame.tex:SetTexture(texture)
  end

  function UpdateTooltip(self)
    self.frame:SetScript("OnEnter", function(btn)
          GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
          GameTooltip:SetHyperlink(self:GetLink())
          GameTooltip:Show()
    end)
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "link" { Get="GetLink", Set="SetLink"}
  property "texture" { Get="GetTexture", Set="SetTexture"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestItem(self)
    super(self)

    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    local tex = self.frame:CreateTexture()
    tex:SetAllPoints()
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.frame.tex = tex

    self.height     = 26
    self.width      = 26
    self.baseHeight = self.height
  end
end)
