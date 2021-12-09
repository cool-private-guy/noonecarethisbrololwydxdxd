-- // Aimlock

getgenv().OldAimPart = "HumanoidRootPart"
getgenv().AimPart = "HumanoidRootPart" 
getgenv().AimlockKey = "q"
getgenv().AimRadius = 30 
getgenv().ThirdPerson = true 
getgenv().FirstPerson = true
getgenv().TeamCheck = false 
getgenv().PredictMovement = true 
getgenv().PredictionVelocity = 7
getgenv().CheckIfJumped = false
getgenv().AutoPrediction = false



local Players, Uis, RService, SGui = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"StarterGui";
local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new;
local Aimlock, MousePressed, CanNotify = false, false, false;
local AimlockTarget;
local OldPre;

getgenv().WorldToViewportPoint = function(P)
	return Camera:WorldToViewportPoint(P)
end

getgenv().WorldToScreenPoint = function(P)
	return Camera.WorldToScreenPoint(Camera, P)
end

getgenv().GetObscuringObjects = function(T)
	if T and T:FindFirstChild(getgenv().AimPart) and Client and Client.Character:FindFirstChild("Head") then 
		local RayPos = workspace:FindPartOnRay(RNew(
			T[getgenv().AimPart].Position, Client.Character.Head.Position)
		)
		if RayPos then return RayPos:IsDescendantOf(T) end
	end
end

getgenv().GetNearestTarget = function()
	-- Credits to whoever made this, i didnt make it, and my own mouse2plr function kinda sucks
	local players = {}
	local PLAYER_HOLD  = {}
	local DISTANCES = {}
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Client then
			table.insert(players, v)
		end
	end
	for i, v in pairs(players) do
		if v.Character ~= nil then
			local AIM = v.Character:FindFirstChild("Head")
			if getgenv().TeamCheck == true and v.Team ~= Client.Team then
				local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
				local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
				local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
				local DIFF = math.floor((POS - AIM.Position).magnitude)
				PLAYER_HOLD[v.Name .. i] = {}
				PLAYER_HOLD[v.Name .. i].dist= DISTANCE
				PLAYER_HOLD[v.Name .. i].plr = v
				PLAYER_HOLD[v.Name .. i].diff = DIFF
				table.insert(DISTANCES, DIFF)
			elseif getgenv().TeamCheck == false and v.Team == Client.Team then 
				local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
				local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
				local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
				local DIFF = math.floor((POS - AIM.Position).magnitude)
				PLAYER_HOLD[v.Name .. i] = {}
				PLAYER_HOLD[v.Name .. i].dist= DISTANCE
				PLAYER_HOLD[v.Name .. i].plr = v
				PLAYER_HOLD[v.Name .. i].diff = DIFF
				table.insert(DISTANCES, DIFF)
			end
		end
	end

	if unpack(DISTANCES) == nil then
		return nil
	end

	local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
	if L_DISTANCE > getgenv().AimRadius then
		return nil
	end

	for i, v in pairs(PLAYER_HOLD) do
		if v.diff == L_DISTANCE then
			return v.plr
		end
	end
	return nil
end

Mouse.KeyDown:Connect(function(a)
	if not (Uis:GetFocusedTextBox()) then 
		if a == AimlockKey and AimlockTarget == nil then
			pcall(function()
				if MousePressed ~= true then MousePressed = true end 
				local Target;Target = GetNearestTarget()
				if Target ~= nil then 
					AimlockTarget = Target
				end
			end)
		elseif a == AimlockKey and AimlockTarget ~= nil then
			if AimlockTarget ~= nil then AimlockTarget = nil end
			if MousePressed ~= false then 
				MousePressed = false 
			end
		end
	end
end)

RService.RenderStepped:Connect(function()
	if getgenv().ThirdPerson == true and getgenv().FirstPerson == true then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	elseif getgenv().ThirdPerson == true and getgenv().FirstPerson == false then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	elseif getgenv().ThirdPerson == false and getgenv().FirstPerson == true then 
		if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
			CanNotify = true 
		else 
			CanNotify = false 
		end
	end
	if Aimlock == true and MousePressed == true then 
		if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then 
			if getgenv().FirstPerson == true then
				if CanNotify == true then
					if getgenv().PredictMovement == true then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
					elseif getgenv().PredictMovement == false then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
					end
				end
			elseif getgenv().ThirdPerson == true then 
				if CanNotify == true then
					if getgenv().PredictMovement == true then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
					elseif getgenv().PredictMovement == false then 
						Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
					end
				end 
			end
		end
	end
	if getgenv().CheckIfJumped == true then
		if AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then

			getgenv().AimPart = "RightFoot"
		else
			getgenv().AimPart = getgenv().OldAimPart
		end
	end
	if getgenv().AutoPrediction == true then
		wait(5.2)
		local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
		local split = string.split(pingvalue,'(')
		local ping = tonumber(split[1])
		local PingNumber = pingValue[1]

		if  ping < 250 then
			getgenv().PredictionVelocity = 4.677
		elseif ping < 240 then
			getgenv().PredictionVelocity = 4.788
		elseif ping < 230 then
			getgenv().PredictionVelocity = 4.788
		elseif ping < 220 then
			getgenv().PredictionVelocity = 4.788
		elseif ping < 210 then
			getgenv().PredictionVelocity = 4.788
		elseif ping < 200 then
			getgenv().PredictionVelocity = 5.188
		elseif ping < 150 then
			getgenv().PredictionVelocity = 5.56
		elseif ping < 140 then
			getgenv().PredictionVelocity = 5.75
		elseif ping < 130 then
			getgenv().PredictionVelocity = 6.28
		elseif ping < 120 then
			getgenv().PredictionVelocity = 6.43
		elseif ping < 110 then
			getgenv().PredictionVelocity = 6.59
		elseif ping < 105 then
			getgenv().PredictionVelocity = 6.7
		elseif ping < 90 then
			getgenv().PredictionVelocity = 7
		elseif ping < 80 then
			getgenv().PredictionVelocity = 7
		elseif ping < 70 then
			getgenv().PredictionVelocity = 8
		elseif ping < 60 then
			getgenv().PredictionVelocity = 8
		elseif ping < 50 then
			getgenv().PredictionVelocity = 8.125
		elseif ping < 40 then
			getgenv().PredictionVelocity = 8.543
		end
	end
end)

-- // Silent Aim

loadstring(game:HttpGet("https://raw.githubusercontent.com/cool-private-guy/noonecarethisbrololwydxdxd/main/base.lua", true))()

-- // UI

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

L_1_:AddToggle("Enabled", function(bro1)
	Aimlock = bro1
end)