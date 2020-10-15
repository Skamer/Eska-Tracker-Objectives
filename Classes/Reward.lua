--============================================================================--
--                          EskaTracker                                       --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker               --
--============================================================================--
Eska                    "EskaTracker.Classes.Reward"                          ""
--============================================================================--
namespace                   "EKT"
--============================================================================--
REWARD_SHOW_ICON_SETTING    = "reward-show-icon"
REWARD_ICON_SIZE_SETTING    = "reward-icon-size"
--============================================================================--
enum "RewardType" {
  EXP_REWARD = 1,
  ARTIFACT_EXP_REWARD = 2,
  CURRENCY_REWARD = 3,
  ITEM_REWARD = 4,
  MONEY_REWARD = 5,
}

__Recyclable__()
class "Reward" (function(_ENV)
  inherit "Frame"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "text" then
      --self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
      self.frame.text:SetText(new)
    elseif prop == "icon" then
      --self.frame.icon:SetTexture(new)
      self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
    elseif prop == "count" then
      self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
    elseif prop == "quality" then
      if self.type == RewardType.ITEM_REWARD then
        self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
      end
    elseif prop == "count" then
      self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
    elseif prop == "questID" or prop == "itemIndex" then
      self:UpdateTooltip()
    end
  end
  ------------------------------------------------------------------------------
  --                             Methods                                      --
  ------------------------------------------------------------------------------
  --[[function ShowIcon(self)
    if not self.frame.icon:IsShown() then
      self.frame.text:SetPoint("LEFT", self.frame.icon, "RIGHT", 5, 0)
      self.frame.icon:Show()
    end
  end

  function HideIcon(self)
    if self.frame.icon:IsShown() then
      self.frame.text:SetPoint("LEFT")
      self.frame.icon:Hide()
    end
  end--]]

  function UpdateTooltip(self)
    self.frame:SetScript("OnEnter", function(f)
      GameTooltip:SetOwner(f, "ANCHOR_LEFT")
      if self.type and self.type == RewardType.ITEM_REWARD and self.itemIndex > 0 and self.questID > 0 then
        GameTooltip:SetQuestLogItem("reward", self.itemIndex, self.questID)
        GameTooltip:Show()
      end
    end)
  end

  __Arguments__ { String }
  function GetRewardText(self, text)
    local txt
    if self.type == RewardType.ITEM_REWARD and self.quality > 1 then
      -- NOTE: 'hexColorStr' includes |c
      local hexColorStr = ITEM_QUALITY_COLORS[self.quality].hex
      if self.count > 1 then
        txt = string.format("%s%s|r x %i", hexColorStr, text, self.count)
      else
        txt = string.format("%s%s|r", hexColorStr, text)
      end
    elseif self.type == RewardType.MONEY_REWARD then
      return text
    else
      if self.count > 1 then
        txt = string.format("%s x %i", text, self.count)
      else
        txt = string.format("%s", text)
      end
    end

    -- Add icon
    if self.showIcon and self.icon then
      return string.format("|T%s:%i:%i:0:0:64:64:4:60:4:60|t %s", self.icon, self.iconSize, self.iconSize, txt)
    end
    return txt
  end

  __Arguments__ { Variable.Optional(Theme.SkinFlags, Theme.DefaultSkinFlags), Variable.Optional(String) }
  function OnSkin(self, flags, target)
    super.OnSkin(self, flags, target)
    local state = self:GetCurrentState()

    if Theme:NeedSkin(self.frame, target) then
      Theme:SkinFrame(self.frame, flags, state)
    end

    if Theme:NeedSkin(self.frame.text, target) then
      --[[if self.type == RewardType.ITEM_REWARD and self.quality > 1 then
        -- NOTE: 'hexColorStr' includes |c
        local hexColorStr = ITEM_QUALITY_COLORS[self.quality].hex
        if self.count > 1 then
          text = string.format("%s%s|r x %i", hexColorStr, self.text, self.count)
        else
          text = string.format("%s%s|r", hexColorStr, self.text)
        end
      else
        if self.count > 1 then
          text = string.format("%s x %i", self.text, self.count)
        else
          text = string.format("%s", self.text)
        end
      end--]]
      --flags = Utils.RemoveEnumFlag(flags, Theme.SkinFlags.TEXT_TRANSFORM)
      --Theme:SkinText(self.frame.text, flags, self.text, state)

      --if not self.type == RewardType.MONEY_REWARD then
        --local text = self:GetRewardText(Theme:GetTransformedText(self.text, Theme:GetElementID(self.frame.text), state))
        ---self.frame.text:SetText(text)
      --else
        --elf.frame.text:SetText(self.text)
      --end
      self.frame.text:SetText(self.text)
    end
  end

  function OnReset(self)
    super.OnReset(self)

    self.type       = nil
    self.count      = nil
    self.text       = nil
    self.icon       = nil
    self.quality    = nil
    self.itemIndex  = nil
    self.questID    = nil
  end

  __Arguments__ { String }
  function IsRegisteredSetting(self, setting)
    if setting == REWARD_SHOW_ICON_SETTING or setting == REWARD_ICON_SIZE_SETTING then
      return true
    end

    return super.IsRegisteredSetting(self, setting)
  end

  __Arguments__ { String, Variable.Optional(), Variable.Optional() }
  function OnSetting(self, setting, new, old)
    if setting == REWARD_SHOW_ICON_SETTING then
      self.showIcon = new
      self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
    elseif setting == REWARD_ICON_SIZE_SETTING then
      self.iconSize = new
      self:Skin(Theme.SkinFlags.TEXT_TRANSFORM, Theme:GetElementID(self.frame.text))
    end
  end

  function Init(self)
    local prefix = self:GetClassPrefix()
    local state  = self:GetCurrentState()

    -- Register frames in the theme system
    Theme:RegisterFrame(prefix..".frame", self.frame)
    Theme:RegisterText(prefix..".text", self.frame.text)

    -- Then skin them
    self:Skin()

    -- Load settings
    self:LoadSetting(REWARD_SHOW_ICON_SETTING)
    self:LoadSetting(REWARD_ICON_SIZE_SETTING)
  end
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "type"       { TYPE = RewardType }
  property "count"      { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "text"       { TYPE = String, DEFAULT = "", HANDLER = UpdateProps}
  property "icon"       { TYPE = Number + String, HANDLER = UpdateProps }
  property "quality"    { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "itemIndex"  { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "questID"    { TYPE = NaturalNumber, DEFAULT = 0, HANDLER = UpdateProps }
  property "showIcon"   { TYPE = Boolean, DEFAULT = true }
  property "iconSize"   { TYPE = NaturalNumber, DEFAULT = 18 }
  __Static__() property "_prefix" { DEFAULT = "reward" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Reward(self)
    super(self, CreateFrame("Frame", nil, nil, "BackdropTemplate"))
    self.frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    self.frame:SetBackdrop(_Backdrops.Common)

    --[[local icon = self.frame:CreateTexture()
    icon:SetWidth(18)
    icon:SetHeight(18)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetPoint("LEFT")
    self.frame.icon = icon
    self.frame.icon:Hide()--]]

    local text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetHeight(16)
    text:SetPoint("LEFT", 5, 0)
    text:SetPoint("RIGHT", -5, 0)
    text:SetJustifyH("LEFT")
    self.frame.text = text

    self.baseHeight = 24
    self.height     = self.baseHeight

    Init(self)
  end

end)

__Recyclable__()
class "Rewards" (function(_ENV)
  inherit "Frame"

  __Arguments__ { Reward }
  function AddReward(self, reward)
    reward:SetParent(self)
    reward.OnHeightChanged = function(_, new, old)
      self.height = self.height + (new - old)
    end

    self.rewards:Insert(reward)

    self:Draw()
  end

  function OnLayout(self)
    local previousFrame
    for index, reward in self.rewards:GetIterator() do
      reward:Hide()
      reward:ClearAllPoints()

      if index == 1 then
        reward:SetPoint("TOPLEFT")
        reward:SetPoint("TOPRIGHT")
      else
        reward:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        reward:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      reward:Show()

      previousFrame = reward.frame
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight
    for index, reward in self.rewards:GetIterator() do
      height = height + reward.height
    end
    self.height = height
  end

  function OnRecycle(self)
    super.OnRecycle(self)

    -- Reset rewards
    for _, reward in self.rewards:GetIterator() do
      reward:Recycle()
    end
    self.rewards:Clear()
  end
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Rewards(self)
    super(self, CreateFrame("Frame", nil, nil, "BackdropTemplate"))


    self.rewards = Array[Reward]()

  end
end)

function OnLoad(self)
  Settings:Register(REWARD_SHOW_ICON_SETTING, true)
  Settings:Register(REWARD_ICON_SIZE_SETTING, 18)
end
