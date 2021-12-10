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
local window = library:CreateWindow("privateware-rewrite", Vector2.new(492, 598), Enum.KeyCode.V)

local B_1_ = window:CreateTab("Aim Stuff")
local B_2_ = window:CreateTab("Misc")
local B_3_ = window:CreateTab("Visual")
local B_4_ = window:CreateTab("Teleports")

local section1 = B_1_:CreateSector("Aimbot", "left")
local section2 = B_1_:CreateSector("Aimbot; Settings", "right")
local section3 = B_1_:CreateSector("Silent Aim", "left")
local section4 = B_1_:CreateSector("Silent Aim; Settings", "right")
local section5 = B_1_:CreateSector("Esp", "left")
local section6 = B_1_:CreateSector("Settings", "right")
local section7 = B_2_:CreateSector("Animations", "left")
local section8 = B_2_:CreateSector("CFrame Speed", "right")

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

section5:AddToggle("Esp Toggle", false, function(bro17)
    ESP:Toggle(bro17)
end):AddKeybind("None")

section5:AddToggle("Boxes", false, function(bro18)
    ESP.Boxes = bro18
end)

section5:AddToggle("Names", false, function(bro19)
    ESP.Names = bro19
end)

section5:AddToggle("Tracers", false, function(bro20)
    ESP.Tracers = bro20
end)

section5:AddSlider("Attach Shift", 0, 1, 10, decimals, function(bro21)
    ESP.AttachShift = bro21
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