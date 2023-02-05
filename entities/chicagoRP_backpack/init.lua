AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/weapons/c_medkit.mdl")
    self:SetUseType(SIMPLE_USE) -- how do we make this a pickup like ammo/health?
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller) -- , useType, value
    local tblindex = self.TableIndex

    if !IsValid(activator) or !isnumber(tblindex) or !istable(chicagoRP.deathentindex[tblindex]) then return end

    local JSONTable = util.TableToJSON(chicagoRP.deathentindex[tblindex])
    local compTable = util.Compress(JSONTable)
    local bytecount = #compTable

    net.Start("chicagoRP_deathdropentity_GUI")
    net.WriteUInt(bytecount, 16)
    net.WriteData(compTable, bytecount)
    net.WriteString(self:GetVictimNick())
    net.WriteInt(tblindex, 16)
    net.Send(activator)
end

function ENT:GetTableIndex()
    return self.TableIndex
end

function ENT:SetTableIndex(number)
    self.TableIndex = number
end