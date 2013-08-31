// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSserverWebdata.lua
//
//    Created by:   Synomi 
//
// ========= For more information, visit us at http://ns2stats.com or #ns2stats @ qnet =====================

RBPSwebPlayers = {} //table to store fetched player data

function RBPS:webGetPlayerData()
    local params = {}
    
    params.players = ""
    
    local allPlayers = Shared.GetEntitiesWithClassname("Player")            

    for index, fromPlayer in ientitylist(allPlayers) do                                                                          
        local client = Server.GetOwner(fromPlayer)
        if client and client:GetIsVirtual() == false then
            params.players = params.players .. client:GetUserId() .. ","            
        end
    end
    
    local url = RBPS.websiteUrl .. "/api/players"    
    
    Shared.SendHTTPRequest(url, "POST", params, function(response,status) RBPS:onWebdataResponse("webdata_all",response,status,nil) end)	  
end

function RBPS:webGetSinglePlayerData(steamId)
    local params = {}
    
    params.players = steamId .. ","    
                        
    local url = RBPS.websiteUrl .. "/api/players"    
        
    Shared.SendHTTPRequest(url, "POST", params, function(response,status) RBPS:onWebdataResponse("webdata_single",response,status,steamId) end)	  
end

function RBPS:onWebdataResponse(action,response,status,steamId)	
    if RBPSdebug and status then
        Shared.Message("Error: " .. status)
    end
    local message = json.decode(response)    
    if message then               
        if action == "webdata_all" then        
            RBPSwebPlayers = message
        elseif action == "webdata_single" then
            local exits = false
            //check if exists
            for key,p in pairs(RBPSwebPlayers) do            
                if p.id == message[1].id then
                    exits = true               
                end                    
            end
            if exits == false then        
                table.insert(RBPSwebPlayers,message[1])           
            end
            
            if RBPSautoArrangeGameStarted == true then //arrange player to team
                RBPS:autoArrangeOnePlayerToTeam(message[1].id)
            end
            
        end       
        
        //Shared.Message("Player list:")
        //for key,p in pairs(RBPSwebPlayers) do        
            //Shared.Message(json.encode(p)) 
        //end
        
     //else
      //  Shared.Message("Unable to receive player data from http://ns2stats.com")    
    end       
    
    if status or not message then //timeout or we got no data = player does not exists
        if action=="webdata_single" then
            if RBPSautoArrangeGameStarted == true then //arrange player to team
                RBPS:autoArrangeOnePlayerToTeam(steamId)
            end
        end
    end
end