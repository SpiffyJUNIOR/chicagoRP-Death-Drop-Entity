local HideHUD = false
local OpenMotherFrame = nil
local Dynamic = 0
local graycolor = Color(20, 20, 20, 200)
local reddebug = Color(200, 10, 10, 150)
local blurMat = Material("pp/blurscreen")

local function isempty(s)
    return s == nil or s == ""
end

local function BlurBackground(panel)
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 100
    local x, y = panel:LocalToScreen(0, 0)
    local FrameRate, Num, Dark = 1 / RealFrameTime(), 5, 0

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blurMat)

    for i = 1, Num do
        blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end

    surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
    Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
end

local function SmoothScrollBar(vbar) -- why
    vbar.nInit = vbar.Init
    function vbar:Init()
        self:nInit()
        self.DeltaBuffer = 0
    end

    vbar.nSetUp = vbar.SetUp
    function vbar:SetUp(_barsize_, _canvassize_)
        self:nSetUp(_barsize_, _canvassize_)
        self.BarSize = _barsize_
        self.CanvasSize = _canvassize_ - _barsize_
        if (1 > self.CanvasSize) then self.CanvasSize = 1 end
    end

    vbar.nAddScroll = vbar.AddScroll
    function vbar:AddScroll(dlta)
        self:nAddScroll(dlta)

        self.DeltaBuffer = OldScroll + (dlta * (self:GetSmoothScroll() && 75 || 50))
        if (self.DeltaBuffer < -self.BarSize) then self.DeltaBuffer = -self.BarSize end
        if (self.DeltaBuffer > (self.CanvasSize + self.BarSize)) then self.DeltaBuffer = self.CanvasSize + self.BarSize end
    end

    vbar.nSetScroll = vbar.SetScroll
    function vbar:SetScroll(scrll)
        self:nSetScroll(scrll)

        if (scrll > self.CanvasSize) then scrll = self.CanvasSize end
        if (0 > scrll ) then scrll = 0 end
        self.Scroll = scrll
    end

    function vbar:AnimateTo(scrll, length, delay, ease)
        self.DeltaBuffer = scrll
    end

    function vbar:GetDeltaBuffer()
        if (self.Dragging) then self.DeltaBuffer = self:GetScroll() end
        if (!self.Enabled) then self.DeltaBuffer = 0 end
        return self.DeltaBuffer
    end

    vbar.nThink = vbar.Think
    function vbar:Think()
        self:nThink()
        if (!self.Enabled) then return end

        local FrameRate = (self.CanvasSize / 10) > math.abs(self:GetDeltaBuffer() - self:GetScroll()) && 2 || 5
        self:SetScroll(Lerp(FrameTime() * (self:GetSmoothScroll() && FrameRate || 10), self:GetScroll(), self:GetDeltaBuffer()))

        if (self.CanvasSize > self.DeltaBuffer && self.Scroll == self.CanvasSize) then self.DeltaBuffer = self.CanvasSize end
        if (0 > self.DeltaBuffer && self.Scroll == 0) then self.DeltaBuffer = 0 end
    end
end

hook.Add("HUDShouldDraw", "chicagoRP_deathdropentity_HideHUD", function()
    if HideHUD == true then
        return false
    end
end)

net.Receive("chicagoRP_deathdropentity_GUI", function()
    local ply = LocalPlayer()
    if IsValid(OpenMotherFrame) then OpenMotherFrame:Close() return end
    if !IsValid(ply) or !ply:Alive() or ply:InVehicle() then return end
    if !enabled:GetBool() then return end

    local viewtrace = ply:GetEyeTraceNoCursor()
    local entname = viewtrace.Entity:GetName()

    if isempty(entname) or entname != "chicagoRP_backpack" then return end -- EZ anti-exploit

    local closebool = net.ReadBool()

    if closebool == false then return end

    local screenwidth = ScrW()
    local screenheight = ScrH()
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth / 1.2, screenheight / 1.2) -- 1600/900
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(true)
    motherFrame:ShowCloseButton(true)
    motherFrame:SetTitle("Shop")
    motherFrame:ParentToHUD()
    HideHUD = true

    motherFrame.lblTitle.Think = nil

    chicagoRP.PanelFadeIn(motherFrame, 0.15)

    motherFrame:MakePopup()
    motherFrame:Center()

    function motherFrame:OnClose()
        if IsValid(self) then
            chicagoRP.PanelFadeOut(motherFrame, 0.15)
        end

        HideHUD = false
    end

    function motherFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE or key == KEY_W or key == KEY_A or key == KEY_S or key == KEY_D or key == KEY_Q then
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(self) then
                    self:Close()
                end
            end)
        end
    end

    function motherFrame:Paint(w, h)
        -- BlurBackground(self)
    end

    OpenMotherFrame = motherFrame
end)

print("chicagoRP NPC Shop GUI loaded!")




