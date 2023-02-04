ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Backpack"
ENT.Author = "SpiffyJUNIOR"
ENT.Category = "chicagoRP"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:SetOwnerName(ply)
    self.ply = ply:Nick()
end

function ENT:Think()
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "HeaderText")
    self:NetworkVar("String", 1, "TableType")
    self:NetworkVar("String", 2, "NetWorkId")
    self:NetworkVar("Vector", 0, "ThemeColor")
end