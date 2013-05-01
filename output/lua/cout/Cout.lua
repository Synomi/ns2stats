// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

kMaxJsonMessageLength = 255
CoutDebug = false
Script.Load("cout/CoutEntity.lua")
class 'Cout' (ClientTextOutFunctions)
if Server then
    kCoutServerMessages = {}
    Script.Load("lua/Server.lua")    
    Script.Load("cout/CoutSharedNetworkMessages.lua")
    Script.Load("cout/CoutServerNetworkHooks.lua")
	Script.Load("cout/CoutServerGeneralFunctions.lua")    
	Script.Load("cout/CoutServerNetworkActions.lua")
	Script.Load("cout/CoutServerNetworkFunctionsAndFunctionHooks.lua")
    if CoutDebug then
		Shared.Message("Cout loaded on server")    
	end
elseif Client then
    kCoutClientMessages = {}    
    Script.Load("lua/Client.lua")        
    Script.Load("cout/CoutSharedNetworkMessages.lua")
    Script.Load("cout/CoutClientNetworkHooks.lua")    
    Script.Load("cout/CoutClientGeneralFunctions.lua")
    Script.Load("cout/CoutClientGeneralHooks.lua")
	Script.Load("cout/CoutClientNetworkActions.lua")
	Script.Load("cout/CoutClientNetworkFunctionsAndFunctionHooks.lua")
	Script.Load("cout/CoutClientLogic.lua")
    if CoutDebug then
		Shared.Message("Cout loaded on client")    
	end
end

Cout.version = 0.11

function Cout:PrintVersionInfo()
    Shared.Message("Cout version: " .. Cout.version)
end


/*
 General goals:
 
 - Create easy to use library/class for sending data from server to client screen
 - Customizable client side output "windows".
 - Minimal cpu/network usage.
 - Useable with every mod.
 - Keep Client and Server functions separate somehow.
 
 Coding progress:
 - Start by finding out how to register and use network messages. 
        Use chat message as base for finding out how this works. 
 - Test data send from server to client
 - Find out how to write text to client screen.
 - Create customization options.
 
- Create function to display customizable message on client screen, for both server and client, server can use to display message on every client screen.
  


*/