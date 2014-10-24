
local myname, ns = ...


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


local tradebags = {
	[8] = true, -- Leatherworking
	[16] = true, -- Inscription
	[32] = true, -- Herb
	[64] = true, -- Enchanting
	[128] = true, -- Engineering
}
function ns.HasTradeskillBag()
	for i=1,4 do
		if tradebags[select(2, GetContainerNumFreeSlots(i))] then return true end
	end
end


local upgrades = {
	water = {81923,74636,81924,58257,58256,33445,33444,27860,28399,8766,1645,1708,1205,1179,159},
	intbrew = {89594,89593,89592,89591,89590,89589,89588},
	agibrew = {89601,89600,89599,89598,89597,89596,89595},
}
for _,set in pairs(upgrades) do
	-- Query server to ensure GetItemInfo doesn't nil out.
	for _,id in pairs(set) do
		if not GetItemInfo(id) then GameTooltip:SetHyperlink("item:"..id) end
	end
end
function StealYourCarbon:UpgradeWater()
	local level = UnitLevel("player")
	local stocklist = ns.HasTradeskillBag() and self.db.tradestocklist or self.db.stocklist

	for _,set in pairs(upgrades) do
		local buy, found, oldid = 0
		for _,id in pairs(set) do
			if found then
				buy = buy + (stocklist[id] or 0)
				if stocklist[id] then oldid = id end
				stocklist[id] = nil
			else
				local _, _, _, _, reqlvl = GetItemInfo(id)
				if reqlvl and level >= reqlvl then found = id end
			end
		end

		if found and buy > 0 then
			stocklist[found] = buy
			ns.PrintF("Upgrading %s to %s", select(2, GetItemInfo(oldid)), select(2, GetItemInfo(found)))
		end
	end
end


----------------------
--      Events      --
----------------------

function ns.OnLoad()
	StealYourCarbonDB = StealYourCarbonDB or {stocklist = {}}
	StealYourCarbonDB.tradestocklist = StealYourCarbonDB.tradestocklist or {}
	StealYourCarbon.db = StealYourCarbonDB


	if MerchantFrame:IsVisible() then ns.MERCHANT_SHOW() end

	-- We can't check visiblity because the play might have a bank addon
	if GetContainerNumSlots(5) > 0 then ns.BANKFRAME_OPENED() end
end


local _, _, _, _, _, TRADE_GOODS = GetAuctionItemClasses()
ns.RegisterEvent("MERCHANT_SHOW", function()
	local hastradebag = ns.HasTradeskillBag()
	StealYourCarbon:UpgradeWater()
	local spent, stocklist = 0, hastradebag and StealYourCarbon.db.tradestocklist or StealYourCarbon.db.stocklist
	for i=1,GetMerchantNumItems() do
		local link = GetMerchantItemLink(i)
		local itemID = link and ids[link]
		if itemID and stocklist[itemID] then
			local _, _, _, _, _, item_type = GetItemInfo(itemID)
			local crafting_reagent = item_type == TRADE_GOODS
			local needed = stocklist[itemID] - GetItemCount(itemID, crafting_reagent)
			if needed > 0 then
				local _, _, price, qty, avail = GetMerchantItemInfo(i)
				local tobuy = avail > 0 and avail < needed and avail or needed

				ns.PrintF("Buying %s x%d", select(2, GetItemInfo(itemID)), tobuy)

				while tobuy > 0 do
					local thisbuy = min(tobuy, stacks[itemID])
					BuyMerchantItem(i, thisbuy)
					spent = spent + (price/qty)*thisbuy
					tobuy = tobuy - thisbuy
				end
			end
		end
	end
	if spent > 0 then ns.Print("Spent", ns.GS(spent)) end
end)
