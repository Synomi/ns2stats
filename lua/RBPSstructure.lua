// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSstructure.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

--ei käytössä, eikä tarvikkaan olla.
/*function RBPS:addStructureDroppedToLog(structure)
	
	local techId = structure:GetTechId()
	
	local newUpgrade = 
	{
		team = structure:GetTeamNumber(),
		cost = GetCostForTech(techId),
		name = EnumToString(kTechId, techId),
		action = "structure_dropped"
	}
	
	RBPS:addLog(newUpgrade)

end*/

function RBPS:addPlayerBuiltHydraToLog(structure, player, builtTime)

	local client = Server.GetOwner(player)
	local techId = structure:GetTechId()
	local structureOrigin = structure:GetOrigin()
	local steamId = 0
	
	if client ~= nil then steamId = client:GetUserId() end

	local newHydra = 
	{
	    id = structure:GetId(),
		elapsedTimeOnBuild = builtTime,
		lifeform = player:GetMapName(),
		team = player:GetTeamNumber(),
		structure_cost = GetCostForTech(techId),
		structure_name = EnumToString(kTechId, techId),
		steamId = steamId,
		action = "player_built_hydra",
		structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z)
	}
	
	RBPS:addLog(newStructure)
	
end


function RBPS:addConstructionTime(client)
    local RBPSplayer = RBPS:getPlayerByClient(client)

    if RBPSplayer then
        if RBPSplayer["teamnumber"] == 2 then
                RBPSplayer["total_constructed"] = RBPSplayer["total_constructed"] + 5 //gorges get more points per healingspray, since it doesnt happen as often as marine buidling
            else
                RBPSplayer["total_constructed"] = RBPSplayer["total_constructed"] + 1
        end
    end
end

function RBPS:addPlayerBuiltClogToLog(structure, player)

	local client = Server.GetOwner(player)
	local techId = structure:GetTechId()
	local structureOrigin = structure:GetOrigin()
	local steamId = 0
	
	if client ~= nil then steamId = client:GetUserId() end

	local newHydra = 
	{
	    id = structure:GetId(),
		elapsedTimeOnBuild = builtTime,
		lifeform = player:GetMapName(),
		team = player:GetTeamNumber(),
		structure_cost = GetCostForTech(techId),
		structure_name = EnumToString(kTechId, techId),
		steamId = steamId,
		action = "player_built_clog",
		structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z)
	}
	
	RBPS:addLog(newStructure)
	
end

--ei käytössä, eikä tarviikkaan olla.
/*function RBPS:addPlayerBuiltStructureToLog(player, structure, score, elapsedTime)	
	local client = Server.GetOwner(player)
	local techId = structure:GetTechId()
	local structureOrigin = structure:GetOrigin()
	local steamid = ""
	
	if client ~= nil then steamid = client:GetUserId() end
	
	local newStructure = 
	{
		lifeform = player:GetMapName(),
		team = player:GetTeamNumber(),
		structure_cost = GetCostForTech(techId),
		scoregiven = score,
		elapsedTimeOnBuild = elapsedTime,
		structure_name = EnumToString(kTechId, techId),
		steamid = steamid,
		action = "player_built_structure",
		structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z)
	}
	
	RBPS:addLog(newStructure)

end*/

function RBPS:addStructureBuiltToLog(structure, player)
	local techId = structure:GetTechId()
	local structureOrigin = structure:GetOrigin()
	
	local client = Server.GetOwner(player)
	local steamId = 0
	local buildername = ""
	
	if client ~= nil then 
		steamId = client:GetUserId() 
		buildername = player:GetName()
	end
	
	local newStructure = 
		{
		    id = structure:GetId(),
			builder_name = buildername,
			steamId = steamId,
			structure_cost = GetCostForTech(techId),
			team = structure:GetTeamNumber(),
			structure_cost = GetCostForTech(techId),
			structure_name = EnumToString(kTechId, techId),
			action = "structure_built",
			structure_x = string.format("%.4f", structureOrigin.x),
			structure_y = string.format("%.4f", structureOrigin.y),
			structure_z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newStructure)		
end

function RBPS:addStructureKilledToLog(structure, player, doer)
	if player ~= nil and structure:isa("Player") then return end
	local structureOrigin = structure:GetOrigin()
	local techId = structure:GetTechId()
	
	//print(LookupTechData(techId, kTechDataMapName, ""))
	if player == nil then 
	
		local newStructure = 
		{
		    id = structure:GetId(),
			structure_team = structure:GetTeamNumber(),
			structure_cost = GetCostForTech(techId),
			structure_name = EnumToString(kTechId, techId),
			action = "structure_suicide",
			structure_x = string.format("%.4f", structureOrigin.x),
			structure_y = string.format("%.4f", structureOrigin.y),
			structure_z = string.format("%.4f", structureOrigin.z)
		}
		RBPS:addLog(newStructure)
		
	else
		local client = Server.GetOwner(player)
		local steamId = 0
		local weapon = ""
	
		if client then steamId = client:GetUserId() end
	
		if not doer then weapon = "self"
		else weapon = doer:GetMapName()
		end
	
		local newStructure = 
		{
		    id = structure:GetId(),
			killer_steamId = steamId,
			killer_lifeform = player:GetMapName(),
			killer_team = player:GetTeamNumber(),
			structure_team = structure:GetTeamNumber(),
			killerweapon = weapon,
			structure_cost = GetCostForTech(techId),
			structure_name = EnumToString(kTechId, techId),
			action = "structure_killed",
			structure_x = string.format("%.4f", structureOrigin.x),
			structure_y = string.format("%.4f", structureOrigin.y),
			structure_z = string.format("%.4f", structureOrigin.z)
		}
		RBPS:addLog(newStructure)
	end
end

function RBPS:addRecycledToLog(structure, finalRecycleAmount)
	local structureOrigin = structure:GetOrigin()
	local techId = structure:GetTechId()
	
	local newUpgrade = 
	{
	    id = structure:GetId(),
		team = structure:GetTeamNumber(),
		givenback = finalRecycleAmount,
		structure_name = EnumToString(kTechId, techId),
		action = "structure_recycled",
		structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z)
	}
	
	RBPS:addLog(newUpgrade)

end

function RBPS:ghostStructureAction(action,structure,doer)
        
    if not structure then return end
    local techId = structure:GetTechId()
    local structureOrigin = structure:GetOrigin()
    
    local log = nil
    
    log = 
    {
        action = action,
        structure_name = EnumToString(kTechId, techId),
        team = structure:GetTeamNumber(),
        id = structure:GetId(),
        structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z)
    }
    
    if action == "ghost_remove" then   
        //something extra here? we can use doer here     
    end
    
    
        RBPS:addLog(log)
    
end

function RBPS:dropStructure(structure, commander)
    if not structure then return end
    if not commander then return end
    
    local client = Server.GetOwner(commander)
    if not client then return end
    
    local techId = structure:GetTechId()
    local structureOrigin = structure:GetOrigin()
    
    local log =
    {
        structure_name = EnumToString(kTechId, techId),
        id = structure:GetId(),
        structure_cost = GetCostForTech(techId),
        structure_x = string.format("%.4f", structureOrigin.x),
		structure_y = string.format("%.4f", structureOrigin.y),
		structure_z = string.format("%.4f", structureOrigin.z),
		team = structure:GetTeamNumber(),		
		action = "structure_dropped",   
		steamId = client:GetUserId()
    }
    
    RBPS:addLog(log)
    
end


