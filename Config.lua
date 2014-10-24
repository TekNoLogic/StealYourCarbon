
local myname, ns = ...

local NUMROWS, NUMCOLS, ICONSIZE, ICONGAP, GAP, EDGEGAP = 9, 10, 32, 3, 8, 16
local tekcheck = LibStub("tekKonfig-Checkbox")
local rows, offset, scrollbar, tradeview, grouptext = {}, 0
local _, myclass = UnitClass('player')


if AddonLoader and AddonLoader.RemoveInterfaceOptions then AddonLoader:RemoveInterfaceOptions("Steal Your Carbon") end

local frame = CreateFrame("Frame", "StealYourCarbonConfig", InterfaceOptionsFramePanelContainer)
frame.name = "Steal Your Carbon"
frame:SetScript("OnShow", function(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Steal Your Carbon", "To add an item drop it in the frame below.  Shift-click an arrow to add/remove a full stack.  Set the quantity to 0 to remove the item.  Crafting materials in your bank will be counted when buying from vendors.")


	local group = ns.GenerateRestockPanel(frame)
	group:SetPoint("TOP", subtitle, "BOTTOM", 0, -EDGEGAP-GAP)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -EDGEGAP/4, EDGEGAP)


	local bags = ns.GenerateBagsPanel(frame)
	bags:SetPoint("TOP", group, "TOP")
	bags:SetPoint("LEFT", frame, "CENTER", EDGEGAP/4, 0)
	bags:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)

	ns.UpdateConfigList()
	frame:SetScript("OnShow", nil)
end)


ns.configframe = frame
InterfaceOptions_AddCategory(frame)


local orig = IsOptionFrameOpen
function IsOptionFrameOpen(...)
	if not frame:IsVisible() then return orig(...) end
end
