
local ICONSIZE, GAP, EDGEGAP = 32, 8, 16

local frame = CreateFrame("Frame", "StealYourCarbonConfig", UIParent)
frame.name = "Steal Your Carbon"
frame:SetScript("OnShow", function(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Steal Your Carbon", "Example text goes here...")

	frame.lines = {}
	for i=1,12 do
		local l = CreateFrame("CheckButton", nil, frame)
		if i == 1 then l:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
		else l:SetPoint("TOPLEFT", frame.lines[i-1], "BOTTOMLEFT") end
		l:SetPoint("RIGHT", -EDGEGAP, 0)
		l:SetHeight(ICONSIZE)
--~ 		l:SetScript("OnEnter", ShowItemDetails)
--~ 		l:SetScript("OnLeave", HideItemDetails)

		l.icon = l:CreateTexture(nil, "ARTWORK")
		l.icon:SetPoint("TOPLEFT")
		l.icon:SetWidth(ICONSIZE)
		l.icon:SetHeight(ICONSIZE)

		l.name = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		l.name:SetPoint("TOPLEFT", l.icon, "TOPRIGHT", 5, 0)
		l.name:SetText("TEST")
		l.count = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		l.count:SetPoint("TOPLEFT", l.icon, "TOPRIGHT", 5, -12)
		l.count:SetText(20)

		frame.lines[i] = l
	end

	local OnShow = function(self)
		local i = 0
		for id,qty in pairs(StealYourCarbon.db.stocklist) do
			i = i + 1
		end
	end
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnHide", function() for i,v in pairs(StealYourCarbon.db.stocklist) do if v == 0 then StealYourCarbon.db.stocklist[i] = nil end end end)
	OnShow(f)
end)


StealYourCarbon.configframe = frame
InterfaceOptions_AddCategory(frame)
