tick = getTickCount()

-- /UPTIME
function getUptime(thePlayer, commandName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		local currTick = getTickCount()
		local uptimeMilliseconds = currTick - tick
		
		local minutes = math.floor((uptimeMilliseconds/1000)/60)
		
		if (minutes==1) then
			outputChatBox("Uptime: " .. minutes .. " Minute.", thePlayer, 255, 194, 14)
		else
			outputChatBox("Uptime: " .. minutes .. " Minutes.", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("uptime", getUptime)

-- /astats
function getAdminStats(thePlayer, commandName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		outputChatBox("-=-=-=-=-=-=-=-=-= STATISTICS =-=-=-=-=-=-=-=-=-", thePlayer, 255, 194, 14)
		
		-- CURRENT PLAYERS
		local playerCount = getPlayerCount()
		local maxCount = getMaxPlayers()
		outputChatBox("     Current Players: " .. playerCount .. "/" .. maxCount .. ".", thePlayer, 255, 194, 14)
		
		-- UPTIME
		local currTick = getTickCount()
		local uptimeMilliseconds = currTick - tick
		
		local minutes = math.floor((uptimeMilliseconds/1000)/60)
		
		if (minutes==1) then
			outputChatBox("     Uptime: " .. minutes .. " Minute.", thePlayer, 255, 194, 14)
		else
			outputChatBox("     Uptime: " .. minutes .. " Minutes.", thePlayer, 255, 194, 14)
		end
				
		-- VEHICLES
		outputChatBox("     Vehicles: " .. #exports.pool:getPoolElementsByType("vehicle") .. ".", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("astats", getAdminStats)