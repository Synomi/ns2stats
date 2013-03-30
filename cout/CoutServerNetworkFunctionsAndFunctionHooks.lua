// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com


function Cout:addServerTextMessageToClient(player,x,y,text,displayDuration, color, id)    
    local textMessage = {
        x = string.format("%.3f", x),
        y = string.format("%.3f", y),
        text = text,
        displayDuration = displayDuration,
        color = color,
        id = id
    }    
        
    Cout:SendMessageToClient(player, "addClientTextMessage", textMessage)	
        
end

function Cout:addServerTextMessageToAllClients(x,y,text,displayDuration, color, id)
   local allPlayers = Shared.GetEntitiesWithClassname("Player")   
   
    for index, fromPlayer in ientitylist(allPlayers) do                    
        local client = Server.GetOwner(fromPlayer)
        if client ~= nil and client:GetIsVirtual() == false then   
            Cout:addServerTextMessageToClient(fromPlayer,x,y,text,displayDuration, color, id)
        end
    end           
end