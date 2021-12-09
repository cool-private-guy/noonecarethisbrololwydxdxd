local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/cool-private-guy/noonecarethisbrololwydxdxd/main/uilib.lua"))()
local window = library:CreateWindow("privateware-rewrite", Vector2.new(492, 598), Enum.KeyCode.V)

local B_1_ = window:CreateTab("Aim Stuff")
local B_2_ = window:CreateTab("Misc")
local B_3_ = window:CreateTab("Visual")
local B_4_ = window:CreateTab("Teleports")

local L_1_ = B_1_:CreateSector("Aimbot", "left")
local L_2_ = B_1_:CreateSector("Aimbot; Settings", "right")
local L_3_ = B_1_:CreateSector("Silent Aim", "left")
local L_4_ = B_1_:CreateSector("Silent Aim; Settings", "right")
local L_5_ = B_1_:CreateSector("Esp", "left")
local L_6_ = B_1_:CreateSector("Settings", "right")

L_1_:AddToggle