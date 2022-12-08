local FatedContext_config = {
	{
		title = 'First category',
		content = {
			{
				name = 'Say hello',
				func = function()
					RunConsoleCommand('say', 'Hello')
				end,
				icon = 'icon16/book_open.png',
			}
		},
	},
	{
		title = 'Other',
		content = {
			{
				name = 'Stop all sounds',
				func = function()
					RunConsoleCommand('stopsound')
				end,
				icon = 'icon16/sound_delete.png',
			},
			{
				name = 'Die',
				func = function()
					RunConsoleCommand('kill')
				end,
				icon = 'icon16/exclamation.png',
			},
		},
	},
}

surface.CreateFont('FatedContext.category', {
	font = 'Roboto Regular',
	size = 22,
	weight = 300,
	extended = true,
})

surface.CreateFont('FatedContext.action', {
	font = 'Roboto Regular',
	size = 23,
	weight = 300,
	extended = true,
})

local color_white = Color(255,255,255)
local color_black = Color(0,0,0)
local color_background = Color(56,56,56)
local color_background_panel = Color(31,31,31)
local color_btn = Color(78,78,78)
local color_btn_hover = Color(150,150,150)
local color_vbar = Color(63,66,102)

local function CreateFatedContext()
	Fated_context = vgui.Create('DFrame')
	Fated_context:SetSize(370, ScrH() * 0.5)
	Fated_context:SetPos(25, 0)
	Fated_context:CenterVertical()
	Fated_context:MakePopup()
	Fated_context:SetTitle('')
	Fated_context:ShowCloseButton(false)
	Fated_context:DockPadding(0, 0, 0, 0)
	Fated_context.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_background)
	end
	Fated_context:SetSizable(true)
	Fated_context:SetMinHeight(300)
	Fated_context:SetMinWidth(370)

	Fated_context.panel = vgui.Create('DPanel', Fated_context)
	Fated_context.panel:Dock(FILL)
	Fated_context.panel:DockMargin(6, 6, 6, 6)
	Fated_context.panel.Paint = function(_, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_background_panel)
	end

	Fated_context.panel.sp = vgui.Create('DScrollPanel', Fated_context.panel)
	Fated_context.panel.sp:Dock(FILL)
	Fated_context.panel.sp:DockMargin(6, 6, 6, 6)
	
	local vbar = Fated_context.panel.sp:GetVBar()
	vbar:SetWide(18)
	vbar.Paint = nil
	vbar.btnDown.Paint = nil
	vbar.btnUp.Paint = nil
	vbar.btnGrip.Paint = function(_, w, h)
		draw.RoundedBox(6, 6, 0, w - 6, h, color_vbar)
	end

	for catID = 1, #FatedContext_config do
		local cat = FatedContext_config[catID]

		local cat_name = vgui.Create('DPanel', Fated_context.panel.sp)
		cat_name:Dock(TOP)
		cat_name:DockMargin(0, 0, 0, 6)
		cat_name:SetTall(30)
		cat_name.Paint = function(_, w, h)
			draw.SimpleText(cat.title, 'FatedContext.category', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local cmds_count = #cat.content

		for cmdID = 1, cmds_count do
			local cmd = cat.content[cmdID]

			local cmd_btn = vgui.Create('DButton', Fated_context.panel.sp)
			cmd_btn:Dock(TOP)
			cmd_btn:DockMargin(0, 0, 0, 6)
			cmd_btn:SetTall(36)
			cmd_btn:SetText('')

			local cmd_mat = Material(cmd.icon)

			cmd_btn.Paint = function(self, w, h)
				draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and color_btn_hover or color_btn)

				draw.SimpleText(cmd.name, 'FatedContext.action', w * 0.5, h * 0.5, self:IsHovered() and color_black or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				surface.SetDrawColor(color_white)
				surface.SetMaterial(cmd_mat)
				surface.DrawTexturedRect(10, 10, 16, 16)
			end
			cmd_btn.DoClick = function()
				cmd.func()
			end
		end
	end
end

hook.Add('OnContextMenuOpen', 'FatedContextOpen', function()
	if IsValid(Fated_context) then
		Fated_context:SetVisible(true)
	else
		CreateFatedContext()
	end
end)

hook.Add('OnContextMenuClose', 'FatedContextClose', function()
	Fated_context:SetVisible(false)
end)
