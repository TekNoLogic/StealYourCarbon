
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
	ns.UpgradeWater()
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
