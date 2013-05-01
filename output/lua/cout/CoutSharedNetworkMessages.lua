// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

local kCoutClientMessageJson =
{
    action = string.format("string (%d)", kMaxChatLength),
    message = string.format("string (%d)", kMaxJsonMessageLength)
}


local kCoutServerMessageJson =
{
    action = string.format("string (%d)", kMaxChatLength),
    message = string.format("string (%d)", kMaxJsonMessageLength)
}

Shared.RegisterNetworkMessage("CoutClientMessage", kCoutClientMessageJson) 
Shared.RegisterNetworkMessage("CoutServerMessage", kCoutServerMessageJson) 

