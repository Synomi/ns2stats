// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSsend.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

function RBPS:initLog ()       
    RBPSlogInit = true
    RBPSlog = ""    
    //if autobuild or cheats has been on
    RBPSskipLogging = false
end

function RBPS:addLog(tbl)
    //if autobuild or cheats 
    if RBPSskipLogging == true then return end

    if  RBPSlogInit == false then RBPS:initLog() end
    
    if tbl == nil then
        if RBPSdebug then
            Shared.Message("Trying to log null value!")
        end
  
        return
    end
    
    tbl.time = Shared.GetGMTString(false)
    tbl.gametime = Shared.GetTime() - RBPS.gamestarted
    RBPSlog = RBPSlog .. json.encode(tbl) .."\n"	
    //local data = RBPSlibc:CompressHuffman(RBPSlog)
    //Shared.Message("compress size: " .. string.len(data) .. "decompress size: " .. string.len(RBPSlibc:Decompress(data)))    
    
    if RBPSdebug then
	    Shared.Message("LOG:" .. json.encode(tbl))
	end
    
	if string.len(RBPSlog) > RBPSpartSize and RBPSgameFinished == 0 then //if game has ended do not split log anymore, 
                                                                         //data is send using another way in ns2gamerules		
        RBPS:sendData() //senddata also clears log
        		
	    RBPSlogPartNumber = RBPSlogPartNumber + 1
	end
end


function RBPS:sendData()
    //if autobuild or cheats 
    if RBPSskipLogging == true then return end   

    if RBPSconfig.tournamentMode and not RBPSrecordStats then //do not record stats        
        return
    end	
     
    local params = 
    {
        key = RBPSadvancedConfig.key,        
        roundlog = RBPSlog,
        part_number = RBPSlogPartNumber,
        last_part = RBPSgameFinished,
        map = Shared.GetMapName(),
    }    
    
    RBPSlastGameFinished = RBPSgameFinished
       
    
    if RBPSdebug then
	    Shared.Message("Sending part of data to :" .. RBPS.websiteDataUrl)
	end
		
	if RBPSlastLog == nil then
	    RBPSlastLogPartNumber = RBPSlogPartNumber	
	    RBPSlastLog = RBPSlog
	    RBPS:initLog() //clears log	    
    else //if we still have data in last log, we wont send data normally, since it would be duplicated data
    
        local totalLength = string.len(RBPSlastLog) + string.len(RBPSlog)
        
        if totalLength>500000 then //we dont want to have more than 500 000 characters since that seems to crash the server
            RBPSlastLog = nil //basicly log fails here, but continue anyway
        else
            RBPSlastLog = RBPSlastLog .. RBPSlog //save log in memory if we need to resend, keep last log also in memory if send failed	    
        end	
                        	    	   
	    RBPS:initLog() //clears log
	    //since we do not send log part we dont need to increase part count
	    RBPSlogPartNumber = RBPSlogPartNumber -  1 //is increased after this function happens
	    return
	end		
	
	Shared.SendHTTPRequest(RBPS.websiteDataUrl, "POST", params, function(response,status) RBPS:onHTTPResponseFromSend(client,"send",response,status) end)	       
		
    if RBPSgameFinished == 1 then //it takes some time for post send to finish, so after last piece, 
                             //reset RBPSlogPartNumber counter just in case
        RBPSgameFinished = 0
        RBPSlogPartNumber = 1 
    end
	
    RBPSsendStartTime = Shared.GetSystemTime()
end


function RBPS:resendData()
     
    local params = 
    {
        key = RBPSadvancedConfig.key,        
        roundlog = RBPSlastLog,
        part_number = RBPSlastLogPartNumber,
        last_part = RBPSlastGameFinished
    }           
    
    if RBPSdebug then
	    Shared.Message("Resending part of data to :" .. RBPS.websiteDataUrl)
	end	
	
	Shared.SendHTTPRequest(RBPS.websiteDataUrl, "POST", params, function(response,status) RBPS:onHTTPResponseFromSend(client,"send",response,status) end)	       
			
    RBPSsendStartTime = Shared.GetSystemTime()
    RBPSresendCount = RBPSresendCount + 1
end

function RBPS:onHTTPResponseFromSend(client,action,response,status)	
    if RBPSdebug and status then
        Shared.Message("Status: (" .. status.. ")")
    end
    local message = json.decode(response)
    if RBPSdebug then
        Shared.Message("Sending part of round data completed (" .. (Shared.GetSystemTime() - RBPSsendStartTime) .. " seconds)")
    end       
    
    if message then
    
        if string.len(response)>0 then //if we got somedata, that means send was completed            
            RBPSlastLog = nil
            RBPSsuccessfulSends = RBPSsuccessfulSends +1
        end
    
        if message.other then
		    RBPS:messageAll(message.other)
		end
		
        if RBPSdebug then
	        Shared.Message(json.encode(response))	
	    end
    
		if message.error == "NOT_ENOUGH_PLAYERS" then 
               local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))                            
            for p = 1, #playerList do 
                if RBPSdebug then
                    Shared.Message("Lopping through players, cur index: " .. p)            
                end                                     
                
                Cout:SendMessageToClient(playerList[p], "lastRoundNotEnoughPlayers",{lastRound = nil})                                                   
                  		    		                  
            end
            return
        end			
		
		if message.link then		   		  
            local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))                            
            for p = 1, #playerList do 
                if RBPSdebug then
                    Shared.Message("Lopping through players, cur index: " .. p)            
                end                                     
                
                Cout:SendMessageToClient(playerList[p], "lastRoundLink",{lastRound = RBPS.websiteUrl .. message.link})                                                   
                  		    		                  
            end
		end			
    elseif response then //if message = nil, json parse failed prob or timeout
        if string.len(response)>0 then //if we got somedata, that means send was completed            
            RBPSlastLog = nil
            RBPSsuccessfulSends = RBPSsuccessfulSends +1
        end
        Shared.Message("ns2stats.com: (" .. response .. ")")
	end
	
end



function RBPS:sendServerStatus(gameState)
local stime = Shared.GetGMTString(false)
local gameTime = Shared.GetTime() - RBPS.gamestarted
    local params = 
    {
        key = RBPSadvancedConfig.key,        
        players = json.encode(RBPS.Players),  
        state = gameState,
        time = stime,
        gametime = gameTime,
        map = Shared.GetMapName(),
    }           
    
    if RBPSdebug then
	    Shared.Message("Sending game status to :" .. RBPS.websiteStatusUrl)
	end	
	
	Shared.SendHTTPRequest(RBPS.websiteStatusUrl, "POST", params, function(response,status) RBPS:onHTTPResponseFromSendStatus(client,"sendstatus",response,status) end)	       
			    
end

function RBPS:onHTTPResponseFromSendStatus(client,action,response,status) 
    if RBPSdebug then
        if status then
            Shared.Message("sendstatus status: " .. status)
            else
            Shared.Message("gameStatus response: " .. response)
        end
    end
end








