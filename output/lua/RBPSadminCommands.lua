// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSadminCommands.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

/*
    RBPSconfig.unstuck = true    
    RBPSconfig.votemapEnabled = true
    RBPSconfig.afkKickEnabled = true
    RBPSconfig.afkKickIdleTime = 180    
    RBPSconfig.killstreaksEnabled = false
    RBPSconfig.chatMessageSayer = "NS2Stats"
    RBPSconfig.tournamentMode = false
*/
local serverAdminFileName = "ServerAdmin.json"
local settings = LoadConfigFile(serverAdminFileName)

function RBPS:isUserAdmin(client,steamId)        
    if not settings then return false end
    
    if client then
        steamId = client:GetUserId()
    end
    
    if not steamId then return false end
    
    for name, user in pairs(settings.users) do        
        if user.id == steamId then                   
            return true
        end            
    end
            
    return false        
end

local function toggleTournamentMode()
    if RBPSconfig.tournamentMode == false then
        RBPSconfig.tournamentMode = true
        RBPS:messageAll("Tournament mode is now enabled.")
    else
        RBPSconfig.tournamentMode = false
        RBPS:messageAll("Tournament mode is now disabled.")
    end
    
    RBPSoverwritesDone = false
end
CreateServerAdminCommand("Console_sv_tournamentmode", toggleTournamentMode, "<toggle>, Enables or disables tournament mode (NS2Stats).")

local function toggleUnstuck()
    if RBPSconfig.unstuck == false then
        RBPSconfig.unstuck = true
        RBPS:messageAll("Unstuck is now enabled.")
    else
        RBPSconfig.unstuck = false
        RBPS:messageAll("Unstuck is now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_unstuck", toggleUnstuck, "<toggle>, Enables or disables unstuck (NS2Stats).")

local function toggleVotemap()
    if RBPSconfig.votemapEnabled == false then
        RBPSconfig.votemapEnabled = true
        RBPS:messageAll("Votemap is now enabled.")
    else
        RBPSconfig.votemapEnabled = false
        RBPS:messageAll("Votemap is now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_votemap", toggleVotemap, "<toggle>, Enables or disables votemap (NS2Stats).")

local function toggleAfkKick()
    if RBPSconfig.afkKickEnabled == false then
        RBPSconfig.afkKickEnabled = true
        RBPS:messageAll("AFK kick is now enabled.")
    else
        RBPSconfig.afkKickEnabled = false
        RBPS:messageAll("AFK kick is now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_afkkick", toggleAfkKick, "<toggle>, Enables or disables AFK kick (NS2Stats).")

local function toggleKillstreaks()
    if RBPSconfig.killstreaksEnabled == false then
        RBPSconfig.killstreaksEnabled = true
        RBPS:messageAll("Killstreaks are now enabled.")
    else
        RBPSconfig.killstreaksEnabled = false
        RBPS:messageAll("Killstreaks are now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_killstreaks", toggleKillstreaks, "<toggle>, Enables or disables killstreaks (NS2Stats).")

local function toggleAwards()
    if RBPSconfig.awardsEnabled == false then
        RBPSconfig.awardsEnabled = true
        RBPS:messageAll("Awards are now enabled.")
    else
        RBPSconfig.awardsEnabled = false
        RBPS:messageAll("Awards are now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_awards", toggleAwards, "<toggle>, Enables or disables awards (NS2Stats).")


local function toggleAutoArrange()
    if RBPSconfig.enableELOAutoArrange == false then
        RBPSconfig.enableELOAutoArrange = true
        RBPS:messageAll("Auto-arrange by ELO is now enabled.")
    else
        RBPSconfig.enableELOAutoArrange = false
        RBPS:messageAll("Auto-arrange by ELO is now disabled.")
    end
end
CreateServerAdminCommand("Console_sv_autoarrange", toggleAutoArrange, "<toggle>, Enables or disables ELO auto-arrange (NS2Stats).")


local function verifyServer(client)
    ServerAdminPrint(client,"Verifying...")
    
    Shared.SendHTTPRequest(RBPS.websiteUrl .. "/api/verifyServer/" .. client:GetUserId() .. "?s=479qeuehq2829&key=" .. RBPSadvancedConfig.key, "GET",
        function(response) RBPS:onHTTPRespVerify(client,response) end)    
end
CreateServerAdminCommand("Console_sv_verify_server", verifyServer, "Makes you owner of this server (NS2Stats).")


local function saveNS2StatsChanges(client)
    ServerAdminPrint(client,"Saving NS2Stats changes into " .. RBPSconfigFileName .. " file.")
    newSettingAdded = true
    RBPS:saveConfig()
end
CreateServerAdminCommand("Console_sv_ns2stats_save", saveNS2StatsChanges, "Saves current NS2Stats settings into config file.")



function RBPS:onHTTPRespVerify(client,response)       
    if client then
        ServerAdminPrint(client,response)        
    end
end





RBPScreateAdminCommands = false
