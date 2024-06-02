// SHARED HOOKS


    -- Key presses
hook.Add("KeyRelease", "ZWB_KeyRelease", function( ply, key )

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) && wep.IsZWBWeapon then
        wep:Inter_KeyRelease(key)
    end

end)