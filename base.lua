local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Universal/Aiming/Module.lua"))()
Aiming.TeamCheck(false)

-- // Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Vars
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera

local DaHoodSettings = {
    SilentAim = true,
    AimLock = true,
    Prediction = 0.165,
    AutoPrediction = false,
    AimLockKeybind = Enum.KeyCode.E
}
getgenv().DaHoodSettings = DaHoodSettings

-- // Auto Prediction

if DaHoodSettings.AutoPrediction == true then
    wait(4.2)
    local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    local split = string.split(pingvalue,'(')
    local ping = tonumber(split[1])
    local PingNumber = pingValue[1]
    if ping < 300 then
        DaHoodSettings.Prediction = 0.610
    elseif ping < 290 then
        DaHoodSettings.Prediction = 0.515
    elseif ping < 280 then
        DaHoodSettings.Prediction = 0.500
    elseif ping < 270 then
        DaHoodSettings.Prediction = 0.470
    elseif ping < 260 then
        DaHoodSettings.Prediction = 0.459
    elseif ping < 250 then
        DaHoodSettings.Prediction = 0.440
    elseif ping < 240 then
        DaHoodSettings.Prediction = 0.439
    elseif ping < 230 then
        DaHoodSettings.Prediction = 0.359
    elseif ping < 220 then
        DaHoodSettings.Prediction = 0.326
    elseif ping < 210 then
        DaHoodSettings.Prediction = 0.249
    elseif ping < 200 then
        DaHoodSettings.Prediction = 0.210
    elseif ping < 190 then
        DaHoodSettings.Prediction = 0.200
    elseif ping < 180 then
        DaHoodSettings.Prediction = 0.199
    elseif ping < 170 then
        DaHoodSettings.Prediction = 0.195
    elseif ping < 160 then
        DaHoodSettings.Prediction = 0.185
    elseif ping < 150 then
        DaHoodSettings.Prediction = 0.180
    elseif ping < 130 then
        DaHoodSettings.Prediction = 0.171
    elseif ping < 120 then
        DaHoodSettings.Prediction = 0.167
    elseif ping < 110 then
        DaHoodSettings.Prediction = 0.159
    elseif ping < 105 then
        DaHoodSettings.Prediction = 0.150
    elseif ping < 90 then
        DaHoodSettings.Prediction = 0.149
    elseif ping < 80 then
        DaHoodSettings.Prediction = 0.148
    elseif ping < 70 then
        DaHoodSettings.Prediction = 0.147
    elseif ping < 60 then
        DaHoodSettings.Prediction = 0.146
    elseif ping < 50 then
        DaHoodSettings.Prediction = 0.145
    elseif ping < 40 then
        DaHoodSettings.Prediction = 0.144
    end
end

-- // Overwrite to account downed
function Aiming.Check()
    -- // Check A
    if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
        return false
    end

    -- // Check if downed
    local Character = Aiming.Character(Aiming.Selected)
    local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value
    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    -- // Check B
    if (KOd or Grabbed) then
        return false
    end

    -- //
    return true
end

-- // Hook
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    -- // Check if it trying to get our mouse's hit or target and see if we can use it
    if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and Aiming.Check()) then
        -- // Vars
        local SelectedPart = Aiming.SelectedPart

        -- // Hit/Target
        if (DaHoodSettings.SilentAim and (k == "Hit" or k == "Target")) then
            -- // Hit to account prediction
            local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

            -- // Return modded val
            return (k == "Hit" and Hit or SelectedPart)
        end
    end

    -- // Return
    return __index(t, k)
end)

-- // Aimlock
RunService:BindToRenderStep("AimLock", 0, function()
    if (DaHoodSettings.AimLock and Aiming.Check() and UserInputService:IsKeyDown(DaHoodSettings.AimLockKeybind)) then
        -- // Vars
        local SelectedPart = Aiming.SelectedPart

        -- // Hit to account prediction
        local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

        -- // Set the camera to face towards the Hit
        CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, Hit.Position)
    end
end)