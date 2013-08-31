// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSclientCoutActions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================    

if Cout.createClientNetworkAction then        
    Cout:createClientNetworkAction("askServerInfo",
        function (message)
            RBPS:sendServerInfo()
        end
    )
    
    Cout:createClientNetworkAction("askModsInfo",
        function (message)
            RBPS:sendModsInfo()
        end
    )

    Cout:createClientNetworkAction("lastRoundLink",
        function (message)
            RBPSlastRound = message.lastRound
            local col = Color(240/255, 240/255, 240/255 )             
            Cout:addClientTextMessage(Client.GetScreenWidth() * 1/2,Client.GetScreenHeight() * 5/6,"Round stats at "  .. RBPSlastRound,24, col, "lastRound")
            Cout:addClientTextMessage(Client.GetScreenWidth() * 1/2,Client.GetScreenHeight() * 5/6+34,"Type check in chat or console to open browser.",24,col,"lastRoundHelp")
            
                      local values = {   
           }   
           
           RBPSclientConfig.lastRoundLink = RBPSlastRound
           RBPS:saveClientConfig()
        end
    )
    
        Cout:createClientNetworkAction("lastRoundNotEnoughPlayers",
        function (message)
            RBPSlastRound = "http://ns2stats.com"
            local col = Color(240/255, 240/255, 240/255 )             
            Cout:addClientTextMessage(Client.GetScreenWidth() * 1/2,Client.GetScreenHeight() * 5/6,"Game did not have enough players for stats to save.",12, col, "lastRoundNotEnoughPlayers")            
            
        end
    )
    //awards
    Cout:createClientNetworkAction("awards",
        function (message)            
            table.insert(RBPSclientAwards,message.award)                        
        end
    )
    
    Cout:createClientNetworkAction("showAwards",
        function (message)            
            RBPS:clientShowAwards(message)            
        end
    )
end