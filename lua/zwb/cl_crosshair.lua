local CvarDeveloper = GetConVar("developer")


local spreadMod = 500
local function DrawCrosshair()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) then return end
    if !wep.IsZWBWeapon then return end
    if !wep.Inter_DrawCrosshair && !CvarDeveloper:GetBool() then return end

    local thinking = wep:GetInter_IsThinking()

    if !thinking then
        return 
    end


    local spread = wep:Inter_GetSpread()
    ply.ZWB_Crosshair_Gap = (ply.ZWB_Crosshair_Gap && Lerp(0.1, ply.ZWB_Crosshair_Gap, spread * spreadMod)) or spread * spreadMod

    local x, y = ScrW() / 2, ScrH() / 2  -- Center of the screen
    local gap = ply.ZWB_Crosshair_Gap
    local length = 10
    local colamt = CvarDeveloper:GetBool() && 0 or 255


    -- Draw the crosshair
    surface.SetDrawColor(255, colamt, colamt, 255)
    surface.DrawLine(x - gap - length, y, x - gap, y)
    surface.DrawLine(x + gap, y, x + gap + length, y)
    surface.DrawLine(x, y - gap - length, x, y - gap)
    surface.DrawLine(x, y + gap, x, y + gap + length)


    local firing = wep:GetInter_Net_IsFiring()
    if firing && wep.Inter_CLNextIncreaseSpread < CurTime() then

        -- Assume we are firing on server, increase visual spread on client
        wep.Inter_CurSpreadAdd = wep.Inter_CurSpreadAdd + wep.Primary.Bullet.SpreadAccumulation*wep:Inter_GetSpreadMult()
        wep.Inter_CLNextIncreaseSpread = CurTime()+wep.Primary.Cooldown

    elseif !firing && wep.Inter_CurSpreadAdd > 0 && wep.Inter_NextDecreaseSpread < CurTime() then

        -- Decrease visual spread on client over time
        wep.Inter_CurSpreadAdd = math.Clamp(wep.Inter_CurSpreadAdd - wep.Primary.Bullet.SpreadRecover, 0, wep.Primary.Bullet.SpreadMax*wep:Inter_GetSpreadMult())
        wep.Inter_NextDecreaseSpread = CurTime()+0.1

    end
end

hook.Add("HUDPaint", "ZWB_Crosshair", DrawCrosshair)
