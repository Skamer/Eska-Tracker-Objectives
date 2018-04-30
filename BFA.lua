--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio             "EskaTracker.Objectives.BFA"                              ""
--============================================================================--
namespace           "EKT"
--============================================================================--
-- This file is used for overriding the 'BFASupport' class if needed
class "BFASupport" (function(_ENV)

  ------------------------------------------------------------------------------
  --                             Quests                                       --
  ------------------------------------------------------------------------------
  __Arguments__ { ClassType, Number }
  __Static__() function ShowQuestDetailsWithMap(self, questID)
    if self.isBFA then
      QuestMapFrame_OpenToQuestDetails(questID)
    else
      ShowQuestLog()
      QuestMapFrame_ShowQuestDetails(questID)
    end
  end

end)
