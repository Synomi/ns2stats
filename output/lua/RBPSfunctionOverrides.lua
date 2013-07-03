// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSfunctionOverrides.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at www.ns2stats.org or #ns2stats @ qnet =====================

//Default local values, build 244
//NS2Gamerules
local kGameEndCheckInterval = 0.75
local kPregameLength = 3
local kTimeToReadyRoom = 8
local kPauseToSocializeBeforeMapcycle = 30
local kGameStartMessageInterval = 10
			
//constructMixing
local kBuildEffectsInterval = 1

//pickuableMixing
local kCheckForPickupRate = 0.1
local kPickupRange = 1

//commanderAbility
local kDefaultUpdateTime = 0.5

function RBPS:doFunctionOverwrites()

    if RBPSoverwritesDone then return end    
    
    local entityList = Shared.GetEntitiesWithClassname("NS2Gamerules")
    
    local NS2GR = nil
    local state = "na"
    
    if entityList:GetSize() == 0 then    
        if RBPSdebug then
            Shared.Message("Waiting for NS2Gamerules")
        end
        
        return                 
    end
    
    NS2GR = entityList:GetEntityAtIndex(0) //get gamerules entity
            
     
    
    //NS2Gamerules.lua        
    
    if RBPSconfig.tournamentMode then
        //disable mapcycle    
        function NS2GR:UpdateMapCycle()    
            self.timeToCycleMap = nil                
        end
    
        function NS2GR:GetPregameLength()                  
            return 0                
        end
        
        function NS2GR:GetCanJoinTeamNumber(teamNumber)
            return true
        end
    else //not private
        //original mapcycle function
        function NS2GR:UpdateMapCycle()

            if self.timeToCycleMap ~= nil and Shared.GetTime() >= self.timeToCycleMap then

                MapCycle_CycleMap()               
                self.timeToCycleMap = nil
                
            end
            
        end
        
        function NS2GR:GetPregameLength()

            local preGameTime = kPregameLength
            if Shared.GetCheatsEnabled() then
            preGameTime = 0
            end
            
            return preGameTime
            
        end
        
        // Enforce balanced teams
        function NS2GR:GetCanJoinTeamNumber(teamNumber)

        local team1Players = self.team1:GetNumPlayers()
        local team2Players = self.team2:GetNumPlayers()
        
        if (team1Players > team2Players) and (teamNumber == self.team1:GetTeamNumber()) then
            return false
        elseif (team2Players > team1Players) and (teamNumber == self.team2:GetTeamNumber()) then
            return false
        end
        
        return true

        end
    end
    
    //private / nonprivate overwrites in ns2gamerules
       function NS2GR:OnEntityCreate(entity)

        self:OnEntityChange(nil, entity:GetId())

        if entity.GetTeamNumber then
        
            local team = self:GetTeam(entity:GetTeamNumber())
            
            if team then
            
                       //MODIFY START
                    if entity:isa("Egg") then
                        RBPS:addStructureBuiltToLog(entity, nil)
                    end
                    //MODIFY END
            
                if entity:isa("Player") then
            
                    if team:AddPlayer(entity) then

                        // Tell team to send entire tech tree on team change
                        entity.sendTechTreeBase = true           
                        
                    end
                   
                    // Send scoreboard changes to everyone    
                    entity:SetScoreboardChanged(true)
                
                end
                
            end
            
        end
        
    end     
        function NS2GR:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        
        // Also output to log if we're recording the game for playback in the game visualizer
        PostGameViz(string.format("%s killed %s", SafeClassName(doer), SafeClassName(targetEntity)), targetEntity)
        
        self.team1:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.team2:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.worldTeam:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.spectatorTeam:OnEntityKilled(targetEntity, attacker, doer, point, direction)
        self.sponitor:OnEntityKilled(targetEntity, attacker, doer)
        
        	//MODIFY START
		RBPS:addDeathToLog(targetEntity, attacker, doer)
		//MODIFY END

    end       
    
    //ObstacleMixing.lua
    function RemoveAllObstacles()
        for obstacle, v in pairs(gAllObstacles) do
            obstacle:RemoveFromMesh()
        end
        //MODIFY START
       RBPS:gameReset()       
       //MODIFY END
    end
    
    //GhostStructureMixing.lua
    
    function GhostStructureMixin:__initmixin()

        // init the entity in ghost structure mode
        if Server then
        //MODIFY START
        RBPS:ghostStructureAction("ghost_create",self,nil)
        //MODIFY END
            self.isGhostStructure = true
        end
        
    end
    
    function GhostStructureMixin:PerformAction(techNode, position)

        if techNode.techId == kTechId.Cancel and self:GetIsGhostStructure() then
        
            // give back only 75% of resources to avoid abusing the mechanic
            self:TriggerEffects("ghoststructure_destroy")
            local cost = math.round(LookupTechData(self:GetTechId(), kTechDataCostKey, 0) * kRecyclePaybackScalar)
            self:GetTeam():AddTeamResources(cost)
            self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, cost, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
            
            //MODIFY START            
            RBPS:ghostStructureAction("ghost_destroy",self,nil)            
            //MODIFY END
            DestroyEntity(self)

            
        end
    
    end    
    
    //fireMixing.lua  
 //TODO flamethrower damage is not registered, due change in firemixing   
  
    
    //ConstructMixing.lua
    local function AddBuildHealth(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxHealth = self:GetMaxHealth()
        self:AddHealth(scalar * (1 - kStartHealthScalar) * maxHealth, false, false, true)
        
    end
    
    end
    
    local function AddBuildArmor(self, scalar)

    // Add health according to build time.
    if scalar > 0 then
    
        local maxArmor = self:GetMaxArmor()
        self:SetArmor(self:GetArmor() + scalar * (1 - kStartHealthScalar) * maxArmor, true)
        
    end
    
    end

    
function ConstructMixin:SetConstructionComplete(builder)

    // Construction cannot resurrect the dead.
    if self:GetIsAlive() then
    
        local wasComplete = self.constructionComplete
        self.constructionComplete = true
        
        AddBuildHealth(self, 1 - self.buildFraction)
        AddBuildArmor(self, 1 - self.buildFraction)
        
        self.buildFraction = 1
        
         //MODIFY START
        if Server then
            RBPS:addStructureBuiltToLog(self, builder)
        end
        //MODIFY END
        
        if wasComplete ~= self.constructionComplete then
            self:OnConstructionComplete(builder)
        end
        
    end
    
end
function ConstructMixin:Construct(elapsedTime, builder)

    local success = false
    local playAV = false
    
    if not self.constructionComplete then
        
        if builder and builder.OnConstructTarget then
            builder:OnConstructTarget(self)
        end
        
        if Server then

            local startBuildFraction = self.buildFraction
            local newBuildTime = self.buildTime + elapsedTime
            local timeToComplete = self:GetTotalConstructionTime()
            
            if newBuildTime >= timeToComplete then
            
                self:SetConstructionComplete(builder)
                
                // Give points for building structures
                if self:GetIsBuilt() and not self:isa("Hydra") and builder and HasMixin(builder, "Scoring") then                
                    builder:AddScore(kBuildPointValue)
                end
                
            else
            
                if self.buildTime <= self.timeOfNextBuildWeldEffects and newBuildTime >= self.timeOfNextBuildWeldEffects then
                
                    playAV = true
                    self.timeOfNextBuildWeldEffects = newBuildTime + kBuildEffectsInterval
                    
                end
                
                self.buildTime = newBuildTime
                self.buildFraction = math.max(math.min((self.buildTime / timeToComplete), 1), 0)
                
                local scalar = self.buildFraction - startBuildFraction
                AddBuildHealth(self, scalar)
                AddBuildArmor(self, scalar)
                
                if self.oldBuildFraction ~= self.buildFraction then
                
                    if self.OnConstruct then
                        self:OnConstruct(builder, self.buildFraction)
                    end
                    
                    self.oldBuildFraction = self.buildFraction
                    
                end
                
            end
        
                    //MODIFY START
                    local client = Server.GetOwner(builder)
                    if client then
                        RBPS:addConstructionTime(client)            
                    end
                    //MODIFY END

         end
        
        success = true
        
    end
    
    return success, playAV
    
end


      
    //researchMixing.lua
    
    local function AbortResearch(self, refundCost)

        if self.researchProgress > 0 then
        
            local team = self:GetTeam()
            // Team is not always available due to order of destruction during map change.
            if team then
            
                local researchNode = team:GetTechTree():GetTechNode(self.researchingId)
                if researchNode ~= nil then
                
                    //MODIFY START
                    RBPS:addUpgradeAbortedToLog(researchNode, self)
                    //MODIFY END
                
                    // Give money back if refundCost is true.
                    if refundCost then
                        team:SetTeamResources(team:GetTeamResources() + researchNode:GetCost())
                    end
                    
                    ASSERT(researchNode:GetResearching() or researchNode:GetIsUpgrade())
                    
                    researchNode:ClearResearching()
                    
                    if self.OnResearchCancel then
                        self:OnResearchCancel(self.researchingId)
                    end
                    
                    self:ClearResearch()
                    
                    team:GetTechTree():SetTechChanged()
                    
                end
                
            end
            
        end
        
    end    

           
    function ResearchMixin:SetResearching(techNode, player)

        //MODIFY START
        if player:isa("Commander") then RBPS:addUpgradeStartedToLog(techNode, player, self) end
        //MODIFY END
        
        self.researchingId = techNode.techId
        assert(self.researchingId ~= 0)
        self.researchTime = techNode.time
        self.researchingPlayerId = player:GetId()
        
        self.timeResearchStarted = Shared.GetTime()
        self.timeResearchComplete = techNode.time
        self.researchProgress = 0
        
        if self.OnResearch then
            self:OnResearch(self.researchingId)
        end
        
    end
    
    function ResearchMixin:OnKill()
    AbortResearch(self)
    end 

    function ResearchMixin:PerformAction(techNode, position)

        // Process Cancel of research or upgrade.
        if techNode.techId == kTechId.Cancel then
        
            if self:GetIsResearching() then
                AbortResearch(self, true)
            end
            
        end
        
    end

    function ResearchMixin:OnPowerOff()

        if self:GetIsResearching() then        
            AbortResearch(self, true)            
        end       

    end          
        
    function ResearchMixin:TechResearched(structure, researchId)

        if structure and structure:GetId() == self:GetId() then
        
            local researchNode = self:GetTeam():GetTechTree():GetTechNode(researchId)
            
                //MODIFY START
            RBPS:addUpgradeFinishedToLog(researchNode, structure, self)
            //MODIFY END
            
            if researchNode and (researchNode:GetIsEnergyManufacture() or researchNode:GetIsManufacture() or researchNode:GetIsPlasmaManufacture()) then        

                // Handle manufacture actions        
                self:CreateManufactureEntity(researchId)
                
            elseif self.OnResearchComplete then
                self:OnResearchComplete(researchId)
            end
        
            self:ClearResearch()
            
        end

    end
    
    //recycleMixing.lua
    
    
function RecycleMixin:OnResearchComplete(researchId)

    if researchId == kTechId.Recycle then
        
        self:TriggerEffects("recycle_end")
        
        // Amount to get back, accounting for upgraded structures too
        local upgradeLevel = 0
        if self.GetUpgradeLevel then
            upgradeLevel = self:GetUpgradeLevel()
        end
        
        local amount = GetRecycleAmount(self:GetTechId(), upgradeLevel)
        // returns a scalar from 0-1 depending on health the structure has (at the present moment)
        local scalar = self:GetRecycleScalar() * kRecyclePaybackScalar
        
        // We round it up to the nearest value thus not having weird
        // fracts of costs being returned which is not suppose to be 
        // the case.
        local finalRecycleAmount = math.round(amount * scalar)
        
        self:GetTeam():AddTeamResources(finalRecycleAmount)
        
        self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, finalRecycleAmount, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
        
        Server.SendNetworkMessage( "Recycle", BuildRecycleMessage(amount - finalRecycleAmount, self:GetTechId(), finalRecycleAmount), true )
        
        local team = self:GetTeam()
        local deathMessageTable = team:GetDeathMessage(self, kDeathMessageIcon.Recycled, self)
        team:ForEachPlayer(function(player) if player:GetClient() then Server.SendNetworkMessage(player:GetClient(), "DeathMessage", deathMessageTable, true) end end)
        
        self.recycled = true
        self.timeRecycled = Shared.GetTime()

        self:OnRecycled()

   //MODIFY START
            if Server then
                RBPS:addRecycledToLog(self, finalRecycleAmount)
            end
            //MODIFY END
        
    end

end
   
    //pickuableMixing.lua
    
    function PickupableMixin:__initmixin()

        if Server then
            //MODIFY START
            RBPS:addPickableItemCreateToLog(self)
            //MODIFY END
            if not self.GetCheckForRecipient or self:GetCheckForRecipient() then
                self:AddTimedCallback(PickupableMixin._CheckForPickup, kCheckForPickupRate)
            end
            
            if not self.GetIsPermanent or not self:GetIsPermanent() then
                self:AddTimedCallback(PickupableMixin._DestroySelf, kItemStayTime)
            end
            
        end
        
    end

    
    function PickupableMixin:_CheckForPickup()

        assert(Server)
        
        // Scan for nearby friendly players that need medpacks because we don't have collision detection yet
        local player = self:_GetNearbyRecipient()

        if player ~= nil then
        
            self:OnTouch(player)
            //MODIFY START
            RBPS:addPickableItemPickedToLog(self, player)
            //MODIFY END
            DestroyEntity(self)
            
        end
        
        // Continue the callback.
        return true
        
    end
    
    
    function PickupableMixin:_DestroySelf()

        assert(Client == nil)
        
        //MODIFY START
        if Server then
            RBPS:addPickableItemDestroyedToLog(self)
        end
        //MODIFY END
        
        DestroyEntity(self)

    end
    
    //NS2Utility.lua

    local kNumMeleeZones = 3
    function PerformGradualMeleeAttack(weapon, player, damage, range, optionalCoords, altMode, filter)

        local didHit, target, endPoint, direction, surface
        local didHitNow
        local damageMult = 1
        local stepSize = 1 / kNumMeleeZones

        for i = 1, kNumMeleeZones do

            didHitNow, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true, i * stepSize, nil, filter)
            didHit = didHit or didHitNow
            if target and didHitNow then

                if target:isa("Player") then
                    damageMult = 1 - (i - 1) * stepSize
                end

                //damageMult = math.cos(damageMult * (math.pi / 2) + math.pi) + 1
                //Print(ToString(damageMult))
                break

            end

        end

        if didHit then
            weapon:DoDamage(damage * damageMult, target, endPoint, direction, surface, altMode)
        end

         //MODIFY START
            if Server then
                if not didHit then        
                    RBPS:addMissToLog(player)
                end
             end
            //MODIFY END

        return didHit, target, endPoint, direction, surface

    end

    function AttackMeleeCapsule(weapon, player, damage, range, optionalCoords, altMode, filter)

        // Enable tracing on this capsule check, last argument.
        local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true, 1, nil, filter)

        if didHit then
            weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        end

     //MODIFY START
        if Server then
            if not didHit then        
                RBPS:addMissToLog(player)
            end
         end
            //MODIFY END
        return didHit, target, endPoint, surface

    end   
       
    
    //projectile_server.lua

function Projectile:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)

    if not self:GetSimulatePhysics() then
        if self.physicsBody then
            Shared.DestroyCollisionObject(self.physicsBody)
            self.physicsBody = nil
        end
        return            
    end
  
    // don't quite know why this is here...
    // self:CreatePhysics() 
    
    // If the projectile has moved outside of the world, destroy it
    local coords = self.physicsBody:GetCoords()

    // Update the position/orientation of the entity based on the current
    // position/orientation of the physics object.
    self:SetCoords(coords)

    // If we move the projectile outside the valid bounds of the world, it will get
    // destroyed so we need to check for that to avoid errors.
    if self:GetIsDestroyed() then
        return
    end
    
    // DL: Workaround for bouncing projectiles. Detect a change in velocity and find the impacted object
    // by tracing a ray from the last frame's origin.
    local velocity = self.physicsBody:GetLinearVelocity()
    local origin = self:GetOrigin()

    if self.lastVelocity ~= nil then

        local delta = velocity - self.lastVelocity
        // if we have hit something that slowed us down in xz direction, or if we are standing still, we explode
        if delta:GetLengthSquaredXZ() > 0.0001 or velocity:GetLength() < 0.0001 then                    

            local endPoint = self.lastOrigin + self.lastVelocity * (deltaTime + self.radius * 3)
            local trace = Shared.TraceCapsule(self.lastOrigin, endPoint, self.radius, 0, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))

            self:SetOrigin(trace.endPoint)
            if trace.fraction == 0 or trace.fraction == 1 then
                trace.normal = Vector(0, 1, 0)
            end
            self:ProcessHit(trace.entity, trace.surface, trace.normal)

       //MODIFY START
                if trace.entity and trace.entity:isa("Player") and self:GetOwner() ~= trace.entity:isa("Player") then
                    //is player
                else                                    
                    RBPS:addMissToLog(self:GetOwner())
                end
                //MODIFY END
        end

    end
    
    self.lastVelocity = velocity
    self.lastOrigin = origin
    
end
    
    //networkmessages.lua    
    function BuildChatMessage(teamOnly, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage)

        local message = { }

        message.teamOnly = teamOnly
        message.playerName = playerName
        message.locationId = playerLocationId
        message.teamNumber = playerTeamNumber
        message.teamType = playerTeamType
        message.message = chatMessage

        //MODIFY START
            RBPS:processChatCommand(playerName,chatMessage)    
        //MODIFY END
        return message
    
    end   
    
    if RBPSdebug then
        Shared.Message("NS2Stats function overwrites done.")    
    end
    RBPSoverwritesDone = true

end