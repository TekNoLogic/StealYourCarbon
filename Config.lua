
local NUMROWS, NUMCOLS, ICONSIZE, ICONGAP, GAP, EDGEGAP = 6, 10, 32, 3, 8, 16
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", "StealYourCarbonConfig", UIParent)
frame.name = "Steal Your Carbon"
frame:SetScript("OnShow", function(frame)
	local StealYourCarbon = StealYourCarbon
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Steal Your Carbon", "To add items to SYC's list, visit a merchant or type '/carbon add [Item Link] 20'.  Shift-click to add/remove a full satck.  Set the quantity to 0 to remove the item.")


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


	local listlabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	listlabel:SetPoint("TOPLEFT", upgradewater, "BOTTOMLEFT", EDGEGAP, -GAP)
	listlabel:SetText("Restock Items")

	local function OnClick(self)
		PlaySound("UChatScrollButton")
		local diff = (self.up and 1 or -1) * (IsShiftKeyDown() and select(8, GetItemInfo(self.row.id)) or 1)
		StealYourCarbon.db.stocklist[self.row.id] = StealYourCarbon.db.stocklist[self.row.id] + (diff)
		if StealYourCarbon.db.stocklist[self.row.id] == 0 then
			StealYourCarbon.db.stocklist[self.row.id] = 0
			self.row.down:Disable()
		else self.row.down:Enable() end
		self.row.count:SetText(StealYourCarbon.db.stocklist[self.row.id])
	end
	local rows = {}
	for i=1,NUMROWS do
		local row = CreateFrame("Frame", nil, frame)
		if i == 1 then row:SetPoint("TOP", listlabel, "BOTTOM", 0, -4)
		else row:SetPoint("TOP", rows[i-1], "BOTTOM", 0, -6) end
		if i <= NUMROWS then
			row:SetPoint("LEFT", frame, EDGEGAP, 0)
			row:SetPoint("RIGHT", frame, -EDGEGAP, 0)
		end
		row:SetHeight(ICONSIZE)
--~ 		row:SetScript("OnEnter", ShowItemDetails)
--~ 		row:SetScript("OnLeave", HideItemDetails)

		local icon = row:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT")
		icon:SetWidth(ICONSIZE)
		icon:SetHeight(ICONSIZE)
		icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")

		local count = row:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
		count:SetPoint("BOTTOMRIGHT", icon, -2, 2)

		local up = CreateFrame("Button", nil, row)
		up:SetPoint("TOPLEFT", icon, "TOPRIGHT", -6, 7)
		up:SetWidth(ICONSIZE/2 + 12) up:SetHeight(ICONSIZE/2 + 14)
		up:SetHitRectInsets(6, 6, 7, 7)
		up:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Up")
		up:SetPushedTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Down")
		up:SetHighlightTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollUpButton-Highlight")
		up:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
		up:GetHighlightTexture():SetBlendMode("ADD")
		up.row = row
		up.up = true
		up:SetScript("OnClick", OnClick)

		local down = CreateFrame("Button", nil, row)
		down:SetPoint("TOPLEFT", up, "BOTTOMLEFT", 0, 14)
		down:SetWidth(ICONSIZE/2 + 12) down:SetHeight(ICONSIZE/2 + 14)
		down:SetHitRectInsets(6, 6, 7, 7)
		down:SetNormalTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Up")
		down:SetPushedTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Down")
		down:SetHighlightTexture("Interface\\MainMenuBar\\UI-MainMenu-ScrollDownButton-Highlight")
		down:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
		down:GetHighlightTexture():SetBlendMode("ADD")
		down.row = row
		down:SetScript("OnClick", OnClick)

		local name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		name:SetPoint("TOPLEFT", up, "TOPRIGHT", GAP-6, -7)
		name:SetPoint("RIGHT", row)
		name:SetJustifyH("LEFT")

		local stack = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		stack:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		stack:SetPoint("RIGHT", row)
		stack:SetJustifyH("LEFT")
		stack:SetText("Stack Size: 20")

		rows[i], row.icon, row.count, row.name, row.stack, row.down = row, icon, count, name, stack, down
	end

	local function OnShow(self)
		local offset = 0
		local id, qty = next(StealYourCarbon.db.stocklist)
		for i=1,offset-1 do id, qty = next(StealYourCarbon.db.stocklist, id) end

		for _,row in ipairs(rows) do
			if id then
				row.id = id
				local _, link, _, _, _, _, _, stack, _, texture = GetItemInfo(id)
				row.icon:SetTexture(texture)
				row.count:SetText(qty)
				row.name:SetText(link)
				row.stack:SetText("Stack Size: "..stack)
				row:Show()
				id, qty = next(StealYourCarbon.db.stocklist, id)
			else
				row:Hide()
			end
		end
	end
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", function() for i,v in pairs(StealYourCarbon.db.stocklist) do if v == 0 then StealYourCarbon.db.stocklist[i] = nil end end end)
	OnShow(f)
end)


StealYourCarbon.configframe = frame
InterfaceOptions_AddCategory(frame)
