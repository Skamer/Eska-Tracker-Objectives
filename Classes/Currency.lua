--============================================================================--
--                          EskaTracker                                       --
-- Author     : Skamer <https://mods.curse.com/members/DevSkamer>             --
-- Website    : https://wow.curseforge.com/projects/eskatracker               --
--============================================================================--
Eska                    "EskaTracker.Classes.Currency"                      ""
--============================================================================--
namespace                      "EKT"
--============================================================================--
__Recyclable__()
class "Currency" (function(_ENV)
    inherit "Frame"

    local function UpdateProps(self, new, old, prop)
        if prop == "icon" then 
            self.frame.icon:SetTexture(new)
        elseif prop == "displayAmount" then 
            self.frame.text:SetText(new)
        end
    end 

    function OnReset(self)
        super.OnReset(self)

        self.id             = nil
        self.name           = nil
        self.desc           = nil
        self.icon           = nil
        self.quality        = nil
        self.displayAmount  = nil
        self.actualAmount   = nil
    end
    ------------------------------------------------------------------------------
    --                         Properties                                       --
    ------------------------------------------------------------------------------
    property "id" { TYPE = Number }
    property "name" { TYPE = String, DEFAULT = "" }
    property "desc" { TYPE = String, DEFAULT = "" }
    property "icon" { TYPE = String + Number, HANDLER = UpdateProps }
    property "quality" { TYPE = Number }
    property "displayAmount" { TYPE = Number, DEFAULT = 0, HANDLER = UpdateProps}
    property "actualAmount" { TYPE = Number, DEFAULT = 0,}
    __Static__() property "_prefix" { DEFAULT = "currency" }

    function Currency(self)
        super(self, CreateFrame("Frame", nil, nil, "BackdropTemplate"))

        local icon = self.frame:CreateTexture()
        icon:SetTexture(self.icon)
        icon:SetWidth(20)
        icon:SetHeight(20)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:SetPoint("CENTER", -10, 0)
        self.frame.icon = icon
        
        local text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        text:SetPoint("TOP")
        text:SetPoint("BOTTOM")
        text:SetText(self.displayAmount)
        text:SetTextColor(255, 208/255, 0)
        self.frame.text = text

        self.baseHeight = 28
        self.height = self.baseHeight
    end 
end)


__Recyclable__()
class "Currencies" (function(_ENV)
    inherit "Frame"

    __Arguments__ { Number }
    function GetCurrency(self, id)
        for _, currency in self.currencies:GetIterator() do 
            if currency.id == id then 
                return currency, false
            end
        end
        
        local currency = ObjectManager:Get(Currency)
        currency.id = id 
        currency:SetParent(self)

        self.currencies:Insert(currency)

        self:Layout()

        return currency, true
    end

    function OnLayout(self)
        local previousFrame 
        for index, currency in self.currencies:GetIterator() do 
            currency:Hide()
            currency:ClearAllPoints()

            if index == 1 then 
                currency:SetPoint("TOP", 0, -2)
                currency:SetPoint("LEFT")
                currency:SetPoint("RIGHT")
            else 
                currency:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
                currency:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
            end 

            currency:Show()

            previousFrame = currency.frame 
        end 

        self:CalculateHeight()
    end

    function CalculateHeight(self)
        local height = self.baseHeight
        for index, currency in self.currencies:GetIterator() do 
            height = height + currency.height 
        end 

        self.height = height
    end

    function OnRecycle(self)
        super.OnRecycle(self)

        -- Reset currencies 
        for _, currency in self.currencies:GetIterator() do
            currency:Recycle()
        end 

        self.currencies:Clear() 
    end

    function Init(self)
        local prefix = self:GetClassPrefix()
        local state = self:GetCurrentState()

        Theme:RegisterFrame(prefix..".frame", self.frame)

        Theme:SkinFrame(self.frame, nil, state)
    end

     __Static__() property "_prefix" { DEFAULT = "currencies" }
    ------------------------------------------------------------------------------
    --                            Constructors                                  --
    ------------------------------------------------------------------------------
    function Currencies(self)
        super(self, CreateFrame("Frame", nil, nil, "BackdropTemplate"))
        self.frame:SetBackdrop(_Backdrops.Common)

        self.currencies = Array[Currency]()
        self.baseHeight = 4 
        self.height = 4

        Init(self)
    end
end)
