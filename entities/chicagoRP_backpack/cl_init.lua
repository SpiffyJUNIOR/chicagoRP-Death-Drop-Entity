include("shared.lua")

local client = LocalPlayer()
local whitecolor = Color(255, 255, 255, 255)
local greycolor = Color(25, 25, 25, 100)

local function isempty(s)
    return s == nil or s == ""
end

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local dist = pos:DistToSqr(EyePos() * EyePos())
	local clam = math.Clamp(dist, 0, 255)
	local main = (255 - clam)

	if (main <= 0) or isempty(self.ply) then return end

	local ahAngle = self:GetAngles()
	local plyEyeAng = client:EyeAngles()

	ahAngle:RotateAroundAxis(ahAngle:Forward(), 90)
	ahAngle:RotateAroundAxis(ahAngle:Right(), -90)

	whitecolor.a = main
	greycolor.a = main

	cam.Start3D2D(pos + self:GetUp() * 80, Angle(0, plyEyeAng.y - 90, 90), 0.175)
		-- surface.SetDrawColor(Color(whitecolor.x, whitecolor.y, whitecolor.z, main))
		draw.SimpleTextOutlined(self.ply .. "'s Backpack", "chicagoRP_NPCShop", 0, 13, whitecolor, 1, 0, 1, greycolor)
	cam.End3D2D()
end