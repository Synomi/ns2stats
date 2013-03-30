// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

kCoutClientNetworkActions = {}

function Cout:createClientNetworkAction(action,func)
	table.insert(kCoutClientNetworkActions,{action = action, func = func})	
end
