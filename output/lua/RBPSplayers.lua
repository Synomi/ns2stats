// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPShookedFunctions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

RBPS.Players = { }

function RBPS:addKill(attacker_steamId,target_steamId)
//target_steamId not used yet
    for key,taulu in pairs(RBPS.Players) do		
		if taulu["steamId"] == attacker_steamId then	
		    taulu["killstreak"] = taulu["killstreak"] +1		    
		    RBPS:checkForMultiKills(taulu["name"],taulu["killstreak"])		    
		    taulu.kills = taulu.kills +1		
		    if taulu.killstreak > taulu.highestKillstreak then
		        taulu.highestKillstreak = taulu.killstreak
		    end
		end
		
		if taulu["steamId"] == target_steamId then	
		    taulu.deaths = taulu.deaths +1		
		end
    end
end

function RBPS:addPlayerToTable(client)
	
    if not client then return end
	
	if RBPS:IsClientInTable(client) == false then	
	    table.insert(RBPS.Players, RBPS:createPlayerTable(client))	    
	else
	    RBPS:setConnected(client)
	end
	
end
function RBPS:setConnected(client)
    //player disconnected and came back
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer then
        RBPSplayer["dc"]=false
    end
end
function RBPS:getNumberOfConnectedPlayers()
    local num=0
    for p = 1, #RBPS.Players do	
        local player = RBPS.Players[p]	    
        if not player.dc then
            num = num +1        
        end
    end
    return num
end

function RBPS:getVotersOnMapId(id)
    local num=0
    for p = 1, #RBPS.Players do	
        local player = RBPS.Players[p]	    
        if player.votedMap == id then
            num = num +1        
        end
    end
    
    return num
end

function RBPS:createPlayerTable(client)	
	local player = client:GetControllingPlayer()
	if player == nil then
	    Shared.Message("Tried to update nil player")
	    return
	end
	
	local newPlayer =
	{		
		isbot = client:GetIsVirtual(),
        steamId = client:GetUserId(),
		name = player:GetName(),
		score = HasMixin(player, "Scoring") and player:GetScore() or 0,
		ping = client:GetPing(),
		teamnumber = player:GetTeamNumber(),
		ipaddress = IPAddressToString(Server.GetClientAddress(client)),
		x=0,
		y=0,
		z=0,
		lx=0,
		ly=0,
		lz=0,
                wrh=0,                
                health = 0,
                armor = 0,
                pres = 0,
        unstuck = false,
        unstuckCounter = 0,
        lastCoords =0,
		index=0,		
		lifeform="",
	    weapon = "none",
	    lastCommand = 0,
	    dc = false,
        total_constructed=0,
        code=0,
        votedMap = 0,
        hasVoted = false,
        afkCount = 0,
		isCommander = false,
        weapons = {},
        damageTaken = {},
        kills = 0,
        deaths = 0,
        assists =0,
        killstreak =0,
        totalKills =0,
        totalDeaths=0,
        playerSkill=0,
        totalScore=0,
        totalPlayTime=0,
        playerLevel=0,
        highestKillstreak =0,
        jumps = 0,
        walked = 0, //not used        
        alien_ELO = 0,
        marine_ELO = 0,        
        marine_commander_ELO = 0,
        alien_commander_ELO = 0,
	}
	
	return newPlayer
end
function RBPS:weaponsAddMiss(RBPSplayer,weapon)
        
    if not RBPSplayer then return end       
            
    local foundId = false
      
    for i=1, #RBPSplayer.weapons do        
        if RBPSplayer.weapons[i].name == weapon then
            foundId=i             
            break
        end
    end

    if foundId then        
        RBPSplayer.weapons[foundId].miss = RBPSplayer.weapons[foundId].miss + 1
        
        if RBPSdebug then
            Shared.Message(json.encode(RBPSplayer.weapons[foundId]))
        end
    else //add new weapon              
        table.insert(RBPSplayer.weapons,
        {
            name = weapon,
            time = 0,
            miss = 1,
            player_hit = 0,                        
            structure_hit = 0,
            player_damage = 0,
            structure_damage = 0
        })        
    end
        
end

function RBPS:weaponsAddHit(RBPSplayer,weapon, damage)
       
    if not RBPSplayer then return end
    
    local foundId = false
      
    for i=1, #RBPSplayer.weapons do        
        if RBPSplayer.weapons[i].name == weapon then
            foundId=i 
            break
        end
    end

    if foundId then        
        RBPSplayer.weapons[foundId].player_hit = RBPSplayer.weapons[foundId].player_hit + 1
        RBPSplayer.weapons[foundId].player_damage = RBPSplayer.weapons[foundId].player_damage + damage
        
        
        if RBPSdebug then
            Shared.Message(json.encode(RBPSplayer.weapons[foundId]))
        end
    else //add new weapon              
        table.insert(RBPSplayer.weapons,
        {
            name = weapon,
            time = 0,
            miss = 0,
            player_hit = 1,
            structure_hit = 0,
            player_damage = damage,
            structure_damage = 0
        })        
    end
        
end


function RBPS:weaponsAddStructureHit(RBPSplayer,weapon, damage)
       
    if not RBPSplayer then return end
    
    local foundId = false
      
    for i=1, #RBPSplayer.weapons do        
        if RBPSplayer.weapons[i].name == weapon then
            foundId=i 
            break
        end
    end

    if foundId then        
        RBPSplayer.weapons[foundId].structure_hit = RBPSplayer.weapons[foundId].structure_hit + 1
        RBPSplayer.weapons[foundId].structure_damage = RBPSplayer.weapons[foundId].structure_damage + damage
        
        if RBPSdebug then
            Shared.Message(json.encode(RBPSplayer.weapons[foundId]))
        end
    else //add new weapon              
        table.insert(RBPSplayer.weapons,
        {
            name = weapon,
            time = 0,
            miss = 0,
            player_hit = 0,
            structure_hit = 1,
            player_damage = 0,
            structure_damage = damage
        })        
    end
        
end

function RBPS:updateWeaponData(RBPSplayer)
    // Happens every second, 
    // checks if current weapon exists in weapons table, 
    // if it does increases it by 1, if it doesnt its added
    
    local foundId = false
    
    for i=1, #RBPSplayer.weapons do        
        if RBPSplayer.weapons[i].name == RBPSplayer.weapon then foundId=i end
    end
    
    if foundId then        
        RBPSplayer.weapons[foundId].time = RBPSplayer.weapons[foundId].time + 1
    else //add new weapon              
        table.insert(RBPSplayer.weapons,
        {
            name = RBPSplayer.weapon,
            time = 1,
            miss = 0,
            player_hit = 0,
            structure_hit = 0,
            player_damage = 0,
            structure_damage = 0
        })        
    end

end

function RBPS:checkLifeformChange(player, newPlayer)
	local currentLifeform = newPlayer:GetMapName()
    local previousLifeform = player.lifeform
    
    if newPlayer:GetIsAlive() == false then
        currentLifeform = "dead"
    end
    
    if previousLifeform ~= currentLifeform then
    player.lifeform = currentLifeform
    RBPS:addLog({action = "lifeform_change", name = player.name, lifeform = currentLifeform, steamId = player.steamId})                                                                
    end        
    
    return player
end


function RBPS:checkTeamChange(player, newPlayer)
	local currentTeam = newPlayer:GetTeamNumber()
    local previousTeam = player.teamnumber
    
    if previousTeam ~= currentTeam then
        player.teamnumber = currentTeam
         RBPS:addPlayerJoinedTeamToLog(player, currentTeam)    
    end        
    
    return player
end
	
        
        
function RBPS:returnDisconnectedPlayer() //TODO: fix, this function doesnt really work

    local allPlayers = Shared.GetEntitiesWithClassname("Player")            
    local theplayer = nil
                
        for p = 1, #RBPS.Players do	
        
            local player = RBPS.Players[p]	    	               
            local found = false
            
            for index, fromPlayer in ientitylist(allPlayers) do                    
                local client = Server.GetOwner(fromPlayer)                
                
                if client ~= nil then
                if client:GetUserId() == player.steamId then
                    found = true                     
                end                
                end
            end           
            
            if found==false then
                if player.dc == false then
                    //player just disconnected                
                    theplayer=player                    
                end                
                player.dc = true
            else
                player.dc = false
            end
        end
    
    return theplayer
end

function RBPS:IsClientInTable(client)

	if not client then return false end
	
    local steamId = client:GetUserId()
	
	for p = 1, #RBPS.Players do	
	    local player = RBPS.Players[p]	    	   
	    
	    if player.steamId == steamId then
	        return true
	    end	    
    end
    
	return false
end

function RBPS:getAmountOfPlayersPerTeam(team)
local amount = 0
    for key,taulu in pairs(RBPS.Players) do
        if team == taulu.teamnumber and taulu.dc == false then
            amount = amount +1
        end
    end
    
    return amount
end

function RBPS:UpdatePlayerInTable(client)
	if not client then return end
	local player = client:GetControllingPlayer()
	local steamId = client:GetUserId()
	local origin = player:GetOrigin()
	
	if RBPSdebug and player == nil then 
	    Shared.Message("Trying to update nil player")
        return	
	end	
	
    local weapon = "none"
	
	for key,taulu in pairs(RBPS.Players) do
		--Jos taulun(pelaajan) steamid on sama kuin etsitt�v� niin p�ivitet��n tiedot.
		if (taulu["isbot"] == false and taulu["steamId"] == steamId) or (taulu["isbot"] == true and taulu["name"] == player:GetName()) then
		    taulu = RBPS:checkTeamChange(taulu,player)
		    taulu = RBPS:checkLifeformChange(taulu,player)
		   	
		   	if taulu.lifeform == "dead" then //TODO optimize, happens many times when dead
		   	    taulu.damageTaken = {}
		   	    taulu.killstreak = 0
		   	end		   	

            //weapon table>>
                if player.GetActiveWeapon and player:GetActiveWeapon() then
                    weapon = player:GetActiveWeapon():GetMapName()
                end
                
                taulu["weapon"] = weapon
                RBPS:updateWeaponData(taulu)
		    //weapon table<<
		    
		    if client:GetUserId() ~= 0 then
			    taulu["steamId"] = client:GetUserId()
			end
			taulu["name"] = player:GetName()
                        if type(player["GetAssistKills"]) ~= "nil" then                            
                            taulu["assists"] = player:GetAssistKills()
                        end
			if HasMixin(player, "Scoring") then taulu["score"] = player:GetScore() end
			taulu["ping"] = client:GetPing()
			taulu["teamnumber"] = player:GetTeamNumber()
			taulu["isbot"] = client:GetIsVirtual()		
			taulu["isCommander"] = player:GetIsCommander()                        

                        taulu['totalKills'] = player.totalKills
                        taulu['totalAssists'] = player.totalAssists
                        taulu['totalDeaths'] = player.totalDeaths
                        taulu['playerSkill'] = player.playerSkill
                        taulu['totalScore'] = player.totalScore
                        taulu['totalPlayTime'] = player.totalPlayTime
                        taulu['playerLevel'] = player.playerLevel
                        
                        //view roration
                        taulu['wrh'] = player:GetDirectionForMinimap()        
                        taulu['health'] = player:GetHealth()
                        taulu['armor'] = player:GetArmor()
                        taulu['pres'] = player:GetResources()
			
			if RBPSconfig.afkKickEnabled and RBPSnumperOfPlayers > RBPSconfig.afkKickPlayersToEnable and RBPS:areSameCoordinates(taulu,origin) then			
			    taulu["afkCount"] = taulu["afkCount"] + 1
			    			    			   
			    if taulu["afkCount"] == RBPSconfig.afkKickIdleTime and RBPS:isUserAdmin(nil,taulu["steamId"]) == false then 			    
			        taulu["afkCount"] = 0			        			       
			        			                                   
                    //use server.getowner for player kicking, prob same than kicking client, but there were complains about zombie players                                 
                    local afkPlayer = client:GetControllingPlayer()
                    local afkPlayerOwner = nil
                    if afkPlayer then
                        afkPlayerOwner = Server.GetOwner(afkPlayer)
                    end
                    
                    if afkPlayerOwner then
                        Server.DisconnectClient(afkPlayerOwner)
                        Shared.Message(string.format("%s afk kicked from the server", taulu["name"]))
                    end
                                               
			    end
			    
			    if taulu["afkCount"] == RBPSconfig.afkKickIdleTime*0.8 and RBPS:isUserAdmin(nil,taulu["steamId"])==false then 			    
			        RBPS:PlayerSay(taulu["steamId"],"Move or you are going to get afk kicked soon.")
			    end
			else
			    taulu["afkCount"] = 0
			end
			    
			taulu["x"] = origin.x
			taulu["y"] = origin.y
			taulu["z"] = origin.z		
			//Shared.Message("x: " .. taulu["x"] .. ", y: " .. taulu["y"] .. ", z: " .. taulu["z"])
			 
			if string.format("%.1f", taulu.x)~=string.format("%.1f", taulu.lx) then
			    if string.format("%.1f", taulu.y)~=string.format("%.1f", taulu.ly) then
			        if string.format("%.1f", taulu.z)~=string.format("%.1f", taulu.lz) then
			            taulu.lx=taulu.x
			            taulu.ly=taulu.y
			            taulu.lz=taulu.z			    
			        end
			    end
			end
			
			//unstuck feature>>
			if RBPSconfig.unstuck and taulu.unstuck then
		        if taulu.unstuckCounter == RBPSadvancedConfig.unstuckTime then
		        
                    if taulu.lastCoords ~= taulu.x + taulu.y + taulu.z then
                        RBPS:PlayerSay(client:GetUserId(),"You moved during unstuck counter, not unstucking.")
                        taulu.unstuckCounter=0
                        taulu.unstuck = false
                    else //did not move
                                        
                        local sameCoords = false		        
                        
                        RBPS:messageAll(player:GetName() .. " has used /unstuck.")
                        taulu.counter = 0
                        
                        if string.format("%.1f", taulu.x)==string.format("%.1f", taulu.lx) then
                            if string.format("%.1f", taulu.y)==string.format("%.1f", taulu.ly) then
                                if string.format("%.1f", taulu.z)==string.format("%.1f", taulu.lz) then
                                    sameCoords = true  
                                end
                            end
                        end
                        
                        taulu.unstuckCounter=0
                        taulu.unstuck = false
                        local checks=0
                        if sameCoords then //add some random and test if player is colliding
                            for c=1,20 do
                                local rx = math.random(-20,20)/100
                                local ry = math.random(-20,20)/100
                                local rz = math.random(-20,20)/100
                                                                                                                                
                                player:SetOrigin(Vector(taulu.lx+rx, taulu.ly+ry, taulu.lz+rz))                                
                                if player:GetIsColliding() == false then break end
                                         
                            end
                        else
                            player:SetOrigin(Vector(taulu.lx, taulu.ly, taulu.lz))
                        end		            		           
                    end
		            
		        else
		            RBPS:PlayerSay(client:GetUserId(),"Unstucking you in " .. (RBPSadvancedConfig.unstuckTime - taulu.unstuckCounter) .. " seconds.")
		            taulu.unstuckCounter = taulu.unstuckCounter +1		            
		            
		        end
			end
			
			for k,d in pairs(taulu.damageTaken) do		
			    d.time = d.time +1
			    if d.time > RBPSassistTime then                    
                    table.remove(taulu.damageTaken,k)			       
			    end
			end
			//<<
			
			return
		end
	end
	
end

function RBPS:getPlayerClientBySteamId(steamId)
if not steamId then return nil end
    
        for list, victim in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
        
			local client = Server.GetOwner(victim)
			if client and client:GetUserId() then
			
				if client:GetUserId() == tonumber(steamId) and client:GetIsVirtual() == false then									
					return client					
				end
			end
            
        end
        
        return nil
                        
end


function RBPS:getPlayerByClientId(client)
	if client == nil then 
        if RBPSdebug then
            Shared.Message("Unable to find player table using null client")
        end
        return 
    end
	    
	local steamId = client:GetUserId()
			

	for key,taulu in pairs(RBPS.Players) do		
	    if steamId then
		    if taulu["steamId"] == steamId then return taulu end
		end		
	end
	    if RBPSdebug then
	        Shared.Message("Unable to find player using steamId: " .. steamId)
	    end
	    
	return nil
end

function RBPS:getTeamCommanderSteamid(teamNumber)

    for key,taulu in pairs(RBPS.Players) do			    		       
        if taulu["isCommander"] and taulu["teamnumber"] == teamNumber then
		    return taulu["steamId"]
		end				
	end
	
	return -1
end

function RBPS:getPlayerBySteamId(steamId)
    for key,taulu in pairs(RBPS.Players) do			    		       
    
        if steamId then
		    if taulu["steamId"] .. "" == steamId .. "" then return taulu end
		end				
	end
	
	return nil
end

function RBPS:getPlayerByName(name)
    for key,taulu in pairs(RBPS.Players) do			    		       
        if name then
		    if taulu["name"] == name then return taulu end
		end				
	end
	
	return nil
end

function RBPS:getPlayerByClient(client)
	if client == nil then 
	    if RBPSdebug then
    	    Shared.Message("Unable to find player table using null client")
    	end
    	
        return 
    end
    local steamId = nil
    local name = nil
    if type(client["GetUserId"]) ~= "nil" then
    steamId = client:GetUserId()
    else
        if type(client["GetControllingPlayer"]) ~= "nil" then
                local player = client:GetControllingPlayer()
	            local name = player:GetName()               
            else
                return
        end
    end
				
	for key,taulu in pairs(RBPS.Players) do			    
		if steamId then
		    if taulu["steamId"] == steamId then return taulu end
		end
        
        if name then
		    if taulu["name"] == name then return taulu end
		end				
	end
	
	if RBPSdebug then
	    Shared.Message("Unable to find player using name")
	end
	    
	return nil
end


function RBPS:areSameCoordinates(a,b) //first parameter needs to be RBPS.Player
 local ax = string.format("%.1f", a.x)
 local ay = string.format("%.1f", a.y)
 local az = string.format("%.1f", a.z)
 local bx = string.format("%.1f", b.x)
 local by = string.format("%.1f", b.y)
 local bz = string.format("%.1f", b.z)
 
 if ax == bx and az == bz and ay == by then    
    return true
 end
 
 return false
end

function RBPS:addPlayerJoinedTeamToLog(player, newTeamNumber)

//	local client = Server.GetOwner(player)

    if RBPSconfig.tournamentMode and RBPSdebug == false then 
        //if player is on team 1 or 2 then teams wont be ready
            if player.teamnumber == 1 then
                if RBPSteam1ready then
                    RBPS:messageAll("Marine team is not ready anymore because " .. player.name .. " has left the team.");
                    RBPSteam1ready=false
                end
            end
            
            if player.teamnumber == 2 then
                if RBPSteam2ready then
                    RBPS:messageAll("Alien team is not ready anymore because " .. player.name .. " has left the team.");
                    RBPSteam2ready=false
                end
            end
        end
        
	local playerJoin = 
	{
		action="player_join_team",
		name = player.name,
		team=newTeamNumber,
		steamId = player.steamId,
		score = player.score
	}
    RBPS:addLog(playerJoin)
		
    //if newTeamNumber ~=0 then removed for now, caused quite a lot of load on ns2stats.org
        //RBPSstats(client, "stats", newTeamNumber, "nil")
    //end

end

function RBPS:findPlayerScoreFromTable(client)

	local steamId = client:GetUserId()
	
	for key,taulu in pairs(RBPS.Players) do			    
		if steamId then
		    if taulu["steamId"] == steamId then return taulu["score"] end
		end
	end
	
	return 0
end

function RBPS:addPlayersToLog(type)
 
    local tmp = {}
    
    if type == 0 then
        tmp.action = "player_list_start"
    else
        tmp.action = "player_list_end"
    end
    
    //reset codes
    for p = 1, #RBPS.Players do	
        local player = RBPS.Players[p]	    
        player.code = 0
    end
    
    tmp.list = RBPS.Players    
    
	RBPS:addLog(tmp)
end

function RBPS:clearPlayersTable()
	RBPS.Players = { }
end

--Debuggaus
function RBPS:PrintPlayersTable()
	/*for k,v in pairs(RBPS.Players) do
		for key,value in pairs(v) do
			print(key,value)
		end
		print("--------")
	end
	print("#########")*/
	print(json.encode(RBPS.Players))
end

function RBPS:PrintTable(tbl)
	for k,v in pairs(tbl) do
			print(k,v)
	end
end