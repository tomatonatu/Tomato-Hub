-- tomato HUB - iOS対応モバイル専用版
-- steal a brainlotゲーム用Brainパーツ検索・テレポート・自動ブロック・リモート攻撃・ラグスクリプト

-- プレイヤーとサービスの変数
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

-- メインUI変数
local mainGui = nil
local menuFrame = nil

-- 機能状態変数
local brainTeleportEnabled = false
local autoBlockEnabled = false
local remoteAttackEnabled = false
local lagScriptEnabled = false
local batEquipped = false
local targetPlayer = nil
local lagObjects = {}

-- 起動画面表示
local function showLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TomatoHubLoading"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "tomato HUB"
    titleLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = frame
    
    local innerBar = Instance.new("Frame")
    innerBar.Size = UDim2.new(0, 0, 0, 10)
    innerBar.Position = UDim2.new(0.1, 0, 0, 80)
    innerBar.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    innerBar.BorderSizePixel = 0
    innerBar.Parent = frame
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 5)
    innerCorner.Parent = innerBar
    
    -- アニメーション処理
    spawn(function()
        innerBar:TweenSize(
            UDim2.new(0.8, 0, 0, 10),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            3,
            true
        )
        
        wait(3)
        
        frame:TweenSize(
            UDim2.new(0, 300, 0, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.5,
            true
        )
        
        wait(0.5)
        screenGui:Destroy()
        
        -- メインメニュー表示
        createMainMenu()
    end)
end

-- メインメニュー作成
local function createMainMenu()
    -- ScreenGui作成
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "TomatoHubMenu"
    mainGui.Parent = player:WaitForChild("PlayerGui")
    mainGui.ResetOnSpawn = false
    
    -- メインフレーム
    menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 320, 0, 450)
    menuFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
    menuFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = mainGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = menuFrame
    
    -- タイトルバー
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = menuFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "tomato HUB"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = titleBar
    
    -- 閉じるボタン
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 30)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    
    -- 機能ボタン作成関数
    local function createButton(text, yPos, toggleVar, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 280, 0, 50)
        button.Position = UDim2.new(0, 20, 0, yPos)
        button.BackgroundColor3 = toggleVar and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
        button.BorderSizePixel = 0
        button.Text = text .. (toggleVar and ": ON" or ": OFF")
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSans
        button.Parent = menuFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 5)
        buttonCorner.Parent = button
        
        -- ボタンクリック処理
        button.MouseButton1Click:Connect(function()
            callback()
            button.BackgroundColor3 = toggleVar and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
            button.Text = text .. (toggleVar and ": ON" or ": OFF")
        end)
        
        return button
    end
    
    -- Brainテレポート機能
    local brainTeleportButton = createButton("Brainテレポート", 60, brainTeleportEnabled, function()
        brainTeleportEnabled = not brainTeleportEnabled
    end)
    
    -- 自動ブロック機能
    local autoBlockButton = createButton("自動ブロック", 120, autoBlockEnabled, function()
        autoBlockEnabled = not autoBlockEnabled
    end)
    
    -- リモート攻撃機能
    local remoteAttackButton = createButton("リモート攻撃", 180, remoteAttackEnabled, function()
        remoteAttackEnabled = not remoteAttackEnabled
        if remoteAttackEnabled and not batEquipped then
            -- プレイヤーに通知
            local notify = Instance.new("TextLabel")
            notify.Size = UDim2.new(0, 250, 0, 50)
            notify.Position = UDim2.new(0.5, -125, 0.8, 0)
            notify.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
            notify.BorderSizePixel = 0
            notify.Text = "バットを装備してください"
            notify.TextColor3 = Color3.new(1, 1, 1)
            notify.TextScaled = true
            notify.Font = Enum.Font.SourceSansBold
            notify.Parent = mainGui
            
            local notifyCorner = Instance.new("UICorner")
            notifyCorner.CornerRadius = UDim.new(0, 5)
            notifyCorner
