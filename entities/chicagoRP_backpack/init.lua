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

function ENT:Use()
end