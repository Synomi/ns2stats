// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSserverAutoArrange.lua
//
//    Created by:   Synomi
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

//goal: 
/**
- auto arrange teams always and create even ELO teams.
- do not allow for change of team until 10mins or if other team has 2 less players.
- when game_reset happens and webdata has been fetched, then arrange teams based on ELO
- show both team average ratings.

*/

function RBPS:autoArrangeTeamsBasedOnELO()
    RBPS:autoArrangeSetELOs()
    
    RBPS:autoArrangeArrangeTeams()
        
    local entityList = Shared.GetEntitiesWithClassname("NS2Gamerules")
    
    local NS2GR = nil   
    
    if entityList:GetSize() > 0 then    
        NS2GR = entityList:GetEntityAtIndex(0) //get gamerules entity        
    else
        return
    end
    
    RBPSgameStartCounter=0
    RBPS:messageAll("Play!")
                  
    RBPS.startGame = true

    NS2GR:ResetGame()        
    NS2GR:SetGameState(kGameState.Countdown)        
    NS2GR.countdownTime = kCountDownLength        
    NS2GR.lastCountdownPlayed = nil   
    RBPSautoArrangeGameStarted = true
end

function RBPS:autoArrangeUpdatePlayerElo(steamId)
    for key,taulu in pairs(RBPS.Players) do
        if taulu.steamId == steamId then
            taulu.alien_ELO = 1500
            taulu.marine_ELO = 1500
            taulu.ELO_arranged = true
        end               
    end

    //set current ELOs
    for key,p in pairs(RBPSwebPlayers) do                
        if p.id == steamId then
            local RBPSplayer = RBPS:getPlayerBySteamId(p.id)        
            if RBPSplayer then       
                if p.alien_ELO then 
                    RBPSplayer.alien_ELO = tonumber(p.alien_ELO)                
                end
                if p.marine_ELO then 
                    RBPSplayer.marine_ELO = tonumber(p.marine_ELO)                
                end
            end                
        end                           
    end
end

function RBPS:autoArrangeOnePlayerToTeam(steamId)
    local marines = RBPS:getAmountOfPlayersPerTeam(1)
    local aliens = RBPS:getAmountOfPlayersPerTeam(2)
    
    RBPS:autoArrangeUpdatePlayerElo(steamId)
    
    if marines>aliens then
        RBPS:switchTeam(steamId, 2) 
    elseif aliens>marines then    
        RBPS:switchTeam(steamId, 1) 
    else
        local marine_elo = RBPS:autoArrangeCalculateAverageELO(1)
        local alien_elo = RBPS:autoArrangeCalculateAverageELO(2)
        if marine_elo > alien_elo then
            RBPS:switchTeam(steamId, 2) 
        elseif alien_elo > marine_elo then
            RBPS:switchTeam(steamId, 1) 
        else
            local randomTeam = math.random(1,2)
            RBPS:switchTeam(steamId, randomTeam)             
        end
    end       
    
end

function RBPS:autoArrangeArrangeTeams()
    //randomize first player            
    local firstTeam = math.random(1,2)
    Shared.Message("First team: " .. firstTeam)
    local player = nil
    local team = firstTeam
    player = RBPS:autoArrangeFindHighestAvailableELO(team)
    while player do        
        player.teamnumber = team //important to update this right away

        if team == 1 then            
            RBPS:switchTeam(player.steamId, team)            
            team = 2
        elseif team == 2 then
            RBPS:switchTeam(player.steamId, team)            
            team = 1
        end
        
        player = RBPS:autoArrangeFindHighestAvailableELO(team)
    end
    
    RBPS:messageAll("Teams have been auto-arranged by ELO ratings.")
    RBPS:messageAll("Marines (" .. RBPS:autoArrangeCalculateAverageELO(1) .. ") vs Aliens (" .. RBPS:autoArrangeCalculateAverageELO(2) .. ")")
        
end

function RBPS:autoArrangeCalculateAverageELO(team)
    local total = 0
    local amount = 0
    for key,taulu in pairs(RBPS.Players) do    
        if team==taulu.teamnumber then
            if team == 1 then
                total = total + taulu.marine_ELO                
            elseif team == 2 then
                total = total + taulu.alien_ELO                
            end
            amount = amount +1
        end
    end
    
    if amount > 0 then    
        return string.format("%d", total/amount)        
    end
    return 0
end

function RBPS:autoArrangeFindHighestAvailableELO(team)
    local highestELO = 0
    local highestPlayer = nil
    for key,taulu in pairs(RBPS.Players) do
        if taulu.ELO_arranged == false then
        if not taulu.marine_ELO then Shared.Message("Marine ELO null") end
        if not taulu.alien_ELO then Shared.Message("alien ELO null") end
        if not highestELO then Shared.Message("highest ELO null") end
            if team == 1 then                           
                if taulu.marine_ELO > highestELO then
                    highestELO = taulu.marine_ELO
                    highestPlayer = taulu  
                end      
            elseif team == 2 then
                if taulu.alien_ELO > highestELO then
                    highestELO = taulu.alien_ELO
                    highestPlayer = taulu  
                end            
            end
        end
    end
    
    if highestPlayer then
        highestPlayer.ELO_arranged = true
        return highestPlayer
    end
    
    return nil
end

function RBPS:autoArrangeSetELOs()
    /*
    if webdata doesnt contain player info, default that player to default ELO of 1500
    */

    //arrange web data to each player (or default 1500)
    //set all default
    for key,taulu in pairs(RBPS.Players) do
        taulu.alien_ELO = 1500
        taulu.marine_ELO = 1500
        taulu.ELO_arranged = false                      
    end
    
    //set current ELOs
    for key,p in pairs(RBPSwebPlayers) do                
        local RBPSplayer = RBPS:getPlayerBySteamId(p.id)        
        if RBPSplayer then       
            if p.alien_ELO then 
                RBPSplayer.alien_ELO = tonumber(p.alien_ELO)
//            else
  //              Shared.Message("alien ELO null" .. RBPSplayer.name)
            end
            if p.marine_ELO then 
                RBPSplayer.marine_ELO = tonumber(p.marine_ELO)
    //        else
      //          Shared.Message("marine ELO null" .. RBPSplayer.name)
            end
        end                                           
    end
end


function RBPS:switchTeam(steamId, team)

    local client = RBPS:getPlayerClientBySteamId(steamId)
    if not client then
        //Shared.Message("Can't find player to move into team")
        return 
    end    
    local player = client:GetControllingPlayer()
    if not player then
        //Shared.Message("Can't find player to move into team")
        return 
    end
    
    local teamNumber = tonumber(team)
    
    if type(teamNumber) ~= "number" or teamNumber < 0 or teamNumber > 3 then           
        return        
    end
    
    if player and teamNumber ~= player:GetTeamNumber() then
        GetGamerules():JoinTeam(player, teamNumber)
  //  elseif not player then
      //  Shared.Message("Can't find player to switch team into.")
    end
    
end