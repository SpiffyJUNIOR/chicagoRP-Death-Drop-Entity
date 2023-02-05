ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Backpack"
ENT.Author = "SpiffyJUNIOR"
ENT.Category = "chicagoRP"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:Think()
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Victim")
    self:NetworkVar("String", 1, "VictimNick")
end