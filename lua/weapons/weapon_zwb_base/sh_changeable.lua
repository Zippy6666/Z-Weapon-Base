AddCSLuaFile()

// Custom functions that you can change


--[[
======================================================================================================================================================
                                          INITIALIZE + THINK
======================================================================================================================================================
--]]


    -- Called after the SWEP has been created/spawned
function SWEP:On_Initialize()
end

    -- Called when the SWEP thinks
function SWEP:On_Think()
end

    -- Set your networked variables here
function SWEP:On_SetupDataTables()
end

--[[
======================================================================================================================================================
                                           DEPLOY / HOLSTER
======================================================================================================================================================
--]]


    -- Called when player has just switched to this weapon
function SWEP:On_Deploy()
end


    -- Called when weapon tries to holster
    -- Return true to allow weapon to holster. 
function SWEP:On_Holster()
    return true
end


--[[
======================================================================================================================================================
                                           PRIMARY / FIRING / RELOADING
======================================================================================================================================================
--]]


    -- Called when the SWEP does a primary attack
function SWEP:On_Shoot()
end


    -- Called before the swep shoots, return true to prevent
function SWEP:Before_Shoot()
    return false
end


    -- Called before the swep uses its secondary, return true to use this instead of ironsights
    -- Ensure SWEP.IronSights.Enabled is false if you want to use this function
function SWEP:Before_Shoot_Secondary()
    return false
end


    -- Called on reload
function SWEP:On_Reload()
end


--[[
======================================================================================================================================================
                                           OTHER EVENTS
======================================================================================================================================================
--]]


    -- Called when the player presses a key
function SWEP:On_KeyPress( key )
end


    -- Called when the player releases a key
function SWEP:On_KeyRelease( key )
end


    -- Called before firing animation events, such as muzzle flashes or shell ejections.
    -- This will only be called serverside for 3000-range events, and clientside for 5000-range and other events.
    -- 'pos' = Position of the effect.
    -- 'ang' = Angle of the effect.
    -- 'event' = The event ID of happened even. See this page: https://developer.valvesoftware.com/wiki/Animation_Events
    -- 'options' = Name or options of the event.
    -- 'source' The source entity. This will be a viewmodel on the client and the weapon itself on the server
    -- Return true to disable the effect.
function SWEP:Custom_FireAnimationEvent(pos, ang, event, options, source)
end

--[[
======================================================================================================================================================
                                           VIEW / VIEWMODEL
======================================================================================================================================================
--]]


if CLIENT then


        -- Alter the player's viewmodel position
	function SWEP:Custom_GetViewModelPosition(pos, ang)
	end


        -- Alter the player's view
	function SWEP:Custom_CalcView( ply, pos, ang, fov, znewar, zfar )
	end


end