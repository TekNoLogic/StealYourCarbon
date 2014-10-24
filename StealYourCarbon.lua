
local myname, ns = ...
ns.dbpcname = "StealYourCarbonDB"


function ns.OnLoad()
	ns.dbpc.stocklist = ns.dbpc.stocklist or {}

	if MerchantFrame:IsVisible() then ns.MERCHANT_SHOW() end

	-- We can't check visiblity because the play might have a bank addon
	if GetContainerNumSlots(5) > 0 then ns.BANKFRAME_OPENED() end

	-- If we were loaded by AddonLoader because our config panel was opened,
	-- then force it to build itself
	if ns.configframe:IsShown() then
		ns.configframe:GetScript("OnShow")(ns.configframe)
	end
end
