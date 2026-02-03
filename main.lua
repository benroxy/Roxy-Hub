local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Modal = loadstring(game:HttpGet("https://github.com/lxte/Modal/releases/latest/download/main.lua"))()

-- [ GLOBAL AYARLAR ]
_G.AutoParry = false
_G.BallLock = false
_G.HitSound = true
_G.HitEffect = true
local Parried = false

-- [ SES ÖN YÜKLEME ]
local SoundAsset = "rbxassetid://6607204501"
local PreloadSound = Instance.new("Sound")
PreloadSound.SoundId = SoundAsset
ContentProvider:PreloadAsync({PreloadSound})

-- [ NEON HIT EFEKTİ ]
local function CreateNeonAura(Pos)
    if not _G.HitEffect then return end
    task.spawn(function()
        local Aura = Instance.new("Part")
        Aura.Size, Aura.Position, Aura.Anchored, Aura.CanCollide = Vector3.new(2, 0.2, 2), Pos - Vector3.new(0, 2.8, 0), true, false
        Aura.Material, Aura.Color, Aura.Parent = Enum.Material.Neon, Color3.fromRGB(0, 255, 255), workspace
        
        local Mesh = Instance.new("SpecialMesh", Aura)
        Mesh.MeshId, Mesh.Scale = "rbxassetid://20329976", Vector3.new(1, 1, 1)
        
        local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(Mesh, Info, {Scale = Vector3.new(22, 22, 3)}):Play()
        TweenService:Create(Aura, Info, {Transparency = 1}):Play()
        
        task.wait(0.4)
        Aura:Destroy()
    end)
end

-- [ VURUŞ SESİ ]
local function PlayHitSound()
    if not _G.HitSound then return end
    task.spawn(function()
        local Sound = Instance.new("Sound")
        Sound.SoundId = SoundAsset
        Sound.Volume = 3
        Sound.Parent = Player:WaitForChild("PlayerGui")
        Sound:Play()
        task.wait(1.5)
        Sound:Destroy()
    end)
end

-- [ UI OLUŞTURMA ]
local Window = Modal:CreateWindow({ 
    Title = "💎 Roxy Hub", 
    SubTitle = "Blade Ball V1.0" 
})
Window:SetTheme("Midnight")

local Main = Window:AddTab("Savaş")
local Visual = Window:AddTab("Görsel")

Main:New("Toggle")({ 
    Title = "Auto Parry", 
    Description = "Otomatik vuruş yapar.",
    Callback = function(v) _G.AutoParry = v end 
})

Main:New("Toggle")({ 
    Title = "Ball Lock", 
    Description = "Kamera serbest, gövde topa bakar.",
    Callback = function(v) _G.BallLock = v end 
})

Visual:New("Toggle")({ 
    Title = "Neon Hit Effect", 
    DefaultValue = true,
    Callback = function(v) _G.HitEffect = v end 
})

Visual:New("Toggle")({ 
    Title = "Custom Hit Sound", 
    DefaultValue = true,
    Callback = function(v) _G.HitSound = v end 
})

-- [ ANA DÖNGÜ ]
RunService.PostSimulation:Connect(function()
    local Ball = nil
    local Balls = workspace:FindFirstChild("Balls")
    if Balls then
        for _, b in pairs(Balls:GetChildren()) do
            if b:GetAttribute("realBall") then Ball = b break end
        end
    end

    local Character = Player.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if Ball and HRP then
        -- BALL LOCK SİSTEMİ
        if _G.BallLock then
            local TargetPos = Vector3.new(Ball.Position.X, HRP.Position.Y, Ball.Position.Z)
            HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(HRP.Position, TargetPos), 0.25)
        end

        -- AUTO PARRY & TETİKLEYİCİLER
        if _G.AutoParry and Ball:GetAttribute("target") == Player.Name and not Parried then
            local Speed = Ball.zoomies.VectorVelocity.Magnitude
            local Distance = (HRP.Position - Ball.Position).Magnitude
            
            if (Distance / Speed) <= 0.53 then
                task.defer(function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    CreateNeonAura(HRP.Position)
                    PlayHitSound()
                end)
                
                Parried = true
                task.delay(0.2, function() Parried = false end)
            end
        end
    end
end)
