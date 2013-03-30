// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSserverAwards.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

//goal: print award lists to client screen after game has ended always
//, create system where new awards can be inserted easily
//, calculate awards completely on server side and send award list to every client
//, might cause some lag if messages are sent with for clause, but game has ended so that should not be big issue
//, use Cout in client side for messages, print them in 1-2 places now in test version
//, make setting to disable/enable, also admin command
//, awards will only contain 1 string, this includes name and award info
//, top awards will be inserted first, in test there are no order in awards

function RBPS:processAwards()
   RBPSawards = {}
   RBPS:makeAwardsList()
   RBPS:sendAwardListToClients()
      
   return RBPSawards
end

function RBPS:makeAwardsList()

    //DO NOT CHANGE ORDER HERE
    RBPS:addAward(RBPS:awardMostDamage())                     
    RBPS:addAward(RBPS:awardMostKillsAndAssists())
    RBPS:addAward(RBPS:awardMostConstructed())
    RBPS:addAward(RBPS:awardMostStructureDamage())
    RBPS:addAward(RBPS:awardMostPlayerDamage())
    RBPS:addAward(RBPS:awardBestAccuracy())
    RBPS:addAward(RBPS:awardMostJumps())
    RBPS:addAward(RBPS:awardHighestKillstreak())        
    
end

function RBPS:sendAwardListToClients()

    //send highest 10 rating awards
    table.sort(RBPSawards, function (a, b)
          return a.rating > b.rating
        end)          

   local playerList = EntityListToTable(Shared.GetEntitiesWithClassname("Player"))                            
   for a=1,#RBPSawards do           
        for p = 1, #playerList do             
            Cout:SendMessageToClient(playerList[p], "awards",{award = RBPSawards[a].message})                                                                                                                        
            
            if a == #RBPSawards or a == RBPSadvancedConfig.awardsMax then
                Cout:SendMessageToClient(playerList[p], "showAwards",{msg = "no msg"})                                                                                                                         
            end
        end
        
        if a == #RBPSawards or a == RBPSadvancedConfig.awardsMax then
            break
        end
   end     
end

function RBPS:addAward(award)
    RBPSnextAwardId = RBPSnextAwardId +1
    award.id = RBPSnextAwardId
    
    RBPSawards[#RBPSawards +1] = award
    
    if RBPSdebug then
        Shared.Message("Added award " .. award.id .. ": " .. award.message .. "(" .. award.rating .. ") total awards: " .. #RBPSawards)
    end
end

function RBPS:awardMostDamage()
    local highestDamage = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""
    local totalDamage = nil
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
        totalDamage = 0
        
        for i=1, #taulu.weapons do        
            totalDamage = totalDamage + taulu.weapons[i].structure_damage
            totalDamage = totalDamage + taulu.weapons[i].player_damage
        end        
        
        if math.floor(totalDamage) > math.floor(highestDamage) then
            highestDamage = totalDamage
            highestPlayer = taulu.name
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = (highestDamage+1)/350
    
    return {steamId = highestSteamId, rating = rating, message = "Most damage done by " .. highestPlayer .. " with total of " .. math.floor(highestDamage) .. " damage!"}
end

function RBPS:awardMostKillsAndAssists()
    local total = 0
    local rating = 0
    local highestTotal = 0
    local highestPlayer = "Nobody"
    local highestSteamId = ""
    
    for key,taulu in pairs(RBPS.Players) do
        total = taulu.kills + taulu.assists
        if total > highestTotal then
            highestTotal = total
            highestPlayer = taulu.name
            highestSteamId = taulu.steamId
        end        
    
    end
    
    rating = highestTotal
    
    return {steamId = highestSteamId, rating = rating, message = highestPlayer .. " is deathbringer with total of " .. highestTotal .. " kills and assists!"}
end

function RBPS:awardMostConstructed()    
    local highestTotal = 0
    local rating = 0
    local highestPlayer = "was not present"
    local highestSteamId = ""
    
    for key,taulu in pairs(RBPS.Players) do
        if taulu.total_constructed > highestTotal then
            highestTotal = taulu.total_constructed
            highestPlayer = taulu.name
            highestSteamId = taulu.steamId
        end
    end    
    
    rating = (highestTotal+1)/30
    
    return {steamId = highestSteamId, rating = rating, message = "Bob the builder: " .. highestPlayer .. "!"}
end


function RBPS:awardMostStructureDamage()
    local highestTotal = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""
    local total = 0
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
        total = 0
        
        for i=1, #taulu.weapons do        
            total = total + taulu.weapons[i].structure_damage            
        end        
        
        if math.floor(total) > math.floor(highestTotal) then
            highestTotal = total
            highestPlayer = taulu.name
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = (highestTotal+1)/150
    
    return {steamId = highestSteamId, rating = rating, message = "Demolition man: " .. highestPlayer .. " with " .. math.floor(highestTotal) .. " structure damage."}
end


function RBPS:awardMostPlayerDamage()
    local highestTotal = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""
    local total = 0
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
        total = 0
        
        for i=1, #taulu.weapons do        
            total = total + taulu.weapons[i].player_damage            
        end        
        
        if math.floor(total) > math.floor(highestTotal) then
            highestTotal = total
            highestPlayer = taulu.name
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = (highestTotal+1)/90
    
    return {steamId = highestSteamId, rating = rating, message = highestPlayer .. " was spilling blood worth of " .. math.floor(highestTotal) .. " damage."}
end


function RBPS:awardBestAccuracy()
    local highestTotal = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""
    local highestTeam = 0
    local total = 0
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
        total = 0
        
        for i=1, #taulu.weapons do        
            total = total + taulu.weapons[i].player_hit/(taulu.weapons[i].miss+1)            
        end        
        
        if total > highestTotal then
            highestTotal = total
            highestPlayer = taulu.name
            highestTeam = taulu.teamnumber
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = highestTotal*10
    
    if highestTeam == 2 then
        return {steamId = highestSteamId, rating = rating, message = "Versed: " .. highestPlayer}
    else //marine or ready room
         return {steamId = highestSteamId, rating = rating, message = "Weapon specialist: " .. highestPlayer}
    end
end


function RBPS:awardMostJumps()
    local highestTotal = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""    
    local total = 0
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
        total = 0
        
        
        total = taulu.jumps
        
        
        if total > highestTotal then
            highestTotal = total
            highestPlayer = taulu.name            
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = highestTotal/30
        
    return {steamId = highestSteamId, rating = rating, message = highestPlayer .. " is jump maniac with " .. highestTotal .. " jumps!"}
    
end


function RBPS:awardHighestKillstreak()
    local highestTotal = 0
    local highestPlayer = "nobody"
    local highestSteamId = ""    
    local total = 0
    local rating = 0
    
    for key,taulu in pairs(RBPS.Players) do
                  
        total = taulu.highestKillstreak        
        
        if total > highestTotal then
            highestTotal = total
            highestPlayer = taulu.name            
            highestSteamId = taulu.steamId
        end        
    end
    
    rating = highestTotal
        
    return {steamId = highestSteamId, rating = rating, message = highestPlayer .. " became unstoppable with streak of " .. highestTotal .. " kills!"}
    
end