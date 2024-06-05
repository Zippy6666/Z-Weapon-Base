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


    -- Register SWEPs for NPCs
hook.Add("PreRegisterSWEP", "ZBASE", function( swep, class )

	if swep.IsZWBWeapon then
		list.Add( "NPCUsableWeapons", { class = class, title = "[ZWB] "..swep.PrintName.." ("..class..")" } )
	end

end)