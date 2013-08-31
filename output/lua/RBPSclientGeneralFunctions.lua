// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSclientGeneralFunctions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================
       
function RBPS:sendServerInfo()
     
    local address, password = ""

    address = Client.GetOptionString(kLastServerConnected, "")
    password = Client.GetOptionString(kLastServerPassword, "")                      
    
    Cout:SendMessageToServer("serverInfo",{ip = address, password = password})	
end    

local kModStateNames =
    {
        getting_info    = "GETTING INFO",
        downloading     = "DOWNLOADING",
        unavailable     = "UNAVAILABLE",
        available       = "AVAILABLE",
    }

function RBPS:sendModsInfo()
    local modsString = ""
    for s = 1, Client.GetNumMods() do

        local state = Client.GetModState(s)
        local stateString = kModStateNames[state]
        if stateString == nil then
            stateString = "??"
        end 
        local name = Client.GetModTitle(s)        
        local active = Client.GetIsModActive(s) and "YES" or "NO"
        local subscribed = Client.GetIsSubscribedToMod(s) and "YES" or "NO"
        local percent = "100%"
        if active=="NO" and subscribed == "NO" then
            if name and name ~= "" then
                modsString = modsString .. name .. ","
            end                   
        end        
    end
    
    if modsString then
        Cout:SendMessageToServer("modsInfo",{mods = modsString})       
    end
end

function RBPS:getPlayerColor(count, default)
    //count 0-5
    Shared.Message("Setting color: " .. count)
    if count == 0 then return Color(255/255, 0/255, 0/255 )
    elseif count == 1 then return Color(24/255, 24/255, 24/255 )
    elseif count == 2 then return Color(0/255, 0/255, 255/255 )
    elseif count == 3 then return Color(0/255, 255/255, 0/255 )
    elseif count == 4 then return Color(255/255, 255/255, 255/255 )    
    else 
    Shared.Message("Can't find color")
    return default
    end
end

