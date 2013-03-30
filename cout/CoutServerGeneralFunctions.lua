// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com


function Cout:SendMessageToClient(player, action,table)	
local encoded = json.encode(table)
if CoutDebug then
    Shared.Message("Sending message to " .. player:GetName() .. " message length: " .. string.len(encoded))    
end
if string.len(encoded) > kMaxJsonMessageLength then
    Shared.Message("Warning: Cout is trying to send network message which is larger than kMaxJsonMessageLength!")
end

	Server.SendNetworkMessage(player,"CoutServerMessage",{action = action, message = encoded}, true)	
end


//tset
local function testHook()
for p=1,30 do
    Cout:addServerTextMessageToAllClients(1/2,p/31,"I " .. p .. "wqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqwqw21333333333331212312232r!",5,{r = 146, g = (p*20), b = p },p)
end
end

//Event.Hook("Console_t2",testHook)
