
local myname, ns = ...


local upgrades = {
	water = {117452,81923,74636,81924,58257,58256,33445,33444,27860,28399,8766,1645,1708,1205,1179,159},
	intbrew = {89594,89593,89592,89591,89590,89589,89588},
	agibrew = {89601,89600,89599,89598,89597,89596,89595},
}
for _,set in pairs(upgrades) do
	-- Query server to ensure GetItemInfo doesn't nil out.
	for _,id in pairs(set) do
		if not GetItemInfo(id) then GameTooltip:SetHyperlink("item:"..id) end
	end
end


function ns.UpgradeWater()
	local level = UnitLevel("player")

	for _,set in pairs(upgrades) do
		local buy, found, oldid = 0
		for _,id in pairs(set) do
			if found then
				buy = buy + (ns.dbpc.stocklist[id] or 0)
				if ns.dbpc.stocklist[id] then oldid = id end
				ns.dbpc.stocklist[id] = nil
			else
				local _, _, _, _, reqlvl = GetItemInfo(id)
				if reqlvl and level >= reqlvl then found = id end
			end
		end

		if found and buy > 0 then
			ns.dbpc.stocklist[found] = buy
			local _, oldname = GetItemInfo(oldid)
			local _, newname = GetItemInfo(found)
			ns.Print("Upgrading", oldname, "to", newname)
		end
	end
end
