-- Radical optimization with degradation: https://steamcommunity.com/sharedfiles/filedetails/?id=2140391568

CreateClientConVar( 'fopt_focus', 0, true )
CreateClientConVar( 'fopt_dist', 1500, true )

hook.Add( 'PreRender', 'fopt', function()
	if ( GetConVar( 'fopt_focus' ):GetBool() ) then
		return
	end

	if ( !system.HasFocus() ) then
		return true
	end
end )

local function checkDist( ply )
	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() ) then return end
	if ( !ply:Alive() ) then return end

	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )

	return dist > GetConVar( 'fopt_dist' ):GetInt()
end

local hooks_list = {
	'PrePlayerDraw',
	'PlayerFootstep',
}

for k, Hook in pairs( hooks_list ) do
	hook.Add( Hook, 'fopt', function( ply )
		if ( checkDist( ply ) ) then
			return true
		end
	end )
end

// Custom menu settings

hook.Add( 'PopulateToolMenu', 'fopt_tool', function()
	spawnmenu.AddToolMenuOption( 'Utilities', 'User', 'fopt', 'fOptimization', '', '', function( panel )
		panel:AddControl( 'CheckBox', { Label = 'Game rendering activity out of focus', Command = 'fopt_focus' } )
		panel:AddControl( 'Slider', { Label = 'The limit of the action of player events', Type = 'Integer', Command = 'fopt_dist', Min = '300', Max = '4000' } )
	end )
end )
