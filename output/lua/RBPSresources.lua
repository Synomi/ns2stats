// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSresources.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

function RBPS:addResourcesGathered(ResourceTower)

local team = ResourceTower:GetTeamNumber()

	local newResourceGathered = 
	{
		team = ResourceTower:GetTeamNumber(),
		action = "resources_gathered",
		amount = 1
	}
    
    if team == 1 then
        RBPSteam1ResGathered = RBPSteam1ResGathered +1
    elseif team == 2 then
        RBPSteam2ResGathered = RBPSteam2ResGathered +1
    end
	
end

function RBPS:addResourcesGatheredToLog(team,amount)
    local newResourceGathered = 
	{
		team = team,
		action = "resources_gathered",
		amount = amount
	}
	
	RBPS:addLog(newResourceGathered)
		
end
