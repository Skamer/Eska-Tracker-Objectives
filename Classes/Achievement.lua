--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Classes.Achievement"                      ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
__Recyclable__()
class "Achievement" (function(_ENV)
  inherit "Frame" extend "IObjectiveHolder"
  _AchievementCache = setmetatable({}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    local state = self:GetCurrentState()

    if prop == "name" then
      Theme:SkinText(self.frame.headerName, Theme.SkinFlags.TEXT_TRANSFORM, new, state)
    elseif prop == "icon" then
      self.frame.ftex.texture:SetTexture(new)
    elseif prop == "desc" then
      Theme:SkinText(self.frame.description, Theme.SkinFlags.TEXT_TRANSFORM, new, state)
      self:CalculateHeight()
    elseif prop == "showDesc" then
      if new then
        self:ShowDescription()
      else
        self:HideDescription()
      end
    elseif prop == "failed" then
      self:Skin()
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  function ShowDescription(self)
    if self.frame.description:IsShown() then
      return
    end

    self.frame.description:Show()
    self:Layout()
  end

  function HideDescription(self)
    if not self.frame.description:IsShown() then
      return
    end

    self.frame.description:Hide()
    self:Layout()
  end

  function OnLayout(self)
    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:Hide()
      obj:ClearAllPoints()

      if index == 1 then
        if self.showDesc then
          obj:SetPoint("TOP", self.frame.description, "BOTTOM")
          obj:SetPoint("LEFT")
          obj:SetPoint("RIGHT")
        else
          obj:SetPoint("TOP", self.frame.header, "BOTTOM")
          obj:SetPoint("LEFT", self.frame.ftex.texture, "RIGHT")
          obj:SetPoint("RIGHT")
        end
      else
        obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        obj:SetPoint("RIGHT")
      end
      obj:Show()
      previousFrame = obj.frame
    end
    self:CalculateHeight()
  end

  function CalculateHeight(self)
    -- Reset the height to baseHeight
    local height = self.baseHeight
    -- Get the objectives height
    local objectivesHeight = self:GetObjectivesHeight()

    -- Get the description height if enabled
    if self.showDesc then
      -- Update the height (avoid a incorrect value by CalculateHeight)
      self.frame.description:SetHeight(0)
      height = max(height, self.frame.description:GetHeight() + objectivesHeight + 21)
    else
      height = max(height, objectivesHeight + 21)
    end

    self.height = height + 2
  end

  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame, target) then
      Theme:SkinFrame(self.frame, flags, state)
    end

    if Theme:NeedSkin(self.frame.header, target) then
      Theme:SkinFrame(self.frame.header, flags, state)
    end

    if Theme:NeedSkin(self.frame.ftex, target) then
      Theme:SkinFrame(self.frame.ftex, flags, state)
    end

    if Theme:NeedSkin(self.frame.headerName, target) then
      Theme:SkinText(self.frame.headerName, flags, self.name, state)
    end

    if Theme:NeedSkin(self.frame.description, target) then
      Theme:SkinText(self.frame.description, flags, self.desc, state)
      self:CalculateHeight()
    end
  end


  function GetCurrentState(self)
    return self.failed and "failed" or nil
  end

  function OnParentWidthChanged(self, width)
    self:CalculateHeight()
  end

  function UpdateTextHeight(self)
      self:CalculateHeight()
  end

  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".frame", self.frame)
    Theme:RegisterFrame(prefix..".header", self.frame.header)
    Theme:RegisterFrame(prefix..".icon", self.frame.ftex)
    Theme:RegisterText(prefix..".name", self.frame.headerName)
    Theme:RegisterText(prefix..".description", self.frame.description)

    -- Then skin them
    Theme:SkinFrame(self.frame, nil, state)
    Theme:SkinFrame(self.frame.header, nil, state)
    Theme:SkinFrame(self.frame.ftex, nil, state)
    Theme:SkinText(self.frame.headerName, nil, self.name, state)
    Theme:SkinText(self.frame.description, nil, self.desc, state)
  end

  function Reset(self)
    self:Hide()
    self:SetParent(nil)
    self:ClearAllPoints()

    -- Remove event handlers
    self.OnHeightChanged = nil

    -- Reset properties
    self.numObjectives  = nil
    self.id             = nil
    self.name           = nil
    self.icon           = nil
    self.desc           = nil
    self.showDesc       = nil
    self.failed         = nil
  end

  function PrepareContextMenu(self)
    ContextMenu():ClearAll()
    ContextMenu():AnchorTo(self.frame.ftex, self.frame.header):UpdateAnchorPoint()
    ContextMenu():AddAction("select-achievement", self)
    ContextMenu():AddAction("stop-tracking-achievement", self)
    ContextMenu():Finish()
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "id"       { TYPE = Number, DEFAULT = -1 }
  property "name"     { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "icon"     { TYPE = String + Number, DEFAULT = nil, HANDLER = UpdateProps }
  property "desc"     { TYPE = String, DEFAULT = "",  HANDLER = UpdateProps }
  property "showDesc" { TYPE = Boolean, DEFAULT = true, HANDLER = UpdateProps }
  property "failed"   { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  __Static__() property "_prefix" { DEFAULT = "achievement" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Achievement(self)
    super(self)

    self.frame = CreateFrame("Frame")
    self.frame:SetBackdrop(_Backdrops.Common)

    local ftex = CreateFrame("Frame", nil, self.frame)
    ftex:SetBackdrop(_Backdrops.Common)
    ftex:SetPoint("TOPLEFT")
    ftex:SetHeight(46)
    ftex:SetWidth(46)
    self.frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(44)
    texture:SetWidth(44)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.frame.ftex.texture = texture

    local headerFrame = CreateFrame("Button", nil, self.frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT", ftex, "TOPRIGHT")
    headerFrame:SetHeight(21)
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    self.frame.header = headerFrame

    headerFrame:SetScript("OnClick", function(_, button, down)
      if button == "LeftButton" then
        Actions:Exec("select-achievement", self)
      elseif button == "RightButton" then
        Actions:Exec("toggle-context-menu", self)
      end
    end)

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerText:GetFontObject():SetShadowOffset(0.5, 0)
    headerText:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    headerText:SetPoint("LEFT", 10, 0)
    headerText:SetPoint("RIGHT")
    headerText:SetPoint("TOP")
    headerText:SetPoint("BOTTOM")
    self.frame.headerName = headerText

    local description = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOP", 0, -21)
    description:SetPoint("LEFT", 51, 0)
    description:SetPoint("RIGHT")
    description:SetText("")
    description:SetJustifyH("LEFT")
    description:SetWordWrap(true)
    self.frame.description = description

    self.baseHeight = 46
    self.height     = self.baseHeight

    -- Keep it in the cache
    _AchievementCache[self] = true
    -- Init things (register, skin elements)
    Init(self)
  end
end)
--------------------------------------------------------------------------------
--                                                                            --
--                          Achievement Block                                 --
--                                                                            --
--------------------------------------------------------------------------------
__Block__ "achievements-basic" "achievements"
class "AchievementBlock" (function(_ENV)
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Achievement }
  function AddAchievement(self, achievement)
    if not self.achievements:Contains(achievement) then
      self.achievements:Insert(achievement)
      achievement:SetParent(self.frame.content)

      achievement.OnHeightChanged = function(_, new, old)
        self.height = self.height + (new - old)
      end

      self:Layout()
    end
  end

  __Arguments__ { Number }
  function RemoveAchievement(self, achievementID)
    local achievement = self:GetAchievement(achievementID)
    if achievement then
      self:RemoveAchievement(achievement)
    end
  end

  __Arguments__ { Achievement }
  function RemoveAchievement(self, achievement)
    local found = self.achievements:Remove(achievement)
    if found then
      achievement:Recycle()
      self:Layout()
    end
  end

  __Arguments__ { Number }
  function GetAchievement(self, achievementID)
    for _, achievement in self.achievements:GetIterator() do
      if achievement.id == achievementID then
        return achievement
      end
    end
  end

  function OnLayout(self)
    local previousFrame
    for index, achievement in self.achievements:GetIterator() do
      achievement:Hide()
      achievement:ClearAllPoints()

      if index == 1 then
        achievement:SetPoint("TOP")
        achievement:SetPoint("LEFT")
        achievement:SetPoint("RIGHT")
      else
        achievement:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        achievement:SetPoint("RIGHT")
      end

      achievement:Show()
      previousFrame = achievement.frame
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight
    local offset = 5

    for index, achievement in self.achievements:GetIterator() do
      height = height + achievement.height
      if index > 1 then
        height = height + offset
      end
    end

    self.height = height + 2
  end
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function AchievementBlock(self)
    super(self)
    self.text = "Achievements"

    self.achievements = Array[Achievement]()
  end
end)
--------------------------------------------------------------------------------
--                                                                            --
--                         Achievements Actions                               --
--                                                                            --
--------------------------------------------------------------------------------
__Action__ "select-achievement" "Open achievement"
class "SelectAchievementAction" (function(_ENV)
  ------------------------------------------------------------------------------
  --                            Helper functions                              --
  ------------------------------------------------------------------------------
  local function SelectAchievement(achievementID)
    if not AchievementFrame then
      AchievementFrame_LoadUI()
    end
    if not AchievementFrame:IsShown() then
      AchievementFrame_ToggleAchievementFrame()
    end
    AchievementFrame_SelectAchievement(achievementID)
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  __Static__() function Exec(achievementID)
    if not AchievementFrame or AchievementFrameAchievements.selection ~= achievementID then
      SelectAchievement(achievementID)
    else
      AchievementFrame_ToggleAchievementFrame()
    end
  end

  __Arguments__ { Achievement }
  __Static__() function Exec(achievement)
    SelectAchievementAction.Exec(achievement.id)
  end
end)

__Action__ "stop-tracking-achievement" "Stop Tracking"
class "StopTrackingAchievementAction" (function(_ENV)
  __Arguments__ { Number }
  __Static__() function Exec(achievementID)
    RemoveTrackedAchievement(achievementID);
    if AchievementFrame then
      AchievementFrameAchievements_ForceUpdate();
    end
  end

  __Arguments__ { Achievement }
  __Static__() function Exec(achievement)
    StopTrackingAchievementAction.Exec(achievement.id)
  end
end)
