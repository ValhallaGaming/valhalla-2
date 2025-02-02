mysql = exports.mysql

tags = {1524, 1525, 1526, 1527, 1528, 1529, 1530, 1531 }

function makeTagObject(cx, cy, cz, rot, interior, dimension)
	local tag = getElementData(source, "tag")
	if (tag~=9) then
		local obj = createObject(tags[tag], cx, cy, cz, 0, 0, rot+90)
		exports.pool:allocateElement(obj)
		setElementDimension(obj, dimension)
		setElementInterior(obj, interior)
		
		local id = mysql:query_insert_free("INSERT INTO tags SET x='" .. cx .. "', y='" .. cy .. "', z='" .. cz .. "', interior='" .. interior .. "', dimension='" .. dimension .. "', rx='0', ry='0', rz='" .. rot+90 .. "', modelid='" .. tags[tag] .. "', creationdate=NOW()")
		exports.global:sendLocalMeAction(source, "tags the wall.")
		setElementData(obj, "dbid", id, false)
		setElementData(obj, "type", "tag")
		outputChatBox("You have tagged the wall!", source, 255, 194, 14)
	else
		local distance = 2
		local colshape = createColSphere(cx, cy, cz, distance)
		exports.pool:allocateElement(colshape)
		local objects = getElementsWithinColShape(colshape, "object")
		
		local object = nil
		for key, value in ipairs(objects) do
			local objtype = getElementData(value, "type")
			if objtype=="tag" then
				local tx, ty, tz = getElementPosition(value)
				local tdistance = getDistanceBetweenPoints3D(cx,cy,cz,tx,ty,tz)
				if tdistance < distance then
					object = value
					distance = tdistance
				end
			end
		end
		
		if (object) then
			local id = getElementData(object, "dbid")
			outputChatBox("You removed the tag. You earnt 30$ for doing so.", source, 255, 194, 14)
			exports.global:giveMoney(source, 30)
			destroyElement(object)
			local query = mysql:query_free("DELETE FROM tags WHERE id='" .. id .. "'")
		end
		destroyElement(colshape)
	end
end
addEvent("createTag", true )
addEventHandler("createTag", getRootElement(), makeTagObject)

function clearNearbyTag(thePlayer)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local object = nil
		local dist = 999999
		for key, value in ipairs(exports.global:getNearbyElements(thePlayer, "object")) do
			local objtype = getElementData(value, "type")
			if (objtype=="tag") then
				local ox, oy, oz = getElementPosition(value)
				local distance = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz)
				if (distance<dist) then
					object = value
					dist = distance
				end
			end
		end
		
		if (object) then
			local id = getElementData(object, "dbid")
			destroyElement(object)
			local query = mysql:query_free("DELETE FROM tags WHERE id='" .. id .. "'")
			outputChatBox("Deleted tag with id #" .. id .. ".", thePlayer, 0, 255, 0)
		else
			outputChatBox("You are not near any tag.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("clearnearbytag", clearNearbyTag, false, false)

function loadAllTags(res)
	-- delete old tags
	mysql:query_free("DELETE FROM tags WHERE DATEDIFF(NOW(), creationdate) > 7")
	
	-- Load current ones
	local result = mysql:query("SELECT * FROM tags")
	local count = 0
	local highest = 0
	
	if (result) then
		local run = true
		while run do
			local row = exports.mysql:fetch_assoc(result)
			if not (row) then
				break
			end
			
			local id = tonumber(row["id"])
					
			local x = tonumber(row["x"])
			local y = tonumber(row["y"])
			local z = tonumber(row["z"])
				
			local interior = tonumber(row["interior"])
			local dimension = tonumber(row["dimension"])
				
			local rx = tonumber(row["rx"])
			local ry = tonumber(row["ry"])
			local rz = tonumber(row["rz"])
			local modelid = tonumber(row["modelid"])
				
			local object = createObject(modelid, x, y, z, rx, ry, rz)
			exports.pool:allocateElement(object)
			setElementInterior(object, interior)
			setElementDimension(object, dimension)
			setElementData(object, "dbid", id, false)
			setElementData(object, "type", "tag")
			count = count + 1
			if id > highest then
				highest = id
			end
		end

		mysql:query_free("ALTER TABLE `tags` AUTO_INCREMENT = " .. (highest + 1))
		
	end
	mysql:free_result(result)
	exports.irc:sendMessage("[SCRIPT] Loaded " .. count .. " Tags.")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllTags)

addEvent("updateTag", true)
addEventHandler("updateTag", getRootElement(),
	function(tag)
		mysql:query_free("UPDATE characters SET tag=" .. tag .. " WHERE id = " .. getElementData(source, "dbid"))
	end
)