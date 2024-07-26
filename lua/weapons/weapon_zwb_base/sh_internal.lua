AddCSLuaFile()


if SERVER then
	util.AddNetworkString("ZWB_FiredWeapon_SendCL")
end


local CvarDeveloper = GetConVar("developer")
local isSingleplayer = game.SinglePlayer()
local isMultiplayer = !isSingleplayer



// Engine functions here
// New functions should start with "Inter_" to mark them as internal



SWEP.IsZWBWeapon = true
SWEP.DrawCrosshair = false


SWEP.Secondary.Ammo = -1 -- Ammo type (Pistol, SMG1, etc.) See: https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Secondary.ClipSize = -1 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket
SWEP.Secondary.DefaultClip = 0 -- Default ammo in the clip, making it higher than ClipSize will give player additional ammo on spawn
SWEP.Secondary.Automatic = false -- If true makes the weapon shoot automatically as long as the player has primary attack button held down


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
	self.Inter_NextDecreaseSpread = CurTime()
	self.Inter_IsFiring = false
	self.Inter_IsThinking = false


	-- Client vars
	if CLIENT then
		self.Inter_CLNextIncreaseSpread = CurTime()
		self.Inter_CrosshairRecoil = 0
		self.Inter_Crosshair_Gap = 0
	end


	-- local fileExt = ".png"
	-- if file.Exists("materials/entities/"..self:GetClass()..fileExt, "GAME") then
	-- 	self.WepSelectIcon = "materials/entities/"..self:GetClass()..fileExt
	-- end

end

function SWEP:SetupDataTables()
	if isSingleplayer then
		-- Networked vars
		self:NetworkVar( "Bool", "Inter_Net_IsFiring" )
		self:NetworkVar( "Bool", "Inter_IsThinking" )
		self:NetworkVar( "Bool", "Inter_ADS" )
	end

	self:On_SetupDataTables()
end

--[[
======================================================================================================================================================
                                           THINK
======================================================================================================================================================
--]]

function SWEP:Think()

	self:TempVar("Inter_IsThinking", true, 0.2)
	self:On_Think()

	if SERVER then

		-- Decrease spread accumulation when not firing
		if !self.Inter_IsFiring && self.Inter_CurSpreadAdd > 0 && self.Inter_NextDecreaseSpread < CurTime() then

			local curSpread = self:Inter_GetSpread()
			local curSpreadMult = self:Inter_GetSpreadMult()


			self.Inter_CurSpreadAdd = math.Clamp(self.Inter_CurSpreadAdd - self.Primary.Bullet.SpreadRecover, 0, self.Primary.Bullet.SpreadMax*self:Inter_GetSpreadMult())
			self.Inter_NextDecreaseSpread = CurTime()+0.1

		end

		-- Register wheter or not we are thinking
		if isSingleplayer then
			self:TempNetVar("Inter_IsThinking", true, 0.2)
		end

	end

end

--[[
======================================================================================================================================================
                                           PRIMARY
======================================================================================================================================================
--]]


function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) then

		self:EmitSound("weapons/ar2/ar2_empty.wav", 70, math.random(90, 110), 0.9, CHAN_AUTO)
		self:SetNextPrimaryFire( CurTime() + 1 )
		return false

	end

	return true

end


function SWEP:PrimaryAttack()

	local own = self:GetOwner()
	if !IsValid(own) then return end
	if !self:CanPrimaryAttack() then return end
	if self:Before_Shoot() then return end


	-- Fire bullets
	if self.Primary.Bullet.Enable then

		local spread = self:Inter_GetSpread()
		self:FireBullets({
			Damage = self.Primary.Bullet.Damage,
			Force = self.Primary.Bullet.Force,
			HullSize = self.Primary.Bullet.HullSize,
			Num = self.Primary.Bullet.Num,
			Tracer = self.Primary.Bullet.Tracer,
			TracerName = self.Primary.Bullet.TracerName,
			Spread = Vector(spread, spread),
			Src = own:GetShootPos(),
			Dir = own:GetAimVector(),
			Attacker = own,
			Inflictor = self,
		})

	end

	-- Sounds/effects
	if self.Primary.Sound && self.Primary.Sound != "" then
		self:EmitSound(self.Primary.Sound, 140, math.random(95, 105), 1, CHAN_WEAPON)
		self:ShootEffects()
	end


	-- Muzzle light
	if SERVER && self.Primary.MuzzleLight then

		local col = self.Primary.MuzzleLightColor or color_white
		local muzzleLight = ents.Create("light_dynamic")
		muzzleLight:SetKeyValue("brightness", "2")
		muzzleLight:SetKeyValue("distance", "300")
		muzzleLight:SetPos(own:GetShootPos())

		if isstring(col) then
			muzzleLight:Fire("Color", col)
		elseif istable(col) then
			muzzleLight:Fire("Color", col.r .. " " .. col.g .. " " .. col.b)
		end

		muzzleLight:Spawn()
		muzzleLight:Activate()
		muzzleLight:Fire("TurnOn", "", 0)
		SafeRemoveEntityDelayed(muzzleLight, 0.1)

	end



	-- View punch
	if own:IsPlayer() then

		self:Inter_ViewPunch()

		if isMultiplayer && CLIENT then
			ZWB_CrosshairRecoil()
		elseif isSingleplayer && SERVER then
			net.Start("ZWB_FiredWeapon_SendCL")
			net.Send(own)
		end

	end



	-- Increase spread
	self.Inter_CurSpreadAdd = self.Inter_CurSpreadAdd + self.Primary.Bullet.SpreadAccumulation*self:Inter_GetSpreadMult()


	-- Important variables
	self:TempVar("Inter_IsFiring", true, 0.2)
	if isSingleplayer then
		self:TempNetVar("Inter_Net_IsFiring", true, 0.2)
	end

	-- Take ammo / set cooldown
	self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	self:SetNextPrimaryFire( CurTime() + self.Primary.Cooldown )


	self:On_Shoot()
end


function SWEP:Inter_DefaultMuzzleFlash()
	local vm = self:GetOwner():GetViewModel()
	if IsValid(vm) then

		if self.Primary.MuzzleFlash == true then
			local effectdata = EffectData()
			effectdata:SetEntity(vm)
			effectdata:SetFlags(1)
			util.Effect( "MuzzleFlash", effectdata, true, true )
		elseif self.Primary.MuzzleFlash == "big" then
			local effectdata = EffectData()
			effectdata:SetEntity(vm)
			effectdata:SetFlags(7)
			util.Effect( "MuzzleFlash", effectdata, true, true )
		end

	end
end


function SWEP:Inter_DefaultWorldMuzzleFlash()

	if self.Primary.MuzzleFlash == true then
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetFlags(1)
		util.Effect( "MuzzleFlash", effectdata, true, true )
	elseif self.Primary.MuzzleFlash == "big" then
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetFlags(7)
		util.Effect( "MuzzleFlash", effectdata, true, true )
	end

end


function SWEP:Inter_GetSpreadMult()

	local own = self:GetOwner()

	if !IsValid(own) then return 0 end

	if own:IsNPC() then

		if self.Primary.Bullet.Num >= 2 then
			-- Shotgun
			return 1
		else
			return 0
		end

	elseif own:IsPlayer() then

		local ADSActive = self:Inter_InADS()

		local mult = 1

		if ADSActive or own:Crouching() then
			mult = mult*0.5
		end

		return mult

	end

end


local baseSpread = 0.004
function SWEP:Inter_GetSpread()

	local own = self:GetOwner()

	if !IsValid(own) then return 0 end

	local spreadMult = self:Inter_GetSpreadMult()
	local speed = (own:IsPlayer() && own:GetVelocity():Length()*0.0002) or (own:IsNPC() && own:GetMoveVelocity():Length()*0.0002)
	local currentSpread = (baseSpread + self.Inter_CurSpreadAdd) + speed

	if !self:Inter_InADS() or self.Primary.Bullet.Num >= 2 then
		currentSpread = currentSpread + self.Primary.Bullet.HipFireSpread
	end

	return math.Clamp(currentSpread*spreadMult, 0, self.Primary.Bullet.SpreadMax*spreadMult)

end


function SWEP:Inter_ViewPunch()

	local amt = self.Primary.ViewPunch+(self.Inter_CurSpreadAdd)
	if amt <= 0 then return end

	local own = self:GetOwner()


	local ang1 = Angle(-amt*0.33, 0, 0)
	own:SetViewPunchAngles(ang1)

	if self:Inter_InADS() then
		local rand1 = math.Rand(-amt, amt)*3
		local rand2 = math.Rand(-amt, amt)*3
		local rand3 = math.Rand(-amt, amt)*3
		local ang2 = Angle(rand1, rand2, rand3)
		own:SetViewPunchVelocity(ang2)
	end

end


function SWEP:Reload()
	if !self.Primary.DefaultReload then

		self:On_Reload()

	else

		local didReload = self:DefaultReload( ACT_VM_RELOAD )

		if didReload then
			self:On_Reload()
			self:EmitSound(self.Primary.ReloadSound, 80, math.random(95,105), 0.75, CHAN_AUTO)
		end

	end
end


function SWEP:GetNPCBurstSettings()
	return self.Primary.ClipSize*0.1, self.Primary.ClipSize*0.2, self.Primary.Cooldown
end


function SWEP:GetNPCRestTimes()
	return self.Primary.Cooldown, self.Primary.Cooldown*2
end


function SWEP:GetNPCBulletSpread( WeaponProficiency )
	return (5-WeaponProficiency)*self.Primary.Bullet.SpreadMax*8
end


function SWEP:CanBePickedUpByNPCs()
	return true
end


--[[
======================================================================================================================================================
                                           SECONDARY/ADS
======================================================================================================================================================
--]]


function SWEP:Inter_InADS()
	return self.ZWB_AimingDownSights or self.Inter_CL_ADS_Active or (isSingleplayer && self:GetInter_ADS())
end


function SWEP:Inter_CanADS()
	local own = self:GetOwner()
	return IsValid(own) && own:IsPlayer() -- && !own:IsSprinting()
end


function SWEP:Inter_StopADS()
	self:ZWB_StopAimDownSights()
end


if CLIENT then
	local posIncMult = 0.75
	local angIncMult = 3
	local bobADS = 0.1

	function SWEP:Inter_ADSAdjust()
		local ply = LocalPlayer()
		local own = self:GetOwner()

		if own!=ply then return end
		if !ply:KeyDown(IN_DUCK) then return end

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

		elseif ply.ZWB_AdjustMode == 2 then

			local ftime = FrameTime()
			if ply:KeyDown(IN_FORWARD) then
				self.IronSights.Ang.x = self.IronSights.Ang.x+ftime*angIncMult
			elseif ply:KeyDown(IN_BACK) then
				self.IronSights.Ang.x = self.IronSights.Ang.x-ftime*angIncMult
			elseif ply:KeyDown(IN_MOVELEFT) then
				self.IronSights.Ang.y = self.IronSights.Ang.y+ftime*angIncMult
			elseif ply:KeyDown(IN_MOVERIGHT) then
				self.IronSights.Ang.y = self.IronSights.Ang.y-ftime*angIncMult
			elseif ply:KeyDown(IN_JUMP) then
				self.IronSights.Ang.z = self.IronSights.Ang.z+ftime*angIncMult
			elseif ply:KeyDown(IN_SPEED) then
				self.IronSights.Ang.z = self.IronSights.Ang.z-ftime*angIncMult
			end

		end
	end

	function SWEP:Inter_DoADS(pos, ang)
		local accelIncr = self.IronSights.Speed*0.006

		if self:Inter_InADS() then

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

		self.BobScale = math.Clamp(1-self.Inter_ADSAmount, bobADS, self.BaseBobScale)
		self.SwayScale = math.Clamp(1-self.Inter_ADSAmount, bobADS, self.BaseSwayScale)



		-- Draw crosshair if we should when not doing ADS
		if self.Inter_ADSAmount >= 0.3 then
			self.Inter_DrawCrosshair = false
		else
			self.Inter_DrawCrosshair = self.DoDrawCrosshair
		end




		if self.Inter_ADSAmount > 0 then

			-- Adjust vm position accordingly

			-- Tweak ADS pos for devs
			if CvarDeveloper:GetBool() && LocalPlayer().ZWB_AdjustMode then
				self:Inter_ADSAdjust()
			end

			local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
			local ironPos = self.IronSights.Pos*self.Inter_ADSAmount


			local ironAng = self.IronSights.Ang*self.Inter_ADSAmount
			ang:RotateAroundAxis(forward, ironAng.x)
			ang:RotateAroundAxis(right, ironAng.y)
			ang:RotateAroundAxis(up, ironAng.z)


			pos:Add( forward*ironPos.x )
			pos:Add( right*ironPos.y )
			pos:Add( up*ironPos.z )

		end
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

		self:Custom_GetViewModelPosition(pos, ang)
		self:Inter_DoADS(pos, ang)
		return pos, ang

	end


	function SWEP:CalcView( ply, pos, ang, fov, znewar, zfar )
		self:Custom_CalcView( ply, pos, ang, fov, znewar, zfar )
		return pos, ang, fov-(self.IronSights.ZoomAmount*(self.Inter_ADSAmount or 0))
	end

end


--[[
======================================================================================================================================================
                                           Other
======================================================================================================================================================
--]]


function SWEP:FireAnimationEvent( pos, ang, event, options, source )

	local returnValue = self:Custom_FireAnimationEvent(pos, ang, event, options, source)
	if returnValue != nil then
		return returnValue
	end

	if event == 22 && self.Primary.MuzzleFlash && IsFirstTimePredicted() then
		self:Inter_DefaultWorldMuzzleFlash()
	elseif CLIENT && event == 21 && self.Primary.MuzzleFlash then
		self:Inter_DefaultMuzzleFlash()
	end

end


function SWEP:Deploy()
	self:On_Deploy()
	return true
end


function SWEP:Holster()
	local returnValue = self:On_Holster()
	if returnValue != nil then
		return returnValue
	end
end