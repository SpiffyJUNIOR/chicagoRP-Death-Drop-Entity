util.AddNetworkString("chicagoRP_deathdropentity_GUI")
util.AddNetworkString("chicagoRP_deathdropentity_fetchtable")
util.AddNetworkString("chicagoRP_deathdropentity_senditem")

local wpnblacklist = {} -- yes, blacklist code was taken from YuRaNnNzZZ. If you want this removed then please open an issue

local enabled = GetConVar("sv_chicagoRP_deathdropentity_enable")
local droparmorcvar = GetConVar("jmod_armordropondeath")
local blacklistcvar = GetConVar("sv_chicagoRP_weapon_blacklist")

local function isempty(s)
    return s == nil or s == ""
end

local function StringToTable(str, separator)
	local newtable = {}
	local strings = string.Explode(separator, str)

	for _, v in pairs(strings) do
		if #v > 0 then
			newtable[v] = true
		end
	end

	return newtable
end

-- local function IsArcCW(wep)
--     local sweptbl = weapons.GetStored(enttbl.ent)
--     local swepbase = sweptbl.ArcCW

--     if !isempty(swepbase) then return false end

--     return true
-- end

local function CoolerDropWeapon(ply, wpn, ang, vel)
	if !IsValid(ply) or !IsValid(wpn) then return end

	ply:DropWeapon(wpn, ang, vel)
end

net.Receive("chicagoRP_deathdropentity_senditem", function(len, ply)
	if !enabled:GetBool() or !IsValid(ply) or !ply:Alive() or ply:InVehicle() then return end

	local viewtrace = ply:GetEyeTraceNoCursor()
	local entname = viewtrace.Entity:GetName()

	if isempty(entname) or entname != "chicagoRP_backpack" then return end -- EZ anti-exploit

	if chicagoRP.deathentindex[tblindex].[itemindex] == nil then return end

	local entpos = viewtrace.Entity:GetPos()
	local spawnpos = entpos
	local tblindex = net.ReadInt(32)
	local itemindex = net.ReadInt(32)

	spawnpos.x = spawnpos.x + 5

	local spawnedent = duplicator.CreateEntityFromTable(ply, chicagoRP.deathentindex[tblindex].[itemindex])
	spawnedent:SetPos(spawnpos)
	spawnedent:Spawn()
	spawnedent:Activate()

	chicagoRP.deathentindex[tblindex].[itemindex] = nil
end)

local function chicagoRP_PlayerDeath(victim, inflictor, attacker) -- add ammo and arccw atts in inventory
	if !IsValid(victim) then return end

	local pos = victim:GetPos()
	local ang = victim:GetAimVector()
	local vel = victim:GetVelocity()

	local activewep = victim:GetActiveWeapon()

	local tblcount = #chicagoRP.deathentindex
	local indexnum = tblcount + 1

    for k, wep in ipairs(victim:GetWeapons()) do
    	local wep = v

    	if wpnblacklist[wpn:GetClass()] then continue end
    	if wep == activewep then CoolerDropWeapon(victim, wep, ang, vel) continue end

    	local weptbl = duplicator.CopyEntTable(wep)

    	table.insert(chicagoRP.deathentindex[indexnum].[k], weptbl)
    end

    if !JMod then return end

    local itemindex = #chicagoRP.deathentindex[indexnum]

    for k, _ in ipairs(victim.EZarmor.items) do
	    local Info = victim.EZarmor.items[k]

	    if !Info then return end

	    local Specs = JMod.ArmorTable[Info.name]

        local armorEnt = ents.Create(Specs.ent)
        armorEnt.ArmorDurability = Info.dur

        if Info.chrg then
            armorEnt.ArmorCharges = table.FullCopy(Info.chrg)
        end

        armorEnt.EZID = ID
        armorEnt:SetColor(Info.col)
        armorEnt:SetSkin(Info._skin)
        armorEnt:Spawn()
        armorEnt:Activate()

	    if Specs.plymdl then
	        -- if this is a suit, we need to reset the player's model when he takes it off
	        if victim.EZoriginalPlayerModel then
	            JMod.SetPlayerModel(victim, victim.EZoriginalPlayerModel)
	        end

	        victim:SetColor(Color(255, 255, 255))
	        victim.EZarmor.suited = false
	        victim.EZarmor.bodygroups = nil
	    end

	    victim.EZarmor.items[ID] = nil
	    victim:SetNW2Bool("chicagoRP_masked", false)
	    victim:SetNW2Bool("MWParachuteEquipped", false)

    	local armortbl = duplicator.CopyEntTable(armorEnt)

    	armorEnt:Remove()

    	table.insert(chicagoRP.deathentindex[indexnum].[itemindex + k], armortbl)
    end

    JMod.EZarmorSync(victim)

    local spawnpos = pos

    spawnpos.x = spawnpos.x + 5

    local droppedbox = ents.Create("chicagoRP_backpack")
    droppedbox:SetVictim(victim)
    droppedbox:TableIndex(indexnum)
    droppedbox:SetPos(spawnpos)
    droppedbox:SetVelocity(vel)
    droppedbox:Spawn()
    droppedbox:Activate()
end

hook.Add("DoPlayerDeath", "chicagoRP_deathdropentity_doplayerdeath", chicagoRP_PlayerDeath)

concommand.Add("sv_chicagoRP_blacklist_add", function(ply, cmd, args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	if #args < 1 then return end
	if wpnblacklist[args[1]] then return end

	wpnblacklist[args[1]] = true
	local str = ""

	for k, v in ipairs(wpnblacklist) do
		if v then str = str .. k .. "," end
	end

	blacklistcvar:SetString(str)
	wpnblacklist = StringToTable(blacklistcvar:GetString(), ",")
end)

concommand.Add("sv_chicagoRP_blacklist_remove", function(ply, cmd, args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	if #args < 1 then return end
	if !wpnblacklist[args[1]] then return end

	wpnblacklist[args[1]] = false
	local str = ""

	for k, v in pairs(wpnblacklist) do
		if v then str = str .. k .. "," end
	end

	blacklistcvar:SetString(str)
	wpnblacklist = StringToTable(blacklistcvar:GetString(), ",")
end)

print("chicagoRP Death Drop Entity sv_util loaded!")
















