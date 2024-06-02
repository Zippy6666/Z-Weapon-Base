AddCSLuaFile()

// Engine functions here
// Custom functions should start with "Inter_" to mark them as internal


SWEP.IsZWBWeapon = true


--[[
======================================================================================================================================================
                                           SECONDARY/ADS
======================================================================================================================================================
--]]


function SWEP:Inter_CanADS()
	return true
end

function SWEP:Inter_StopADS()
	self:ZWB_StopAimDownSights()
end


function SWEP:CanSecondaryAttack()
	return self:Inter_CanADS()
end


	-- Secondary attack aims down sights
function SWEP:SecondaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end


	self:ZWB_AimDownSights()

end


--[[
======================================================================================================================================================
                                           KEY/INPUT
======================================================================================================================================================
--]]


function SWEP:Inter_KeyRelease(key)
	self:Custom_KeyRelease(key)

	if key == IN_ATTACK2 then
		self:Inter_StopADS()
	end
end
