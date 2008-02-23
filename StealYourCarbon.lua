
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


local water = {
	[65] = "33042,32668,29395,27860,29401",
	[60] = "28399,29454",
	[35] = "1645,19300",
	[15] = "19299,1205",
	[5] = "17404,1179",
}


-------------------------------------------
--      Namespace and all that shit      --
-------------------------------------------

StealYourCarbon = CreateFrame("Frame")
local StealYourCarbon = StealYourCarbon
function StealYourCarbon:Print(...) ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99Steal Your Carbon|r:", ...)) end
function StealYourCarbon:PrintF(fmsg, ...) ChatFrame1:AddMessage(string.format("|cFF33FF99Steal Your Carbon|r: "..fmsg, ...)) end


local waterupgrades = {27860,28399,8766,1645,1708,1205,1179,159}
function StealYourCarbon:UpgradeWater()
	local level = UnitLevel("player")

	local buy, found, oldid = 0
	for _,id in pairs(waterupgrades) do
		if found then
			buy = buy + (self.db.stocklist[id] or 0)
			if self.db.stocklist[id] then oldid = id end
			self.db.stocklist[id] = nil
		elseif level >= select(5, GetItemInfo(id)) then
			found = id
		end
	end

	if found and buy > 0 then
		if self.db.chatter then self:PrintF("Upgrading %s to %s", select(2, GetItemInfo(oldid)), select(2, GetItemInfo(found))) end
		self.db.stocklist[found] = buy
	end
end


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
