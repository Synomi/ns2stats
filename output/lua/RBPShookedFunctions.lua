// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPShookedFunctions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================
function RBPSlistPlayers(client)
if not client then return end

    if not RBPSwebPlayers or #RBPSwebPlayers == 0 then
        ServerAdminPrint(client,"Player data has not been fetched yet, try again later.")
        return
    end
    
    ServerAdminPrint(client,"Players:")
    for key,p in pairs(RBPSwebPlayers) do        
        local RBPSplayer = RBPS:getPlayerBySteamId(p.id)
        local name = "Unknown"
        if RBPSplayer then        
            name = RBPSplayer.name
            
            if RBPSplayer.dc then
                name = name .. " (DC)"
            end
        end                
                
        ServerAdminPrint(client,name .. ", steam: " .. p.steam_name .. ", rank: " .. p.ranking .. ", rating: " .. p.rating)    
    end
end


function RBPSlistplayers(client)
    if not RBPSdebug then return end
    if not client then return end
    ServerAdminPrint(client,"#player list")
    
    for key,taulu in pairs(RBPS.Players) do		
	    ServerAdminPrint(client,json.encode(taulu))
	end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function RBPStag(client,tag)
if not client then return end
if string.len(tag)<30 then
        if tablelength(RBPStags) < 10 then
                table.insert(RBPStags,tag)
                ServerAdminPrint(client,"This game is now tagged as " .. tag)
            else
                ServerAdminPrint(client,"Game already contains maxium number of tags ")
        end
    else
        ServerAdminPrint(client,"Maximum length for tag is 30 characters")
end
Shared.Message("tags: " .. json.encode(RBPStags))
end
function RBPSclientConnect(client)
	if not Server then return end	
	if not client then return end
    RBPS:addPlayerToTable(client)
	
    local data = 
    {        
        action = "connect",
        steamId = client:GetUserId()
    }
    
    RBPS:addLog(data)	
    //RBPSstats(client, "motd", RBPS.statsVersion, nil)
    
    if RBPSconfig.motdLine1 ~= "" then
        RBPS:PlayerSay(client:GetUserId(),RBPSconfig.motdLine1)               
    end
    if RBPSconfig.motdLine2 ~= "" then
        RBPS:PlayerSay(client:GetUserId(),RBPSconfig.motdLine2)               
    end
    if RBPSconfig.motdLine3 ~= "" then
        RBPS:PlayerSay(client:GetUserId(),RBPSconfig.motdLine3)               
    end    
    
    if RBPSadvancedConfig.helpText ~= "" then    
        RBPS:PlayerSay(client:GetUserId(),RBPSadvancedConfig.helpText)
    end
    
    local player = client:GetControllingPlayer()
    if player then 
        Cout:SendMessageToClient(player, "askServerInfo",{action = "connect"})
    end
    
    if player then 
        Cout:SendMessageToClient(player, "askModsInfo",{action = "connect"})
    end

    if client:GetIsVirtual() == false and RBPSwebDataFetched == true then //data has been fetched already, so fetch for single player
        RBPS:webGetSinglePlayerData(client:GetUserId())
    end
end

function RBPSclientDisconnect(client)
	if not Server then return end
	local theplayer = nil
	if client then	
        if RBPSdebug then
            Shared.Message("Trying to find disconnected player by client")
        end
	    theplayer = RBPS:getPlayerByClient(client)
	else	
	    if RBPSdebug then
            Shared.Message("Trying to find disconnected player by checking all players.")
        end
	    theplayer = RBPS:returnDisconnectedPlayer()                                  
	end
    //when player disconnects find it by checking who is not there anymore. client variable doesnt work.
    
    theplayer.dc=true;
    
    if not theplayer and RBPSdebug then        
            Shared.Message("Unable to find disconnected player.")        
        return 
    else
        if RBPSdebug then
            Shared.Message(theplayer.name .. " disconnected")
        end
    end
    
    if RBPSconfig.tournamentMode then     
    //if player is on team 1 or 2 then teams wont be ready
        if theplayer.teamnumber == 1 then        
            if RBPSteam1ready then            
                RBPS:messageAll("Marine team is not ready anymore because " .. theplayer.name .. " has disconnected.");
                RBPSteam1ready=false
            end
            RBPScancelByDisconnect(theplayer)
        end
        
        if theplayer.teamnumber == 2 then
            if RBPSteam2ready then
                RBPS:messageAll("Alien team is not ready anymore because " .. theplayer.name .. " has disconnected.");
                RBPSteam2ready=false
            end
            RBPScancelByDisconnect(theplayer)
        end
    end
    
    local score = theplayer["score"]
    
    if score == nil then score = 0 end	
		
    local data = 
    {
        score = score,
        action = "disconnect",
        steamId = theplayer.steamId        
    }
    
    RBPS:addLog(data)
	
end


function RBPSstats(client, command, param2, param3)
    if not Server then return end
    if client == nil then        
        return
    end
    
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer == nil then        
        return
    end
    
    if command == "login" then
        if param2 then
            ServerAdminPrint(client,"Your login code is now set at: '" .. param2 .. "'")        	
            RBPSplayer.code = param2        
        else
            ServerAdminPrint(client,"Your login code currently set at: '" .. param2 .. "'")        	
        end        
        RBPSstats(client, "logintest", nil, nil)
        return                
    end
    
    if RBPSplayer.lastCommand == nil then RBPSplayer.lastCommand = 0 end
    local last = RBPSplayer.lastCommand + 2
    if last > Shared.GetSystemTime() then 
        ServerAdminPrint(client,"Please, wait a moment before using stats command again.")        	
        return 
    end
    
    RBPSplayer.lastCommand = Shared.GetSystemTime()
    
    if not client then return end
    if not command then command="help" end
    
    local player = client:GetControllingPlayer()
    if not param2 then param2 = "empty" end
    if not param3 then param3 = "empty" end
       
    Shared.SendHTTPRequest(RBPS.websiteUrl .. "/api/" .. command .. "/" .. client:GetUserId() .. "?a=" .. param2 .. "&b=" .. param3 .. "&key=" .. RBPSadvancedConfig.key .. "&code=" .. RBPSplayer.code, "GET",
         function(response) RBPS:onHTTPResp(client,command,response) end)

    
end


function RBPS:onHTTPResp(client,action,response)            
    if action == "stats" then        
         RBPS:PlayerSay(client:GetUserId(),response)               
    end       
    
    if client then
        ServerAdminPrint(client,response)        
    end
end
function RBPScancel(client)
    if not Server then return end

    if client == nil then        
        return
    end
    
    if not RBPSconfig.tournamentMode then 
         ServerAdminPrint(client,"Server is not running in tournament mode. Cancel command is not available.")
         return
    end
    
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer == nil then        
        return
    end
    
     if RBPSprivateStartGame then
        RBPSprivateStartGame = false
        RBPSrecordStats = false
        RBPSteam1ready = false
        RBPSteam2ready = false
        RBPSgameStartCounter=0
        RBPS:messageAll("Live game start has been cancelled. (" .. RBPSplayer.name .. ")")
     else
        ServerAdminPrint(client,"Live game is not starting, unable to cancel.")
     end
        
end


function RBPScancelByDisconnect(RBPSplayer)
    if not Server then return end

    if not RBPSplayer then return end
            
     if RBPSprivateStartGame then
        RBPSprivateStartGame = false
        RBPSrecordStats = false
        RBPSteam1ready = false
        RBPSteam2ready = false
        RBPSgameStartCounter=0
        RBPS:messageAll("Live game start has been cancelled because " .. RBPSplayer.name .. " disconnected.")     
     end
        
end



function RBPSnot(client,param1)
    if not Server then return end
    if client == nil then        
        return
    end
        
    if not ServerAdminPrint then return end
    
    if not RBPSconfig.tournamentMode then 
         ServerAdminPrint(client,"Server is not running in tournament mode. Notready command is not available.")
         return
    end
    
    if param1 then    
        if param1 ~= "ready" then return end
    end
    
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer == nil then        
        return
    end
    
     if RBPSplayer.teamnumber == 1 then                
         if RBPSteam1ready then
            RBPSteam1ready = false
            RBPS:messageAll("Marines are not ready anymore. (" .. RBPSplayer.name .. ")")
         else
            ServerAdminPrint(client,"Your team is not ready yet.")
         end         
     end
     
     if RBPSplayer.teamnumber == 2 then                
         if RBPSteam2ready then
            RBPSteam2ready = false
             RBPS:messageAll("Aliens are not ready anymore. (" .. RBPSplayer.name .. ")")
         else
            ServerAdminPrint(client,"Your team is not ready yet.")
         end         
     end
        
end

function RBPSnotready(client)
   if not Server then return end
   if not client then return end    
   if not ServerAdminPrint then return end     
   
    if not RBPSconfig.tournamentMode then 
         ServerAdminPrint(client,"Server is not running in tournament mode. Notready command is not available.")
         return
    end
   
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer == nil then        
        return
    end
    
     if RBPSplayer.teamnumber == 1 then                
         if RBPSteam1ready then
            RBPSteam1ready = false
            RBPS:messageAll("Marines are not ready anymore. (" .. RBPSplayer.name .. ")")
         else
            ServerAdminPrint(client,"Your team is not ready yet.")
         end         
     end
     
     if RBPSplayer.teamnumber == 2 then                
         if RBPSteam2ready then
            RBPSteam2ready = false
             RBPS:messageAll("Aliens are not ready anymore. (" .. RBPSplayer.name .. ")")
         else
            ServerAdminPrint(client,"Your team is not ready yet.")
         end         
     end
        
end

function RBPSready(client)    
    if not Server then return end

    if client == nil then        
        return
    end
    
    if not RBPSconfig.tournamentMode then 
         ServerAdminPrint(client,"Server is not running in tournament mode. Ready command is not available.")
         return
    end
    
    local RBPSplayer = RBPS:getPlayerByClient(client)
    
    if RBPSplayer == nil then        
        return
    end
    
    local team1wasReady = RBPSteam1ready
    local team2wasReady = RBPSteam2ready
    
        
    if RBPSplayer.teamnumber==1 then
        if not team1wasReady then
            if not RBPSteam2ready then
                RBPS:messageAll("Marines are ready, now waiting for alien team. (" .. RBPSplayer.name .. ")")
            else
                RBPS:messageAll("Both teams are ready. (" .. RBPSplayer.name .. ")")
            end
            
            RBPSteam1ready=true
        else
            ServerAdminPrint(client,"Your team is ready already.")
        end
    end
    
    if RBPSplayer.teamnumber==2 then
        if not team2wasReady then
            if not RBPSteam1ready then
                RBPS:messageAll("Aliens are ready, now waiting for marine team. (" .. RBPSplayer.name .. ")")
            else
                RBPS:messageAll("Both teams are ready. (" .. RBPSplayer.name .. ")")
            end
            
            RBPSteam2ready=true
        
        else
            ServerAdminPrint(client,"Your team is ready already.")            
        end
    end
                             
    if RBPSteam1ready and RBPSteam2ready then            
        RBPS:messageAll("Countdown for live game starting in 10 seconds! Cancel command is available.")
        RBPS:messageAll("In case someone is not ready in live, you can use ready again to reset.")
        RBPSprivateStartGame = true    
        RBPSrecordStats = true
    end
      
end

function RBPSvotemap(client,command)
    if not Server then return end
    if not client then 
        command = nil
        return 
    end        
    
    if not RBPSconfig.votemapEnabled and ServerAdminPrint then 
        ServerAdminPrint(client,"Votemap is not enabled on server.")    
        return 
    end                    

    if not command and ServerAdminPrint then RBPSlistMaps(client) end
    if not command then return end
    
    local theplayer = RBPS:getPlayerByClient(client)    
    
    if not theplayer then 
        command = nil    
        return
    end
    
    command = tonumber(command)        
    
     for p = 1, #RBPSconfig.maps do	        
        if p == command then
            command = nil            
                                    
            local needed = RBPS:getVotesNeeded()          

            //calculate number of votes on p
            theplayer.votedMap=p
            local votes = RBPS:getVotersOnMapId(p)
            
            
            if not theplayer.hasVoted then                           
                    RBPS:messageAll(theplayer.name ..  " has voted " ..  p .. " : " .. RBPSconfig.maps[p] .. " (".. votes  .. "/" .. needed .. ") votes.")
                    theplayer.hasVoted=true                    
            end
            
            ServerAdminPrint(client,"You have voted " .. RBPSconfig.maps[p] .. " (".. votes  .. "/" .. needed .. ") votes.")                
            
            //if we have enough votes
            if needed == votes then            
                RBPS:messageAll("Changing map into " .. RBPSconfig.maps[p])                
                                                                                                             
                MapCycle_ChangeMap( RBPSconfig.maps[p] )
            end
            
            return
        end
    end

    ServerAdminPrint(client,"Can't find map number: " .. command)                

end

function RBPSlistMaps(client)
    if not client then return end
    local numPlayers = RBPS:getNumberOfConnectedPlayers()
    local needed = RBPS:getVotesNeeded()    
    
 	ServerAdminPrint(client,"# Usage: votemap <map number>. Votes needed: " .. needed)	    
    for p = 1, #RBPSconfig.maps do		    
        ServerAdminPrint(client,p .. " : " .. RBPSconfig.maps[p] .. " (" .. RBPS:getVotersOnMapId(p) .. " votes)") 
    end
  
end

//test
function RBPSsendData()
	RBPS:sendData()
end

function voteRequirements()
    if not RBPSdebug then return end
    
    for a=1,32 do
    local needed = a
    needed= RBPS:round(needed/2-0.5,0) + RBPS:round(needed/5-0.5,0) + 1
    Shared.Message("Players " .. a .. " votes needed: " .. needed)
    end
end

function RBPSshowLog()
    if not RBPSdebug then return end
	Shared.Message("FULL LOG:")
	Shared.Message(RBPSlog)
end

function RBPSclientCommand(client)
    if not client then return end    
    if not RBPSdebug then return end
    local player = client:GetControllingPlayer()
    if player then                     
        Server.SendCommand(player, "connect arc.q-q.name:27030 gorge")
    end
             
end

