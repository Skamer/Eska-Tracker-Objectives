--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio             "EskaTracker.Objectives.Utils"                            ""
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

    __Arguments__ { Number, Variable.Optional(Number) }
    __Static__() function IsQuestOnMap(questID, mapID)
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
      end

      return false
    end
  end)
  ------------------------------------------------------------------------------
  --                             Instance                                     --
  ------------------------------------------------------------------------------
  class "Instance" (function(_ENV)

    __Static__() function GetCurrentInstance()
      local mapID = C_Map.GetBestMapForUnit("player")
      return EJ_GetInstanceForMap(mapID)
    end
  end)
end)
