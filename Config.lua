
local NUMROWS, NUMCOLS, ICONSIZE, ICONGAP, GAP, EDGEGAP = 3, 10, 32, 3, 8, 16
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", "StealYourCarbonConfig", UIParent)
frame.name = "Steal Your Carbon"
frame:SetScript("OnShow", function(frame)
	local StealYourCarbon = StealYourCarbon
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Steal Your Carbon", "To add items to SYC's list, drop them in the slots below.  Click an item to edit it's quantity.  Set the quantity to 0 to remove the item.")


	local overstock = tekcheck.new(frame, nil, "Overstock items", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	overstock.tiptext = "Ensure that the quantity specified is always purchased (will buy extra items if vendor does not sell the exact quantity you need)."
	local checksound = overstock:GetScript("OnClick")
	overstock:SetScript("OnClick", function(self) checksound(self); StealYourCarbon.db.overstock = not StealYourCarbon.db.overstock end)
	overstock:SetChecked(StealYourCarbon.db.overstock)


	local chatter = tekcheck.new(frame, nil, "Chat feedback", "TOP", overstock, "TOP")
	chatter:SetPoint("LEFT", frame, "TOP", GAP, 0)
	chatter.tiptext = "Give chat feedback when purchasing items."
	chatter:SetScript("OnClick", function(self) checksound(self); StealYourCarbon.db.chatter = not StealYourCarbon.db.chatter end)
	chatter:SetChecked(StealYourCarbon.db.chatter)


	local upgradewater = tekcheck.new(frame, nil, "Upgrade water", "TOPLEFT", overstock, "BOTTOMLEFT", 0, -GAP)
	upgradewater.tiptext = "Automatically upgrade to better water as player levels."
	upgradewater:SetScript("OnClick", function(self) checksound(self); StealYourCarbon.db.upgradewater = not StealYourCarbon.db.upgradewater end)
	upgradewater:SetChecked(StealYourCarbon.db.upgradewater)


	frame.items = {}
	for line=NUMROWS,1,-1 do
		for col=1,NUMCOLS do
			local i = (line-1)*NUMCOLS + col
			local l = CreateFrame("CheckButton", nil, frame)
			if i == (NUMCOLS * (NUMROWS - 1) + 1) then l:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", EDGEGAP, EDGEGAP)
			elseif col == 1 then l:SetPoint("BOTTOM", frame.items[i+NUMCOLS], "TOP", 0, ICONGAP)
			else l:SetPoint("LEFT", frame.items[i-1], "RIGHT", ICONGAP, 0) end
--~ 			l:SetPoint("RIGHT", -EDGEGAP, 0)
			l:SetHeight(ICONSIZE)
			l:SetWidth(ICONSIZE)
--~ 			l:SetScript("OnEnter", ShowItemDetails)
--~ 			l:SetScript("OnLeave", HideItemDetails)

			l.icon = l:CreateTexture(nil, "ARTWORK")
			l.icon:SetAllPoints()
--~ 			l.icon:SetPoint("TOPLEFT")
--~ 			l.icon:SetWidth(ICONSIZE)
--~ 			l.icon:SetHeight(ICONSIZE)
			l.icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")

	--~ 		l.name = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	--~ 		l.name:SetPoint("TOPLEFT", l.icon, "TOPRIGHT", 5, 0)
	--~ 		l.name:SetText("TEST")
	--~ 		l.count = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	--~ 		l.count:SetPoint("TOPLEFT", l.icon, "TOPRIGHT", 5, -12)
	--~ 		l.count:SetText(20)

			frame.items[i] = l
		end
	end

	local OnShow = function(self)
--~ 		local i = 0
--~ 		for id,qty in pairs(StealYourCarbon.db.stocklist) do
--~ 			i = i + 1
--~ 		end
	end
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", function() for i,v in pairs(StealYourCarbon.db.stocklist) do if v == 0 then StealYourCarbon.db.stocklist[i] = nil end end end)
	OnShow(f)
end)


StealYourCarbon.configframe = frame
InterfaceOptions_AddCategory(frame)
