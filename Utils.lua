--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                "EskaTracker.Objectives.Utils"                            ""
--============================================================================--
namespace                  "EKT"
--============================================================================--
--- Enhance the 'Utils' class provided by the addon core.
class "Utils" (function(_ENV)
  ------------------------------------------------------------------------------
  --                             Quests                                       --
  ------------------------------------------------------------------------------
  class "Quest" (function(_ENV)

    __Arguments__ { Number }
    __Static__() function ShowQuestDetailsWithMap(questID)
      QuestMapFrame_OpenToQuestDetails(questID)
    end

    __Arguments__ { Number, Variable.Optional(Number), Variable.Optional(Boolean, false) }
    __Static__() function IsQuestOnMap(questID, mapID, strict)
      mapID = mapID or C_Map.GetBestMapForUnit("player")
      if mapID then
        local questsOnMap = C_QuestLog.GetQuestsOnMap(mapID)
        if questsOnMap then
          for index, questInfo in ipairs(questsOnMap) do
            if questInfo.questID == questID then
              return true
            end
          end
        end

        if not strict then
          local mapInfo = C_Map.GetMapInfo(mapID)
          if mapInfo.mapType == 5 then -- 5 -> cave
            return IsQuestOnMap(questID, mapInfo.parentMapID, true)
          end

          -- Make something for dungeon
        end

      end

      return false
    end

    EnumQuestTag = _G.Enum.QuestTag
    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsDungeonQuest(questID, questTag)
      if not questTag then
        questTag = GetQuestTagInfo(questID)
      end

      if questTag == EnumQuestTag.Dungeon then
        return true
      end

      return false
    end

    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsRaidQuest(questID, questTag)
      if not questTag then
        questTag = GetQuestTagInfo(questID)
      end

      if questTag == EnumQuestTag.Raid then
        return  true
      end

      return false
    end

    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsInstanceQuest(questID, questTag)
      if not questTag then
        questTag = GetQuestTagInfo(questID)
      end

      if IsDungeonQuest(questID, questTag) or IsRaidQuest(questID, questTag) then
        return true
      end

      return false
    end

    __Arguments__ { Number }
    __Static__() function IsLegionAssaultQuest(questID)
      return (questID == 45812) -- Assault on Val'sharah
          or (questID == 45838) -- Assault on Azsuna
          or (questID == 45840) -- Assault on Highmountain
          or (questID == 45839) -- Assault on StormHeim
          or (questID == 45406) -- StomHeim : The Storm's Fury
          or (questID == 46110) -- StomHeim : Battle for Stormheim
    end


    __Arguments__ { Number }
    __Static__() function GetRewardsData(questID)
      local data = {}

      -- Experience
      local xp = GetQuestLogRewardXP(questID)
      if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
        local t = {}
        t.type    = RewardType.EXP_REWARD
        t.label   = xp
        t.icon    = "Interface\\Icons\\XP_Icon"
        t.count   = 0
        tinsert(data, t)
      end
      -- Artifact Experience
      local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID)
      if artifactXP > 0 then
        local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory)
        local t = {}
        t.type  = RewardType.ARTIFACT_EXP_REWARD
        t.label = artifactXP
        t.icon  = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        t.count = 0
        tinsert(data, t)
      end
      -- Currencies
      local numCurrencies = GetNumQuestLogRewardCurrencies(questID)
      for i = 1, numCurrencies do
        local name, icon, count = GetQuestLogRewardCurrencyInfo(i, questID)
        local t = {}
        t.type  = RewardType.CURRENCY_REWARD
        t.label = name
        t.icon  = icon
        t.count = count
        tinsert(data, t)
      end
      -- Items
      local numItems = GetNumQuestLogRewards(questID);
      for i = 1, numItems do
        local name, icon, count, quality, isUsable = GetQuestLogRewardInfo(i, questID);
        local t = {}
        t.type      = RewardType.ITEM_REWARD
        t.label     = name
        t.icon      = icon
        t.count     = count
        t.questID   = questID
        t.itemIndex = i
        t.quality   = quality
        tinsert(data, t)
      end
      -- Money
      local money = GetQuestLogRewardMoney(questID)
      if money > 0 then
        local t = {}
        t.type    = RewardType.MONEY_REWARD
        t.label   = GetMoneyString(money)
        t.texture = "Interface\\Icons\\inv_misc_coin_01"
        t.count   = 0
        tinsert(data, t)
      end

      return data
    end
  end)
  ------------------------------------------------------------------------------
  --                             Instance                                     --
  ------------------------------------------------------------------------------
  class "Instance" (function(_ENV)

    __Static__() function GetCurrentInstance()
      local mapID = C_Map.GetBestMapForUnit("player")
      if mapID then
        return EJ_GetInstanceForMap(mapID)
      end
    end

    __Static__() function IsInstanceMap(mapID)
      if mapID then
        return EJ_GetInstanceForMap(mapID) ~= 0
      end

      return false
    end
  end)
end)
