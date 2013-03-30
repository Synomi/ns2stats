// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPScommunications.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

function RBPS:messageAll(msg)
    local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
    local player
    local client

    for p = 1, #playerList do       
        player = playerList[p]
        
        if player then
            client = Server.GetOwner(player)
        end

        if client then
            RBPS:PlayerSay(client:GetUserId(), msg) 
        end                      
    end
end


function RBPS:PlayerSay(steamId, msg)    
    local player = RBPS:GetPlayerMatchingSteamId(steamId)
    
    if player then                      
        if string.len(msg) > 1000 then
            Shared.Message("Responce was too long, not displaying. Probably an error message. This should be fixed soon.")
            return 
        end
        if string.len(msg) > 0 then    
            for token in string.gmatch(msg, "[^\n]+") do        
                Server.SendNetworkMessage(player, "Chat", BuildChatMessage(false, RBPSconfig.chatMessageSayer, -1, teamNumber, kNeutralTeamType, token), true)               
            end             
        end
    else
        Shared.Message("Player name not found when trying to pm: " .. msg)       
    end
    
end
function RBPS:GetPlayerList()

    local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))
    table.sort(playerList, function(p1, p2) return p1:GetName() < p2:GetName() end)
    return playerList
    
end


function RBPS:GetPlayerMatchingSteamId(steamId)

    assert(type(steamId) == "number")
    
    local match = nil
    
    local function Matches(player)
    
        local playerClient = Server.GetOwner(player)
        
        if playerClient == nil then return nil end
        
        if playerClient:GetUserId() == steamId then
            match = player
        end
        
    end
    RBPS:AllPlayers(Matches)()
    
    return match
    
end

function RBPS:AllPlayers(doThis)

    return function(client)
    
        local playerList = RBPS:GetPlayerList()
        for p = 1, #playerList do
        
            local player = playerList[p]
            doThis(player, client, p)
            
        end
        
    end
    
end

function RBPS:GetPlayerMatchingByName(name)
   
    local playerList = RBPS:GetPlayerList()
    for i=1,#playerList do
        if playerList[id]:GetName() == name then
            return i    
        end
    end
    
    return nil
    
end
