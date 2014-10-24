
local myname, ns = ...

local GOLD, SILVER, COPPER = "|cffffd700%d", "|cffc7c7cf%02d", "|cffeda55f%02d"

local GSC = string.join('.', GOLD, SILVER, COPPER)
local GS  = string.join('.', GOLD, SILVER)
local  SC = string.join('.',       SILVER, COPPER)


-- Converts an integer into a colored gold.silver.copper string
--
--         cash - an integer representing a price in copper
--   colorblind - force the use of colorblind mode, always printing out
--                zero-value silver and copper
--
-- Returns a colored string
function ns.GSC(cash, colorblind)
	if not cash then return end

	local g, s, c = floor(cash/10000), floor((cash/100)%100), cash%100

	if colorblind or GetCVarBool("colorblindMode") then
		if g > 0 then return string.format(GSC, g, s, c)
		elseif s > 0 then return string.format(SC, s, c)
		else return string.format(COPPER, c) end
	else
		if g > 0 and s == 0 and c == 0 then return string.format(GOLD, g)
		elseif g > 99999 then return string.format(GS, g, s)
		elseif g > 0 and c == 0 then return string.format(GS, g, s)
		elseif g > 0 then return string.format(GSC, g, s, c)
		elseif s > 0 and c == 0 then return string.format(SILVER, s)
		elseif s > 0 then return string.format(SC, s, c)
		else return string.format(COPPER, c) end
	end
end


-- Converts an integer into a colored gold.silver string
--
--   cash - an integer representing a price in copper
--
-- Returns a colored string
function ns.GS(cash)
	if not cash then return end

	if cash > 999999 then return ns.GSC(floor(cash/10000)*10000)
	else return ns.GSC(floor(cash/100)*100) end
end


-- Converts an integer into a colored gold string
--
--   cash - an integer representing a price in copper
--
-- Returns a colored string
function ns.G(cash)
	if not cash then return end

	return ns.GSC(floor(cash/10000)*10000)
end
