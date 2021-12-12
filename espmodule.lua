local Lowfi = {
    Boxes = false,
    BoxesColor = Color3.fromRGB(255, 255, 255),
    Names = false,
    NamesColor = Color3.fromRGB(255, 255, 255),
    Distance = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    Cham = false,
    ChamColor1 = Color3.fromRGB(0, 153, 153),
    ChamColor2 = Color3.fromRGB(0, 220, 220),
    Thickness = 1,
    Objects = setmetatable({}, {__mode = "kv"})
}

local Service = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})

local CurrentCamera = workspace.CurrentCamera
local Players = Service.Players
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local WorldToViewPortPoint = CurrentCamera.WorldToViewportPoint
local WorldToScreenPoint = CurrentCamera.WorldToScreenPoint
local V2New = Vector2.new
local V3New = Vector3.new
local RunService = Service.RunService

local Module = {
    Network = function(Data)
        if Data and Data.Character and Data.Character:FindFirstChild("HumanoidRootPart") ~= nil and Data.Character:FindFirstChild("Humanoid") ~= nil and Data.Character:FindFirstChild("Head") ~= nil then
            return true
        end
        return false
    end,
    Cham = function(Data, State)
        local BoxVar = nil
        local GlowVar = nil
        if State then
            for _, v in pairs(Data.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    if not v:FindFirstChild("Box") then
                        if not v:FindFirstChild("VisibleBox") then
                            BoxVar = Instance.new("BoxHandleAdornment", v)
                            BoxVar.Name = "Box"
                            BoxVar.AlwaysOnTop = true
                            BoxVar.ZIndex = 4
                            BoxVar.Adornee = v
                            BoxVar.Color3 = Lowfi.ChamColor1
                            BoxVar.Transparency = 0.5
                            BoxVar.Size = v.Size + Vector3.new(0.02, 0.02, 0.02)

                            GlowVar = Instance.new("BoxHandleAdornment", v)
                            GlowVar.Name = "VisibleBox"
                            GlowVar.AlwaysOnTop = false
                            GlowVar.ZIndex = 3
                            GlowVar.Adornee = v
                            GlowVar.Color3 = Lowfi.ChamColor2
                            GlowVar.Size = v.Size + Vector3.new(0.07, 0.07, 0.07)
                        end
                    end
                end
            end
        else
            for i, v in pairs(Data.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    if v:FindFirstChild("Box") then
                        v["Box"]:Destroy()
                    end
                    if v:FindFirstChild("VisibleBox") then
                        v["VisibleBox"]:Destroy()
                    end
                end
            end
            
            return BoxVar, GlowVar
        end
    end
}

local function NewDrawing(Object, Props)
    local New = Drawing.new(Object)
    Props = Props or {}
    for i, v in pairs(Props) do
        New[i] = v
    end
    return New
end

function Lowfi:Add(P, User, Obj)
    if Obj == nil then
        return 
    end

    local Box = NewDrawing("Square", {
        Thickness = self.Thickness,
        Color = Lowfi.BoxesColor,
        Transparency = 1,
        Filled = false,
        Visible = false
    })

    local Name = NewDrawing("Text", {
        Text = User,
        Color = Lowfi.NamesColor,
        Transparency = 1,
        Outline = false,
        Center = true,
        Visible = false,
        Size = 14
    })

    local Distance = NewDrawing("Text", {
        Text = "0m",
        Color = Lowfi.DistanceColor,
        Transparency = 1,
        Outline = false,
        Center = true,
        Visible = false,
        Size = 14
    })

    local Env = RunService.RenderStepped:Connect(function()
        local RootPos, RootVis = WorldToViewPortPoint(CurrentCamera, Obj.Position)
        local LegPos = WorldToViewPortPoint(CurrentCamera, Obj.Position - V3New(0, 6, 0))
        local GetDistance = (CurrentCamera.CFrame.p - Obj.Position).Magnitude

        if RootVis and Module.Network(P) then
            Module.Cham(P, Lowfi.Cham)

            if Box then
                if Lowfi.Boxes then
                    Box.Size = V2New(2750 / RootPos.Z, 4000 / RootPos.Z)
                    Box.Position = V2New(RootPos.X - Box.Size.X / 2, RootPos.Y - Box.Size.Y / 2)
                    Box.Color = Lowfi.BoxesColor
                    Box.Visible = true  
                else
                    Box.Visible = false
                end
            end

            if Name then
                if Lowfi.Names then
                    Name.Position = V2New(Box.Position.X + (Box.Size.X / 2), Box.Position.Y - 16.5)
                    Name.Color = Lowfi.NamesColor
                    Name.Visible = true  
                else
                    Name.Visible = false
                end
            end

            if Distance then
                if Lowfi.Distance then
                    Distance.Text = tostring(math.floor(GetDistance) .. "m")
                    Distance.Position = V2New(Box.Position.X + (Box.Size.X / 2), Box.Position.Y + Box.Size.Y)
                    Distance.Color = Lowfi.DistanceColor
                    Distance.Visible = true
                else
                    Distance.Visible = false
                end
            end
        else
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
        end
    end)

    Obj.AncestryChanged:Connect(function(_, Parent)
        if Parent == nil then
            Env:Disconnect()
            wait(0.1)
            Env = nil
            repeat wait() until Env == nil
            Box:Remove()
            Name:Remove()
            Distance:Remove()
        end
    end)

    Obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if Obj.Parent == nil then
            Env:Disconnect()
            wait(0.1)
            Env = nil
            repeat wait() until Env == nil
            Box:Remove()
            Name:Remove()
            Distance:Remove()
        end
    end)
end

local function CharAdded(Char)
    local Plr = Players:GetPlayerFromCharacter(Char)
    if not Char:FindFirstChild("HumanoidRootPart") then
        local Env
        Env = Char.ChildAdded:Connect(function(Child)
            if Child.Name == "HumanoidRootPart" then
                Env:Disconnect()
                Lowfi:Add(Plr, Plr.Name, Child)
            end
        end)
    else
        Lowfi:Add(Plr, Plr.Name, Char.HumanoidRootPart)
    end
end

local function PlayerAdded(P)
    P.CharacterAdded:Connect(CharAdded)
    if P.Character then
        coroutine.wrap(CharAdded)(P.Character)
    end
end

Players.PlayerAdded:Connect(PlayerAdded)

for i, v in pairs(Players:GetPlayers()) do
    if v ~= Player then
        PlayerAdded(v)
    end
end

return Lowfi
