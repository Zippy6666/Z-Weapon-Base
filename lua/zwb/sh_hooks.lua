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



hook.Add("PreRegisterSWEP", "ZWB", function( swep, class )

	if swep.IsZWBWeapon then

        if CLIENT then
            language.Add( class, swep.PrintName ) -- Language

            -- local fileExt = ".png"
            -- if file.Exists("materials/entities/"..class..fileExt, "GAME") then
            --     killicon.Add( class, "materials/entities/"..class..fileExt, color_white ) -- Killicon
            -- end

        end

		list.Add( "NPCUsableWeapons", { class = class, title = "[ZWB] "..swep.PrintName.." ("..class..")" } ) -- Add to NPC weapons
	end

end)