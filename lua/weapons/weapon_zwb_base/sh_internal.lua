AddCSLuaFile()

// Engine functions here
// Custom functions should start with "Inter_" to mark them as internal


SWEP.IsZWBWeapon = true


--[[
======================================================================================================================================================
                                           INIT
======================================================================================================================================================
--]]

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end


--[[
======================================================================================================================================================
                                           PRIMARY
======================================================================================================================================================
--]]

function SWEP:PrimaryAttack()

	-- Use custom if we should
	if self.Use_Custom_PrimaryAttack == true then
		return self:Custom_PrimaryAttack()
	end


	local own = self:GetOwner()


	if !IsValid(own) then return end
	if !self:CanPrimaryAttack() then return end


	-- Fire bullets
	self:FireBullets({
		Damage = self.Primary.Bullet.Damage,
		Force = self.Primary.Bullet.Force,
		HullSize = self.Primary.Bullet.HullSize,
		Num = self.Primary.Bullet.Num,
		Tracer = self.Primary.Bullet.Tracer,
		TracerName = self.Primary.Bullet.TracerName,
		Spread = Vector(self.Primary.Bullet.Spread, self.Primary.Bullet.Spread),
		Src = own:GetShootPos(),
		Dir = own:GetAimVector(),
	})

	-- Sounds/effects
	self:EmitSound(self.Primary.Sound, 140, math.random(95, 105), 1, CHAN_WEAPON)
	self:ShootEffects()

	-- Take ammo / set cooldown
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self:SetNextPrimaryFire( CurTime() + self.Primary.Cooldown )

	-- View punch
	if ( !own:IsNPC() ) then
		self:Inter_ViewPunch()
	end

end


function SWEP:Inter_ViewPunch()

	-- Use custom if we should
	if self.Use_Custom_ViewPunch == true then
		return self:Custom_ViewPunch()
	end

	local own = self:GetOwner()

	local ang1 = Angle(-self.Primary.ViewPunch*0.33, 0, 0)
	own:SetViewPunchAngles(ang1)

	local rand1 = math.Rand(-self.Primary.ViewPunch, self.Primary.ViewPunch)*3
	local rand2 = math.Rand(-self.Primary.ViewPunch, self.Primary.ViewPunch)*3
	local rand3 = math.Rand(-self.Primary.ViewPunch, self.Primary.ViewPunch)*3
	local ang2 = Angle(rand1, rand2, rand3)
	own:SetViewPunchVelocity(ang2)

end


function SWEP:Reload()
	local didReload = self:DefaultReload( ACT_VM_RELOAD )
	if didReload then
		self:On_Reload()
		self:EmitSound(self.Primary.ReloadSound, 80, math.random(95,105), 0.75, CHAN_AUTO)
	end
end


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


function SWEP:Inter_KeyPress(key)
	self:On_KeyPress(key)
end


function SWEP:Inter_KeyRelease(key)
	self:On_KeyRelease(key)

	if key == IN_ATTACK2 then
		self:Inter_StopADS()
	end
end

