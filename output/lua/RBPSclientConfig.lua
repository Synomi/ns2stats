// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSclientConfig.lua
//
//    Created by:   Synomi and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet ===================== 
RBPSclientConfig = {}

function RBPS:saveClientConfig()                                 
       local clientFile = io.open("config://" .. "ns2stats_client_data.json", "w+")   
       clientFile:write(json.encode(RBPSclientConfig, { indent = true }))
       io.close(clientFile)       
end

function RBPS:loadClientConfig()

        Shared.Message("Loading " .. "config://" .. "ns2stats_client_data.json")
        
        local openedFile = io.open("config://ns2stats_client_data.json", "r")
        if openedFile then                             
            RBPSclientConfig = json.decode(openedFile:read("*all")) or { }                                   
            io.close(openedFile)                                  
        end               
        
end   

RBPS:loadClientConfig()

//settings
local function RBPSclientSettings(val1, val2)  
    if not val1 then
        Shared.Message("NS2Stats settings:")
        Shared.Message("To change setting type: ns2stats_settings <setting to change> <possible values>")
        Shared.Message("[toggle_browser] - toggles between steam and in-game browser")        
        return
    elseif val1 == "toggle_browser" then
        if RBPSclientConfig.browser and RBPSclientConfig.browser == "steam" then
                RBPSclientConfig.browser = "in-game"
            else
                RBPSclientConfig.browser = "steam"                
        end     
        
        Shared.Message("check-command will now use " .. RBPSclientConfig.browser .. " browser.") 
    end
        
    RBPS:saveClientConfig()    
end

Event.Hook("Console_ns2stats_settings",RBPSclientSettings)