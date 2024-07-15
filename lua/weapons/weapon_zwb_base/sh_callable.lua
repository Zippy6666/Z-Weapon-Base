AddCSLuaFile()


local isMultiplayer = !game.SinglePlayer()

// These are functions you can call
// Do not change them
// Should start with "ZWB_"


    -- Start aiming down sights
function SWEP:ZWB_AimDownSights()

    if self.ZWB_AimingDownSights then return end

    if !isMultiplayer && SERVER then
        self:SetInter_ADS(true)
    end

    self.ZWB_AimingDownSights = true

end


    -- Stop aiming down sights
function SWEP:ZWB_StopAimDownSights()

    if !self.ZWB_AimingDownSights then return end

    if !isMultiplayer && SERVER then
        self:SetInter_ADS(false)
    end

    self.ZWB_AimingDownSights = false

end


    -- Return wheter or not we are aiming down sights
function SWEP:ZWB_IsAimingDownSights()
    return self:Inter_InADS()
end