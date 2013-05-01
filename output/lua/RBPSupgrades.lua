// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSupgrades.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

function RBPS:addUpgradeStartedToLog(researchNode, commander, ResearchMixin)
	local client = Server.GetOwner(commander)
	local steamId = ""
	if client ~= nil then steamId = client:GetUserId() end
	local techId = researchNode:GetTechId()
	
	local newUpgrade = 
	{
		structure_id = ResearchMixin:GetId(),
		commander_steamid = steamId,
		team = commander:GetTeamNumber(),
		cost = GetCostForTech(techId),
		upgrade_name = EnumToString(kTechId, techId),
		action = "upgrade_started"
	}
	
	RBPS:addLog(newUpgrade)

end

function RBPS:addUpgradeLostToLog(TechMixin, techId)

	//local techId = researchNode:GetTechId()
	local teamNumber = HasMixin(self, "Team") and self:GetTeam()

	local newUpgrade = 
	{
		team = teamNumber,
		cost = GetCostForTech(techId),
		upgrade_name = EnumToString(kTechId, techId), //GetDisplayNameForTechId(techId)
		action = "upgrade_lost"
	}
	
	RBPS:addLog(newUpgrade)

end

function RBPS:addUpgradeAbortedToLog(researchNode, ResearchMixin)
	local techId = researchNode:GetTechId()
	local steamid = RBPS:getTeamCommanderSteamid(ResearchMixin:GetTeamNumber())

	local newUpgrade = 
	{
		structure_id = ResearchMixin:GetId(),
		team = ResearchMixin:GetTeamNumber(),
		commander_steamid = steamid,
		cost = GetCostForTech(techId),
		upgrade_name = EnumToString(kTechId, techId),
		action = "upgrade_aborted"
	}
	
	RBPS:addLog(newUpgrade)

end

function RBPS:addUpgradeFinishedToLog(researchNode, structure, ResearchMixin)
	local techId = researchNode:GetTechId()
	
	local newUpgrade = 
	{
		structure_id = ResearchMixin:GetId(),
		team = structure:GetTeamNumber(),
		commander_steamid = -1,
		cost = GetCostForTech(techId),
		upgrade_name = EnumToString(kTechId, techId),
		action = "upgrade_finished"
	}
	
	RBPS:addLog(newUpgrade)

end

//Ei käytössä vielä
function RBPS:addPlayerUpgradeStartedToLog(researchNode, player)
	local techId = researchNode:GetTechId()
	local client = Server.GetOwner(player)
	local steamId = ""
	if client ~= nil then steamId = client:GetUserId() end
	
	local newUpgrade = 
	{
		steamid = steamId,
		team = player:GetTeamNumber(),
		cost = GetCostForTech(techId),
		upgrade_name = EnumToString(kTechId, techId), //GetDisplayNameForTechId(techId)
		action = "player_upgrade"
	}
	
	RBPS:addLog(newUpgrade)

end
