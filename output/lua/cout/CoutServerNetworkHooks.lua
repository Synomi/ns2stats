// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com


local function OnCoutClientMessageReceived(client, message)
	local action = message.action
	local decoded = json.decode(message.message)

	for key,taulu in pairs(kCoutServerNetworkActions) do
			if taulu.action == action then
				taulu.func(client, decoded)
				return
			end
	end
	
	Shared.Message("Unable to find network action: " .. action)
	Shared.Message("Message received was: " .. message.message)
	

end

Server.HookNetworkMessage("CoutClientMessage", OnCoutClientMessageReceived) //serverillä hookataan clientiltä tullu message functioon