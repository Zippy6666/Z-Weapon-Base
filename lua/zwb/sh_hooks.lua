// SHARED HOOKS


    -- Key release
hook.Add("KeyRelease", "ZWB_KeyRelease", function( ply, key )

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) && wep.IsZWBWeapon then
        wep:Inter_KeyRelease(key)
    end

end)


-- Key press
hook.Add("KeyPress", "ZWB_KeyPress", function( ply, key )

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) && wep.IsZWBWeapon then
        wep:Inter_KeyPress(key)
    end

end)