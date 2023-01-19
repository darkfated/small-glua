-- Radical optimization with degradation: https://steamcommunity.com/sharedfiles/filedetails/?id=2140391568

local fopt_focus = CreateClientConVar('fopt_focus', 0, true)
local fopt_dist = CreateClientConVar('fopt_dist', 1500, true)

hook.Add('PreRender', 'fopt', function()
	if fopt_focus:GetBool() then
		return
	end

	if !system.HasFocus() then
		return true
	end
end)

local function checkDist(ply)
	if !IsValid(ply) then return end
	if ply == LocalPlayer() then return end
	if !ply:Alive() then return end

	local dist = LocalPlayer():GetPos():Distance(ply:GetPos())

	return dist > fopt_dist:GetInt()
end

local hooks_list = {
	'PrePlayerDraw',
	'PlayerFootstep',
}

for hookID = 1, #hooks_list do
	hook.Add(hooks_list[hookID], 'fopt', function(ply)
		if checkDist(ply) then
			return true
		end
	end)
end

// Custom menu settings

hook.Add('PopulateToolMenu', 'fopt_tool', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'fopt', 'fOptimization', '', '', function(panel)
		panel:AddControl('CheckBox', {Label = 'Game rendering activity out of focus', Command = 'fopt_focus'})
		panel:AddControl('Slider', {Label = 'The limit of the action of player events', Type = 'Integer', Command = 'fopt_dist', Min = '300', Max = '4000'})
	end)
end)
