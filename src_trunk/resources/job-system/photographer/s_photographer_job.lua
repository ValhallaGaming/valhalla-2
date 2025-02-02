function getPaid(collectionValue)
	exports.global:giveMoney(getPlayerTeam(source), tonumber(collectionValue))
	
	local gender = getElementData(source, "gender")
	local genderm = "his"
	if (gender == 1) then
		genderm = "her"
	end
	
	exports.global:sendLocalMeAction(source,"hands " .. genderm .. " collection of photographs to the woman behind the desk.")
	exports.global:sendLocalText(source, "Victoria Greene says: Thank you. These should make the morning edition. Keep up the good work.", nil, nil, nil, 10)
	outputChatBox("#FF9933SAN News made $".. collectionValue .." from the photographs.", source, 255, 104, 91, true)
	exports.global:sendMessageToAdmins("SANNews: " .. tostring(getPlayerName(source)) .. " sold photos for $" .. collectionValue .. ".")
	exports.logs:logMessage(tostring(getPlayerName(source)) .. " sold photos for $" .. collectionValue .. ".", 10)
	updateCollectionValue(0)
end
addEvent("submitCollection", true)
addEventHandler("submitCollection", getRootElement(), getPaid)


function info()
	exports.global:sendLocalText(source, "Victoria Greene says: Hello, Sir. I'm taking the photos of our SAN News Photographers -", nil, nil, nil, 10)
	exports.global:sendLocalText(source, "but it seems you aren't one. Feel free to apply for SAN any time ((on the forums))!", nil, nil, nil, 10)
end
addEvent("sellPhotosInfo", true)
addEventHandler("sellPhotosInfo", getRootElement(), info)

function updateCollectionValue(value)
	mysql:query_free("UPDATE characters SET photos = " .. (tonumber(value) or 0) .. " WHERE id = " .. getElementData(source, "dbid") )
end
addEvent("updateCollectionValue", true)
addEventHandler("updateCollectionValue", getRootElement(), updateCollectionValue)

addEvent("getCollectionValue", true)
addEventHandler("getCollectionValue", getRootElement(),
	function()
		if getElementData( source, "loggedin" ) == 1 then
			local result = mysql:query_fetch_assoc("SELECT photos FROM characters WHERE id = " .. getElementData(source, "dbid") )
			if result then
				triggerClientEvent( source, "updateCollectionValue", source, tonumber( result["photos"] ) )
			end
		end
	end
)