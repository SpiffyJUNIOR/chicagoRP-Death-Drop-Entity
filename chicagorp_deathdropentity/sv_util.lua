util.AddNetworkString("chicagoRP_deathdropentity_GUI")
util.AddNetworkString("chicagorp_deathdropentity_senditem")

local enabled = GetConVar("sv_chicagoRP_deathdropentity_enable")

local function isempty(s)
    return s == nil or s == ""
end

net.Receive("chicagorp_deathdropentity_senditem", function(_, ply)
	if !enabled:GetBool() or !IsValid(ply) or !ply:Alive() or ply:InVehicle() then return end

	local viewtrace = ply:GetEyeTraceNoCursor()
	local entname = viewtrace.Entity:GetName()

	if isempty(entname) or entname != "chicagoRP_backpack" then return end -- EZ anti-exploit
end)









