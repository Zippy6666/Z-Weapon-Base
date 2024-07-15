local red = Color(255, 0, 0)
local green = Color(0, 255, 0)
local blue = Color(0, 0, 255)
local dev = GetConVar("developer")

hook.Add("PopulateToolMenu", "NPCSpawner", function()
    spawnmenu.AddToolMenuOption("Options", "Zippy's Weapon Base", "Developer", "Iron Sights", "", "", function(panel)

        RunConsoleCommand("zwb_ads_adjust_mode", "0")


        local ironSightModeBtn = panel:Button("ADS Adjust Mode: Disabled")
        ironSightModeBtn:SetTextColor(red)
        ironSightModeBtn:SetSize(nil, 100)
        ironSightModeBtn.CurrentMode = "Disabled"
        function ironSightModeBtn:DoClick()
            if !dev:GetBool() then
                chat.AddText(red, "'developer' must be set to '1' in console!")
                return
            end

            if self.CurrentMode == "Disabled" then
                self.CurrentMode = "Position"
            elseif self.CurrentMode == "Position" then
                self.CurrentMode = "Angle"
            elseif self.CurrentMode == "Angle" then
                self.CurrentMode = "Disabled"
            end

            local translateMode = {
                Disabled = 0,
                Position = 1,
                Angle = 2,
            }

            local modeNumber = translateMode[self.CurrentMode]

            local color = {
                [0] = red,
                [1] = blue,
                [2] = green,
            }

            local curCol = color[modeNumber]

            self:SetTextColor(curCol)
            self:SetText(self.CurrentMode)

            RunConsoleCommand("zwb_ads_adjust_mode", tostring(modeNumber))
        end

        panel:ControlHelp("Switch iron sight adjustment mode (disabled, position, or angle). Crouch while aiming down the sights of your weapon and use your movement keys to adjust until the sights align with the crosshair.")
        panel:ControlHelp( "\nFORWARD = 'W' (your forward key)" )
        panel:ControlHelp( "LEFT = 'A' (your left key)" )
        panel:ControlHelp( "BACKWARD = 'S' (your backward key)" )
        panel:ControlHelp( "RIGHT = 'D' (your right key)" )
        panel:ControlHelp( "UP = 'SPACE' (your jump key)" )
        panel:ControlHelp( "DOWN = 'SHIFT' (your sprint key)\n" )

        local ironSightResetBtn = panel:Button("Reset")
        ironSightResetBtn:SetTextColor(red)
        function ironSightResetBtn:DoClick()
            if !dev:GetBool() then
                chat.AddText(red, "'developer' must be set to '1' in console!")
                return
            end
            RunConsoleCommand("zwb_ads_reset")
        end
        panel:ControlHelp("Reset iron sight position and angles.")

        panel:Button("Print ADS Pos", "zwb_ads_print_pos")
        panel:ControlHelp("Print out the vector and angle of the iron sights in the chat.")

    end)

end)