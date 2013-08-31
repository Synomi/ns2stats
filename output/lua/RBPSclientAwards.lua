// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSclientAwards.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

RBPSclientAwards = {}

local function addSpaces(amount)
    local str = ""
    for p=1,amount do
        str = str .. "F"
    end
    
    return str
end

function RBPS:clientShowAwards(message) //message not used currently
    
    local addY = 0
    local col = Color(230/255, 230/255, 0/255 )             
    //sort by length: tmp solution
    table.sort(RBPSclientAwards, function (a, b)
      return string.len(a) > string.len(b)
    end)          
    /*
    for a=1,#RBPSclientAwards do                        
        Cout:addClientTextMessage(Client.GetScreenWidth() * 6/8,(Client.GetScreenHeight() * 1/6) + addY
            ,RBPSclientAwards[a],24, col, "awardmsg" .. a)            
        addY = addY + 22
    end    
    */
    //StartSoundEffectForPlayer(Player.kInvalidSound, nil)  

    RBPSnextAwardId = 1       
    RBPSshowingAwards = true
end

function RBPS:clientShowNextAward(id)
    local addY = id*22
    local col = Color(230/255, 230/255, 0/255 )             
    
    Cout:addClientTextMessage(Client.GetScreenWidth() * 6/8,(Client.GetScreenHeight() * 1/6) + addY
        ,RBPSclientAwards[id],30-id, col, "awardmsg" .. id)                    
end