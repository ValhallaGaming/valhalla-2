-- ////////////////////////////////////
-- //			MYSQL				 //
-- ////////////////////////////////////		
sqlUsername = exports.mysql:getMySQLUsername()
sqlPassword = exports.mysql:getMySQLPassword()
sqlDB = exports.mysql:getMySQLDBName()
sqlHost = exports.mysql:getMySQLHost()
sqlPort = exports.mysql:getMySQLPort()

handler = mysql_connect(sqlHost, sqlUsername, sqlPassword, sqlDB, sqlPort)

function checkMySQL()
	if not (mysql_ping(handler)) then
		handler = mysql_connect(sqlHost, sqlUsername, sqlPassword, sqlDB, sqlPort)
	end
end
setTimer(checkMySQL, 300000, 0)

function closeMySQL()
	if (handler) then
		mysql_close(handler)
	end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), closeMySQL)
-- ////////////////////////////////////
-- //			MYSQL END			 //
-- ////////////////////////////////////

-- ADMIN HISTORY:
-- 0: jail
-- 1: kick
-- 2: ban
-- 3: forceapp
-- 4: warn
-- 5: auto-ban

-- /LOOK
function lookPlayer(thePlayer, commandName, targetPlayer)
	if not (targetPlayer) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
	else
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
		
		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			local username = getPlayerName(thePlayer)
			
			if (logged==0) then
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
			else
				--local query = mysql_query(handler, "SELECT description, age, weight, height, skincolor FROM characters WHERE id = " .. getElementData(targetPlayer, "dbid"))
				local description = getElementData(targetPlayer, "chardescription")
				local age = getElementData(targetPlayer, "age")
				local weight = getElementData(targetPlayer, "weight")
				local height = getElementData(targetPlayer, "height")
				local race = getElementData(targetPlayer, "race")
				--mysql_free_result(query)
				
				if (race==0) then
					race = "Black"
				elseif (race==1) then
					race = "White"
				elseif (race==2) then
					race = "Asian"
				else
					race = "Alien"
				end
				
				outputChatBox("~~~~~~~~~~~~ " .. targetPlayerName .. " ~~~~~~~~~~~~", thePlayer, 255, 194, 14)
				outputChatBox("Age: " .. age .. " years old", thePlayer, 255, 194, 14)
				outputChatBox("Ethnicity: " .. race, thePlayer, 255, 194, 14)
				outputChatBox("Weight: " .. weight .. "kg", thePlayer, 255, 194, 14)
				outputChatBox("Height: " .. height .. "cm", thePlayer, 255, 194, 14)
				outputChatBox("Description: " .. description, thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("look", lookPlayer, false, false)

--/AUNCUFF
function adminUncuff(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local username = getPlayerName(thePlayer)
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					local restrain = getElementData(targetPlayer, "restrain")
					
					if (restrain==0) then
						outputChatBox("Player is not restrained.", thePlayer, 255, 0, 0)
					else
						outputChatBox("You have been uncuffed by " .. username .. ".", targetPlayer)
						outputChatBox("You have uncuffed " .. targetPlayerName .. ".", thePlayer)
						toggleControl(targetPlayer, "sprint", true)
						toggleControl(targetPlayer, "fire", true)
						toggleControl(targetPlayer, "jump", true)
						toggleControl(targetPlayer, "next_weapon", true)
						toggleControl(targetPlayer, "previous_weapon", true)
						toggleControl(targetPlayer, "accelerate", true)
						toggleControl(targetPlayer, "brake_reverse", true)
						toggleControl(targetPlayer, "aim_weapon", true)
						setElementData(targetPlayer, "restrain", 0)
						removeElementData(targetPlayer, "restrainedBy")
						removeElementData(targetPlayer, "restrainedObj")
						exports.global:removeAnimation(targetPlayer)
						mysql_free_result( mysql_query( handler, "UPDATE characters SET cuffed = 0, restrainedby = 0, restrainedobj = 0 WHERE id = " .. getElementData( targetPlayer, "dbid" ) ) )
						exports['item-system']:deleteAll(47, getElementData( targetPlayer, "dbid" ))
					end
				end
			end
		end
	end
end
addCommandHandler("auncuff", adminUncuff, false, false)

--/AUNMASK
function adminUnmask(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local username = getPlayerName(thePlayer)
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					local gasmask = getElementData(targetPlayer, "gasmask")
					local mask = getElementData(targetPlayer, "mask")
					local helmet = getElementData(targetPlayer, "helmet")
					
					if (gasmask==1 or mask==1 or helmet==1) then
						local name = targetPlayerName:gsub("_", " ")
						setPlayerNametagText(targetPlayer, tostring(name))

						removeElementData(targetPlayer, "gasmask")
						removeElementData(targetPlayer, "mask")
						removeElementData(targetPlayer, "helmet")
						outputChatBox("You have removed the mask from " .. name .. ".", thePlayer, 255, 0, 0)
					else
						outputChatBox("Player is not masked.", thePlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("aunmask", adminUnmask, false, false)

function infoDisplay(thePlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		outputChatBox("---[        Useful Information        ]---", getRootElement(), 255, 194, 15)
		outputChatBox("---[ Ventrilo: 72.37.247.172 Port 3797", getRootElement(), 255, 194, 15)
		outputChatBox("---[ Forums: www.ValhallaGaming.net/forums", getRootElement(), 255, 194, 15)
		outputChatBox("---[ IRC: irc.multitheftauto.com #Valhalla", getRootElement(), 255, 194, 15)
		outputChatBox("---[ UCP: www.ValhallaGaming.net/mtaucp", getRootElement(), 255, 194, 15)

	end
end
addCommandHandler("vginfo", infoDisplay)

function adminUnblindfold(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local username = getPlayerName(thePlayer)
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					local blindfolded = getElementData(targetPlayer, "rblindfold")
					
					if (blindfolded==0) then
						outputChatBox("Player is not blindfolded", thePlayer, 255, 0, 0)
					else
						removeElementData(targetPlayer, "blindfold")
						fadeCamera(targetPlayer, true)
						outputChatBox("You have unblindfolded " .. targetPlayerName .. ".", thePlayer)
						mysql_free_result( mysql_query( handler, "UPDATE characters SET blindfold = 0 WHERE id = " .. getElementData( targetPlayer, "dbid" ) ) )
					end
				end
			end
		end
	end
end
addCommandHandler("aunblindfold", adminUnblindfold, false, false)

-- /MUTE
function mutePlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					local muted = getElementData(targetPlayer, "muted")
					
					if (muted==0) then
						setElementData(targetPlayer, "muted", 1)
						outputChatBox(targetPlayerName .. " is now muted from OOC.", thePlayer, 255, 0, 0)
						outputChatBox("You were muted by '" .. getPlayerName(thePlayer) .. "'.", targetPlayer, 255, 0, 0)
					else
						setElementData(targetPlayer, "muted", 0)
						outputChatBox(targetPlayerName .. " is now unmuted from OOC.", thePlayer, 0, 255, 0)
						outputChatBox("You were unmuted by '" .. getPlayerName(thePlayer) .. "'.", targetPlayer, 0, 255, 0)
					end
					mysql_free_result( mysql_query( handler, "UPDATE accounts SET muted=" .. getElementData(targetPlayer, "muted") .. " WHERE id = " .. getElementData(targetPlayer, "gameaccountid") ) )
				end
			end
		end
	end
end
addCommandHandler("pmute", mutePlayer, false, false)

-- /RESKICK
function resKick(thePlayer, commandName, amount)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (amount) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Amount of Players to Kick]", thePlayer, 255, 194, 14)
		else
			amount = tonumber(amount)
			local playercount = getPlayerCount()
			if (amount>=playercount) then
				outputChatBox("There is not enough players to kick. (Currently " .. playercount .. " Players)", thePlayer, 255, 0, 0)
			else
				local players = { }
				local count = 1
				for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
					if not (exports.global:isPlayerAdmin(value)) and not exports.global:isPlayerScripter(value) then
						players[count] = value
						count = count + 1
						
						if (count==amount) then
							break
						end
					end
				end
				local kickcount = 0
				for key, value in ipairs(players) do
					if (kickcount<amount) then
						local luck = math.random(0, 1)
						if (luck==1) then
							kickPlayer(value, getRootElement(), "Slot Reservation")
							kickcount = kickcount + 1
						end
					end
				end
				outputChatBox("Kicked " .. kickcount .. "/" .. amount .. " players for slot reservation.", thePlayer, 0, 255, 0)
			end
		end
	end
end
addCommandHandler("reskick", resKick, false, false)

-- /DISARM
function disarmPlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					exports.global:takeAllWeapons(targetPlayer)
					outputChatBox(targetPlayerName .. " is now disarmed.", thePlayer, 255, 194, 14)
					exports.logs:logMessage("[/DISARM] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." disarmed ".. targetPlayerName , 4)
				end
			end
		end
	end
end
addCommandHandler("disarm", disarmPlayer, false, false)

-- forceapp
function forceApplication(thePlayer, commandName, targetPlayer, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick/ID] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if not (targetPlayer) then
			elseif exports.global:isPlayerAdmin(targetPlayer) then
				outputChatBox("No.", thePlayer, 255, 0, 0)
			else
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					local reason = table.concat({...}, " ")
					local id = getElementData(targetPlayer, "gameaccountid")
					local username = getElementData(thePlayer, "gameaccountusername")
					mysql_query(handler, "UPDATE accounts SET appstate = 2, apphandler='" .. username .. "', appreason='" .. mysql_escape_string(handler, reason) .. "', appdatetime = NOW() + INTERVAL 1 DAY WHERE id='" .. id .. "'")
					outputChatBox(targetPlayerName .. " was forced to re-write their application.", thePlayer, 255, 194, 14)
					
					local port = getServerPort()
					local password = getServerPassword()
					
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " sent " .. targetPlayerName .. " back to the application stage.")
					
					local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',0,3,0,"' .. mysql_escape_string(handler, reason) .. '")' )
					if res then
						mysql_free_result( res )
					else
						outputDebugString( mysql_error( handler ) )
					end
					
					redirectPlayer(targetPlayer, "87.238.173.138", port, password)
				end
			end
		end
	end
end
addCommandHandler("forceapp", forceApplication, false, false)

-- /CK
function ckPlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					local query = mysql_query(handler, "UPDATE characters SET cked='1' WHERE id = " .. getElementData(targetPlayer, "dbid"))
					
					local x, y, z = getElementPosition(targetPlayer)
					local skin = getPedSkin(targetPlayer)
					local rotation = getPedRotation(targetPlayer)
					
					call( getResourceFromName( "realism-system" ), "addCharacterKillBody", x, y, z, rotation, skin, getElementData(targetPlayer, "dbid"), targetPlayerName, getElementInterior(targetPlayer), getElementDimension(targetPlayer) )
					
					-- send back to change char screen
					local id = getElementData(targetPlayer, "gameaccountid")
					showCursor(targetPlayer, false)
					triggerEvent("sendAccounts", targetPlayer, targetPlayer, id, true)
					setElementData(targetPlayer, "loggedin", 0, false)
					outputChatBox("Your character was CK'ed by " .. getPlayerName(thePlayer) .. ".", targetPlayer, 255, 194, 14)
					showChat(targetPlayer, true)
					outputChatBox("You have CK'ed ".. targetPlayerName ..".", thePlayer, 255, 194, 1, 14)
					mysql_free_result(query)
					exports.logs:logMessage("[/CK] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." CK'ED ".. targetPlayerName , 4)
				end
			end
		end
	end
end
addCommandHandler("ck", ckPlayer)

-- /UNCK
function unckPlayer(thePlayer, commandName, ...)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result = mysql_query(handler, "SELECT id FROM characters WHERE charactername='" .. mysql_escape_string(handler, tostring(targetPlayer)) .. "' AND cked > 0")
			
			if (mysql_num_rows(result)>1) then
				outputChatBox("Too many results - Please enter a more exact name.", thePlayer, 255, 0, 0)
			elseif (mysql_num_rows(result)==0) then
				outputChatBox("Player does not exist or is not CK'ed.", thePlayer, 255, 0, 0)
			else
				local dbid = tonumber(mysql_result(result, 1, 1)) or 0
				local query = mysql_query(handler, "UPDATE characters SET cked='0' WHERE id = " .. dbid .. " LIMIT 1")
				mysql_free_result(query)
				
				-- delete all peds for him
				for key, value in pairs( getElementsByType( "ped" ) ) do
					if isElement( value ) and getElementData( value, "ckid" ) then
						if getElementData( value, "ckid" ) == dbid then
							destroyElement( value )
						end
					end
				end
				
				outputChatBox(targetPlayer .. " is no longer CK'ed.", thePlayer, 0, 255, 0)
				exports.logs:logMessage("[/UNCK] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." UNCK'ED ".. targetPlayer , 4)
			end
			mysql_free_result(result)
		end
	end
end
addCommandHandler("unck", unckPlayer)

-- /BURY
function buryPlayer(thePlayer, commandName, ...)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result = mysql_query(handler, "SELECT id, cked FROM characters WHERE charactername='" .. mysql_escape_string(handler, tostring(targetPlayer)) .. "'")
			
			if (mysql_num_rows(result)>1) then
				outputChatBox("Too many results - Please enter a more exact name.", thePlayer, 255, 0, 0)
			elseif (mysql_num_rows(result)==0) then
				outputChatBox("Player does not exist.", thePlayer, 255, 0, 0)
			else
				local dbid = tonumber(mysql_result(result, 1, 1)) or 0
				local cked = tonumber(mysql_result(result, 1, 2)) or 0
				if cked == 0 then
					outputChatBox("Player is not CK'ed.", thePlayer, 255, 0, 0)
				elseif cked == 2 then
					outputChatBox("Player is already buried.", thePlayer, 255, 0, 0)
				else
					local query = mysql_query(handler, "UPDATE characters SET cked='2' WHERE id = " .. dbid .. " LIMIT 1")
					mysql_free_result(query)
					
					-- delete all peds for him
					for key, value in pairs( getElementsByType( "ped" ) ) do
						if isElement( value ) and getElementData( value, "ckid" ) then
							if getElementData( value, "ckid" ) == dbid then
								destroyElement( value )
							end
						end
					end
					
					outputChatBox(targetPlayer .. " was buried.", thePlayer, 0, 255, 0)
					exports.logs:logMessage("[/BURY] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." buried ".. targetPlayer , 4)
				end
			end
			mysql_free_result(result)
		end
	end
end
addCommandHandler("bury", buryPlayer)

-- /FRECONNECT
function forceReconnect(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					outputChatBox("Player '" .. targetPlayerName .. "' was forced to reconnect.", thePlayer, 255, 0, 0)
					
					local port = getServerPort()
					local password = getServerPassword()
					
					redirectPlayer(targetPlayer, "87.238.173.138", port, password)
					
					exports.logs:logMessage("[/FRECONNECT] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." reconnected ".. targetPlayerName , 4)
				end
			end
		end
	end
end
addCommandHandler("freconnect", forceReconnect, false, false)

-- /GIVEGUN
function givePlayerGun(thePlayer, commandName, targetPlayer, ...)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		local args = {...}
		if not (targetPlayer) or (#args < 1) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Weapon ID/Name] [Ammo]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local weapon = tonumber(args[1])
				local ammo = #args ~= 1 and tonumber(args[#args]) or 1
				
				if not weapon then -- weapon is specified as name
					local weaponEnd = #args
					repeat
						weapon = getWeaponIDFromName(table.concat(args, " ", 1, weaponEnd))
						weaponEnd = weaponEnd - 1
					until weapon or weaponEnd == -1
					if weaponEnd == -1 then
						outputChatBox("Invalid Weapon Name.", thePlayer, 255, 0, 0)
						return
					elseif weaponEnd == #args - 1 then
						ammo = 1
					end
				elseif not getWeaponNameFromID(weapon) then
					outputChatBox("Invalid Weapon ID.", thePlayer, 255, 0, 0)
				end
				
				local logged = getElementData(targetPlayer, "loggedin")
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					exports.global:takeWeapon(targetPlayer, weapon)
					local give = exports.global:giveWeapon(targetPlayer, weapon, ammo, true)
					
					if not (give) then
						outputChatBox("Invalid Weapon ID.", thePlayer, 255, 0, 0)
					else
						outputChatBox("Player " .. targetPlayerName .. " now has a " .. getWeaponNameFromID(weapon) .. " with " .. ammo .. " Ammo.", thePlayer, 0, 255, 0)
						exports.logs:logMessage(getPlayerName(thePlayer):gsub("_", " ") .. " gave " .. targetPlayerName .. " a " .. getWeaponNameFromID(weapon) .. " with " .. ammo .. " Ammo.", 22)
						if (hiddenAdmin==0) then
							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a " .. getWeaponNameFromID(weapon) .. " with " .. ammo .. " ammo.")
						end
					end
				end
			end
		end
	end
end
addCommandHandler("givegun", givePlayerGun, false, false)

-- /GIVEITEM
function givePlayerItem(thePlayer, commandName, targetPlayer, itemID, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (itemID) or not (...) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Item ID] [Item Value]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				itemID = tonumber(itemID)
				local itemValue = table.concat({...}, " ")
				itemValue = tonumber(itemValue) or itemValue
				
				if ( itemID == 74 or itemID == 75 or itemID == 78 ) and not exports.global:isPlayerScripter( thePlayer ) and not exports.global:isPlayerHeadAdmin( thePlayer) then
					-- nuthin
				elseif ( itemID == 84 ) and not exports.global:isPlayerLeadAdmin( thePlayer ) then
				elseif (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					local name = call( getResourceFromName( "item-system" ), "getItemName", itemID )
					
					if itemID > 0 and name and name ~= "?" then
						local success, reason = exports.global:giveItem(targetPlayer, itemID, itemValue)
						if success then
							outputChatBox("Player " .. targetPlayerName .. " now has a " .. name .. " with value " .. itemValue .. ".", thePlayer, 0, 255, 0)
							exports.logs:logMessage(getPlayerName(thePlayer):gsub("_", " ") .. " gave " .. targetPlayerName .. " a " .. name .. " with value " .. itemValue, 13)
							
							if itemID == 2 or itemID == 17 then
								triggerClientEvent(targetPlayer, "updateHudClock", targetPlayer)
							end
						else
							outputChatBox("Couldn't give " .. targetPlayerName .. " a " .. name .. ": " .. tostring(reason), thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("Invalid Item ID.", thePlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("giveitem", givePlayerItem, false, false)

-- /TAKEITEM
function takePlayerItem(thePlayer, commandName, targetPlayer, itemID, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (itemID) or not (...) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Item ID] [Item Value]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				itemID = tonumber(itemID)
				local itemValue = table.concat({...}, " ")
				itemValue = tonumber(itemValue) or itemValue
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					if exports.global:hasItem(targetPlayer, itemID, itemValue) then
						outputChatBox("You took that Item " .. itemID .. " from " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
						exports.global:takeItem(targetPlayer, itemID, itemValue)
						
						if itemID == 2 or itemID == 17 then
							triggerClientEvent(targetPlayer, "updateHudClock", targetPlayer)
						end
					else
						outputChatBox("Player doesn't have that item", thePlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("takeitem", takePlayerItem, false, false)

-- /SETHP
function setPlayerHealth(thePlayer, commandName, targetPlayer, health)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (health) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Health]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local hp = nil
				
				if (tostring(type(tonumber(health))) == "number") then
					hp = setElementHealth(targetPlayer, tonumber(health))
				end
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif not (hp) then
					outputChatBox("Invalid health value.", thePlayer, 255, 0, 0)
				else
					outputChatBox("Player " .. targetPlayerName .. " now has " .. health .. " Health.", thePlayer, 0, 255, 0)
					triggerEvent("onPlayerHeal", targetPlayer, true)
					exports.logs:logMessage("[/SETHP] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." set ".. targetPlayerName .. " to " .. health , 4)
				end
			end
		end
	end
end
addCommandHandler("sethp", setPlayerHealth, false, false)

-- /SETARMOR
function setPlayerArmour(thePlayer, commandName, targetPlayer, armor)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (armor) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Armor]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (tostring(type(tonumber(armor))) == "number") then
					local setArmor = setPedArmor(targetPlayer, tonumber(armor))
					outputChatBox("Player " .. targetPlayerName .. " now has " .. armor .. " Armor.", thePlayer, 0, 255, 0)
					exports.logs:logMessage("[/SETARMOR] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." set ".. targetPlayerName .. " his armor to " .. armor , 4)
				else
					outputChatBox("Invalid armor value.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setarmor", setPlayerArmour, false, false)

-- /SETSKIN
function setPlayerSkinCmd(thePlayer, commandName, targetPlayer, skinID)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (skinID) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Skin ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (tostring(type(tonumber(skinID))) == "number" and tonumber(skinID) ~= 0) then
					local fat = getPedStat(targetPlayer, 21)
					local muscle = getPedStat(targetPlayer, 23)
					
					setPedStat(targetPlayer, 21, 0)
					setPedStat(targetPlayer, 23, 0)
					local skin = setElementModel(targetPlayer, tonumber(skinID))
					
					setPedStat(targetPlayer, 21, fat)
					setPedStat(targetPlayer, 23, muscle)
					if not (skin) then
						outputChatBox("Invalid skin ID.", thePlayer, 255, 0, 0)
					else
						outputChatBox("Player " .. targetPlayerName .. " now has skin " .. skinID .. ".", thePlayer, 0, 255, 0)
						mysql_free_result( mysql_query( handler, "UPDATE characters SET skin = " .. skinID .. " WHERE id = " .. getElementData( targetPlayer, "dbid" ) ) )
						exports.logs:logMessage("[/SETSKIN] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." set ".. targetPlayerName .. " his skin to "..skinID , 4)
					end
				else
					outputChatBox("Invalid skin ID.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setskin", setPlayerSkinCmd, false, false)

-- /CHANGENAME
function asetPlayerName(thePlayer, commandName, targetPlayer, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (...) or not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Player New Nick]", thePlayer, 255, 194, 14)
		else
			local newName = table.concat({...}, "_")
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				if newName == targetPlayerName then
					outputChatBox( "The player's name is already that.", thePlayer, 255, 0, 0)
				else
					local dbid = getElementData(targetPlayer, "dbid")
					local result = mysql_query(handler, "SELECT charactername FROM characters WHERE charactername='" .. mysql_escape_string(handler, newName) .. "' AND id != " .. dbid)
					
					if (mysql_num_rows(result)>0) then
						outputChatBox("This name is already in use.", thePlayer, 255, 0, 0)
					else
						setElementData(targetPlayer, "legitnamechange", 1)
						local name = setPlayerName(targetPlayer, tostring(newName))
						
						if (name) then
							if getPlayerNametagText(targetPlayer) ~= "Unknown Person" then
								setPlayerNametagText(targetPlayer, tostring(newName):gsub("_", " "))
							end
							exports['vehicle-system']:clearCharacterName( dbid )
							local query = mysql_query(handler, "UPDATE characters SET charactername='" .. mysql_escape_string(handler, newName) .. "' WHERE id = " .. dbid)
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " changed " .. targetPlayerName .. "'s Name to " .. newName .. ".")
							end
							outputChatBox("You changed " .. targetPlayerName .. "'s Name to " .. tostring(newName) .. ".", thePlayer, 0, 255, 0)
							setElementData(targetPlayer, "legitnamechange", 0)
							mysql_free_result(query)
							
							exports.logs:logMessage("[/CHANGENAME] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." changed ".. targetPlayerName .. " TO ".. tostring(newName) , 4)
						else
							outputChatBox("Failed to change name.", thePlayer, 255, 0, 0)
						end
						setElementData(targetPlayer, "legitnamechange", 0)
					end
					mysql_free_result(result)
				end
			end
		end
	end
end
addCommandHandler("changename", asetPlayerName, false, false)

-- /HIDEADMIN
function hideAdmin(thePlayer, commandName)
	if exports.global:isPlayerHeadAdmin(thePlayer) or exports.global:isPlayerScripter(thePlayer) then
		local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
		
		if (hiddenAdmin==0) then
			setElementData(thePlayer, "hiddenadmin", 1)
			outputChatBox("You are now a hidden admin.", thePlayer, 255, 194, 14)
		elseif (hiddenAdmin==1) then
			setElementData(thePlayer, "hiddenadmin", 0)
			outputChatBox("You are no longer a hidden admin.", thePlayer, 255, 194, 14)
		end
		exports.global:updateNametagColor(thePlayer)
		mysql_free_result( mysql_query( handler, "UPDATE accounts SET hiddenadmin=" .. getElementData(thePlayer, "hiddenadmin") .. " WHERE id = " .. getElementData(thePlayer, "gameaccountid") ) )
	end
end
addCommandHandler("hideadmin", hideAdmin, false, false)
	
-- /SLAP
function slapPlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.global:getPlayerAdminLevel(targetPlayer)
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (targetPlayerPower > thePlayerPower) then -- Check the admin isn't slapping someone higher rank them him
					outputChatBox("You cannot slap this player as they are a higher admin rank then you.", thePlayer, 255, 0, 0)
				else
					local x, y, z = getElementPosition(targetPlayer)
					
					if (isPedInVehicle(targetPlayer)) then
						setElementData(targetPlayer, "realinvehicle", 0, false)
						removePedFromVehicle(targetPlayer)
					end
					
					setElementPosition(targetPlayer, x, y, z+15)
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					
					if (hiddenAdmin==0) then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " slapped " .. targetPlayerName .. ".")
						exports.logs:logMessage("[/SLAP] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." slapped ".. targetPlayerName , 4)
					end
				end
			end
		end
	end
end
addCommandHandler("slap", slapPlayer, false, false)

-- /HUGESLAP
function hugeSlapPlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.global:getPlayerAdminLevel(targetPlayer)
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (targetPlayerPower > thePlayerPower) then -- Check the admin isn't slapping someone higher rank them him
					outputChatBox("You cannot hugeslap this player as they are a higher admin rank then you.", thePlayer, 255, 0, 0)
				else
					local x, y, z = getElementPosition(targetPlayer)
					
					if (isPedInVehicle(targetPlayer)) then
						setElementData(targetPlayer, "realinvehicle", 0, false)
						removePedFromVehicle(targetPlayer)
					end
					
					setElementPosition(targetPlayer, x, y, z+50)
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					
					if (hiddenAdmin==0) then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " huge-slapped " .. targetPlayerName .. ".")
						exports.logs:logMessage("[/HUGESLAP] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." slapped ".. targetPlayerName , 4)
					end
				end
			end
		end
	end
end
addCommandHandler("hugeslap", hugeSlapPlayer, false, false)

-- HEADS Hidden OOC
function hiddenOOC(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if (exports.global:isPlayerHeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local players = exports.pool:getPoolElementsByType("player")
			local message = table.concat({...}, " ")
			
			exports.irc:sendMessage("[OOC: Global Chat] Hidden Admin " .. getPlayerName(thePlayer) .. ": " .. message)
			for index, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
			
				if (logged==1) and getElementData(arrayPlayer, "globalooc") == 1 then
					outputChatBox("(( Hidden Admin: " .. message .. " ))", arrayPlayer, 255, 255, 255)
				end
			end
		end
	end
end
addCommandHandler("ho", hiddenOOC, false, false)

-- HEADS Hidden Whisper
function hiddenWhisper(thePlayer, command, who, ...)
	if (exports.global:isPlayerHeadAdmin(thePlayer)) then
		if not (who) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Message]", thePlayer, 255, 194, 14)
		else
			message = table.concat({...}, " ")
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
			
			if (targetPlayer) then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==1) then
					local playerName = getPlayerName(thePlayer)
					outputChatBox("PM From Hidden Admin: " .. message, targetPlayer, 255, 255, 0)
					outputChatBox("Hidden PM Sent to " .. targetPlayerName .. ": " .. message, thePlayer, 255, 255, 0)
				elseif (logged==0) then
					outputChatBox("Player is not logged in yet.", thePlayer, 255, 255, 0)
				end
			end
		end
	end
end
addCommandHandler("hw", hiddenWhisper, false, false)

-- RECON
function reconPlayer(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) then
			local rx = getElementData(thePlayer, "reconx")
			local ry = getElementData(thePlayer, "recony")
			local rz = getElementData(thePlayer, "reconz")
			local reconrot = getElementData(thePlayer, "reconrot")
			local recondimension = getElementData(thePlayer, "recondimension")
			local reconinterior = getElementData(thePlayer, "reconinterior")
			
			if not (rx) or not (ry) or not (rz) or not (reconrot) or not (recondimension) or not (reconinterior) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick]", thePlayer, 255, 194, 14)
			else
				detachElements(thePlayer)
			
				setElementPosition(thePlayer, rx, ry, rz)
				setPedRotation(thePlayer, reconrot)
				setElementDimension(thePlayer, recondimension)
				setElementInterior(thePlayer, reconinterior)
				setCameraInterior(thePlayer, reconinterior)
				
				setElementData(thePlayer, "reconx", nil)
				setElementData(thePlayer, "recony", nil, false)
				setElementData(thePlayer, "reconz", nil, false)
				setElementData(thePlayer, "reconrot", nil, false)
				setCameraTarget(thePlayer, thePlayer)
				setElementAlpha(thePlayer, 255)
				outputChatBox("Recon turned off.", thePlayer, 255, 194, 14)
			end
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif getElementData(targetPlayer, "gameaccountusername") == "mabako" and not exports.global:isPlayerScripter(thePlayer) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					setElementAlpha(thePlayer, 0)
					
					if not getElementData(thePlayer, "reconx") and not getElementData(thePlayer, "recony") then
						local x, y, z = getElementPosition(thePlayer)
						local rot = getPedRotation(thePlayer)
						local dimension = getElementDimension(thePlayer)
						local interior = getElementInterior(thePlayer)
						setElementData(thePlayer, "reconx", x)
						setElementData(thePlayer, "recony", y, false)
						setElementData(thePlayer, "reconz", z, false)
						setElementData(thePlayer, "reconrot", rot, false)
						setElementData(thePlayer, "recondimension", dimension, false)
						setElementData(thePlayer, "reconinterior", interior, false)
					end
					setPedWeaponSlot(thePlayer, 0)
					
					local playerdimension = getElementDimension(targetPlayer)
					local playerinterior = getElementInterior(targetPlayer)
					
					setElementDimension(thePlayer, playerdimension)
					setElementInterior(thePlayer, playerinterior)
					setCameraInterior(thePlayer, playerinterior)
					
					local x, y, z = getElementPosition(targetPlayer)
					setElementPosition(thePlayer, x - 10, y - 10, z - 5)
					local success = attachElements(thePlayer, targetPlayer, -10, -10, 5)
					if not (success) then
						success = attachElements(thePlayer, targetPlayer, -5, -5, 5)
						if not (success) then
							success = attachElements(thePlayer, targetPlayer, 5, 5, 5)
						end
					end
					
					if not (success) then
						outputChatBox("Failed to attach the element.", thePlayer, 0, 255, 0)
					else
						setCameraTarget(thePlayer, targetPlayer)
						outputChatBox("Now reconning " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
						
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						
						if hiddenAdmin == 0 and not exports.global:isPlayerLeadAdmin(thePlayer) then
							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " started reconning " .. targetPlayerName .. ".")
						end
					end
				end
			end
		end
	end
end
addCommandHandler("recon", reconPlayer, false, false)

function fuckRecon(thePlayer, commandName, targetPlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		local rx = getElementData(thePlayer, "reconx")
		local ry = getElementData(thePlayer, "recony")
		local rz = getElementData(thePlayer, "reconz")
		local reconrot = getElementData(thePlayer, "reconrot")
		local recondimension = getElementData(thePlayer, "recondimension")
		local reconinterior = getElementData(thePlayer, "reconinterior")
		
		detachElements(thePlayer)
		setCameraTarget(thePlayer, thePlayer)
		setElementAlpha(thePlayer, 255)
		
		if rx and ry and rz then
			setElementPosition(thePlayer, rx, ry, rz)
			if reconrot then
				setPedRotation(thePlayer, reconrot)
			end
			
			if recondimension then
				setElementDimension(thePlayer, recondimension)
			end
			
			if reconinterior then
					setElementInterior(thePlayer, reconinterior)
					setCameraInterior(thePlayer, reconinterior)
			end
		end
		
		removeElementData(thePlayer, "reconx")
		removeElementData(thePlayer, "recony")
		removeElementData(thePlayer, "reconz")
		removeElementData(thePlayer, "reconrot")
		outputChatBox("Recon turned off.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("fuckrecon", fuckRecon, false, false)
addCommandHandler("stoprecon", fuckRecon, false, false)

-- Kick
function kickAPlayer(thePlayer, commandName, targetPlayer, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.global:getPlayerAdminLevel(targetPlayer)
				reason = table.concat({...}, " ")
				
				if (targetPlayerPower <= thePlayerPower) then
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					
					local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',' .. hiddenAdmin .. ',1,0,"' .. mysql_escape_string(handler, reason) .. '")' )
					if res then
						mysql_free_result( res )
					else
						outputDebugString( mysql_error( handler ) )
					end
					
					if (hiddenAdmin==0) then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						outputChatBox("AdmKick: " .. adminTitle .. " " .. playerName .. " kicked " .. targetPlayerName .. ".", getRootElement(), 255, 0, 51)
						outputChatBox("AdmKick: Reason: " .. reason .. ".", getRootElement(), 255, 0, 51)
						kickPlayer(targetPlayer, thePlayer, reason)
					else
						outputChatBox("AdmKick: Hidden Admin kicked " .. targetPlayerName .. ".", getRootElement(), 255, 0, 51)
						outputChatBox("AdmKick: Reason: " .. reason, getRootElement(), 255, 0, 51)
						kickPlayer(targetPlayer, getRootElement(), reason)
					end
					exports.logs:logMessage("[/PKICK] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." kicked ".. targetPlayerName .." (".. reason ..")" , 4)
				else
					outputChatBox(" This player is a higher level admin than you.", thePlayer, 255, 0, 0)
					outputChatBox(playerName .. " attempted to execute the kick command on you.", targetPlayer, 255, 0 ,0)
				end
			end
		end
	end
end
addCommandHandler("pkick", kickAPlayer, false, false)


-- BAN
function banAPlayer(thePlayer, commandName, targetPlayer, hours, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (hours) or (tonumber(hours)<0) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Time in Hours, 0 = Infinite] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			hours = tonumber(hours)
			
			if not (targetPlayer) then
			elseif (hours>168) then
				outputChatBox("You cannot ban for more than 7 days (168 Hours).", thePlayer, 255, 194, 14)
			else
				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.global:getPlayerAdminLevel(targetPlayer)
				reason = table.concat({...}, " ")
				
				if (targetPlayerPower <= thePlayerPower) then -- Check the admin isn't banning someone higher rank them him
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					local accountID = getElementData(targetPlayer, "gameaccountid")
					
					local seconds = ((hours*60)*60)
					local rhours = hours
					-- text value
					if (hours==0) then
						hours = "Permanent"
					elseif (hours==1) then
						hours = "1 Hour"
					else
						hours = hours .. " Hours"
					end
					
					reason = reason .. " (" .. hours .. ")"
					
					local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',' .. hiddenAdmin .. ',2,' .. rhours .. ',"' .. mysql_escape_string(handler, reason) .. '")' )
					if res then
						mysql_free_result( res )
					else
						outputDebugString( mysql_error( handler ) )
					end
					if (hiddenAdmin==0) then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						outputChatBox("AdmBan: " .. adminTitle .. " " .. playerName .. " banned " .. targetPlayerName .. ". (" .. hours .. ")", getRootElement(), 255, 0, 51)
						outputChatBox("AdmBan: Reason: " .. reason .. ".", getRootElement(), 255, 0, 51)
						
						local ban = banPlayer(targetPlayer, true, false, false, thePlayer, reason, seconds)
						
						local query = mysql_query(handler, "UPDATE accounts SET banned='1', banned_reason='" .. reason .. "', banned_by='" .. mysql_escape_string(handler, playerName) .. "' WHERE id='" .. accountID .. "'")
						mysql_free_result(query)
					elseif (hiddenAdmin==1) then
						outputChatBox("AdmBan: Hidden Admin banned " .. targetPlayerName .. ". (" .. hours .. ")", getRootElement(), 255, 0, 51)
						outputChatBox("AdmBan: Reason: " .. reason, getRootElement(), 255, 0, 51)
						outputChatBox("AdmBan: Time: " .. hours .. ".", getRootElement(), 255, 0, 51)
						
						local ban = banPlayer(targetPlayer, true, false, false, getRootElement(), reason, seconds)
						
						local query = mysql_query(handler, "UPDATE accounts SET banned='1', banned_reason='" .. reason .. "', banned_by='" .. mysql_escape_string(handler, playerName) .. "' WHERE id='" .. accountID .. "'")
						mysql_free_result(query)
					end
				else
					outputChatBox(" This player is a higher level admin than you.", thePlayer, 255, 0, 0)
					outputChatBox(playerName .. " attempted to execute the ban command on you.", targetPlayer, 255, 0 ,0)
				end
			end
		end
	end
end
addCommandHandler("pban", banAPlayer, false, false)

function unbanAccount(theBan)
	local ip = getBanIP(theBan)
	mysql_query(handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='" .. ip .. "'")
end
addEventHandler("onUnban", getRootElement(), unbanAccount)

function remoteUnban(thePlayer, targetNick)
	local bans = getBans()
	local found = false
	
	local result1 = mysql_query(handler, "SELECT id, ip, banned FROM accounts WHERE username='" .. tostring(targetNick) .. "' LIMIT 1")
	
	if (result1) then
		if (mysql_num_rows(result1)>0) then
			local accountid = tonumber(mysql_result(result1, 1, 1))
			local ip = tostring(mysql_result(result1, 1, 2))
			local banned = tonumber(mysql_result(result1, 1, 3))
			mysql_free_result(result1)
			local bans = getBans()
			
			for key, value in ipairs(bans) do
				if (ip==getBanIP(value)) then
					exports.global:sendMessageToAdmins(tostring(targetNick) .. " was remote unbanned from UCP by " .. thePlayer .. ".")
					removeBan(value)
					local query = mysql_query(handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='" .. ip .. "'")
					mysql_free_result(query)
					found = true
					break
				end
			end
			
			if not found and banned == 1 then
				mysql_free_result( mysql_query( handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE id='" .. id .. "'") )
				return true
			end
		end
	end
	return found
end

-- /UNBAN
function unbanPlayer(thePlayer, commandName, nickName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (nickName) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Full Name]", thePlayer, 255, 194, 14)
		else
			local bans = getBans()
			local found = false
			
			local result1 = mysql_query(handler, "SELECT account FROM characters WHERE charactername='" .. mysql_escape_string(handler, tostring(nickName)) .. "' LIMIT 1")
			
			if (result1) then
				if (mysql_num_rows(result1)>0) then
					local accountid = tonumber(mysql_result(result1, 1, 1))
					mysql_free_result(result1)
					
					local result = mysql_query(handler, "SELECT ip, banned FROM accounts WHERE id='" .. accountid .. "'")
						
					if (result) then
						if (mysql_num_rows(result)>0) then
							local ip = tostring(mysql_result(result, 1, 1))
							local banned = tonumber(mysql_result(result, 1, 2))
							
							for key, value in ipairs(bans) do
								if (ip==getBanIP(value)) then
									exports.global:sendMessageToAdmins(tostring(nickName) .. " was unbanned by " .. getPlayerName(thePlayer) .. ".")
									removeBan(value, thePlayer)
									local query = mysql_query(handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='" .. ip .. "'")
									mysql_free_result(query)
									found = true
									break
								end
							end
							
							if not found and banned == 1 then
								mysql_free_result( mysql_query( handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE id='" .. accountid .. "'") )
								found = true
							end
							
							if not (found) then
								outputChatBox("No ban found for '" .. nickName .. "'", thePlayer, 255, 0, 0)
							end
							mysql_free_result(result)
						else
							outputChatBox("No ban found for '" .. nickName .. "'", thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("No ban found for '" .. nickName .. "'", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("No ban found for '" .. nickName .. "'", thePlayer, 255, 0, 0)
				end
				mysql_free_result(result1)
			else
				outputChatBox("No ban found for '" .. nickName .. "'", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("unban", unbanPlayer, false, false)

-- /UNBANIP
function unbanPlayerIP(thePlayer, commandName, ip)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (ip) then
			outputChatBox("SYNTAX: /" .. commandName .. " [IP]", thePlayer, 255, 194, 14)
		else
			ip = mysql_escape_string(handler, ip)
			local bans = getBans()
			local found = false
				
			for key, value in ipairs(bans) do
				if (ip==getBanIP(value)) then
					exports.global:sendMessageToAdmins(tostring(ip) .. " was unbanned by " .. getPlayerName(thePlayer) .. ".")
					removeBan(value, thePlayer)
					local query = mysql_query(handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='" .. ip .. "'")
					mysql_free_result(query)
					found = true
					break
				end
			end
			
			local query = mysql_query(handler,"SELECT COUNT(*) FROM accounts WHERE ip = '" .. ip .. "' AND banned = 1")
			if tonumber(mysql_result(query, 1, 1)) > 0 then
				local query2 = mysql_query(handler, "UPDATE accounts SET banned='0', banned_by=NULL WHERE ip='" .. ip .. "'")
				mysql_free_result(query2)
			end
			mysql_free_result(query)
			
			if not (found) then
				outputChatBox("No ban found for '" .. ip .. "'", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("unbanip", unbanPlayerIP, false, false)

function teleportToPresetPoint(thePlayer, commandName, target)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [LS/SF/LV]", thePlayer, 255, 194, 14)
		else
			target = string.lower(tostring(target))
			
			if (target=="ls") then -- LOS SANTOS
				if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
					setElementPosition(veh, 1520.0029296875, -1701.2425537109, 16.546875)
					setVehicleRotation(veh, 0, 0, 275.82763671875)
					setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
					setElementDimension(veh, 0)
					setElementInterior(veh, 0)
					
					setElementDimension(thePlayer, 0)
					setElementInterior(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
				else
					setElementPosition(thePlayer, 1520.0029296875, -1701.2425537109, 13.546875)
					setPedRotation(thePlayer, 275.82763671875)
					setElementDimension(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
					setElementInterior(thePlayer, 0)
				end
				outputChatBox("Teleported to Los Santos!", thePlayer, 0, 255, 0)
			elseif (target=="sf") then -- SAN FIERRO
				if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setVehicleTurnVelocity(veh, 0, 0, 0)
					setElementPosition(veh, -1689.0689697266, -536.7919921875, 18.854997634888)
					setVehicleRotation(veh, 0, 0, 252.35975646973)
					setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
					
					setElementDimension(veh, 0)
					setElementInterior(veh, 0)
					
					setElementDimension(thePlayer, 0)
					setElementInterior(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
				else
					setElementPosition(thePlayer, -1689.0689697266, -536.7919921875, 15.854997634888)
					setPedRotation(thePlayer, 252.35975646973)
					setElementDimension(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
					setElementInterior(thePlayer, 0)
				end
				outputChatBox("Teleported to San Fierro!", thePlayer, 0, 255, 0)
			elseif (target=="lv") then -- LAS VENTURAS
				if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setVehicleTurnVelocity(veh, 0, 0, 0)
					setElementPosition(veh, 1691.6801757813, 1449.1293945313, 12.765375137329)
					setVehicleRotation(veh, 0, 0, 268.20239257813)
					setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
					setElementDimension(veh, 0)
					setElementInterior(veh, 0)
					
					setElementDimension(thePlayer, 0)
					setElementInterior(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
				else
					setElementPosition(thePlayer, 1691.6801757813, 1449.1293945313, 12.765375137329)
					setPedRotation(thePlayer, 268.20239257813)
					setElementDimension(thePlayer, 0)
					setCameraInterior(thePlayer, 0)
					setElementInterior(thePlayer, 0)
				end
				outputChatBox("Teleported to Las Venturas!", thePlayer, 0, 255, 0)
			else
				outputChatBox("Invalid Place Entered!", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("gotoplace", teleportToPresetPoint, false, false)

function makePlayerAdmin(thePlayer, commandName, who, rank)
	if (exports.global:isPlayerHeadAdmin(thePlayer)) then
		if not (who) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Rank]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
			
			if (targetPlayer) then
				local username = getPlayerName(thePlayer)
				local accountID = getElementData(targetPlayer, "gameaccountid")
				
				setElementData(targetPlayer, "adminlevel", tonumber(rank))
				
				rank = tonumber(rank)
				
				if (rank<1337) then
					setElementData(targetPlayer, "hiddenadmin", 0)
				end
				
				local query = mysql_query(handler, "UPDATE accounts SET admin='" .. tonumber(rank) .. "', hiddenadmin='0' WHERE id='" .. accountID .. "'")
				mysql_free_result(query)
				outputChatBox("You set " .. targetPlayerName .. "'s Admin rank to " .. rank .. ".", thePlayer, 0, 255, 0)
				
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				
				-- Fix for scoreboard & nametags
				local targetAdminTitle = exports.global:getPlayerAdminTitle(targetPlayer)
				if (rank>0) or (rank==-999999999) then
					setElementData(targetPlayer, "adminduty", 1)
				else
					setElementData(targetPlayer, "adminduty", 0)
				end
				mysql_free_result( mysql_query( handler, "UPDATE accounts SET adminduty=" .. getElementData(targetPlayer, "adminduty") .. " WHERE id = " .. getElementData(targetPlayer, "gameaccountid") ) )
				exports.global:updateNametagColor(targetPlayer)
				
				if (hiddenAdmin==0) then
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					outputChatBox(adminTitle .. " " .. username .. " set your admin rank to " .. rank .. ".", targetPlayer, 255, 194, 14)
					exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. username .. " set " .. targetPlayerName .. "'s admin level to " .. rank .. ".")
				else
					outputChatBox("Hidden admin set your admin rank to " .. rank .. ".", targetPlayer, 255, 194, 14)
				end
			end
		end
	end
end
addCommandHandler("makeadmin", makePlayerAdmin, false, false)


----------------------[JAIL]--------------------
function jailPlayer(thePlayer, commandName, who, minutes, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		local minutes = tonumber(minutes)
		if not (who) or not (minutes) or not (...) or (minutes<1) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Minutes(>=1) 999=Perm] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
			local reason = table.concat({...}, " ")
			
			if (targetPlayer) then
				local playerName = getPlayerName(thePlayer)
				local jailTimer = getElementData(targetPlayer, "jailtimer")
				local accountID = getElementData(targetPlayer, "gameaccountid")
				
				if isTimer(jailTimer) then
					killTimer(jailTimer)
				end
				
				if (isPedInVehicle(targetPlayer)) then
					setElementData(targetPlayer, "realinvehicle", 0, false)
					removePedFromVehicle(targetPlayer)
				end
				
				if (minutes>=999) then
					local query = mysql_query(handler, "UPDATE accounts SET adminjail='1', adminjail_time='" .. minutes .. "', adminjail_permanent='1', adminjail_by='" .. playerName .. "', adminjail_reason='" .. mysql_escape_string(handler, reason) .. "' WHERE id='" .. accountID .. "'")
					mysql_free_result(query)
					minutes = "Unlimited"
					setElementData(targetPlayer, "jailtimer", true, false)
				else
					local query = mysql_query(handler, "UPDATE accounts SET adminjail='1', adminjail_time='" .. minutes .. "', adminjail_permanent='0', adminjail_by='" .. playerName .. "', adminjail_reason='" .. mysql_escape_string(handler, reason) .. "' WHERE id='" .. tonumber(accountID) .. "'")
					mysql_free_result(query)
					local theTimer = setTimer(timerUnjailPlayer, 60000, minutes, targetPlayer)
					setElementData(targetPlayer, "jailserved", 0, false)
					setElementData(targetPlayer, "jailtimer", theTimer, false)
				end
				setElementData(targetPlayer, "adminjailed", true)
				setElementData(targetPlayer, "jailreason", reason, false)
				setElementData(targetPlayer, "jailtime", minutes, false)
				setElementData(targetPlayer, "jailadmin", getPlayerName(thePlayer), false)
				
				outputChatBox("You jailed " .. targetPlayerName .. " for " .. minutes .. " Minutes.", thePlayer, 255, 0, 0)
				
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',' .. hiddenAdmin .. ',0,' .. ( minutes == 999 and 0 or minutes ) .. ',"' .. mysql_escape_string(handler, reason) .. '")' )
				if res then
					mysql_free_result( res )
				else
					outputDebugString( mysql_error( handler ) )
				end
				
				if (hiddenAdmin==0) then
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					outputChatBox("AdmJail: " .. adminTitle .. " " .. playerName .. " jailed " .. targetPlayerName .. " for " .. minutes .. " Minutes.", getRootElement(), 255, 0, 0)
					outputChatBox("AdmJail: Reason: " .. reason, getRootElement(), 255, 0, 0)
				else
					outputChatBox("AdmJail: Hidden Admin jailed " .. targetPlayerName .. " for " .. minutes .. " Minutes.", getRootElement(), 255, 0, 0)
					outputChatBox("AdmJail: Reason: " .. reason, getRootElement(), 255, 0, 0)
				end
				setElementDimension(targetPlayer, 65400+getElementData(targetPlayer, "playerid"))
				setElementInterior(targetPlayer, 6)
				setCameraInterior(targetPlayer, 6)
				setElementPosition(targetPlayer, 263.821807, 77.848365, 1001.0390625)
				setPedRotation(targetPlayer, 267.438446)
				
				toggleControl(targetPlayer,'next_weapon',false)
				toggleControl(targetPlayer,'previous_weapon',false)
				toggleControl(targetPlayer,'fire',false)
				toggleControl(targetPlayer,'aim_weapon',false)
				setPedWeaponSlot(targetPlayer,0)
			end
		end
	end
end
addCommandHandler("jail", jailPlayer, false, false)

function timerUnjailPlayer(jailedPlayer)
	if(isElement(jailedPlayer)) then
		local timeServed = getElementData(jailedPlayer, "jailserved")
		local timeLeft = getElementData(jailedPlayer, "jailtime")
		local accountID = getElementData(jailedPlayer, "gameaccountid")
		if (timeServed) then
			setElementData(jailedPlayer, "jailserved", timeServed+1, false)
			local timeLeft = timeLeft - 1
			setElementData(jailedPlayer, "jailtime", timeLeft, false)
		
			if (timeLeft<=0) then
				local query = mysql_query(handler, "UPDATE accounts SET adminjail_time='0', adminjail='0' WHERE id='" .. accountID .. "'")
				mysql_free_result(query)
				removeElementData(jailedPlayer, "jailtimer")
				removeElementData(jailedPlayer, "adminjailed")
				removeElementData(jailedPlayer, "jailreason")
				removeElementData(jailedPlayer, "jailtime")
				removeElementData(jailedPlayer, "jailadmin")
				setElementPosition(jailedPlayer, 1519.7177734375, -1697.8154296875, 13.546875)
				setPedRotation(jailedPlayer, 269.92446899414)
				setElementDimension(jailedPlayer, 0)
				setElementInterior(jailedPlayer, 0)
				setCameraInterior(jailedPlayer, 0)
				toggleControl(jailedPlayer,'next_weapon',true)
				toggleControl(jailedPlayer,'previous_weapon',true)
				toggleControl(jailedPlayer,'fire',true)
				toggleControl(jailedPlayer,'aim_weapon',true)
				outputChatBox("Your time has been served, Behave next time!", jailedPlayer, 0, 255, 0)
				
				local gender = getElementData(jailedPlayer, "gender")
				local genderm = "his"
				if (gender == 1) then
					genderm = "her"
				end
				
				exports.global:sendMessageToAdmins("AdmJail: " .. getPlayerName(jailedPlayer) .. " has served " .. genderm .. " jail time.")
				exports.irc:sendMessage("[ADMIN] " .. getPlayerName(jailedPlayer) .. " was unjailed by script (Time Served)")
			else
				local query = mysql_query(handler, "UPDATE accounts SET adminjail_time='" .. timeLeft .. "' WHERE id='" .. accountID .. "'")
				mysql_free_result(query)
			end
		end
	end
end

function unjailPlayer(thePlayer, commandName, who)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (who) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
			
			if (targetPlayer) then
				local jailed = getElementData(targetPlayer, "jailtimer", nil)
				local username = getPlayerName(thePlayer)
				local accountID = getElementData(targetPlayer, "gameaccountid")
				
				if not (jailed) then
					outputChatBox(targetPlayerName .. " is not jailed.", thePlayer, 255, 0, 0)
				else
					local query = mysql_query(handler, "UPDATE accounts SET adminjail_time='0', adminjail='0' WHERE id='" .. accountID .. "'")
					mysql_free_result(query)
					if isTimer(jailed) then
						killTimer(jailed)
					end
					removeElementData(targetPlayer, "jailtimer")
					removeElementData(targetPlayer, "adminjailed")
					removeElementData(targetPlayer, "jailreason")
					removeElementData(targetPlayer, "jailtime")
					removeElementData(targetPlayer, "jailadmin")
					setElementPosition(targetPlayer, 1519.7177734375, -1697.8154296875, 13.546875)
					setPedRotation(targetPlayer, 269.92446899414)
					setElementDimension(targetPlayer, 0)
					setCameraInterior(targetPlayer, 0)
					setElementInterior(targetPlayer, 0)
					toggleControl(targetPlayer,'next_weapon',true)
					toggleControl(targetPlayer,'previous_weapon',true)
					toggleControl(targetPlayer,'fire',true)
					toggleControl(targetPlayer,'aim_weapon',true)
					outputChatBox("You were unjailed by " .. username .. ", Behave next time!", targetPlayer, 0, 255, 0)
					exports.global:sendMessageToAdmins("AdmJail: " .. targetPlayerName .. " was unjailed by " .. username .. ".")
					exports.irc:sendMessage("[ADMIN] " .. targetPlayerName .. " was unjailed by " .. username .. ".")
				end
			end
		end
	end
end
addCommandHandler("unjail", unjailPlayer, false, false)

function jailedPlayers(thePlayer, commandName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		outputChatBox("~~~~~~~~~ Jailed ~~~~~~~~~", thePlayer, 255, 194, 15)
		
		local players = exports.pool:getPoolElementsByType("player")
		local count = 0
		for key, value in ipairs(players) do
			if getElementData(value, "adminjailed") then
				outputChatBox("[JAIL] " .. getPlayerName(value) .. ", jailed by " .. tostring(getElementData(value, "jailadmin")) .. ", served " .. tostring(getElementData(value, "jailserved")) .. " minutes, " .. tostring(getElementData(value,"jailtime")) .. " minutes left", thePlayer, 255, 194, 15)
				outputChatBox("[JAIL] Reason: " .. tostring(getElementData(value, "jailreason")), thePlayer, 255, 194, 15)
				count = count + 1
			elseif getElementData(value, "pd.jailtimer") then
				outputChatBox("[ARREST] " .. getPlayerName(value) .. ", served " .. tostring(getElementData(value, "pd.jailserved")) .. " minutes, " .. tostring(getElementData(value, "pd.jailtime")) .. " minutes left", thePlayer, 0, 102, 255)
				count = count + 1
			end
		end
		
		if count == 0 then
			outputChatBox("There is noone jailed.", thePlayer, 255, 194, 15)
		end
	end
end

addCommandHandler("jailed", jailedPlayers, false, false)

----------------------------[GO TO PLAYER]---------------------------------------
function gotoPlayer(thePlayer, commandName, target)
	if (exports.global:isPlayerAdmin(thePlayer)) then
	
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
				else
					local x, y, z = getElementPosition(targetPlayer)
					local interior = getElementInterior(targetPlayer)
					local dimension = getElementDimension(targetPlayer)
					local r = getPedRotation(targetPlayer)
					
					-- Maths calculations to stop the player being stuck in the target
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )
					
					setCameraInterior(thePlayer, interior)
					
					if (isPedInVehicle(thePlayer)) then
						local veh = getPedOccupiedVehicle(thePlayer)
						setVehicleTurnVelocity(veh, 0, 0, 0)
                        setElementInterior(thePlayer, interior)
                        setElementDimension(thePlayer, dimension)
                        setElementInterior(veh, interior)
                        setElementDimension(veh, dimension)
                        setElementPosition(veh, x, y, z + 1)
                        warpPedIntoVehicle ( thePlayer, veh ) 
						setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
					else
						setElementPosition(thePlayer, x, y, z)
						setElementInterior(thePlayer, interior)
						setElementDimension(thePlayer, dimension)
					end
					outputChatBox(" You have teleported to player " .. targetPlayerName .. ".", thePlayer)
					outputChatBox(" An admin " .. username .. " has teleported to you. ", targetPlayer)
				end
			end
		end
	end
end
addCommandHandler("goto", gotoPlayer, false, false)

--[[function getPlayer(thePlayer, commandName, from, to)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if(not from or not to) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Sending Player] [To Player]", thePlayer, 255, 194, 14)
		else
			local admin = getPlayerName(thePlayer):gsub("_"," ")
			local fromplayer, targetPlayerName1 = exports.global:findPlayerByPartialNick(thePlayer, from)
			local toplayer, targetPlayerName2 = exports.global:findPlayerByPartialNick(thePlayer, to)
			
			if(fromplayer and toplayer) then
				local logged1 = getElementData(fromplayer, "loggedin")
				local logged2 = getElementData(toplayer, "loggedin")
				
				if(not logged1 or not logged2) then
					outputChatBox("At least one of the players is not logged in.", thePlayer, 255, 0 , 0)
				else
					local x, y, z = getElementPosition(toplayer)
					local interior = getElementInterior(toplayer)
					local dimension = getElementDimension(toplayer)
					local r = getPedRotation(toplayer)
					
					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(fromplayer)) then
						local veh = getPedOccupiedVehicle(fromplayer)
						setVehicleTurnVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)
						
					else
						setElementPosition(fromplayer, x, y, z)
						setElementInterior(fromplayer, interior)
						setElementDimension(fromplayer, dimension)
					end
					
					outputChatBox(" You have teleported player " .. targetPlayerName1:gsub("_"," ") .. " to " .. targetPlayerName2:gsub("_"," ") .. ".", thePlayer)
					outputChatBox(" An admin " .. admin .. " has teleported you to " .. targetPlayerName2:gsub("_"," ") .. ". ", fromplayer)
					outputChatBox(" An admin " .. admin .. " has teleported " .. targetPlayerName1:gsub("_"," ") .. " to you.", toplayer)
				end
			end
		end
	end
end
addCommandHandler("sendto", getPlayer, false, false)--]]

function utp(thePlayer, commandName, from, to)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if (not from or not to) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Sending Player/Car] [To Player/Car]", thePlayer, 255, 194, 14)
		else
			--checking if it is an player or car
			local first, targetPlayerName1 = exports.global:findPlayerByPartialNick(thePlayer, from)
			local second, targetPlayerName2 = exports.global:findPlayerByPartialNick(thePlayer, to)
			if (first and not second) then
				local logged = getElementData(first, "loggedin")
				if (logged==1) then
					local veh = exports.pool:getElement("vehicle", tonumber(to))
					if (veh) then
						local rx, ry, rz = getVehicleRotation(veh)
						local x, y, z = getElementPosition(veh)
						x = x + ( ( math.cos ( math.rad ( rz ) ) ) * 5 )
						y = y + ( ( math.sin ( math.rad ( rz ) ) ) * 5 )
						
						setElementPosition(first, x, y, z)
						setPedRotation(first, rz)
						setElementInterior(first, getElementInterior(veh))
						setElementDimension(first, getElementDimension(veh))
						
						local username = getPlayerName(thePlayer)
						outputChatBox(targetPlayerName1:gsub("_"," ") .. " was teleported to the vehicles location.", thePlayer, 255, 194, 14)
						outputChatBox("Admin " .. username:gsub("_"," ") .. " has teleported you to the vehicles location.", first, 255, 194, 14)
					else
						outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				end
			elseif (second and not first) then
				local logged = getElementData(second, "loggedin")
				if (logged==1) then
					local veh = exports.pool:getElement("vehicle", tonumber(from))
					if (veh) then
						local rx, ry, rz = getVehicleRotation(veh)
						local x, y, z = getElementPosition(veh)
						x = x + ( ( math.cos ( math.rad ( rz ) ) ) * 5 )
						y = y + ( ( math.sin ( math.rad ( rz ) ) ) * 5 )
						
						setVehicleTurnVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)
						
						local username = getPlayerName(thePlayer)
						outputChatBox("The vehicle was teleported to " .. targetPlayerName1:gsub("_"," ") .. " location.", thePlayer, 255, 194, 14)
						outputChatBox("Admin " .. username:gsub("_"," ") .. " has teleported the vehicle to your location.", second, 255, 194, 14)
					else
						outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)				
				end
			elseif (first and second) then
				local logged1 = getElementData(first, "loggedin")
				local logged2 = getElementData(second, "loggedin")
				
				if (not logged1 or not logged2) then
					outputChatBox("At least one of the players is not logged in.", thePlayer, 255, 0 , 0)
				else
					local x, y, z = getElementPosition(second)
					local interior = getElementInterior(second)
					local dimension = getElementDimension(second)
					local r = getPedRotation(second)
					
					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(first)) then
						local veh = getPedOccupiedVehicle(first)
						setVehicleTurnVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)
						
					else
						setElementPosition(first, x, y, z)
						setElementInterior(first, interior)
						setElementDimension(first, dimension)
					end
					local username = getPlayerName(thePlayer)
					outputChatBox(" You have teleported player " .. targetPlayerName1:gsub("_"," ") .. " to " .. targetPlayerName2:gsub("_"," ") .. ".", thePlayer)
					outputChatBox(" An admin " .. username:gsub("_"," ") .. " has teleported you to " .. targetPlayerName2:gsub("_"," ") .. ". ", first)
					outputChatBox(" An admin " .. username:gsub("_"," ") .. " has teleported " .. targetPlayerName1:gsub("_"," ") .. " to you.", second)
				end
			end
		end
	end
end
addCommandHandler("sendto", utp, false, false)

----------------------------[GET PLAYER HERE]---------------------------------------
function getPlayer(thePlayer, commandName, target)
	if (exports.global:isPlayerAdmin(thePlayer)) then
	
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " /gethere [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
				else
					local x, y, z = getElementPosition(thePlayer)
					local interior = getElementInterior(thePlayer)
					local dimension = getElementDimension(thePlayer)
					local r = getPedRotation(thePlayer)
					setCameraInterior(targetPlayer, interior)
					
					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )
					
					if (isPedInVehicle(targetPlayer)) then
						local veh = getPedOccupiedVehicle(targetPlayer)
						setVehicleTurnVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)
						
					else
						setElementPosition(targetPlayer, x, y, z)
						setElementInterior(targetPlayer, interior)
						setElementDimension(targetPlayer, dimension)
					end
					outputChatBox(" You have teleported player " .. targetPlayerName .. " to you.", thePlayer)
					outputChatBox(" An admin " .. username .. " has teleported you to them. ", targetPlayer)
				end
			end
		end
	end
end
addCommandHandler("gethere", getPlayer, false, false)

function setMoney(thePlayer, commandName, target, money)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Money]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
			if targetPlayer then
				exports.logs:logMessage("[SET] " .. getPlayerName(thePlayer):gsub("_", " ") .. " set " .. targetPlayerName .. "'s money to $" .. money, 23)
				exports.global:setMoney(targetPlayer, money)
				outputChatBox(targetPlayerName .. " now has " .. money .. " $.", thePlayer)
				outputChatBox("Admin " .. username .. " set your money to " .. money .. " $.", targetPlayer)
			end
		end
	end
end
addCommandHandler("setmoney", setMoney, false, false)

function giveMoney(thePlayer, commandName, target, money)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Money]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
			if targetPlayer then
				exports.logs:logMessage("[GIVE] " .. getPlayerName(thePlayer):gsub("_", " ") .. " gave " .. targetPlayerName .. " to $" .. money, 23)
				exports.global:giveMoney(targetPlayer, money)
				outputChatBox("You have given " .. targetPlayerName .. " $" .. money .. ".", thePlayer)
				outputChatBox("Admin " .. username .. " has given you $" .. money .. ".", targetPlayer)
			end
		end
	end
end
addCommandHandler("givemoney", giveMoney, false, false)

-----------------------------------[FREEZE]----------------------------------
function freezePlayer(thePlayer, commandName, target)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local veh = getPedOccupiedVehicle( targetPlayer )
				if (veh) then
					setVehicleFrozen(veh, true)
					toggleAllControls(targetPlayer, false, true, false)
					outputChatBox(" You have been frozen by an admin. Take care when following instructions.", targetPlayer)
					outputChatBox(" You have frozen " ..targetPlayerName.. ".", thePlayer)
				else	
					toggleAllControls(targetPlayer, false, true, false)
					setPedWeaponSlot(targetPlayer, 0)
					setElementData(targetPlayer, "freeze", 1)
					outputChatBox(" You have been frozen by an admin. Take care when following instructions.", targetPlayer)
					outputChatBox(" You have frozen " ..targetPlayerName.. ".", thePlayer)
				end
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer)
				exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. username .. " froze " .. targetPlayerName .. ".")
			end
		end
	end
end
addCommandHandler("freeze", freezePlayer, false, false)
addEvent("remoteFreezePlayer", true )
addEventHandler("remoteFreezePlayer", getRootElement(), freezePlayer)

-----------------------------------[UNFREEZE]----------------------------------
function unfreezePlayer(thePlayer, commandName, target)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " /unfreeze [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local veh = getPedOccupiedVehicle( targetPlayer )
				if (veh) then
					setVehicleFrozen(veh, false)
					toggleAllControls(targetPlayer, true, true, true)
					
					if (isElement(targetPlayer)) then
						outputChatBox(" You have been unfrozen by an admin. Thanks for your co-operation.", targetPlayer)
					end
					
					if (isElement(thePlayer)) then
						outputChatBox(" You have unfrozen " ..targetPlayerName.. ".", thePlayer)
					end
				else	
					toggleAllControls(targetPlayer, true, true, true)
					
					-- Disable weapon scrolling if restrained
					if getElementData(targetPlayer, "restrain") == 1 then
						setPedWeaponSlot(targetPlayer, 0)
						toggleControl(targetPlayer, "next_weapon", false)
						toggleControl(targetPlayer, "previous_weapon", false)
					end
					removeElementData(targetPlayer, "freeze")
					outputChatBox(" You have been unfrozen by an admin. Thanks for your co-operation.", targetPlayer)
					outputChatBox(" You have unfrozen " ..targetPlayerName.. ".", thePlayer)
				end
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer)
				exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. username .. " unfroze " .. targetPlayerName .. ".")
			end
		end
	end
end
addCommandHandler("unfreeze", unfreezePlayer, false, false)

------------- [Mark and /gotomark ] commands

function markPosition(thePlayer, command)
	
	local logged = getElementData ( thePlayer, "loggedin" )
	if ( logged == 1) then
		if (exports.global:isPlayerAdmin(thePlayer)) then
		
			local x, y, z = getElementPosition(thePlayer)
			local interior = getElementInterior(thePlayer)
			local dimension= getElementDimension(thePlayer)
			
			setElementData(thePlayer, "tempMark.x", x, false)
			setElementData(thePlayer, "tempMark.y", y, false)
			setElementData(thePlayer, "tempMark.z", z, false)
			setElementData(thePlayer, "tempMark.interior", interior, false)
			setElementData(thePlayer, "tempMark.dimension", dimension, false)
						
			outputChatBox("Mark set sucessfull.", thePlayer, 0, 255, 0, true)
		
		else
			 outputChatBox( " You are not an admin and are not authorised to use that command.", thePlayer, 255, 0,0, true )
		end
	end
end
addCommandHandler ( "mark", markPosition , false, false)


function gotoMark(thePlayer, command)

	local logged = getElementData ( thePlayer, "loggedin" )
	if ( logged == 1) then
		if (exports.global:isPlayerAdmin(thePlayer)) then
		
			if(getElementData(thePlayer, "tempMark.x") )then
			
				fadeCamera ( thePlayer, false, 1,0,0,0 )
				
				setTimer(function()
				
					local vehicle = nil
					local seat = nil
				
					if(isPedInVehicle ( thePlayer )) then
						 vehicle =  getPedOccupiedVehicle ( thePlayer )
						seat = getPedOccupiedVehicleSeat ( thePlayer )
					end
					
					if(vehicle and (seat ~= 0)) then
						removePedFromVehicle (thePlayer )
						setElementData(thePlayer, "realinvehicle", 0, false)
						setElementPosition(thePlayer, tonumber(getElementData(thePlayer, "tempMark.x")),tonumber(getElementData(thePlayer, "tempMark.y")),tonumber(getElementData(thePlayer, "tempMark.z")))
						setElementInterior(thePlayer, getElementData(thePlayer, "tempMark.interior"))
						setElementDimension(thePlayer, getElementData(thePlayer, "tempMark.dimension"))
					elseif(vehicle and seat == 0) then
						removePedFromVehicle (thePlayer )
						setElementData(thePlayer, "realinvehicle", 0, false)
						setElementPosition(vehicle, tonumber(getElementData(thePlayer, "tempMark.x")),tonumber(getElementData(thePlayer, "tempMark.y")),tonumber(getElementData(thePlayer, "tempMark.z")))
						setElementInterior(vehicle, getElementData(thePlayer, "tempMark.interior"))
						setElementDimension(vehicle, getElementData(thePlayer, "tempMark.dimension"))
						warpPedIntoVehicle ( thePlayer, vehicle, 0)
					else
						setElementPosition(thePlayer, tonumber(getElementData(thePlayer, "tempMark.x")),tonumber(getElementData(thePlayer, "tempMark.y")),tonumber(getElementData(thePlayer, "tempMark.z")))
						setElementInterior(thePlayer, getElementData(thePlayer, "tempMark.interior"))
						setElementDimension(thePlayer, getElementData(thePlayer, "tempMark.dimension"))
					end
					

					
					setTimer(fadeCamera, 1000, 1, thePlayer, true, 1)
				end, 1000, 1)
			
			else
				outputChatBox( "You need to set a position with /mark first.", thePlayer, 255, 0,0, true )
			end
		else
			 outputChatBox( " You are not an admin and are not authorised to use that command.", thePlayer, 255, 0,0, true )
		end
	end

end
addCommandHandler ( "gotomark", gotoMark , false, false)

----------------------------[MAKE DONATOR]---------------------------------------
function makePlayerDonator(thePlayer, commandName, target, level)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if (level) then
			level = tonumber(level)
		end
		
		if not (target) or not (level) or (level<0) or (level>7) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Level 0=None, 1=Bronze, 2=Silver, 3=Gold, 4=Platinum, 5=Pearl, 6=Diamond, 7=Godly]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
				else
					local levelString = ""
					local gameaccountID = getElementData(targetPlayer, "gameaccountid")
					
					if (level==0) then
						setElementData(targetPlayer, "donatorlevel", 0)
						local query = mysql_query(handler, "UPDATE accounts SET donator='0' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Non-Donator"
					elseif (level==1) then
						setElementData(targetPlayer, "donatorlevel", 1)
						local query = mysql_query(handler, "UPDATE accounts SET donator='1' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Bronze Donator"
					elseif (level==2) then
						setElementData(targetPlayer, "donatorlevel", 2)
						local query = mysql_query(handler, "UPDATE accounts SET donator='2' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Silver Donator"
					elseif (level==3) then
						setElementData(targetPlayer, "donatorlevel", 3)
						local query = mysql_query(handler, "UPDATE accounts SET donator='3' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Gold Donator"
					elseif (level==4) then
						setElementData(targetPlayer, "donatorlevel", 4)
						local query = mysql_query(handler, "UPDATE accounts SET donator='4' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Platinum Donator"
					elseif (level==5) then
						setElementData(targetPlayer, "donatorlevel", 5)
						local query = mysql_query(handler, "UPDATE accounts SET donator='5' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Pearl Donator"
					elseif (level==6) then
						setElementData(targetPlayer, "donatorlevel", 6)
						local query = mysql_query(handler, "UPDATE accounts SET donator='6' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Diamond Donator"
					elseif (level==7) then
						setElementData(targetPlayer, "donatorlevel", 7)
						local query = mysql_query(handler, "UPDATE accounts SET donator='7' WHERE id='" .. gameaccountID .. "'")
						mysql_free_result(query)
						levelString = "Godly Donator"
					end
					
					if (level>0) then
						exports.global:givePlayerAchievement(targetPlayer, 29)
					end
					outputChatBox("You set " .. targetPlayerName .. " as a " .. levelString .. ".", targetPlayer, 0, 255, 0)
					exports.global:sendMessageToAdmins("AdmCmd: " .. username .. " set " .. targetPlayerName .. " as a " .. levelString .. ".")
					exports.irc:sendMessage("[ADMIN] " .. username .. " set " .. targetPlayerName .. " as a " .. levelString .. ".")
					exports.global:updateNametagColor(targetPlayer)
					exports.logs:logMessage("[/MAKEDONATOR] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." made " .. targetPlayerName .. " a " .. levelString , 4)

				end
			end
		end
	end
end
addCommandHandler("makedonator", makePlayerDonator, false, false)

function adminDuty(thePlayer, commandName)
	if exports.global:isPlayerAdmin(thePlayer) then
		local adminduty = getElementData(thePlayer, "adminduty")
		local username = getPlayerName(thePlayer)
		
		if (adminduty==0) then
			setElementData(thePlayer, "adminduty", 1)
			outputChatBox("You went on admin duty.", thePlayer, 0, 255, 0)
			exports.global:sendMessageToAdmins("AdmDuty: " .. username .. " came on duty.")
		elseif (adminduty==1) then
			setElementData(thePlayer, "adminduty", 0)
			outputChatBox("You went off admin duty.", thePlayer, 255, 0, 0)
			exports.global:sendMessageToAdmins("AdmDuty: " .. username .. " went off duty.")
		end
		mysql_free_result( mysql_query( handler, "UPDATE accounts SET adminduty=" .. getElementData(thePlayer, "adminduty") .. " WHERE id = " .. getElementData(thePlayer, "gameaccountid") ) )
		exports.global:updateNametagColor(thePlayer)
	end
end
addCommandHandler("adminduty", adminDuty, false, false)

----------------------------[SET MOTD]---------------------------------------
function setMOTD(thePlayer, commandName, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: " .. commandName .. " [message]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local query = mysql_query(handler, "UPDATE settings SET value='" .. message .. "' WHERE name='motd'")
			
			if (query) then
				mysql_free_result(query)
				outputChatBox("MOTD set to '" .. message .. "'.", thePlayer, 0, 255, 0)
				exports.logs:logMessage("[/SETMOTD] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." changed the MOTD TO " .. message , 4)
			else
				outputChatBox("Failed to set MOTD.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("setmotd", setMOTD, false, false)

-- GET PLAYER ID
function getPlayerID(thePlayer, commandName, target)
	if not (target) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
	else
		local username = getPlayerName(thePlayer)
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
		
		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==1) then
				local id = getElementData(targetPlayer, "playerid")
				outputChatBox("** " .. targetPlayerName .. "'s ID is " .. id .. ".", thePlayer, 255, 194, 14)
			else
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("getid", getPlayerID, false, false)
addCommandHandler("id", getPlayerID, false, false)

-- EJECT
function ejectPlayer(thePlayer, commandName, target)
	if not (target) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
	else
		if not (isPedInVehicle(thePlayer)) then
			outputChatBox("You are not in a vehicle.", thePlayer, 255, 0, 0)
		else
			local vehicle = getPedOccupiedVehicle(thePlayer)
			local seat = getPedOccupiedVehicleSeat(thePlayer)
			
			if (seat~=0) then
				outputChatBox("You must be the driver to eject.", thePlayer, 255, 0, 0)
			else
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
				
				if not (targetPlayer) then
				elseif (targetPlayer==thePlayer) then
					outputChatBox("You cannot eject yourself.", thePlayer, 255, 0, 0)
				else
					local targetvehicle = getPedOccupiedVehicle(targetPlayer)
					
					if targetvehicle~=vehicle and not exports.global:isPlayerAdmin(thePlayer) then
						outputChatBox("This player is not in your vehicle.", thePlayer, 255, 0, 0)
					else
						outputChatBox("You have thrown " .. targetPlayerName .. " out of your vehicle.", thePlayer, 0, 255, 0)
						removePedFromVehicle(targetPlayer)
						setElementData(targetPlayer, "realinvehicle", 0, false)
					end
				end
			end
		end
	end
end
addCommandHandler("eject", ejectPlayer, false, false)

-- WARNINGS
function warnPlayer(thePlayer, commandName, targetPlayer, ...)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				local playerName = getPlayerName(thePlayer)
				local warns = getElementData(targetPlayer, "warns")
				reason = table.concat({...}, " ")
				warns = warns + 1
				local accountID = getElementData(targetPlayer, "gameaccountid")
				mysql_free_result( mysql_query( handler, "UPDATE accounts SET warns=" .. warns .. " WHERE id = " .. accountID ) )
				outputChatBox("You have given " .. targetPlayerName .. " a warning. (" .. warns .. "/3).", thePlayer, 255, 0, 0)
				outputChatBox("You have been given a warning by " .. getPlayerName(thePlayer) .. ".", targetPlayer, 255, 0, 0)
				outputChatBox("Reason: " .. reason, targetPlayer, 255, 0, 0)
				
				setElementData(targetPlayer, "warns", warns, false)
				
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',' .. hiddenAdmin .. ',4,0,"' .. mysql_escape_string(handler, reason) .. '")' )
				if res then
					mysql_free_result( res )
				else
					outputDebugString( mysql_error( handler ) )
				end
				if (hiddenAdmin==0) then
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					outputChatBox("AdmWarn: " .. adminTitle .. " " .. playerName .. " warned " .. targetPlayerName .. ". (" .. warns .. "/3)", getRootElement(), 255, 0, 51)
				end
				
				if (warns>=3) then
					local res = mysql_query( handler, 'INSERT INTO adminhistory (user_char, user, admin_char, admin, hiddenadmin, action, duration, reason) VALUES ("' .. mysql_escape_string(handler, getPlayerName(targetPlayer)) .. '",' .. tostring(getElementData(targetPlayer, "gameaccountid") or 0) .. ',"' .. mysql_escape_string(handler, getPlayerName(thePlayer)) .. '",' .. tostring(getElementData(thePlayer, "gameaccountid") or 0) .. ',' .. hiddenAdmin .. ',5,0,"' .. warns .. ' Admin Warnings")' )
					if res then
						mysql_free_result( res )
					else
						outputDebugString( mysql_error( handler ) )
					end
					
					banPlayer(targetPlayer, true, false, false, thePlayer, "Received " .. warns .. " admin warnings.", 0)
					outputChatBox("AdmWarn: " .. targetPlayerName .. " was banned for several admin warnings.", getRootElement(), 255, 0, 51)
					
					local query = mysql_query(handler, "UPDATE accounts SET banned='1', banned_reason='3 Admin Warnings', banned_by='Warn System' WHERE id='" .. accountID .. "'")
					mysql_free_result(query)
				end
			end
		end
	end
end
addCommandHandler("warn", warnPlayer, false, false)

-- recon fix for interior changing
function interiorChanged()
	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		if isElement(value) then
			local cameraTarget = getCameraTarget(value)
			if (cameraTarget) then
				if (cameraTarget==source) then
					local interior = getElementInterior(source)
					local dimension = getElementDimension(source)
					setCameraInterior(value, interior)
					setElementInterior(value, interior)
					setElementDimension(value, dimension)
				end
			end
		end
	end
end
addEventHandler("onPlayerInteriorChange", getRootElement(), interiorChanged)

-- stop recon on quit of the player
function removeReconning()
	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		if isElement(value) then
			local cameraTarget = getCameraTarget(value)
			if (cameraTarget) then
				if (cameraTarget==source) then
					executeCommandHandler("recon", source)
				end
			end
		end
	end
end
addEventHandler("onPlayerQuit", getRootElement(), removeReconning)

-- FREECAM
function toggleFreecam(thePlayer)
    if exports.global:isPlayerAdmin(thePlayer) then
        local enabled = exports.freecam:isPlayerFreecamEnabled (thePlayer)
        
        if (enabled) then
            removeElementData(thePlayer, "reconx")
            setElementAlpha(thePlayer, 255)
            setPedFrozen(thePlayer, false)
            exports.freecam:setPlayerFreecamDisabled (thePlayer)
        else
			removePedFromVehicle(thePlayer)
            setElementData(thePlayer, "reconx", 0)
            setElementAlpha(thePlayer, 0)
            setPedFrozen(thePlayer, true)
            exports.freecam:setPlayerFreecamEnabled (thePlayer)
        end
    end
end
addCommandHandler("freecam", toggleFreecam)

-- DROP ME

function dropOffFreecam(thePlayer)
	if exports.global:isPlayerAdmin(thePlayer) then
		local enabled = exports.freecam:isPlayerFreecamEnabled (thePlayer)
		if (enabled) then
			local x, y, z = getElementPosition(thePlayer)
			removeElementData(thePlayer, "reconx")
			setElementAlpha(thePlayer, 255)
			setPedFrozen(thePlayer, false)
			exports.freecam:setPlayerFreecamDisabled (thePlayer)
			setElementPosition(thePlayer, x, y, z)
		else
			outputChatBox("This command only works while freecam is on.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("dropme", dropOffFreecam)

-- DISAPPEAR

function toggleInvisibility(thePlayer)
	if exports.global:isPlayerAdmin(thePlayer) then
		local enabled = getElementData(thePlayer, "invisible")
		if (enabled == true) then
			setElementAlpha(thePlayer, 255)
			setElementData(thePlayer, "reconx", false)
			outputChatBox("You are now visible.", thePlayer, 255, 0, 0)
			setElementData(thePlayer, "invisible", false)
		else
			setElementAlpha(thePlayer, 0)
			setElementData(thePlayer, "reconx", true)
			outputChatBox("You are now invisible.", thePlayer, 0, 255, 0)
			setElementData(thePlayer, "invisible", true)
		end
	end
end
addCommandHandler("disappear", toggleInvisibility)

					
-- TOGGLE NAMETAG

function toggleMyNametag(thePlayer)
	local visible = getElementData(thePlayer, "reconx")
	if exports.global:isPlayerAdmin(thePlayer) then
		if (visible == true) then
			setPlayerNametagShowing(thePlayer, false)
			setElementData(thePlayer, "reconx", false)
			outputChatBox("Your nametag is now visible.", thePlayer, 255, 0, 0)
		else
			setPlayerNametagShowing(thePlayer, false)
			setElementData(thePlayer, "reconx", true)
			outputChatBox("Your nametag is now hidden.", thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("togmytag", toggleMyNametag)

-- RESET CHARACTER
function resetCharacter(thePlayer, commandName, ...)
	if exports.global:isPlayerLeadAdmin(thePlayer) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [exact character name]", thePlayer, 255, 0, 0)
		else
			local character = table.concat({...}, "_")
			if getPlayerFromName(character) then
				kickPlayer(getPlayerFromName(character), "Character Reset")
			end
				
			local result = mysql_query(handler, "SELECT id, account FROM characters WHERE charactername='" .. mysql_escape_string(handler, character) .. "'")
			local charid = tonumber(mysql_result(result, 1, 1))
			local account = tonumber(mysql_result(result, 1, 2))
			mysql_free_result(result)
			
			if charid and account ~= 1500 then
				-- delete all in-game vehicles
				for key, value in pairs( getElementsByType( "vehicle" ) ) do
					if isElement( value ) then
						if getElementData( value, "owner" ) == charid then
							call( getResourceFromName( "item-system" ), "deleteAll", 3, getElementData( value, "dbid" ) )
							destroyElement( value )
						end
					end
				end
				mysql_free_result( mysql_query(handler, "DELETE FROM vehicles WHERE owner = " .. charid ) )
				
				-- un-rent all interiors
				local old = getElementData( thePlayer, "dbid" )
				setElementData( thePlayer, "dbid", charid )
				local result = mysql_query( handler, "SELECT id FROM interiors WHERE owner = " .. charid .. " AND type != 2" )
				if result then
					for result, row in mysql_rows( result ) do
						local id = tonumber(row[1])
						call( getResourceFromName( "interior-system" ), "publicSellProperty", thePlayer, id, false, false )
					end
				end
				setElementData( thePlayer, "dbid", old )
				
				-- get rid of all items, give him default items back
				mysql_free_result( mysql_query(handler, "DELETE FROM items WHERE type = 1 AND owner = " .. charid ) )
				
				-- get the skin
				local skin = 264
				local skinr = mysql_query(handler, "SELECT skin FROM characters WHERE id = " .. charid )
				if skinr then
					skin = tonumber(mysql_result(skinr, 1, 1)) or 264
					mysql_free_result(skinr)
				end
				
				mysql_free_result( mysql_query(handler, "INSERT INTO items (type, owner, itemID, itemValue) VALUES (1, " .. charid .. ", 16, " .. skin .. ")" ) )
				mysql_free_result( mysql_query(handler, "INSERT INTO items (type, owner, itemID, itemValue) VALUES (1, " .. charid .. ", 17, 1)" ) )
				mysql_free_result( mysql_query(handler, "INSERT INTO items (type, owner, itemID, itemValue) VALUES (1, " .. charid .. ", 18, 1)" ) )
				
				-- delete wiretransfers
				mysql_free_result( mysql_query(handler, "DELETE FROM wiretransfers WHERE `from` = " .. charid .. " OR `to` = " .. charid ) )
				
				-- set spawn at unity, strip off money etc
				mysql_free_result( mysql_query(handler, "UPDATE characters SET x=1742.1884765625, y=-1861.3564453125, z=13.577615737915, rotation=0, faction_id=-1, faction_rank=0, faction_leader=0, weapons='', ammo='', car_license=0, gun_license=0, hoursplayed=0, timeinserver=0, transport=1, lastarea='El Corona', lang1=1, lang1skill=100, lang2=0, lang2skill=0, lang3=0, lang3skill=0, currLang=1, money=250, bankmoney=500, interior_id=0, dimension_id=0, health=100, armor=0, radiochannel=100, fightstyle=0, pdjail=0, pdjail_time=0, restrainedobj=0, restrainedby=0, hunter=0, stevie=0, tyrese=0, rook=0, fish=0, truckingruns=0, truckingwage=0, blindfold=0, phoneoff=0 WHERE id = " .. charid ) )
				
				outputChatBox("You stripped " .. character .. " off their possession.", thePlayer, 0, 255, 0)
				if (getElementData(thePlayer, "hiddenadmin")==0) then
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " has reset " .. character .. ".")
				end
				
				exports.logs:logMessage("[/RESETCHARACTER] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." did this on ".. character , 4)

			else
				outputChatBox("Couldn't find " .. character, thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("resetcharacter", resetCharacter)

-- FIND ALT CHARS
local function showAlts(thePlayer, id)
	result = mysql_query( handler, "SELECT charactername, cked, faction_id FROM characters WHERE account = " .. id )
	if result then
		local name = mysql_query( handler, "SELECT username FROM accounts WHERE id = " .. id )
		if name then
			local uname = mysql_result( name, 1, 1 )
			if uname and uname ~= mysql_null() then
				outputChatBox( "~-~-~-~-~-~ " .. uname .. " ~-~-~-~-~-~", thePlayer, 255, 194, 14 )
			else
				outputChatBox( " ", thePlayer )
			end
			mysql_free_result( name )
		else
			outputChatBox( " ", thePlayer )
		end
		local count = 0
		for result, row in mysql_rows( result ) do
			count = count + 1
			local r = 255
			if getPlayerFromName( row[1] ) then
				r = 0
			end
			
			local text = "#" .. count .. ": " .. row[1]:gsub("_", " ")
			if tonumber( row[2] ) == 1 then
				text = text .. " (Missing)"
			elseif tonumber( row[2] ) == 2 then
				text = text .. " (Buried)"
			end
			
			local faction = tonumber( row[3] ) or 0
			if faction > 0 then
				local theTeam = exports.pool:getElement("team", faction)
				if theTeam then
					text = text .. " - " .. getTeamName( theTeam )
				end
			end
			
			outputChatBox( text, thePlayer, r, 255, 0)
		end
		mysql_free_result( result )
	else
		outputChatBox( "Error #9100 - Report on Forums", thePlayer, 255, 0, 0)
		outputDebugString( mysql_error( handler ) )
	end
end

function findAltChars(thePlayer, commandName, ...)
	if exports.global:isPlayerAdmin( thePlayer ) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({...}, "_")
			local targetPlayer = exports.global:findPlayerByPartialNick(nil, targetPlayerName)
			
			if not targetPlayer or getElementData( targetPlayer, "loggedin" ) ~= 1 then
				-- select by character name
				local result = mysql_query( handler, "SELECT account FROM characters WHERE charactername = '" .. mysql_escape_string( handler, targetPlayerName ) .. "'" )
				if result then
					if mysql_num_rows( result ) == 1 then
						local id = tonumber( mysql_result( result, 1, 1 ) ) or 0
						showAlts( thePlayer, id )
						return
					else
						-- select by account name
						local result2 = mysql_query( handler, "SELECT id FROM accounts WHERE username = '" .. mysql_escape_string( handler, targetPlayerName ) .. "'" )
						if result2 then
							if mysql_num_rows( result2 ) == 1 then
								local id = tonumber( mysql_result( result2, 1, 1 ) ) or 0
								showAlts( thePlayer, id )
								return
							end
							mysql_free_result( result2 )
						end
					end
					mysql_free_result( result )
				end
				outputChatBox("Player not found or multiple were found.", thePlayer, 255, 0, 0)
			else
				local id = getElementData( targetPlayer, "gameaccountid" )
				if id then
					showAlts( thePlayer, id )
				else
					outputChatBox("Game Account is unknown.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler( "findalts", findAltChars )

--give player license
function givePlayerLicense(thePlayer, commandName, targetPlayerName, licenseType)
	if exports.global:isPlayerAdmin(thePlayer) then
		if not targetPlayerName or not (licenseType and (licenseType == "1" or licenseType == "2")) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Type]", thePlayer, 255, 194, 14)
			outputChatBox("Type 1 = Driver", thePlayer, 255, 194, 14)
			outputChatBox("Type 2 = Weapon", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					local licenseTypeOutput = licenseType == "1" and "driver" or "weapon"
					licenseType = licenseType == "1" and "car" or "gun"
					if getElementData(targetPlayer, "license."..licenseType) == 1 then
						outputChatBox(getPlayerName(thePlayer).." has already a "..licenseTypeOutput.." license.", thePlayer, 255, 255, 0)
					else
						setElementData(targetPlayer, "license."..licenseType, 1)
						local query = mysql_query(handler, "UPDATE characters SET "..licenseType.."_license='1' WHERE id = "..getElementData(targetPlayer, "dbid").." LIMIT 1")
						mysql_free_result(query)
						outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
						outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
						exports.logs:logMessage("[/GIVELICENSE] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." gave ".. targetPlayerName .." the following license:"..licenseTypeOutput, 4)
					end
				end
			end
		end
	end
end
addCommandHandler("givelicense", givePlayerLicense)

-- Language commands
function getLanguageByName( language )
	for i = 1, call( getResourceFromName( "language-system" ), "getLanguageCount" ) do
		if language:lower() == call( getResourceFromName( "language-system" ), "getLanguageName", i ):lower() then
			return i
		end
	end
	return false
end

function setLanguage(thePlayer, commandName, targetPlayerName, language, skill)
	if exports.global:isPlayerAdmin(thePlayer) then
		if not targetPlayerName or not language or not tonumber( skill ) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Language] [Skill]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			if not targetPlayer then	
			elseif getElementData( targetPlayer, "loggedin" ) ~= 1 then
				outputChatBox( "Player is not logged in.", thePlayer, 255, 0, 0 )
			else
				local lang = tonumber( language ) or getLanguageByName( language )
				local skill = tonumber( skill )
				if not lang then
					outputChatBox( language .. " is not a valid Language.", thePlayer, 255, 0, 0 )
				else
					local langname = call( getResourceFromName( "language-system" ), "getLanguageName", lang )
					local success, reason = call( getResourceFromName( "language-system" ), "learnLanguage", targetPlayer, lang, false, skill )
					if success then
						outputChatBox( targetPlayerName .. " learned " .. langname .. ".", thePlayer, 0, 255, 0 )
					else
						outputChatBox( targetPlayerName .. " couldn't learn " .. langname .. ": " .. tostring( reason ), thePlayer, 255, 0, 0 )
					end
					exports.logs:logMessage("[/SETLANGUAGE] " .. getElementData(thePlayer, "gameaccountusername") .. "/".. getPlayerName(thePlayer) .." learned ".. targetPlayerName .. " " .. langname , 4)
				end
			end
		end
	end
end
addCommandHandler("setlanguage", setLanguage)

function deleteLanguage(thePlayer, commandName, targetPlayerName, language)
	if exports.global:isPlayerAdmin(thePlayer) then
		if not targetPlayerName or not language then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Language]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			if not targetPlayer then
			elseif getElementData( targetPlayer, "loggedin" ) ~= 1 then
				outputChatBox( "Player is not logged in.", thePlayer, 255, 0, 0 )
			else
				local lang = tonumber( language ) or getLanguageByName( language )
				if not lang then
					outputChatBox( language .. " is not a valid Language.", thePlayer, 255, 0, 0 )
				else
					local langname = call( getResourceFromName( "language-system" ), "getLanguageName", lang )
					if call( getResourceFromName( "language-system" ), "removeLanguage", targetPlayer, lang ) then
						outputChatBox( targetPlayerName .. " forgot " .. langname .. ".", thePlayer, 0, 255, 0 )
					else
						outputChatBox( targetPlayerName .. " doesn't speak " .. langname, thePlayer, 255, 0, 0 )
					end
				end
			end
		end
	end
end
addCommandHandler("dellanguage", deleteLanguage)

function marry(thePlayer, commandName, player1, player2)
	if exports.global:isPlayerLeadAdmin(thePlayer) then
		if not player1 or not player2 then
			outputChatBox( "SYNTAX: /" .. commandName .. " [player] [player]", thePlayer, 255, 194, 14 )
		else
			local player1, player1name = exports.global:findPlayerByPartialNick( thePlayer, player1 )
			if player1 then
				local player2, player2name = exports.global:findPlayerByPartialNick( thePlayer, player2 )
				if player2 then
					-- check if one of the players is already married
					local p1r = mysql_query( handler, "SELECT COUNT(*) FROM characters WHERE marriedto = " .. getElementData( player1, "dbid" ) )
					if p1r then
						if tonumber( mysql_result( p1r, 1, 1 ) ) == 0 then
							local p2r = mysql_query( handler, "SELECT COUNT(*) FROM characters WHERE marriedto = " .. getElementData( player2, "dbid" ) )
							if p2r then
								if tonumber( mysql_result( p2r, 1, 1 ) ) == 0 then
									mysql_free_result( mysql_query( handler, "UPDATE characters SET marriedto = " .. getElementData( player1, "dbid" ) .. " WHERE id = " .. getElementData( player2, "dbid" ) ) )
									mysql_free_result( mysql_query( handler, "UPDATE characters SET marriedto = " .. getElementData( player2, "dbid" ) .. " WHERE id = " .. getElementData( player1, "dbid" ) ) )
									
									outputChatBox( "You are now married to " .. player2name .. ".", player1, 0, 255, 0 )
									outputChatBox( "You are now married to " .. player1name .. ".", player2, 0, 255, 0 )
									
									exports['vehicle-system']:clearCharacterName( getElementData( player1, "dbid" ) )
									exports['vehicle-system']:clearCharacterName( getElementData( player2, "dbid" ) )
									
									outputChatBox( player1name .. " and " .. player2name .. " are now married.", thePlayer, 255, 194, 14 )
								else
									outputChatBox( player2name .. " is already married.", thePlayer, 255, 0, 0 )
								end
								mysql_free_result( p1r )
							else
								outputDebugString( "p2r: " .. mysql_error( handler ) )
							end
						else
							outputChatBox( player1name .. " is already married.", thePlayer, 255, 0, 0 )
						end
						mysql_free_result( p1r )
					else
						outputDebugString( "p1r: " .. mysql_error( handler ) )
					end
				end
			end
		end
	end
end
addCommandHandler("marry", marry)

function divorce(thePlayer, commandName, targetPlayer)
	if exports.global:isPlayerLeadAdmin(thePlayer) then
		if not targetPlayer then
			outputChatBox( "SYNTAX: /" .. commandName .. " [player]", thePlayer, 255, 194, 14 )
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayer )
			if targetPlayer then
				local marriedto = mysql_query( handler, "SELECT marriedto FROM characters WHERE id = " .. getElementData( targetPlayer, "dbid" ) )
				if marriedto then
					local to = tonumber( mysql_result( marriedto, 1, 1 ) )
					mysql_free_result( marriedto )
					if to > 0 then
						mysql_free_result( mysql_query( handler, "UPDATE characters SET marriedto = 0 WHERE id = " .. getElementData( targetPlayer, "dbid" ) ) )
						mysql_free_result( mysql_query( handler, "UPDATE characters SET marriedto = 0 WHERE marriedto = " .. getElementData( targetPlayer, "dbid" ) ) )
						
						exports['vehicle-system']:clearCharacterName( getElementData( targetPlayer, "dbid" ) )
						exports['vehicle-system']:clearCharacterName( to )
						
						outputChatBox( targetPlayerName .. " is now divorced.", thePlayer, 0, 255, 0 )
					else
						outputChatBox( targetPlayerName .. " is not married to anyone.", thePlayer, 255, 194, 14 )
					end
				else
					outputDebugString( mysql_error( handler ) )
				end
			end
		end
	end
end
addCommandHandler("divorce", divorce)

function vehicleLimit(admin, command, player, limit)
	if exports.global:isPlayerLeadAdmin(admin) then
		if (not player and not limit) then
			outputChatBox("SYNTAX: /" .. command .. " [Player] [Limit]", admin, 255, 194, 14)
		else
			local tplayer, targetPlayerName = exports.global:findPlayerByPartialNick(admin, player)
			if (tplayer) then			
				local query = mysql_query(handler, "SELECT maxvehicles FROM characters WHERE id = " .. getElementData(tplayer, "dbid"))
				if (query) then
					local newl = tonumber(limit)
					if (newl) then
						mysql_free_result(mysql_query(handler, "UPDATE characters SET maxvehicles = '" .. newl .. "' WHERE id = " .. getElementData( tplayer, "dbid" ) ) )
						outputChatBox("You have set " .. targetPlayerName:gsub("_", " ") .. " vehicle limit to " .. newl .. ".", admin, 255, 194, 14)
						outputChatBox("Admin " .. getPlayerName(admin):gsub("_"," ") .. " has set your vehicle limit to " .. newl .. ".", tplayer, 255, 194, 14)
					else
						outputChatBox("nope, newl", admin)
					end
				else
					outputChatBox("nope, query", admin)
					outputDebugString( mysql_error( handler ) )
				end
			end			
		end
	end
end
addCommandHandler("setvehlimit", vehicleLimit)