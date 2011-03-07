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
function StealYourCarbon:Print(...) ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99Steal Your Carbon|r:", ...)) end
function StealYourCarbon:PrintF(fmsg, ...) ChatFrame1:AddMessage(string.format("|cFF33FF99Steal Your Carbon|r: "..fmsg, ...)) end

local waterupgrades = {58257,58256,33445,33444,27860,28399,8766,1645,1708,1205,1179,159}
for _,id in pairs(waterupgrades) do if not GetItemInfo(id) then GameTooltip:SetHyperlink("item:"..id) end end -- Query server to ensure GetItemInfo doesn't nil out.
function StealYourCarbon:UpgradeWater()
	local level = UnitLevel("player")

	local buy, found, oldid = 0
	for _,id in pairs(waterupgrades) do
		if found then
			buy = buy + (self.db.stocklist[id] or 0)
			if self.db.stocklist[id] then oldid = id end
			self.db.stocklist[id] = nil
		else
			local _, _, _, _, reqlvl = GetItemInfo(id)
			if reqlvl and level >= reqlvl then found = id end
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
SLASH_SYC1 = "/syc"
SlashCmdList.CARBON = function(input)
	if input == "" then
		InterfaceOptionsFrame_OpenToCategory(StealYourCarbon.configframe)
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
SlashCmdList.SYC = SlashCmdList.CARBON


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("StealYourCarbon", {
	type = "launcher",
	icon = "Interface\\Icons\\INV_Misc_Gem_Diamond_01",
	OnClick = function() InterfaceOptionsFrame_OpenToCategory(StealYourCarbon.configframe) end,
})


----------------------
--      Events      --
----------------------

StealYourCarbon:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
StealYourCarbon:RegisterEvent("ADDON_LOADED")


function StealYourCarbon:ADDON_LOADED(event, addon)
	if addon:lower() ~= "stealyourcarbon" then return end

	StealYourCarbonDB = StealYourCarbonDB or {stocklist = {}}
	StealYourCarbonDB.tradestocklist = StealYourCarbonDB.tradestocklist or {}
	self.db = StealYourCarbonDB

	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("BANKFRAME_OPENED")

	if MerchantFrame:IsVisible() then self:MERCHANT_SHOW() end
	if GetContainerNumSlots(5) > 0 then self:BANKFRAME_OPENED() end -- We can't check visiblity because the play might have a bank addon
end


local function GS(cash)
	if not cash then return end
	cash = cash/100
	local s = floor(cash%100)
	local g = floor(cash/100)
	if g > 0 then return string.format("|cffffd700%d.|cffc7c7cf%02d", g, s)
	else return string.format("|cffc7c7cf%d", s) end
end


local tradebags = {
	[8] = true, -- Leatherworking
	[16] = true, -- Inscription
	[32] = true, -- Herb
	[64] = true, -- Enchanting
	[128] = true, -- Engineering
}
local function HasTradeskillBag()
	for i=1,4 do
		if tradebags[select(2, GetContainerNumFreeSlots(i))] then return true end
	end
end


function StealYourCarbon:MERCHANT_SHOW()
	local hastradebag = HasTradeskillBag()
	if self.db.upgradewater and not hastradebag then self:UpgradeWater() end
	local spent, stocklist = 0, hastradebag and self.db.tradestocklist or self.db.stocklist
	for i=1,GetMerchantNumItems() do
		local link = GetMerchantItemLink(i)
		local itemID = link and ids[link]
		if itemID and stocklist[itemID] then
			local needed = stocklist[itemID] - GetItemCount(itemID)
			if needed > 0 then
				local _, _, price, qty, avail = GetMerchantItemInfo(i)
				local tobuy = avail > 0 and avail < needed and avail or needed

				if self.db.chatter then self:PrintF("Buying %s x%d", select(2, GetItemInfo(itemID)), tobuy) end

				while tobuy > 0 do
					local thisbuy = min(tobuy, stacks[itemID])
					BuyMerchantItem(i, thisbuy)
					spent = spent + (price/qty)*thisbuy
					tobuy = tobuy - thisbuy
				end
			end
		end
	end
	if spent > 0 and self.db.chatter then self:Print("Spent", GS(spent)) end
end


local function MoveStack(bag, slot, qty)
	local _, this_stack = GetContainerItemInfo(bag, slot)

	if this_stack <= qty then
		UseContainerItem(bag, slot)
		return this_stack
	end

	local id = GetContainerItemID(bag, slot)
	local _, _, _, _, _, _, _, max_stack = GetItemInfo(id)

	-- Try to find a stack to stick this on
	for bag2=0,4 do
		for slot2=1,GetContainerNumSlots(bag2) do
			local _, bag_stack = GetContainerItemInfo(bag2, slot2)
			local id2 = GetContainerItemID(bag2, slot2)
			if id2 == id then
				if (max_stack - bag_stack) >= qty then
					-- We have room, split and drop in this slot
					SplitContainerItem(bag, slot, qty)
					PickupContainerItem(bag2, slot2)
					return qty
				elseif max_stack > bag_stack then
					-- We have room, but not enough to finish
					qty = max_stack - bag_stack
					SplitContainerItem(bag, slot, qty)
					PickupContainerItem(bag2, slot2)
					return qty
				end
			end
		end
	end

	-- We couldn't find a partial stack, so lets find an empty bag
	-- Try for a trade bag first
	local item_family = GetItemFamily(id)
	for bag2=1,4 do
		local free_slots, bag_family = GetContainerNumFreeSlots(bag2)
		if free_slots > 0 and bag_family ~= 0 and bit.band(item_family, bag_family) > 0 then
			-- We have a special bag and the item fits
			SplitContainerItem(bag, slot, qty)
			PutItemInBag(bag2)
			return qty
		end
	end

	-- No luck, any bag will do, start with the backpack
	if GetContainerNumFreeSlots(0) > 0 then
		SplitContainerItem(bag, slot, qty)
		PutItemInBackpack()
		return qty
	end

	-- then the other bags, ignore trade bags
	for bag2=1,4 do
		local free_slots, bag_family = GetContainerNumFreeSlots(bag2)
		if free_slots > 0 and bag_family == 0 then
			SplitContainerItem(bag, slot, qty)
			PutItemInBag(bag2)
			return qty
		end
	end

	return 0
end

local BANKBAGS = {-1,5,6,7,8,9,10,11}
local function SwapFromBank(id, needed)
	local _, _, _, _, _, _, _, max_stack = GetItemInfo(id)

	-- First, scan the bank for partial stacks until we get all we need or run out of bank
	for _,bag in ipairs(BANKBAGS) do
		for slot=1,GetContainerNumSlots(bag) do
			if GetContainerItemID(bag, slot) == id then
				local _, this_stack = GetContainerItemInfo(bag, slot)
				if this_stack ~= max_stack then
					local qty = math.min(this_stack, needed)
					needed = needed - MoveStack(bag, slot, qty)
					if needed <= 0 then return end
				end
			end
		end
	end

	-- Next, Use any full stacks until we're all done
	for _,bag in ipairs(BANKBAGS) do
		for slot=1,GetContainerNumSlots(bag) do
			if GetContainerItemID(bag, slot) == id then
				local _, this_stack = GetContainerItemInfo(bag, slot)
				local qty = math.min(this_stack, needed)
				needed = needed - MoveStack(bag, slot, qty)
				if needed <= 0 then return end
			end
		end
	end
end


function StealYourCarbon:BANKFRAME_OPENED()
	local stocklist = HasTradeskillBag() and self.db.tradestocklist or self.db.stocklist
	for id,num in pairs(stocklist) do
		local inbag = GetItemCount(id)
		if inbag < num and GetItemCount(id, true) > inbag then SwapFromBank(id, num - inbag) end
	end
end
