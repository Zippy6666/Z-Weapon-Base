AddCSLuaFile()

SWEP.Base = "weapon_zwb_base" -- The weapon's base script, relative to lua/weapons.
SWEP.Spawnable = true -- Whether or not this weapon can be obtained through the spawn menu.
SWEP.AdminOnly = false -- If spawnable, this variable determines whether only administrators can use the button in the spawn menu.
SWEP.PrintName = "Shotgun" -- The name of the SWEP displayed in the spawn menu.
SWEP.Author = "Zippy" -- The SWEP's author.
SWEP.Category = "Other" -- The spawn menu category that this weapon resides in.
SWEP.IsZWBWeapon = true

SWEP.Purpose = "Kill everyone."
SWEP.Instructions = "Shoot 'em up."

SWEP.WorldModel = Model( "models/weapons/w_shotgun.mdl" ) -- Relative path to the SWEP's world model.
SWEP.ViewModel = Model( "models/weapons/c_shotgun.mdl" ) -- Relative path to the SWEP's view model.
SWEP.HoldType = "shotgun" -- How to hold the weapon: https://wiki.facepunch.com/gmod/Hold_Types
SWEP.ViewModelFOV = 60 -- The field of view percieved whilst wielding this SWEP.

SWEP.Primary.Ammo = "buckshot" -- Ammo type (buckshot, SMG1, etc.) See: https://wiki.facepunch.com/gmod/Default_Ammo_Types
SWEP.Primary.ClipSize = 8 -- The maximum amount of bullets one clip can hold. Setting it to -1 means weapon uses no clips, like a grenade or a rocket 
SWEP.Primary.DefaultClip = 32 -- Default ammo in the clip, making it higher than ClipSize will give player additional ammo on spawn
SWEP.Primary.Automatic = true -- If true makes the weapon shoot automatically as long as the player has primary attack button held down
SWEP.Primary.Cooldown = 0.8 -- How long until it can fire again
SWEP.Primary.TakeAmmo = 1 -- Amount of ammo to take each shot
SWEP.Primary.Sound = "^weapons/shotgun/shotgun_fire6.wav" -- The sound to play when firing
SWEP.Primary.ViewPunch = 8 -- The amount to kick the player's screen when firing
SWEP.Primary.ReloadSound = "weapons/smg1/smg1_reload.wav"
SWEP.Primary.MuzzleLight = true -- Emit dynamic light when shooting
SWEP.Primary.MuzzleLightColor = "255 125 25" -- The color of the dynamic light when shooting
SWEP.Primary.DefaultReload = false -- Use the default weapon reload code


SWEP.Primary.Bullet = {
    Enable = true, -- Should it fire bullets? Disable to add your own code instead!
    Damage = 14, -- Bullet damage
    Force = 3, -- Bullet force on physics
    HullSize = 0, -- Bullet hull size
    Num = 8, -- Amount of bullets to fire per bang
    Tracer = 1, -- Chance for tracers, 0 = Never
    TracerName = nil, -- Tracer effect name, nil = default, more here: https://wiki.facepunch.com/gmod/Default_Effects
    HipFireSpread = 0.06, -- The base spread when not in sights
    SpreadMax = 0.3, -- Max spread when firing recklessly
    SpreadAccumulation = 0.03, -- Amount to increase spread each shot
    SpreadRecover = 0.03, -- Speed at which spread recovers when not shooting
}


--[[
======================================================================================================================================================
                                           IRON SIGHTS / ADS
======================================================================================================================================================
--]]


SWEP.IronSights = {
    Pos  = Vector(-6.544051, -8.864565, 4.672704), -- Weapon position offset when in sights
    Ang = Angle(1.501, -0.534, 0.022), -- Weapon angle offset when in sights
    Speed = 5, -- Speed at which sights are lowered/risen
    ZoomAmount = 30, -- Amount to zoom the screen when in sights
}


function SWEP:On_Initialize()
    self.NextInsertShell = CurTime()
    self.IsPumping = false
    self.JustFired = false
end


function SWEP:On_Shoot()

    -- Pump
    if SERVER then
        self:CONV_TempVar("IsPumping", true, 0.4)
        self:CONV_TimerSimple(0.2, function()
            self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
            self:EmitSound("weapons/shotgun/shotgun_cock.wav", 70, math.random(125, 130), 0.75, CHAN_AUTO)
        end)
    end

    self:CONV_TempVar("JustFired", true, 0.8)

end


function SWEP:On_Reload()

    local own = self:GetOwner()

    if !IsValid(own) then return end

    if own:IsPlayer() && self.NextInsertShell < CurTime() && self:Clip1() < self:GetMaxClip1() && !self.IsPumping && !self.JustFired && own:GetAmmoCount(self.Primary.Ammo) > 0 then

        self:SendWeaponAnim(ACT_VM_RELOAD)

        own:SetAmmo(own:GetAmmoCount(self.Primary.Ammo)-1, self.Primary.Ammo)
        self:SetClip1(self:Clip1()+1)

        self:CONV_TimerCreate("ReloadFinishAnim", 0.45, 1, function()
            self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
        end)

        self:EmitSound("weapons/shotgun/shotgun_reload2.wav", 70, math.random(90, 110), 0.75, CHAN_AUTO)
        self.NextInsertShell = CurTime()+0.4

    elseif own:IsNPC() then

        self:DefaultReload(ACT_RELOAD)

    end

end