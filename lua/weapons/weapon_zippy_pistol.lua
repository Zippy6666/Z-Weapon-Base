AddCSLuaFile()

SWEP.Base = "weapon_zwb_base" -- The weapon's base script, relative to lua/weapons.
SWEP.Spawnable = true -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.PrintName = "Pistol" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.
SWEP.Category = "Other" -- The spawn menu category that this weapon resides in.
SWEP.IsZWBWeapon = true

SWEP.Purpose = "Kill everyone."
SWEP.Instructions = "Shoot 'em up."

SWEP.WorldModel = Model( "models/weapons/w_pistol.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_pistol.mdl" ) -- Relative path to the SWEP's view model.
SWEP.HoldType = "pistol" -- How to hold the weapon: https://wiki.facepunch.com/gmod/Hold_Types
SWEP.ViewModelFOV = 50 -- The field of view percieved whilst wielding this SWEP.

SWEP.Primary.Ammo = "SMG1" -- Ammo type (Pistol, SMG1, etc.) See: https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ClipSize = 20 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket
SWEP.Primary.DefaultClip = 270 -- Default ammo in the clip, making it higher than ClipSize will give player additional ammo on spawn
SWEP.Primary.Automatic = false -- If true makes the weapon shoot automatically as long as the player has primary attack button held down
SWEP.Primary.Cooldown = 0.3 -- How long until it can fire again
SWEP.Primary.TakeAmmo = 1 -- Amount of ammo to take each shot
SWEP.Primary.Sound = "^weapons/pistol/pistol_fire3.wav" -- The sound to play when firing
SWEP.Primary.ViewPunch = 4 -- The amount to kick the player's screen when firing
SWEP.Primary.ReloadSound = "weapons/smg1/smg1_reload.wav"
SWEP.Primary.MuzzleLight = true -- Emit dynamic light when shooting
SWEP.Primary.MuzzleLightColor = Color(255, 125, 25) -- The color of the dynamic light when shooting
SWEP.Primary.DefaultReload = true -- Use the default weapon reload code


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
    Pos  = Vector(0.729172, -6.020793, 2.641391), -- Weapon position offset when in sights
    Ang = Angle(1.063, 1.362, -1.416), -- Weapon angle offset when in sights
    Speed = 30, -- Speed at which sights are lowered/risen
    ZoomAmount = 10, -- Amount to zoom the screen when in sights
}