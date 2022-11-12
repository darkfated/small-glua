-- Required for work: https://github.com/darkfated/FatedUI

local color_white = Color(255,255,255)

local function FatedStartMenuOpen()
	local menu = vgui.Create('EditablePanel')
	menu:SetSize(ScrW(), ScrH())
	menu:MakePopup()

	FatedUI.func.DownloadMat('https://i.imgur.com/GO5thYc.jpeg', 'startmenu_background.png', function(img)
		menu.Paint = function(_, w, h)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(img)
			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText('Welcome to the server!', 'fu.50', menu:GetWide() * 0.5, FatedUI.func.h(80), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end)
	
	local close_btn = vgui.Create('DButton', menu)
	close_btn:SetSize(64, 64)
	close_btn:SetPos(menu:GetWide() - close_btn:GetWide() - FatedUI.func.w(16), FatedUI.func.w(16))
	close_btn.DoClick = function()
		menu:Remove()

		FatedUI.func.Sound()
	end
	close_btn:SetText('')

	FatedUI.func.DownloadMat('https://i.imgur.com/TbZbOIe.png', 'startmenu_close.png', function(img)
		close_btn.Paint = function(_, w, h)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(img)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end)

	local left_panel = vgui.Create('fu-panel', menu)
	left_panel:SetSize(menu:GetWide() * 0.5 - FatedUI.func.w(110), menu:GetTall() - FatedUI.func.h(240))
	left_panel:SetPos(FatedUI.func.w(80), FatedUI.func.h(160))
	left_panel:Radius(45)

	local online_text = #player.GetAll() .. '/' .. game.MaxPlayers() .. ' players'

	left_panel.PaintOver = function(_, w, h)
		draw.SimpleText('Current online', 'fu.40', w * 0.5, h * 0.5 - FatedUI.func.h(25), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(online_text, 'fu.35', w * 0.5, h * 0.5 + FatedUI.func.h(25), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local right_panel = vgui.Create('fu-panel', menu)
	right_panel:SetSize(menu:GetWide() * 0.5 - FatedUI.func.w(110), menu:GetTall() - FatedUI.func.h(240))
	right_panel:SetPos(left_panel:GetWide() + FatedUI.func.w(130), FatedUI.func.h(160))
	right_panel:Radius(45)
	right_panel.PaintOver = function(_, w, h)
		draw.SimpleText(GetHostName(), 'fu.40', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

hook.Add('InitPostEntity', 'FatedStartMenu', FatedStartMenuOpen)

// Console command to open

concommand.Add('fated_startmenu', FatedStartMenuOpen)
