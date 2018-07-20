--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio             "EskaTracker.Classes.Objective"                           ""
--============================================================================--
namespace "EKT"
--============================================================================--
__Recyclable__()
class "Objective" (function(_ENV)
  inherit "Frame"
  _ObjectiveCache = setmetatable({}, { __mode = "k"})

  local function CreateStatusBar(self)
    local bar = CreateFrame("StatusBar", nil, self.frame)
    bar:SetStatusBarTexture(_Backdrops.Common.bgFile)
    bar:SetStatusBarColor(0, 148/255, 1, 0.6)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.6)

    local text = bar:CreateFontString(nil, "OVERLAY", GameFontHighlightSmall)
    local color = { r = 0, g = 148 / 255, b = 255 / 255 }
    local font = _LibSharedMedia:Fetch("font", "PT Sans Bold Italic")

    text:SetTextColor(1, 1, 1, 1)
    text:SetAllPoints()
    text:SetFont(font, 13) -- 9
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    bar.text = text

    local bgFrame = CreateFrame("Frame", nil, bar)
    bgFrame:SetPoint("TOPLEFT", -2, 2)
    bgFrame:SetPoint("BOTTOMRIGHT", 2, -2)
    bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)

    bgFrame.background = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgFrame.background:SetAllPoints(bgFrame)
    bgFrame.background:SetTexture([[Interface\AddOns\EskaTracker\Media\Textures\Frame-Background-6]])
    bgFrame.background:SetVertexColor(0, 0, 0, 0.5)

    local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
    borderB:SetColorTexture(0,0,0)
    borderB:SetPoint("BOTTOMLEFT")
    borderB:SetPoint("BOTTOMRIGHT")
    borderB:SetHeight(3)

    local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
    borderT:SetColorTexture(0,0,0)
    borderT:SetPoint("TOPLEFT")
    borderT:SetPoint("TOPRIGHT")
    borderT:SetHeight(3)

    local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
    borderL:SetColorTexture(0,0,0)
    borderL:SetPoint("TOPLEFT")
    borderL:SetPoint("BOTTOMLEFT")
    borderL:SetWidth(3)

    local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
    borderR:SetColorTexture(0,0,0)
    borderR:SetPoint("TOPRIGHT")
    borderR:SetPoint("BOTTOMRIGHT")
    borderR:SetWidth(3)


    return bar
  end
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "text" then
    Theme:SkinText(self.frame.text, Theme.SkinFlags.TEXT_TRANSFORM, new, self:GetCurrentState())
    elseif prop == "failed" or prop == "isCompleted" then
      self:Skin()
    end
  end

  local function SetText(self, new, old)
    Theme:SkinText(self.frame.text, Theme.SkinFlags.TEXT_TRANSFORM, new, self:GetCurrentState())
    self:CalculateHeight()
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function ShowTimer()
    if not self.frame.timer then
      local timer = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      timer:SetText("14:35")
      timer:SetPoint("TOP", self.frame.text, "BOTTOM", 0, -5)
      timer:SetFont(timer:GetFont(), 18, "OUTLINE")
      timer:SetHeight(18)
      self.frame.timer = timer
    end

    self.frame.timer:Show()
  end

  function HasTimer(self)
    if self.frame.timer and self.frame.timer:IsShown() then
      return true
    else
      return false
    end
  end

  function HideTimer(self)
    if self.frame.timer then
      self.frame.timer:Hide()
    end
  end



  function SetTimer(self, duration, elapsed)
    local remainingDuration = duration - elapsed
    local remainingDurationPercent = remainingDuration * 100 / duration

    if remainingDurationPercent < 10 then
      self.frame.timer:SetTextColor(1, 0, 0)
    elseif remainingDurationPercent < 25 then
      self.frame.timer:SetTextColor(1, 106/255, 0)
    elseif remainingDurationPercent < 50 then
      self.frame.timer:SetTextColor(1, 216/255, 0)
    else
      self.frame.timer:SetTextColor(1, 1, 1)
    end

    self.frame.timer:SetText(GetTimeStringFromSeconds(remainingDuration, false, true))
  end


  function ShowProgress(self)
    if not self.frame.fbar then
      local fbar = CreateStatusBar(self)
      fbar:SetHeight(18)
      fbar:SetPoint("TOPLEFT", self.frame.text, "BOTTOMLEFT", 0, -4)
      fbar:SetPoint("TOPRIGHT", self.frame.text, "BOTTOMRIGHT", -35, 0)
      self.frame.fbar = fbar
    end

    self.frame.fbar:Show()
    self:CalculateHeight()
  end

  function HasProgress(self)
    if self.frame.fbar and self.frame.fbar:IsShown() then
      return true
    else
      return false
    end
  end

  function HideProgress(self)
    if self.frame.fbar then
      self.frame.fbar:Hide()
    end
    self:CalculateHeight()
  end

  __Arguments__ { String }
  function SetTextProgress(self, text)
    if self.frame.fbar then
      self.frame.fbar.text:SetText(text)
    end
  end

  __Arguments__ { String, Any, Variable.Rest(Any) }
  function SetTextProgress(self, text, ...)
    if self.frame.fbar then
      self.frame.fbar.text:SetFormattedText(text, ...)
    end
  end

  __Arguments__ { Number }
  function SetProgress(self, progress)
    if self.frame.fbar then
      self.frame.fbar:SetValue(progress)
    end
  end

  __Arguments__ { Number, Number }
  function SetMinMaxProgress(self, min, max)
    if self.frame.fbar then
      self.frame.fbar:SetMinMaxValues(min, max)
    end
  end

  function GetCurrentState(self)
    if self.failed then
      return "failed"
    end

    if self.isCompleted then
      return "completed"
    end

    return "progress"
  end


  __Arguments__ { Variable.Optional(SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame, target) then
      Theme:SkinFrame(self.frame, flags, state)
    end

    if Theme:NeedSkin(self.frame.square, target) then
      Theme:SkinFrame(self.frame.square, flags, state)
    end

    if Theme:NeedSkin(self.frame.text, target) then
      Theme:SkinText(self.frame.text, flags, self.text, state)
      self:CalculateHeight()
    end
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    -- Important ! This is needed to update the text box height
    self.frame.text:SetHeight(0)

    local textHeight = self.frame.text:GetHeight()

    local diff = (textHeight + 4) - self.baseHeight
    if diff < 0 then diff = 0 end
      height = height + diff

    -- if the objective has a progress
    if self:HasProgress() then
      height = height + 26
    end

    -- if the objective has a timer
    if self:HasTimer() then
      height = height + 23
    end

    self.height = height

  end

  -- NOTE Investigate this code !
  function OnParentWidthChanged(self, width)
    self:CalculateHeight()
  end

  function UpdateTextHeight(self)
      self:CalculateHeight()
  end



  function Init(self)
    local prefix = self:GetClassPrefix()
    local state = self:GetCurrentState()

    Theme:RegisterFrame(prefix..".frame", self.frame)
    Theme:RegisterText(prefix..".text", self.frame.text)
    Theme:RegisterFrame(prefix..".square", self.frame.square)

    Theme:SkinFrame(self.frame, nil, state)
    Theme:SkinText(self.frame.text, nil, self.text, state)
    Theme:SkinFrame(self.frame.square, nil, state)
  end

  function OnReset(self)
    super.OnReset(self)

    self.text = nil
    self.type = nil
    self.isCompleted = nil
  end

  function OnRecycle(self)
    super.OnRecycle(self)

    self:HideProgress()
    self:HideTimer()
  end

  __Static__() function UpdateSize()
    for obj in pairs(_ObjectiveCache) do
      obj:CalculateHeight()
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "text" { TYPE = String, DEFAULT = "", HANDLER = SetText }
  property "type" { TYPE = String, DEFAULT = "" }
  property "isCompleted" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  property "failed" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }

  __Static__() property "_prefix" { DEFAULT = "objective" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Objective(self)
    super(self, CreateFrame("Frame"))
    self.frame:SetBackdrop(_Backdrops.Common)
    self.frame:SetBackdropColor(0.1, 1, 0.1, 0)
    self.frame:SetBackdropBorderColor(0, 0, 0, 0)

    local square = CreateFrame("Frame", nil, self.frame)
    square:SetBackdrop(_Backdrops.Common)
    square:SetPoint("TOP", 0, -4)
    square:SetPoint("LEFT", 10, 0)
    square:SetWidth(12)
    square:SetHeight(12)
    square:SetBackdropBorderColor(0, 0, 0)
    self.frame.square = square

    local text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", 27, 0)
    text:SetPoint("RIGHT")
    text:SetPoint("TOP", 0, -4)
    text:SetJustifyH("LEFT")
    text:SetText("")
    text:SetWordWrap(true)
    text:SetNonSpaceWrap(false)
    self.frame.text = text

    self.baseHeight = 20
    self.height = self.baseHeight

    -- Keep it in the cache for later
    _ObjectiveCache[self] = true
    -- Init things (register, skin elements)
    Init(self)
  end

end)

__Recyclable__()
class "DottedObjective" (function(_ENV)
  inherit "Frame"
  _DottedObjectiveCache = setmetatable({}, { __mode = "k" })
  function DottedObjective(self)
    super(self)

    local frame = CreateFrame("Frame")
    frame:SetHeight(8)

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetFont(text:GetFont(), 18)
    text:SetText("...")
    text:SetAllPoints()
    text:SetJustifyH("CENTER")
    text:SetJustifyV("BOTTOM")

    frame.text = text

    self.frame = frame
    self.height = 8
    self.baseHeight = self.height

    _DottedObjectiveCache[self] = true
  end
end)
--------------------------------------------------------------------------------
--                          Scorpio OnLoad                                    --
--------------------------------------------------------------------------------
function OnLoad(self)
  -- Register these classes in the object manager
  ObjectManager:Register(Objective)
  ObjectManager:Register(DottedObjective)
end
