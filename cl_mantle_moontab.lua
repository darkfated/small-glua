--[[
    * MoonTab *
    GitHub: https://github.com/darkfated/small-glua/blob/master/cl_mantle_moontab.lua
    Author's discord: darkfated
]]

local table_ranks = {
    ['superadmin'] = {'Создатель', 'icon16/tux.png'},
    ['user'] = {'Игрок', 'icon16/user.png'},
}

local table_hours = {
    {0, 'icon16/status_offline.png', 'Старт с нуля, финиш на вершине'},
    {100, 'icon16/scratchnumber.png', 'Усердно работаю над собой'},
    {500, 'icon16/world.png', 'Вертуоз в своём деле'},
    {1000, 'icon16/rosette.png', 'Финальный босс побеждён'}
}

local function Create()
    MoonTab = vgui.Create('DFrame')
    Mantle.ui.frame(MoonTab, 'Количество игроков: ' .. #player.GetAll() .. ' из ' .. game.MaxPlayers(), Mantle.func.w(1200), Mantle.func.h(600), false)
    MoonTab:Center()
    MoonTab:MakePopup()
    MoonTab:SetKeyBoardInputEnabled(false)

    MoonTab.title = vgui.Create('DButton', MoonTab)
    MoonTab.title:SetSize(MoonTab:GetWide() * 0.5, 24)
    MoonTab.title:SetPos(MoonTab:GetWide() * 0.25, 0)
    MoonTab.title:SetText('')

    local title_text = 'Mantle MoonTab'
    local mat_title = Material('icon16/page_white_copy.png')

    MoonTab.title.Paint = function(_, w, h)
        draw.SimpleText(title_text, 'Fated.24', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_title)
        surface.DrawTexturedRect(w * 0.5 + surface.GetTextSize(title_text) * 0.5 + 4, 4, 16, 16)
    end
    MoonTab.title.DoClick = function()
        chat.AddText(color_white, 'Айпи сервера скопирован!')
        chat.PlaySound()

        SetClipboardText(game.GetIPAddress())
    end

	local sort_table_job = {}

	for _, cat_job_table in pairs(DarkRP.getCategories().jobs) do
		sort_table_job[cat_job_table.name] = {}
	end

	for v, pl in pairs(player.GetAll()) do
		local job_table = pl:getJobTable()

		if !sort_table_job[job_table.category][job_table.name] then
			sort_table_job[job_table.category][job_table.name] = {}
		end

		table.insert(sort_table_job[job_table.category][job_table.name], pl)
	end

    MoonTab.sp = vgui.Create('DScrollPanel', MoonTab)
    Mantle.ui.sp(MoonTab.sp)
    MoonTab.sp:Dock(FILL)
    MoonTab.sp:DockMargin(4, 4, 4, 4)
    

    local grid_players = vgui.Create('DGrid', MoonTab.sp)
    grid_players:Dock(TOP)
    grid_players:DockMargin(8, 8, 0, 8)
    grid_players:SetCols(7)
    
    local panel_size = (MoonTab:GetWide() - 32) / 7
    
    grid_players:SetColWide(panel_size)
    grid_players:SetRowHeight(panel_size)

    for job_cat, pl_table in pairs(sort_table_job) do
        for job_name, job_players in pairs(pl_table) do
            for pl_k, pl in pairs(job_players) do 
                local ply_btn = vgui.Create('DButton', grid_players)
                ply_btn:SetSize(panel_size - 8, panel_size - 8)
                ply_btn:SetText('')
                
                local icon_color = Color(190, 190, 190)
                local ply_time = math.random(200, 1200) -- Здесь написать meta системы измерения часов у игрока
                local ply_time_data

                for _, data_hour in pairs(table_hours) do
                    if ply_time >= data_hour[1] then
                        ply_time_data = data_hour
                    end
                end

                local ply_time_icon = Material(ply_time_data[2])

                ply_btn.Paint = function(self, w, h)
                    if !IsValid(pl) then
                        ply_btn:Remove()
                        
                        return
                    end

                    local job_table = pl:getJobTable()

                    draw.RoundedBox(8, 0, 0, w, h, Mantle.color.panel[2])
                    draw.RoundedBoxEx(8, 0, 0, w, h * 0.4 - 16, job_table.color, true, true, false, false)
                    draw.RoundedBox(8, w * 0.25 - 8, h * 0.25 - 8, w * 0.5 + 16, h * 0.5 + 16, Mantle.color.panel[2])
                    draw.RoundedBoxEx(8, 0, h * 0.4 - 16, h * 0.25 - 8, 16, job_table.color, false, false, false, true)
                    draw.RoundedBoxEx(8, h * 0.75 + 8, h * 0.4 - 16, h * 0.25 - 8, 16, job_table.color, false, false, true, false)

                    local name = pl:Name()
                    local len_name = string.len(name)

                    draw.SimpleText(name, len_name > 18 and 'Fated.17' or len_name > 20 and 'Fated.15' or 'Fated.18', w * 0.5, h * 0.1 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(job_table.name or 'Загрузка...', 'Fated.15', w * 0.5, h * 0.815 - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    draw.SimpleText(ply_time .. ' ч.', 'Fated.15', w * 0.05 + 16, h * 0.9 + 2, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local function PlayerClick()
                    local DM = Mantle.ui.derma_menu()
                    DM:AddOption('Скопировать SteamID', function()
                        SetClipboardText(pl:SteamID())
                    end, 'icon16/disk.png')
                    DM:AddOption('Открыть профиль', function()
                        gui.OpenURL('https://steamcommunity.com/profiles/' .. pl:SteamID64())
                    end, 'icon16/layout_content.png')
                end

                ply_btn.DoClick = function()
                    PlayerClick()
                end

                ply_btn.icon_time = vgui.Create('DButton', ply_btn)
                ply_btn.icon_time:SetSize(16, 16)
                ply_btn.icon_time:SetPos(ply_btn:GetWide() * 0.25 - 35, ply_btn:GetTall() * 0.9 - 5)
                ply_btn.icon_time:SetText('')
                ply_btn.icon_time:SetTooltip(ply_time_data[3])
                ply_btn.icon_time.Paint = function(self, w, h)
                    surface.SetDrawColor(icon_color)
                    surface.SetMaterial(ply_time_icon)
                    surface.DrawTexturedRect(0, 0, w, h)
                end

                ply_btn.avatar = vgui.Create('AvatarImage', ply_btn)
                ply_btn.avatar:SetSize(ply_btn:GetWide() * 0.5, ply_btn:GetWide() * 0.5)
                ply_btn.avatar:Center()
                ply_btn.avatar:SetSteamID(pl:SteamID64(), 128)

                ply_btn.avatar.btn = vgui.Create('DButton', ply_btn.avatar)
                ply_btn.avatar.btn:Dock(FILL)
                ply_btn.avatar.btn:SetText('')

                local color_shadow = Color(0, 0, 0, 100)

                ply_btn.avatar.btn.Paint = function(self, w, h)
                    if self:IsHovered() or ply_btn:IsHovered() or ply_btn.rank:IsHovered() or ply_btn.icon_time:IsHovered() then
                        draw.RoundedBox(4, 0, 0, w, h, color_shadow)
                    end
                end
                ply_btn.avatar.btn.DoClick = function()
                    PlayerClick()
                end

                ply_btn.rank = vgui.Create('DButton', ply_btn)
                ply_btn.rank:SetSize(16, 16)
                ply_btn.rank:SetPos(ply_btn:GetWide() * 0.75 + 18, ply_btn:GetTall() * 0.9 - 5)
                ply_btn.rank:SetText('')
                
                local rank_table = table_ranks[pl:GetUserGroup()]
                local rank_icon = Material(rank_table[2])
                
                ply_btn.rank:SetTooltip(rank_table[1])
                ply_btn.rank.Paint = function(self, w, h)
                    surface.SetDrawColor(icon_color)
                    surface.SetMaterial(rank_icon)
                    surface.DrawTexturedRect(0, 0, w, h)
                end

                grid_players:AddItem(ply_btn)
            end
        end
    end

    MoonTab.sp:GetVBar():AnimateTo(IsValid(MoonTabScrollPos) and MoonTabScrollPos or 0, 0.01, 0)
end

hook.Add('ScoreboardShow', 'Mantle.MoonTab', function()
    Create()

    return false
end)

hook.Add('ScoreboardHide', 'Mantle.MoonTab', function()
    if IsValid(MoonTab) then
        MoonTabScrollPos = MoonTab.sp:GetVBar():GetScroll()

        MoonTab:Remove()
    end

    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:Remove()
    end

    return false
end)
