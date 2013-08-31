// ======= All rights maybe not reserved totally. ==========
//
// lua\RBPSplugins.lua
//
//    Created by:   Synomi and Zups and UWE
//
// ========= For more information, visit us at ns2stats.com or #ns2stats @ qnet =====================

Script.Load("cout/Cout.lua")

//LibC
Script.Load("plugins/lib/LibStub/LibStub.lua")
Script.Load("plugins/LibCompress.lua")


RBPSlibc = LibStub:GetLibrary("LibCompress")

if RBPSlibc then
    Shared.Message("Compress library loaded")
end