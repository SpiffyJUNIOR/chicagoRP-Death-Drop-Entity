util.AddNetworkString("chicagoRP_deathdropentity_GUI")
util.AddNetworkString("chicagoRP_deathdropentity_fetchtable")
util.AddNetworkString("chicagoRP_deathdropentity_senditem")

local wpnblacklist = {} -- yes, blacklist code was taken from YuRaNnNzZZ. If you want this removed then please open an issue

-- local ammotypes = {
--     {
--         ent = "item_ammo_ar2"
--     }, {
--         ent = "ar2altfire"
--     }, {
--         ent = "pistol"
--     }, {
--         ent = "smg1"
--     }, {
--         ent = "357"
--     }, {
--         ent = "crossbow"
--     }, {
--         ent = "buckshot"
--     }, {
--         ent = "rpg"
--     }, {
--         ent = "smg1_grenade"
--     }, {
--         ent = "grenade"
--     }, {
--         ent = "slam"
--     }, {
--         ent = "alyxgun"
--     }, {
--         ent = "sniperround"
--     }, {
--         ent = "sniperpenetratedround"
--     }
-- }

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

local function DelayedBoxRemoval(index, ent)
    timer.Simple(300, function()
    	if IsValid(ent) then
    		ent:Remove()

    		chicagoRP.deathentindex[index] = nil
    	end
    end)
end

net.Receive("chicagoRP_deathdropentity_senditem", function(len, ply)
	if !enabled:GetBool() or !IsValid(ply) or !ply:Alive() or ply:InVehicle() then return end

	local viewtrace = ply:GetEyeTraceNoCursor()
	local entname = viewtrace.Entity:GetName()

	if isempty(entname) or entname != "chicagoRP_backpack" then return end -- EZ anti-exploit

	local tblindex = net.ReadInt(32)
	local itemindex = net.ReadInt(32)

	if chicagoRP.deathentindex[tblindex].[itemindex] == nil then return end

	local entpos = viewtrace.Entity:GetPos()
	local spawnpos = entpos

	if viewtrace.Entity:GetTableIndex() != tblindex then return end

	if itemindex.ammo == true then
		ply:GiveAmmo(itemindex.quanity, itemindex.ammoid)
		chicagoRP.deathentindex[tblindex].[itemindex] = nil

		return
	end

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

    local itemindex_ammo = #chicagoRP.deathentindex[indexnum]
    local ammotbl = victim:GetAmmo()

    if !istable(ammotbl) or table.IsEmpty(ammotbl) then continue end

    for k, v in ipairs(ammotbl) do
    	if isempty(game.GetAmmoName(k)) then continue end

    	local contbl = {ammo = true, ammoid = k, quanity = v}

    	table.insert(chicagoRP.deathentindex[indexnum].[itemindex_ammo + k], contbl)
    end

    local itemindex_atts = #chicagoRP.deathentindex[indexnum]
    local attinv = victim.ArcCW_AttInv or {}

    if !istable(attinv) or table.IsEmpty(attinv) then continue end

    local atttbl = table.GetKeys(attinv)
    table.sort(atttbl)

    for k, v in ipairs(atts) do
    	local attid = ArcCW.AttachmentIDTable[ArcCW.AttachmentTable[v].ID]

    	local atttbl = ArcCW.AttachmentTable[att]

	    local ent = ents.Create("arccw_att_base")
	    if !IsValid(ent) then continue end

	    ent:SetNWInt("attid", attid)

	    ent.GiveAttachments = {[att] = 1}
	    ent.Model = atttbl.DroppedModel or atttbl.Model or "models/Items/BoxSRounds.mdl"
	    ent.Icon = atttbl.Icon
	    ent.PrintName = atttbl.PrintName or att

	    -- ent:Spawn()

    	local enttbl = duplicator.CopyEntTable(armorEnt)

    	-- ent:Remove()

    	table.insert(chicagoRP.deathentindex[indexnum].[itemindex_atts + k], enttbl)
    end

    -- if !JMod then return end

    -- for k, _ in ipairs(victim.EZarmor.items) do
	   --  local Info = victim.EZarmor.items[k]

	   --  if !Info then return end

	   --  local Specs = JMod.ArmorTable[Info.name]

    --     local armorEnt = ents.Create(Specs.ent)
    --     armorEnt.ArmorDurability = Info.dur

    --     if Info.chrg then
    --         armorEnt.ArmorCharges = table.FullCopy(Info.chrg)
    --     end

    --     armorEnt.EZID = k
    --     armorEnt:SetColor(Info.col)
    --     armorEnt:SetSkin(Info._skin)
        -- armorEnt:Spawn()
        -- armorEnt:Activate()

	   --  if Specs.plymdl then
	   --      -- if this is a suit, we need to reset the player's model when he takes it off
	   --      if victim.EZoriginalPlayerModel then
	   --          JMod.SetPlayerModel(victim, victim.EZoriginalPlayerModel)
	   --      end

	   --      victim:SetColor(Color(255, 255, 255))
	   --      victim.EZarmor.suited = false
	   --      victim.EZarmor.bodygroups = nil
	   --  end

	   --  victim.EZarmor.items[ID] = nil
	   --  victim:SetNW2Bool("chicagoRP_masked", false)
	   --  victim:SetNW2Bool("MWParachuteEquipped", false)

    -- 	local armortbl = duplicator.CopyEntTable(armorEnt)

    	-- armorEnt:Remove()

    -- 	table.insert(chicagoRP.deathentindex[indexnum].[itemindex + k], armortbl)
    -- end

    -- JMod.EZarmorSync(victim)

    local spawnpos = pos

    spawnpos.x = spawnpos.x + 5

    local droppedbox = ents.Create("chicagoRP_backpack")
    droppedbox:SetVictim(victim)
    droppedbox:SetVictimNick(victim:Nick())
    droppedbox:SetTableIndex(indexnum)
    droppedbox:SetPos(spawnpos)
    droppedbox:SetVelocity(vel)
    droppedbox:Spawn()
    droppedbox:Activate()

    DelayedBoxRemoval(indexnum, ent)
end

hook.Add("PlayerDeath", "chicagoRP_deathdropentity_doplayerdeath", chicagoRP_PlayerDeath)

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
















