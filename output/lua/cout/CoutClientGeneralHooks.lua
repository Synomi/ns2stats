// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com
local lastClientUpdateSec = 0
local lastClientUpdate100ms = 0
local lastClientUpdate10ms = 0

local function CoutClientUpdate()
    
    if Shared.GetTime() - lastClientUpdateSec > 1 then
        lastClientUpdateSec = Shared.GetTime()
        Cout:processClientMessages()        
        //Shared.Message("One second timer?" .. Shared.GetTime())
    end
    
    if Shared.GetTime() - lastClientUpdate100ms > 0.1 then
        lastClientUpdate100ms = Shared.GetTime()
        //Cout:rotateTest()
        //Shared.Message("100mstimer?" .. Shared.GetTime())
    end
    
    if Shared.GetTime() - lastClientUpdate10ms > 0.01 then
        lastClientUpdate10ms = Shared.GetTime()
        Cout:rotateTest()
        //Shared.Message("100mstimer?" .. Shared.GetTime())
    end
end

Event.Hook("UpdateClient", CoutClientUpdate)

local function messageTest()
    Cout:addClientTextMessage(Client.GetScreenWidth()/2,Client.GetScreenHeight()/2,"I'm here for 5 seconds",5,Color(246/255, 254/255, 37/255 ),nil)         
    Cout:addClientTextMessage(Client.GetScreenWidth()/2,Client.GetScreenHeight()/3,"I'm here for 3 seconds",3,Color(246/255, 254/255, 37/255 ),nil)         
    Cout:addClientTextMessage(Client.GetScreenWidth()/2,Client.GetScreenHeight()/4,"I'm here for 10 seconds",10,Color(246/255, 254/255, 37/255 ),nil)         
    Cout:addClientTextMessage(Client.GetScreenWidth()/4,Client.GetScreenHeight()/2,"I'm here for 20 seconds",20,Color(246/255, 254/255, 37/255 ),nil)         
end



//Event.Hook("Console_t1",messageTest)


local function CoutVersion()
    Cout:PrintVersionInfo()
end

Event.Hook("Console_cout",CoutVersion)
