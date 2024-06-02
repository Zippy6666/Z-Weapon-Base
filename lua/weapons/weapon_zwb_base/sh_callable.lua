AddCSLuaFile()

// These are functions you can call
// Do not change them
// Should start with "ZWB_"


    -- Start aiming down sights
function SWEP:ZWB_AimDownSights()

    if self.ZWB_AimingDownSights then return end

    if SERVER then
        PrintMessage(HUD_PRINTTALK, "Entered ADS.")
    end

    self.ZWB_AimingDownSights = true

end


    -- Stop aiming down sights
function SWEP:ZWB_StopAimDownSights()

    if !self.ZWB_AimingDownSights then return end

    if SERVER then
        PrintMessage(HUD_PRINTTALK, "Exited ADS.")
    end

    self.ZWB_AimingDownSights = false

end