// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPS.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

//loaded for client and server.    
Script.Load("lua/RBPSentity.lua")
class 'RBPS' (RoundBasedPlayerStats)
Script.Load("lua/RBPSplugins.lua")

RBPSforBuild = 257
RBPSenabled = nil


if Shared.GetBuildNumber()~= RBPSforBuild then
    Shared.Message("NS2Stats is running on untested build and will get updated soonish.")
    Shared.Message("Due this NS2Stats may work incorrectly and cause script errors")        
end

RBPSenabled = true
if RBPSenabled then
    
    //loaded only for server   
    RBPSdebug=true //shows debug information if true 
      
    if Server then
        
        Script.Load("lua/RBPSconfig.lua")        
        Script.Load("lua/RBPSadvancedConfig.lua")   
        Script.Load("lua/RBPSsend.lua")
        Script.Load("lua/RBPSlogic.lua")
        Script.Load("lua/RBPSplayers.lua")
        Script.Load("lua/RBPSgeneralFunctions.lua")
        Script.Load("lua/RBPShookedFunctions.lua")
        Script.Load("lua/RBPShooks.lua")
        Script.Load("lua/RBPSupgrades.lua")
        Script.Load("lua/RBPSstructure.lua")
        Script.Load("lua/RBPScommunications.lua")
        Script.Load("lua/RBPSpickable.lua")
        Script.Load("lua/RBPSresources.lua")
        Script.Load("lua/RBPSfunctionOverrides.lua")    
        Script.Load("lua/RBPSserverCoutActions.lua")    
        Script.Load("lua/RBPSmultiKills.lua")    
        Script.Load("lua/RBPSserverAwards.lua")    
        Script.Load("lua/RBPSserverAwardHelpers.lua")    
        Script.Load("lua/RBPSserverWebdata.lua")    
        Script.Load("lua/RBPSserverAutoArrange.lua")                                   
        Script.Load("lua/RBPSdevour.lua")      

        RBPSserverInfo = {} //for server ip+port+password        
        RBPS.gamestarted = 0 //initial value
        RBPSlogInit = false //initial value
        RBPSlog = nil //initial value
        RBPSlastLog = nil //last log which was send to ns2stats.com, saved in memory for resending in case send failed
        RBPSlastLogPartNumber = 0 //for resend
        RBPSlastGameFinished = 0 //for resend
        RBPSresendWaitTime = 30 //how long we wait until we resend log file if no response
        RBPSresendCount = 0 //counter for statistics
        RBPSsuccessfulSends = 0 //counter for statistics
        RBPSlogPartNumber = 1 //initial value
        RBPSpartSize = 160000 //length in characters - how often data is posted to ns2stats.com, max value ~500000    
        RBPSgameFinished = 0 //initial value
        RBPS.statsVersion = "0.42" //current version of ns2stats        
        RBPSteam1ready = false //initial value for tournament mode
        RBPSteam2ready = false //initial value for tournament mode
        RBPSprivateStartGame = false //initial value for tournament mode
        RBPSrecordStats = false //initial value for tournament mode
        RBPSgameStartCounter = 0 //initial value for tournament mode
        RBPSwarmupMessageCounter=30 //initial value for tournament mode
        RBPSnumperOfPlayers = 0 //initial value for for afkkick           
        RBPSsendStartTime = 0 //initial value for posted data time counter
        RBPSteam1ResGathered=0 //for res gathered
        RBPSteam2ResGathered=0 //for res gathered    
        RBPSassistTime = 12 //how long we keep assist damage in players
        RBPSoverwritesDone = false //original function overwrites intial value    
        RBPSnewSettingAdded = false //initial value, needed to save config file when able to
        RBPScreateAdminCommands = true//initial value    
        RBPSinitDone = false
        RBPSserverMods = nil //clients give this info
        //awards
        RBPSawards = nil
        RBPSnextAwardId = 0 //initial value    
        RBPStags = {} //initial value
        RBPSskipLogging = false //initial value

        //auto arrange
        RBPSautoArrangeGameStarted = false //initial value
        
        RBPS.websiteUrl = "http://ns2stats.com" //this is url which is shown in player private messages, so its for advertising
        RBPS.websiteDataUrl = "http://ns2stats.com/api/sendlog" //this is url where posted data is send and where it is parsed into database
        RBPS.websiteStatusUrl = "http://dev.ns2stats.com/api/sendstatus" //this is url where posted data is send on status sends
        RBPS.websiteApiUrl = "http://ns2stats.com/api"
        RBPS.websiteIngameUrl = "http://ingame.ns2stats.com"
        RBPSserverId = 0
        //webdata
        RBPSwebDataFetched = false
      
                     
        Shared.Message("NS2Stats loaded. Check out stats at ns2stats.com")       
                       
    else //if client loads the lua file
        RBPSlastRound = "http://ns2stats.com"        
        //awards
        RBPSshowingAwards = false //initial value
        RBPSnextAwardId = 0 //initial value         
           
        Script.Load("lua/RBPSclientHooks.lua")
        Script.Load("lua/RBPSclientCoutActions.lua")   
        Script.Load("lua/RBPSclientGeneralFunctions.lua") 
        Script.Load("lua/RBPSclientAwards.lua")    
        Script.Load("lua/RBPSclientAutoArrange.lua")
        Script.Load("lua/RBPSclientConfig.lua")
        Shared.Message("Server is using NS2stats, you can find your stats at ns2stats.com.")                    
        RBPS.websiteApiUrl = "http://ns2stats.com/api"
                
        //for map data updates        
        local val = math.random(1,50)        
        if  val == 25 then            
            RBPSsendMapData = true            
        end
    end

    //precache sounds
    RBPSsoundTriplekill = PrecacheAsset("sound/killstreaks.fev/killstreaks/triplekill")
    RBPSsoundMultikill = PrecacheAsset("sound/killstreaks.fev/killstreaks/multikill")
    RBPSsoundRampage = PrecacheAsset("sound/killstreaks.fev/killstreaks/rampage")
    RBPSsoundKillingspree = PrecacheAsset("sound/killstreaks.fev/killstreaks/killingspree")
    RBPSsoundDominating = PrecacheAsset("sound/killstreaks.fev/killstreaks/dominating")
    RBPSsoundUnstoppable = PrecacheAsset("sound/killstreaks.fev/killstreaks/unstoppable")
    RBPSsoundMegakill = PrecacheAsset("sound/killstreaks.fev/killstreaks/megakill")
    RBPSsoundUltrakill = PrecacheAsset("sound/killstreaks.fev/killstreaks/ultrakill")
    RBPSsoundOwnage = PrecacheAsset("sound/killstreaks.fev/killstreaks/ownage")
    RBPSsoundLudicrouskill = PrecacheAsset("sound/killstreaks.fev/killstreaks/ludicrouskill")
    RBPSsoundHeadhunter = PrecacheAsset("sound/killstreaks.fev/killstreaks/headhunter")
    RBPSsoundWhickedsick = PrecacheAsset("sound/killstreaks.fev/killstreaks/whickedsick")
    RBPSsoundMonsterkill = PrecacheAsset("sound/killstreaks.fev/killstreaks/monsterkill")
    RBPSsoundHolyshit = PrecacheAsset("sound/killstreaks.fev/killstreaks/holyshit")
    RBPSsoundGodlike = PrecacheAsset("sound/killstreaks.fev/killstreaks/godlike")
    RBPSsoundSuicide = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide")
    RBPSsoundSuicide2 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide2")
    RBPSsoundSuicide3 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide3")
    RBPSsoundSuicide4 = PrecacheAsset("sound/killstreaks.fev/killstreaks/suicide4")

function RBPS:print_r (t, name, indent)
  local tableList = {}
  function table_r (t, name, indent, full)
    local id = not full and name
        or type(name)~="number" and tostring(name) or '['..name..']'
    local tag = indent .. id .. ' = '
    local out = {}	-- result
    if type(t) == "table" then
      if tableList[t] ~= nil then table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
      else
        tableList[t]= full and (full .. '.' .. id) or id
        if next(t) then -- Table not empty
          table.insert(out, tag .. '{')
          for key,value in pairs(t) do 
            table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
          end 
          table.insert(out,indent .. '}')
        else table.insert(out,tag .. '{}') end
      end
    else 
      local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
      table.insert(out, tag .. val)
    end
    return table.concat(out, '\n')
  end
  return table_r(t,name or 'Value',indent or '')
end
 
function RBPS:pr (t, name)
  Shared.Message((RBPS:print_r(t,name)))
end

end
    
