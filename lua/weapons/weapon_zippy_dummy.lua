AddCSLuaFile()


--[[
======================================================================================================================================================
                                           VARIABLES: BASICS
======================================================================================================================================================
--]]


SWEP.Base = "weapon_zwb_base" -- The weapon's base script, relative to lua/weapons.
SWEP.PrintName = "Dummy" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.
SWEP.Category = "Other" -- The spawn menu category that this weapon resides in.

SWEP.Spawnable = true -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.

SWEP.WorldModel = Model( "models/weapons/w_shotgun.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_shotgun.mdl" ) -- Relative path to the SWEP's view model.


SWEP.Primary.Ammo = "Shotgun" -- Ammo type (Pistol, SMG1, etc.) See: https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ClipSize = 100 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket 
SWEP.Primary.DefaultClip = 100 -- Default ammo in the clip, making it higher than ClipSize will give player additional ammo on spawn
SWEP.Primary.Automatic = false -- If true makes the weapon shoot automatically as long as the player has primary attack button held down
SWEP.Primary.Cooldown = 0.3 -- How long until it can fire again
SWEP.Primary.TakeAmmo = 1 -- Amount of ammo to take each shot
SWEP.Primary.Sound = "^weapons/shotgun/shotgun_dbl_fire.wav" -- The sound to play when firing
SWEP.Primary.ViewPunch = 20 -- The amount to kick the player's screen when firing
SWEP.Primary.ReloadSound = "weapons/smg1/smg1_reload.wav"

SWEP.Primary.Bullet = {} -- Don't touch
SWEP.Primary.Bullet.Damage = 60 -- Bullet damage
SWEP.Primary.Bullet.Force = 10 -- Bullet force on physics
SWEP.Primary.Bullet.HullSize = 0 -- Bullet hull size
SWEP.Primary.Bullet.Num = 1 -- Amount of bullets to fire per bang
SWEP.Primary.Bullet.Tracer = 0 -- Chance for tracers, 0 = Never
SWEP.Primary.Bullet.TracerName = nil -- Tracer effect name, nil = default, more here: https://wiki.facepunch.com/gmod/Default_Effects

SWEP.Primary.Bullet.Spread = 0.005 -- Base bullet spread
SWEP.Primary.Bullet.SpreadAccumulation = 0.1 -- Amount to increase spread each shot
SWEP.Primary.Bullet.SpreadRecover = 0.1 -- Speed at which spread recovers when not shooting
SWEP.Primary.Bullet.SpreadRecoverDelay = 0.3 -- Time in seconds until spread starts to recover

SWEP.IronSights = {} -- Don't touch
SWEP.IronSights.Pos  = Vector(-4.688324, -8.973290, 4.042560) -- Weapon position offset when in sights
