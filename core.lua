-- [[ ADDONS + // 2100 // FIXED RESIZE & TRANSPARENCY ]] --
SynapseDB = SynapseDB or { 
    autoSell = true, autoRepair = true, autoAccept = true, 
    hideError = true, fastLoot = true, zoom = true,
    firstRun = true, w = 380, h = 300, goldStart = 0,
    iconX = 0, iconY = -100 
}

local APEX = CreateFrame("Frame", "AddonsPlusHUD", UIParent, "BackdropTemplate")
APEX.nodes = {}

local function GetRGB()
    local t = GetTime() * 0.5
    return math.sin(t)*0.5+0.5, math.sin(t+2)*0.5+0.5, math.sin(t+4)*0.5+0.5
end

-- [[ 1. THE STABLE GUI ]] --
function APEX:Build()
    if self.built then return end
    self:SetSize(SynapseDB.w, SynapseDB.h)
    self:SetPoint("CENTER")
    self:SetFrameStrata("HIGH")
    self:SetClampedToScreen(true)
    self:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2})
    self:SetBackdropColor(0, 0, 0, 0.84) -- 10% more transparent (Standard was ~0.95)
    
    -- DRAG & MODERN RESIZE
    self:SetMovable(true); self:SetResizable(true); self:EnableMouse(true)
    -- NEW API FIX: SetResizeBounds replaces SetMinResize/SetMaxResize
    if self.SetResizeBounds then
        self:SetResizeBounds(320, 240, 600, 500)
    end
    
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", self.StopMovingOrSizing)

    -- RESIZE GRABBER (Bottom Right)
    local rb = CreateFrame("Button", nil, self)
    rb:SetPoint("BOTTOMRIGHT", -2, 2); rb:SetSize(16, 16)
    rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    rb:SetScript("OnMouseDown", function() self:StartSizing("BOTTOMRIGHT") end)
    rb:SetScript("OnMouseUp", function() 
        self:StopMovingOrSizing() 
        SynapseDB.w, SynapseDB.h = self:GetSize() 
    end)

    -- X CLOSE BUTTON
    self.close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
    self.close:SetPoint("TOPRIGHT", -2, -2)
    self.close:SetScript("OnClick", function() self:Hide() end)

    -- HEADER
    local t = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("TOPLEFT", 15, -15); t:SetText("|cffffffffADDONS|r |cff00ffff+|r")
    
    -- DYNAMIC ELEMENTS (Corner Anchored)
    self.goldText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.goldText:SetPoint("BOTTOMRIGHT", -15, 38)
    
    self.credit = self:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    self.credit:SetPoint("BOTTOMRIGHT", -15, 18); self.credit:SetText("Created by |cffffffffDurty#21402|r")

    self.joke = self:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    self.joke:SetPoint("BOTTOMLEFT", 15, 18)
    self.joke:SetText("At least I have chicken...")

    -- NODE CONTAINER
    self.list = CreateFrame("Frame", nil, self)
    self.list:SetPoint("TOPLEFT", 15, -50); self.list:SetPoint("BOTTOMRIGHT", -15, 60)
    self:Populate()

    -- SYNC LOOP
    self:SetScript("OnUpdate", function(self)
        local r, g, b = GetRGB()
        self:SetBackdropBorderColor(r, g, b, 0.8)
        self.credit:SetTextColor(r, g, b, 1)
        self.joke:SetTextColor(r, g, b, 0.7)
        if AddonsPlusMinimapBtn then AddonsPlusMinimapBtn.border:SetVertexColor(r, g, b) end
        local diff = GetMoney() - (SynapseDB.goldStart or GetMoney())
        self.goldText:SetText("Session: " .. (diff > 0 and "|cff00ff00+" or "|cffffffff") .. GetCoinTextureString(diff) .. "|r")
    end)

    self.built = true
end

function APEX:CreateNode(key, label, index)
    local cb = CreateFrame("CheckButton", "APNode"..index, self.list, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 0, -(index-1)*32)
    cb:SetScale(0.85) -- Slightly smaller to fit the sleeker GUI
    cb:SetChecked(SynapseDB[key])
    cb:SetScript("OnClick", function(s) 
        SynapseDB[key] = s:GetChecked() 
        if key == "zoom" then SetCVar("cameraDistanceMaxZoomFactor", s:GetChecked() and 2.6 or 1.9) end
    end)
    _G[cb:GetName().."Text"]:SetText("|cffffffff"..label.."|r")
end

function APEX:Populate()
    local opts = {{"autoSell", "LIQUIDATE JUNK"},{"autoRepair", "AUTO-REPAIR"},{"autoAccept", "NEURAL QUESTING"},{"hideError", "SILENCE ERRORS"},{"fastLoot", "VECTOR LOOT"},{"zoom", "ORBITAL ZOOM"}}
    for i, o in ipairs(opts) do self:CreateNode(o[1], o[2], i) end
end

-- [[ 2. MINIMAP BUTTON ]] --
local MiniBtn = CreateFrame("Button", "AddonsPlusMinimapBtn", UIParent)
MiniBtn:SetSize(32, 32); MiniBtn:SetFrameStrata("MEDIUM"); MiniBtn:SetMovable(true); MiniBtn:EnableMouse(true); MiniBtn:SetClampedToScreen(true)
MiniBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

MiniBtn.back = MiniBtn:CreateTexture(nil, "BACKGROUND")
MiniBtn.back:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
MiniBtn.back:SetVertexColor(0, 0, 0, 1); MiniBtn.back:SetSize(28, 28); MiniBtn.back:SetPoint("CENTER")

MiniBtn.border = MiniBtn:CreateTexture(nil, "OVERLAY")
MiniBtn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
MiniBtn.border:SetSize(54, 54); MiniBtn.border:SetPoint("CENTER", 11, -11)

MiniBtn.icon = MiniBtn:CreateTexture(nil, "ARTWORK")
MiniBtn.icon:SetTexture("Interface\\Icons\\inv_misc_coin_01")
MiniBtn.icon:SetSize(20, 20); MiniBtn.icon:SetPoint("CENTER")

local mask = MiniBtn:CreateMaskTexture()
mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOEDGE", "CLAMPTOEDGE")
mask:SetAllPoints(MiniBtn.icon); MiniBtn.icon:AddMaskTexture(mask)

function MiniBtn:RestorePosition()
    self:ClearAllPoints()
    if SynapseDB.iconX and SynapseDB.iconY then self:SetPoint("CENTER", UIParent, "CENTER", SynapseDB.iconX, SynapseDB.iconY)
    else self:SetPoint("RIGHT", Minimap, "LEFT", -20, 0) end
end

MiniBtn:RegisterForDrag("RightButton")
MiniBtn:SetScript("OnDragStart", function(self) self:StartMoving() end)
MiniBtn:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); local _, _, _, x, y = self:GetPoint(); SynapseDB.iconX, SynapseDB.iconY = x, y end)
MiniBtn:SetScript("OnClick", function(_, btn) if btn == "LeftButton" then if AddonsPlusHUD:IsShown() then AddonsPlusHUD:Hide() else AddonsPlusHUD:Show() end end end)

-- [[ 3. ENGINE ]] --
local MCU = CreateFrame("Frame")
MCU:RegisterAllEvents()
MCU:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then 
        SynapseDB.goldStart = GetMoney(); APEX:Build(); MiniBtn:RestorePosition()
        if SynapseDB.zoom then SetCVar("cameraDistanceMaxZoomFactor", 2.6) end
        if SynapseDB.firstRun then APEX:Show(); SynapseDB.firstRun = false else APEX:Hide() end
    elseif event == "MERCHANT_SHOW" and SynapseDB.autoSell then
        for b = 0, 4 do for s = 1, C_Container.GetContainerNumSlots(b) do
            local info = C_Container.GetContainerItemInfo(b, s)
            if info and info.quality == 0 then C_Container.UseContainerItem(b, s) end
        end end
        if SynapseDB.autoRepair then RepairAllItems(CanGuildBankRepair()) end
    elseif event == "UI_ERROR_MESSAGE" and SynapseDB.hideError then UIErrorsFrame:Clear()
    elseif event == "LOOT_READY" and SynapseDB.fastLoot then for i = GetNumLootItems(), 1, -1 do LootSlot(i) end
    elseif SynapseDB.autoAccept then
        if event == "GOSSIP_SHOW" then
            local av = C_GossipInfo.GetAvailableQuests()
            if av and av[1] then C_GossipInfo.SelectAvailableQuest(av[1].questID) end
        elseif event == "QUEST_DETAIL" then AcceptQuest()
        elseif event == "QUEST_PROGRESS" and IsQuestCompletable() then CompleteQuest()
        elseif event == "QUEST_COMPLETE" then GetQuestReward(1) end
    end
end)

SLASH_APLUS1 = "/ap"; SlashCmdList["APLUS"] = function() if AddonsPlusHUD:IsShown() then AddonsPlusHUD:Hide() else AddonsPlusHUD:Show() end end