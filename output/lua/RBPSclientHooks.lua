// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSclientHooks.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================    

local RBPSlastClientUpdateSec = 0

local function RBPSClientUpdate()
           
    if Shared.GetTime() - RBPSlastClientUpdateSec > 1 then
        RBPSlastClientUpdateSec = Shared.GetTime()
                                     
       // RBPS:pr(Client.minimapExtentScale)                       
   //     RBPS:pr(Client.minimapExtentOrigin)                       
                  
        
        if RBPSshowingAwards then        
            RBPS:clientShowNextAward(RBPSnextAwardId)
                        
            if RBPSnextAwardId == #RBPSclientAwards then
                RBPSshowingAwards = false
                RBPSclientAwards = {}                
            end
            
            RBPSnextAwardId = RBPSnextAwardId +1            
        
        end        
        //Shared.Message("One second timer?" .. Shared.GetTime())
    end
    /*
    if Shared.GetTime() - lastClientUpdate100ms > 0.1 then
        lastClientUpdate100ms = Shared.GetTime()
        //Cout:rotateTest()
        //Shared.Message("100mstimer?" .. Shared.GetTime())
    end
    
    if Shared.GetTime() - lastClientUpdate10ms > 0.01 then
        lastClientUpdate10ms = Shared.GetTime()
        Cout:rotateTest()
        //Shared.Message("100mstimer?" .. Shared.GetTime())
    end
    */
end

Event.Hook("UpdateClient", RBPSClientUpdate)

local WebWindow = nil

function openNS2Stats(siteurl, scaleX, scaleY)
    //copy pasted from Shine Admin mod (ty)
    
  local Manager = GetGUIManager()

	if WebWindow then
		Manager:DestroyGUIScript( WebWindow )
	end
	
	if not CommanderUI_IsLocalPlayerCommander() then
		MouseTracker_SetIsVisible( true, "ui/Cursor_MenuDefault.dds", true )
	end

	WebWindow = Manager:CreateGUIScript( "GUIWebView" )
	local OldSendKeyEvent = WebWindow.SendKeyEvent
	local OldUnInit = WebWindow.Uninitialize

	--Just in case, we'll override this too.
	function WebWindow:Uninitialize()
		if not CommanderUI_IsLocalPlayerCommander() then
			MouseTracker_SetIsVisible( false, "ui/Cursor_MenuDefault.dds", true )
		end

		return OldUnInit( self )
	end

	--Need to override this so the mouse is removed on close.
	function WebWindow:SendKeyEvent(key, down)
		if not self.background then
			return false
		end
		
		local isReleventKey = false
		
		if type(self.buttonDown[key]) == "boolean" then
			isReleventKey = true
		end
		
		local mouseX, mouseY = Client.GetCursorPosScreen()
		if isReleventKey then
		
			local containsPoint, withinX, withinY = GUIItemContainsPoint(self.background, mouseX, mouseY)
			if down and not containsPoint then
				if not CommanderUI_IsLocalPlayerCommander() then
					MouseTracker_SetIsVisible( false, "ui/Cursor_MenuDefault.dds", true )
				end
				
				self:Uninitialize()
				
				return true    
			end
			
			containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
			
			if containsPoint or (not down and self.buttonDown[key]) then
			
				local buttonCode = key - InputKey.MouseButton0
				if down then
					self.webView:OnMouseDown(buttonCode)
				else
					self.webView:OnMouseUp(buttonCode)
				end
				
				self.buttonDown[key] = down
				
				return true
				
			elseif (key == InputKey.MouseButton0 and down and GUIItemContainsPoint(self.close, mouseX, mouseY)) then
				if not CommanderUI_IsLocalPlayerCommander() then
					MouseTracker_SetIsVisible( false, "ui/Cursor_MenuDefault.dds", true )
				end
				
				self:Uninitialize()
				
				return true
			end
			
		elseif key == InputKey.MouseZ then
			self.webView:OnMouseWheel(down and 30 or -30, 0)
		elseif key == InputKey.Escape then
			if not CommanderUI_IsLocalPlayerCommander() then
				MouseTracker_SetIsVisible( false, "ui/Cursor_MenuDefault.dds", true )
			end
			
			self:Uninitialize()
			
			return true
		end
		
		return false
		
	end

    Shared.Message("Opening: " .. siteurl)    
    if scaleX and scaleY then
    
        WebWindow:LoadUrl( siteurl, Client.GetScreenWidth() * scaleX, Client.GetScreenHeight() * scaleY )
    else
        WebWindow:LoadUrl( siteurl, Client.GetScreenWidth() * 0.95, Client.GetScreenHeight() * 0.9 )
    end	
    
	local Background = WebWindow:GetBackground()

	Background:SetAnchor( GUIItem.Middle, GUIItem.Center )
	Background:SetPosition( -Background:GetSize() / 2 )
	Background:SetLayer( kGUILayerMainMenuWeb )
	Background:SetIsVisible( true )

    
end     

            
function RBPSopenLastRound(scaleX,scaleY)

    if RBPSclientConfig.browser and RBPSclientConfig.browser == "steam" then
        Client.ShowWebpage(RBPSlastRound)
    else
        openNS2Stats(RBPSlastRound, scaleX,scaleY)
    end
    
end

Event.Hook("Console_check",RBPSopenLastRound)

local kModStateNames =
    {
        getting_info    = "GETTING INFO",
        downloading     = "DOWNLOADING",
        unavailable     = "UNAVAILABLE",
        available       = "AVAILABLE",
    }
    
function RBPSmodtest()
Shared.Message("Server is using mods:")
 for s = 1, Client.GetNumMods() do

        local state = Client.GetModState(s)
        local stateString = kModStateNames[state]
        if stateString == nil then
            stateString = "??"
        end 
        local name = Client.GetModTitle(s)        
        local active = Client.GetIsModActive(s) and "YES" or "NO"
        local subscribed = Client.GetIsSubscribedToMod(s) and "YES" or "NO"
        local percent = "100%"
        if active=="NO" and subscribed == "NO" then
            Shared.Message(name)
        end
        
    end


end
//test
Event.Hook("Console_showservermods",RBPSmodtest)
  
