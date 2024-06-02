AddCSLuaFile()

// Custom functions that you can change


    -- Called after the swep has been created/spawned
function SWEP:Post_Initialize()
end


    -- Called when the player presses a key
function SWEP:On_KeyPress( key )
end


    -- Called when the player releases a key
function SWEP:On_KeyRelease( key )
end


    -- Called on reload
function SWEP:On_Reload()
end


    -- Your own primary attack
SWEP.Use_Custom_PrimaryAttack = false
function SWEP:Custom_PrimaryAttack()
end

    -- Your own view punch code
SWEP.Use_Custom_ViewPunch = false
function SWEP:Custom_ViewPunch()
end
