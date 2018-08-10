--============================================================================--
--                         EskaTracker : Objectives                           --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker-objectives    --
--============================================================================--
Eska                   "EskaTracker.Classes.WorldQuest"                       ""
--============================================================================--
namespace                        "EKT"
--============================================================================--
__Recyclable__()
class "WorldQuest" (function(_ENV)
  inherit "Quest"
  _WorldQuestCache = setmetatable({}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "world-quest"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function WorldQuest(self)
    super(self)
    -- Keep it in the cache
    _WorldQuestCache[self] = true

    -- Hide the level
    self:HideLevel()
  end
end)
