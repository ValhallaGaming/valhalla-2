TotalSpikes=nil
Spike = {}
SpikeLimit=10
Shape1= {}
Shape2= {}

function PlacingSpikes(sourcePlayer, command)
	local theTeam = getPlayerTeam(sourcePlayer)
	local teamType = getElementData(theTeam, "type")
	
	if (teamType==2) then
		local x1,y1,z1 = getElementPosition(sourcePlayer)		
		local rotz = getPedRotation(sourcePlayer)
			if(TotalSpikes == nil or TotalSpikes < SpikeLimit) then
			if(TotalSpikes == nil) then
				TotalSpikes = 1
			else
				TotalSpikes = TotalSpikes+1
			end
			for value=1,SpikeLimit,1 do
				if(Spike[value] == nil) then

					Spike[value] = createObject ( 1593, x1, y1, z1-0.8, 0.0, 0.0, rotz+90.0)
					exports.pool:allocateElement(Spike[value])
					Shape[value] = createColCuboid ( x1-0.5, y1-0.5, z1-0.8, 2.0, 2.0, 2.5)
					exports.pool:allocateElement(Shape[value])
					setElementData(Shape[value], "type", "spikes")
					outputChatBox("Spawned spikes with ID:" .. value, sourcePlayer, 0, 194, 0)
					
					break
				end
			end
		else
			outputChatBox("Too many spikes are already spawned.", sourcePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("deployspikes", PlacingSpikes)

function ThrowSpikes(sourcePlayer, command)
	local theTeam = getPlayerTeam(sourcePlayer)
	local teamType = getElementData(theTeam, "type")
	
	if (teamType==2) then
		local x1,y1,z1 = getElementPosition(sourcePlayer)		
		local rotz = getPedRotation(sourcePlayer)
			if(TotalSpikes == nil or TotalSpikes < SpikeLimit) then
			if(TotalSpikes == nil) then
				TotalSpikes = 1
			else
				TotalSpikes = TotalSpikes+1
			end
			for value=1,SpikeLimit,1 do
				if(Spike[value] == nil) then
					-- some general stuff
					local px, py, pz = getElementPosition ( sourcePlayer )
					local rz = getPedRotation ( sourcePlayer )  
					
					
					-- some calculations to find the place for the object
					local distance = 5
					local x = distance*math.cos((rz+90)*math.pi/180)
					local y = distance*math.sin((rz+90)*math.pi/180)
					local b2 = 15 / math.cos(math.pi/180)
					local nx = px + x
					local ny = py + y
					local nz = pz - 0.8

					Spike[value] = createObject ( 2892, nx, ny, nz, 0.0, 0.0, rz)
					exports.pool:allocateElement(Spike[value])
					
					
					-- Object is done, now we need the colpolygen
					-- size of the object:
					--	1		10.0 		3
					--  x-------------------x
					--  |                   | 1.0  
					--	x-------------------x
					--  2					4

					
					-- create the colpolygon
					Shape1[value] = createColRectangle( (nx - 5), (ny - 5), 5.0, 5.0 )
					exports.pool:allocateElement(Shape1[value])
					Shape2[value] = createColRectangle( (nx), (ny), 5.0, 5.0 )
					exports.pool:allocateElement(Shape2[value])
					setElementData(Shape1[value], "type", "spikes")
					setElementData(Shape2[value], "type", "spikes")
					outputChatBox("Spawned spikes with ID:" .. value, sourcePlayer, 0, 194, 0)
					break
				end
			end
		else
			outputChatBox("Too many spikes are already spawned.", sourcePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("throwspikes", ThrowSpikes)

function RemovingSpikes(sourcePlayer, command, ID)
	local theTeam = getPlayerTeam(sourcePlayer)
	local teamType = getElementData(theTeam, "type")
	
	if (teamType==2) then
		if not (ID) then
		outputChatBox("SYNTAX: /removespikes [ID]", sourcePlayer, 255, 194, 14)
		
		else
			local message = tonumber(ID)
			if(Spike[message] ~= nil) then
				local x2,y2,z2 = getElementPosition(Spike[message])
				local x1,y1,z1 = getElementPosition(sourcePlayer)
				
				if (getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2) <= 10) then
					outputChatBox("Removed spikes with ID:" .. message, sourcePlayer, 0, 194, 0)
					TotalSpikes = TotalSpikes -1
					destroyElement(Spike[message])
					Spike[message] = nil
					destroyElement(Shape1[message])
					Shape1[message] = nil
					if isElement(Shape2[message]) then
						destroyElement(Shape2[message])
						Shape2[message] = nil
					end
					if(TotalSpikes <= 0) then
						TotalSpikes = nil
					end
				else
					outputChatBox("You are too far from those spikes!", sourcePlayer, 255, 194, 14)
				end
			else
				outputChatBox("No spikes with that ID found!", sourcePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("removespikes", RemovingSpikes)

function AdminRemovingSpikes(sourcePlayer, command)
	if	(exports.global:isPlayerAdmin(sourcePlayer)) then
		for value=1,SpikeLimit,1 do
			if(Spike[value] ~= nil) then
				local id = tonumber ( value )
				destroyElement(Spike[id])
				Spike[id] = nil
				destroyElement(Shape1[id])
				Shape1[id] = nil
				if isElement(Shape2[id]) then
					destroyElement(Shape2[id])
					Shape2[id] = nil
				end
			end
		end
		outputChatBox("Removed all the spawned spikes.", sourcePlayer, 0, 194, 0)
		TotalSpikes = nil
	end
end
addCommandHandler("aremovespikes", AdminRemovingSpikes)

