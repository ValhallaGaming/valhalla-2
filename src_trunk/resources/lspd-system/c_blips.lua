local blips = { }

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		if getElementData( getLocalPlayer( ), "faction" ) == 1 then
			for key, value in pairs( getElementsByType( "player" ) ) do
				if value ~= getLocalPlayer( ) and not blips[ value ] and getElementData( value, "faction" ) == 1 then
					blips[ value ] = createBlipAttachedTo( value, 0, 2, 0, 0, 255 )
				end
			end
		end
	end
)

addEventHandler( "onClientElementDataChange", getRootElement( ),
	function( name )
		if name == "faction" and getElementType( source ) == "player" then
			local newfaction = getElementData( source, "faction" )
			
			if source == getLocalPlayer( ) then
				if newfaction ~= 1 then
					for key, value in pairs( blips ) do
						destroyElement( value )
					end
					blips = { }
				else
					for key, value in pairs( getElementsByType( "player" ) ) do
						if value ~= getLocalPlayer( ) and not blips[ value ] and getElementData( value, "faction" ) == 1 then
							blips[ value ] = createBlipAttachedTo( value, 0, 2, 0, 0, 255 )
						end
					end
				end
			elseif getElementData( getLocalPlayer( ), "faction" ) == 1 then
				if newfaction == 1 then
					if not blips[ source ] then
						blips[ source ] = createBlipAttachedTo( source, 0, 2, 0, 0, 255 )
					end
				elseif blips[ source ] then
					destroyElement( blips[ source ] )
					blips[ source ] = nil
				end
			end
		end
	end
)

addEventHandler( "onClientPlayerQuit", getRootElement( ),
	function( )
		if blips[ source ] then
			destroyElement( blips[ source ] )
			blips[ source ] = nil
		end
	end
)