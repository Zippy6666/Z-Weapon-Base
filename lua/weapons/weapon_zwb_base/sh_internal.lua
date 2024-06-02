AddCSLuaFile()

// Engine functions here
// New functions should start with "Inter_" to mark them as internal


local CvarDeveloper = GetConVar("developer")



SWEP.IsZWBWeapon = true


--[[
======================================================================================================================================================
                                           INITIALIZE
======================================================================================================================================================
--]]

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self:Post_Initialize()
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


local posIncMult = 1
function SWEP:Inter_ADSAdjust()
	local ply = LocalPlayer()
	local own = self:GetOwner()

	if own!=ply then return end


	if ply.ZWB_AdjustMode == 1 then

		local ftime = FrameTime()
		if ply:KeyDown(IN_FORWARD) then
			self.IronSights.Pos.x = self.IronSights.Pos.x+ftime*posIncMult
		elseif ply:KeyDown(IN_BACK) then
			self.IronSights.Pos.x = self.IronSights.Pos.x-ftime*posIncMult
		elseif ply:KeyDown(IN_MOVELEFT) then
			self.IronSights.Pos.y = self.IronSights.Pos.y+ftime*posIncMult
		elseif ply:KeyDown(IN_MOVERIGHT) then
			self.IronSights.Pos.y = self.IronSights.Pos.y-ftime*posIncMult
		elseif ply:KeyDown(IN_JUMP) then
			self.IronSights.Pos.z = self.IronSights.Pos.z+ftime*posIncMult
		elseif ply:KeyDown(IN_SPEED) then
			self.IronSights.Pos.z = self.IronSights.Pos.z-ftime*posIncMult
		end

	-- elseif ply.ZWB_AdjustMode == 2 then

	-- print("attempting to adjust angs")

	end
end


local ADS_ADJUST_POS = 1
local ADS_ADJUST_ANG = 2
function SWEP:Inter_ADSVMPos(pos, ang)


	if CvarDeveloper:GetBool() && LocalPlayer().ZWB_AdjustMode then
		self:Inter_ADSAdjust()
	end

	local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
	local ironPos = self.IronSights.Pos

	
	-- local ironAng, ironPos = self.IronSights.Ang, self.IronSights.Pos
	-- ang:RotateAroundAxis(forward, ironAng.x)
	-- ang:RotateAroundAxis(right, ironAng.y)
	-- ang:RotateAroundAxis(up, ironAng.z)


	pos:Add( forward*ironPos.x )
	pos:Add( right*ironPos.y )
	pos:Add( up*ironPos.z )

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


--[[
======================================================================================================================================================
                                           View Model Position
======================================================================================================================================================
--]]


if CLIENT then


	function SWEP:GetViewModelPosition(EyePos, EyeAng)

		if self:GetNWBool("ADS") then
			self:Inter_ADSVMPos(EyePos, EyeAng)
		end
		
		return EyePos, EyeAng

	end

end