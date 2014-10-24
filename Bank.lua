
local myname, ns = ...


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


ns.RegisterEvent("BANKFRAME_OPENED", function()
	for id,num in pairs(ns.dbpc.stocklist) do
		local inbag = GetItemCount(id)
		if inbag < num and GetItemCount(id, true) > inbag then SwapFromBank(id, num - inbag) end
	end
end)
