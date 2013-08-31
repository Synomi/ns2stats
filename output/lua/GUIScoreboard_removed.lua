
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIScoreboard.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the player scoreboard (scores, pings, etc).
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIScoreboard' (GUIScript)

GUIScoreboard.kGameTimeBackgroundSize = Vector(650, GUIScale(32), 0)
GUIScoreboard.kGameTimeTextSize = GUIScale(22)

GUIScoreboard.kClickForMouseBackgroundSize = Vector(GUIScale(200), GUIScale(32), 0)
GUIScoreboard.kClickForMouseTextSize = GUIScale(22)
GUIScoreboard.kClickForMouseText = Locale.ResolveString("SB_CLICK_FOR_MOUSE")

// Shared constants.
GUIScoreboard.kTeamInfoFontName      = "fonts/Arial_15.fnt"
GUIScoreboard.kPlayerStatsFontName   = "fonts/Arial_15.fnt"
GUIScoreboard.kTeamNameFontName      = "fonts/Arial_17.fnt"
GUIScoreboard.kGameTimeFontName      = "fonts/Arial_17.fnt"
GUIScoreboard.kClickForMouseFontName = "fonts/Arial_17.fnt"

GUIScoreboard.kLowPingThreshold = 100
GUIScoreboard.kLowPingColor = Color(0, 1, 0, 1)
GUIScoreboard.kMedPingThreshold = 249
GUIScoreboard.kMedPingColor = Color(1, 1, 0, 1)
GUIScoreboard.kHighPingThreshold = 499
GUIScoreboard.kHighPingColor = Color(1, 0.5, 0, 1)
GUIScoreboard.kInsanePingColor = Color(1, 0, 0, 1)
GUIScoreboard.kVoiceMuteColor = Color(1, 0, 0, 0.5)
GUIScoreboard.kVoiceDefaultColor = Color(1, 1, 1, 0.5)

// Team constants.
GUIScoreboard.kTeamBackgroundYOffset = 50
GUIScoreboard.kTeamNameFontSize = 26
GUIScoreboard.kTeamInfoFontSize = 16
GUIScoreboard.kTeamItemWidth = 600
GUIScoreboard.kTeamItemHeight = GUIScoreboard.kTeamNameFontSize + GUIScoreboard.kTeamInfoFontSize + 8
GUIScoreboard.kTeamSpacing = 32
GUIScoreboard.kTeamScoreColumnStartX = 200
GUIScoreboard.kTeamColumnSpacingX = 50

// Player constants.
GUIScoreboard.kPlayerStatsFontSize = 16
GUIScoreboard.kPlayerItemWidthBuffer = 10
GUIScoreboard.kPlayerItemHeight = 32
GUIScoreboard.kPlayerSpacing = 4
GUIScoreboard.kPlayerVoiceChatIconSize = 20
//MODIFY START
GUIScoreboard.kBadgeSize = 22
//MODIFY END

// Color constants.
GUIScoreboard.kBlueColor = ColorIntToColor(kMarineTeamColor)
GUIScoreboard.kBlueHighlightColor = Color(0.30, 0.69, 1, 1)
GUIScoreboard.kRedColor = kRedColor--ColorIntToColor(kAlienTeamColor)
GUIScoreboard.kRedHighlightColor = Color(1, 0.79, 0.23, 1)
GUIScoreboard.kSpectatorColor = ColorIntToColor(kNeutralTeamColor)
GUIScoreboard.kSpectatorHighlightColor = Color(0.8, 0.8, 0.8, 1)

GUIScoreboard.kCommanderFontColor = Color(1, 1, 0, 1)
GUIScoreboard.kWhiteColor = Color(1,1,1,1)
local kDeadColor = Color(1,0,0,1)

local kConnectionProblemsIcon = PrecacheAsset("ui/ethernet-connect.dds")

function GUIScoreboard:OnResolutionChanged(oldX, oldY, newX, newY)

    GUIScoreboard.kGameTimeBackgroundSize = Vector(650, GUIScale(32), 0)
    GUIScoreboard.kGameTimeTextSize = GUIScale(22)
    
    GUIScoreboard.kClickForMouseBackgroundSize = Vector(GUIScale(200), GUIScale(32), 0)
    GUIScoreboard.kClickForMouseTextSize = GUIScale(22)
    
    self:Uninitialize()
    self:Initialize()
    
end

local function GetTeamItemWidth()
    return (Client.GetScreenWidth() / 2) * 0.95
end

local function CreateTeamBackground(self, teamNumber)

    local color = nil
    local teamItem = GUIManager:CreateGraphicItem()
    
    // Background
    teamItem:SetSize(Vector(GetTeamItemWidth(), GUIScoreboard.kTeamItemHeight, 0))
    if teamNumber == kTeamReadyRoom then
    
        color = GUIScoreboard.kSpectatorColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
        teamItem:SetPosition(Vector(-GetTeamItemWidth() / 2, -35, 0))
        
    elseif teamNumber == kTeam1Index then
    
        color = GUIScoreboard.kBlueColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        teamItem:SetPosition(Vector(-GetTeamItemWidth() - 10, GUIScoreboard.kTeamBackgroundYOffset, 0))
        
    elseif teamNumber == kTeam2Index then
    
        color = GUIScoreboard.kRedColor
        teamItem:SetAnchor(GUIItem.Middle, GUIItem.Top)
        teamItem:SetPosition(Vector(10, GUIScoreboard.kTeamBackgroundYOffset, 0))
        
    end
    
    teamItem:SetColor(Color(0, 0, 0, 0.75))
    teamItem:SetIsVisible(false)
    teamItem:SetLayer(kGUILayerScoreboard)
    
    // Team name text item.
    local teamNameItem = GUIManager:CreateTextItem()
    teamNameItem:SetFontName(GUIScoreboard.kTeamNameFontName)
    teamNameItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    teamNameItem:SetTextAlignmentX(GUIItem.Align_Min)
    teamNameItem:SetTextAlignmentY(GUIItem.Align_Min)
    teamNameItem:SetPosition(Vector(10, 5, 0))
    teamNameItem:SetColor(color)
    teamItem:AddChild(teamNameItem)
    
    // Add team info (team resources and number of players).
    local teamInfoItem = GUIManager:CreateTextItem()
    teamInfoItem:SetFontName(GUIScoreboard.kTeamInfoFontName)
    teamInfoItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    teamInfoItem:SetTextAlignmentX(GUIItem.Align_Min)
    teamInfoItem:SetTextAlignmentY(GUIItem.Align_Min)
    teamInfoItem:SetPosition(Vector(12, GUIScoreboard.kTeamNameFontSize + 7, 0))
    teamInfoItem:SetColor(color)
    teamItem:AddChild(teamInfoItem)
    
                     //MODIFY START
    //local currentColumnX = Client.GetScreenWidth() / 6
    local currentColumnX = Client.GetScreenWidth() / 7
    //MODIFY END
	
    local playerDataRowY = 10
    
    // Status text item.
    local statusItem = GUIManager:CreateTextItem()
    statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    statusItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    statusItem:SetTextAlignmentX(GUIItem.Align_Min)
    statusItem:SetTextAlignmentY(GUIItem.Align_Min)
    statusItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    statusItem:SetColor(color)
    statusItem:SetText("")
    teamItem:AddChild(statusItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2
    
    // Score text item.
    local scoreItem = GUIManager:CreateTextItem()
    scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    scoreItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    scoreItem:SetTextAlignmentX(GUIItem.Align_Min)
    scoreItem:SetTextAlignmentY(GUIItem.Align_Min)
    scoreItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    scoreItem:SetColor(color)
    scoreItem:SetText(Locale.ResolveString("SB_SCORE"))
    teamItem:AddChild(scoreItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Kill text item.
    local killsItem = GUIManager:CreateTextItem()
    killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    killsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    killsItem:SetTextAlignmentX(GUIItem.Align_Min)
    killsItem:SetTextAlignmentY(GUIItem.Align_Min)
    killsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    killsItem:SetColor(color)
    killsItem:SetText(Locale.ResolveString("SB_KILLS"))
    teamItem:AddChild(killsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Deaths text item.
    local deathsItem = GUIManager:CreateTextItem()
    deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    deathsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    deathsItem:SetTextAlignmentX(GUIItem.Align_Min)
    deathsItem:SetTextAlignmentY(GUIItem.Align_Min)
    deathsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    deathsItem:SetColor(color)
    deathsItem:SetText(Locale.ResolveString("SB_DEATHS"))
    teamItem:AddChild(deathsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
	
						//MODIFY START
    //assists
    local assistsItem = GUIManager:CreateTextItem()
    assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)    
    assistsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    assistsItem:SetTextAlignmentX(GUIItem.Align_Min)
    assistsItem:SetTextAlignmentY(GUIItem.Align_Min)
    assistsItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    assistsItem:SetColor(color)
    assistsItem:SetText("Assists")
    teamItem:AddChild(assistsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    //MODIFY END
    
    // Resources text item.
    local resItem = GUIManager:CreateTextItem()
    resItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    resItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    resItem:SetTextAlignmentX(GUIItem.Align_Min)
    resItem:SetTextAlignmentY(GUIItem.Align_Min)
    resItem:SetPosition(Vector(currentColumnX , playerDataRowY, 0))
    resItem:SetColor(color)
    resItem:SetText(Locale.ResolveString("SB_RES"))
    teamItem:AddChild(resItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Ping text item.
    local pingItem = GUIManager:CreateTextItem()
    pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    pingItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    pingItem:SetTextAlignmentX(GUIItem.Align_Min)
    pingItem:SetTextAlignmentY(GUIItem.Align_Min)
    pingItem:SetPosition(Vector(currentColumnX, playerDataRowY, 0))
    pingItem:SetColor(color)
    pingItem:SetText(Locale.ResolveString("SB_PING"))
    teamItem:AddChild(pingItem)
    
    return { Background = teamItem, TeamName = teamNameItem, TeamInfo = teamInfoItem }
    
end

function GUIScoreboard:Initialize()

    self.visible = false
    
    self.teams = { }
    self.reusePlayerItems = { }
    
    self.gameTimeBackground = GUIManager:CreateGraphicItem()
    self.gameTimeBackground:SetSize(GUIScoreboard.kGameTimeBackgroundSize)
    //self.gameTimeBackground:SetPosition(Vector(0, -GUIScoreboard.kGameTimeBackgroundSize.y - 6, 0))
    self.gameTimeBackground:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.gameTimeBackground:SetPosition( Vector(- GUIScoreboard.kGameTimeBackgroundSize.x / 2, 10, 0) )
    self.gameTimeBackground:SetIsVisible(false)
    self.gameTimeBackground:SetColor(Color(0,0,0,0.5))
    self.gameTimeBackground:SetLayer(kGUILayerScoreboard)
    
    self.gameTime = GUIManager:CreateTextItem()
    self.gameTime:SetFontName(GUIScoreboard.kGameTimeFontName)
    self.gameTime:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gameTime:SetTextAlignmentX(GUIItem.Align_Center)
    self.gameTime:SetTextAlignmentY(GUIItem.Align_Center)
    self.gameTime:SetColor(Color(1, 1, 1, 1))
    self.gameTime:SetText("")
    self.gameTimeBackground:AddChild(self.gameTime)
    
    // Teams table format: Team GUIItems, color, player GUIItem list, get scores function.
    // Spectator team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeamReadyRoom), TeamName = ScoreboardUI_GetSpectatorTeamName(),
                               Color = GUIScoreboard.kSpectatorColor, PlayerList = { }, HighlightColor = GUIScoreboard.kSpectatorHighlightColor,
                               GetScores = ScoreboardUI_GetSpectatorScores, TeamNumber = kTeamReadyRoom })
                               
    // Blue team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeam1Index), TeamName = ScoreboardUI_GetBlueTeamName(),
                               Color = GUIScoreboard.kBlueColor, PlayerList = { }, HighlightColor = GUIScoreboard.kBlueHighlightColor,
                               GetScores = ScoreboardUI_GetBlueScores, TeamNumber = kTeam1Index})                              
                       
    // Red team.
    table.insert(self.teams, { GUIs = CreateTeamBackground(self, kTeam2Index), TeamName = ScoreboardUI_GetRedTeamName(),
                               Color = GUIScoreboard.kRedColor, PlayerList = { }, HighlightColor = GUIScoreboard.kRedHighlightColor,
                               GetScores = ScoreboardUI_GetRedScores, TeamNumber = kTeam2Index })

    

    self.playerHighlightItem = GUIManager:CreateGraphicItem()
    self.playerHighlightItem:SetSize(Vector(GetTeamItemWidth() - (GUIScoreboard.kPlayerItemWidthBuffer * 2), GUIScoreboard.kPlayerItemHeight, 0))
    self.playerHighlightItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.playerHighlightItem:SetColor(Color(1, 1, 1, 1))
    self.playerHighlightItem:SetTexture("ui/hud_elements.dds")
    self.playerHighlightItem:SetTextureCoordinates(0, 0.16, 0.558, 0.32)
    self.playerHighlightItem:SetIsVisible(false)
    
    self.clickForMouseBackground = GUIManager:CreateGraphicItem()
    self.clickForMouseBackground:SetSize(GUIScoreboard.kClickForMouseBackgroundSize)
    self.clickForMouseBackground:SetPosition(Vector(-GUIScoreboard.kClickForMouseBackgroundSize.x / 2, -GUIScoreboard.kClickForMouseBackgroundSize.y - 5, 0))
    self.clickForMouseBackground:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.clickForMouseBackground:SetIsVisible(false)
    
    self.clickForMouseIndicator = GUIManager:CreateTextItem()
    self.clickForMouseIndicator:SetFontName(GUIScoreboard.kClickForMouseFontName)
    self.clickForMouseIndicator:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.clickForMouseIndicator:SetTextAlignmentX(GUIItem.Align_Center)
    self.clickForMouseIndicator:SetTextAlignmentY(GUIItem.Align_Center)
    self.clickForMouseIndicator:SetColor(Color(0, 0, 0, 1))
    self.clickForMouseIndicator:SetText(GUIScoreboard.kClickForMouseText)
    self.clickForMouseBackground:AddChild(self.clickForMouseIndicator)
    
    self.centeredFrame = GUIManager:CreateGraphicItem()
    self.centeredFrame:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.centeredFrame:SetColor(Color(0,0,0,0))
    self.centeredFrame:SetLayer(kGUILayerScoreboard)
    
    self.centeredFrame:AddChild(self.teams[2].GUIs.Background)
    self.centeredFrame:AddChild(self.teams[3].GUIs.Background)
    
    self.connectionProblemsIcon = GUIManager:CreateGraphicItem()
    self.connectionProblemsIcon:SetAnchor(GUIItem.Left, GUIItem.Center)
    self.connectionProblemsIcon:SetPosition(Vector(32, 0, 0))
    self.connectionProblemsIcon:SetSize(Vector(64, 64, 0))
    self.connectionProblemsIcon:SetLayer(kGUILayerScoreboard)
    self.connectionProblemsIcon:SetTexture(kConnectionProblemsIcon)
    self.connectionProblemsIcon:SetColor(Color(1, 0, 0, 1))
    self.connectionProblemsIcon:SetIsVisible(false)
    
    self.connectionProblemsDetector = CreateTokenBucket(8, 20)
    
    self.mousePressed = { LMB = { Down = nil }, RMB = { Down = nil } }

end

function GUIScoreboard:Uninitialize()

    for index, team in ipairs(self.teams) do
        GUI.DestroyItem(team["GUIs"]["Background"])
    end
    self.teams = { }
    
    for index, playerItem in ipairs(self.reusePlayerItems) do
        GUI.DestroyItem(playerItem["Background"])
    end
    self.reusePlayerItems = { }
    
    GUI.DestroyItem(self.clickForMouseIndicator)
    self.clickForMouseIndicator = nil
    GUI.DestroyItem(self.clickForMouseBackground)
    self.clickForMouseBackground = nil
    
    GUI.DestroyItem(self.gameTime)
    self.gameTime = nil
    GUI.DestroyItem(self.gameTimeBackground)
    self.gameTimeBackground = nil
    
    GUI.DestroyItem(self.connectionProblemsIcon)
    self.connectionProblemsIcon = nil
    
end

local function SetMouseVisible(self, setVisible)

    if self.mouseVisible ~= setVisible then
    
        self.mouseVisible = setVisible
        
        MouseTracker_SetIsVisible(self.mouseVisible, "ui/Cursor_MenuDefault.dds", true)
        if self.mouseVisible then
            self.clickForMouseBackground:SetIsVisible(false)
        end
        
    end
    
end

function GUIScoreboard:Update(deltaTime)

    PROFILE("GUIScoreboard:Update")
    
    if not self.visible then
        SetMouseVisible(self, false)
    end
    
    if not self.mouseVisible then
    
        // Click for mouse only visible when not a commander and when the scoreboard is visible.
        local clickForMouseBackgroundVisible = (not PlayerUI_IsACommander()) and self.visible
        self.clickForMouseBackground:SetIsVisible(clickForMouseBackgroundVisible)
        local backgroundColor = PlayerUI_GetTeamColor()
        backgroundColor.a = 0.8
        self.clickForMouseBackground:SetColor(backgroundColor)
        
    end
    
    //First, update teams.
    for index, team in ipairs(self.teams) do
    
        // Don't draw if no players on team
        local numPlayers = table.count(team["GetScores"]())    
        team["GUIs"]["Background"]:SetIsVisible(self.visible and (numPlayers > 0))
        
        if self.visible then
            self:UpdateTeam(team)
        end
        
    end
    
    // update game time
    self.gameTimeBackground:SetIsVisible(self.visible)
    self.gameTime:SetIsVisible(self.visible)
    
    if self.visible then
    
        local gameTime = PlayerUI_GetGameStartTime()
        
        if gameTime ~= 0 then
            gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
        end
        
        local minutes = math.floor(gameTime / 60)
        local seconds = gameTime - minutes * 60
        local serverName = Client.GetServerIsHidden() and "Hidden" or Client.GetConnectedServerName()
        local gameTimeText = string.format(serverName .. " | " .. Shared.GetMapName() .. " - %d:%02d", minutes, seconds)
        
        self.gameTime:SetText(gameTimeText)
        
        // Next, position teams.
        
        local numTeams = table.count(self.teams)
        if numTeams > 0 then
        
            // Update Spectator Position
            for index, team in ipairs(self.teams) do
            
                if team.TeamNumber == kTeamReadyRoom then
                
                    local newPosition = team["GUIs"]["Background"]:GetPosition()
                    newPosition.y = - team["GUIs"]["Background"]:GetSize().y - 35
                    team["GUIs"]["Background"]:SetPosition(newPosition)
                    
                end
                
            end
            
        end
        
        local playerCount = math.max(#ScoreboardUI_GetBlueScores(), #ScoreboardUI_GetRedScores())
        local frameHeight = GUIScoreboard.kPlayerItemHeight * playerCount
        
        local yPos = math.max(-Client.GetScreenHeight()/2, -frameHeight/2 - 160)
        
        self.centeredFrame:SetPosition(Vector(0, yPos, 0))
        
    end
    
    // Detect connection problems and display the indicator.
    self.droppedMoves = self.droppedMoves or 0
    local numberOfDroppedMovesTotal = Shared.GetNumDroppedMoves()
    if numberOfDroppedMovesTotal ~= self.droppedMoves then
    
        self.connectionProblemsDetector:RemoveTokens(numberOfDroppedMovesTotal - self.droppedMoves)
        self.droppedMoves = numberOfDroppedMovesTotal
        
    end
    
    local tooManyDroppedMoves = self.connectionProblemsDetector:GetNumberOfTokens() < 6
    local connectionProblems = Client.GetConnectionProblems()
    local connectionProblemsDetected = tooManyDroppedMoves or connectionProblems
    
    self.connectionProblemsIcon:SetIsVisible(connectionProblemsDetected)
    if connectionProblemsDetected then
    
        local alpha = 0.5 + (((math.cos(Shared.GetTime() * 10) + 1) / 2) * 0.5)
        local useColor = Color(0, 0, 0, alpha)
        if tooManyDroppedMoves and connectionProblems then
            useColor.g = 1
        elseif tooManyDroppedMoves then
        
            useColor.r = 1
            useColor.g = 1
            
        elseif connectionProblems then
            useColor.r = 1
        end
        
        self.connectionProblemsIcon:SetColor(useColor)
        
    end
    
end

function GUIScoreboard:UpdateTeam(updateTeam)
    
    local teamGUIItem = updateTeam["GUIs"]["Background"]
    local teamNameGUIItem = updateTeam["GUIs"]["TeamName"]
    local teamInfoGUIItem = updateTeam["GUIs"]["TeamInfo"]
    local teamNameText = updateTeam["TeamName"]
    local teamColor = updateTeam["Color"]
    local localPlayerHighlightColor = updateTeam["HighlightColor"]
    local playerList = updateTeam["PlayerList"]
    local teamScores = updateTeam["GetScores"]()
    
    // Determines if the local player can see secret information
    // for this team.
    local isVisibleTeam = false
    local player = Client.GetLocalPlayer()
    if player then
    
        local teamNum = player:GetTeamNumber()
        // Can see secret information if the player is on the team or is a spectator.
        if teamNum == updateTeam["TeamNumber"] or teamNum == kSpectatorIndex then
            isVisibleTeam = true
        end
        
    end
    
    // How many items per player.
    local numPlayers = table.count(teamScores)
    
    // Update the team name text.
    teamNameGUIItem:SetText(string.format("%s (%d %s)", teamNameText, numPlayers, numPlayers == 1 and Locale.ResolveString("SB_PLAYER") or Locale.ResolveString("SB_PLAYERS")))
    
    // Update team resource display
    local teamResourcesString = ConditionalValue(isVisibleTeam, string.format(Locale.ResolveString("SB_TEAM_RES"), ScoreboardUI_GetTeamResources(updateTeam["TeamNumber"])), "")
    teamInfoGUIItem:SetText(string.format("%s", teamResourcesString))
    
    // Make sure there is enough room for all players on this team GUI.
    teamGUIItem:SetSize(Vector(GetTeamItemWidth(), (GUIScoreboard.kTeamItemHeight) + ((GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing) * numPlayers), 0))
    
    // Resize the player list if it doesn't match.
    if table.count(playerList) ~= numPlayers then
        self:ResizePlayerList(playerList, numPlayers, teamGUIItem)
    end
    
    local currentY = GUIScoreboard.kTeamNameFontSize + GUIScoreboard.kTeamInfoFontSize + 10
    local currentPlayerIndex = 1
    local deadString = Locale.ResolveString("STATUS_DEAD")
    
    for index, player in pairs(playerList) do
    
        local playerRecord = teamScores[currentPlayerIndex]
        local playerName = playerRecord.Name
        local clientIndex = playerRecord.ClientIndex
        local score = playerRecord.Score
        local kills = playerRecord.Kills
        local deaths = playerRecord.Deaths
											 //MODIFY START
        local assists = playerRecord.Assists
        local badgeTexture = playerRecord.Badge
        //MODIFY END
        local isCommander = playerRecord.IsCommander
        local isRookie = playerRecord.IsRookie
        local resourcesStr = ConditionalValue(isVisibleTeam, tostring(math.floor(playerRecord.Resources * 10) / 10), "-")
        local ping = playerRecord.Ping
        local pingStr = tostring(ping)
        local currentPosition = Vector(player["Background"]:GetPosition())
        local playerStatus = playerRecord.Status
        local isSpectator = playerRecord.IsSpectator
        local isDead = playerRecord.Status == deadString
        
        if playerRecord.IsCommander then
            score = "*"
        end
        
        currentPosition.y = currentY
        player["Background"]:SetPosition(currentPosition)
        player["Background"]:SetColor(teamColor)
        
        // Handle local player highlight
        if ScoreboardUI_IsPlayerLocal(playerName) then
            if self.playerHighlightItem:GetParent() ~= player["Background"] then
                if self.playerHighlightItem:GetParent() ~= nil then
                    self.playerHighlightItem:GetParent():RemoveChild(self.playerHighlightItem)
                end
                player["Background"]:AddChild(self.playerHighlightItem)
                self.playerHighlightItem:SetIsVisible(true)
                self.playerHighlightItem:SetColor(localPlayerHighlightColor)
            end
        end
        
        player["Index"]:SetText(index..".")
        player["Name"]:SetText(playerName)
        
        // Needed to determine who to (un)mute when voice icon is clicked.
        player["ClientIndex"] = clientIndex
        
        // Voice icon.
        local playerVoiceColor = GUIScoreboard.kVoiceDefaultColor
        if ChatUI_GetClientMuted(clientIndex) then
            playerVoiceColor = GUIScoreboard.kVoiceMuteColor
        elseif ChatUI_GetIsClientSpeaking(clientIndex) then
            playerVoiceColor = teamColor
        end

        player["Voice"]:SetColor(playerVoiceColor)
        player["Score"]:SetText(tostring(score))
        player["Kills"]:SetText(tostring(kills))
        player["Deaths"]:SetText(tostring(deaths))
												//MODIFY START
        player["Assists"]:SetText(tostring(assists))
        if badgeTexture then
            player["Badge"]:SetIsVisible(true)
            player["Badge"]:SetTexture(badgeTexture)
        else
            player["Badge"]:SetIsVisible(false)
        end
        //MODIFY END
        player["Status"]:SetText(playerStatus)
        player["Resources"]:SetText(resourcesStr)
        player["Ping"]:SetText(pingStr)
        
        if playerRecord.IsCommander then
        
            player["Score"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Kills"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Deaths"]:SetColor(GUIScoreboard.kCommanderFontColor)
																 //MODIFY START
            player["Assists"]:SetColor(GUIScoreboard.kCommanderFontColor)
            //MODIFY END
            player["Status"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Resources"]:SetColor(GUIScoreboard.kCommanderFontColor)
            player["Ping"]:SetColor(GUIScoreboard.kCommanderFontColor)    
            player["Name"]:SetColor(GUIScoreboard.kCommanderFontColor)

        elseif isDead and isVisibleTeam then
        
            player["Name"]:SetColor(kDeadColor)
            player["Status"]:SetColor(kDeadColor)
            
        elseif playerRecord.IsRookie and isVisibleTeam then
        
            player["Name"]:SetColor(kNewPlayerColorFloat)
            player["Status"]:SetColor(GUIScoreboard.kWhiteColor)
        
        else
        
            player["Score"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Kills"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Deaths"]:SetColor(GUIScoreboard.kWhiteColor)
																//MODIFY START
            player["Assists"]:SetColor(GUIScoreboard.kWhiteColor)
            //MODIFY END
            player["Status"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Resources"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Ping"]:SetColor(GUIScoreboard.kWhiteColor)
            player["Name"]:SetColor(GUIScoreboard.kWhiteColor)

        end  
        
        if ping < GUIScoreboard.kLowPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kLowPingColor)
        elseif ping < GUIScoreboard.kMedPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kMedPingColor)
        elseif ping < GUIScoreboard.kHighPingThreshold then
            player["Ping"]:SetColor(GUIScoreboard.kHighPingColor)
        else
            player["Ping"]:SetColor(GUIScoreboard.kInsanePingColor)
        end
        currentY = currentY + GUIScoreboard.kPlayerItemHeight + GUIScoreboard.kPlayerSpacing
        currentPlayerIndex = currentPlayerIndex + 1
        
    end

end

function GUIScoreboard:ResizePlayerList(playerList, numPlayers, teamGUIItem)
    
    while table.count(playerList) > numPlayers do
        teamGUIItem:RemoveChild(playerList[1]["Background"])
        playerList[1]["Background"]:SetIsVisible(false)
        table.insert(self.reusePlayerItems, playerList[1])
        table.remove(playerList, 1)
    end
    
    while table.count(playerList) < numPlayers do
        local newPlayerItem = self:CreatePlayerItem()
        table.insert(playerList, newPlayerItem)
        teamGUIItem:AddChild(newPlayerItem["Background"])
        newPlayerItem["Background"]:SetIsVisible(true)
    end

end

function GUIScoreboard:CreatePlayerItem()
    
    // Reuse an existing player item if there is one.
    if table.count(self.reusePlayerItems) > 0 then
        local returnPlayerItem = self.reusePlayerItems[1]
        table.remove(self.reusePlayerItems, 1)
        return returnPlayerItem
    end
    
    // Create background.
    local playerItem = GUIManager:CreateGraphicItem()
    playerItem:SetSize(Vector(GetTeamItemWidth() - (GUIScoreboard.kPlayerItemWidthBuffer * 2), GUIScoreboard.kPlayerItemHeight, 0))
    playerItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerItem:SetPosition(Vector(GUIScoreboard.kPlayerItemWidthBuffer, GUIScoreboard.kPlayerItemHeight / 2, 0))
    playerItem:SetColor(Color(1, 1, 1, 1))
    playerItem:SetTexture("ui/hud_elements.dds")
    playerItem:SetTextureCoordinates(0, 0, 0.558, 0.16)

    // Player number item
    local playerIndexItem = GUIManager:CreateTextItem()
    playerIndexItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerIndexItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerIndexItem:SetTextAlignmentX(GUIItem.Align_Max)
    playerIndexItem:SetTextAlignmentY(GUIItem.Align_Min)
    playerIndexItem:SetPosition(Vector(15, 5, 0))
    playerIndexItem:SetColor(Color(0.5, 0.5, 0.5, 1))
    playerItem:AddChild(playerIndexItem)
    
    // Player name text item.
    local playerNameItem = GUIManager:CreateTextItem()
    playerNameItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    playerNameItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerNameItem:SetTextAlignmentX(GUIItem.Align_Min)
    playerNameItem:SetTextAlignmentY(GUIItem.Align_Min)
            	    	 //MODIFY START
    playerNameItem:SetPosition(Vector(GUIScoreboard.kPlayerVoiceChatIconSize + GUIScoreboard.kBadgeSize + 10, 5, 0))
    //playerNameItem:SetPosition(Vector(35, 5, 0))
    //MODIFY END
    playerNameItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(playerNameItem)
    
    // Player voice icon item.
    local playerVoiceIcon = GUIManager:CreateGraphicItem()
    playerVoiceIcon:SetSize(Vector(GUIScoreboard.kPlayerVoiceChatIconSize, GUIScoreboard.kPlayerVoiceChatIconSize, 0))
    playerVoiceIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
            	   	//MODIFY START
    playerVoiceIcon:SetPosition(Vector(-GUIScoreboard.kPlayerVoiceChatIconSize - 10 - GUIScoreboard.kBadgeSize, 0, 0))
    //playerVoiceIcon:SetPosition(Vector(-GUIScoreboard.kPlayerVoiceChatIconSize - 0, 0, 0))
    //MODIFY END
    playerVoiceIcon:SetTexture("ui/speaker.dds")
    playerNameItem:AddChild(playerVoiceIcon)
    
                	        //MODIFY START
     
    // Player badge item.
    local playerBadge = GUIManager:CreateGraphicItem()
    playerBadge:SetSize(Vector(GUIScoreboard.kBadgeSize, GUIScoreboard.kBadgeSize, 0))
    playerBadge:SetAnchor(GUIItem.Left, GUIItem.Top)
    playerBadge:SetPosition(Vector(-GUIScoreboard.kBadgeSize - 5, 0, 0))
    playerBadge:SetIsVisible(false)
    playerNameItem:AddChild(playerBadge)
     
    local currentColumnX = Client.GetScreenWidth() / 7
    //local currentColumnX = Client.GetScreenWidth() / 6
    //MODIFY END
    
    // Status text item.
    local statusItem = GUIManager:CreateTextItem()
    statusItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    statusItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    statusItem:SetTextAlignmentX(GUIItem.Align_Min)
    statusItem:SetTextAlignmentY(GUIItem.Align_Min)
    statusItem:SetPosition(Vector(currentColumnX, 5, 0))
    statusItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(statusItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX * 2
    
    // Score text item.
    local scoreItem = GUIManager:CreateTextItem()
    scoreItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    scoreItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    scoreItem:SetTextAlignmentX(GUIItem.Align_Min)
    scoreItem:SetTextAlignmentY(GUIItem.Align_Min)
    scoreItem:SetPosition(Vector(currentColumnX, 5, 0))
    scoreItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(scoreItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Kill text item.
    local killsItem = GUIManager:CreateTextItem()
    killsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    killsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    killsItem:SetTextAlignmentX(GUIItem.Align_Min)
    killsItem:SetTextAlignmentY(GUIItem.Align_Min)
    killsItem:SetPosition(Vector(currentColumnX, 5, 0))
    killsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(killsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Deaths text item.
    local deathsItem = GUIManager:CreateTextItem()
    deathsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    deathsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    deathsItem:SetTextAlignmentX(GUIItem.Align_Min)
    deathsItem:SetTextAlignmentY(GUIItem.Align_Min)
    deathsItem:SetPosition(Vector(currentColumnX, 5, 0))
    deathsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(deathsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
	
							 //MODIFY START
    local assistsItem = GUIManager:CreateTextItem()
    assistsItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)    
    assistsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    assistsItem:SetTextAlignmentX(GUIItem.Align_Min)
    assistsItem:SetTextAlignmentY(GUIItem.Align_Min)
    assistsItem:SetPosition(Vector(currentColumnX, 5, 0))
    assistsItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(assistsItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    //MODIFY END
    
    // Resources text item.
    local resItem = GUIManager:CreateTextItem()
    resItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    resItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    resItem:SetTextAlignmentX(GUIItem.Align_Min)
    resItem:SetTextAlignmentY(GUIItem.Align_Min)
    resItem:SetPosition(Vector(currentColumnX, 5, 0))
    resItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(resItem)
    
    currentColumnX = currentColumnX + GUIScoreboard.kTeamColumnSpacingX
    
    // Ping text item.
    local pingItem = GUIManager:CreateTextItem()
    pingItem:SetFontName(GUIScoreboard.kPlayerStatsFontName)
    pingItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    pingItem:SetTextAlignmentX(GUIItem.Align_Min)
    pingItem:SetTextAlignmentY(GUIItem.Align_Min)
    pingItem:SetPosition(Vector(currentColumnX, 5, 0))
    pingItem:SetColor(Color(1, 1, 1, 1))
    playerItem:AddChild(pingItem)
    
               //MODIFY START
    //return { Background = playerItem, Index = playerIndexItem, Name = playerNameItem, Voice = playerVoiceIcon, Status = statusItem, Score = scoreItem, Kills = killsItem, Deaths = deathsItem, Resources = resItem, Ping = pingItem }
    return { Background = playerItem, Index = playerIndexItem, Name = playerNameItem, Badge = playerBadge, Voice = playerVoiceIcon, Status = statusItem, Score = scoreItem, Kills = killsItem, Assists = assistsItem, Deaths = deathsItem, Resources = resItem, Ping = pingItem }
    //MODIFY END
end

local function HandlePlayerVoiceClicked(self)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    for t = 1, #self.teams do
    
        local playerList = self.teams[t]["PlayerList"]
        for p = 1, #playerList do
        
            local playerItem = playerList[p]
            if GUIItemContainsPoint(playerItem["Voice"], mouseX, mouseY) then
            
                local clientIndex = playerItem["ClientIndex"]
                ChatUI_SetClientMuted(clientIndex, not ChatUI_GetClientMuted(clientIndex))
                
            end
            
        end
        
    end
    
end

function GUIScoreboard:SendKeyEvent(key, down)

    if ChatUI_EnteringChatMessage() then
        return false
    end
    
    if GetIsBinding(key, "Scoreboard") then
        self.visible = down
    end
    
    if not self.visible then
        return false
    end
    
    if key == InputKey.MouseButton0 and self.mousePressed["LMB"]["Down"] ~= down then
    
        self.mousePressed["LMB"]["Down"] = down
        if down then
        
            if not MouseTracker_GetIsVisible() then
                SetMouseVisible(self, true)
            else
                HandlePlayerVoiceClicked(self)
            end
            
        end
        
    end
    
end
