// Created by Synomi aka Sint, cout-class for outputting text / images client side from server/client.
// Contact info: Synomi66@gmail.com

local tipNextHint = nil
local spinner = nil
function Cout:checkIfClientTextMessageExists(id)
    if not id then return false end
    
    for key,message in pairs(kCoutClientMessages) do    
        if message.id == id then return message end
    end
    
    return false
end

function Cout:addClientTextMessage(x,y,text,displayDuration, color, id)

    //if message with same id already exists in screen
    local message = Cout:checkIfClientTextMessageExists(id)
    if message then //update and reset duration
        message.displayDuration = displayDuration
        message.text = text
        message.x = x
        message.y = y
        message.color = color
        
        textMessage:SetPosition(Vector(x,y, 0))
        textMessage:SetText(text)  
        textMessage:SetColor(color)

        if CoutDebug then
            Shared.Message("Client message updated id: " .. id .. ", text : " .. text .. " display for: " .. displayDuration .. " seconds")
        end 
      
        return    
    end
    
    local clientTextMessage = {}        
    
    textMessage = GUI.CreateItem()
    textMessage:SetOptionFlag(GUIItem.ManageRender)
    textMessage:SetPosition(Vector(x,y, 0))
    textMessage:SetTextAlignmentX(GUIItem.Align_Center)
    textMessage:SetTextAlignmentY(GUIItem.Align_Center)
    textMessage:SetFontName("fonts/AgencyFB_small.fnt")
    textMessage:SetIsVisible( true )    
    textMessage:SetText(text)  
    textMessage:SetColor(color)   
     
    clientTextMessage.message = textMessage
    clientTextMessage.displayDuration = displayDuration
    clientTextMessage.displayed = false
    clientTextMessage.text = text //for debug
    clientTextMessage.id = id
    
    if CoutDebug then
        Shared.Message("Client message added, text : " .. text .. " display for: " .. displayDuration .. " seconds")
    end 
   
    table.insert(kCoutClientMessages,clientTextMessage)
    
end

function Cout:testText()
    tipNextHint = GUI.CreateItem()
    tipNextHint:SetOptionFlag(GUIItem.ManageRender)
    tipNextHint:SetPosition(Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() - 15, 0))
    tipNextHint:SetTextAlignmentX(GUIItem.Align_Center)
    tipNextHint:SetTextAlignmentY(GUIItem.Align_Center)
    tipNextHint:SetFontName("fonts/AgencyFB_small.fnt")
    tipNextHint:SetIsVisible( true )
    
    // Translate string to account for findings
    tipNextHint:SetText(" HELLO NS2! " )
    
       local spinnerSize   = GUIScale(100)
    local spinnerOffset = GUIScale(0)

    spinner = GUI.CreateItem()
    spinner:SetTexture("cout/images/test.dds")
    spinner:SetSize( Vector( spinnerSize, spinnerSize, 0 ) )
    spinner:SetPosition( Vector( Client.GetScreenWidth() - spinnerSize - spinnerOffset, Client.GetScreenHeight() - spinnerSize - spinnerOffset, 0 ) )
    spinner:SetBlendTechnique( GUIItem.Add )
end

function Cout:rotateTest()
   local spinnerSpeed  = 2           
   local time = Shared.GetTime()

    if spinner ~= nil then
        local angle = -time * spinnerSpeed
        spinner:SetRotation( Vector(0, 0, angle) )
    end
end

function Cout:SendMessageToServer(action,table)	
	Client.SendNetworkMessage("CoutClientMessage",{action = action, message = json.encode(table)}, true)
	if CoutDebug then
		Shared.Message("Sending message to server: " .. action)
	end
end


