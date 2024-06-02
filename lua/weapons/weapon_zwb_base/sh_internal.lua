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

	self:On_Initialize()

	-- Holdtype
	self:SetHoldType( self.HoldType )

	-- Vars
	self.Inter_CurSpreadAdd = 0

end



function SWEP:Think()

	self:On_Think()

	if SERVER then

		-- Decrease spread accumulation when not firing
		if !self.Inter_IsFiring && self.Inter_CurSpreadAdd > 0 then
			self.Inter_CurSpreadAdd = math.Clamp(self.Inter_CurSpreadAdd-self.Primary.Bullet.SpreadRecover, 0, self.Inter_CurSpreadAdd)
		end

	end

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


	local spread_mult_from_speed = own:IsPlayer() && 1+own:GetVelocity():Length()*0.01 or 1
	local spread = (self.ZWB_AimingDownSights && self.Primary.Bullet.Spread or self.Primary.Bullet.Spread*5)*spread_mult_from_speed
	local spread_accumulated = math.Clamp(spread+self.Inter_CurSpreadAdd, 0, 1)
	local accumulate = self.ZWB_AimingDownSights && self.Primary.Bullet.SpreadAccumulation*0.5 or self.Primary.Bullet.SpreadAccumulation


	-- Fire bullets
	self:FireBullets({
		Damage = self.Primary.Bullet.Damage,
		Force = self.Primary.Bullet.Force,
		HullSize = self.Primary.Bullet.HullSize,
		Num = self.Primary.Bullet.Num,
		Tracer = self.Primary.Bullet.Tracer,
		TracerName = self.Primary.Bullet.TracerName,
		Spread = Vector(spread_accumulated, spread_accumulated),
		Src = own:GetShootPos(),
		Dir = own:GetAimVector(),
	})

	-- Sounds/effects
	self:EmitSound(self.Primary.Sound, 140, math.random(95, 105), 1, CHAN_WEAPON)
	self:ShootEffects()

	-- View punch
	if own:IsPlayer() then
		self:Inter_ViewPunch()
	end

	-- Increase spread
	self.Inter_CurSpreadAdd = self.Inter_CurSpreadAdd + accumulate
	self:TempVar("Inter_IsFiring", true, self.Primary.Bullet.SpreadRecoverDelay)


	-- Take ammo / set cooldown
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self:SetNextPrimaryFire( CurTime() + self.Primary.Cooldown )
end


function SWEP:Inter_ViewPunch()

	-- Use custom if we should
	if self.Use_Custom_ViewPunch == true then
		return self:Custom_ViewPunch()
	end

	local own = self:GetOwner()
	local amt = self.Primary.ViewPunch+(self.Inter_CurSpreadAdd)

	local ang1 = Angle(-amt*0.33, 0, 0)
	own:SetViewPunchAngles(ang1)

	local rand1 = math.Rand(-amt, amt)*3
	local rand2 = math.Rand(-amt, amt)*3
	local rand3 = math.Rand(-amt, amt)*3
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
	local accelIncr = self.IronSights.Speed*0.006

	if ADSActive then

		-- We are doing ADS
		-- Start raising


		-- Accelerate raising of iron sights
		self.Inter_ADSAmt_Accel = self.Inter_ADSAmt_Accel == 1 && 1
		or ( (self.Inter_ADSAmt_Accel && math.Clamp( self.Inter_ADSAmt_Accel + accelIncr, accelIncr, self.IronSights.Speed)) or accelIncr )


		-- Raise iron sights
		self.Inter_ADSAmount = self.Inter_ADSAmount == 1 && 1
		or ( (self.Inter_ADSAmount && math.Clamp( self.Inter_ADSAmount + (FrameTime()* self.Inter_ADSAmt_Accel ), 0, 1)) or 0 )

		-- Reset this var (important!)
		self.Inter_ADSAmt_AccelOut = nil

		-- Don't draw crosshair when doing ADS
		self.DrawCrosshair = false 

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

		-- Draw crosshair if we should when not doing ADS
		self.DrawCrosshair = self.DoDrawCrosshair

	end

	self.BobScale = math.Clamp(1-self.Inter_ADSAmount, bobADS, self.BaseBobScale)
	self.SwayScale = math.Clamp(1-self.Inter_ADSAmount, bobADS, self.BaseSwayScale)


	-- Adjust vm position accordingly
	if self.Inter_ADSAmount > 0 then

		-- Tweak ADS pos for devs
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


	function SWEP:CalcView( ply, pos, ang, fov, znewar, zfar )
		return pos, ang, fov-(self.IronSights.ZoomAmount*(self.Inter_ADSAmount or 0))
	end

end