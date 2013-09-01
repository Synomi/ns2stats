// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSconfig.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

  //temporary functions until they are in>>
    function RBPS:WriteDefaultConfigFile(fileName, defaultConfig)

        local fileExists = io.open("config://" .. fileName, "r")
        if not fileExists then
        
             //add map list>>                       
            if RBPSconfigFileName == fileName then
                local matchingFiles = { }
                defaultConfig.maps = {}
                Shared.GetMatchingFileNames("maps/*.level", false, matchingFiles)
                
                for _, mapFile in pairs(matchingFiles) do

                    local _, _, filename = string.find(mapFile, "maps/(.*).level")
                    local tagged,_ = string.match(filename, "ns2_", 1)
                    if tagged ~= nil then    
                        table.insert(defaultConfig.maps, filename)        
                    end    
                end                       
            end                        
            //<<
        
            local configFile = io.open("config://" .. fileName, "w+")
            configFile:write(json.encode(defaultConfig, { indent = true }))
            io.close(configFile)
            
            
        end
        
    end

    function RBPS:LoadConfigFile(fileName)

        Shared.Message("Loading " .. "config://" .. fileName)
        
        local openedFile = io.open("config://" .. fileName, "r")
        if openedFile then                     
        
            local parsedFile = json.decode(openedFile:read("*all")) or { }                                   
            io.close(openedFile)          
            return parsedFile
            
        end
        
        return nil
        
    end   
    //<<temporary functions until they are in
    
    function RBPS:saveConfig()   
        local configFile = io.open("config://" .. RBPSconfigFileName, "w+")
        if configFile then                     
            configFile:write(json.encode(RBPSconfig, { indent = true }))
            io.close(configFile)
            newSettingAdded = false
            Shared.Message("Added new setting(s) (or changed) into " .. RBPSconfigFileName .. " file.")
        else 
            if RBPSdebug then
                Shared.Message("Unable to open ns2stats config file.")
            end
        end    
    end
    
    //config>>
    RBPSconfigFileName = "ns2stats_config.json"
    RBPSconfig = {}    
    RBPSconfig.unstuck = true    
    RBPSconfig.votemapEnabled = true
    RBPSconfig.afkKickEnabled = true
    RBPSconfig.afkKickIdleTime = 180    
    RBPSconfig.killstreaksEnabled = false
    RBPSconfig.chatMessageSayer = "NS2Stats"
    RBPSconfig.tournamentMode = false
    RBPSconfig.awardsEnabled = true
    RBPSconfig.motdLine1 = "Welcome!"
    RBPSconfig.motdLine2 = ""
    RBPSconfig.motdLine3 = ""
    RBPSconfig.afkKickPlayersToEnable = 8
    RBPSconfig.enableELOAutoArrange = false
    RBPSconfig.enableStatusUpdates = true
    RBPSconfig.enableChatLogging = false
        
    RBPS:WriteDefaultConfigFile(RBPSconfigFileName, RBPSconfig)
    RBPSconfig = RBPS:LoadConfigFile(RBPSconfigFileName)
    
    //new stuff       
    if RBPSconfig.killstreaksEnabled == nil then //b223
        RBPSconfig.killstreaksEnabled = false
        newSettingAdded = true
    end
    
    if RBPSconfig.chatMessageSayer == nil then //b223
        RBPSconfig.chatMessageSayer = "NS2Stats"
        newSettingAdded = true
    end
    
    if RBPSconfig.tournamentMode == nil then //b227
        RBPSconfig.tournamentMode = false
        newSettingAdded = true
    end
    
    if RBPSconfig.awardsEnabled == nil then //b228
        RBPSconfig.awardsEnabled = true
        newSettingAdded = true
    end
    
    if RBPSconfig.motdLine1 == nil then //b228 2
        RBPSconfig.motdLine1 = "Welcome!"
        RBPSconfig.motdLine2 = ""
        RBPSconfig.motdLine3 = ""
        newSettingAdded = true
    end           
    
    if RBPSconfig.afkKickPlayersToEnable == nil then //b229
        RBPSconfig.afkKickPlayersToEnable = 8
        newSettingAdded = true
    end           
    
    if RBPSconfig.enableELOAutoArrange == nil then //b232
        RBPSconfig.enableELOAutoArrange = false
        newSettingAdded = true
    end           
    
    if RBPSconfig.enableStatusUpdates == nil then //b239
        RBPSconfig.enableStatusUpdates = true
        newSettingAdded = true
    end           

    if RBPSconfig.enableChatLogging == nil then //b254
        RBPSconfig.enableChatLogging = false
        newSettingAdded = true
    end     
            
    if not RBPSconfig then
        Shared.Message("Error, cannot load ns2stats config file, stats will not work!")            
    end           

//<<config




