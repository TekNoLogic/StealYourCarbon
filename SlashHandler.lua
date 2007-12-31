
local StealYourCarbon = StealYourCarbon


------------------------------
--      Slash Commands      --
------------------------------

SLASH_CARBON1 = "/carbon"
SLASH_CARBON2 = "/syc"
SlashCmdList.CARBON = function(input)
	local cmd, rest = string.match(input, "^%s*(%S+)%s*(.*)$")
	local handler = cmd and StealYourCarbon["CMD_"..cmd:upper()]

	if handler then handler(StealYourCarbon, rest)
	else
		StealYourCarbon:Print("Automatically restock items from vendors and your bank")
		ChatFrame1:AddMessage(" /carbon /syc")
		ChatFrame1:AddMessage("   |cffff9933add|r: Add an item to be restocked")
		ChatFrame1:AddMessage("   |cffff9933del|r: Remove an item from the restock list")
		ChatFrame1:AddMessage("   |cffff9933list|r: List current restock items")
		ChatFrame1:AddMessage("   |cffff9933overstock|r: Ensure that the quantity specified is always purchased for items offered in stacks from vendor")
		ChatFrame1:AddMessage("   |cffff9933chatter|r: Give chat feedback when purchasing items")
	end
end


function StealYourCarbon:CMD_ADD(input)
	local id, qty = string.match(input, "item:(%d+):.*%s+(%d+)%s*$")
	if not id or not qty then return self:Print("Usage: /carbon add [Item Link] quantity") end
	self.db.stocklist[tonumber(id)] = tonumber(qty)
	self:PrintF("Added %s x%d", select(2, GetItemInfo(id)), qty)
end


function StealYourCarbon:CMD_DEL(input)
	local id = string.match(input, "item:(%d+):")
	if not id or not qty then return self:Print("Usage: /carbon del [Item Link]") end
	self.db.stocklist[tonumber(id)] = nil
	self:Print("Removed", select(2, GetItemInfo(id)))
end


function StealYourCarbon:CMD_LIST()
	if not next(self.db.stocklist) then return self:Print("No items in restock list") end
	self:Print("Restock list")
	for id,qty in pairs(self.db.stocklist) do ChatFrame1:AddMessage(string.format("  %s x%d", select(2, GetItemInfo(id)), qty)) end
end


function StealYourCarbon:CMD_OVERSTOCK()
	self.db.overstock = not self.db.overstock
	self:Print("Overstocking", (self.db.overstock and "|cff00ff00enabled" or "|cffff0000disabled"))
end


function StealYourCarbon:CMD_CHATTER()
	self.db.chatter = not self.db.chatter
	self:Print("Purchasing feedback", (self.db.chatter and "|cff00ff00enabled" or "|cffff0000disabled"))
end


