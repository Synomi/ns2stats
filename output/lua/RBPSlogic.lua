// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSupgrades.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

local lastServerUpdateSec = 0
local lastState=""

local reloadMapTime = 1800
local reloadMapCounter = 0

local statusTime = 30
local statusCounter = 0

local autoArrangeCounter = 0
local autoArrangeTime = 45

function RBPS:init()
    RBPSinitDone = true    
    
    if RBPScreateAdminCommands and CreateServerAdminCommand then
        Script.Load("lua/RBPSadminCommands.lua")
        if RBPSdebug then
            Shared.Message("Admin commands created")
        end
    end

    if RBPSadvancedConfig.key == "" then    
        Shared.SendHTTPRequest(RBPS.websiteUrl .. "/api/generateKey/?s=7g94389u3r89wujj3r892jhr9fwj", "GET",
            function(response) RBPS:acceptKey(response) end)
    end
        
end

function RBPS:getAmountOfRealPlayers()
 local allPlayers = Shared.GetEntitiesWithClassname("Player")            
 local amount = 0     
    for index, fromPlayer in ientitylist(allPlayers) do                                                                          
        local client = Server.GetOwner(fromPlayer)
        if client and client:GetIsVirtual() == false then
            amount = amount + 1
        end
    end
    
    return amount
end

function RBPS:oneSecondTimer()
    if RBPSenabled then                  
    
        RBPS:doFunctionOverwrites()
          
        RBPS:playerUpdates()   

        RBPSnumperOfPlayers = RBPS:getNumberOfConnectedPlayers()      

        RBPS:tournamentModeLogic()

        RBPS:resendLogic()

        RBPS:resLogic()

        RBPS:gameLogic()         
          
        if newSettingAdded then //TODO find better place for this
            RBPS:saveConfig()                               
        end

        if newAdvancedSettingAdded then //TODO find better place for this        
            RBPS:saveAdvancedConfig()                
        end
        if RBPSinitDone == false then
            RBPS:init()
        end    
        
         statusCounter = statusCounter +1
    if RBPSconfig.enableStatusUpdates and statusCounter == statusTime then
        statusCounter = 0
        RBPS:sendServerStatus(lastState)
    end
    
    
        if RBPSconfig.enableELOAutoArrange and RBPSnumperOfPlayers > 7 then    
            if autoArrangeCounter == autoArrangeTime then                      
                RBPS:autoArrangeTeamsBasedOnELO()            
            end

            if RBPSwebDataFetched == false and autoArrangeCounter == autoArrangeTime -14 then //get web data for all players before auto arrange
                RBPS:messageAll("Auto-arrange in 15 seconds!")
            end

            if RBPSwebDataFetched == false and autoArrangeCounter == autoArrangeTime -7 then //get web data for all players before auto arrange
                RBPSwebDataFetched = true            
                RBPS:webGetPlayerData()
            end    
                    
            autoArrangeCounter = autoArrangeCounter +1
        end
        
    end    
        
    reloadMapCounter = reloadMapCounter +1
    if reloadMapCounter == reloadMapTime then
        reloadMapCounter = 0        
        if RBPS:getAmountOfRealPlayers() == 0 then //reload map
            Shared.Message("Reloading map for possible mod updates...")
            MapCycle_ChangeMap(Shared.GetMapName())
        end                
    end

    if GetGamerules():GetAutobuild() or Shared.GetCheatsEnabled() then        
        RBPSskipLogging = true
        return
    end
       
end

function RBPS:playerUpdates()

    local allPlayers = Shared.GetEntitiesWithClassname("Player")
   
    for index, fromPlayer in ientitylist(allPlayers) do    
        local client = Server.GetOwner(fromPlayer)        
        RBPS:UpdatePlayerInTable(client)			        
     end
    
end

function RBPSupdateServer()

    if Shared.GetTime() - lastServerUpdateSec > 1 then
        lastServerUpdateSec = Shared.GetTime()
        RBPS:oneSecondTimer()
    end     

end


Event.Hook("UpdateServer",RBPSupdateServer)

function RBPS:gameLogic()

    local entityList = Shared.GetEntitiesWithClassname("NS2Gamerules")
    
    local NS2GR = nil
    local state = "na"
    
    if entityList:GetSize() > 0 then
    
        NS2GR = entityList:GetEntityAtIndex(0) //get gamerules entity
        state = NS2GR:GetGameState()               

        //state 1 = waiting for players
        //state 2 = pregame starting soon
        //state 3 = pregame
        //state 4 = ongoing
        //state 5 = aliens win        
        //state 6 = marines win        
    else 
        Shared.Message("Unable to find NS2Gamerules!")
        return
    end
    
    if lastState == 3 and state == 4 then //game has started
        RBPS:gameStart()
    end
            
    if lastState == 4 and (state == 5 or state == 6) then //game has ended
    
        local winningTeam = 0        
        
        if NS2GR.losingTeam:GetTeamType() == 1 then
            winningTeam = 2
        elseif NS2GR.losingTeam:GetTeamType() == 2 then
            winningTeam = 1
        end
        
        local initialHiveTechIdString = "None"
        
        if NS2GR.initialHiveTechId then
                initialHiveTechIdString = EnumToString(kTechId, NS2GR.initialHiveTechId)
        end
        
        local params =
            {
                version = ToString(Shared.GetBuildNumber()),
                winner = ToString(winningTeam),
                length = string.format("%.2f", Shared.GetTime() - NS2GR.gameStartTime),
                map = Shared.GetMapName(),
                start_location1 = NS2GR.startingLocationNameTeam1,
                start_location2 = NS2GR.startingLocationNameTeam2,
                start_path_distance = NS2GR.startingLocationsPathDistance,
                start_hive_tech = initialHiveTechIdString,
            }
        RBPS:gameEnded(params)
    end                				                
           
    lastState = state
end

function RBPS:resLogic()
    if RBPSteam1ResGathered ~=0 then
        RBPS:addResourcesGatheredToLog(1,RBPSteam1ResGathered)
        RBPSteam1ResGathered = 0
    end
    
    if RBPSteam2ResGathered ~=0 then
        RBPS:addResourcesGatheredToLog(2,RBPSteam2ResGathered)
        RBPSteam2ResGathered = 0
    end

end

function RBPS:resendLogic()

    if RBPSlastLog then //means that last send is not completed yet, and we might have to resend
        if (Shared.GetSystemTime() - RBPSsendStartTime) > RBPSresendWaitTime then 
            //we did not reseice responce from ns2stats.com in time so we will resend last log
            RBPS:resendData()                                
        end       
    end
end

function RBPS:tournamentModeLogic()  

    local entityList = Shared.GetEntitiesWithClassname("NS2Gamerules")
    
    local NS2GR = nil
    local state = "na"
    
    if entityList:GetSize() > 0 then    
        NS2GR = entityList:GetEntityAtIndex(0) //get gamerules entity        
    else
        return
    end

    if RBPSprivateStartGame then
        RBPSgameStartCounter = RBPSgameStartCounter + 1
        if RBPSgameStartCounter >= 5 and RBPSgameStartCounter ~= 10 then
            RBPS:messageAll("Live starting in " .. (10-RBPSgameStartCounter) .. " seconds.")
        end
    end

    if RBPSprivateStartGame and RBPSgameStartCounter == 10 then
        RBPSprivateStartGame = false
        RBPSrecordStats = true
                
        //NS2GameRules:ResetGame
        //NS2GameRules:SetGameState(kGameState.Countdown)

        //NS2GameRules:countdownTime = NS2Gamerules.kCountDownLength

        //NS2GameRules:lastCountdownPlayed = nil
        RBPSgameStartCounter=0
        RBPS:messageAll("Live!")
                          
        RBPS.startGame = true
        
        //reset scores
        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do            
            if player.ResetScores then
                player:ResetScores()
            end            
        end

        NS2GR:ResetGame()        
        NS2GR:SetGameState(kGameState.Countdown)        
        NS2GR.countdownTime = kCountDownLength        
        NS2GR.lastCountdownPlayed = nil     
               
    end	

    if RBPSconfig.tournamentMode and not RBPSrecordStats and not RBPSprivateStartGame then
        //disable auto_team_balance until map change at least if tournament mode is enabled.
        Server.SetConfigSetting("auto_team_balance", nil)
        Server.SetConfigSetting("end_round_on_team_unbalance",nil)
        
        if RBPSwarmupMessageCounter == 0 then
            if not RBPSteam1ready and not RBPSteam2ready then
                RBPS:messageAll("Live game begins when both teams have typed ready in console.")
            end
            if RBPSteam1ready then
                RBPS:messageAll("Live game begins when aliens have typed ready in console.")
            end
            
            if RBPSteam2ready then
                RBPS:messageAll("Live game begins when marines have typed ready in console.")
            end
            
            RBPSwarmupMessageCounter = 120
        else
            RBPSwarmupMessageCounter = RBPSwarmupMessageCounter - 1
        end
    end
end


function RBPS:gameStart()   
    
    if RBPSconfig.tournamentMode and not RBPSrecordStats then
        RBPS:messageAll("This is a warmup game. Stats won't be recorded.")			        
    end			   

    RBPS.gamestarted = Shared.GetTime()                
    RBPS:addLog({action="game_start"})
    RBPS.Players = { } //clear current players
    if RBPSdebug then
        Shared.Message("Player list cleared, preparing to start game, adding current players to list.")
    end
                     

    local allPlayers = Shared.GetEntitiesWithClassname("Player")            

    for index, fromPlayer in ientitylist(allPlayers) do                    
        local client = Server.GetOwner(fromPlayer)
        RBPS:addPlayerToTable(client)                        
        RBPS:UpdatePlayerInTable(client)				
    end       

    RBPS:addPlayersToLog(0)
end

function RBPS:gameReset()
    
    if RBPSlastLog then //perform last try to send data which have not been sent
        RBPS:resendData()  
        RBPSlastLog = nil
    end
    
    
    if RBPSdebug then
        Shared.Message("Game reset!")
    end
        
    RBPSgameFinished = 0    
    RBPSteam1ready = false
    RBPSteam2ready = false
    RBPSgameStartCounter=0
    RBPSlogPartNumber = 1
    RBPSwarmupMessageCounter=30
    RBPSresendCount = 0
    RBPSsuccessfulSends = 0
    RBPStags = {}
    RBPS:initLog()
    RBPS:addLog({action="game_reset"})       
       
end

function RBPS:gameEnded(params)
    //auto arrange
    autoArrangeCounter = 0
    params.autoarrange = false
    if RBPSconfig.enableELOAutoArrange and RBPSautoArrangeGameStarted then
        params.autoarrange = true
        
        RBPSautoArrangeGameStarted = false
    elseif RBPSconfig.enableELOAutoArrange and not RBPSautoArrangeGameStarted then
        return //do nothing if game ends without auto arrange
    end
    
    RBPSgameFinished = 1 //do not split send anymore
    local awards = ""
    if RBPSconfig.awardsEnabled then
        awards = RBPS:processAwards()
    end
    
    /*
    local allPlayers = Shared.GetEntitiesWithClassname("Player")            
        //to get last kills
    for index, fromPlayer in ientitylist(allPlayers) do                        
        local client = Server.GetOwner(fromPlayer)
        RBPS:UpdatePlayerInTable(client)				
    end              
    */
    
    RBPS:addPlayersToLog(1)            
    local serverName = Server.GetName()
    params.action = "game_ended"

    params.statsVersion = RBPS.statsVersion                                
    params.serverName = serverName
    params.private = RBPSconfig.tournamentMode
    params.successfulSends = RBPSsuccessfulSends
    params.resendCount = RBPSresendCount
    params.serverInfo = RBPS:getServerInfoTable()
    params.mods = RBPSserverMods
    params.awards = awards    
    params.tags = RBPStags
    
    RBPS:addLog(params)                                  
    RBPSsendData()            
    RBPSrecordStats=false //for tournament mode     
end