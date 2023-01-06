local fated_paint_tool = CreateClientConVar('fated_paint_tool', 1, true)
local fated_paint_color_paint = CreateClientConVar('fated_paint_color_paint', 1, true)
local fated_paint_pixl_size = CreateClientConVar('fated_paint_pixl_size', 24, true)
local fated_paint_pixl_wide = CreateClientConVar('fated_paint_pixl_wide', 30, true)
local fated_paint_pixl_tall = CreateClientConVar('fated_paint_pixl_tall', 20, true)
local color_pixl = Color(165,165,165)
local colors_paint_table = {
	{
		'Белый',
		Color(255,255,255),
	},
	{
		'Красный',
		Color(223,37,37),
	},
	{
		'Синий',
		Color(46,79,224),
	},
	{
		'Чёрный',
		Color(0,0,0),
	},
	{
		'Зелёный',
		Color(30,211,30),
	},
}
local color_background = Color(75,75,75)
local color_header = Color(36,36,36)

surface.CreateFont('FatedPaint.Header', {
	font = 'Roboto Regular',
	size = 22,
	weight = 300,
	extended = true,
})

local function OpenFatedPaintMenu()
	if IsValid(fated_paint_menu) then
		fated_paint_menu:Remove()
	end

	local pixl_size = fated_paint_pixl_size:GetInt()
	local pixl_wide, pixl_tall = fated_paint_pixl_wide:GetInt(), fated_paint_pixl_tall:GetInt()
	local PaintData = {}

	fated_paint_menu = vgui.Create('EditablePanel')
	fated_paint_menu:SetSize(pixl_size * pixl_wide + 12, pixl_size * pixl_tall + 82)
	fated_paint_menu:Center()
	fated_paint_menu:MakePopup()
	fated_paint_menu:DockPadding(6, 46, 6, 6)
	fated_paint_menu.Paint = function(_, w, h)
		draw.RoundedBox(6, 0, 0, w, h, color_background)
		draw.RoundedBoxEx(6, 0, 0, w, 40, color_header, true, true, false, false)

		draw.SimpleText('Fated Paint', 'FatedPaint.Header', w * 0.5, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local close_btn = vgui.Create('DButton', fated_paint_menu)
	close_btn:SetSize(32, 32)
	close_btn:SetPos(fated_paint_menu:GetWide() - close_btn:GetWide() - 4, 4)
	close_btn.DoClick = function()
		fated_paint_menu:Remove()
	end
	close_btn:SetText('')

	local menuBar = vgui.Create('DMenuBar', fated_paint_menu)
	menuBar:Dock(TOP)
	menuBar:DockMargin(0, 0, 0, 6)

	local option_brush = menuBar:AddMenu('Кисть')
	option_brush:AddCVar('Выбрать', 'fated_paint_tool', 1):SetIcon('icon16/accept.png')

	local option_brush_color, parent_option_brush_color = option_brush:AddSubMenu('Цвет')
	option_brush_color:SetDeleteSelf( false )
	parent_option_brush_color:SetIcon('icon16/color_wheel.png')

	for id, tabl in pairs(colors_paint_table) do
		option_brush_color:AddCVar(tabl[1], 'fated_paint_color_paint', id)
	end

	local option_clear = menuBar:AddMenu('Стёрка')
	option_clear:AddCVar('Выбрать', 'fated_paint_tool', 2):SetIcon('icon16/accept.png')

	local option_field = menuBar:AddMenu('Поле')
	option_field:AddOption('Закрасить всё в выбранный цвет', function()
		local p = 1

		for x = 1, pixl_wide do
			for y = 1, pixl_tall do
				PaintData[p] = colors_paint_table[fated_paint_color_paint:GetInt()][2]

				p = p + 1
			end
		end
	end)
	option_field:AddOption('Очистить поле', function()
		local p = 1

		for x = 1, pixl_wide do
			for y = 1, pixl_tall do
				PaintData[p] = nil

				p = p + 1
			end
		end
	end)
	option_field:AddOption('Скопировать базу-данных рисунка', function()
		SetClipboardText(util.TableToJSON(PaintData))
	end)
	option_field:AddOption('Вставить базу-данных рисунка', function()
		Derma_StringRequest('Вставить базу-данных рисунка', 'Содержимое?', '', function(s)
			local tabl = util.JSONToTable(s)
			
			if istable(tabl) then
				PaintData = util.JSONToTable(s)
			end
		end)
	end)

	local FieldProperties = vgui.Create('DProperties', option_field)
	FieldProperties:SetTall(120)
	FieldProperties:DockMargin(2, 2, 2, 2)

	local FieldProperties_pixl_size = FieldProperties:CreateRow('Параметры', 'Размер пикселя')
	FieldProperties_pixl_size:Setup('Int', {min = 12, max = 32})
	FieldProperties_pixl_size:SetValue(fated_paint_pixl_size:GetInt())
	FieldProperties_pixl_size.DataChanged = function(_, val)
		RunConsoleCommand('fated_paint_pixl_size', val)
	end

	local FieldProperties_pixl_wide = FieldProperties:CreateRow('Параметры', 'Ширина пикселей')
	FieldProperties_pixl_wide:Setup('Int', {min = 10, max = 40})
	FieldProperties_pixl_wide:SetValue(fated_paint_pixl_wide:GetInt())
	FieldProperties_pixl_wide.DataChanged = function(_, val)
		RunConsoleCommand('fated_paint_pixl_wide', val)
	end

	local FieldProperties_pixl_tall = FieldProperties:CreateRow('Параметры', 'Длинна пикселей')
	FieldProperties_pixl_tall:Setup('Int', {min = 10, max = 40})
	FieldProperties_pixl_tall:SetValue(fated_paint_pixl_tall:GetInt())
	FieldProperties_pixl_tall.DataChanged = function(_, val)
		RunConsoleCommand('fated_paint_pixl_tall', val)
	end

	option_field:AddPanel(FieldProperties)

	local sp = vgui.Create('DScrollPanel', fated_paint_menu)
	sp:Dock(FILL)

	local panel = vgui.Create('DPanel', sp)
	panel:SetSize(pixl_size * pixl_wide, pixl_size * pixl_tall)
	panel:Dock(TOP)
	panel.Paint = nil

	local pixl_place = 1

	for y = 1, pixl_tall do
		for x = 1, pixl_wide do
			local pixl_btn = vgui.Create('DButton', panel)
			pixl_btn:SetSize(pixl_size, pixl_size)
			pixl_btn:SetPos(pixl_size * (x - 1), pixl_size * (y - 1))
			pixl_btn:SetText('')
			pixl_btn.Paint = function(self, w, h)
				local i = PaintData[pixl_btn.place] and 0 or 2
				
				draw.RoundedBox(i, i, i, w - i * 2, h - i * 2, PaintData[pixl_btn.place] and PaintData[pixl_btn.place] or color_pixl)

				if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
					local mode = fated_paint_tool:GetInt()

					if mode == 2 then
						PaintData[pixl_btn.place] = nil
					elseif mode == 1 then
						PaintData[pixl_btn.place] = colors_paint_table[fated_paint_color_paint:GetInt()][2]
					end
				end
			end
			pixl_btn.place = pixl_place

			pixl_place = pixl_place + 1
		end
	end
end

concommand.Add('fated_paint', OpenFatedPaintMenu)
