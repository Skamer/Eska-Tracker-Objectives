--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                  "EskaTracker.Objectives.TomTom"                         ""
--============================================================================--
namespace                       "EKT"
--============================================================================--
IsWorldQuest = QuestUtils_IsQuestWorldQuest
--============================================================================--
--                              TomTom                                        --
--        https://www.curseforge.com/wow/addons/tomtom                        --
--============================================================================--
interface "TomTomAddon" (function(_ENV)
  function IsLoaded()
    if TomTom then
      return true
    else
      return false
    end
  end

  function GetPOIArrivalDistance()
      return TomTom.profile.poi.arrival
  end

  QuestWaypoints = {}
  function AddQuestWaypoint(questID)
    local cvar = GetCVarBool("questPOI")
    SetCVar("questPOI", 1)

    QuestPOIUpdateIcons()

    local map, title, completed, x, y
    if IsWorldQuest(questID) then
      title = C_TaskQuest.GetQuestInfoByQuestID(questID)
      x, y = C_TaskQuest.GetQuestLocation(questID)
      map = select(2, C_TaskQuest.GetQuestZoneID(questID))
      completed = false
    else
      title =  C_QuestLog.GetQuestInfo(questID)
      completed, x, y = QuestPOIGetIconInfo(questID)

      if WorldMapFrame:IsShown() then
          map = WorldMapFrame:GetMapID()
      else
          map = C_Map.GetBestMapForUnit("player")
      end
    end

    if completed then
      title = "Turn in: " .. title
    end

    if not x or not y then
      return
    end

    local key = TomTom:GetKeyArgs(m, x, y, title)
    local alreadySet = false
    if QuestWaypoints[key] then
      local uid = QuestWaypoints[key]
      if TomTom:IsValidWaypoint(uid) then
        alreadySet = true
      end
    end

    if not alreadySet then
      local uid = TomTom:AddWaypoint(map, x, y, {
        title = title,
        arrivaldistance = GetPOIArrivalDistance(),
      })
      QuestWaypoints[key] = uid
    else
      local uid = QuestWaypoints[key]
      TomTom:SetCrazyArrow(uid, GetPOIArrivalDistance(), title)
    end

    SetCVar("questPOI", cvar and 1 or 0)
  end

end)

__Action__ "tomtom-addon-add-quest-waypoint" "Set waypoint"
class "TomTomAddonAddQuestWayPointAction" (function(_ENV)

  __Arguments__ { Number }
  __Static__() function Exec(questID)
    TomTomAddon.AddQuestWaypoint(questID)
  end

  __Arguments__ { Quest }
  __Static__() function Exec(quest)
    TomTomAddonAddQuestWayPointAction.Exec(quest.id)
  end
end)
