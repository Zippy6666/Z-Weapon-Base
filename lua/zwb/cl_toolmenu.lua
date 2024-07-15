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
        panel:Help("Switch iron sight adjustment mode (disabled, position, or angle).")


        panel:Button("Print ADS Pos", "zwb_ads_print_pos")
        panel:Help("Print out the vector and angle of the iron sights in the chat.")

    end)

end)