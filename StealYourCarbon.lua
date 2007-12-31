
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
	for i=1,GetMerchantNumItems() do
		local itemID = ids[GetMerchantItemLink(i)]
		if self.db.stocklist[itemID] then
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
