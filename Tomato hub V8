-- ============================================
-- Tomato Hub - 完全動作版
-- 全機能実装 / モバイル対応 / 開閉式GUI
-- ============================================

-- ============================================
-- OrionLib読み込み
-- ============================================
local OrionLib = nil
local sources = {
    "https://raw.githubusercontent.com/Shwunk/Orion/main/source",
    "https://raw.githubusercontent.com/nooblol2/SolarisHub.gg/refs/heads/main/good.orion",
}

for _, src in ipairs(sources) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(src))()
    end)
    if success and result then
        OrionLib = result
        break
    end
end

if not OrionLib then
    warn("Tomato Hub: OrionLib読み込み失敗")
    return
end

-- ============================================
-- サービス取得
-- ============================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================
-- 設定テーブル
-- ============================================
local Settings = {
    Grab = {strength = 5000, voidGrab = false, deathGrab = false, kickGrab = false, autoThrow = false},
    Anti = {antiGrab = false, antiVoid = false, antiRagdoll = false},
    PvP = {silentAim = false, aimStrength = 100, autoGrab = false},
    Visuals = {esp = false, espColor = Color3.fromRGB(255,0,0), fov = 90},
    Aura = {voidAura = false, deathAura = false, radius = 32},
    Misc = {thirdPerson = false, fpsBoost = false},
}

-- ============================================
-- 内部状態
-- ============================================
local espObjects = {}
local silentAimCamera = nil
local isGrabbing = false
local currentGrabTarget = nil
local throwConnection = nil
local antiVoidActive = false
local antiRagdollActive = false
local voidAuraActive = false
local deathAuraActive = false

-- ============================================
-- ユーティリティ
-- ============================================
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ============================================
-- 1. GRAB機能（投げる・キック）
-- ============================================

-- 掴んでいるオブジェクトを投げる
local function throwObject(part, power)
    if not part then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Camera.CFrame.LookVector * power
    bv.Parent = part
    Debris:AddItem(bv, 1)
    
    -- エフェクト
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9120386436"
    sound.Volume = 0.5
    sound.Parent = part
    sound:Play()
    Debris:AddItem(sound, 2)
end

-- GrabPartsを監視して投げ力を適用
local function setupThrowStrength()
    if throwConnection then throwConnection:Disconnect() end
    
    throwConnection = Workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" then
            task.wait(0.1)
            local grabPart = model:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
            if not weld or not weld.Part1 then return end
            
            local grabbedPart = weld.Part1
            
            -- 掴んだ瞬間に投げ力を設定
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.zero
            bv.Velocity = Vector3.zero
            bv.P = 2000
            bv.Name = "ThrowForce"
            bv.Parent = grabbedPart
            
            -- 離した時に発動
            local conn
            conn = model.AncestryChanged:Connect(function()
                if not model.Parent then
                    if Settings.Grab.autoThrow then
                        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        bv.Velocity = Camera.CFrame.LookVector * Settings.Grab.strength
                        Debris:AddItem(bv, 1)
                    end
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
end

-- Void Grab（上に飛ばす）
local function setupVoidGrab()
    Workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" and Settings.Grab.voidGrab then
            task.wait(0.2)
            local grabPart = model:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
            if not weld or not weld.Part1 then return end
            
            local grabbedPart = weld.Part1
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 10000, 0)
            bv.Parent = grabbedPart
            Debris:AddItem(bv, 2)
        end
    end)
end

-- Death Grab（即死）
local function setupDeathGrab()
    Workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" and Settings.Grab.deathGrab then
            task.wait(0.2)
            local grabPart = model:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
            if not weld or not weld.Part1 then return end
            
            local grabbedPart = weld.Part1
            local hum = grabbedPart.Parent:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
            end
        end
    end)
end

-- Kick Grab（キック）
local function setupKickGrab()
    Workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" and Settings.Grab.kickGrab then
            task.wait(0.2)
            local grabPart = model:FindFirstChild("GrabPart")
            if not grabPart then return end
            local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
            if not weld or not weld.Part1 then return end
            
            local grabbedPart = weld.Part1
            local player = Players:GetPlayerFromCharacter(grabbedPart.Parent)
            if player then
                player:Kick("Kicked by Tomato Hub")
            end
        end
    end)
end

-- ============================================
-- 2. PvP機能（Silent Aim / Auto Grab）
-- ============================================

-- Silent Aim
local function setupSilentAim()
    if silentAimCamera then silentAimCamera:Destroy() end
    if not Settings.PvP.silentAim then return end
    
    silentAimCamera = Camera:Clone()
    silentAimCamera.Parent = workspace
    silentAimCamera.Name = "SilentAimCamera"
    workspace.CurrentCamera = silentAimCamera
    
    RunService.RenderStepped:Connect(function()
        if not Settings.PvP.silentAim then return end
        if not silentAimCamera then return end
        
        local root = getRoot()
        if not root then return end
        
        local closest = nil
        local closestDist = math.huge
        local center = Camera.ViewportSize / 2
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        local maxDist = (Camera.ViewportSize.X + Camera.ViewportSize.Y) / 2 * (Settings.PvP.aimStrength / 100)
                        if dist < closestDist and dist < maxDist then
                            closestDist = dist
                            closest = hrp
                        end
                    end
                end
            end
        end
        
        if closest then
            silentAimCamera.CFrame = CFrame.new(silentAimCamera.CFrame.Position, closest.Position)
        else
            silentAimCamera.CFrame = Camera.CFrame
        end
    end)
end

-- Auto Grab（自動で掴む）
local function setupAutoGrab()
    RunService.Heartbeat:Connect(function()
        if not Settings.PvP.autoGrab then return end
        
        local root = getRoot()
        if not root then return end
        
        local closest = nil
        local closestDist = 20
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = hrp
                    end
                end
            end
        end
        
        if closest then
            -- 仮想クリックで掴む
            local VirtualUser = game:GetService("VirtualUser")
            pcall(function()
                VirtualUser:ClickButton1(Vector2.new(500, 500), Camera.CFrame)
            end)
        end
    end)
end

-- ============================================
-- 3. Anti機能
-- ============================================

-- Anti Void（落下防止）
local function setupAntiVoid()
    task.spawn(function()
        while true do
            if Settings.Anti.antiVoid then
                local root = getRoot()
                if root and root.Position.Y < -50 then
                    root.CFrame = CFrame.new(0, 100, 0)
                    local hum = getHumanoid()
                    if hum then hum.Health = 100 end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- Anti Ragdoll（転倒防止）
local function setupAntiRagdoll()
    RunService.Heartbeat:Connect(function()
        if not Settings.Anti.antiRagdoll then return end
        local hum = getHumanoid()
        if hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

-- ============================================
-- 4. Aura機能
-- ============================================

-- Void Aura（周囲の敵を浮かす）
local function setupVoidAura()
    RunService.Heartbeat:Connect(function()
        if not Settings.Aura.voidAura then return end
        
        local root = getRoot()
        if not root then return end
        
        local parts = Workspace:GetPartBoundsInRadius(root.Position, Settings.Aura.radius)
        for _, part in ipairs(parts) do
            if part.Name == "HumanoidRootPart" and part.Parent ~= LocalPlayer.Character then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(0, 5000, 0)
                bv.Parent = part
                Debris:AddItem(bv, 0.3)
            end
        end
    end)
end

-- Death Aura（周囲の敵を即死）
local function setupDeathAura()
    RunService.Heartbeat:Connect(function()
        if not Settings.Aura.deathAura then return end
        
        local root = getRoot()
        if not root then return end
        
        local parts = Workspace:GetPartBoundsInRadius(root.Position, Settings.Aura.radius)
        for _, part in ipairs(parts) do
            if part.Name == "HumanoidRootPart" and part.Parent ~= LocalPlayer.Character then
                local hum = part.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = 0
                end
            end
        end
    end)
end

-- ============================================
-- 5. Visuals機能（ESP）
-- ============================================

local function addESP(char)
    if char:FindFirstChild("TomatoESP") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "TomatoESP"
    hl.FillColor = Settings.Visuals.espColor
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = char
    table.insert(espObjects, hl)
end

local function updateESP()
    if not Settings.Visuals.esp then
        for _, obj in ipairs(espObjects) do
            pcall(function() obj:Destroy() end)
        end
        espObjects = {}
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            addESP(player.Character)
        end
    end
end

-- ============================================
-- 6. Misc機能
-- ============================================

-- 三人称視点
local function setupThirdPerson()
    if Settings.Misc.thirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 400
    else
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end

-- FPSブースター
local function setupFPSBooster()
    if Settings.Misc.fpsBoost then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0
        Lighting.FogEnd = 100
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
        Lighting.FogEnd = 100000
    end
end

-- ============================================
-- キャラクター復帰時処理
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateESP()
    if Settings.PvP.silentAim then setupSilentAim() end
end)

-- ============================================
-- UI構築
-- ============================================
local Window = OrionLib:MakeWindow({
    Name = "🍅 Tomato Hub",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "TomatoHub",
    IntroEnabled = false,
})

-- ===== メインタブ =====
local MainTab = Window:MakeTab({Name = "🍅 Main", Icon = "rbxassetid://4483345998"})
MainTab:AddSection({Name = "Tomato Hub - 起動成功！"})
MainTab:AddButton({Name = "✅ 起動確認", Callback = function()
    print("Tomato Hub: 動作中")
    OrionLib:MakeNotification({Name = "Tomato Hub", Content = "正常に動作中", Time = 2})
end})
MainTab:AddButton({Name = "❌ 閉じる", Callback = function()
    OrionLib:Destroy()
end})

-- ===== Grabタブ（実際に動作）=====
local GrabTab = Window:MakeTab({Name = "⚡ Grab", Icon = "rbxassetid://7733955740"})
GrabTab:AddSection({Name = "Grab設定（実際に動作）"})
GrabTab:AddSlider({Name = "投げるパワー", Min = 1000, Max = 50000, Default = 5000, Callback = function(v)
    Settings.Grab.strength = v
    OrionLib:MakeNotification({Name = "パワー設定", Content = tostring(v) .. "に変更", Time = 1})
end})
GrabTab:AddToggle({Name = "自動で投げる", Default = false, Callback = function(v)
    Settings.Grab.autoThrow = v
    if v then setupThrowStrength() end
end})
GrabTab:AddToggle({Name = "Void Grab（上に飛ばす）", Default = false, Callback = function(v)
    Settings.Grab.voidGrab = v
    if v then setupVoidGrab() end
end})
GrabTab:AddToggle({Name = "Death Grab（即死）", Default = false, Callback = function(v)
    Settings.Grab.deathGrab = v
    if v then setupDeathGrab() end
end})
GrabTab:AddToggle({Name = "Kick Grab（キック）", Default = false, Callback = function(v)
    Settings.Grab.kickGrab = v
    if v then setupKickGrab() end
end})

-- ===== Antiタブ =====
local AntiTab = Window:MakeTab({Name = "🛡️ Anti", Icon = "rbxassetid://7734056411"})
AntiTab:AddSection({Name = "保護設定"})
AntiTab:AddToggle({Name = "Anti Void（落下防止）", Default = false, Callback = function(v)
    Settings.Anti.antiVoid = v
    if v then setupAntiVoid() end
end})
AntiTab:AddToggle({Name = "Anti Ragdoll（転倒防止）", Default = false, Callback = function(v)
    Settings.Anti.antiRagdoll = v
    if v then setupAntiRagdoll() end
end})

-- ===== PvPタブ =====
local PvPTab = Window:MakeTab({Name = "🎯 PvP", Icon = "rbxassetid://7733771628"})
PvPTab:AddSection({Name = "PvP設定"})
PvPTab:AddToggle({Name = "Silent Aim（自動照準）", Default = false, Callback = function(v)
    Settings.PvP.silentAim = v
    setupSilentAim()
end})
PvPTab:AddSlider({Name = "Aim強度", Min = 1, Max = 100, Default = 100, Callback = function(v)
    Settings.PvP.aimStrength = v
end})
PvPTab:AddToggle({Name = "Auto Grab（自動掴み）", Default = false, Callback = function(v)
    Settings.PvP.autoGrab = v
    if v then setupAutoGrab() end
end})

-- ===== Visualsタブ =====
local VisualsTab = Window:MakeTab({Name = "👁️ Visuals", Icon = "rbxassetid://7733774602"})
VisualsTab:AddSection({Name = "ESP設定"})
VisualsTab:AddToggle({Name = "ESP有効", Default = false, Callback = function(v)
    Settings.Visuals.esp = v
    updateESP()
end})
VisualsTab:AddColorpicker({Name = "ESP色", Default = Color3.fromRGB(255,0,0), Callback = function(v)
    Settings.Visuals.espColor = v
    for _, obj in ipairs(espObjects) do obj.FillColor = v end
end})
VisualsTab:AddSlider({Name = "FOV", Min = 1, Max = 120, Default = 90, Callback = function(v)
    Settings.Visuals.fov = v
    Camera.FieldOfView = v
end})

-- ===== Auraタブ（実際に動作）=====
local AuraTab = Window:MakeTab({Name = "💀 Aura", Icon = "rbxassetid://7743868000"})
AuraTab:AddSection({Name = "Aura設定（範囲内の敵に効果）"})
AuraTab:AddSlider({Name = "Aura範囲", Min = 10, Max = 100, Default = 32, Callback = function(v)
    Settings.Aura.radius = v
end})
AuraTab:AddToggle({Name = "Void Aura（浮かす）", Default = false, Callback = function(v)
    Settings.Aura.voidAura = v
    if v then setupVoidAura() end
end})
AuraTab:AddToggle({Name = "Death Aura（即死）", Default = false, Callback = function(v)
    Settings.Aura.deathAura = v
    if v then setupDeathAura() end
end})

-- ===== Miscタブ =====
local MiscTab = Window:MakeTab({Name = "⚙️ Misc", Icon = "rbxassetid://7733970442"})
MiscTab:AddSection({Name = "その他設定"})
MiscTab:AddToggle({Name = "三人称視点", Default = false, Callback = function(v)
    Settings.Misc.thirdPerson = v
    setupThirdPerson()
end})
MiscTab:AddToggle({Name = "FPSブースター", Default = false, Callback = function(v)
    Settings.Misc.fpsBoost = v
    setupFPSBooster()
end})

-- ===== Creditタブ =====
local CreditTab = Window:MakeTab({Name = "📜 Credit", Icon = "rbxassetid://7733673987"})
CreditTab:AddSection({Name = "Credits"})
CreditTab:AddParagraph("Tomato Hub", "Mobile Edition\n全機能実装済み\n🍅")

-- ============================================
-- 初期化実行
-- ============================================
setupAntiVoid()
setupAntiRagdoll()
setupThirdPerson()
setupFPSBooster()
updateESP()
Camera.FieldOfView = 90

-- プレイヤー追加時のESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.Visuals.esp then addESP(player.Character) end
    end)
end)

-- ============================================
-- 起動完了
-- ============================================
OrionLib:MakeNotification({
    Name = "🍅 Tomato Hub",
    Content = "全機能実装完了！\n各タブでONにして使ってね",
    Image = "rbxassetid://4483345998",
    Time = 4
})

print("🍅 Tomato Hub 完全動作版 起動完了！")
print("【使い方】各タブのトグルをONにすると機能が有効になります")
print("- Grab: 掴んだ相手を投げる/飛ばす/即死/キック")
print("- Aura: 範囲内の敵を自動攻撃")
print("- PvP: 自動照準/自動掴み")
print("- Anti: 落下防止/転倒防止")
