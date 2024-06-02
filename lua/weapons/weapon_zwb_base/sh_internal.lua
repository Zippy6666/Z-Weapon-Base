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
	local own = self:GetOwner()
	return IsValid(own) && own:IsPlayer() -- && !own:IsSprinting()
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


local bobADS = 0.1
function SWEP:Inter_DoADS(pos, ang)

	local ADSActive = (self:GetNWBool("ADS") or self.Inter_CL_ADS_Active)
	local accelIncr = self.IronSights.Speed*0.0075

	if ADSActive then

		-- We are doing ADS
		-- Start raising

		-- Lower bob/sway scale + hide crosshair
		if self.BobScale != bobADS then
			self.BobScale = bobADS -- The scale of the viewmodel bob (viewmodel movement from left to right when walking around)
			self.SwayScale = bobADS -- The scale of the viewmodel sway (viewmodel position lerp when looking around).
			self.DrawCrosshair = CvarDeveloper:GetBool()
		end

		-- Accelerate raising of iron sights
		self.Inter_ADSAmt_Accel = self.Inter_ADSAmt_Accel == 1 && 1
		or ( (self.Inter_ADSAmt_Accel && math.Clamp( self.Inter_ADSAmt_Accel + accelIncr, accelIncr, self.IronSights.Speed)) or accelIncr )


		-- Raise iron sights
		self.Inter_ADSAmount = self.Inter_ADSAmount == 1 && 1
		or ( (self.Inter_ADSAmount && math.Clamp( self.Inter_ADSAmount + (FrameTime()* self.Inter_ADSAmt_Accel ), 0, 1)) or 0 )

		-- Reset this var (important!)
		self.Inter_ADSAmt_AccelOut = nil

	elseif self.Inter_ADSAmount != 0 then

		-- We are not doing ADS
		-- Start lowering

		-- Accelerate lowering of iron sights
		self.Inter_ADSAmt_AccelOut = self.Inter_ADSAmt_AccelOut == 1 && 1
		or ( (self.Inter_ADSAmt_AccelOut && math.Clamp( self.Inter_ADSAmt_AccelOut + accelIncr, accelIncr, self.IronSights.Speed)) or accelIncr )

		-- Lower iron sights
		self.Inter_ADSAmount = (self.Inter_ADSAmount && math.Clamp( self.Inter_ADSAmount - (FrameTime()*self.Inter_ADSAmt_AccelOut), 0, 1)) or 0

		-- Reset this var (important!)
		self.Inter_ADSAmt_Accel = nil

	end
	
	-- Adjust vm position accordingly
	if self.Inter_ADSAmount > 0 then
		if CvarDeveloper:GetBool() && LocalPlayer().ZWB_AdjustMode then
			self:Inter_ADSAdjust()
		end
	
		local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
		local ironPos = self.IronSights.Pos*self.Inter_ADSAmount
	
	
		-- local ironAng, ironPos = self.IronSights.Ang, self.IronSights.Pos
		-- ang:RotateAroundAxis(forward, ironAng.x)
		-- ang:RotateAroundAxis(right, ironAng.y)
		-- ang:RotateAroundAxis(up, ironAng.z)
	
	
		pos:Add( forward*ironPos.x )
		pos:Add( right*ironPos.y )
		pos:Add( up*ironPos.z )
	elseif self.BobScale != self.BaseBobScale then
		-- Set bob/sway scale + crosshair
		-- Returns to normal once sights are completely lowered
		self.BobScale = self.BaseBobScale -- The scale of the viewmodel bob (viewmodel movement from left to right when walking around)
		self.SwayScale = self.BaseSwayScale -- The scale of the viewmodel sway (viewmodel position lerp when looking around).
		self.DrawCrosshair = self.DoDrawCrosshair

	end


end


function SWEP:CanSecondaryAttack()
	return self:Inter_CanADS()
end


	-- Secondary attack aims down sights
function SWEP:SecondaryAttack()

	if ( !self:CanSecondaryAttack() ) then
		self:Inter_StopADS()
		return
	end


	self:ZWB_AimDownSights()

end

--[[
======================================================================================================================================================
                                           KEY/INPUT
======================================================================================================================================================
--]]


function SWEP:Inter_KeyPress(key)
	self:On_KeyPress(key)

	if key == IN_ATTACK then
		self:On_KeyPress()
	end

	if key == IN_ATTACK2 then
		self:TempVar("Inter_CL_ADS_Active", true, 0.3)
	end
end


function SWEP:Inter_KeyRelease(key)
	self:On_KeyRelease(key)

	if key == IN_ATTACK2 then
		self:Inter_StopADS()
		self.Inter_CL_ADS_Active = false
	end
end


--[[
======================================================================================================================================================
                                           View Model Position
======================================================================================================================================================
--]]


if CLIENT then



	function SWEP:GetViewModelPosition(pos, ang)


		self:Inter_DoADS(pos, ang)
		return pos, ang

	end

end