// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com


Cout:createClientNetworkAction("addClientTextMessage",
    function (message)    
    local col = Color(message.color.r/255, message.color.g/255, message.color.b/255 )
        Cout:addClientTextMessage(Client.GetScreenWidth() * message.x,Client.GetScreenHeight() * message.y,message.text,message.displayDuration, col, message.id)
    end
)