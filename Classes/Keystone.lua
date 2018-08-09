--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Classes.Keystone"                         ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
SHOW_DEATH_COUNT_OPTION     = "keystone-show-death-count"
SHOW_TIMER_BAR_OPTION       = "keystone-show-timer-bar"
--------------------------------------------------------------------------------
--                                Helpers                                     --
--------------------------------------------------------------------------------
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

__Recyclable__()
class "Affix" (function(_ENV)
  inherit "Frame"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetTexture(self, new)
    self.frame.texture:SetTexture(new)
  end

  local function UpdateTooltip(self, new)
      self.frame:SetScript("OnEnter", function(f)
        GameTooltip:SetOwner(f, "ANCHOR_LEFT")
        GameTooltip:SetText(self.name, 1, 1, 1, 1, true)
        GameTooltip:AddLine(new, nil, nil, nil, true);
        GameTooltip:Show()
      end)
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "id"       { TYPE = Number }
  property "name"     { TYPE = String }
  property "desc"     { TYPE = String, DEFAULT = "", HANDLER = UpdateTooltip }
  property "texture"  { TYPE = String + Number, HANDLER = SetTexture }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Affix(self)


    self.frame = CreateFrame("Frame")

    local texture = self.frame:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.frame.texture = texture

    self.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.height = 24
    self.width  = 24
  end
end)

__Block__ "keystone-bfa" "keystone"
class "BFAKeystoneBlock" (function(_ENV)
  inherit "DungeonBlock" extend "IObjectiveHolder"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetNumAffixes(self, new, old)
    if new > old then
      for i = 1, new - old do
        local affix = ObjectManager:Get(Affix)
        affix:SetParent(self.frame.affixes)
        self.affixes:Insert(affix)
      end
    elseif new < old then
      for i = 1, old - new do
        local affix = self:GetAffix(new + 1)
        if affix then
          self.affixes:Remove(affix)
          affix:Recycle()
        end
      end
    end
  end

  local function SetLevel(self, new)
    self:ForceSkin(nil, Theme:GetElementID(self.frame.level))
  end

  local function SetTimeLimit(self, new)
    self.timeLimit2Key = new * 0.8
    self.timeLimit3Key = new * 0.6

    self.frame.plus2KeyLevelTimer:SetFormattedText("[2+] %s", GetTimeStringFromSeconds(self.timeLimit2Key, false, true))
    self.frame.plus3KeyLevelTimer:SetFormattedText("[3+] %s", GetTimeStringFromSeconds(self.timeLimit3Key, false, true))
  end

  local function SetTimer(self, new)
    local strTimer = GetTimeStringFromSeconds(new, false, true)
    local strTimeLimit = GetTimeStringFromSeconds(self.timeLimit, false, true)

    -- Update the color for the 3 chest
    if new > self.timeLimit3Key then
      self.frame.plus3KeyLevelTimer:SetTextColor(1, 0, 0)
    else
      self.frame.plus3KeyLevelTimer:SetTextColor(38/255, 127/255, 0)
    end

    if new > self.timeLimit2Key then
      self.frame.plus2KeyLevelTimer:SetTextColor(1, 0, 0)
    else
      self.frame.plus2KeyLevelTimer:SetTextColor(38/255, 127/255, 0)
    end


    if self:HasTimerBar() then
      self:SetTimerBarMinMaxValues(0, self.timeLimit)
      self:SetTimerBarValue(max(0, self.timeLimit-new))
    end

    --self.frame.timer:SetText(string.format("%s / %s", strTimer, strTimeLimit))
    self.frame.timer:SetFormattedText("%s / %s", strTimer, strTimeLimit)
  end

  local function SetDeathCount(self, new)
    if new > 0 and Settings:Get(SHOW_DEATH_COUNT_OPTION) then
      self.frame.death:Show()
      self.frame.deathCount:SetText(new)
    else
      self.frame.death:Hide()
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  function GetAffix(self, index)
    return self.affixes[index]
  end


  function ShowTimerBar(self)
    if not self.frame.fbar then
      local fbar = CreateStatusBar(self)
      fbar:SetParent(self.frame.content)
      fbar:SetHeight(12)
      fbar:SetPoint("TOP", self.frame.timer, "BOTTOM", 0, -6)
      fbar:SetPoint("LEFT", self.frame.ftex, "RIGHT", 8, 0)
      fbar:SetPoint("RIGHT", -8, 0)
      self.frame.fbar = fbar
    end

    self.frame.fbar:Show()
  end

  function HideTimerBar(self)
    if self.frame.fbar then
      self.frame.fbar:Hide()
    end
  end

  function HideProgress(self)
    if self.frame.fbar then
      self.frame.fbar:Hide()
    end
  end

  function HasTimerBar(self)
    if self.frame.fbar and self.frame.fbar:IsShown() then
      return true
    else
      return false
    end
  end

  __Arguments__{ Number}
  function SetTimerBarValue(self, value)
    if self.frame.fbar then
      self.frame.fbar:SetValue(value)
    end
  end

  __Arguments__ { Number, Number }
  function SetTimerBarMinMaxValues(self, min, max)
    if self.frame.fbar then
      self.frame.fbar:SetMinMaxValues(min, max)
    end
  end

  function ShowDeathCount(self)
    self.frame.death:Show()
  end

  function HideDeathCount(self)
    self.frame.death:Hide()
  end


  function OnLayout(self)

    do
      local previousFrame
      self.frame.affixes:SetWidth(self.numAffixes * 29)
      for i = 1, self.numAffixes do
        local affix = self:GetAffix(i)
        if i == 1 then
          affix:SetPoint("TOPLEFT", self.frame.affixes, "TOPLEFT")
          affix:SetPoint("BOTTOMLEFT", self.frame.affixes, "BOTTOMLEFT")
        else
          affix:SetPoint("TOPLEFT", previousFrame, "TOPRIGHT", 3, 0)
          affix:SetPoint("BOTTOMLEFT", previousFrame, "BOTTOMRIGHT")
        end
        previousFrame = affix.frame
      end
    end


    do
      local previousFrame
      for index, obj in self.objectives:GetIterator() do
        obj:Hide()
        obj:ClearAllPoints()
        if index == 1 then
          obj:SetPoint("TOP", self.frame.ftex, "BOTTOM")
          obj:SetPoint("LEFT")
          obj:SetPoint("RIGHT")
        else
          obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
          obj:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
        end
        obj:Show()
        previousFrame = obj.frame
      end
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    -- Get the icon height
    local iconHeight = self.frame.ftex:GetHeight()
    -- Get the objectivesHeight
    local objectivesHeight = self:GetObjectivesHeight()
    -- Get the top info height (level/ chest)
    local topInfoHeight = 31

    height = height + iconHeight + topInfoHeight +  objectivesHeight + 5

    self.height = height
  end

  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame.level, target) then
      Theme:SkinText(self.frame.level, flags, string.format("LEVEL %i", self.level), state)
    end

    if Theme:NeedSkin(self.frame.timer, target) then
      Theme:SkinText(self.frame.timer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE + Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL, nil, state)
    end

    if Theme:NeedSkin(self.frame.plus2KeyLevelTimer, target) then
      Theme:SkinText(self.frame.plus2KeyLevelTimer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE, nil, state)
    end

    if Theme:NeedSkin(self.frame.plus3KeyLevelTimer, target) then
      Theme:SkinText(self.frame.plus3KeyLevelTimer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE, nil, state)
    end
  end

  __Arguments__ { String }
  function IsRegisteredSetting(self, option)
    if option == SHOW_DEATH_COUNT_OPTION or option == SHOW_TIMER_BAR_OPTION then
      return true
    end

    return super.IsRegisteredSetting(self, option)
  end

  __Arguments__ { String, Variable.Optional(), Variable.Optional() }
  function OnSetting(self, option, new, old)
    if option == SHOW_TIMER_BAR_OPTION then
      if new then
        self:ShowTimerBar()
      else
        self:HideTimerBar()
      end
    elseif option == SHOW_DEATH_COUNT_OPTION then
      if new and self.deathCount > 0 then
        self:ShowDeathCount()
      else
        self:HideDeathCount()
      end
    end
  end



  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    Theme:RegisterText(prefix..".level", self.frame.level)
    Theme:RegisterText(prefix..".timer", self.frame.timer)
    Theme:RegisterText(prefix..".timeLimit2Key", self.frame.plus2KeyLevelTimer)
    Theme:RegisterText(prefix..".timeLimit3Key", self.frame.plus3KeyLevelTimer)



    Theme:SkinText(self.frame.level, nil, self.level, state)
    Theme:SkinText(self.frame.timer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE + Theme.SkinFlags.TEXT_JUSTIFY_HORIZONTAL, nil, state)
    Theme:SkinText(self.frame.plus2KeyLevelTimer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE, nil, state)
    Theme:SkinText(self.frame.plus3KeyLevelTimer, Theme.SkinFlags.TEXT_FONT + Theme.SkinFlags.TEXT_SIZE, nil, state)


    -- Load options
    self:LoadSetting(SHOW_TIMER_BAR_OPTION)
    self:LoadSetting(SHOW_DEATH_COUNT_OPTION)
  end

  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  --- The Keystone level
  property "level"              { TYPE = Number, DEFAULT = 0, HANDLER = SetLevel }

  --- The number of affixes the key has
  property "numAffixes"         { TYPE = Number, DEFAULT = 0, HANDLER = SetNumAffixes }

  --  The current timer
  property "timer"              { TYPE = Number, DEFAULT = 0, HANDLER = SetTimer }

  --- The time limit where the group can finish the dungeon to upgrade the key
  property "timeLimit"          { TYPE = Number, DEFAULT = 0, HANDLER = SetTimeLimit }

  --- The time limit where the key will be upgraded by 2 levels
  property "timeLimit2Key"      { TYPE = Number, DEFAULT = 0 }

  --- The time limit where the key will be upgraded by 3 levels
  property "timeLimit3Key"      { TYPE = Number, DEFAULT = 0 }

  --- Time lost by death
  property "timeLost"           { TYPE = Number, DEFAULT = 0}

  --- The number of death
  property "deathCount"         { TYPE = Number, DEFAULT = 0, HANDLER = SetDeathCount }

  --- Is the keystone has been completed ?
  property "isCompleted"        { TYPE = Boolean, DEFAULT = false }

  --- The current mob point
  property "mobPoints"          { TYPE = Number, DEFAULT = 0 }

  --- The amount of mob points required
  property "mobPointsRequired"  { TYPE = Number, DEFAULT = 0 }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function BFAKeystoneBlock(self)
    super(self)
    self.text = "Mythic +"

    local topInfoFrame = CreateFrame("Frame", nil, self.frame.content)
    topInfoFrame:SetHeight(31)
    topInfoFrame:SetBackdrop(_Backdrops.Common)
    topInfoFrame:SetBackdropColor(0, 0, 0, 0.25)
    topInfoFrame:SetPoint("TOPLEFT")
    topInfoFrame:SetPoint("RIGHT")
    self.frame.topInfoFrame = topInfoFrame

    self.frame.ftex:SetPoint("TOPLEFT", topInfoFrame, "BOTTOMLEFT")

    local level = topInfoFrame:CreateFontString(nil, "OVERLAY", GameFontHighlightSmall)
    level:SetPoint("TOP")
    level:SetPoint("BOTTOM")
    level:SetPoint("LEFT", 5, 0)
    self.frame.level = level

    -- +2 Key timer
    local plus2KeyLevelTimer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plus2KeyLevelTimer:SetTextColor(38/255, 127/255, 0)
    plus2KeyLevelTimer:SetPoint("TOP", topInfoFrame, "BOTTOM", 0, -5)
    plus2KeyLevelTimer:SetFont(plus2KeyLevelTimer:GetFont(), 15)
    self.frame.plus2KeyLevelTimer = plus2KeyLevelTimer

    -- +3 Key Timer
    local plus3KeyLevelTimer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plus3KeyLevelTimer:SetTextColor(38/255, 127/255, 0)
    plus3KeyLevelTimer:SetPoint("LEFT", plus2KeyLevelTimer, "RIGHT", 16, 0)
    plus3KeyLevelTimer:SetFont(plus3KeyLevelTimer:GetFont(), 15)
    self.frame.plus3KeyLevelTimer = plus3KeyLevelTimer

    -- timer
    local timer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    timer:SetPoint("LEFT", self.frame.ftex, "RIGHT")
    timer:SetPoint("RIGHT")
    timer:SetFont(timer:GetFont(), 22, "OUTLINE")
    self.frame.timer = timer

    -- affixes anchor
    local affixes = CreateFrame("Frame", nil, self.frame.topInfoFrame)
    affixes:SetHeight(24)
    affixes:SetPoint("CENTER", topInfoFrame, "CENTER")
    self.frame.affixes = affixes

    -- Death
    local death = CreateFrame("Frame", nil, topInfoFrame)
    death:SetPoint("TOPRIGHT")
    death:SetPoint("BOTTOMRIGHT")
    death:SetWidth(38)
    death:SetScript("OnEnter", function(f)
      GameTooltip:SetOwner(f, "ANCHOR_TOPLEFT")
      GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(self.deathCount), 1, 1, 1)
      GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(GetTimeStringFromSeconds(self.timeLost, false, true)))
      GameTooltip:Show()
    end)

    death:SetScript("OnLeave", function(f) GameTooltip:Hide() end)
    death:Hide()
    self.frame.death = death

    local deathIcon = death:CreateTexture()
    deathIcon:SetAtlas("poi-graveyard-neutral", true)
    deathIcon:SetPoint("RIGHT", -20, 0)
    self.frame.deathIcon = deathIcon

    local deathCount = death:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall2")
    deathCount:SetPoint("LEFT", deathIcon, "RIGHT", 4, 0)
    self.frame.deathCount = deathCount


    self.affixes = Array[Affix]()

    Init(self)
  end
end)





__Block__ "keystone-basic" "keystone"
class "KeystoneBlock" (function(_ENV)
  inherit "DungeonBlock" extend "IObjectiveHolder"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetNumAffixes(self, new, old)
    if new > old then
      for i = 1, new - old do
        local affix = ObjectManager:Get(Affix)
        affix:SetParent(self.frame.affixes)
        self.affixes:Insert(affix)
      end
    elseif new < old then
      for i = 1, old - new do
        local affix = self:GetAffix(new + i)
        if affix then
          self.affixes:Remove(affix)
          affix.isReusable = true
        end
      end
    end
  end

  local function SetWasEnergized(self, new)
    if new then
      self.frame.redLine:Hide()
    else
      self.frame.redLine:Show()
    end
  end

  local function SetLevel(self, new)
    self.frame.level:SetText(string.format("LEVEL %i", new))
  end

  local function SetTimeLimit(self, new)
    self.timeLimit2Chest = new * 0.8
    self.timeLimit3Chest = new * 0.6

    self.frame.twoChestTimer:SetText(string.format("[2+] %s", GetTimeStringFromSeconds(self.timeLimit2Chest, false, true)))
    self.frame.threeChestTimer:SetText(string.format("[3+] %s", GetTimeStringFromSeconds(self.timeLimit3Chest, false, true)))
  end

  local function SetTimer(self, new)
    local strTimer = GetTimeStringFromSeconds(new, false, true)
    local strTimeLimit = GetTimeStringFromSeconds(self.timeLimit, false, true)

    -- Update the color for the 3 chest
    if new > self.timeLimit3Chest then
      self.frame.threeChestTimer:SetTextColor(1, 0, 0)
    else
      self.frame.threeChestTimer:SetTextColor(38/255, 127/255, 0)
    end

    if new > self.timeLimit2Chest then
      self.frame.twoChestTimer:SetTextColor(1, 0, 0)
    else
      self.frame.twoChestTimer:SetTextColor(38/255, 127/255, 0)
    end


    self.frame.timer:SetText(string.format("%s / %s", strTimer, strTimeLimit))
  end
  ------------------------------------------------------------------------------
  --                          Meta-Methods                                    --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  function GetAffix(self, index)
    return self.affixes[index]
  end

  function OnLayout(self)
    do
      local previousFrame
      for i = 1, self.numAffixes do
        local affix = self:GetAffix(i)
        if i == 1 then
          affix.frame:SetPoint("TOPLEFT", self.frame.affixes, "TOPLEFT")
          affix.frame:SetPoint("BOTTOMLEFT", self.frame.affixes, "BOTTOMLEFT")
        else
          affix.frame:SetPoint("TOPLEFT", previousFrame, "TOPRIGHT", 3, 0)
          affix.frame:SetPoint("BOTTOMLEFT", previousFrame, "BOTTOMRIGHT")
        end
        previousFrame = affix.frame
      end
    end

    do
      local previousFrame

      for index, obj in self.objectives:GetIterator() do
        obj:Hide()
        obj:ClearAllPoints()
        if index == 1 then
          obj:SetPoint("TOPLEFT", self.frame.ftex, "TOPRIGHT")
          obj:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
        else
          obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
          obj:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
        end
        obj:Show()
        previousFrame = obj.frame
      end
    end

    self:CalculateHeight()
  end


  function CalculateHeight(self)
    local height = self.baseHeight

    -- Get the icon height
    local iconHeight = self.frame.ftex:GetHeight()
    -- Get the objectivesHeight
    local objectivesHeight = self:GetObjectivesHeight()
    -- Get the top info height (level/ chest)
    local topInfoHeight = 29
    -- Get the affixes height
    local affixesHeight = 29


    height = height + topInfoHeight + affixesHeight + max(iconHeight, objectivesHeight) + 5

    self.height = height
  end



  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)

    -- Get the current state
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame.level, target) then
      Theme:SkinFrame(self.frame.level, flags, state)
    end
  end

  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterText(prefix..".level", self.frame.level)

    -- Then skin them
    Theme:SkinText(self.frame.level, nil, self.level, state)
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "level" { TYPE = Number, DEFAULT = 0, HANDLER = SetLevel }
  property "numAffixes" { TYPE = Number, DEFAULT = 0, HANDLER = SetNumAffixes }
  property "wasEnergized" { TYPE = Boolean, DEFAULT = true, HANDLER = SetWasEnergized }
  property "timer" { TYPE = Number, DEFAULT = 0, HANDLER = SetTimer }
  property "timeLimit" { TYPE = Number, DEFAULT = 0, HANDLER = SetTimeLimit }
  property "timeLimit2Chest" { TYPE = Number, DEFAULT = 0 }
  property "timeLimit3Chest" { TYPE = Number, DEFAULT = 0 }
  property "isCompleted" { TYPE = Boolean, DEFAULT = false }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function KeystoneBlock(self)
    super(self)
    self.text = "Mythic +"

    -- chest ( is depleted ?)
    local chest = self.frame.content:CreateTexture("Frame")
    chest:SetAtlas("ChallengeMode-icon-chest")
    chest:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 4, -4)
    chest:SetHeight(20)
    chest:SetWidth(20)
    self.frame.chest = chest

    -- redline when the keystone is depleted
    local redLine = self.frame.content:CreateTexture("Frame")
    redLine:SetAtlas("ChallengeMode-icon-redline")
    redLine:SetAllPoints(chest)
    redLine:Hide()
    self.frame.redLine = redLine

    -- level
    local level = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    level:SetPoint("TOPLEFT", chest, "TOPRIGHT", 4, 0)
    self.frame.level = level

    -- two chest timer
    local twoChestTimer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    twoChestTimer:SetText("[+2] 15:20")
    twoChestTimer:SetTextColor(38/255, 127/255, 0)
    twoChestTimer:SetPoint("TOP", self.frame.header, "BOTTOM", 0, -2)
    twoChestTimer:SetFont(twoChestTimer:GetFont(), 15)
    self.frame.twoChestTimer = twoChestTimer
    -- three chest timer
    local threeChestTimer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    threeChestTimer:SetText("[+3] 9:48")
    threeChestTimer:SetTextColor(38/255, 127/255, 0)
    threeChestTimer:SetPoint("LEFT", twoChestTimer, "RIGHT", 16, 0)
    threeChestTimer:SetFont(threeChestTimer:GetFont(), 15)
    self.frame.threeChestTimer = threeChestTimer

    -- affixes anchor
    local affixes = CreateFrame("Frame", nil, self.frame.content)
    affixes:SetHeight(29)
    affixes:SetWidth(29 * 3)
    affixes:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 4, -26)
    self.frame.affixes = affixes

    -- timer
    local timer = self.frame.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    timer:SetText("24:35.535 / 25:00")
    timer:SetPoint("LEFT", affixes, "RIGHT")
    timer:SetPoint("RIGHT", self.frame.header, "RIGHT")
    timer:SetFont(timer:GetFont(), 18, "OUTLINE")
    self.frame.timer = timer

    -- Move the dungeon icon
    self.frame.ftex:SetPoint("TOPLEFT", affixes, "BOTTOMLEFT", 0, -4)

    self.affixes = Array[Affix]()

    -- Init things (register, skin elements)
    Init(self)
  end
end)


function OnLoad(self)
  -- Register the options
  Settings:Register(SHOW_DEATH_COUNT_OPTION, true)
  Settings:Register(SHOW_TIMER_BAR_OPTION, true)
end
