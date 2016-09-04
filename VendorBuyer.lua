
local myname, ns = ...


local stacks = setmetatable({}, {__index = function(t,i)
	local _, _, _, _, _, _, _, stack = GetItemInfo(i)
	t[i] = stack
	return stack
end})


local TRADE_GOODS = GetItemClassInfo(LE_ITEM_CLASS_TRADEGOODS)
ns.RegisterEvent("MERCHANT_SHOW", function()
	ns.UpgradeWater()

	local spent = 0
	for i=1,GetMerchantNumItems() do
		local link = GetMerchantItemLink(i)
		local itemID = link and ns.ids[link]
		if itemID and ns.dbpc.stocklist[itemID] then
			local _, _, _, _, _, item_type = GetItemInfo(itemID)
			local crafting_reagent = item_type == TRADE_GOODS
			local num_owned = GetItemCount(itemID, crafting_reagent)
			local needed = ns.dbpc.stocklist[itemID] - num_owned
			if needed > 0 then
				local _, _, price, qty, avail = GetMerchantItemInfo(i)
				local tobuy = avail > 0 and avail < needed and avail or needed

				ns.Printf("Buying %s x%d", select(2, GetItemInfo(itemID)), tobuy)

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
