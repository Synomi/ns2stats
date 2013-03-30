// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

//timer 1 sec
function Cout:processClientMessages()
    for key,message in pairs(kCoutClientMessages) do    
        
        if message.displayDuration > 0 then //display message
           message.displayDuration = message.displayDuration - 1
           //message.message:SetText(message.text .. " " .. message.displayDuration)
        end        
    end
    
    Cout:removeExpiredMessages()                       
    
end

function Cout:removeExpiredMessages()
    local deleted = false
    
    for key,message in pairs(kCoutClientMessages) do    
        if message.displayDuration < 1 then //remove message
            deleted = true
            
            if CoutDebug then
                Shared.Message("Removed client message id: " .. key .. " text: " .. message.text)
            end

            GUI.DestroyItem(message.message)  
            table.remove(kCoutClientMessages,key)                              
                        
        end
    
    end
    
    if deleted then 
        Cout:removeExpiredMessages() //called multiple times, because table.remove changes table order, i guess
    end
end