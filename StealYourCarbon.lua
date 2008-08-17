
--------------------------------
--      Memoizing Tables      --
--------------------------------

local stacks = setmetatable({}, {__index = function(t,i)
	local _, _, _, _, _, _, _, stack = GetItemInfo(i)
	t[i] = stack
	return stack
end})

local ids = setmetatable({}, {__index = function(t,i)
	local _, link = GetItemInfo(i)
	if not link then return end
	local id = tonumber(string.match(link, "item:(%d+):"))
	t[i] = id
	return id
end})


-------------------------------------------
--      Namespace and all that shit      --
-------------------------------------------

StealYourCarbon = CreateFrame("Frame")
local StealYourCarbon = StealYourCarbon
function StealYourCarbon:Print(...) ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99Steal Your Carbon|r:", ...)) end
function StealYourCarbon:PrintF(fmsg, ...) ChatFrame1:AddMessage(string.format("|cFF33FF99Steal Your Carbon|r: "..fmsg, ...)) end


local waterupgrades = {27860,28399,8766,1645,1708,1205,1179,159}
for _,id in pairs(waterupgrades) do GameTooltip:SetHyperlink("item:"..id) end -- Query server to ensure GetItemInfo doesn't nil out.
function StealYourCarbon:UpgradeWater()
	local level = UnitLevel("player")

	local buy, found, oldid = 0
	for _,id in pairs(waterupgrades) do
		if found then
			buy = buy + (self.db.stocklist[id] or 0)
			if self.db.stocklist[id] then oldid = id end
			self.db.stocklist[id] = nil
		elseif level >= (select(5, GetItemInfo(id)) or 0) then
			found = id
		end
	end

	if found and buy > 0 then
		self.db.stocklist[found] = buy
		if self.db.chatter then self:PrintF("Upgrading %s to %s", select(2, GetItemInfo(oldid)), select(2, GetItemInfo(found))) end
	end
end


-----------------------------
--      Slash Command      --
-----------------------------

SLASH_CARBON1 = "/carbon"
SLASH_CARBON2 = "/syc"
SlashCmdList.CARBON = function(input)
	if input == "" then
		InterfaceOptionsFrame_OpenToFrame(StealYourCarbon.configframe)
	else
		local id, qty = string.match(input, "add .*item:(%d+):.*%s+(%d+)%s*$")
		if id and qty then
			StealYourCarbon.db.stocklist[tonumber(id)] = tonumber(qty)
			StealYourCarbon:PrintF("Added %s x%d", select(2, GetItemInfo(id)), qty)
			StealYourCarbon:UpdateConfigList()
		else
			StealYourCarbon:Print("Automatically restock items from vendors and your bank")
			ChatFrame1:AddMessage(" /carbon /syc")
			ChatFrame1:AddMessage("   |cffff9933(no command)|r: Open config panel")
			ChatFrame1:AddMessage("   |cffff9933add [Item Link] quantity|r: Add an item to be restocked")
		end
	end
end


-------------------------------
--      Merchant Button      --
-------------------------------

local addbutton = LibStub("tekKonfig-Button").new_small(MerchantFrame, "TOPLEFT", 175, -45)
addbutton:SetWidth(50)
addbutton:SetText("SYC")
addbutton:SetScript("OnClick", function(self) InterfaceOptionsFrame_OpenToFrame(StealYourCarbon.configframe) end)


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("StealYourCarbon", {
	launcher = true,
	icon = "Interface\\Icons\\INV_Misc_Gem_Diamond_01",
	OnClick = function() InterfaceOptionsFrame_OpenToFrame(StealYourCarbon.configframe) end,
})


----------------------
--      Events      --
----------------------

StealYourCarbon:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
StealYourCarbon:RegisterEvent("ADDON_LOADED")


function StealYourCarbon:ADDON_LOADED(event, addon)
	if addon ~= "StealYourCarbon" then return end

	StealYourCarbonDB = StealYourCarbonDB or {stocklist = {}}
	self.db = StealYourCarbonDB

	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("MERCHANT_SHOW")
--~ 	self:RegisterEvent("BANKFRAME_OPENED")

	if MerchantFrame:IsVisible() then self:MERCHANT_SHOW() end
end


function StealYourCarbon:MERCHANT_SHOW()
	if self.db.upgradewater then self:UpgradeWater() end

	for i=1,GetMerchantNumItems() do
		local link = GetMerchantItemLink(i)
		local itemID = link and ids[link]
		if itemID and self.db.stocklist[itemID] then
			local needed = self.db.stocklist[itemID] - GetItemCount(itemID)
			if needed > 0 then
				local _, _, _, qty, avail = GetMerchantItemInfo(i)
				local tobuy = avail > 0 and avail < needed and avail or needed
				local diff = math.fmod(tobuy, qty)
				tobuy = tobuy - diff + ((diff > 0) and self.db.overstock and qty or 0)

				if self.db.chatter then self:PrintF("Buying %s x%d", select(2, GetItemInfo(itemID)), tobuy) end

				while tobuy > 0 do
					local thisbuy = min(tobuy, stacks[itemID])
					BuyMerchantItem(i, thisbuy/qty)
					tobuy = tobuy - thisbuy
				end
			end
		end
	end
end


-- TODO: BANKFRAME_OPENED
--~ function StealYourCarbon:BANKFRAME_OPENED()
--~ UseContainerItem(BANK_CONTAINER, this:GetID())
--~ PickupContainerItem(BANK_CONTAINER, this:GetID())
--~ end
