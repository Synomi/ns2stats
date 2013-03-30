// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSserverCoutActions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================    
   
Cout:createServerNetworkAction("serverInfo",
    function(client,message)
        //message contains server ip and port, and maybe password
        if not message.password then
            message.password=""
        end
        
        RBPS:addServerIpPortAndPass(message.ip,message.password)   
    end
)

Cout:createServerNetworkAction("modsInfo",
    function(client,message)        
        if message and message.mods then
            RBPSserverMods = message.mods
        end
    end
)

    
        --Shared.Message("PASSWORD: " .. message.password)
        --if client then        
        --    local player = client:GetControllingPlayer()
        --    if player then 
        --        Shared.Message("Sender " .. player:GetName() .. " (" .. client:GetUserId() .. ")")                
        --    end 
        --end