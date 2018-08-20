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
