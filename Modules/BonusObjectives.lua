--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Scorpio              "EskaTracker.Objectives.BonusObjectives"                 ""
--============================================================================--
import                            "EKT"
--============================================================================--
IsWorldQuest = QuestUtils_IsQuestWorldQuest
IsQuestTask  = IsQuestTask
--============================================================================--
function OnLoad(self)
  -- Check if the player is in a bonus quest
  self._Enabled = self:HasBonusQuest()
end

function OnEnable(self)

end 


function HasBonusQuest(self)
  for i = 1, GetNumQuestLogEntries() do
    local id = select(8, GetQuestLogTitle(i))
    if IsQuestTask(id) and not IsWorldQuest(id) then
      return true
    end
  end

  return false
end
