// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSserverAwardHelpers.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

function RBPS:addJump(name)
 
    local RBPSplayer = nil
    
    if name then
        RBPSplayer = RBPS:getPlayerByName(name)    
    end
    
    if RBPSplayer then
        RBPSplayer.jumps = RBPSplayer.jumps +1        
    end
        
end