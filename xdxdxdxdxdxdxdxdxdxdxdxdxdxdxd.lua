getgenv().OldAimPart = "UpperTorso"
getgenv().AimPart = "UpperTorso" 
getgenv().AimlockKey = "q"
getgenv().AimRadius = 30 
getgenv().ThirdPerson = true 
getgenv().FirstPerson = true
getgenv().TeamCheck = false 
getgenv().PredictMovement = true 
getgenv().PredictionVelocity = 6.3
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
end)


if getgenv().AutoPrediction == true then
    wait(5.2)
        local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local split = string.split(pingvalue,'(')
        local ping = tonumber(split[1])
            local PingNumber = pingvalue[1]

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

IsFirstPerson = false
	WHeld = false
	SHeld = false
	AHeld = false
	DHeld = false
	local L_167_ = true
    local activar = false
	urspeed = 0.1
	function ChangeFaster(L_168_arg0, L_169_arg1)
		if L_168_arg0.KeyCode == Enum.KeyCode.Down and L_169_arg1 == false then
			urspeed = urspeed - 0.01
		end
	end
	function ChangeSlower(L_170_arg0, L_171_arg1)
		if L_170_arg0.KeyCode == Enum.KeyCode.Up and L_171_arg1 == false then
			urspeed = urspeed + 0.01
		end
	end
	function GChecker(L_172_arg0, L_173_arg1)
		if L_172_arg0.KeyCode == Enum.KeyCode.N and L_173_arg1 == false then
			if L_167_ == false then
				L_167_ = true
			elseif L_167_ == true then
				L_167_ = false
			end
		end
	end
	function PressW(L_178_arg0, L_179_arg1)
		if L_178_arg0.KeyCode == Enum.KeyCode.W and L_179_arg1 == false and L_167_ == true then
			WHeld = true
		end
	end
	function ReleaseW(L_180_arg0, L_181_arg1)
		if L_180_arg0.KeyCode == Enum.KeyCode.W then
			WHeld = false
		end
	end
	function PressS(L_182_arg0, L_183_arg1)
		if L_182_arg0.KeyCode == Enum.KeyCode.S and L_183_arg1 == false and L_167_ == true then
			SHeld = true
		end
	end
	function ReleaseS(L_184_arg0, L_185_arg1)
		if L_184_arg0.KeyCode == Enum.KeyCode.S then
			SHeld = false
		end
	end
	function PressA(L_186_arg0, L_187_arg1)
		if L_186_arg0.KeyCode == Enum.KeyCode.A and L_187_arg1 == false and L_167_ == true then
			AHeld = true
		end
	end
	function ReleaseA(L_188_arg0, L_189_arg1)
		if L_188_arg0.KeyCode == Enum.KeyCode.A then
			AHeld = false
		end
	end
	function PressD(L_190_arg0, L_191_arg1)
		if L_190_arg0.KeyCode == Enum.KeyCode.D and L_191_arg1 == false and L_167_ == true then
			DHeld = true
		end
	end
	function ReleaseD(L_192_arg0, L_193_arg1)
		if L_192_arg0.KeyCode == Enum.KeyCode.D then
			DHeld = false
		end
	end
	function CheckFirst(L_194_arg0, L_195_arg1)
		if L_194_arg0.KeyCode == Enum.UserInputType.MouseWheel then
			if (player.Character.Head.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude < 0.6 then
				IsFirstPerson = true
			elseif (player.Character.Head.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 0.6 then
				IsFirstPerson = false
			end
		end
	end
	game:GetService("UserInputService").InputBegan:connect(PressW)
	game:GetService("UserInputService").InputEnded:connect(ReleaseW)
	game:GetService("UserInputService").InputBegan:connect(PressS)
	game:GetService("UserInputService").InputEnded:connect(ReleaseS)
	game:GetService("UserInputService").InputBegan:connect(PressA)
	game:GetService("UserInputService").InputEnded:connect(ReleaseA)
	game:GetService("UserInputService").InputBegan:connect(PressD)
	game:GetService("UserInputService").InputEnded:connect(ReleaseD)
	game:GetService("UserInputService").InputChanged:connect(CheckFirst)
	game:GetService("UserInputService").InputBegan:connect(ChangeFaster)
	game:GetService("UserInputService").InputBegan:connect(ChangeSlower)
	game:GetService("RunService").Stepped:connect(
            function()
		if activar == true then
			if WHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -urspeed)
			end
			if SHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, urspeed)
			end
			if DHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(urspeed, 0, 0)
			end
			if AHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-urspeed, 0, 0)
			end
		end
end)

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/wydkidwydkid4345/noonecarethisbrololwydxdxd/main/espmodule.lua", true))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/wydkidwydkid4345/noonecarethisbrololwydxdxd/main/base.lua", true))()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wydkidwydkid4345/noonecarethisbrololwydxdxd/main/uilib.lua"))()
local window = library:CreateWindow("doggyware-rewrite", Vector2.new(492, 598), Enum.KeyCode.V)

local B_1_ = window:CreateTab("Aim Stuff")
local B_2_ = window:CreateTab("Misc")
local B_3_ = window:CreateTab("Ingame")
local B_4_ = window:CreateTab("Teleports")

local section1 = B_1_:CreateSector("Aimbot", "left")
local section2 = B_1_:CreateSector("Aimbot; Settings", "right")
local section3 = B_1_:CreateSector("Silent Aim", "left")
local section4 = B_1_:CreateSector("Silent Aim; Settings", "right")
local section5 = B_1_:CreateSector("Anti-Aim (Beta)", "left")
local section6 = B_1_:CreateSector("Settings", "right")
local section7 = B_2_:CreateSector("Animations", "left")
local section8 = B_2_:CreateSector("CFrame Speed", "right")
local section9 = B_2_:CreateSector("Force Resets", "left")
local section10 = B_2_:CreateSector("Cheats", "right")
local section11 = B_3_:CreateSector("ESP", "left")
local section12 = B_3_:CreateSector("Sided Things", "right")
local section13 = B_3_:CreateSector("Ingame Things", "left")
local section14 = B_4_:CreateSector("Tps 1", "left")
local section15 = B_4_:CreateSector("Tps 2", "right")
local section16 = B_4_:CreateSector("Tps 3", "left")
local section17 = B_4_:CreateSector("Tps 4", "right")
local section18 = B_4_:CreateSector("Tps 5", "left")
local section19 = B_4_:CreateSector("Tps 6", "right")
local section20 = B_4_:CreateSector("Tps 7", "left")
local section21 = B_4_:CreateSector("Tps 8", "right")
local section22 = B_4_:CreateSector("Tps 9", "left")

section1:AddToggle("Enabled", false, function(alr1)
    Aimlock = alr1
end):AddKeybind("None")

section1:AddToggle("Ping Based Prediction", false, function(alr2)
    getgenv().AutoPrediction = alr2
end)

section1:AddToggle("Airshot Function", false, function(alr3)
    getgenv().CheckIfJumped = alr3
end)

section1:AddToggle("Team Check", false, function(alr4)
    getgenv().TeamCheck = alr4
end)

section1:AddDropdown("Hitbox", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}, default, false, function(alr5)
    getgenv().AimPart = alr5
end)

section1:AddTextbox("Bullet Prediction", "", function(lockpredictionlolxdd)
    getgenv().PredictionVelocity = lockpredictionlolxdd
end)

section2:AddTextbox("Aimlock Key", "q", function(bindasd)
    getgenv().AimlockKey = bindasd
  end)

section2:AddSlider("Aim Radius", 1, 30, 100, decimals, function(alr21)
    getgenv().AimRadius = alr21
end)

section3:AddToggle("Enabled", false, function(alr10)
    DaHoodSettings.SilentAim = alr10
    Aiming.Enabled = alr10
end):AddKeybind("None")

section3:AddToggle("Visible Check", false, function(alr12)
    Aiming.VisibleCheck = alr12
end)

section3:AddToggle("K0d Check", false, function(alr13)
    Aiming.Check().K0d = alr13
end)

section3:AddToggle("Grabbed Check", false, function(alr14)
    Aiming.Check().Grabbed = alr14
end)

section3:AddDropdown("Hitbox", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}, default, false, function(silenthitbox)
    Aiming.TargetPart = silenthitbox
end)

section3:AddTextbox("Bullet Prediction", "", function(silentpredictionlolxdd)
    DaHoodSettings.Prediction = silentpredictionlolxdd
end)

section4:AddToggle("Show Fov", false, function(alr15)
    Aiming.ShowFOV = alr15
end):AddKeybind("None")

section4:AddToggle("Filled", false, function(alr16)
    Aiming.Filled = alr16
end)

section4:AddDropdown("Shape", {"Custom", "Circle", "Square"}, "Custom", false, function(v)
    if v == "Custom" then
        Aiming.FOV = 30
        Aiming.FOVSides = 100
        Aiming.Transparency = 0.5
    elseif v == "Circle" then
        Aiming.FOV = 30
        Aiming.FOVSides = 100
        Aiming.Transparency = 0.5
    elseif v == "Square" then
        Aiming.FOV = 30
        Aiming.FOVSides = 14
        Aiming.Transparency = 0.5
    end
end)

section4:AddSlider("Size", 1, 30, 300, decimals, function(bro14)
    Aiming.FOV = bro14
end)

section4:AddSlider("Round", 1, 40, 40, decimals, function(bro15)
    Aiming.FOVSides = bro15
end)

section4:AddSlider("Transparency", 0, 0.5, 1, 10, function(bro16)
    Aiming.Transparency = bro16
end)

section5:AddButton("FIX ANTILOCK", function()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
			v:Destroy()
		end
	end
	game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		repeat
			wait()
		until game.Players.LocalPlayer.Character
		char.ChildAdded:Connect(function(child)
			if child:IsA("Script") then 
				wait(0.1)
				if child:FindFirstChild("LocalScript") then
					child.LocalScript:FireServer()
				end
			end
		end)
	end)
end)

local glitch = false
local clicker = false

section5:AddTextbox("Antilock Value", "", function(alr8)
    getgenv().Multiplier = alr8
end, {
    ["clear"] = false,
})

section5:AddButton("Antilock Improved (Z)", function()
    local userInput = game:service('UserInputService')
	local runService = game:service('RunService')

	userInput.InputBegan:connect(function(Key)
		if Key.KeyCode == Enum.KeyCode.Z then
			Enabled = not Enabled
			if Enabled == true then
				repeat
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * getgenv().Multiplier
					runService.Stepped:wait()
				until Enabled == false
			end
		end
	end)
end)

local whitelist = section6:AddTextbox("Player Username", "", function()
end)

section6:AddButton("Add Whitelist", function()
    Aiming.IgnorePlayer(whitelist)
end)

section6:AddButton("Remove Whitelist", function()
    Aiming.UnIgnorePlayer(whitelist)
end)

section7:AddButton("Zombie and Werewolf-Mage", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
end)

section7:AddButton("Zombie and Rthro-OldSchool", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=2510197830"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=5319839762"
end)

section7:AddButton("Zombie and Ninja", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
end)

section7:AddButton("Zombie and Knight", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
end)

section7:AddButton("Ninja and Rthro", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
end)

section7:AddButton("Zombie and Ninja-Mage", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
end)

section7:AddButton("Keo's Animation", function()
	local Animate = game.Players.LocalPlayer.Character.Animate
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=2510196951"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=2510197257"
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
	Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
end)


section8:AddToggle("CFrame Speed", false, function(cframe)
    activar = cframe
end):AddKeybind("None")

section8:AddButton("Fix CFrame", function(cframe)
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
            v:Destroy()
        end
    end
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        repeat
            wait()
        until game.Players.LocalPlayer.Character
        char.ChildAdded:Connect(function(child)
            if child:IsA("Script") then 
                wait(0.1)
                if child:FindFirstChild("LocalScript") then
                    child.LocalScript:FireServer()
                end
            end
        end)
    end)

end)

local glitch = false
local clicker = false

section8:AddSlider("Speed", -10, 0, 10, 5, function(ass)
    urspeed = ass
end)

section9:AddButton("Nil Body", function()
    for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v:Destroy()
        end
    end
end)

section9:AddButton("Nil Char", function()
    game.Players.LocalPlayer.Character.Head:Destroy()
    game.Players.LocalPlayer.Character.UpperTorso:Destroy()
    game.Players.LocalPlayer.Character.LowerTorso:Destroy()
    game.Players.LocalPlayer.Character.LeftFoot:Destroy()
    game.Players.LocalPlayer.Character.LeftLowerLeg:Destroy()
    game.Players.LocalPlayer.Character.LeftUpperLeg:Destroy()
    game.Players.LocalPlayer.Character.RightFoot:Destroy()
    game.Players.LocalPlayer.Character.RightLowerLeg:Destroy()
    game.Players.LocalPlayer.Character.RightUpperLeg:Destroy()
    game.Players.LocalPlayer.Character.LeftHand:Destroy()
    game.Players.LocalPlayer.Character.LeftLowerArm:Destroy()
    game.Players.LocalPlayer.Character.LeftUpperArm:Destroy()
    game.Players.LocalPlayer.Character.RightHand:Destroy()
    game.Players.LocalPlayer.Character.RightLowerArm:Destroy()
    game.Players.LocalPlayer.Character.RightUpperArm:Destroy()
    game.Players.LocalPlayer.Character.HumanoidRootPart:Destroy()  
end)

FLYMODE = 'IY'
FLYSPEED = 30
section10:AddButton("Fly (X)", function()
	if FLYMODE == 'IY' then
		repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Head") and game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		local mouse = game.Players.LocalPlayer:GetMouse()
		repeat wait() until mouse
		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Head
		local flying = false
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 5000
		local speed = 5000
		function Fly()
			local bg = Instance.new("BodyGyro", torso)
			bg.P = 9e4
			bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
			bg.cframe = torso.CFrame
			local bv = Instance.new("BodyVelocity", torso)
			bv.velocity = Vector3.new(0,0.1,0)
			bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
			repeat wait()
				plr.Character:FindFirstChildWhichIsA('Humanoid').PlatformStand = true
				if ctrl.l + ctrl.r ~= 100000 or ctrl.f + ctrl.b ~= 10000 then
					speed = speed+.0+(speed/maxspeed)
					if speed > maxspeed then
						speed = maxspeed
					end
				elseif not (ctrl.l + ctrl.r ~= 5 or ctrl.f + ctrl.b ~= 5) and speed ~= 5 then
					speed = speed-5
					if speed > 5 then
						speed = -2
					end
				end
				if (ctrl.l + ctrl.r) ~= 5 or (ctrl.f + ctrl.b) ~= 5 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
					lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
				elseif (ctrl.l + ctrl.r) == 5 and (ctrl.f + ctrl.b) == 5 and speed ~= 5 then
					bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				else
					bv.velocity = Vector3.new(0,0.1,0)
				end
				bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
			until not flying
			ctrl = {f = 0, b = 0, l = 0, r = 0}
			lastctrl = {f = 0, b = 0, l = 0, r = 0}
			speed = 5
			bg:Destroy()
			bv:Destroy()
			plr.Character:FindFirstChildWhichIsA('Humanoid').PlatformStand = false
		end
		mouse.KeyDown:connect(function(key)
			if key:lower() == "x" then
				if flying then flying = false
				else
					flying = true
					Fly()
				end
			elseif key:lower() == "w" then
				ctrl.f = FLYSPEED
			elseif key:lower() == "s" then
				ctrl.b = -FLYSPEED
			elseif key:lower() == "a" then
				ctrl.l = -FLYSPEED
			elseif key:lower() == "d" then
				ctrl.r = FLYSPEED
			end
		end)
		mouse.KeyUp:connect(function(key)
			if key:lower() == "w" then
				ctrl.f = 0
			elseif key:lower() == "s" then
				ctrl.b = 0
			elseif key:lower() == "a" then
				ctrl.l = 0
			elseif key:lower() == "d" then
				ctrl.r = 0
			end
		end)
		Fly()
	else
		local plr = game.Players.LocalPlayer
		local Humanoid = plr.Character:FindFirstChildWhichIsA('Humanoid')
		local mouse = plr:GetMouse()
		localplayer = plr
		if workspace:FindFirstChild("Core") then
			workspace.Core:Destroy()
		end
		local Core = Instance.new("Part")
		Core.Name = "Core"
		Core.Size = Vector3.new(0.05, 0.05, 0.05)
		spawn(function()
			Core.Parent = workspace
			local Weld = Instance.new("Weld", Core)
			Weld.Part0 = Core
			Weld.Part1 = localplayer.Character.LowerTorso
			Weld.C0 = CFrame.new(0, 0, 0)
		end)
		workspace:WaitForChild("Core")
		local torso = workspace.Core
		flying = true
		local speed=FLYSPEED
		local keys={a=false,d=false,w=false,s=false}
		local e1
		local e2
		local function start()
			local pos = Instance.new("BodyPosition",torso)
			local gyro = Instance.new("BodyGyro",torso)
			pos.Name="EPIXPOS"
			pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
			pos.position = torso.Position
			gyro.maxTorque = Vector3.new(15e15, 15e15, 15e15)
			gyro.cframe = torso.CFrame
			repeat
				wait()
				Humanoid.PlatformStand=true
				local new=gyro.cframe - gyro.cframe.p + pos.position
				if not keys.w and not keys.s and not keys.a and not keys.d then
					speed=FLYSPEED
				end
				if keys.w then
					new = new + workspace.CurrentCamera.CoordinateFrame.lookVector * speed
					speed=speed
				end
				if keys.s then
					new = new - workspace.CurrentCamera.CoordinateFrame.lookVector * speed
					speed=speed
				end
				if keys.d then
					new = new * CFrame.new(speed,0,0)
					speed=speed
				end
				if keys.a then
					new = new * CFrame.new(-speed,0,0)
					speed=speed
				end
				if speed>FLYSPEED then
					speed=FLYSPEED
				end
				pos.position=new.p
				if keys.w then
					gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad(speed),0,0)
				elseif keys.s then
					gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(math.rad(speed),0,0)
				else
					gyro.cframe = workspace.CurrentCamera.CoordinateFrame
				end
			until flying == false
			if gyro then gyro:Destroy() end
			if pos then pos:Destroy() end
			flying=false
			Humanoid.PlatformStand=false
			speed=FLYSPEED
		end
		e1=mouse.KeyDown:connect(function(key)
			if not torso or not torso.Parent then flying=false e1:disconnect() e2:disconnect() return end
			if key=="w" then
				keys.w=true
			elseif key=="s" then
				keys.s=true
			elseif key=="a" then
				keys.a=true
			elseif key=="d" then
				keys.d=true
			elseif key=="x" then
				if flying==true then
					flying=false
				else
					flying=true
					start()
				end
			end
		end)
		e2=mouse.KeyUp:connect(function(key)
			if key=="w" then
				keys.w=false
			elseif key=="s" then
				keys.s=false
			elseif key=="a" then
				keys.a=false
			elseif key=="d" then
				keys.d=false
			end
		end)
		start()
	end
end)
section10:AddButton("Fly Type", function()
	if FLYMODE == 'IY' then
		FLYMODE = 'Default'
		game.StarterGui:SetCore("SendNotification", {
			Title = "Private-Ware",
			Text = 'Fly ( Default Mode ) / Reset To Change.',
			Duration = 2,
		})
	else
		FLYMODE = 'IY'
		game.StarterGui:SetCore("SendNotification", {
			Title = "Private-Ware",
			Text = 'Fly ( IY Mode ) / Reset To Change.',
			Duration = 2,
		})
	end
end)

section10:AddButton("Fly Speed [+]", function()
	FLYSPEED = FLYSPEED + 1
	game.StarterGui:SetCore("SendNotification", {
		Title = "Private-Ware",
		Text = " [+] Your Fly Speed Is Now, " ..(tostring(FLYSPEED))..".",
		Duration = 1,
	})
end)

section10:AddButton("Fly Speed [-]", function()
	FLYSPEED = FLYSPEED - 1
	game.StarterGui:SetCore("SendNotification", {
		Title = "Private-Ware",
		Text = " [-] Your Fly Speed Is Now, " ..(tostring(FLYSPEED))..".",
		Duration = 1,
	})
end)

section10:AddLabel(" ")

section10:AddButton("AntiFling (K)", function()
	getgenv().Key = "K"
	local L_148_ = game.Players.LocalPlayer
	local L_149_ = L_148_:GetMouse()
	local L_150_ = false
	function Nigger(L_151_arg0)
		L_151_arg0 = L_151_arg0:upper() or L_151_arg0:lower()
		if L_151_arg0 == Key then
			L_150_ = not L_150_
			game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = L_150_
		end
	end
	L_149_.KeyDown:Connect(Nigger)
end)

section10:AddButton("Macro in Lua (B)", function()
	local Player = game:GetService("Players").LocalPlayer
	local Mouse = Player:GetMouse()
	local SpeedGlitch = false
	local Wallet = Player.Backpack:FindFirstChild("Wallet")

	local UniversalAnimation = Instance.new("Animation")

	function stopTracks()
		for _, v in next, game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks() do
			if (v.Animation.AnimationId:match("rbxassetid")) then
				v:Stop()
			end
		end
	end

	function loadAnimation(id)
		if UniversalAnimation.AnimationId == id then
			stopTracks()
			UniversalAnimation.AnimationId = "1"
		else
			UniversalAnimation.AnimationId = id
			local animationTrack = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(UniversalAnimation)
			animationTrack:Play()
		end
	end

	Mouse.KeyDown:Connect(function(Key)
		if Key == "b" then
			SpeedGlitch = not SpeedGlitch
			if SpeedGlitch == true then
				stopTracks()
				loadAnimation("rbxassetid://3189777795")
				wait(1.5)
				Wallet.Parent = Player.Character
				wait(0.15)
				Player.Character:FindFirstChild("Wallet").Parent = Player.Backpack
				wait(0.05)
				repeat game:GetService("RunService").Heartbeat:wait()
					keypress(0x49)
					game:GetService("RunService").Heartbeat:wait()
					keypress(0x4F)
					game:GetService("RunService").Heartbeat:wait()
					keyrelease(0x49)
					game:GetService("RunService").Heartbeat:wait()
					keyrelease(0x4F)
					game:GetService("RunService").Heartbeat:wait()
				until SpeedGlitch == false
			end
		end
	end)
end)

section10:AddButton("Speed (C)", function()
	plr = game:GetService('Players').LocalPlayer
	down = true

	function onButton1Down(mouse)
		down = true
		while down do
			if not down then break end
			local char = plr.Character
			char.HumanoidRootPart.Velocity = char.HumanoidRootPart.CFrame.lookVector * 190
			wait()
		end
	end

	function onButton1Up(mouse)
		down = false
	end

	function onSelected(mouse)
		mouse.KeyDown:connect(function(c) if c:lower()=="c"then onButton1Down(mouse)end end)
		mouse.KeyUp:connect(function(c) if c:lower()=="c"then onButton1Up(mouse)end end)
	end
	onSelected(game.Players.LocalPlayer:GetMouse())
end)

section10:AddButton("Chatlogs", function()
	enabled = true
	spyOnMyself = true
	public = false
	publicItalics = true
	privateProperties = {
		Color = Color3.fromRGB(188, 0, 255); 
		Font = Enum.Font.SourceSansBold;
		TextSize = 18;
	}

	--////////////////////////////////////////////////////////////////

	local StarterGui = game:GetService("StarterGui")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
	local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
	local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
	local instance = (_G.chatSpyInstance or 0) + 1
	_G.chatSpyInstance = instance

	local function onChatted(p,msg)
		if _G.chatSpyInstance == instance then
			if p==player and msg:lower():sub(1,4)=="/spy" then
				enabled = not enabled
				wait(0.3)
				privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
				StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
			elseif enabled and (spyOnMyself==true or p~=player) then
				msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
				local hidden = true
				local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
					if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and public==false and Players[packet.FromSpeaker].Team==player.Team)) then
						hidden = false
					end
				end)
				wait(1)
				conn:Disconnect()
				if hidden and enabled then
					if public then
						saymsg:FireServer((publicItalics and "/me " or '').."{SPY} [".. p.Name .."]: "..msg,"All")
					else
						privateProperties.Text = "{SPY} [".. p.Name .."]: "..msg
						StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
					end
				end
			end
		end
	end

	for _,p in ipairs(Players:GetPlayers()) do
		p.Chatted:Connect(function(msg) onChatted(p,msg) end)
	end
	Players.PlayerAdded:Connect(function(p)
		p.Chatted:Connect(function(msg) onChatted(p,msg) end)
	end)
	privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
	StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
	if not player.PlayerGui:FindFirstChild("Chat") then wait(3) end
	local chatFrame = player.PlayerGui.Chat.Frame
	chatFrame.ChatChannelParentFrame.Visible = true
	chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)
end)

section11:AddToggle("Esp Toggle", false, function(bro17)
    ESP:Toggle(bro17)
end):AddKeybind("None")

section11:AddToggle("Boxes", false, function(bro18)
    ESP.Boxes = bro18
end)

section11:AddToggle("Names", false, function(bro19)
    ESP.Names = bro19
end)

section11:AddToggle("Tracers", false, function(bro20)
    ESP.Tracers = bro20
end)

section11:AddSlider("Attach Shift", 0, 1, 10, decimals, function(bro21)
    ESP.AttachShift = bro21
end)

section12:AddDropdown("Faces", {"Super Super Happy Face", "Playful Vampire", "Blizzard Beast Mode", "Troublemaker", "Beast Mode", "Radioactive Beast Mode", "Madness Face"}, default, false, function(v)
    if v == "Super Super Happy Face" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://494290547"
    elseif v == "Playful Vampire" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://2409281591"
    elseif v == "Blizzard Beast Mode" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://209712379"
    elseif v == "Troublemaker" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://22920500"
    elseif v == "Beast Mode" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://127959433"
    elseif v == "Radioactive Beast Mode" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://2225757922"
    elseif v == "Madness Face" then
        game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://42070872"
    end
end)

section13:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

section13:AddButton("CPU Limiter", function()
    local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
 
local WindowFocusReleasedFunction = function()
    RunService:Set3dRenderingEnabled(false)
    setfpscap(10)
    return
end
 
local WindowFocusedFunction = function()
    RunService:Set3dRenderingEnabled(true)
    setfpscap(360)
    return
end
 
local Initialize = function()
    UserInputService.WindowFocusReleased:Connect(WindowFocusReleasedFunction)
    UserInputService.WindowFocused:Connect(WindowFocusedFunction)
    return
end
Initialize()
end)

section13:AddButton("FPS Booster", function()
    local decalsyeeted = true
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
local ggw = game:GetService("Workspace")
local ggp = game:GetService("Player")
local ggl = game:GetService("Lighting")
local ggrs = game:GetService("ReplicatedStorage")
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0
l.GlobalShadows = false
l.FogEnd = 9e9
l.Brightness = 0
ggw.Ignored.SnowBlock:Destroy()
ggp.nasipdevarsa.PlayerGui.MainScreenGui.SNOWBALLFRAME:Destroy()
ggl.SnowBlur:Destroy()
ggrs.SnowBlock:Destroy()
settings().Rendering.QualityLevel = "Level01"
for i, v in pairs(g:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    end
end
for i, e in pairs(l:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
end)

section13:AddSlider("Field Of View", 10, 70, 120, 120, function(fov)
    game:GetService("Workspace").Camera.FieldOfView = fov
end)

section14:AddDropdown("Teleports", {"Admin Guns 1", "Admin Guns 2", "Food Admin", "Ufo", "Ufo 2", "Ufo 3"}, default, false, function(v)
    if v == "Admin Guns 1" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-873, -34, -537)
            pl.CFrame = location
    elseif v == "Admin Guns 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-808, -39, -932)
            pl.CFrame = location
    elseif v == "Food Admin" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-786, -39, -932)
            pl.CFrame = location
    elseif v == "Ufo" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(71, 139, -691)
            pl.CFrame = location
    elseif v == "Ufo 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-30, 132, -742)
            pl.CFrame = location
    elseif v == "Ufo 3" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(173, 157, -731)
            pl.CFrame = location
    end
end)

section15:AddDropdown("Mountains", {"Rev Mountain", "Db Mountain", "Lmg Mountain", "AK Mountain", "Tactical Mountain"}, default, false, function(v)
    if v == "Rev Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-681, 167, -55)
            pl.CFrame = location
    elseif v == "Db Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-1073, 110, -136)
            pl.CFrame = location
    elseif v == "Lmg Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-720, 122, -350)
            pl.CFrame = location
    elseif v == "AK Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-721, 123, -660)
            pl.CFrame = location
    elseif v == "Tactical Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(503, 139, -755)
            pl.CFrame = location
    end
end)

section16:AddDropdown("Mountains 2", {"Gstation Mountain", "Bathroom Mountain", "Cementery Mountain", "Cementery Mountain 2", "Flowers Mountain"}, default, false, function(v)
    if v == "Gstation Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(654, 159, -400)
            pl.CFrame = location
    elseif v == "Bathroom Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(391, 130, -205)
            pl.CFrame = location
    elseif v == "Cementery Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(438, 122, -26)
            pl.CFrame = location
    elseif v == "Cementery Mountain 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(91, 111, -39)
            pl.CFrame = location
    elseif v == "Flowers Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(151, 137, -329)
            pl.CFrame = location
    end
end)

section17:AddDropdown("Mountains 3", {"Tommy Mountain", "Jail Mountain", "Furniture Mountain", "Playground Mountain", "Box Mountain"}, default, false, function(v)
    if v == "Tommy Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-136, 128, -31)
            pl.CFrame = location
    elseif v == "Jail Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-260, 130, 42)
            pl.CFrame = location
    elseif v == "Furniture Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-509, 152, -36)
            pl.CFrame = location
    elseif v == "Playground Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-310, 103, -681)
            pl.CFrame = location
    elseif v == "Box Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-272, 126, -948)
            pl.CFrame = location
    end
end)

section18:AddDropdown("Mountains 4", {"Circus Mountain", "Circus Mountain 2", "School Mountain", "Grenade Mountain", "Casino Mountain"}, default, false, function(v)
    if v == "Circus Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(248, 122, -869)
            pl.CFrame = location
    elseif v == "Circus Mountain 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-38, 115, -875)
            pl.CFrame = location
    elseif v == "Grenade Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-891, 136, 528)
            pl.CFrame = location
    elseif v == "Casino Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-848, 113, -28)
            pl.CFrame = location
    elseif v == "School Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-610, 147, 478)
            pl.CFrame = location
    end
end)

section19:AddDropdown("Buildings", {"Rev building", "Rev building 2", "Rev building 3", "Rpg building", "Bank Building"}, default, false, function(v)
    if v == "Rev building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-584, 80, -78)
            pl.CFrame = location
    elseif v == "Rev building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-496, 48, -213)
            pl.CFrame = location
    elseif v == "Rev building 3" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-647, 80, -204)
            pl.CFrame = location
    elseif v == "Rpg building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-222, 80, -466)
            pl.CFrame = location
    elseif v == "Bank Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-321, 80, -273)
            pl.CFrame = location
    end
end)

section20:AddDropdown("Buildings 2", {"Flowers Building", "Playground Building", "Playground Building 2", "Tommy Building", "Cementery Building"}, default, false, function(v)
    if v == "Flowers Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-111, 80, -314)
            pl.CFrame = location
    elseif v == "Playground Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-225, 80, -626)
            pl.CFrame = location
    elseif v == "Playground Building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-222, 80, -859)
            pl.CFrame = location
    elseif v == "Tommy Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-30, 80, -79)
            pl.CFrame = location
    elseif v == "Cementery Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(122, 80, -90)
            pl.CFrame = location
    end
end)

section21:AddDropdown("Buildings 3", {"AK Building", "AK Building 2", "Gstation Bulding", "Tactical Building", "School Roof"}, default, false, function(v)
    if v == "AK Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-586, 66, -681)
            pl.CFrame = location
    elseif v == "AK Building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-415, 71, -655)
            pl.CFrame = location
    elseif v == "Gstation Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(560, 106, -408)
            pl.CFrame = location
    elseif v == "Tactical Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(434, 106, -629)
            pl.CFrame = location
    elseif v == "School Roof" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-605, 68, 353)
            pl.CFrame = location
    end
end)

section22:AddDropdown("Threes", {"Bank Three", "Ak Three", "Playground Three", "Gym Three", "Flowers Three", "Tactical Three", "Gstation Three", "Cementery Three", "Cementery Three 2", "Jail Three", "School Three", "Circus Three"}, default, false, function(v)
    if v == "Bank Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-376, 98, -444)
            pl.CFrame = location
    elseif v == "Ak Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-404, 98, -719)
            pl.CFrame = location
    elseif v == "Playground Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-345, 98, -769)
            pl.CFrame = location
    elseif v == "Gym Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-63, 98, -535)
            pl.CFrame = location
    elseif v == "Flowers Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-44, 99, -289)
            pl.CFrame = location
    elseif v == "Gstation Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(641, 102, -193)
            pl.CFrame = location
    elseif v == "Cementery Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(326, 99, -114)
            pl.CFrame = location
    elseif v == "Cementery Three 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(110, 99, -213)
            pl.CFrame = location
    elseif v == "Jail Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-418, 94, 67)
            pl.CFrame = location
    elseif v == "School Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-537, 75, 162)
            pl.CFrame = location
    elseif v == "Circus Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(320, 100, -962)
            pl.CFrame = location
    elseif v == "Tactical Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(387, 125, -492)
            pl.CFrame = location
    end
end)