local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- 二重起動防止（古いUIを消す）
if CoreGui:FindFirstChild("AdminConsole_Pro") then
    CoreGui["AdminConsole_Pro"]:Destroy()
end

-- メインGUI作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminConsole_Pro"
ScreenGui.Parent = CoreGui

-- ウィンドウ本体
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- モバイルで自由に動かせる
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- タイトルバー（赤色で警告感を出す）
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 12)
BarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = " SYSTEM: 管理者モード"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ログ表示テキスト
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -20, 0, 100)
LogLabel.Position = UDim2.new(0, 10, 0, 50)
LogLabel.BackgroundTransparency = 1
LogLabel.TextColor3 = Color3.fromRGB(0, 255, 50) -- ハッカーグリーン
LogLabel.TextSize = 16
LogLabel.Font = Enum.Font.Code
LogLabel.Text = "> システム起動中..."
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.Parent = MainFrame

-- 演出スタート
task.spawn(function()
    -- 接続アニメーション（3回ループ）
    for i = 1, 3 do
        LogLabel.Text = "> 管理者モード接続中."
        task.wait(1)
        LogLabel.Text = "> 管理者モード接続中.."
        task.wait(1)
        LogLabel.Text = "> 管理者モード接続中..."
        task.wait(1)
    end
    
    -- 最終段階
    LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogLabel.Text = "> ターゲット特定済\n> 権限取得完了\n> 準備完了！"
    task.wait(3)
    
    -- キック実行
    Players.LocalPlayer:Kick("ROBLOXガイドライン 368\n\nI'm sad, brother 🥀")
end)
