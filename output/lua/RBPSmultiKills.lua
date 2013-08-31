// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSmultiKills.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

function RBPS:checkForMultiKills(name,streak)

    if not RBPSconfig.killstreaksEnabled then return end
        
    local text = ""
    
    if streak == 3 then
        text = name .. " is on triple kill!"      
        RBPS:playSoundForEveryPlayer(RBPSsoundTriplekill)  
    elseif streak == 5 then    
        text = name .. " is on multikill!"
        RBPS:playSoundForEveryPlayer(RBPSsoundMultikill)  
    elseif streak == 6 then
        text = name .. " is on rampage!"
        RBPS:playSoundForEveryPlayer(RBPSsoundRampage)  
    elseif streak == 7 then
        text = name .. " is on a killing spree!"
        RBPS:playSoundForEveryPlayer(RBPSsoundKillingspree)  
    elseif streak == 9 then
        text = name .. " is dominating!"
        RBPS:playSoundForEveryPlayer(RBPSsoundDominating)  
    elseif streak == 11 then
        text = name .. " is unstoppable!"
        RBPS:playSoundForEveryPlayer(RBPSsoundUnstoppable)  
    elseif streak == 13 then
        text = name .. " made a mega kill!"
        RBPS:playSoundForEveryPlayer(RBPSsoundMegakill)  
    elseif streak == 15 then
        text = name .. " made an ultra kill!"    
        RBPS:playSoundForEveryPlayer(RBPSsoundUltrakill)  
    elseif streak == 17 then
        text = name .. " owns!"
        RBPS:playSoundForEveryPlayer(RBPSsoundOwnage)  
    elseif streak == 18 then
        text = name .. " made a ludicrouskill!"
        RBPS:playSoundForEveryPlayer(RBPSsoundLudicrouskill)  
    elseif streak == 19 then
        text = name .. " is a head hunter!"
        RBPS:playSoundForEveryPlayer(RBPSsoundHeadhunter)  
    elseif streak == 20 then
        text = name .. " is whicked sick!"
        RBPS:playSoundForEveryPlayer(RBPSsoundWhickedsick)  
    elseif streak == 21 then
        text = name .. " made a monster kill!"
        RBPS:playSoundForEveryPlayer(RBPSsoundMonsterkill)  
    elseif streak == 23 then
        text = "Holy Shit! " .. name .. " got another one!"
        RBPS:playSoundForEveryPlayer(RBPSsoundHolyshit)  
    elseif streak == 25 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 27 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 30 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 34 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 40 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 48 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 58 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 70 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 80 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    elseif streak == 100 then
        text = name .. " is G o d L i k e !!!"
        RBPS:playSoundForEveryPlayer(RBPSsoundGodlike)  
    end
    
    if text ~= "" then    	
    local val = streak
    if streak > 26 then 
        val = 26        
    end
        Cout:addServerTextMessageToAllClients(1/2,2/10,text,4,{r = 255, g = 230-(streak*10), b = 260-(val*10) },"multikill")
    end
end