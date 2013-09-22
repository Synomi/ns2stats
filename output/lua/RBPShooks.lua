// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPShooks.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

Event.Hook("ClientConnect",RBPSclientConnect)
Event.Hook("ClientDisconnect",RBPSclientDisconnect)

//commands
Event.Hook("Console_players",RBPSlistPlayers)
Event.Hook("Console_stats",RBPSstats)

//tournamentmode
Event.Hook("Console_ready",RBPSready)
Event.Hook("Console_notready",RBPSnotready)
Event.Hook("Console_not",RBPSnot)
Event.Hook("Console_cancel",RBPScancel)
Event.Hook("Console_tag",RBPStag)

//votes
Event.Hook("Console_votemap",RBPSvotemap)

//extendedscoreboard
Event.Hook("Console_es",RBPSextendedScoreboard)
Event.Hook("Console_extendedscoreboard",RBPSextendedScoreboard)

//debug hooks
Event.Hook("Console_listplayers",RBPSlistplayers)
Event.Hook("Console_clientcommand",RBPSclientCommand)
Event.Hook("Console_rbpslog",RBPSshowLog)
Event.Hook("Console_voterequirements",voteRequirements)


//test hookds
