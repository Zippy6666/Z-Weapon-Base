AddCSLuaFile()

// Engine functions here
// Custom functions should start with "Inter_" to mark them as internal




function SWEP:SecondaryAttack()

    -- Use custom if we should
    if self.Use_Custom_SecondaryAttack == true then
        return self:Custom_CanSecondaryAttack()
    end

	-- Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end

end
