local colors = {
    Color(75,75,75),
    Color(25,25,25),
    Color(255,255,255),
    Color(70,70,70),
    Color(160,160,160)
}

local Game_List = {
    {
        name = 'Snake',
        url = 'https://www.google.ru/fbx?fbx=snake_arcade'
    },
    {
        name = 'Solitaire',
        url = 'https://www.google.ru/logos/fnbx/solitaire/standalone.html'
    },
    {
        name = 'Pac-Man',
        url = 'https://www.google.ru/logos/2010/pacman10-i.html'
    }
}

local function drawPanel( self, col1, col2 )
    self.Paint = function( self, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, col2 )
        draw.RoundedBox( 6, 1, 1, w - 2, h - 2, col1 )
    end
end

local function OpenMen()
    menu_GAME = vgui.Create( 'DFrame' )
    menu_GAME:SetSize( 610, 658 )
    menu_GAME:Center()
    menu_GAME:MakePopup()
    menu_GAME:SetTitle( 'Games' )
    menu_GAME:ShowCloseButton( false )
    menu_GAME:DockPadding( 4, 24, 4, 4 )

    drawPanel( menu_GAME, colors[ 1 ], colors[ 2 ] )

    local close_button = vgui.Create( 'DButton', menu_GAME )
    close_button:SetSize( 12, 12 )
    close_button:SetPos( menu_GAME:GetWide() - 6 - close_button:GetWide(), 6 )
    close_button:SetText( '' )
    close_button.DoClick = function()
        menu_GAME:SetVisible( false )
    end
    close_button.Paint = function( self, w, h )
        surface.SetDrawColor( colors[ 3 ] )
        surface.DrawLine( 0, 0, w, h )
        surface.DrawLine( w, 0, 0, h )
    end

    local sp = vgui.Create( 'DScrollPanel', menu_GAME )
    sp:Dock( FILL )
    sp:DockMargin( 0, -4, 0, 0 )

    for k, elem in pairs( Game_List ) do
        local btn = vgui.Create( 'DButton', sp )
        btn:Dock( TOP )
        btn:DockMargin( 0, 4, 0, 0 )
        btn:SetTall( 40 )
        btn:SetText( elem.name )
        btn.DoClick = function()
            sp:SetVisible( false )

            menu_GAME:SetTitle( elem.name )

            local pan = vgui.Create( 'DPanel', menu_GAME )
            pan:Dock( FILL )
            pan.Paint = nil

            local ReturnBtn = vgui.Create( 'DButton', pan )
            ReturnBtn:Dock( BOTTOM )
            ReturnBtn:SetTall( 20 )
            ReturnBtn.DoClick = function()
                pan:Remove()

                sp:SetVisible( true )

                menu_GAME:SetTitle( 'Games' )
            end
            ReturnBtn:SetText( 'Back' )
            
            drawPanel( ReturnBtn, colors[ 4 ], colors[ 5 ] )

            ReturnBtn:SetTextColor( colors[ 3 ] )

            local html = vgui.Create( 'DHTML', pan )
            html:Dock( FILL )
            html:DockMargin( 0, 0, 0, 4 )
            html:OpenURL( elem.url )
        end

        drawPanel( btn, colors[ 4 ], colors[ 5 ] )

        btn:SetTextColor( colors[ 3 ] )
    end
end

concommand.Add( 'games', function()
    if ( IsValid( menu_GAME ) ) then
        menu_GAME:SetVisible( true )
    else
        OpenMen()
    end
end  )
