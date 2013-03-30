// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSadvancedConfig.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================
    function RBPS:WriteDefaultAdvancedConfigFile(fileName, defaultConfig)

        local fileExists = io.open("config://" .. fileName, "r")
        if not fileExists then                      
            local configFile = io.open("config://" .. fileName, "w+")
            configFile:write(json.encode(defaultConfig, { indent = true }))
            io.close(configFile)                        
        end
        
    end
    
    
    function RBPS:saveAdvancedConfig()   
        local configFile = io.open("config://" .. RBPSadvancedConfigFileName, "w+")
        if configFile then                     
            configFile:write(json.encode(RBPSadvancedConfig, { indent = true }))
            io.close(configFile)
            newAdvancedSettingAdded = false
            Shared.Message("Added new setting(s) (or changed) into " .. RBPSadvancedConfigFileName .. " file.")
        else 
            if RBPSdebug then
                Shared.Message("Unable to open ns2stats advanced config file.")
            end
        end    
    end
 
    //advancedConfig>>
    RBPSadvancedConfigFileName = "ns2stats_advanced_settings.json"
    RBPSadvancedConfig = {}
    RBPSadvancedConfig.key = ""    
    RBPSadvancedConfig.unstuckTime = 5 //how long it takes to use unstuck    
    RBPSadvancedConfig.awardsMax = 5 //maxium number of awards to show
    RBPSadvancedConfig.helpText = "You can use 'stats' in console for commands and help."    
    
    RBPS:WriteDefaultAdvancedConfigFile(RBPSadvancedConfigFileName, RBPSadvancedConfig)
    RBPSadvancedConfig = RBPS:LoadConfigFile(RBPSadvancedConfigFileName)
    
    //new stuff       
    //if RBPSadvancedConfig.killstreaksEnabled == nil then //b223
  //      RBPSadvancedConfig.killstreaksEnabled = false
  //      newAdvancedSettingAdded = true
  //  end    
           
    if not RBPSadvancedConfig then
        Shared.Message("Error, cannot load ns2stats advanced config file, stats will not work!")            
    end           

//<<advancedConfig




