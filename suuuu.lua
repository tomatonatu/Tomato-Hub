local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- 二重起動防止
if CoreGui:FindFirstChild("AdminConsole_Final") then
    CoreGui["AdminConsole_Final"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminConsole_Final"
ScreenGui.Parent = CoreGui

-- メインウィンドウ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 180)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- 真っ黒
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- タイトルバー（管理者モード）
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 0, 0) -- 警告の赤
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 15)
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

-- ログ表示（ハッカー風）
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -20, 0, 100)
LogLabel.Position = UDim2.new(0, 10, 0, 50)
LogLabel.BackgroundTransparency = 1
LogLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- 緑色の文字
LogLabel.TextSize = 16
LogLabel.Font = Enum.Font.Code
LogLabel.Text = "> 待機中..."
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.Parent = MainFrame

-- 演出の実行
task.spawn(function()
    -- 1. 接続シークエンス
    for i = 1, 3 do
        LogLabel.Text = "> 管理者モード接続中."
        task.wait(1)
        LogLabel.Text = "> 管理者モード接続中.."
        task.wait(1)
        LogLabel.Text = "> 管理者モード接続中..."
        task.wait(1)
    end
    
    -- 2. 準備完了
    LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogLabel.Text = "> ターゲット特定済\n> 権限取得完了\n> 準備完了！"
    task.wait(3)
    
    -- 3. 本気（ガチ）のキックメッセージ
    local kickMsg = [[
[ROBLOX セキュリティ通知]
アカウントに対する不正なアクセス権限の行使が検出されました。

ステータス: 永久追放 (Permanent Blacklist)
ハードウェアID: 0x882-B-119-X

"I'm sad, brother 🥀"

このデバイスからの接続は今後すべて拒否されます。
]]
    Players.LocalPlayer:Kick(kickMsg)
end)
