// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSgeneralFunctions.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

function RBPS:playSoundForEveryPlayer(name)
    local allPlayers = Shared.GetEntitiesWithClassname("Player")            
    
    for index, fromPlayer in ientitylist(allPlayers) do                                                                  
        StartSoundEffectForPlayer(name, fromPlayer)
    end
end

function RBPS:acceptKey(response)
        if not response or response == "" then
            Shared.Message("NS2Stats: Unable to receive unique key from server, stats wont work yet. ")
            Shared.Message("NS2Stats: Server restart might help.")
        else            
            local decoded = json.decode(response)
            if decoded and decoded.key then
                RBPSadvancedConfig.key = decoded.key
                Shared.Message("NS2Stats: Key " .. RBPSadvancedConfig.key .. " has been assigned to this server")                
                Shared.Message("NS2Stats: You may use admin commands (sv_help) to change NS2Stats settings.")
                Shared.Message("NS2Stats: You may use admin command sv_verity_server to claim this server.")
                Shared.Message("NS2Stats setup complete.")
                newAdvancedSettingAdded = true            
            else
                Shared.Message("NS2Stats: Unable to receive unique key from server, stats wont work yet. ")
                Shared.Message("NS2Stats: Server restart might help.")
                Shared.Message("NS2Stats: Server responded: " .. response)
                newAdvancedSettingAdded = true         
            end
        end
end

function RBPS:addServerIpPortAndPass(IP,password)
    for key,taulu in pairs(RBPSserverInfo) do
        if taulu.IP == IP and taulu.password == password then
            taulu.count = taulu.count + 1
            return
        end
    end
    
    //if not didnt exists
    table.insert(RBPSserverInfo,{count = 1, IP = IP, password = password})        
end

function RBPS:getServerInfoTable()
local max = 0
local highestTable = nil
    for key,taulu in pairs(RBPSserverInfo) do
        if max < taulu.count then
            max = taulu.count
            highestTable = taulu 
        end
    end
    
    if max == 0 then
        return {IP = "n/a", password = "n/a"}
    end
    
    return highestTable
end

RBPSlastChatMessage =""
function RBPS:processChatCommand(playerName,chatMessage,teamOnly) 
   
    //Shared.Message(chatMessage)
    if not Server then return end
        
    local rp = RBPS:getPlayerByName(playerName)
    if not rp then return end
    
    local client = RBPS:getPlayerClientBySteamId(rp.steamId)
    if not client then return end
    
    local player = client:GetControllingPlayer()        
    if not player then return end                   

    local RBPSplayer = RBPS:getPlayerByClient(client)    
      
    if chatMessage == "/stuck" or chatMessage == "/unstuck" then                              
        rp.unstuck = true
        rp.unstuckCounter = 0
        rp.lastCoords = rp.x + rp.y + rp.z //needs to be same after RBPSstuckTime seconds        
    elseif chatMessage == "ready" or chatMessage == "rdy" or chatMessage == "/ready" then
        RBPSready(client) 
    elseif chatMessage == "not ready" or chatMessage == "notready" or chatMessage == "notrdy" or chatMessage == "/notready" then
        RBPSnotready(client)
    elseif chatMessage == "check" or chatMessage == "chk" then    
        local player = client:GetControllingPlayer()
        if player then               
            Server.SendCommand(player, "check")            
        end    
    end

    if RBPSconfig.enableChatLogging and RBPSplayer then        

        //do not log duplicates   
        local team = nil
        if teamOnly then
           team = "teamchat"
        else
           team = "publichat"
        end

        if RBPSlastChatMessage == team .. playerName .. chatMessage then return end

        RBPSlastChatMessage = team .. playerName .. chatMessage
        local message = 
            {
                    name = RBPSplayer.name,
                    action = "chat_message",
                    team = RBPSplayer.teamnumber,
                    toteam = teamOnly,
                    steamid = RBPSplayer.steamId,
                    message = chatMessage
            }

        RBPS:addLog(message)        
        end      
end

function RBPS:addMissToLog(attacker)
    if not Server then return end           
    
    local weapon = "none"        
    local RBPSplayer = nil
             
    if attacker and attacker:isa("Player") and attacker:GetName() then
    
        RBPSplayer = RBPS:getPlayerByName(attacker:GetName())                   
        if not RBPSplayer then return end        
		
		if attacker.GetActiveWeapon and attacker:GetActiveWeapon() then
			weapon = attacker:GetActiveWeapon():GetMapName()
		end
        
        --local missLog = 
        --{
            
        --    //general
        --    action = "miss",			
            
        --    //Attacker
        --    attacker_steamId      = RBPSplayer.steamId,
        --    attacker_team         = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
        --    attacker_weapon       = attackerWeapon,
        --    attacker_lifeform     = attacker:GetMapName(),
        --    attacker_hp           = attacker:GetHealth(),
        --    attacker_armor        = attacker:GetArmorAmount(),
        --    attackerx             = RBPSplayer.x,
        --    attackery             = RBPSplayer.y,
        --    attackerz             = RBPSplayer.z                
        --}
        
        --//Lis�t��n data json-muodossa logiin.            
        --RBPS:addLog(missLog)
        //gorge fix
        if weapon == "spitspray" then
            weapon = "spit"                       
        end
        
        RBPS:weaponsAddMiss(RBPSplayer,weapon)        
    end
    

end

function RBPS:addHitToLog(target, attacker, doer, damage, damageType)
    if not Server then return end   
    if not attacker or not doer or not target then return end
        
   
    local targetWeapon = "none"
    local RBPSplayer = nil
    local RBPStargetPlayer = nil
    
    if attacker:isa("Player") and attacker:GetName() then
        RBPSplayer = RBPS:getPlayerByName(attacker:GetName())           
    end
    
    if not RBPSplayer then return end
   
    if target:isa("Player")  and target:GetName() then //target is a player
                                    
        RBPStargetPlayer = RBPS:getPlayerByName(target:GetName())   
        
        if not RBPStargetPlayer then return end
               
        if target.GetActiveWeapon and target:GetActiveWeapon() then
            targetWeapon = target:GetActiveWeapon():GetMapName()
        end      
        
        local hitLog = 
        {            
            //general
            action = "hit_player",			
            
            //Attacker
            attacker_steamId      = RBPSplayer.steamId,
            attacker_team         = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
            attacker_weapon       = doer:GetMapName(),
            attacker_lifeform     = attacker:GetMapName(),
            attacker_hp           = attacker:GetHealth(),
            attacker_armor        = attacker:GetArmorAmount(),
            attackerx             = RBPSplayer.x,
            attackery             = RBPSplayer.y,
            attackerz             = RBPSplayer.z,    
            
            //Target
            target_steamId        = RBPStargetPlayer.steamId,
            target_team           = target:GetTeamType(),
            target_weapon         = targetWeapon,
            target_lifeform       = target:GetMapName(),
            target_hp             = target:GetHealth(),
            target_armor          = target:GetArmorAmount(),
            targetx               = RBPStargetPlayer.x,
            targety               = RBPStargetPlayer.y,
            targetz               = RBPStargetPlayer.z,                
            
            damageType            = damageType,
            damage                = damage
            
        }

        //Lis�t��n data json-muodossa logiin.            
        RBPS:addLog(hitLog)       

        RBPS:weaponsAddHit(RBPSplayer, doer:GetMapName(), damage)                 
        
        
    else //target is a structure       
        local structureOrigin = target:GetOrigin()
        
        local hitLog = 
        {            
            //general
            action = "hit_structure",			
            
            //Attacker
            attacker_steamId      = RBPSplayer.steamId,
            attacker_team         = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
            attacker_weapon       = doer:GetMapName(),
            attacker_lifeform     = attacker:GetMapName(),
            attacker_hp           = attacker:GetHealth(),
            attacker_armor        = attacker:GetArmorAmount(),
            attackerx             = RBPSplayer.x,
            attackery             = RBPSplayer.y,
            attackerz             = RBPSplayer.z, 
                        	   		    
		    structure_id = target:GetId(),
		    structure_name = target:GetMapName(),		    		   
		    structure_x = string.format("%.4f", structureOrigin.x),
		    structure_y = string.format("%.4f", structureOrigin.y),
		    structure_z = string.format("%.4f", structureOrigin.z),		                           
		    		    
		    damageType            = damageType,
            damage                = damage
        }
        
        RBPS:addLog(hitLog)       
        RBPS:weaponsAddStructureHit(RBPSplayer, doer:GetMapName(), damage)         
        
    end  
           
end

function RBPS:addDeathToLog(target, attacker, doer)
    if not Server then return end
    if attacker ~= nil and doer ~= nil then
        local attackerOrigin = attacker:GetOrigin()
        local targetWeapon = "none"
        local targetOrigin = target:GetOrigin()
        local attacker_client = Server.GetOwner(attacker)
        local target_client = Server.GetOwner(target)
        
        if target.GetActiveWeapon and target:GetActiveWeapon() then
                targetWeapon = target:GetActiveWeapon():GetMapName()
        end

        //Jos on quitannu servulta justiin ennen tjsp niin ei ole clientti� ja erroria pukkaa. (uwelta kopsasin)
        if attacker_client and target_client then
            local deathLog = 
            {
                
                //general
                action = "death",			
                
                //Attacker
                attacker_steamId      = attacker_client:GetUserId(),
                attacker_team         = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
                attacker_weapon       = doer:GetMapName(),
                attacker_lifeform     = attacker:GetMapName(), //attacker:GetPlayerStatusDesc(),
                attacker_hp           = attacker:GetHealth(),
                attacker_armor        = attacker:GetArmorAmount(),
                attackerx             = string.format("%.4f", attackerOrigin.x),
                attackery             = string.format("%.4f", attackerOrigin.y),
                attackerz             = string.format("%.4f", attackerOrigin.z),
                
                //Target
                target_steamId        = target_client:GetUserId(),
                target_team           = target:GetTeamType(),
                target_weapon         = targetWeapon,
                target_lifeform       = target:GetMapName(), //target:GetPlayerStatusDesc(),
                target_hp             = target:GetHealth(),
                target_armor          = target:GetArmorAmount(),
                targetx               = string.format("%.4f", targetOrigin.x),
                targety               = string.format("%.4f", targetOrigin.y),
                targetz               = string.format("%.4f", targetOrigin.z),
                target_lifetime       = string.format("%.4f", Shared.GetTime() - target:GetCreationTime())
            }
            
            //Lis�t��n data json-muodossa logiin.                
            RBPS:addLog(deathLog)
            
            if attacker:GetTeamNumber() ~= target:GetTeamNumber() then                               
                
                //addkill / display killstreaks
                RBPS:addKill(attacker_client:GetUserId(),target_client:GetUserId())
            end
            
        else
			--natural causes death
			if target:isa("Player") then
			
			if target.GetActiveWeapon and target:GetActiveWeapon() then
                targetWeapon = target:GetActiveWeapon():GetMapName()
			end
			local deathLog = 
            {  
                //general
                action = "death",

				//Attacker
				attacker_weapon		  = "natural causes",
				
				//Target
                target_steamId        = target_client:GetUserId(),
                target_team           = target:GetTeamType(),
                target_weapon         = targetWeapon,
                target_lifeform       = target:GetMapName(), //target:GetPlayerStatusDesc(),
                target_hp             = target:GetHealth(),
                target_armor          = target:GetArmorAmount(),
                targetx               = string.format("%.4f", targetOrigin.x),
                targety               = string.format("%.4f", targetOrigin.y),
                targetz               = string.format("%.4f", targetOrigin.z),
                target_lifetime       = string.format("%.4f", Shared.GetTime() - target:GetCreationTime())		
			}
			RBPS:addLog(deathLog)
			--Structure kill
			else RBPS:addStructureKilledToLog(target, attacker, doer)
			end
		end
    else //suicide
        local target_client = Server.GetOwner(target)
        
        local targetWeapon = "none"
        local targetOrigin = target:GetOrigin()
        local attacker_client = Server.GetOwner(target) //easy way out
        if attacker_client == nil then
			--Structure suicide
			RBPS:addStructureKilledToLog(target, attacker_client, doer)
            return 
        end
        local attackerOrigin = targetOrigin
        local attacker = target
         local deathLog = 
            {
                
                //general
                action = "death",			
                
                //Attacker

                attacker_weapon       = "self",
               /* attacker_lifeform     = attacker:GetMapName(),
			    attacker_steamId      = attacker_client:GetUserId(),
                attacker_team         = ((HasMixin(attacker, "Team") and attacker:GetTeamType()) or kNeutralTeamType),
                attacker_hp           = attacker:GetHealth(),
                attacker_armor        = attacker:GetArmorAmount(),
                attackerx             = string.format("%.4f", attackerOrigin.x),
                attackery             = string.format("%.4f", attackerOrigin.y),
                attackerz             = string.format("%.4f", attackerOrigin.z),*/
                
                //Target
                target_steamId        = target_client:GetUserId(),
                target_team           = target:GetTeamType(),
                target_weapon         = targetWeapon,
                target_lifeform       = target:GetMapName(),
                target_hp             = target:GetHealth(),
                target_armor          = target:GetArmorAmount(),
                targetx               = string.format("%.4f", targetOrigin.x),
                targety               = string.format("%.4f", targetOrigin.y),
                targetz               = string.format("%.4f", targetOrigin.z),
                target_lifetime       = string.format("%.4f", Shared.GetTime() - target:GetCreationTime())
            }
            
            //Lis�t��n data json-muodossa logiin.            
            RBPS:addLog(deathLog)
    
	end
end
function RBPS:getVotesNeeded()
    //calculate total number of players
    local numPlayers = RBPS:getNumberOfConnectedPlayers()
    
    local needed = numPlayers
    needed= RBPS:round(needed/2-0.5,0) + RBPS:round(needed/5-0.5,0) + 1
        
    return needed
end

function RBPS:round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
