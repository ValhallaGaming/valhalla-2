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
	if (handler~=nil) then
		mysql_close(handler)
	end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), closeMySQL)
-- ////////////////////////////////////
-- //			MYSQL END			 //
-- ////////////////////////////////////

scriptVer = exports.global:getScriptVersion()

salt = "vgrpkeyscotland"

function sendSalt()
	--local version = nil
	--if (getVersion().type~="Custom" and getVersion().type~="Release") then
	--	version = tonumber(string.sub(getVersion().type, 10, string.len(getVersion().type)))
	--end
	
	triggerClientEvent(source, "sendSalt", source, salt, getPlayerIP(source))
end
addEvent("getSalt", true)
addEventHandler("getSalt", getRootElement(), sendSalt)

function encrypt(str)
	local hash = 0
	for i = 1, string.len(str) do
		hash = hash + tonumber(string.byte(str, i, i))
	end
	
	if (hash==0) then
		return 0
	end
	hash = hash + 100000000
	return hash
end

function encryptSerial(str)
	local hash = md5(str)
	
	local rhash = "VGRP" .. string.sub(hash, 17, 20) .. string.sub(hash, 1, 2) .. string.sub(hash, 25, 26) .. string.sub(hash, 21, 2)
	
	return rhash
end

function resourceStart()
	setGameType("Roleplay")
	setMapName("Valhalla Gaming: Los Santos")
	
	setRuleValue("Script Version", tostring(scriptVer))
	setRuleValue("Author", "VG Scripting Team")

	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		triggerEvent("playerJoinResourceStart", value)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), resourceStart)
	
function onJoin()
	-- Set the user as not logged in, so they can't see chat or use commands
	setElementData(source, "loggedin", 0)
	setElementData(source, "gameaccountloggedin", 0, false)
	setElementData(source, "gameaccountusername", "")
	setElementData(source, "gameaccountid", "")
	setElementData(source, "adminlevel", 0)
	setElementData(source, "hiddenadmin", 0)
	setElementData(source, "globalooc", 1, false)
	setElementData(source, "muted", 0)
	setElementData(source, "loginattempts", 0, false)
	setElementData(source, "timeinserver", 0, false)
	
	setElementDimension(source, 9999)
	setElementInterior(source, 0)

	clearChatBox(source)
	outputChatBox("Server is running Valhalla Gaming MTA RP Script V" .. scriptVer, source)
	outputChatBox("Script by Valhalla Gaming Scripting Team.", source)
	
	exports.global:updateNametagColor(source)
end
addEventHandler("onPlayerJoin", getRootElement(), onJoin)
addEvent("playerJoinResourceStart", false)
addEventHandler("playerJoinResourceStart", getRootElement(), onJoin)

--[[
function registerPlayer(username, password)
	local safeusername = mysql_escape_string(handler, username)
	
	local result = mysql_query(handler, "SELECT username FROM accounts WHERE username='" .. safeusername .. "'")
	
	if (mysql_num_rows(result)>0) then
		outputChatBox("An account with this name already exists. Please select another.", source, 255, 0, 0)
	else
		triggerClientEvent(source, "hideUI", source, true)
		triggerEvent("onPlayerRegister", source, username, password)
		
		-- Get registration time & date
		--local time = getRealTime()
		--local days = time.monthday
		--local months = (time.month+1)
		--local years = (1900+time.year)
				
		local registerdate = days .. "/" .. months .. "/" .. years
		
		
		local ip = getPlayerIP(source)
		
		local country = exports.global:getPlayerCountry(source)
		
		local keysalt1 = "vg"
		local keysalt2 = "securitykey"
		local securitykey = encryptSerial(keysalt1 .. username .. keysalt2)
		
		local result = mysql_query(handler, "INSERT INTO accounts SET username='" .. safeusername .. "', password=MD5('" .. salt .. password .. "'), registerdate=NOW(), lastlogin=NOW(), ip='" .. ip .. "', securitykey='" .. securitykey .. "', country='" .. tostring(country) .. "', friendsmessage='Sample Message'")
		
		if (result) then
			outputChatBox("You have now registered, Thank you for registering.", source, 0, 255, 0)
			outputChatBox(" ", source)
			outputChatBox("Your security key is " .. tostring(securitykey) .. ". Please write this down somewhere safe.", source, 255, 194, 14)
			outputChatBox("You will be asked for this should you forget your password.", source, 255, 194, 14)
			mysql_free_result(result)
		else
			outputChatBox("Error 100000 - Report on forums.", source, 255, 0, 0)
		end
	end
	
	if (result) then
		mysql_free_result(result)
	end
end
addEvent("onPlayerRegister", false)
addEvent("attemptRegister", true)
addEventHandler("attemptRegister", getRootElement(), registerPlayer)
]]

addEvent("restoreJob", false)
function spawnCharacter(charname, version)
	exports.global:takeAllWeapons(source)
	local id = getElementData(source, "gameaccountid")
	charname = string.gsub(tostring(charname), " ", "_")
	
	local safecharname = mysql_escape_string(handler, charname)
	
	local result = mysql_query(handler, "SELECT * FROM characters WHERE charactername='" .. safecharname .. "' AND account='" .. id .. "'")
	
	if (result) then
		local data = mysql_fetch_assoc(result)
		
		local id = tonumber(data["id"])
		local x = tonumber(data["x"])
		local y = tonumber(data["y"])
		local z = tonumber(data["z"])
		
		local rot = tonumber(data["rotation"])
		local interior = tonumber(data["interior_id"])
		local dimension = tonumber(data["dimension_id"])
		local health = tonumber(data["health"])
		local armor = tonumber(data["armor"])
		local skin = tonumber(data["skin"])
		local money = tonumber(data["money"])
		local factionID = tonumber(data["faction_id"])
		local cuffed = tonumber(data["cuffed"])
		local radiochannel = tonumber(data["radiochannel"])
		local masked = tonumber(data["masked"])
		local duty = tonumber(data["duty"])
		local cellnumber = tonumber(data["cellnumber"])
		local fightstyle = tonumber(data["fightstyle"])
		local pdjail = tonumber(data["pdjail"])
		local pdjail_time = tonumber(data["pdjail_time"])
		local pdjail_station = tonumber(data["pdjail_station"])
		local job = tonumber(data["job"])
		local casualskin = tonumber(data["casualskin"])
		local weapons = tostring(data["weapons"])
		local ammo = tostring(data["ammo"])
		local carlicense = tonumber(data["car_license"])
		local gunlicense = tonumber(data["gun_license"])
		local bankmoney = tonumber(data["bankmoney"])
		local fingerprint = tostring(data["fingerprint"])
		local tag = tonumber(data["tag"])
		local hoursplayed = tonumber(data["hoursplayed"])
		local timeinserver = tonumber(data["timeinserver"])
		local restrainedobj = tonumber(data["restrainedobj"])
		local restrainedby = tonumber(data["restrainedby"])
		local factionrank = tonumber(data["faction_rank"])
		local dutyskin = tonumber(data["dutyskin"])
		local phoneoff = tonumber(data["phoneoff"])
		local blindfold = tonumber(data["blindfold"])
		local gender = tonumber(data["gender"])
		local cellphonesecret = tonumber(data["cellphonesecret"])
		local photos = tonumber(data["photos"])
		local maxvehicles = tonumber(data["maxvehicles"])
		local factionleader = tonumber(data["faction_leader"])
		
		local description = data["description"]
		local age = tonumber(data["age"])
		local weight = tonumber(data["weight"])
		local height = tonumber(data["height"])
		local skincolor = tonumber(data["skincolor"])
		setElementData(source, "chardescription", description, false)
		setElementData(source, "age", age, false)
		setElementData(source, "weight", weight, false)
		setElementData(source, "height", height, false)
		setElementData(source, "race", skincolor, false)

		-- LANGUAGES
		local lang1 = tonumber(data["lang1"])
		local lang1skill = tonumber(data["lang1skill"])
		local lang2 = tonumber(data["lang2"])
		local lang2skill = tonumber(data["lang2skill"])
		local lang3 = tonumber(data["lang3"])
		local lang3skill = tonumber(data["lang3skill"])
		local currentLanguage = tonumber(data["currlang"])
		setElementData(source, "languages.current", currentLanguage, false)
				
		if lang1 == 0 then
			lang1skill = 0
		end
		
		if lang2 == 0 then
			lang2skill = 0
		end
		
		if lang3 == 0 then
			lang3skill = 0
		end
		
		setElementData(source, "languages.lang1", lang1, false)
		setElementData(source, "languages.lang1skill", lang1skill, false)
		
		setElementData(source, "languages.lang2", lang2, false)
		setElementData(source, "languages.lang2skill", lang2skill, false)
		
		setElementData(source, "languages.lang3", lang3, false)
		setElementData(source, "languages.lang3skill", lang3skill, false)
		-- END OF LANGUAGES
		
		setElementData(source, "timeinserver", timeinserver, false)
		
		setElementData(source, "dbid", tonumber(id))
		exports['item-system']:loadItems( source, true )
		
		setElementData(source, "loggedin", 1)
		
		-- Check his name isn't in use by a squatter
		local playerWithNick = getPlayerFromName(tostring(charname))
		if isElement(playerWithNick) and (playerWithNick~=source) then
			kickPlayer(playerWithNick, getRootElement(), "Duplicate Session.")
		end
		
		-- casual skin
		setElementData(source, "casualskin", casualskin, false)
		
		-- bleeding
		setElementData(source, "bleeding", 0, false)
		
		-- Set their name to the characters
		setElementData(source, "legitnamechange", 1)
		setPlayerName(source, tostring(charname))
		local pid = getElementData(source, "playerid")
		local fixedName = string.gsub(tostring(charname), "_", " ")

		setPlayerNametagText(source, tostring(fixedName))
		setElementData(source, "legitnamechange", 0)
		
		-- If their an admin change their nametag colour
		local adminlevel = getElementData(source, "adminlevel")
		local hiddenAdmin = getElementData(source, "hiddenadmin")
		local adminduty = getElementData(source, "adminduty")
		local muted = getElementData(source, "muted")
		local donator = getElementData(source, "donator")
		
		-- remove all custom badges
		removeElementData(source, "PDbadge")
		removeElementData(source, "ESbadge")
		removeElementData(source, "GOVbadge")
		removeElementData(source, "SANbadge")
		
		exports.global:updateNametagColor(source)
		setPlayerNametagShowing(source, false)
		
		-- Server message
		exports.irc:sendMessage("[SERVER] Character " .. charname .. " logged in.")
		clearChatBox(source)
		outputChatBox("You are now playing as " .. charname:gsub("_", " ") .. ".", source, 0, 255, 0)
		outputChatBox("Looking for animations? /animlist", source, 255, 194, 14)
		outputChatBox("Need Help? /helpme", source, 255, 194, 14)
		
	
		-- If in bank/prison, freeze them
		if (interior==3) or (x >= 654 and x <= 971 and y >= -3541 and y <= -3205) then
			triggerClientEvent(source, "usedElevator", source)
			setPedFrozen(source, true)
			setPedGravity(source, 0)
		end
		
		-- Load the character info
		spawnPlayer(source, x, y, z, rot, skin)
		
		--if (interior==0) then
			--health = health / 2
		--end
		
		setElementHealth(source, health)
		setPedArmor(source, armor)
		
		
		setElementDimension(source, dimension)
		setElementInterior(source, interior, x, y, z)
		setCameraInterior(source, interior)
		
		local motdresult = mysql_query(handler, "SELECT value FROM settings WHERE name='motd' LIMIT 1")
		local motd = mysql_result(motdresult, 1, 1)
		mysql_free_result(motdresult)
		outputChatBox("MOTD: " .. motd, source, 255, 255, 0)
		
		local timer = getElementData(source, "pd.jailtimer")
		if isTimer(timer) then
			killTimer(timer)
		end
		
		removeElementData(source, "pd.jailserved")
		removeElementData(source, "pd.jailtime")
		removeElementData(source, "pd.jailtimer")
		removeElementData(source, "pd.jailstation")
		
		-- ADMIN JAIL
		local jailed = getElementData(source, "adminjailed")
		local jailed_time = getElementData(source, "jailtime")
		local jailed_by = getElementData(source, "jailadmin")
		local jailed_reason = getElementData(source, "jailreason")
		
		if jailed then
			outputChatBox("You still have " .. jailed_time .. " minute(s) to serve of your admin jail sentance.", source, 255, 0, 0)
			outputChatBox(" ", source)
			outputChatBox("You were jailed by: " .. jailed_by .. ".", source, 255, 0, 0)
			outputChatBox("Reason: " .. jailed_reason, source, 255, 0, 0)
				
			local incVal = getElementData(source, "playerid")
				
			setElementDimension(source, 65400+incVal)
			setElementInterior(source, 6)
			setCameraInterior(source, 6)
			setElementPosition(source, 263.821807, 77.848365, 1001.0390625)
			setPedRotation(source, 267.438446)
			
			if jailed_time ~= 999 then
				local theTimer = setTimer(timerUnjailPlayer, 60000, jailed_time, source)
				setElementData(source, "jailtime", jailed_time, false)
				setElementData(source, "jailtimer", theTimer)
			else
				setElementData(source, "jailtime", "Unlimited", false)
				setElementData(source, "jailtimer", true, false)
			end
			setElementData(source, "jailserved", 0, false)
			setElementData(source, "adminjailed", true)
			setElementData(source, "jailreason", jailed_reason, false)
			setElementData(source, "jailadmin", jailed_by, false)
			
			setElementInterior(source, 6)
			setCameraInterior(source, 6)
		elseif pdjail == 1 then -- PD JAIL
			outputChatBox("You still have " .. pdjail_time .. " minute(s) to serve of your state jail sentance.", source, 255, 0, 0)
			
			local theTimer = setTimer(timerPDUnjailPlayer, 60000, pdjail_time, source)
			setElementData(source, "pd.jailserved", 0, false)
			setElementData(source, "pd.jailtime", pdjail_time, false)
			setElementData(source, "pd.jailtimer", theTimer, false)
			setElementData(source, "pd.jailstation", pdjail_station, false)
		end
		
		-- FACTIONS
		local factionName = nil
		if (factionID~=-1) then
			local fresult = mysql_query(handler, "SELECT name FROM factions WHERE id='" .. factionID .. "'")
			if (mysql_num_rows(fresult)>0) then
				factionName = mysql_result(fresult, 1, 1)
			else
				factionName = "Citizen"
				factionID = -1
				factionleader = 0
				outputChatBox("Your faction has been deleted, and you have been set factionless.", source, 255, 0, 0)
				mysql_query(handler, "UPDATE characters SET faction_id='-1', faction_rank='1' WHERE id='" .. id .. "' LIMIT 1")
			end
			
			if (fresult) then
				mysql_free_result(fresult)
			end
		else
			factionName = "Citizen"
		end
		
		local theTeam = getTeamFromName(tostring(factionName))
		setPlayerTeam(source, theTeam)
		setElementData(source, "factionrank", factionrank)
		setElementData(source, "factionleader", factionleader, false)
		
		if factionID == 1 then
			exports.global:givePlayerAchievement(source, 2)
		elseif factionID == 2 then
			exports.global:givePlayerAchievement(source, 5)
		elseif factionID == 3 then
			exports.global:givePlayerAchievement(source, 6)
		end
		-- END FACTIONS
		
		-- number of friends etc
		local playercount = getPlayerCount()
		local maxplayers = getMaxPlayers()
		local percent = math.ceil((playercount/maxplayers)*100)
		
		local friendsonline = 0
		local friends = mysql_query( handler, "SELECT friend FROM friends WHERE id = " .. getElementData( source, "gameaccountid" ) )
		if friends then
			local ids = {}
			for result, row in mysql_rows( friends ) do
				ids[ tonumber( row[1] ) ] = true
			end
			mysql_free_result( friends )
			
			for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
				if isElement( value ) and ids[ getElementData( value, "gameaccountid" ) ] then
					friendsonline = friendsonline + 1
				end
			end
			
			setElementData(source, "friends", ids, false)
		end
		
		if friendsonline == 1 then
			friendsonline = "1 Friend"
		else
			friendsonline = friendsonline .. " Friends"
		end
		
		local factiononline = 0
		if (isElement(theTeam)) then
			factiononline = #getPlayersInTeam(theTeam)
		end
		
		if factiononline == 1 then
			factiononline = "1 Faction Member"
		else
			factiononline = factiononline .. " Faction Members"
		end
		
		
		if (factionName~="Citizen") then
			outputChatBox("Players Online: " .. playercount .. "/" .. maxplayers .. " (" .. percent .. "%) - " .. factiononline .. " - " .. friendsonline .. ".", source, 255, 194, 14)
		else
			outputChatBox("Players Online: " .. playercount .. "/" .. maxplayers .. " (" .. percent .. "%) - " .. friendsonline .. ".", source, 255, 194, 14)
		end
		
		-- LAST LOGIN
		local update = mysql_query(handler, "UPDATE characters SET lastlogin=NOW() WHERE id='" .. id .. "'")
		
		if (update) then
			mysql_free_result(update)
		end
		
		-- Player is cuffed
		if (cuffed==1) then
			toggleControl(source, "sprint", false)
			toggleControl(source, "fire", false)
			toggleControl(source, "jump", false)
			toggleControl(source, "next_weapon", false)
			toggleControl(source, "previous_weapon", false)
			toggleControl(source, "accelerate", false)
			toggleControl(source, "brake_reverse", false)
		end
			
		setElementData(source, "adminlevel", tonumber(adminlevel))
		setElementData(source, "loggedin", 1)
		setElementData(source, "businessprofit", 0, false)
		setElementData(source, "hiddenadmin", tonumber(hiddenAdmin))
		setElementData(source, "legitnamechange", 0)
		setElementData(source, "muted", tonumber(muted))
		setElementData(source, "hoursplayed", hoursplayed)
		exports.global:setMoney(source, money)
		exports.global:checkMoneyHacks(source)
		
		setElementData(source, "faction", factionID)
		setElementData(source, "factionMenu", 0)
		setElementData(source, "restrain", cuffed)
		setElementData(source, "tazed", 0, false)
		setElementData(source, "cellnumber", cellnumber, false)
		setElementData(source, "cellphone.secret", cellphonesecret, false)
		setElementData(source, "calling", nil, false)
		setElementData(source, "calltimer", nil, false)
		setElementData(source, "phonestate", 0, false)
		setElementData(source, "realinvehicle", 0, false)
		setElementData(source, "duty", duty, false)
		setElementData(source, "job", job)
		setElementData(source, "license.car", carlicense)
		setElementData(source, "license.gun", gunlicense)
		setElementData(source, "bankmoney", bankmoney)
		setElementData(source, "fingerprint", fingerprint, false)
		setElementData(source, "tag", tag)
		setElementData(source, "dutyskin", dutyskin, false)
		setElementData(source, "phoneoff", phoneoff, false)
		setElementData(source, "blindfold", blindfold, false)
		setElementData(source, "gender", gender, false)
		setElementData(source, "maxvehicles", maxvehicles, false)
		
		if (restrainedobj>0) then
			setElementData(source, "restrainedObj", restrainedobj, false)
		end
		
		if (restrainedby>0) then
			setElementData(source, "restrainedBy", restrainedby, false)
		end
		
		if job == 1 then
			-- trucker job fix
			triggerClientEvent(source,"restoreTruckerJob",source)
		end
		triggerEvent("restoreJob", source)
		triggerClientEvent(source, "updateCollectionValue", source, photos)
		
		-- Let's give them their weapons
		triggerEvent("syncWeapons", source, weapons, ammo)
		if (tostring(weapons)~=tostring(mysql_null())) and (tostring(ammo)~=tostring(mysql_null())) then -- if player has weapons saved
			for i=0, 12 do
				local tokenweapon = gettok(weapons, i+1, 59)
				local tokenammo = gettok(ammo, i+1, 59)
				
				if (not tokenweapon) or (not tokenammo) then
					break
				else
					exports.global:giveWeapon(source, tonumber(tokenweapon), tonumber(tokenammo), false)
				end
			end
		end
		
		-- Let's stick some blips on the properties they own
		local interiors = { }
		for key, value in ipairs(getElementsByType("pickup", getResourceRootElement(getResourceFromName("interior-system")))) do
			if isElement(value) and getElementDimension(value) == 0 then
				if getElementData(value, "name") then
					local inttype = getElementData(value, "inttype")
					local owner = tonumber(getElementData(value, "owner"))

					if owner == tonumber(id) then -- house/business and owned by this player
						local x, y = getElementPosition(value)
						if (inttype ~= 2) then -- house, business or rentable
							if inttype == 3 then inttype = 0 end
							interiors[#interiors+1] = { inttype, x, y }
						end
					end
				end
			end
		end
		
		triggerClientEvent(source, "createBlipsFromTable", source, interiors)
		
		-- Fight style
		setPedFightingStyle(source, tonumber(fightstyle))
		
		-- Achievement
		if not (exports.global:doesPlayerHaveAchievement(source, 38)) then
			exports.global:givePlayerAchievement(source, 38) -- Welcome to Los Santos
			-- Welcome tooltip (auto opens the window)
			if(getResourceFromName("tooltips-system"))then
				local title = tostring("Welcome to the Valhalla Gaming MTA role play server")
				triggerClientEvent(source,"tooltips:welcomeHelp", source,1,title)
			end
		end
		
		-- Weapon stats
		setPedStat(source, 70, 999)
		setPedStat(source, 71, 999)
		setPedStat(source, 72, 999)
		setPedStat(source, 74, 999)
		setPedStat(source, 76, 999)
		setPedStat(source, 77, 999)
		setPedStat(source, 78, 999)
		setPedStat(source, 79, 999)
		
		-- blindfolds
		if (blindfold==1) then
			setElementData(source, "blindfold", 1)
			outputChatBox("Your character is blindfolded. If this was an OOC action, please contact an administrator via F2.", source, 255, 194, 15)
			--fadeCamera(player, false)
		else
			fadeCamera(source, true, 2)
			setTimer(blindfoldFix, 5000, 1, source)
		end
		
		-- impounded cars
		if exports.global:hasItem(source, 2) then -- phone
			local impounded = mysql_query(handler, "SELECT COUNT(*) FROM vehicles WHERE owner = " .. id .. " and Impounded > 0")
			if impounded then
				local amount = tonumber(mysql_result(impounded, 1, 1)) or 0
				if amount > 0 then
					outputChatBox("((Best's Towing & Recovery)) #999 [SMS]: " .. amount .. " of your vehicles are impounded. Head over to the Impound to release them.", source, 120, 255, 80)
				end
				mysql_free_result(impounded)
			end
		end
		
		if (version) and (version < getVersion().mta) then --getVersion().mta
			outputChatBox("You are using an Old Version of MTA! (V" .. version .. ").", source, 255, 0, 0)
			outputChatBox("We recommend you upgrade to V" .. getVersion().mta .. " to ensure full script compatability and improve your experience.", source, 255, 0, 0)
		end
		
		triggerEvent("onCharacterLogin", source, charname, factionID)
		mysql_free_result(result)
				
		if exports.global:isPlayerScripter(source) then
			triggerClientEvent(source, "runcode:loadScripts", source)
		end
		triggerClientEvent(source, "updateHudClock", source)
	else
		outputDebugString( "Spawning Char failed: " .. mysql_error( handler ) )
	end
end
addEvent("onCharacterLogin", false)
addEvent("spawnCharacter", true)
addEventHandler("spawnCharacter", getRootElement(), spawnCharacter)

function blindfoldFix(player)
	fadeCamera(player, true, 2)
end

function timerUnjailPlayer(jailedPlayer)
	if(isElement(jailedPlayer)) then
		local timeServed = getElementData(jailedPlayer, "jailserved")
		local timeLeft = getElementData(jailedPlayer, "jailtime")
		local accountID = getElementData(jailedPlayer, "gameaccountid")
		
		if (timeServed) and (timeLeft) then
			setElementData(jailedPlayer, "jailserved", timeServed+1)
			local timeLeft = timeLeft - 1
			setElementData(jailedPlayer, "jailtime", timeLeft)
			local result
			if (timeLeft<=0) then
				result = mysql_query(handler, "UPDATE accounts SET adminjail_time='0', adminjail='0' WHERE id='" .. accountID .. "'")
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
				exports.global:sendMessageToAdmins("AdmJail: " .. getPlayerName(jailedPlayer) .. " has served his jail time.")
				exports.irc:sendMessage("[ADMIN] " .. getPlayerName(jailedPlayer) .. " was unjailed by script (Time Served)")
			else
				result = mysql_query(handler, "UPDATE accounts SET adminjail_time='" .. timeLeft .. "' WHERE id='" .. accountID .. "'")
			end
			if (result) then
				mysql_free_result(result)
			end
		else
			if (isElement(jailedPlayer)) then
				local theTimer = getElementData(jailedPlayer, "jailtimer")
			
				if (theTimer) then
					killTimer(theTimer)
				end
			end
		end
	end
end


function loginPlayer(username, password, operatingsystem)
	local safeusername = mysql_escape_string(handler, username)
	local result = mysql_query(handler, "SELECT * FROM accounts WHERE username='" .. safeusername .. "' AND password='" .. password .. "'")
	
	if (mysql_num_rows(result)>0) then
		local data = mysql_fetch_assoc(result)
		triggerEvent("onPlayerLogin", source, username, password)
		
		local id = tonumber(data["id"])
		
		-- Check the account isn't already logged in
		local found = false
		for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
			local accid = tonumber(getElementData(value, "gameaccountid"))
			if (accid) then
				if (accid==id) and (value~=source) then
					found = true
					break
				end
			end
		end
		
		if not (found) then
			triggerClientEvent(source, "hideUI", source, false)
			local admin = tonumber(data["admin"])
			local hiddenadmin = tonumber(data["hiddenadmin"])
			local adminduty = tonumber(data["adminduty"])
			local donator = tonumber(data["donator"])
			local adminjail = tonumber(data["adminjail"])
			local adminjail_time = tonumber(data["adminjail_time"])
			local adminjail_by = tostring(data["adminjail_by"])
			local adminjail_reason = data["adminjail_reason"]
			local banned = tonumber(data["banned"])
			local banned_by = data["banned_by"]
			local banned_reason = data["banned_reason"]
			local muted = tonumber(data["muted"])
			local globalooc = tonumber(data["globalooc"])
			local blur = tonumber(data["blur"])
			local help = tonumber(data["help"])
			local adminreports = tonumber(data["adminreports"])
			local pmblocked = tonumber(data["pmblocked"])
			local adblocked = tonumber(data["adblocked"])
			local newsblocked = tonumber(data["newsblocked"])
			local warns = tonumber(data["warns"])
			local chatbubbles = tonumber(data["chatbubbles"])
			local appstate = tonumber(data["appstate"])
			
			local country = tostring(exports.global:getPlayerCountry(source))
			if username == "Daniels" then
				country = "SC"
			elseif username == "mcreary" then
				country = "UK"
			end
			setElementData(source, "country", country)
			
			if tonumber(admin) == 0 then
				adminduty = 0
				hiddenadmin = 0
			end
			
			setElementData(source, "donatorlevel", tonumber(donator))
			setElementData(source, "adminlevel", tonumber(admin))
			setElementData(source, "hiddenadmin", tonumber(hiddenadmin))
			setElementData(source, "donator", tonumber(donator))
			setElementData(source, "tooltips:help", tonumber(help))
			
			setElementData(source, "blur", blur)
			if (blur==0) then
				setPlayerBlurLevel(source, 0)
			else
				setPlayerBlurLevel(source, 38)
			end
			
			if (appstate==0) then
				clearChatBox(source)
				outputChatBox("You must submit an application at www.valhallagaming.net/mtaucp in order to get your account activated.", source, 255, 194, 15)
				setTimer(kickPlayer, 30000, 1, source, getRootElement(), "Submit an application at www.valhallagaming.net/mtaucp")
			elseif (appstate==1) then
				clearChatBox(source)
				outputChatBox("Your application is still pending, visit www.valhallagaming.net/mtaucp to review its status.", source, 255, 194, 15)
				setTimer(kickPlayer, 30000, 1, source, getRootElement(), "Application Pending, Review Status at www.valhallagaming.net/mtaucp")
			elseif (appstate==2) then
				clearChatBox(source)
				outputChatBox("Your application was declined, You can read why, and resubmit a fixed one at www.valhallagaming.net/mtaucp", source, 255, 194, 15)
				setTimer(kickPlayer, 30000, 1, source, getRootElement(), "Re-Submit an application at www.valhallagaming.net/mtaucp")
			elseif (banned==1) then
				clearChatBox(source)
				outputChatBox("You have been banned from this server by: " .. tostring(banned_by) .. ".", source, 255, 0, 0)
				outputChatBox("Ban Reason: " .. tostring(banned_reason) .. ".", source, 255, 0, 0)
				outputChatBox(" ", source)
				outputChatBox("You can appeal against this ban on our forums at http://www.valhallagaming.net/forums", source)
				setTimer(kickPlayer, 15000, 1, source, getRootElement(), "Account is banned")
			else
				setElementData(source, "gameaccountloggedin", 1, false)
				setElementData(source, "gameaccountusername", username)
				setElementData(source, "gameaccountid", tonumber(id))
				setElementData(source, "adminduty", tonumber(adminduty))
				setElementData(source, "adminjailed", adminjail == 1, false)
				setElementData(source, "jailtime", tonumber(adminjail_time), false)
				setElementData(source, "jailadmin", tostring(adminjail_by), false)
				setElementData(source, "jailreason", tostring(adminjail_reason), false)
				setElementData(source, "globalooc", tonumber(globalooc), false)
				setElementData(source, "muted", tonumber(muted))
				setElementData(source, "adminreports", adminreports, false)
				
				if donator > 0 then -- check if they're a donator
					setElementData(source, "pmblocked", pmblocked, false)
					setElementData(source, "tognews", newsblocked, false)
					if (adblocked == 1) then
						setElementData(source, "disableAds", true, false)
					else
						setElementData(source, "disableAds", false, false)
					end
				else -- no donator, set default things
					setElementData(source, "pmblocked", 0, false)
					setElementData(source, "disableAds", false, false)
					setElementData(source, "tognews", 0, false)
				end
				
				
				setElementData(source, "warns", warns, false)
				setElementData(source, "chatbubbles", chatbubbles, false)
				
				sendAccounts(source, id)
				
				-- Get login time & date
				local time = getRealTime()
				local days = time.monthday
				local months = (time.month+1)
				local years = (1900+time.year)
				
				local yearday = time.yearday
				local logindate = days .. "/" .. months .. "/" .. years
				
				local ip = getPlayerIP(source)
				
				local update = mysql_query(handler, "UPDATE accounts SET lastlogin=NOW(), ip='" .. ip .. "', country='" .. country .. "' WHERE id='" .. id .. "'")
				
				if (update) then
					mysql_free_result(update)
				end
				
			end
		else
			showChat(source, true)
			outputChatBox("This account is already logged in. You cannot login more than once.", source, 255, 0, 0)
		end
	else
		showChat(source, true)
		local attempts = tonumber(getElementData(source, "loginattempts"))
		attempts = attempts + 1
		setElementData(source, "loginattempts", attempts, false)
		
		if (attempts>=3) then
			kickPlayer(source, true, false, false, getRootElement(), "Too many login attempts")
		else
			outputChatBox("Invalid Username or Password.", source, 255, 0, 0)
		end
	end
	
	if (result) then
		mysql_free_result(result)
	end
end
addEvent("onPlayerLogin", false)
addEvent("attemptLogin", true)
addEventHandler("attemptLogin", getRootElement(), loginPlayer)


pendingResult = { }
function displayRetrieveDetailsResult(result, player)
	if (player) and (pendingResult[player] ~= nil) then
		pendingResult[player] = nil
		if ( result == 0 ) then
			outputChatBox("Information on how to retrieve your username and password has been sent to your email address.", player, 0, 255, 0)
		else
			outputChatBox("This service is currently unavailable.", player, 255, 0, 0)
		end
	end
end

function checkTimeout(player)
	if ( pendingResult[player] ) then
		pendingResult[player] = nil
		outputChatBox("[TIMEOUT] This service is currently unavailable.", player, 255, 0, 0)
	end
end

function retrieveDetails(email)
	local safeEmail = mysql_escape_string(handler, tostring(email))
	
	local result = mysql_query(handler, "SELECT id FROM accounts WHERE email='" .. safeEmail .. "'")
	
	if (mysql_num_rows(result)>0) then
		local id = tonumber(mysql_result(result, 1, 1))
		callRemote("http://www.valhallagaming.net/mtaucp/sendfpmail.php", displayRetrieveDetailsResult, id)
		outputChatBox("Contacting account server... Please wait...", source, 255, 194, 15)
		
		pendingResult[source] = true
		setTimer(checkTimeout, 10000, 1, source)
	else
		outputChatBox("Invalid Email.", source, 255, 0, 0)
	end


--[[
	local safesecurityKey = mysql_escape_string(handler, tostring(securityKey))

	local result = mysql_query(handler, "SELECT username FROM accounts WHERE securitykey='" .. safesecurityKey .. "'")

	if (mysql_num_rows(result)>0) then
		local username = mysql_result(result, 1, 1)

		local letter1 = string.char(math.random(65,90))
		local num = math.random(0, 999999)
		
		-- Randomize the casing
		local randnumber1 = math.random(0, 1)
		local randnumber2 = math.random(0, 1)
		local randnumber3 = math.random(0, 1)
		local randnumber4 = math.random(0, 1)
		
		if (randnumber1==0) then
			letter1 = string.upper(letter1)
		else
			letter1 = string.lower(letter1)
		end
		
		if (randnumber2==0) then
			letter2 = string.upper(letter1)
		else
			letter2 = string.lower(letter1)
		end
		
		if (randnumber3==0) then
			letter3 = string.upper(letter1)
		else
			letter3 = string.lower(letter1)
		end
		
		if (randnumber4==0) then
			letter4 = string.upper(letter1)
		else
			letter4 = string.lower(letter1)
		end
		
		
		
		local letter2 = string.char(math.random(65,90))
		local newPassword = letter2 .. tostring(num) .. letter1
		local update = mysql_query(handler, "UPDATE accounts SET password=MD5('" .. salt .. newPassword .. "') WHERE username='" .. username .. "'")
		
		if (update) then
			outputChatBox("Your account name is '" .. tostring(username) .. "'.", source, 255, 194, 14)
			outputChatBox("Your new password is '" .. tostring(newPassword) .. "' (Write it down!).", source, 255, 194, 14)
			outputChatBox("You can change this password after login.", source, 255, 194, 14)
			mysql_free_result(update)
		else
			outputChatBox("Error 100001 - Report on forums.", source, 255, 0, 0)
		end
	else
		outputChatBox("Invalid security key.", source, 255, 0, 0)
	end
	
	if (result) then
		mysql_free_result(result)
	end
	]]--
end
addEvent("retrieveDetails", true)
addEventHandler("retrieveDetails", getRootElement(), retrieveDetails)

function sendAccounts(thePlayer, id, isChangeChar)
	setElementData(thePlayer,"loggedin",0)
	exports.global:updateNametagColor(thePlayer)
	exports.global:takeAllWeapons(thePlayer)
	local accounts = { }

	local result = mysql_query(handler, "SELECT id, charactername, cked, lastarea, age, gender, faction_id, faction_rank, skin, DATEDIFF(NOW(), lastlogin) FROM characters WHERE account='" .. id .. "'  ORDER BY cked ASC, lastlogin DESC")
	local emailresult = mysql_query(handler, "SELECT email FROM accounts WHERE id = '" .. id .. "'")
	
	
	if (mysql_num_rows(result)>0) then
		if (isChangeChar) then
			triggerEvent("savePlayer", source, "Change Character", source)
		end
		
		local i = 1

		for i=1, mysql_num_rows(result) do
			accounts[i] = { }
			accounts[i][1] = mysql_result(result, i, 1)
			accounts[i][2] = mysql_result(result, i, 2)
			
			if (tonumber(mysql_result(result, i, 3)) or 0) > 0 then
				accounts[i][3] = 1
			end
			
			accounts[i][4] = mysql_result(result, i, 4)
			accounts[i][5] = mysql_result(result, i, 5)
			
			if (tonumber(mysql_result(result, i, 6))==1) then
				accounts[i][6] = tonumber(mysql_result(result, i, 6))
			end
			
			local factionID = tonumber(mysql_result(result, i, 7))
			local factionRank = tonumber(mysql_result(result, i, 8))
			
			if (factionID<1) or not (factionID) then
				accounts[i][7] = nil
				accounts[i][8] = nil
			else
				factionResult = mysql_query(handler, "SELECT name, rank_" .. factionRank .. " FROM factions WHERE id='" .. tonumber(factionID) .. "'")

				if (mysql_num_rows(factionResult)>0) then
					accounts[i][7] = mysql_result(factionResult, 1, 1)
					accounts[i][8] = mysql_result(factionResult, 1, 2)
					
					if (string.len(accounts[i][7])>53) then
						accounts[i][7] = string.sub(accounts[i][7], 1, 32) .. "..."
					end
				else
					accounts[i][7] = nil
					accounts[i][8] = nil
				end
				
				if(factionResult) then
					mysql_free_result(factionResult)
				end
			end
			accounts[i][9] = mysql_result(result, i, 9)
			accounts[i][10] = mysql_result(result, i, 10)
			i = i + 1
		end
		
	end
	
	if (result) then
		mysql_free_result(result)
	end
	
	local playerid = getElementData(thePlayer, "playerid")

	spawnPlayer(thePlayer, 258.43417358398, -41.489139556885, 1002.0234375, 268.19247436523, 0, 14, 65000+playerid)
	
	if ( mysql_num_rows(emailresult) > 0 ) then
		local hasEmail = mysql_result(emailresult, 1, 1)
		
		if ( hasEmail == mysql_null() ) then
			triggerClientEvent(thePlayer, "showCharacterSelection", thePlayer, accounts, false, true)
		else
			triggerClientEvent(thePlayer, "showCharacterSelection", thePlayer, accounts)
		end
	else
		triggerClientEvent(thePlayer, "showCharacterSelection", thePlayer, accounts)
	end
end
addEvent("sendAccounts", true)
addEventHandler("sendAccounts", getRootElement(), sendAccounts)

function storeEmail(email)
	local accountid = getElementData(source, "gameaccountid")
	mysql_query(handler, "UPDATE accounts SET email = '" .. email .. "' WHERE id = '" .. accountid .. "'")
end
addEvent("storeEmail", true)
addEventHandler("storeEmail", getRootElement(), storeEmail)

function requestAchievements()
	-- Get achievements
	local gameAccountID = getElementData(source, "gameaccountid")
	local aresult = mysql_query(handler, "SELECT achievementid, date FROM achievements WHERE account='" .. gameAccountID .. "'")
	
	local achievements = { }
	
	-- Determine the total number of achievements & points
	if aresult then
		for result, row in mysql_rows(aresult) do
			achievements[#achievements+1] = { tonumber( row[1] ), row[2] }
		end
		mysql_free_result(aresult)
	end
	
	triggerClientEvent(source, "returnAchievements", source, achievements)
end
addEvent("requestAchievements", true)
addEventHandler("requestAchievements", getRootElement(), requestAchievements)

function deleteCharacterByName(charname)
	
	local fixedName = mysql_escape_string(handler, string.gsub(tostring(charname), " ", "_"))
	
	local accountID = getElementData(source, "gameaccountid")
	local result = mysql_query(handler, "SELECT id FROM characters WHERE charactername='" .. fixedName .. "' AND account='" .. accountID .. "' LIMIT 1")
	local charid = tonumber(mysql_result(result, 1, 1))
	mysql_free_result(result)
	
	if charid then -- not ck'ed
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
		local old = getElementData( source, "dbid" )
		setElementData( source, "dbid", charid )
		local result = mysql_query( handler, "SELECT id FROM interiors WHERE owner = " .. charid .. " AND type != 2" )
		if result then
			for result, row in mysql_rows( result ) do
				local id = tonumber(row[1])
				call( getResourceFromName( "interior-system" ), "publicSellProperty", source, id, false, false )
			end
		end
		setElementData( source, "dbid", old )
		
		-- get rid of all items
		mysql_free_result( mysql_query(handler, "DELETE FROM items WHERE type = 1 AND owner = " .. charid ) )
		
		-- finally delete the character
		mysql_free_result( mysql_query(handler, "DELETE FROM characters WHERE id='" .. charid .. "' AND account='" .. accountID .. "' LIMIT 1") )
	end
	--sendAccounts(source, accountID)
	--showChat(source, true)
end
addEvent("deleteCharacter", true)
addEventHandler("deleteCharacter", getRootElement(), deleteCharacterByName)


function clearChatBox(thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
	outputChatBox(" ", thePlayer)
end
addCommandHandler("clearchat", clearChatBox) -- Users can now clear their chat if they wish

--[[
function stripPlayer()
	for i = 0, 17 do
		removePedClothes(source, i)
	end
end
addEvent("stripPlayer", true)
addEventHandler("stripPlayer", getRootElement(), stripPlayer)
]]--

function declineTOS()
	kickPlayer(source, getRootElement(), "Declined TOS")
end
addEvent("declineTOS", true)
addEventHandler("declineTOS", getRootElement(), declineTOS)

--[[
function adjustFatness(val)
	setPedStat(source, 21, tonumber(val))
end
addEvent("adjustFatness", true)
addEventHandler("adjustFatness", getRootElement(), adjustFatness)

function adjustMuscles(val)
	setPedStat(source, 23, tonumber(val))
end
addEvent("adjustMuscles", true)
addEventHandler("adjustMuscles", getRootElement(), adjustMuscles)

function addClothes(texture, model, ctype)
	if (texture=="NONE") and (model=="NONE") then
		local texture, model = getPedClothes(source, ctype)
		removePedClothes(source, tonumber(ctype), texture, model)
	else
		removePedClothes(source, ctype)
		addPedClothes(source, texture, model, ctype)
	end
end
addEvent("addClothes", true)
addEventHandler("addClothes", getRootElement(), addClothes)
]]--

function doesCharacterExist(charname)
	charname = string.gsub(tostring(charname), " ", "_")
	local safecharname = mysql_escape_string(handler, charname)
	
	local result = mysql_query(handler, "SELECT charactername FROM characters WHERE charactername='" .. safecharname .. "'")
	
	if (mysql_num_rows(result)>0) then
		triggerClientEvent(source, "characterNextStep", source, true)
	else
		triggerClientEvent(source, "characterNextStep", source, false)
	end
	
	if (result) then
		mysql_free_result(result)
	end
end
addEvent("doesCharacterExist", true)
addEventHandler("doesCharacterExist", getRootElement(), doesCharacterExist)

function resetNick(oldNick, newNick)
	setElementData(source, "legitnamechange", 1)
	setPlayerName(source, oldNick)
	setElementData(source, "legitnamechange", 0)
	exports.global:sendMessageToAdmins("AdmWrn: " .. tostring(oldNick) .. " tried to change name to " .. tostring(newNick) .. ".")
end

addEvent("resetName", true )
addEventHandler("resetName", getRootElement(), resetNick)

-- ////////////////////////////////////////
-- STORE CREATED CHARACTERS
-- ///////////////////////////////////////
--[[
leftUpperArmTattoos = { {"NONE", "NONE"}, {"4WEED", "4weed"}, {"4RIP", "4rip"}, {"4SPIDER", "4spider"} }
leftLowerArmTattoos = { {"NONE", "NONE"}, {"5GUN", "5gun"}, {"5CROSS", "5cross"}, {"5CROSS2", "5cross2"}, {"5CROSS3", "5cross3"}  }
rightUpperArmTattoos = { {"NONE", "NONE"}, {"6AZTEC", "6aztec"}, {"6CROWN", "6crown"}, {"6CLOWN", "6clown"}, {"6AFRICA", "6africa"} }
rightLowerArmTattoos = { {"NONE", "NONE"}, {"7CROSS", "7cross"}, {"7CROSS2", "7cross2"}, {"7MARY", "7mary"} }
backTattoos = { {"NONE", "NONE"}, {"8SA", "8sa"}, {"8SA2", "8sa2"}, {"8SA3", "8sa3"}, {"8WESTSD", "8westside"}, {"8SANTOS", "8santos"}, {"8POKER", "8poker"}, {"8GUN", "8gun"} }
leftChestTattoos = { {"NONE", "NONE"}, {"9CROWN", "9crown"}, {"9GUN", "9GUN"}, {"9GUN2", "9gun2"}, {"9HOMBY", "9homeboy"}, {"9BULLT", "9bullet"}, {"9RASTA", "9rasta"} }
rightChestTattoos = { {"NONE", "NONE"}, {"10LS", "10ls"}, {"10LS2", "10ls2"}, {"10LS3", "10ls3"}, {"10LS4", "10ls4"}, {"10ls5", "10ls5"}, {"10OG", "10og"}, {"10WEED", "10weed"} }
stomachTattoos = { {"NONE", "NONE"}, {"11GROVE", "11grove"}, {"11GROV2", "11grove2"}, {"11GROV3", "11grove3"}, {"11DICE", "11dice"}, {"11DICE2", "11dice2"}, {"11JAIL", "11jail"}, {"11GGIFT", "11godsgift"} }
lowerBackTattoos = { {"NONE", "NONE"}, {"12ANGEL", "12angels"}, {"12MAYBR", "12mayabird"}, {"12DAGER", "12dagger"}, {"12BNDIT", "12bandit"}, {"12CROSS", "12cross7"}, {"12MYFAC", "12mayafce"} }

hair = { {"player_face", "head"}, {"hairblond", "head"}, {"hairred", "head"}, {"hairblue", "head"}, {"hairgreen", "head"}, {"hairpink", "head"}, {"bald", "head"}, {"baldbeard", "head"}, {"baldtash", "head"}, {"baldgoatee", "head"}, {"highfade", "head"}, {"highafro", "highafro"}, {"wedge", "wedge"}, {"slope", "slope"}, {"jhericurl", "jheri"}, {"cornrows", "cornrows"}, {"cornrowsb", "cornrows"}, {"tramline", "tramline"}, {"groovecut", "groovecut"}, {"mohawk", "mohawk"}, {"mohawkblond", "mohawk"}, {"mohawkpink", "mohawk"}, {"mohawkbeard", "mohawk"}, {"afro", "afro"}, {"afrotash", "afro"}, {"afrobeard", "afro"}, {"afroblond", "afro"}, {"flattop", "flattop"}, {"elvishair", "elvishair"}, {"beard", "head"}, {"tash", "head"}, {"goatee", "head"}, {"afrogoatee", "afro"} }
hats = { {"NONE", "NONE"}, {"bandred", "bandana"}, {"bandblue", "bandana"}, {"bandgang", "bandana"}, {"bandblack", "bandana"}, {"bandred2", "bandknots"}, {"bandblue2", "bandknots"}, {"bandblack2", "bandknots"}, {"bandgang2", "bandknots"}, {"capknitgrn", "capknit"}, {"captruck", "captruck"}, {"cowboy", "cowboy"}, {"hattiger", "cowboy"}, {"helmet", "helmet"}, {"moto", "moto"}, {"boxingcap", "boxingcap"}, {"hockey", "hockeymask"}, {"capgang", "cap"}, {"capgangback", "capblack"}, {"capgangside", "capside"}, {"capgangover", "capovereye"}, {"capgangup", "caprimup"}, {"bikerhelmet", "bikerhelmet"}, {"capred", "cap"}, {"capredback", "capback"}, {"capredside", "capside"}, {"capredover", "capovereye"}, {"capredup", "caprimup"}, {"capblue", "cap"}, {"capblueback", "capback"}, {"capblueside", "capside"}, {"capblueover", "capovereye"}, {"capblueup", "caprimup"}, {"skullyblk", "scullycap"}, {"skullygrn", "skullycap"}, {"hatmancblk", "hatmanc"}, {"hatmancplaid", "hatmanc"}, {"capzip", "cap"}, {"capzipback", "capback"}, {"capzipside", "capside"}, {"capzipover", "capovereye"}, {"capzipup", "caprimup"}, {"beretred", "beret"}, {"beretblk", "beret"}, {"capblk", "cap"}, {"capblkback", "capback"}, {"capblkside", "capside"}, {"capblkeover", "capovereye"}, {"capblkup", "caprimup"}, {"trilbydrk", "trilby"}, {"trilbylght", "trilby"}, {"bowler", "bowler"}, {"bolwerred", "bowlerred"}, {"bowlerblue", "bowler"}, {"bowleryellow", "bowler"}, {"boater", "boater"}, {"bowlergang", "bowler"}, {"boaterblk", "boater"} }
necks = { {"NONE", "NONE"}, {"dogtag", "neck"}, {"neckafrica", "neck"}, {"stopwatch", "neck"}, {"necksaints", "neck"}, {"neckhash", "neck"}, {"necksilver", "neck2"}, {"neckgold", "neck2"}, {"neckropes", "neck2"}, {"neckropg", "neck2"}, {"neckls", "neck2"}, {"neckdollar", "neck2"}, {"neckcross", "neck2"} }
faces = { {"NONE", "NONE"}, {"groucho", "grouchos"}, {"zorro", "zorromask"}, {"eyepatch", "glasses01"}, {"glasses04", "glasses04"}, {"bandred3", "bandmask"}, {"bandblue3", "bandmask"}, {"bandgang3", "bandmask"}, {"bandblack3", "bandmask"}, {"glasses01dark", "glasses01"}, {"glasses04dark", "glasses04"}, {"glasses03", "glasses03"}, {"glasses03red", "glasses03"}, {"glasses03blue", "glasses03"}, {"glasses03dark", "glasses03"}, {"glasses05dark", "glasses03"}, {"glasses05", "glasses03"} }
upperbody = { {"torso", "player_torso"}, {"vestblack", "vest"}, {"vest", "vest"}, {"tshirt2horiz", "tshirt2"}, {"tshirtwhite", "tshirt"}, {"tshirtlovels", "tshirt"}, {"tshirtblunts", "tshirt"}, {"shirtbplaid", "shirtb"}, {"shirtbcheck", "shirtb"}, {"field", "field"}, {"tshirterisyell", "tshirt"}, {"tshirterisorn", "tshirt"}, {"trackytop2eris", "trackytop2"}, {"bbjackrim", "bbjack"}, {"bbjackrstar", "bbjack"}, {"baskballdrib", "basjball"}, {"sixtyniners", "tshirt"}, {"bandits", "baseball"}, {"tshirtprored", "tshirt"}, {"tshirtproblk", "tshirt"}, {"trackytop1pro", "trackytop1"}, {"hockeytop", "sweat"}, {"bbjersey", "sleevt"}, {"shellsuit", "trackytop1"}, {"tshirtheatwht", "tshirt"}, {"tshirtbobomonk", "tshirt"}, {"tshirtbobored", "tshirt"}, {"tshirtbase5", "tshirt"}, {"tshirtsuburb", "tshirt"}, {"hoodyamerc", "hoodya"}, {"hoodyabase5", "hoodya"}, {"hoodayarockstar", "hoodya"}, {"wcoatblue", "wcoat"}, {"coach", "coach"}, {"coachsemi", "coach"}, {"sweatrstar", "sweat"}, {"hoodyAblue", "hoodyA"}, {"hoodyAblack", "hoodyA"}, {"hoodyAgreen", "hoodyA"}, {"sleevtbrown", "sleevt"}, {"shirtablue", "shirta"}, {"shirtayellow", "shirta"}, {"shirtagrey", "shirta"}, {"shirtbgang", "shirtb"}, {"tshirtzipcrm", "tshirt"}, {"tshirtzipgry", "tshirt"}, {"denimfade", "denim"}, {"bowling", "hawaii"}, {"hoodjackbeige", "hoodjack"}, {"baskballoc", "baskball"}, {"tshirtlocgrey", "tshirt"}, {"tshirtmaddgrey", "tshirt"}, {"tshirtmaddgrn", "tshirt"}, {"suit1grey", "suit1"}, {"suit1blk", "suit1"}, {"leather", "leather"}, {"painter", "painter"}, {"hawaiiwht", "hawaii"}, {"hawaiired", "hawaii"}, {"sportjack", "trackytop1"}, {"suit1red", "suit1"}, {"suit1blue", "suit1"}, {"suit1yellow", "suit1"}, {"suit2grn", "suit2"}, {"tuxedo", "suit2"}, {"suit1gang", "suit1"}, {"letter", "sleevt"} }
wrists = { {"NONE", "NONE"}, {"watchpink", "watch"}, {"watchyellow", "watch"}, {"watchpro", "watch"}, {"watchpro2", "watch"}, {"watchsub1", "watch"}, {"watchsub2", "watch"}, {"watchzip1", "watch"}, {"watchzip2", "watch"}, {"watchgno", "watch"}, {"watchgno2", "watch"}, {"watchcro", "watch"}, {"watchcro2", "watch"} }
lowerbody = { {"player_legs", "legs"}, {"worktrcamogrn", "worktr"}, {"worktrcamogry", "worktr"}, {"worktrgrey", "worktr"}, {"worktrhaki", "worktr"}, {"tracktr", "tracktr"}, {"trackteris", "tracktr"}, {"jeansdenim", "jeans"}, {"legsblack", "legs"}, {"legsheart", "legs"}, {"beiegetr", "chinosb"}, {"trackpro", "tracktr"}, {"tracktrwhstr", "tracktr"}, {"tracktrblue", "tracktr"}, {"tracktrgang", "tracktr"}, {"bbshortwht", "boxingshort"}, {"bbshortred", "boxingshort"}, {"shellsuittr", "tracktr"}, {"shortsgrey", "shorts"}, {"shortskhaki", "shorts"}, {"chongergrey", "chonger"}, {"chongergang", "chonger"}, {"chongerred", "chonger"}, {"chongerblue", "chonger"}, {"shortsgang", "shorts"}, {"denimsgang", "jeans"}, {"denimsred", "jeans"}, {"chinosbiege", "chinosb"}, {"chinoskhaki", "chinosb"}, {"cutoffchinos", "shorts"}, {"cutoffchinesblue", "shorts"}, {"chinosblack", "chinosb"}, {"chinosblue", "chinosb"}, {"leathertr", "leathertr"}, {"leathertrchaps", "leathertr"}, {"suit1trgrey", "suit1tr"}, {"suit1trblk", "suit1tr"}, {"cutoffdenims", "shorts"}, {"suit1trred", "suit1tr"}, {"suit1trblue", "suit1tr"}, {"suit1tryellow", "suit1tr"}, {"suit1trgreen", "suit1tr"}, {"suit1trblk2", "suit1tr"}, {"suit1trgang", "suit1tr"} }
feet = { {"foot", "feet"}, {"cowboyboot2", "biker"}, {"bask2semi", "bask1"}, {"bask1eris", "bask1"}, {"sneakerbincgang", "sneaker"}, {"sneakerbincblue", "sneakers"}, {"sneakerbincblk", "sneaker"}, {"sandal", "flipflop"}, {"sandalsock", "flipflop"}, {"flipflop", "flipflop"}, {"hitop", "bask1"}, {"convproblk", "conv"}, {"convproblu", "conv"}, {"convprogrn", "conv"}, {"sneakerprored", "sneaker"}, {"sneakerproblu", "sneakers"}, {"sneakerprowht", "sneaker"}, {"bask1prowht", "bask1"}, {"bask1problk", "bask1"}, {"boxingshoe", "biker"}, {"convheatblk", "conv"}, {"convheatred", "conv"}, {"convheatorn", "conv"}, {"sneakerheatwht", "sneaker"}, {"sneakerheatgry", "sneaker"}, {"sneakerheatblk", "sneaker"}, {"bask2heatwht", "bask1"}, {"bask2headband", "bask1"}, {"timbergrey", "back1t"}, {"timberred", "bask1"}, {"timberfawn", "bask1"}, {"timberhike", "bask1"}, {"cowboyboot", "biker"}, {"biker", "biker"}, {"snakeskin", "biker"}, {"shoedressblk", "shoe"}, {"shoedressbrn", "shoe"}, {"shoespatz", "shoe"} } 
costumes = { {"NONE", "NONE"}, {"valet", "valet"}, {"countrytr", "countrytr"}, {"croupier", "valet"}, {"pimptr", "pimptr"}, {"policetr", "policetr"} }


function spawnClothes(name)
	local charname = string.gsub(tostring(name), " ", "_")
	local safecharname = mysql_escape_string(handler, name)
	
	local result = mysql_query(handler, "SELECT muscles, fat, shirt, head, trousers, shoes, tattoo_lu, tattoo_ll, tattoo_ru, tattoo_rl, tattoo_back, tattoo_lc, tattoo_rc, tattoo_stomach, tattoo_lb, neck, watch, glasses, hat, extra FROM characters WHERE charactername='" .. safecharname .. "'")
	
	for i = 0, 17 do
		removePedClothes(source, i)
	end
	
	if (result) then
		local muscle = tonumber(mysql_result(result, 1, 1))
		local fat = tonumber(mysql_result(result, 1, 2))
		
		local shirt = tonumber(mysql_result(result, 1, 3))
		local head = tonumber(mysql_result(result, 1, 4))
		local trousers = tonumber(mysql_result(result, 1, 5))
		local shoes = tonumber(mysql_result(result, 1, 6))
		local tattoo_lu = tonumber(mysql_result(result, 1, 7))
		local tattoo_ll = tonumber(mysql_result(result, 1, 8))
		local tattoo_ru = tonumber(mysql_result(result, 1, 9))
		local tattoo_rl = tonumber(mysql_result(result, 1, 10))
		local tattoo_back = tonumber(mysql_result(result, 1, 11))
		local tattoo_lc = tonumber(mysql_result(result, 1, 12))
		local tattoo_rc = tonumber(mysql_result(result, 1, 13))
		local tattoo_stomach = tonumber(mysql_result(result, 1, 14))
		local tattoo_lb = tonumber(mysql_result(result, 1, 15))
		local neck = tonumber(mysql_result(result, 1, 16))
		local watch = tonumber(mysql_result(result, 1, 17))
		local glasses = tonumber(mysql_result(result, 1, 18))
		local hat = tonumber(mysql_result(result, 1, 19))
		local extra = tonumber(mysql_result(result, 1, 20))
	
		setPedStat(source, 23, muscle)
		setPedStat(source, 21, fat)
		
		-- No more infinite stamina =]
		if (fat>500) then -- Fat people = 70% less stamina
			setPedStat(source, 22, 30)
		else
			setPedStat(source, 22, 100)
		end
		
		-- SHIRT
		if (upperbody[shirt][1]~="NONE") then
			addPedClothes(source, upperbody[shirt][1], upperbody[shirt][2], 0)
		end
		
		-- HEAD
		if (hair[head][1]~="NONE") then
			addPedClothes(source, hair[head][1], hair[head][2], 1)
		end
		
		-- TROUSERS
		if (lowerbody[trousers][1]~="NONE") then
			addPedClothes(source, lowerbody[trousers][1], lowerbody[trousers][2], 2)
		end
		
		-- SHOES
		if (feet[shoes][1]~="NONE") then
			addPedClothes(source, feet[shoes][1], feet[shoes][2], 3)
		end
		
		--  Tattoo: LU
		if (leftUpperArmTattoos[tattoo_lu][1]~="NONE") then
			addPedClothes(source, leftUpperArmTattoos[tattoo_lu][1], leftUpperArmTattoos[tattoo_lu][2], 4)
		end
		
		--  Tattoo: LL
		if (leftLowerArmTattoos[tattoo_ll][1]~="NONE") then
			addPedClothes(source, leftLowerArmTattoos[tattoo_ll][1], leftLowerArmTattoos[tattoo_ll][2], 5)
		end
		
		--  Tattoo: RU
		if (rightUpperArmTattoos[tattoo_ru][1]~="NONE") then
			addPedClothes(source, rightUpperArmTattoos[tattoo_ru][1], rightUpperArmTattoos[tattoo_ru][2], 6)
		end
		
		--  Tattoo: RL
		if (rightLowerArmTattoos[tattoo_rl][1]~="NONE") then
			addPedClothes(source, rightLowerArmTattoos[tattoo_rl][1], rightLowerArmTattoos[tattoo_rl][2], 7)
		end
		
		-- Tattoo: back
		if (backTattoos[tattoo_back][1]~="NONE") then
			addPedClothes(source, backTattoos[tattoo_back][1], backTattoos[tattoo_back][2], 8)
		end
		
		-- Tattoo:  LC
		if (leftChestTattoos[tattoo_lc][1]~="NONE") then
			addPedClothes(source, leftChestTattoos[tattoo_lc][1], leftChestTattoos[tattoo_lc][2], 9)
		end
		
		-- Tattoo:  RC
		if (rightChestTattoos[tattoo_rc][1]~="NONE") then
			addPedClothes(source, rightChestTattoos[tattoo_rc][1], rightChestTattoos[tattoo_rc][2], 10)
		end
		
		-- Tattoo:  Stomach
		if (stomachTattoos[tattoo_stomach][1]~="NONE") then
			addPedClothes(source, stomachTattoos[tattoo_stomach][1], stomachTattoos[tattoo_stomach][2], 11)
		end
		
		-- Tattoo: LB
		if (lowerBackTattoos[tattoo_lb][1]~="NONE") then
			addPedClothes(source, lowerBackTattoos[tattoo_lb][1], lowerBackTattoos[tattoo_lb][2], 12)
		end
		
		-- Neck
		if (necks[neck][1]~="NONE") then
			addPedClothes(source, necks[neck][1], necks[neck][2], 13)
		end
		
		-- Watch
		if (wrists[watch][1]~="NONE") then
			addPedClothes(source, wrists[watch][1], wrists[watch][2], 14)
		end
		
		-- Glasses
		if (faces[glasses][1]~="NONE") then
			addPedClothes(source, faces[glasses][1], faces[glasses][2], 15)
		end
		
		-- Hat
		if (hats[hat][1]~="NONE") then
			addPedClothes(source, hats[hat][1], hats[hat][2], 16)
		end

		-- EXTRA
		if (costumes[extra][1]~="NONE") then
			addPedClothes(source, costumes[extra][1], costumes[extra][2], 17)
		end
		
		mysql_free_result(result)
	end
end
addEvent("spawnClothes", true)
addEventHandler("spawnClothes", getRootElement(), spawnClothes)
]]--

function createCharacter(name, gender, skincolour, weight, height, fatness, muscles, transport, description, age, skin, language)
	-- Fix the name and check if its already taken...
	local charname = string.gsub(tostring(name), " ", "_")
	local safecharname = mysql_escape_string(handler, charname)
	description = string.gsub(tostring(description), "'", "")
	
	local result = mysql_query(handler, "SELECT charactername FROM characters WHERE charactername='" .. safecharname .. "'")

	local accountID = getElementData(source, "gameaccountid")
	local accountUsername = getElementData(source, "gameaccountusername")
	
	if (mysql_num_rows(result)>0) then -- Name is already taken
		triggerEvent("onPlayerCreateCharacter", source, charname, gender, skincolour, weight, height, fatness, muscles, transport, description, age, skin, language, false)
	else
	
		-- /////////////////////////////////////
		-- TRANSPORT
		-- /////////////////////////////////////
		local x, y, z, r, lastarea = 0, 0, 0, 0, "Unknown"
		
		if (transport==1) then
			x, y, z = 1742.1884765625, -1861.3564453125, 13.577615737915
			r = 0.98605346679688
			lastarea = "Unity Bus Station"
		else
			x, y, z = 1685.583984375, -2329.4443359375, 13.546875
			r = 0.79379272460938
			lastarea = "Los Santos International"
		end
		
		local salt = "fingerprintscotland"
		local fingerprint = md5(salt .. safecharname)
		
		local query = mysql_query(handler, "INSERT INTO characters SET charactername='" .. safecharname .. "', x='" .. x .. "', y='" .. y .. "', z='" .. z .. "', rotation='" .. r .. "', faction_id='-1', transport='" .. transport .. "', gender='" .. gender .. "', skincolor='" .. skincolour .. "', weight='" .. weight .. "', height='" .. height .. "', muscles='" .. muscles .. "', fat='" .. fatness .. "', description='" .. description .. "', account='" .. accountID .. "', skin='" .. skin .. "', lastarea='" .. lastarea .. "', age='" .. age .. "', fingerprint='" .. fingerprint .. "', lang1=" .. language .. ", lang1skill=100, currLang=1" )
		
		if (query) then
			local id = mysql_insert_id(handler)
			mysql_free_result(query)
			
			setElementData(source, "dbid", id, false)
			exports.global:giveItem( source, 16, skin )
			exports.global:giveItem( source, 17, 1 )
			exports.global:giveItem( source, 18, 1 )
			removeElementData(source, "dbid")
			--if (clothes) then -- Store CJ's clothes!
				--local update = mysql_query(handler, "UPDATE characters SET head='" .. clothes[1] .. "', hat='" .. clothes[2] .. "', neck='" .. clothes[3] .. "', glasses='" .. clothes[4] .. "', shirt='" .. clothes[5] .. "', watch='" .. clothes[6] .. "', trousers='" .. clothes[7] .. "', shoes='" .. clothes[8] .. "', extra='" .. clothes[9] .. "', tattoo_lu='" .. clothes[10] .. "', tattoo_ll='" .. clothes[11] .. "', tattoo_ru='" .. clothes[12] .. "', tattoo_rl='" .. clothes[13] .. "', tattoo_back='" .. clothes[14] .. "', tattoo_lc='" ..clothes[15] .. "', tattoo_rc='" .. clothes[16] .. "', tattoo_stomach='" .. clothes[17] .. "', tattoo_lb='" .. clothes[18] .. "' WHERE charactername='" .. safecharname .. "'")
				--if (update) then
				--	mysql_free_result(update)
				--end
			--end
			
			-- CELL PHONE
			
			local cellnumber = id+15000
			local update = mysql_query(handler, "UPDATE characters SET cellnumber='" .. cellnumber .. "' WHERE charactername='" .. safecharname .. "'")
			
			if (update) then
				mysql_free_result(update)
				triggerEvent("onPlayerCreateCharacter", source, charname, gender, skincolour, weight, height, fatness, muscles, transport, description, age, skin, language, true)
			else
				outputChatBox("Error 100003 - Report on forums.", source, 255, 0, 0)
			end
		else
			triggerEvent("onPlayerCreateCharacter", source, charname, gender, skincolour, weight, height, fatness, muscles, transport, description, age, skin, language, false)
		end
	end
	exports.irc:sendMessage("[ACCOUNT] Character '" ..  charname .. "' was registered to account '" .. accountUsername .. "'")
	sendAccounts(source, accountID)
	
	if (result) then
		mysql_free_result(result)
	end
end
addEvent("onPlayerCreateCharacter", false)
addEvent("createCharacter", true)
addEventHandler("createCharacter", getRootElement(), createCharacter)

function serverToggleBlur(enabled)
	if (enabled) then
		setElementData(source, "blur", 1)
		setPlayerBlurLevel(source, 38)
	else
		setElementData(source, "blur", 0)
		setPlayerBlurLevel(source, 0)
	end
	mysql_free_result( mysql_query( handler, "UPDATE accounts SET blur=" .. getElementData( source, "blur" ).. " WHERE id = " .. getElementData( source, "gameaccountid" ) ) )
end
addEvent("updateBlurLevel", true)
addEventHandler("updateBlurLevel", getRootElement(), serverToggleBlur)

function cmdToggleBlur(thePlayer, commandName)
	local blur = getElementData(thePlayer, "blur")
	
	if (blur==0) then
		outputChatBox("Vehicle blur enabled.", thePlayer, 255, 194, 14)
		setElementData(thePlayer, "blur", 1)
		setPlayerBlurLevel(thePlayer, 38)
	elseif (blur==1) then
		outputChatBox("Vehicle blur disabled.", thePlayer, 255, 194, 14)
		setElementData(thePlayer, "blur", 0)
		setPlayerBlurLevel(thePlayer, 0)
	end
	mysql_free_result( mysql_query( handler, "UPDATE accounts SET blur=" .. ( 1 - blur ) .. " WHERE id = " .. getElementData( thePlayer, "gameaccountid" ) ) )
end
addCommandHandler("toggleblur", cmdToggleBlur)

function serverToggleHelp(enabled)
	if (enabled) then
		setElementData(source, "tooltips:help", 1)
	else
		setElementData(source, "tooltips:help", 0)
	end
	mysql_free_result( mysql_query( handler, "UPDATE accounts SET help=" .. getElementData( source, "tooltips:help" ).. " WHERE id = " .. getElementData( source, "gameaccountid" ) ) )
end
addEvent("updateHelp", true)
addEventHandler("updateHelp", getRootElement(), serverToggleHelp)

function cguiSetNewPassword(oldPassword, newPassword)
	
	local gameaccountID = getElementData(source, "gameaccountid")
	
	local safeoldpassword = mysql_escape_string(handler, oldPassword)
	local safenewpassword = mysql_escape_string(handler, newPassword)
	
	local query = mysql_query(handler, "SELECT username FROM accounts WHERE id='" .. gameaccountID .. "' AND password=MD5('" .. salt .. safeoldpassword .. "')")
	
	if not (query) or (mysql_num_rows(query)==0) then
		outputChatBox("Your current password you entered was wrong.", source, 255, 0, 0)
	else
		local update = mysql_query(handler, "UPDATE accounts SET password=MD5('" .. salt .. safenewpassword .. "') WHERE id='" .. gameaccountID .. "'")

		if (update) then
			outputChatBox("You changed your password to '" .. newPassword .. "'", source, 0, 255, 0)
			mysql_free_result(update)
		else
			outputChatBox("Error 100004 - Report on forums.", source, 255, 0, 0)
		end
	end
	if (query) then
		mysql_free_result(query)
	end
end
addEvent("cguiSavePassword", true)
addEventHandler("cguiSavePassword", getRootElement(), cguiSetNewPassword)

function timerPDUnjailPlayer(jailedPlayer)
	if(isElement(jailedPlayer)) then
		local timeServed = getElementData(jailedPlayer, "pd.jailserved", false) or 0
		local timeLeft = getElementData(jailedPlayer, "pd.jailtime", false) or 0
		local username = getPlayerName(jailedPlayer)
		if not username then
			local theTimer = getElementData(jailedPlayer, "pd.jailtimer")
			if isTimer(theTimer) then
				killTimer(theTimer)	
			end
			removeElementData(jailedPlayer, "pd.jailtimer")
			return
		end
		setElementData(jailedPlayer, "pd.jailserved", timeServed+1, false)
		local timeLeft = timeLeft - 1
		setElementData(jailedPlayer, "pd.jailtime", timeLeft, false)

		if (timeLeft<=0) then
			fadeCamera(jailedPlayer, false)
			local query = mysql_query(handler, "UPDATE characters SET pdjail_time='0', pdjail='0', pdjail_station='0' WHERE charactername='" .. mysql_escape_string(handler, username) .. "'")
			mysql_free_result(query)
			local station = getElementData(jailedPlayer, "pd.jailstation") or 1
			setElementDimension(jailedPlayer, station <= 4 and 1 or 10583)
			setElementInterior(jailedPlayer, 10)
			setCameraInterior(jailedPlayer, 10)
			
			
			setElementPosition(jailedPlayer, 241.3583984375, 115.232421875, 1003.2257080078)
			setPedRotation(jailedPlayer, 270)
				
			setElementData(jailedPlayer, "pd.jailserved", 0, false)
			setElementData(jailedPlayer, "pd.jailtime", 0, false)
			removeElementData(jailedPlayer, "pd.jailtimer")
			removeElementData(jailedPlayer, "pd.jailstation")
			fadeCamera(jailedPlayer, true)
			outputChatBox("Your time has been served.", jailedPlayer, 0, 255, 0)
		elseif (timeLeft>0) then
			local query = mysql_query(handler, "UPDATE characters SET pdjail_time='" .. timeLeft .. "' WHERE charactername='" .. mysql_escape_string(handler, username) .. "'")
			mysql_free_result(query)
		end
	else
		local theTimer = getElementData(jailedPlayer, "pd.jailtimer")
		killTimer(theTimer)
	end
end

function sendEditingInformation(charname)
	local result = mysql_query(handler, "SELECT description, age, weight, height, gender FROM characters WHERE charactername='" .. mysql_escape_string(handler, charname:gsub(" ", "_")) .. "'")
	local description = tostring(mysql_result(result, 1, 1))
	local age = tostring(mysql_result(result, 1, 2))
	local weight = tostring(mysql_result(result, 1, 3))
	local height = tostring(mysql_result(result, 1, 4))
	local gender = tonumber(mysql_result(result, 1, 5))
	mysql_free_result(result)
	
	triggerClientEvent(source, "sendEditingInformation", source, height, weight, age, description, gender)
end
addEvent("requestEditCharInformation", true)
addEventHandler("requestEditCharInformation", getRootElement(), sendEditingInformation)

function updateEditedCharacter(charname, height, weight, age, description)
	local result = mysql_query(handler, "UPDATE characters SET description='" .. mysql_escape_string(handler, description) .. "', height=" .. height .. ", weight=" .. weight .. ", age=" .. age .. " WHERE charactername='" .. mysql_escape_string(handler, charname:gsub(" ", "_")) .. "'")
	mysql_free_result(result)
end
addEvent("updateEditedCharacter", true)
addEventHandler("updateEditedCharacter", getRootElement(), updateEditedCharacter)