mysql = exports.mysql

enginelessVehicle = { [510]=true, [509]=true, [481]=true }
lightlessVehicle = { [592]=true, [577]=true, [511]=true, [548]=true, [512]=true, [593]=true, [425]=true, [520]=true, [417]=true, [487]=true, [553]=true, [488]=true, [497]=true, [563]=true, [476]=true, [447]=true, [519]=true, [460]=true, [469]=true, [513]=true, [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true }
locklessVehicle = { [581]=true, [509]=true, [481]=true, [462]=true, [521]=true, [463]=true, [510]=true, [522]=true, [461]=true, [448]=true, [468]=true, [586]=true }
armoredCars = { [427]=true, [528]=true, [432]=true, [601]=true, [428]=true, [597]=true } -- Enforcer, FBI Truck, Rhino, SWAT Tank, Securicar, SFPD Car

-- cached owner name queries
local charCache = {} -- messes with name changes

local function secondArg( a, b )
	return b
end

local function makeName( a, b )
	-- find first and last name
	local ax, ay = a:sub( 1, a:find( "_" ) - 1 ), a:sub( secondArg( a:find( "_" ) ) + 1 )
	local bx, by = b:sub( 1, b:find( "_" ) - 1 ), b:sub( secondArg( b:find( "_" ) ) + 1 )
	
	if ay == by then
		return ax .. " & " .. bx .. " " .. by
	else
		return a .. " & " .. b
	end
end

function getCharacterName( id )
	if not charCache[ id ] then
		local query = mysql:query_fetch_assoc("SELECT charactername, gender, marriedto FROM characters WHERE id = " .. id .. " LIMIT 1")
		if query then
			local name = query["charactername"]
			local gender = tonumber(query["gender"])
			local marriedto = tonumber(query["marriedto"])
			
			if name then
				if marriedto > 0 then
					local query = mysql:query_fetch_assoc("SELECT charactername FROM characters WHERE id = " .. marriedto .. " LIMIT 1")
					if query then
						local name2 = query["charactername"]
						if name2 ~= mysql_null( ) then
							if gender == 1 then
								name = makeName( name, name2 )
							else
								name = makeName( name2, name )
							end
						end
					end
				end
				charCache[ id ] = name:gsub("_", " ")
			end
		end
	end
	return charCache[ id ]
end

function clearCharacterName( id )
	charCache[ id ] = nil
end

-- /makeveh
function createPermVehicle(thePlayer, commandName, ...)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		local args = {...}
		if (#args < 6) then
			outputChatBox("SYNTAX: /" .. commandName .. " [id/name] [color1] [color2] [Owner] [Faction Vehicle (1/0)] [Cost] [Tinted Windows] ", thePlayer, 255, 194, 14)
			outputChatBox("NOTE: If it is a faction vehicle, Username is the owner of the faction.", thePlayer, 255, 194, 14)
			outputChatBox("NOTE: If it is a faction vehicle, The cost is taken from the faction fund, rather than the player.", thePlayer, 255, 194, 14)
		else
			local vehicleID = tonumber(args[1])
			local col1, col2, userName, factionVehicle, cost
			
			if not vehicleID then -- vehicle is specified as name
				local vehicleEnd = 1
				repeat
					vehicleID = getVehicleModelFromName(table.concat(args, " ", 1, vehicleEnd))
					vehicleEnd = vehicleEnd + 1
				until vehicleID or vehicleEnd == #args
				if vehicleEnd == #args then
					outputChatBox("Invalid Vehicle Name.", thePlayer, 255, 0, 0)
					return
				else
					col1 = tonumber(args[vehicleEnd])
					col2 = tonumber(args[vehicleEnd + 1])
					userName = args[vehicleEnd + 2]
					factionVehicle = tonumber(args[vehicleEnd + 3])
					cost = tonumber(args[vehicleEnd + 4])
				end
			else
				col1 = tonumber(args[2])
				col2 = tonumber(args[3])
				userName = args[4]
				factionVehicle = tonumber(args[5])
				cost = tonumber(args[6])
			end
			
			local id = vehicleID
			
			local r = getPedRotation(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
			y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )
			
			local targetPlayer, username = exports.global:findPlayerByPartialNick(thePlayer, userName)
			
			if targetPlayer then
				local dbid = getElementData(targetPlayer, "dbid")
				
				if (factionVehicle==1) then
					factionVehicle = tonumber(getElementData(targetPlayer, "faction"))
					local theTeam = getPlayerTeam(targetPlayer)
					
					if not exports.global:takeMoney(theTeam, cost) then
						outputChatBox("This faction cannot afford this vehicle.", thePlayer, 255, 0, 0)
						return
					end
				else
					factionVehicle = -1
					if not exports.global:takeMoney(targetPlayer, cost) then
						outputChatBox("This player cannot afford this vehicle.", thePlayer, 255, 0, 0)
						return
					elseif not exports.global:canPlayerBuyVehicle(targetPlayer) then
						outputChatBox("This player has too many cars.", thePlayer, 255, 0, 0)
						return
					elseif ( getVehicleType(id) == "Helicopter" or getVehicleType(id) == "Plane" ) and not exports.global:hasItem(targetPlayer, 78) then
						outputChatBox("The player has no Pilot Certificate.", thePlayer, 255, 0, 0)
						return
					elseif getVehicleType(id) == "BMX" then
						outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
						return
					end
				end
				
				local letter1 = string.char(math.random(65,90))
				local letter2 = string.char(math.random(65,90))
				local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)
				
				local veh = createVehicle(id, x, y, z, 0, 0, r, plate)
				if not (veh) then
					outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
				else
					setElementData(veh, "fuel", 100)
					setElementData(veh, "Impounded", 0)
					setElementData(veh, "handbrake", 0, false)
						
					local rx, ry, rz = getVehicleRotation(veh)
					setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
					setElementData(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
					
					setVehicleLocked(veh, true)
							
					setVehicleColor(veh, col1, col2, col1, col2)
						
					setVehicleOverrideLights(veh, 1)
					setVehicleEngineState(veh, false)
					setVehicleFuelTankExplodable(veh, false)
					
					-- Set the vehicle armored if it is armored
					if (armoredCars[id]) then
						setVehicleDamageProof(veh, true)
					end
						
					local dimension = getElementDimension(thePlayer)
					local interior = getElementInterior(thePlayer)
					local insertid = mysql:query_insert_free("INSERT INTO vehicles SET model='" .. id .. "', x='" .. x .. "', y='" .. y .. "', z='" .. z .. "', rotx='" .. rx .. "', roty='" .. ry .. "', rotz='" .. rz .. "', color1='" .. col1 .. "', color2='" .. col2 .. "', faction='" .. factionVehicle .. "', owner='" .. ( factionVehicle == -1 and dbid or -1 ) .. "', plate='" .. plate .. "', currx='" .. x .. "', curry='" .. y .. "', currz='" .. z .. "', currrx='0', currry='0', currrz='" .. r .. "', locked=1, interior='" .. interior .. "', currinterior='" .. interior .. "', dimension='" .. dimension .. "', currdimension='" .. dimension .. "'")

					if (insertid) then
						exports.pool:allocateElement(veh, insertid)
						
						if (factionVehicle==-1) then
							exports.global:giveItem(targetPlayer, 3, tonumber(insertid))
						end
						
						setElementData(veh, "dbid", tonumber(insertid))
						setElementData(veh, "fuel", 100)
						setElementData(veh, "engine", 0, false)
						setElementData(veh, "oldx", x, false)
						setElementData(veh, "oldy", y, false)
						setElementData(veh, "oldz", z, false)
						setElementData(veh, "faction", factionVehicle)
						setElementData(veh, "owner", factionVehicle == -1 and dbid or -1, false)
						setElementData(veh, "job", 0, false)
						
						setElementData(veh, "dimension", dimension, false)
						setElementData(veh, "interior", interior, false)
						setElementData(veh, "handbrake", 0, false)
						
						setElementDimension(veh, dimension)
						setElementInterior(veh, interior)
						
						outputChatBox(getVehicleName(veh) .. " spawned with ID #" .. insertid .. ".", thePlayer, 255, 194, 14)
						
						local owner = ""
						if factionVehicle == -1 then
							owner = "Owner: " .. getPlayerName( targetPlayer )
						else
							owner = "Faction #" .. factionVehicle
						end
						
						exports.logs:logMessage("[MAKEVEH] " .. getPlayerName( thePlayer ) .. " created car #" .. insertid .. " (" .. getVehicleNameFromModel( id ) .. ") - " .. owner, 9)
						
						exports['vehicle-interiors']:add( veh )
					else
						destroyElement( veh )
					end
				end
			end
		end
	end
end
addCommandHandler("makeveh", createPermVehicle, false, false)

-- /makecivveh
function createCivilianPermVehicle(thePlayer, commandName, ...)
	if (exports.global:isPlayerLeadAdmin(thePlayer)) then
		local args = {...}
		if (#args < 4) then
			outputChatBox("SYNTAX: /" .. commandName .. " [id/name] [color1 (-1 for random)] [color2 (-1 for random)] [Job ID -1 for none]", thePlayer, 255, 194, 14)
			outputChatBox("Job 1 = Delivery Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 2 = Taxi Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 3 = Bus Driver", thePlayer, 255, 194, 14)
		else
			local vehicleID = tonumber(args[1])
			local col1, col2, job
			
			if not vehicleID then -- vehicle is specified as name
				local vehicleEnd = 1
				repeat
					vehicleID = getVehicleModelFromName(table.concat(args, " ", 1, vehicleEnd))
					vehicleEnd = vehicleEnd + 1
				until vehicleID or vehicleEnd == #args
				if vehicleEnd == #args then
					outputChatBox("Invalid Vehicle Name.", thePlayer, 255, 0, 0)
					return
				else
					col1 = tonumber(args[vehicleEnd])
					col2 = tonumber(args[vehicleEnd + 1])
					job = tonumber(args[vehicleEnd + 2])
				end
			else
				col1 = tonumber(args[2])
				col2 = tonumber(args[3])
				job = tonumber(args[4])
			end
			
			local id = vehicleID
			
			local r = getPedRotation(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
			y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )
			
			local letter1 = string.char(math.random(65,90))
			local letter2 = string.char(math.random(65,90))
			local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)

			local veh = createVehicle(id, x, y, z, 0, 0, r, plate)
				
			if not (veh) then
				outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
			else
				setElementData(veh, "fuel", 100)
				setElementData(veh, "handbrake", 0, false)
					
				if (job>0) then
					toggleVehicleRespawn(veh, true)
					setVehicleRespawnDelay(veh, 60000)
					setVehicleIdleRespawnDelay(veh, 180000)
				end
					
				local rx, ry, rz = getVehicleRotation(veh)
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				setElementData(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				
				setVehicleLocked(veh, false)
					
				setVehicleColor(veh, col1, col2, col1, col2)
					
				setVehicleOverrideLights(veh, 1)
				setVehicleEngineState(veh, false)
				setVehicleFuelTankExplodable(veh, false)
				
				local dimension = getElementDimension(thePlayer)
				local interior = getElementInterior(thePlayer)
				
				setElementData(veh, "dimension", dimension, false)
				setElementData(veh, "interior", interior, false)
				setElementData(veh, "job", job, job ~= 0)
				
				-- Set the vehicle armored if it is armored
				if (armoredCars[id]) then
					setVehicleDamageProof(veh, true)
				end
					
				local insertid = mysql:query_insert_free("INSERT INTO vehicles SET job='" .. job .. "', model='" .. id .. "', x='" .. x .. "', y='" .. y .. "', z='" .. z .. "', rotx='" .. rx .. "', roty='" .. ry .. "', rotz='" .. rz .. "', color1='" .. col1 .. "', color2='" .. col2 .. "', faction='-1', owner='-2', plate='" .. plate .. "', currx='" .. x .. "', curry='" .. y .. "', currz='" .. z .. "', currrx='0', currry='0', currrz='" .. r .. "', interior='" .. interior .. "', currinterior='" .. interior .. "', dimension='" .. dimension .. "', currdimension='" .. dimension .. "'")
				
				if (insertid) then
					exports.pool:allocateElement(veh, insertid)
					
					setElementData(veh, "dbid", insertid)
					setElementData(veh, "fuel", 100)
					setElementData(veh, "engine", 0, false)
					setElementData(veh, "oldx", x, false)
					setElementData(veh, "oldy", y, false)
					setElementData(veh, "oldz", z, false)
					setElementData(veh, "faction", -1)
					setElementData(veh, "owner", -2, false)
					setElementData(veh, "job", job, job ~= 0)
					setElementData(veh, "handbrake", 0, false)
					outputChatBox(getVehicleName(veh) .. " (Civilian) spawned with ID #" .. insertid .. ".", thePlayer, 255, 194, 14)
					
					exports.logs:logMessage("[MAKECIVVEH] " .. getPlayerName( thePlayer ) .. " created car #" .. insertid .. " (" .. getVehicleNameFromModel( id ) .. ")", 9)
					
					exports['vehicle-interiors']:add( veh )
				else
					destroyElement( veh )
				end
			end
		end
	end
end
addCommandHandler("makecivveh", createCivilianPermVehicle, false, false)

function loadAllVehicles(res)
	-- Reset player in vehicle states
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do
		setElementData(value, "realinvehicle", 0, false)
	end
	
	local null = mysql_null()
	local result = mysql:query("SELECT * FROM `vehicles` ORDER BY `id` ASC")
	if result then
		while true do
			local row = exports.mysql:fetch_assoc(result)
			if not (row) then
				break
			end
			
			for k, v in pairs( row ) do
				if v == null then
					row[k] = nil
				else
					row[k] = tonumber(row[k]) or row[k]
				end
			end
			
			-- Spawn the vehicle
			local veh = createVehicle(row.model, row.currx, row.curry, row.currz, row.currrx, row.currry, row.currrz, row.plate)
			if veh then
				setElementData(veh, "dbid", row.id)
				exports.pool:allocateElement(veh, row.id)
				
				-- color
				setVehicleColor(veh, row.color1, row.color2, row.color1, row.color2)
				
				-- Set the vehicle armored if it is armored
				if (armoredCars[row.model]) then
					setVehicleDamageProof(veh, true)
				end
				
				-- add the vehicle upgrades
				for i = 0, 16 do
					local upgrade = row['upgrade' .. i]
					if upgrade and upgrade > 0 then
						addVehicleUpgrade(veh, upgrade)
					end
				end
				
				-- paintjob
				setVehiclePaintjob(veh, row.paintjob)
				
				-- wheel states
				setVehicleWheelStates(veh, row.wheel1, row.wheel2, row.wheel3, row.wheel4)
				
				-- panel states (windshield broken etc)
				for i = 0, 6 do
					setVehiclePanelState(veh, i, row['panel' .. i])
				end
				
				-- door states
				for i = 0, 5 do
					setVehicleDoorState(veh, i, row['door' .. (i+1)])
				end
				
				-- lock the vehicle if it's locked
				setVehicleLocked(veh, row.owner ~= -2 and row.locked == 1)
				
				-- set the sirens on if it has some
				setVehicleSirensOn(veh, row.sirens == 1)
				
				-- job
				if row.job > 0 then
					toggleVehicleRespawn(veh, true)
					setVehicleRespawnDelay(veh, 60000)
					setVehicleIdleRespawnDelay(veh, 180000)
					setElementData(veh, "job", row.job)
				else
					setElementData(veh, "job", 0, false)
				end
				
				setVehicleRespawnPosition(veh, row.x, row.y, row.z, row.rotx, row.roty, row.rotz)
				setElementData(veh, "respawnposition", {row.x, row.y, row.z, row.rotx, row.roty, row.rotz}, false)
				
				-- element data
				setElementData(veh, "fuel", row.fuel, false)
				setElementData(veh, "oldx", row.currx, false)
				setElementData(veh, "oldy", row.curry, false)
				setElementData(veh, "oldz", row.currz, false)
				setElementData(veh, "faction", row.faction)
				setElementData(veh, "owner", row.owner)
				
				-- impound shizzle
				setElementData(veh, "Impounded", tonumber(row.Impounded))
				if tonumber(row.Impounded) > 0 then
					setVehicleDamageProof(veh, true)
				end
				
				-- interior/dimension
				setElementDimension(veh, row.currdimension)
				setElementInterior(veh, row.currinterior)
				
				setElementData(veh, "dimension", row.dimension, false)
				setElementData(veh, "interior", row.interior, false)
				
				-- lights
				setVehicleOverrideLights(veh, row.lights == 0 and 1 or row.lights )
				
				-- engine
				if row.hp <= 350 then
					setElementHealth(veh, 300)
					setVehicleDamageProof(veh, true)
					setVehicleEngineState(veh, false)
					setElementData(veh, "engine", 0, false)
					setElementData(veh, "enginebroke", 1, false)
				else
					setElementHealth(veh, row.hp)
					setVehicleEngineState(veh, row.engine == 1)
					setElementData(veh, "engine", row.engine, false)
					setElementData(veh, "enginebroke", 0, false)
				end
				setVehicleFuelTankExplodable(veh, false)
				
				-- handbrake
				if row.handbrake > 0 then
					setVehicleFrozen(veh, true)
				end
				
				--
				exports['vehicle-interiors']:add( veh )
			end
		end
		mysql:free_result(result)
	else
		outputDebugString( "loadAllVehicles failed" )
	end
	exports.irc:sendMessage("[SCRIPT] Loaded " .. #getElementsByType( "vehicle", getResourceRootElement( ) ) .. " vehicles.")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllVehicles)

function vehicleExploded()
	local job = getElementData(source, "job")
	
	if not job or job<=0 then
		setTimer(respawnVehicle, 60000, 1, source)
	end
end
addEventHandler("onVehicleExplode", getRootElement(), vehicleExploded)

function vehicleRespawn(exploded)
	local id = getElementData(source, "dbid")
	local faction = getElementData(source, "faction")
	local job = getElementData(source, "job")
	local owner = getElementData(source, "owner")
	
	if (job>0) then
		toggleVehicleRespawn(source, true)
		setVehicleRespawnDelay(source, 60000)
		setVehicleIdleRespawnDelay(source, 180000)
		setVehicleFrozen(source, true)
		setElementData(source, "handbrake", 1, false)
	end
	
	-- Set the vehicle armored if it is armored
	local vehid = getElementModel(source)
	if (armoredCars[tonumber(vehid)]) then
		setVehicleDamageProof(source, true)
	else
		setVehicleDamageProof(source, false)
	end
		
	setVehicleFuelTankExplodable(source, false)
	setVehicleEngineState(source, false)
	setVehicleLandingGearDown(source, true)

	setElementData(source, "enginebroke", 0, false)
	
	setElementData(source, "dbid", id)
	setElementData(source, "fuel", 100)
	setElementData(source, "engine", 0, false)
	
	local x, y, z = getElementPosition(source)
	setElementData(source, "oldx", x, false)
	setElementData(source, "oldy", y, false)
	setElementData(source, "oldz", z, false)
	
	setElementData(source, "faction", faction)
	setElementData(source, "owner", owner, false)
	
	setVehicleOverrideLights(source, 1)
	setVehicleFrozen(source, false)
	
	-- Set the sirens off
	setVehicleSirensOn(source, false)
	
	setVehicleLightState(source, 0, 0)
	setVehicleLightState(source, 1, 0)
	
	local dimension = getElementData(source, "dimension")
	local interior = getElementData(source, "interior")
	
	setElementDimension(source, dimension)
	setElementInterior(source, interior)
	
	-- unlock civ vehicles
	if owner == -2 then
		setVehicleLocked(source, false)
		setVehicleFrozen(source, true)
		setElementData(source, "handbrake", 1, false)
	end
end
addEventHandler("onVehicleRespawn", getRootElement(), vehicleRespawn)

function setEngineStatusOnEnter(thePlayer, seat)
	if seat == 0 then
		local engine = getElementData(source, "engine")
		local model = getElementModel(source)
		if not (enginelessVehicle[model]) then
			if (engine==0) then
				toggleControl(thePlayer, 'brake_reverse', false)
				setVehicleEngineState(source, false)
			else
				toggleControl(thePlayer, 'brake_reverse', true)
				setVehicleEngineState(source, true)
			end
		else
			toggleControl(thePlayer, 'brake_reverse', true)
			
			setVehicleEngineState(source, true)
			setElementData(source, "engine", 1, false)
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setEngineStatusOnEnter)

function vehicleExit(thePlayer, seat)
	if (isElement(thePlayer)) then 
		toggleControl(thePlayer, 'brake_reverse', true)
		-- For oldcar
		local vehid = getElementData(source, "dbid")
		setElementData(thePlayer, "lastvehid", vehid, false)
	end
end
addEventHandler("onVehicleExit", getRootElement(), vehicleExit)

function destroyTyre(veh)
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(veh)
	
	if (tyre1==1) then
		tyre1 = 2
	end
	
	if (tyre2==1) then
		tyre2 = 2
	end
	
	if (tyre3==1) then
		tyre3 = 2
	end
	
	if (tyre4==1) then
		tyre4 = 2
	end
	
	if (tyre1==2 and tyre2==2 and tyre3==2 and tyre4==2) then
		tyre3 = 0
	end
	
	removeElementData(veh, "tyretimer")
	setVehicleWheelStates(veh, tyre1, tyre2, tyre3, tyre4)
end

function damageTyres()
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(source)
	local tyreTimer = getElementData(source, "tyretimer")
	
	if (tyretimer~=1) then
		if (tyre1==1) or (tyre2==1) or (tyre3==1) or (tyre4==1) then
			setElementData(source, "tyretimer", 1, false)
			local randTime = math.random(5, 15)
			randTime = randTime * 1000
			setTimer(destroyTyre, randTime, 1, source)
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), damageTyres)

-- Bind Keys required
function bindKeys()
	local players = exports.pool:getPoolElementsByType("player")
	for k, arrayPlayer in ipairs(players) do
		if not(isKeyBound(arrayPlayer, "j", "down", toggleEngine)) then
			bindKey(arrayPlayer, "j", "down", toggleEngine)
		end
		
		if not(isKeyBound(arrayPlayer, "l", "down", toggleLights)) then
			bindKey(arrayPlayer, "l", "down", toggleLights)
		end
		
		if not(isKeyBound(arrayPlayer, "k", "down", toggleLock)) then
			bindKey(arrayPlayer, "k", "down", toggleLock)
		end
	end
end

function bindKeysOnJoin()
	bindKey(source, "j", "down", toggleEngine)
	bindKey(source, "l", "down", toggleLights)
	bindKey(source, "k", "down", toggleLock)
end
addEventHandler("onResourceStart", getResourceRootElement(), bindKeys)
addEventHandler("onPlayerJoin", getRootElement(), bindKeysOnJoin)

function toggleEngine(source, key, keystate)
	local veh = getPedOccupiedVehicle(source)
	local inVehicle = getElementData(source, "realinvehicle")

	if veh and inVehicle == 1 then
		local seat = getPedOccupiedVehicleSeat(source)
		
		if (seat == 0) then
			local model = getElementModel(veh)
			if not (enginelessVehicle[model]) then
				local engine = getElementData(veh, "engine")
				
				if engine == 0 then
					local fuel = getElementData(veh, "fuel")
					local broke = getElementData(veh, "enginebroke")
					if broke == 1 then
						exports.global:sendLocalMeAction(source, "attempts to start the engine but fails.")
						outputChatBox("The engine is broken.", source)
					elseif exports.global:hasItem(veh, 74) then
						while exports.global:hasItem(veh, 74) do
							exports.global:takeItem(veh, 74)
						end
						
						blowVehicle(veh)
					elseif fuel >= 1 or exports.global:isPlayerSilverDonator(source) then
						toggleControl(source, 'brake_reverse', true)
						
						setVehicleEngineState(veh, true)
						setElementData(veh, "engine", 1, false)
					elseif fuel < 1 then
						exports.global:sendLocalMeAction(source, "attempts to turn the engine on and fails.")
						outputChatBox("This vehicle has no fuel.", source)
					end
				else
					toggleControl(source, 'brake_reverse', false)
					
					setVehicleEngineState(veh, false)
					setElementData(veh, "engine", 0, false)
				end
			end
		end
	end
end

function toggleLock(source, key, keystate)
	local veh = getPedOccupiedVehicle(source)
	local inVehicle = getElementData(source, "realinvehicle")
	
	if (veh) and (inVehicle==1) then
		triggerEvent("lockUnlockInsideVehicle", source, veh)
	elseif not veh then
		if not triggerEvent("lockUnlockHouse", source) then
			local x, y, z = getElementPosition(source)
			local nearbyVehicles = exports.global:getNearbyElements(source, "vehicle", 30)
			
			if #nearbyVehicles < 1 then return end
			
			local found = nil
			local shortest = 31
			for i, veh in ipairs(nearbyVehicles) do
				local dbid = tonumber(getElementData(veh, "dbid"))
				local distanceToVehicle = getDistanceBetweenPoints3D(x, y, z, getElementPosition(veh))
				if shortest > distanceToVehicle and ( getElementData(source, "adminduty") == 1 or exports.global:hasItem(source, 3, dbid) or (getElementData(source, "faction") > 0 and getElementData(source, "faction") == getElementData(veh, "faction")) ) then
					shortest = distanceToVehicle
					found = veh
				end
			end
			
			if found then
				triggerEvent("lockUnlockOutsideVehicle", source, found)
			end
		end
	end
end

function checkLock(thePlayer, seat, jacked)
	local locked = isVehicleLocked(source)
	
	if (locked) and not (jacked) then
		cancelEvent()
		outputChatBox("The door is locked.", thePlayer)
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), checkLock)

function toggleLights(source, key, keystate)
	local veh = getPedOccupiedVehicle(source)
	local inVehicle = getElementData(source, "realinvehicle")

	if (veh) and (inVehicle==1) then
		local model = getElementModel(veh)
		if not (lightlessVehicle[model]) then
			local lights = getVehicleOverrideLights(veh)
			local seat = getPedOccupiedVehicleSeat(source)

			if (seat==0) then
				if (lights~=2) then
					setVehicleOverrideLights(veh, 2)
					setElementData(veh, "lights", 1, false)
				elseif (lights~=1) then
					setVehicleOverrideLights(veh, 1)
					setElementData(veh, "lights", 0, false)
				end
			end
		end
	end
end

--/////////////////////////////////////////////////////////
--Fix for spamming keys to unlock etc on entering
--/////////////////////////////////////////////////////////

-- bike lock fix
function checkBikeLock(thePlayer)
	if (isVehicleLocked(source)) and (getVehicleType(source)=="Bike" or getVehicleType(source)=="Boat" or getVehicleType(source)=="BMX" or getVehicleType(source)=="Quad" or getElementModel(source)==568 or getElementModel(source)==571 or getElementModel(source)==572 or getElementModel(source)==424) then
		if not getElementData(thePlayer, "interiormarker") then
			outputChatBox("That vehicle is locked.", thePlayer, 255, 194, 15)
		end
		cancelEvent()
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), checkBikeLock)

function setRealInVehicle(thePlayer)
	if isVehicleLocked(source) then
		setElementData(thePlayer, "realinvehicle", 0, false)
		removePedFromVehicle(thePlayer)
		setVehicleLocked(source, true)
	else
		setElementData(thePlayer, "realinvehicle", 1, false)
		
		-- 0000464: Car owner message. 
		local owner = getElementData(source, "owner")
		local faction = getElementData(source, "faction")
		local carName = getVehicleName(source)
		
		if owner < 0 and faction == -1 then
			outputChatBox("(( This " .. carName .. " is a civilian vehicle. ))", thePlayer, 255, 195, 14)
		elseif (faction==-1) and (owner>0) then
			local ownerName = getCharacterName(owner)
			
			if ownerName then
				outputChatBox("(( This " .. carName .. " belongs to " .. ownerName .. ". ))", thePlayer, 255, 195, 14)
				if (getElementData(source, "Impounded") > 0) then
					local output = getRealTime().yearday-getElementData(source, "Impounded")
					outputChatBox("(( This " .. carName .. " has been Impounded for: " .. output .. (output == 1 and " Day." or " Days.") .. " ))", thePlayer, 255, 195, 14)
				end
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setRealInVehicle)

function setRealNotInVehicle(thePlayer)
	local locked = isVehicleLocked(source)
	
	if not (locked) then
		if (thePlayer) then
			setElementData(thePlayer, "realinvehicle", 0, false)
		end
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), setRealNotInVehicle)

-- Faction vehicles removal script
function removeFromFactionVehicle(thePlayer)
	local faction = getElementData(thePlayer, "faction")
	local vfaction = tonumber(getElementData(source, "faction"))
	local CanTowDriverEnter = (call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", thePlayer) == 2)
	if (vfaction~=-1) then
		local seat = getPedOccupiedVehicleSeat(thePlayer)
		local factionName = "this faction"
		for key, value in ipairs(exports.pool:getPoolElementsByType("team")) do
			local id = tonumber(getElementData(value, "id"))
			if (id==vfaction) then
				factionName = getTeamName(value)
				break
			end
		end
		if (faction~=vfaction) and (seat==0) then
			if (CanTowDriverEnter) then
				outputChatBox("(( This " .. getVehicleName(source) .. " belongs to '" .. factionName .. "'. ))", thePlayer, 255, 194, 14)
				setElementData(source, "enginebroke", 1, false)
				setVehicleDamageProof(source, true)
				setVehicleEngineState(source, false)
				return
			end
			outputChatBox("You are not a member of '" .. factionName .. "'.", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "realinvehicle", 0, false)
			removePedFromVehicle(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			setElementPosition(thePlayer, x, y, z)
		elseif faction == vfaction or seat ~= 0 then
			outputChatBox("(( This " .. getVehicleName(source) .. " belongs to '" .. factionName .. "'. ))", thePlayer, 255, 194, 14)
		end
	end
	local Impounded = getElementData(source,"Impounded")
	if (Impounded and Impounded > 0) then
		setElementData(source, "enginebroke", 1, false)
		setVehicleDamageProof(source, true)
		setVehicleEngineState(source, false)
	end
	if (CanTowDriverEnter) then -- Nabs abusing
		return
	end
	local vjob = tonumber(getElementData(source, "job"))
	local job = getElementData(thePlayer, "job")
	local seat = getPedOccupiedVehicleSeat(thePlayer)
	
	if (vjob>0) and (seat==0) then
		if (job~=vjob) then
			if (vjob==1) then
				outputChatBox("You are not a delivery driver. Visit city hall to obtain this job.", thePlayer, 255, 0, 0)
			elseif (vjob==2) then
				outputChatBox("You are not a taxi driver. Visit city hall to obtain this job.", thePlayer, 255, 0, 0)
			elseif (vjob==3) then
				outputChatBox("You are not a bus driver. Visit city hall to obtain this job.", thePlayer, 255, 0, 0)
			end
			setElementData(thePlayer, "realinvehicle", 0, false)
			removePedFromVehicle(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			setElementPosition(thePlayer, x, y, z)
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), removeFromFactionVehicle)

-- engines dont break down
function doBreakdown()
	if exports.global:hasItem(source, 74) then
		while exports.global:hasItem(source, 74) do
			exports.global:takeItem(source, 74)
		end
		
		blowVehicle(source)
	else
		local health = getElementHealth(source)
		local broke = getElementData(source, "enginebroke")

		if (health<=350) and (broke==0 or broke==false) then
			setElementHealth(source, 300)
			setVehicleDamageProof(source, true)
			setVehicleEngineState(source, false)
			setElementData(source, "enginebroke", 1, false)
			setElementData(source, "engine", 0, false)
			
			local player = getVehicleOccupant(source)
			if player then
				toggleControl(player, 'brake_reverse', false)
			end
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), doBreakdown)

-- 0000470: Water Vehicles
function checkWaterVehicles()
	for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
		if (isElementInWater(value) and not isVehicleBlown(value) and getVehicleType(value)~="Boat") then
			blowVehicle(value)
		end
	end
end
setTimer(checkWaterVehicles, 600000, 0)


------------------------------------------------
-- SELLS A VEHICLE
------------------------------------------------
function sellVehicle(thePlayer, commandName, targetPlayerName)
	-- can only sell vehicles outdoor, in a dimension is property
	if isPedInVehicle(thePlayer) then
		if not targetPlayerName then
			outputChatBox("SYNTAX: /" .. commandName .. " [partial player name / id]", thePlayer, 255, 194, 14)
			outputChatBox("Sells the Vehicle you're in to that Player.", thePlayer, 255, 194, 14)
			outputChatBox("Ask the buyer to use /pay to recieve the money for the vehicle.", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			if targetPlayer and getElementData(targetPlayer, "dbid") then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 20 then
					local theVehicle = getPedOccupiedVehicle(thePlayer)
					if theVehicle then
						local vehicleID = getElementData(theVehicle, "dbid")
						if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") or exports.global:isPlayerLeadAdmin(thePlayer) then
							if getElementData(targetPlayer, "dbid") ~= getElementData(theVehicle, "owner") then
								if exports.global:hasSpaceForItem(targetPlayer, 3) then
									if exports.global:canPlayerBuyVehicle(targetPlayer) then
										local query = mysql:query_free("UPDATE vehicles SET owner = '" .. getElementData(targetPlayer, "dbid") .. "' WHERE id='" .. vehicleID .. "'")
										if query then
											setElementData(theVehicle, "owner", getElementData(targetPlayer, "dbid"))
											
											exports.global:takeItem(thePlayer, 3, vehicleID)
											exports.global:giveItem(targetPlayer, 3, vehicleID)
											
											exports.logs:logMessage("[SELL] car #" .. vehicleID .. " was sold from " .. getPlayerName(thePlayer):gsub("_", " ") .. " to " .. targetPlayerName, 9)
											
											outputChatBox("You've successfully sold your " .. getVehicleName(theVehicle) .. " to " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
											outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " sold you a " .. getVehicleName(theVehicle) .. ".", targetPlayer, 0, 255, 0)
										else
											outputChatBox("Error 09001 - Report on Forums.", thePlayer, 255, 0, 0)
										end
									else
										outputChatBox(targetPlayerName .. " has already too much vehicles.", thePlayer, 255, 0, 0)
										outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " tried to sell you a car, but you have too much cars already.", targetPlayer, 255, 0, 0)
									end
								else
									outputChatBox(targetPlayerName .. " has no space for the vehicle keys.", thePlayer, 255, 0, 0)
									outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " tried to sell you a car, but you haven't got space for a key.", targetPlayer, 255, 0, 0)
								end
							else
								outputChatBox("You can't sell your own vehicle to yourself.", thePlayer, 255, 0, 0)
							end
						else
							outputChatBox("This vehicle is not yours.", thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("You must be in a Vehicle.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("sell", sellVehicle)

function lockUnlockInside(vehicle)
	local model = getElementModel(vehicle)
	local owner = getElementData(vehicle, "owner")
	local dbid = getElementData(vehicle, "dbid")
	
	if (owner ~= -2) then
		if not locklessVehicle[model] or exports.global:hasItem( source, 3, dbid ) then
			local locked = isVehicleLocked(vehicle)
			local seat = getPedOccupiedVehicleSeat(source)
			if seat == 0 or exports.global:hasItem( source, 3, dbid ) then
				if (locked) then
					setVehicleLocked(vehicle, false)
					exports.global:sendLocalMeAction(source, "unlocks the vehicle doors.")
				else
					setVehicleLocked(vehicle, true)
					exports.global:sendLocalMeAction(source, "locks the vehicle doors.")
				end
			end
		end
	else
		outputChatBox("(( You can't lock civilian vehicles. ))", source, 255, 195, 14)
	end
	
end
addEvent("lockUnlockInsideVehicle", true)
addEventHandler("lockUnlockInsideVehicle", getRootElement(), lockUnlockInside)


local storeTimers = { }

function lockUnlockOutside(vehicle)
	local dbid = getElementData(vehicle, "dbid")
	
	exports.global:applyAnimation(source, "GHANDS", "gsign3LH", 2000, false, false, false)
	
	if (isVehicleLocked(vehicle)) then
		setVehicleLocked(vehicle, false)
		exports.global:sendLocalMeAction(source, "presses on the key to unlock the vehicle. ((" .. getVehicleName(vehicle) .. "))")
		
		if not (exports.global:hasItem(source, 3, dbid) or (getElementData(source, "faction") > 0 and getElementData(source, "faction") == getElementData(vehicle, "faction"))) then
			exports.logs:logMessage("[UNLOCK] car #" .. dbid .. " was unlocked by " .. getPlayerName(source), 21)
		end
	else
		setVehicleLocked(vehicle, true)
		exports.global:sendLocalMeAction(source, "presses on the key to lock the vehicle. ((" .. getVehicleName(vehicle) .. "))")
		
		if not (exports.global:hasItem(source, 3, dbid) or (getElementData(source, "faction") > 0 and getElementData(source, "faction") == getElementData(vehicle, "faction"))) then
			exports.logs:logMessage("[LOCK] car #" .. dbid .. " was locked by " .. getPlayerName(source), 21)
		end
	end

	if (storeTimers[vehicle] == nil) or not (isTimer(storeTimers[vehicle])) then
		storeTimers[vehicle] = setTimer(storeVehicleLockState, 180000, 1, vehicle, dbid)
	end
end
addEvent("lockUnlockOutsideVehicle", true)
addEventHandler("lockUnlockOutsideVehicle", getRootElement(), lockUnlockOutside)

function storeVehicleLockState(vehicle, dbid)
	if (isElement(vehicle)) then
		local locked = isVehicleLocked(vehicle)
		local state = 0
		
		if (locked) then state = 1
		elseif (not locked) then state = 0 end
		
		local query = mysql:query_free("UPDATE vehicles SET locked='" .. state .. "' WHERE id='" .. dbid .. "' LIMIT 1")
		
		storeTimers[vehicle] = nil
	end
end

function fillFuelTank(veh, fuel)
	local currFuel = getElementData(veh, "fuel")
	local engine = getElementData(veh, "engine")
	if (math.ceil(currFuel)==100) then
		outputChatBox("This vehicle is already full.", source)
	elseif (fuel==0) then
		outputChatBox("This fuel can is empty.", source, 255, 0, 0)
	elseif (engine==1) then
		outputChatBox("You can not fuel running vehicles. Please stop the engine first.", source, 255, 0, 0)
	else
		local fuelAdded = fuel
		
		if (fuelAdded+currFuel>100) then
			fuelAdded = 100 - currFuel
		end
		
		outputChatBox("You added " .. math.ceil(fuelAdded) .. " litres of petrol to your car from your fuel can.", source, 0, 255, 0 )
		
		local gender = getElementData(source, "gender")
		local genderm = "his"
		if (gender == 1) then
			genderm = "her"
		end
		exports.global:sendLocalMeAction(source, "fills up " .. genderm .. " vehicle from a small petrol canister.")
		
		exports.global:takeItem(source, 57, fuel)
		exports.global:giveItem(source, 57, math.ceil(fuel-fuelAdded))
		
		setElementData(veh, "fuel", currFuel+fuelAdded, false)
		triggerClientEvent(source, "syncFuel", veh, currFuel+fuelAdded)
		--triggerClientEvent(source, "setClientFuel", source, currFuel+fuelAdded)
	end
end
addEvent("fillFuelTankVehicle", true)
addEventHandler("fillFuelTankVehicle", getRootElement(), fillFuelTank)

function getYearDay(thePlayer)
	local time = getRealTime()
	local currYearday = time.yearday
	
	outputChatBox("Year day is " .. currYearday, thePlayer)
end
addCommandHandler("yearday", getYearDay)

function removeNOS(theVehicle)
	removeVehicleUpgrade(theVehicle, getVehicleUpgradeOnSlot(theVehicle, 8))
	exports.global:sendLocalMeAction(source, "removes NOS from the " .. getVehicleName(theVehicle) .. ".")
end
addEvent("removeNOS", true)
addEventHandler("removeNOS", getRootElement(), removeNOS)

-- /VEHPOS /PARK
local destroyTimers = { }
function createShopVehicle(dbid, ...)
	local veh = createVehicle(unpack({...}))
	exports.pool:allocateElement(veh, dbid)
	
	setElementData(veh, "dbid", dbid)
	setElementData(veh, "requires.vehpos", 1, false)
	local timer = setTimer(checkVehpos, 3600000, 1, veh, dbid)
	table.insert(destroyTimers, {timer, dbid})
	
	exports['vehicle-interiors']:add( veh )
	
	return veh
end

function checkVehpos(veh, dbid)
	local requires = getElementData(veh, "requires.vehpos")
	
	if (requires) then
		if (requires==1) then
			local id = tonumber(getElementData(veh, "dbid"))
			
			if (id==dbid) then
				exports.logs:logMessage("[VEHPOS DELETE] car #" .. id .. " was deleted", 9)
				exports.irc:sendAdminMessage("Removing vehicle #" .. id .. " (Did not get Vehpossed).")
				destroyElement(veh)
				local query = mysql:query_free("DELETE FROM vehicles WHERE id='" .. id .. "' LIMIT 1")
				
				call( getResourceFromName( "item-system" ), "clearItems", veh )
				call( getResourceFromName( "item-system" ), "deleteAll", 3, id )
			end
		end
	end
end
-- VEHPOS
local PershingSquareCol = createColRectangle( 1420, -1775, 130, 257 )
local HospitalCol = createColRectangle( 1166, -1384, 52, 92 )

function setVehiclePosition(thePlayer, commandName)
	local veh = getPedOccupiedVehicle(thePlayer)
	if not veh or getElementData(thePlayer, "realinvehicle") == 0 then
		outputChatBox("You are not in a vehicle.", thePlayer, 255, 0, 0)
	else
		if call( getResourceFromName("tow-system"), "cannotVehpos", thePlayer ) then
			outputChatBox("Only Best's Towing and Recovery is allowed to park their vehicles on the Impound Lot.", thePlayer, 255, 0, 0)
		elseif isElementWithinColShape( thePlayer, HospitalCol ) and getElementData( thePlayer, "faction" ) ~= 2 and not exports.global:isPlayerAdmin(thePlayer) then
			outputChatBox("Only Los Santos Emergency Service is allowed to park their vehicles in front of the Hospital.", thePlayer, 255, 0, 0)
		elseif isElementWithinColShape( thePlayer, PershingSquareCol ) and getElementData( thePlayer, "faction" ) ~= 1  and not exports.global:isPlayerAdmin(thePlayer) then
			outputChatBox("Only Los Santos Police Department is allowed to park their vehicles on Pershing Square.", thePlayer, 255, 0, 0)
		else
			local playerid = getElementData(thePlayer, "dbid")
			local owner = getElementData(veh, "owner")
			local dbid = getElementData(veh, "dbid")
			local x, y, z = getElementPosition(veh)
			local TowingReturn = call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", thePlayer) -- 2 == in towing and in col shape, 1 == colshape only, 0 == not in col shape
			if (owner==playerid and TowingReturn == 0) or (exports.global:hasItem(thePlayer, 3, dbid)) or (TowingReturn == 2) or (exports.global:isPlayerAdmin(thePlayer) and exports.logs:logMessage("[AVEHPOS] " .. getPlayerName( thePlayer ) .. " parked car #" .. dbid .. " at " .. x .. ", " .. y .. ", " .. z, 9)) then
				if (dbid<0) then
					outputChatBox("This vehicle is not permanently spawned.", thePlayer, 255, 0, 0)
				else
					if (call(getResourceFromName("tow-system"), "CanTowTruckDriverGetPaid", thePlayer)) then
						-- pd has to pay for this impound
						exports.global:giveMoney(getTeamFromName("Best's Towing and Recovery"), 75)
						exports.global:takeMoney(getTeamFromName("Los Santos Police Department"), 75)
					end
					removeElementData(veh, "requires.vehpos")
					local rx, ry, rz = getVehicleRotation(veh)
					
					local interior = getElementInterior(thePlayer)
					local dimension = getElementDimension(thePlayer)
					
					local query = mysql:query_free("UPDATE vehicles SET x='" .. x .. "', y='" .. y .."', z='" .. z .. "', rotx='" .. rx .. "', roty='" .. ry .. "', rotz='" .. rz .. "', currx='" .. x .. "', curry='" .. y .. "', currz='" .. z .. "', currrx='" .. rx .. "', currry='" .. ry .. "', currrz='" .. rz .. "', interior='" .. interior .. "', currinterior='" .. interior .. "', dimension='" .. dimension .. "', currdimension='" .. dimension .. "' WHERE id='" .. dbid .. "'")
					setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
					setElementData(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
					setElementData(veh, "interior", interior)
					setElementData(veh, "dimension", dimension)
					outputChatBox("Vehicle spawn position set.", thePlayer)
					
					for key, value in ipairs(destroyTimers) do
						if (tonumber(destroyTimers[key][2]) == dbid) then
							local timer = destroyTimers[key][1]
							
							if (isTimer(timer)) then
								killTimer(timer)
								table.remove(destroyTimers, key)
							end
						end
					end
					
					if ( getElementData(veh, "Impounded") or 0 ) > 0 then
						local owner = getPlayerFromName( getCharacterName( getElementData( veh, "owner" ) ) )
						if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
							outputChatBox("((Best's Towing & Recovery)) #999 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the Impound to release it.", owner, 120, 255, 80)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("vehpos", setVehiclePosition, false, false)
addCommandHandler("park", setVehiclePosition, false, false)

function setVehiclePosition2(thePlayer, commandName, vehicleID)
	if exports.global:isPlayerAdmin( thePlayer ) then
		local vehicleID = tonumber(vehicleID)
		if not vehicleID or vehicleID < 0 then
			outputChatBox( "SYNTAX: /" .. commandName .. " [vehicle id]", thePlayer, 255, 194, 14 )
		else
			local veh = exports.pool:getElement("vehicle", vehicleID)
			if veh then
				removeElementData(veh, "requires.vehpos")
				local x, y, z = getElementPosition(veh)
				local rx, ry, rz = getVehicleRotation(veh)
				
				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)
				
				local query = mysql:query_free("UPDATE vehicles SET x='" .. x .. "', y='" .. y .."', z='" .. z .. "', rotx='" .. rx .. "', roty='" .. ry .. "', rotz='" .. rz .. "', currx='" .. x .. "', curry='" .. y .. "', currz='" .. z .. "', currrx='" .. rx .. "', currry='" .. ry .. "', currrz='" .. rz .. "', interior='" .. interior .. "', currinterior='" .. interior .. "', dimension='" .. dimension .. "', currdimension='" .. dimension .. "' WHERE id='" .. vehicleID .. "'")
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				setElementData(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				setElementData(veh, "interior", interior)
				setElementData(veh, "dimension", dimension)
				outputChatBox("Vehicle spawn position for #" .. vehicleID .. " set.", thePlayer)
				
				for key, value in ipairs(destroyTimers) do
					if (tonumber(destroyTimers[key][2]) == vehicleID) then
						local timer = destroyTimers[key][1]
						
						if (isTimer(timer)) then
							killTimer(timer)
							table.remove(destroyTimers, key)
						end
					end
				end
				
				if ( getElementData(veh, "Impounded") or 0 ) > 0 then
					local owner = getPlayerFromName( getCharacterName( getElementData( veh, "owner" ) ) )
					if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
						outputChatBox("((Best's Towing & Recovery)) #999 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the Impound to release it.", owner, 120, 255, 80)
					end
				end
				exports.logs:logMessage("[AVEHPOS] " .. getPlayerName( thePlayer ) .. " parked car #" .. vehicleID .. " at " .. x .. ", " .. y .. ", " .. z, 9)
			else
				outputChatBox( "Vehicle not found.", thePlayer, 255, 0, 0 )
			end
		end
	end
end
addCommandHandler("avehpos", setVehiclePosition2, false, false)
addCommandHandler("apark", setVehiclePosition2, false, false)

function setVehiclePosition3(veh)
	if call( getResourceFromName("tow-system"), "cannotVehpos", source ) then
		outputChatBox("Only Best's Towing and Recovery is allowed to park their vehicles on the Impound Lot.", source, 255, 0, 0)
	elseif isElementWithinColShape( source, HospitalCol ) and getElementData( source, "faction" ) ~= 2 and not exports.global:isPlayerAdmin(source) then
		outputChatBox("Only Los Santos Emergency Service is allowed to park their vehicles in front of the Hospital.", source, 255, 0, 0)
	elseif isElementWithinColShape( source, PershingSquareCol ) and getElementData( source, "faction" ) ~= 1  and not exports.global:isPlayerAdmin(source) then
		outputChatBox("Only Los Santos Police Department is allowed to park their vehicles on Pershing Square.", source, 255, 0, 0)
	else
		local playerid = getElementData(source, "dbid")
		local owner = getElementData(veh, "owner")
		local dbid = getElementData(veh, "dbid")
		local x, y, z = getElementPosition(veh)
		local TowingReturn = call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", source) -- 2 == in towing and in col shape, 1 == colshape only, 0 == not in col shape
		if (owner==playerid and TowingReturn == 0) or (exports.global:hasItem(source, 3, dbid)) or (TowingReturn == 2) or (exports.global:isPlayerAdmin(source) and exports.logs:logMessage("[AVEHPOS] " .. getPlayerName( source ) .. " parked car #" .. dbid .. " at " .. x .. ", " .. y .. ", " .. z, 9)) then
			if (dbid<0) then
				outputChatBox("This vehicle is not permanently spawned.", source, 255, 0, 0)
			else
				if (call(getResourceFromName("tow-system"), "CanTowTruckDriverGetPaid", source)) then
					-- pd has to pay for this impound
					exports.global:giveMoney(getTeamFromName("Best's Towing and Recovery"), 75)
					exports.global:takeMoney(getTeamFromName("Los Santos Police Department"), 75)
				end
				removeElementData(veh, "requires.vehpos")
				local rx, ry, rz = getVehicleRotation(veh)
				
				local interior = getElementInterior(source)
				local dimension = getElementDimension(source)
				
				local query = mysql:query_free("UPDATE vehicles SET x='" .. x .. "', y='" .. y .."', z='" .. z .. "', rotx='" .. rx .. "', roty='" .. ry .. "', rotz='" .. rz .. "', currx='" .. x .. "', curry='" .. y .. "', currz='" .. z .. "', currrx='" .. rx .. "', currry='" .. ry .. "', currrz='" .. rz .. "', interior='" .. interior .. "', currinterior='" .. interior .. "', dimension='" .. dimension .. "', currdimension='" .. dimension .. "' WHERE id='" .. dbid .. "'")
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				setElementData(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				setElementData(veh, "interior", interior)
				setElementData(veh, "dimension", dimension)
				outputChatBox("Vehicle spawn position set.", source)
				
				for key, value in ipairs(destroyTimers) do
					if (tonumber(destroyTimers[key][2]) == dbid) then
						local timer = destroyTimers[key][1]
						
						if (isTimer(timer)) then
							killTimer(timer)
							table.remove(destroyTimers, key)
						end
					end
				end
				
				if ( getElementData(veh, "Impounded") or 0 ) > 0 then
					local owner = getPlayerFromName( getCharacterName( getElementData( veh, "owner" ) ) )
					if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
						outputChatBox("((Best's Towing & Recovery)) #999 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the Impound to release it.", owner, 120, 255, 80)
					end
				end
			end
		else
			outputChatBox( "You can't park this vehicle.", source, 255, 0, 0 )
		end
	end
end
addEvent( "parkVehicle", true )
addEventHandler( "parkVehicle", getRootElement( ), setVehiclePosition3 )

function quitPlayer ( quitReason )
	if (quitReason == "Timed out") then -- if timed out
		if (isPedInVehicle(source)) then -- if in vehicle
			local vehicleSeat = getPedOccupiedVehicleSeat(source)
			if (vehicleSeat == 0) then	-- is in driver seat?
				local theVehicle = getPedOccupiedVehicle(source)
				local dbid = tonumber(getElementData(theVehicle, "dbid"))
				if (exports.global:hasItem(source, 3, dbid)) then -- has the player a key for this vehicle?
					if not isVehicleLocked(theVehicle) then -- check if the vehicle aint locked already
						local passenger1 = getVehicleOccupant( theVehicle , 1 )
						local passenger2 = getVehicleOccupant( theVehicle , 2 )
						local passenger3 = getVehicleOccupant( theVehicle , 3 )
						if (passenger1 == false) then -- Nobody in passenger seat 1
							if (passenger2 == false) then -- check seat 2
								if (passenger3 == false) then -- and finally check seat 3
									lockUnlockOutside(theVehicle)
									local engine = getElementData(theVehicle, "engine")
									if engine == 1 then -- stop the engine when its running
										setVehicleEngineState(theVehicle, false)
										setElementData(theVehicle, "engine", 0, false)
									end
									setElementData(theVehicle, "handbrake", 1, false)
									setVehicleFrozen(theVehicle, true)
								end
							end
						end
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerQuit",getRootElement(), quitPlayer)

function detachVehicle(thePlayer)
	if isPedInVehicle(thePlayer) and getPedOccupiedVehicleSeat(thePlayer) == 0 then
		local veh = getPedOccupiedVehicle(thePlayer)
		if getVehicleTowedByVehicle(veh) then
			detachTrailerFromVehicle(veh)
			outputChatBox("The trailer was detached.", thePlayer, 0, 255, 0)
		else
			outputChatBox("There is no trailer...", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("detach", detachVehicle)