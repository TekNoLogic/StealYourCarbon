
local myname, ns = ...
local tektab = LibStub("tekKonfig-TopTab")
local NUMROWS, NUMCOLS, ICONSIZE, ICONGAP, GAP, EDGEGAP = 11, 10, 32, 3, 8, 16
local rows, offset, scrollbar = {}, 0


function ns.GenerateRestockPanel(frame)
	local group = LibStub("tekKonfig-Group").new(frame, "Restocking list")

	local clickbutt = CreateFrame("Button", nil, group)
	clickbutt:SetAllPoints()

	local function OnReceiveDrag()
		local infotype, itemid, itemlink = GetCursorInfo()
		local stocklist = StealYourCarbon.db.stocklist
		if infotype == "item" then stocklist[itemid] = select(8, GetItemInfo(itemid))
		elseif infotype == "merchant" then
			local itemlink = GetMerchantItemLink(itemid)
			itemid = tonumber(itemlink:match("item:(%d+):"))
			stocklist[itemid] = select(8, GetItemInfo(itemid))
		end
		ns.UpdateConfigList()
		return ClearCursor()
	end
	local function OnClick(self)
		PlaySound("UChatScrollButton")
		local diff = (self.up and 1 or -1) * (IsModifiedClick() and select(8, GetItemInfo(self.row.id)) or 1)
		local stocklist = StealYourCarbon.db.stocklist
		stocklist[self.row.id] = stocklist[self.row.id] + (diff)
		if stocklist[self.row.id] <= 0 then
			stocklist[self.row.id] = 0
			self.row.down:Disable()
		else self.row.down:Enable() end
		self.row.count:SetText(stocklist[self.row.id])
	end
	local function OnClick2() if GetCursorInfo() == "item" or GetCursorInfo() == "merchant" then OnReceiveDrag() end end
	local function ShowTooltip(self)
		if not self.row.id then return end
		local _, link = GetItemInfo(self.row.id)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(link)
	end
	local function HideTooltip() GameTooltip:Hide() end
	for i=1,NUMROWS do
		local row = CreateFrame("Frame", nil, group)
		if i == 1 then row:SetPoint("TOP", group, "TOP", 0, -EDGEGAP)
		else row:SetPoint("TOP", rows[i-1], "BOTTOM", 0, -6) end
		row:SetPoint("LEFT", group, EDGEGAP, 0)
		row:SetPoint("RIGHT", group, -EDGEGAP-16, 0)
		row:SetHeight(ICONSIZE)

		local iconbutton = CreateFrame("Button", nil, row)
		iconbutton:SetPoint("TOPLEFT")
		iconbutton:SetWidth(ICONSIZE)
		iconbutton:SetHeight(ICONSIZE)
		iconbutton.row = row
		iconbutton:SetScript("OnEnter", ShowTooltip)
		iconbutton:SetScript("OnLeave", HideTooltip)
		iconbutton:SetScript("OnReceiveDrag", OnReceiveDrag)
		iconbutton:SetScript("OnClick", OnClick2)

		local buttonback = iconbutton:CreateTexture(nil, "ARTWORK")
		buttonback:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		buttonback:SetPoint("CENTER")
		buttonback:SetWidth(ICONSIZE*64/37) buttonback:SetHeight(ICONSIZE*64/37)

		local icon = iconbutton:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()

		local count = iconbutton:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
		count:SetPoint("BOTTOMRIGHT", -2, 2)

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

		rows[i], row.icon, row.count, row.name, row.stack, row.down, row.up = row, icon, count, name, stack, down, up
	end

	scrollbar = LibStub("tekKonfig-Scroll").new(group, 6, 1)

	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		ns.UpdateConfigList()
		return f(self, value, ...)
	end)

	clickbutt:EnableMouseWheel()
	clickbutt:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val*3) end)
	clickbutt:RegisterForDrag("LeftButton")
	clickbutt:SetScript("OnClick", OnClick2)
	clickbutt:SetScript("OnReceiveDrag", OnReceiveDrag)

	group:SetScript("OnShow", ns.UpdateConfigList)
	group:SetScript("OnHide", function()
		for i,v in pairs(StealYourCarbon.db.stocklist) do if v == 0 then StealYourCarbon.db.stocklist[i] = nil end end
	end)

	return group
end


local firsttime = true
function ns.UpdateConfigList()
	local items = {}
	local stocklist = StealYourCarbon.db.stocklist
	for id in pairs(stocklist) do table.insert(items, id) end
	table.sort(items)
	local maxoffset = #items - NUMROWS
	scrollbar:SetMinMaxValues(0, math.max(maxoffset, 0))

	local emptyshown = false
	for i,row in ipairs(rows) do
		local id = items[i + offset]
		if id then
			row.id = id
			local _, link, _, _, _, _, _, stack = GetItemInfo(id)
			local texture = GetItemIcon(id)
			row.icon:SetTexture(texture)
			row.up:Enable()
			if qty == 0 then row.down:Disable() else row.down:Enable() end
			row.count:SetText(stocklist[id])
			row.name:SetText(link)
			row.stack:SetText("Stack Size: "..(stack or "???"))
			row.icon:Show()
			row:Show()
		elseif not emptyshown then
			emptyshown = true
			row.id = nil
			row.icon:Hide()
			row.count:SetText()
			row.name:SetText()
			row.stack:SetText()
			row.up:Disable()
			row.down:Disable()
			row:Show()
		else
			row:Hide()
		end
	end

	if firsttime then
		scrollbar:SetValue(0)
		firsttime = false
	end
end
