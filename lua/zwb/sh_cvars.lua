if CLIENT then
        -- Mode for adjusting iron sight position
    concommand.Add("zwb_ads_adjust_mode", function(_, _, args)

        local ply = LocalPlayer()
        local mode = args[1]

        if mode == "1" then
            ply.ZWB_AdjustMode = 1
            print("Adjusting mode set to 'Position'")
        elseif mode == "2" then
            ply.ZWB_AdjustMode = 2
            print("Adjusting mode set to 'Angle'")
        else
            ply.ZWB_AdjustMode = nil
            print("ADS adjusting disabled")
        end

    end)

    local color_green = Color(0, 255, 0)
    concommand.Add("zwb_ads_print_pos", function(_, _, args)

        local ply = LocalPlayer()
        local mode = args[1]
        local wep = ply:GetActiveWeapon()

        if !IsValid(wep) then return end
        if !wep.IsZWBWeapon then return end

        chat.AddText(color_green, "ADS Position Offset: "..tostring(wep.IronSights.Pos))

    end)
end