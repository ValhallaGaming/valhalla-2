addCommandHandler( "pollresults",
	function( thePlayer )
		if exports.global:isPlayerAdmin( thePlayer ) or exports.global:isPlayerScripter( thePlayer ) or getPlayerTeam( thePlayer ) == getTeamFromName( "San Andreas Network" ) then
			local result = mysql_query( handler, "SELECT ( SELECT charactername FROM characters x WHERE x.id = c.election_votedfor ), COUNT(DISTINCT(account)) AS cnt FROM characters c WHERE election_canvote > 0 GROUP BY election_votedfor ORDER BY cnt DESC" )
			local results = { }
			local total = 0
			local notvoted = 0
			for res, row in mysql_rows( result ) do
				table.insert( results, { row[1] == mysql_null( ) and "Not voted" or row[1], row[2] } )
				if row[1] ~= mysql_null( ) then
					total = total + tonumber( row[2] )
				else
					notvoted = notvoted + tonumber( row[2] )
				end
			end
			mysql_free_result( result )
			
			-- stuff for people who werent voted
			local result = mysql_query( handler, "SELECT c.charactername, ( SELECT COUNT(*) FROM characters x WHERE x.election_votedfor = c.id ) AS cnt FROM characters c WHERE election_candidate = 1 ORDER BY cnt DESC" )
			for res, row in mysql_rows( result ) do
				if tonumber( row[2] ) and tonumber( row[2] ) == 0 then
					table.insert( results, { row[1], 0 } )
				end
			end
			triggerClientEvent( thePlayer, "showPollResults", thePlayer, results, total, notvoted )
		end
	end
)