local CvarDeveloper = GetConVar("developer")
local isSingleplayer = game.SinglePlayer()
local isMultiplayer = !isSingleplayer
local spreadMod = 500
local crosshairDecreaseRecoilMult = 30
local crosshairRecoilAmt = 10


local function DrawCrosshair()


    -- The player
    local ply = LocalPlayer()
    if !IsValid(ply) then return end -- No valid player


    -- The weapon
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) then return end -- Only run code if weapon is valid



    if !wep.IsZWBWeapon then return end -- Only run for ZWB weapons
    if !wep.Inter_DrawCrosshair && !CvarDeveloper:GetBool() then return end -- Only run when we should draw the crosshair


    -- Is the weapon thinking?
    local thinking = wep.Inter_IsThinking or (isSingleplayer && wep:GetInter_IsThinking())
    if !thinking then return end -- Only run crosshair code when weapon is thinking

    
    -- Draw the crosshair
    local x, y = ScrW()*0.5, ScrH()*0.5
    local gap = wep.Inter_Crosshair_Gap + wep.Inter_CrosshairRecoil
    local length = 10
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawLine(x - gap - length, y, x - gap, y)
    surface.DrawLine(x + gap, y, x + gap + length, y)
    surface.DrawLine(x, y - gap - length, x, y - gap)
    surface.DrawLine(x, y + gap, x, y + gap + length)


    -- Decrease visual spread on client over time
    local firing = wep.Inter_IsFiring or (isSingleplayer && wep:GetInter_Net_IsFiring())
    if !firing && wep.Inter_CurSpreadAdd > 0 && wep.Inter_NextDecreaseSpread < CurTime() then
        wep.Inter_CurSpreadAdd = math.Clamp(wep.Inter_CurSpreadAdd - wep.Primary.Bullet.SpreadRecover, 0, wep.Primary.Bullet.SpreadMax*wep:Inter_GetSpreadMult())
        wep.Inter_NextDecreaseSpread = CurTime()+0.1
    end


    -- Crosshair recoil effect
    if wep.Inter_CrosshairRecoil > 0 then
        wep.Inter_CrosshairRecoil = math.Clamp(wep.Inter_CrosshairRecoil - FrameTime()*crosshairDecreaseRecoilMult, 0, wep.Inter_CrosshairRecoil)
    end


    -- Lerp crosshair gap
    wep.Inter_Crosshair_Gap = Lerp(0.1, wep.Inter_Crosshair_Gap, wep:Inter_GetSpread() * spreadMod) 
end


function ZWB_CrosshairRecoil()
    local own = LocalPlayer()
    local wep = own:GetActiveWeapon()

    if IsValid(wep) && wep.IsZWBWeapon then
        wep.Inter_CurSpreadAdd = wep.Inter_CurSpreadAdd + wep.Primary.Bullet.SpreadAccumulation*wep:Inter_GetSpreadMult()
        wep.Inter_CLNextIncreaseSpread = CurTime()+wep.Primary.Cooldown
        wep.Inter_CrosshairRecoil = crosshairRecoilAmt
    end
end


net.Receive("ZWB_FiredWeapon_SendCL", function()
    ZWB_CrosshairRecoil()
end)


hook.Add("HUDPaint", "ZWB_Crosshair", DrawCrosshair)