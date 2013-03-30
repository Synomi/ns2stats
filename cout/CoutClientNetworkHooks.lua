// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com


local function OnCoutServerMessageReceived(message)
	local action = message.action
	local decoded = json.decode(message.message)

	for key,taulu in pairs(kCoutClientNetworkActions) do
			if taulu.action == action then
				taulu.func(decoded)
				return
			end
	end
	
	Shared.Message("Unable to find server network action: " .. action)
	Shared.Message("Message received was: " .. message.message)
	

end

Client.HookNetworkMessage("CoutServerMessage", OnCoutServerMessageReceived) //serverillä hookataan clientiltä tullu message functioon