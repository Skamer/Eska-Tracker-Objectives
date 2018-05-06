--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio                "EskaTracker.Classes.Keystone"                         ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
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

    self.height = 29
    self.width  = 29
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
