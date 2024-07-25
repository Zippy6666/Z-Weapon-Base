AddCSLuaFile()
include("sh_internal.lua")
include("sh_callable.lua")
include("sh_changeable.lua")

// Here you can see the available variables

--[[
======================================================================================================================================================
                                           BASICS
======================================================================================================================================================
--]]


SWEP.Base = "weapon_base" -- SET TO "weapon_zwb_base"!
SWEP.IsZWBWeapon = true -- KEEP THIS!


SWEP.Spawnable = true -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.PrintName = "SMG" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.
SWEP.Category = "Other" -- The spawn menu category that this weapon resides in.
SWEP.Purpose = "Kill everyone."
SWEP.Instructions = "Shoot 'em up."


SWEP.WorldModel = Model( "models/weapons/w_smg1.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_smg1.mdl" ) -- Relative path to the SWEP's view model.
SWEP.HoldType = "smg" -- How to hold the weapon: https://wiki.facepunch.com/gmod/Hold_Types


SWEP.AutoSwitchFrom = true -- Whether this weapon can be autoswitched away from when the player runs out of ammo in this weapon or picks up another weapon or ammo
SWEP.AutoSwitchTo = true -- Whether this weapon can be autoswitched to when the player runs out of ammo in their current weapon or they pick this weapon up


-- Determines the priority of the weapon when autoswitching.
-- The weapon being autoswitched from will attempt to switch to a weapon with the same weight that has ammo,
-- but if none exists, it will prioritise higher weight weapons.
SWEP.Weight = 5


SWEP.Slot = 2 -- Slot in the weapon selection menu, starts with 0
SWEP.SlotPos = 1 -- Position in the slot, should be in the range 0-128


SWEP.m_bPlayPickupSound = true -- If set to false, the weapon will not play the weapon pick up sound when picked up.

--[[
======================================================================================================================================================
                                           VIEW MODEL
======================================================================================================================================================
--]]


SWEP.ViewModelFlip = false -- Used primarily for Counter Strike: Source view models, this variable is used to flip them back to normal.
SWEP.ViewModelFOV = 60 -- The field of view percieved whilst wielding this SWEP.
SWEP.m_WeaponDeploySpeed = 1 -- The deploy speed multiplier. This does not change the internal deployment speed.

SWEP.BaseBobScale = 1 -- The scale of the viewmodel bob (viewmodel movement from left to right when walking around)
SWEP.BaseSwayScale = 1 -- The scale of the viewmodel sway (viewmodel position lerp when looking around).


-- Makes the player models hands bonemerged onto the view model
-- The gamemode and view models must support this feature for it to work!
SWEP.UseHands = true


--[[
======================================================================================================================================================
                                        HUD / CROSSHAIR
======================================================================================================================================================
--]]


SWEP.BounceWeaponIcon = true -- Should the weapon icon bounce in weapon selection?
SWEP.DrawAmmo = true -- Should we draw the default HL2 ammo counter?
SWEP.DoDrawCrosshair = true -- Should we draw the default crosshair?


--[[
======================================================================================================================================================
                                           PRIMARY FIRE
======================================================================================================================================================
--]]

SWEP.Primary.Ammo = "SMG1" -- Ammo type (Pistol, SMG1, etc.) See: https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ClipSize = 45 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket
SWEP.Primary.DefaultClip = 270 -- Default ammo in the clip, making it higher than ClipSize will give player additional ammo on spawn
SWEP.Primary.Automatic = true -- If true makes the weapon shoot automatically as long as the player has primary attack button held down
SWEP.Primary.Cooldown = 0.1 -- How long until it can fire again
SWEP.Primary.TakeAmmo = 1 -- Amount of ammo to take each shot
SWEP.Primary.Sound = "^weapons/smg1/npc_smg1_fire1.wav" -- The sound to play when firing
SWEP.Primary.ViewPunch = 2 -- The amount to kick the player's screen when firing
SWEP.Primary.ReloadSound = "weapons/smg1/smg1_reload.wav"
SWEP.Primary.MuzzleLight = true -- Emit dynamic light when shooting
SWEP.Primary.MuzzleLightColor = Color(255, 125, 25) -- The color of the dynamic light when shooting
SWEP.Primary.DefaultReload = true -- Use the default weapon reload code
SWEP.Primary.MuzzleFlash = true -- Should it have a muzzle flash? Set to false to disable. Set to "big" for a bigger muzzleflash.


SWEP.Primary.Bullet = {
    Enable = true, -- Should it fire bullets? Disable to add your own code instead!
    Damage = 10, -- Bullet damage
    Force = 1, -- Bullet force on physics
    HullSize = 0, -- Bullet hull size
    Num = 1, -- Amount of bullets to fire per bang
    Tracer = 1, -- Chance for tracers, 0 = Never
    TracerName = nil, -- Tracer effect name, nil = default, more here: https://wiki.facepunch.com/gmod/Default_Effects
    HipFireSpread = 0.06, -- The base spread when not in sights
    SpreadMax = 0.3, -- Max spread when firing recklessly
    SpreadAccumulation = 0.01, -- Amount to increase spread each shot
    SpreadRecover = 0.03, -- Speed at which spread recovers when not shooting
}

--[[
======================================================================================================================================================
                                           IRON SIGHTS / ADS
======================================================================================================================================================
--]]

SWEP.IronSights = {
    Pos  = Vector(-5.905377, -6.434172, 1.019111), -- Weapon position offset when in sights
    Ang = Angle(0, 0, 0), -- Weapon angle offset when in sights
    Speed = 15, -- Speed at which sights are lowered/risen
    ZoomAmount = 20, -- Amount to zoom the screen when in sights
}