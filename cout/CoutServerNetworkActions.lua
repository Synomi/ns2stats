// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

kCoutServerNetworkActions = {}

function Cout:createServerNetworkAction(action,func)
	table.insert(kCoutServerNetworkActions,{action = action, func = func})	
end