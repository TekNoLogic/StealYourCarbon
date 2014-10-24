
local myname, ns = ...
ns.dbpcname = "StealYourCarbonDB"


-------------------------------
--      Memoizing Table      --
-------------------------------

local stacks = setmetatable({}, {__index = function(t,i)
	local _, _, _, _, _, _, _, stack = GetItemInfo(i)
	t[i] = stack
	return stack
end})


-------------------------------------------
--      Namespace and all that shit      --
-------------------------------------------

StealYourCarbon = CreateFrame("Frame")
local StealYourCarbon = StealYourCarbon


----------------------
--      Events      --
----------------------

function ns.OnLoad()
	ns.dbpc.stocklist = ns.dbpc.stocklist or {}

	if MerchantFrame:IsVisible() then ns.MERCHANT_SHOW() end

	-- We can't check visiblity because the play might have a bank addon
	if GetContainerNumSlots(5) > 0 then ns.BANKFRAME_OPENED() end

	-- If we were loaded by AddonLoader because our config panel was opened,
	-- then force it to build itself
	if StealYourCarbon.configframe:IsShown() then
		StealYourCarbon.configframe:GetScript("OnShow")(StealYourCarbon.configframe)
	end
end


local _, _, _, _, _, TRADE_GOODS = GetAuctionItemClasses()
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
