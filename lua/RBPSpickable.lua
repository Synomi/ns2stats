// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSpickable.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

function RBPS:addPickableItemCreateToLog(item)

	local techId = item:GetTechId()
	local structureOrigin = item:GetOrigin()
	local InstaHit = ""
	if item:_GetNearbyRecipient() ~= nil then InstaHit = true else InstaHit = false end
	local steamid = RBPS:getTeamCommanderSteamid(item:GetTeamNumber())
	local newItem = 
		{
			commander_steamid = steamid,
			instanthit = InstaHit,
		    id = item:GetId(),
			cost = GetCostForTech(techId),
			team = item:GetTeamNumber(),
			name = EnumToString(kTechId, techId),
			action = "pickable_item_dropped",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end

function RBPS:addPickableAbilityCreateToLog(ability)

	local techId = ability:GetTechId()
	local structureOrigin = ability:GetOrigin()
	local steamid = RBPS:getTeamCommanderSteamid(ability:GetTeamNumber())
	
	local newItem = 
		{
			commander_steamid = steamid,
		    id = ability:GetId(),
			cost = GetCostForTech(techId),
			team = ability:GetTeamNumber(),
			name = ability.kMapName, //EnumToString(kTechId, techId),
			action = "pickable_ability_dropped",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end

function RBPS:addPickableAbilityDestroyedToLog(ability)

	local techId = ability:GetTechId()
	local structureOrigin = ability:GetOrigin()
	
	local newItem = 
		{
		    id = ability:GetId(),
			cost = GetCostForTech(techId),
			team = ability:GetTeamNumber(),
			name = ability.kMapName, //EnumToString(kTechId, techId),
			action = "pickable_ability_destroyed",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end

function RBPS:addPickableAbilityPickedToLog(ability, player)

	local client = Server.GetOwner(player)
	local techId = ability:GetTechId()
	local structureOrigin = ability:GetOrigin()
	
	local steamId = 0
	
	if client ~= nil then 
		steamId = client:GetUserId() 
	end
	
	local newItem = 
		{
			steamId = SteamId,
		    id = item:GetId(),
			cost = GetCostForTech(techId),
			team = player:GetTeamNumber(),
			name = ability.kMapName,
			action = "pickable_ability_picked",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end

function RBPS:addPickableItemPickedToLog(item, player)

	local techId = item:GetTechId()
	local structureOrigin = item:GetOrigin()
	
	local client = Server.GetOwner(player)
	local steamId = 0
	
	if client ~= nil then 
		steamId = client:GetUserId() 
	end
	
	local newItem = 
		{
			steamId = SteamId,
		    id = item:GetId(),
			cost = GetCostForTech(techId),
			team = player:GetTeamNumber(),
			name = EnumToString(kTechId, techId),
			action = "pickable_item_picked",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end

function RBPS:addPickableItemDestroyedToLog(item)

	local techId = item:GetTechId()
	local structureOrigin = item:GetOrigin()
	
	local newItem = 
		{
		    id = item:GetId(),
			cost = GetCostForTech(techId),
			team = item:GetTeamNumber(),
			name = EnumToString(kTechId, techId),
			action = "pickable_item_destroyed",
			x = string.format("%.4f", structureOrigin.x),
			y = string.format("%.4f", structureOrigin.y),
			z = string.format("%.4f", structureOrigin.z)
		}
	
	RBPS:addLog(newItem)	

end