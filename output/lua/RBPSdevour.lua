// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSdevour.lua, live status
//
//    Created by:   Synomi
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================


   
local devourFrame = 0
local entityTimeCounter = 0
local devourEntity = {}
local devourMovement = {}

local lastServerUpdateDevour = 0
local lastServerUpdateFrame = 0

function RBPS:devourInit()
    devourFrame = 0
    entityTimeCounter = 0
    devourEntity = {}
    devourMovement = {}
end

local function devourClearBuffer()        
    devourEntity = {}
    devourMovement = {}
end

local function devourSendStatus()
    local stime = Shared.GetGMTString(false)
    
    local state = {        
        time = stime,
        gametime = Shared.GetTime() - RBPS.gamestarted,
        map = Shared.GetMapName(),        
    }
    
    local dataset = {
        Entity = devourEntity,
        Movement =  devourMovement,
        state = state
               }    

    local params = 
    {
        key = RBPSadvancedConfig.key,       
        data = json.encode(dataset)                          
    }           
    
    if RBPSdebug then
	    Shared.Message("Sending game status to :" .. RBPS.websiteStatusUrl)
            Shared.Message(json.encode(dataset))
    end	
        
	Shared.SendHTTPRequest(
            RBPS.websiteStatusUrl .. 'Devour', "POST", params, function(response,status) RBPS:onHTTPResponseFromSendStatus(client,"sendstatus",response,status) end)	       
		
   devourClearBuffer()
    
end


local function createDevourMovementFrame()    

    local data = {}
    
    for key,taulu in pairs(RBPS.Players) do		
        local movement = 
        {            
            id = taulu['steamId'],            
            x = taulu['x'],
            y = taulu['y'],
            z = taulu['z'],
            wrh = taulu['wrh'],             
        }        
        table.insert(data, movement)	
    end

    local frameNumber = 'f' .. devourFrame    
    local tableData =  {
        [frameNumber] = data
       }
    table.insert(devourMovement, tableData)	    
end


local function createDevourEntityFrame()
    local devourPlayers = {}
    local gameTime = Shared.GetTime() - RBPS.gamestarted

    for key,taulu in pairs(RBPS.Players) do		
        local devourPlayer = 
        {            
            id = taulu['steamId'], 
            name = taulu['name'],
            team = taulu['teamNumber'],
            x = taulu['x'],
            y = taulu['y'],
            z = taulu['z'],
            wrh = taulu['wrh'], 
            weapon = taulu['weapon'], 
            health = taulu['health'],
            armor = taulu['armor'],
            pdmg = 0,
            sdmg = 0, 
            lifeform = taulu['lifeform'], 
            score = taulu['score'],
            kills = taulu['kills'], 
            deaths = taulu['deaths'], 
            assists = taulu['assists'], 
            pres = taulu['pres'], 
            ping =  taulu['ping'],
            acc = 0,

        }        
        table.insert(devourPlayers, devourPlayer)	
    end
    
    local frameNumber = 'f' .. devourFrame    
    local tableData =  {
        [frameNumber] = devourPlayers
       }
    
    table.insert(devourEntity, tableData)	 
    
end

local function devourTimer()

    //devour frame
    if Shared.GetTime() - lastServerUpdateFrame > 0.250 then
        lastServerUpdateFrame = Shared.GetTime()
        
        
        createDevourMovementFrame()

        if entityTimeCounter == 0 then
            createDevourEntityFrame()    
            entityTimeCounter = 4*5                    
        end
        
        entityTimeCounter = entityTimeCounter - 1

        devourFrame = devourFrame + 1
    end

   //devour send
    if Shared.GetTime() - lastServerUpdateDevour > 30 then
        lastServerUpdateDevour = Shared.GetTime()        
        devourSendStatus()        
    end
end

Event.Hook("UpdateServer",devourTimer)