-- NhatPhi Admin Menu - 10 Key Gate + Loader -> Main Script
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local KEY_LIST_URL = "https://raw.githubusercontent.com/buinhatphibuinhatphi-eng/khoscriptnhatphi/main/keys.lua"
local LOAD_DURATION = 5

local function cleanupOldGui()
    for _, parent in ipairs({ CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "NhatPhi_KeyAndMenuGui" or child.Name == "NhatPhi_AdminMenu" then
                    child:Destroy()
                end
            end
        end
    end
end

cleanupOldGui()

local function checkKey(inputKey)
    if type(inputKey) ~= "string" then
        return false
    end
    -- Cắt khoảng trắng thừa đầu/cuối nếu khách lỡ copy dính space
    local cleanedKey = inputKey:match("^%s*(.-)%s*$")
    if cleanedKey == "" then
        return false
    end

    local ok, keyTable = pcall(function()
        return loadstring(game:HttpGet(KEY_LIST_URL))()
    end)

    if ok and type(keyTable) == "table" then
        return keyTable[cleanedKey] == true
    end
    return false
end

local function openMainMenu()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "NhatPhi_AdminMenu"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(360, 220)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.fromOffset(10, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "NHATPHI MENU - VIP ACTIVATED"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.Parent = MainFrame

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, -24, 0, 100)
    Info.Position = UDim2.fromOffset(12, 55)
    Info.BackgroundTransparency = 1
    Info.TextWrapped = true
    Info.Text = "Key hợp lệ! Hãy dán code tính năng chính của bạn vào hàm openMainMenu()."
    Info.TextColor3 = Color3.fromRGB(190, 198, 212)
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 13
    Info.Parent = MainFrame

    -- DÁN CODE TÍNH NĂNG CHÍNH CỦA BẠN VÀO ĐÂY
end
local KEY_LIST_URL = "https://raw.githubusercontent.com/buinhatphibuinhatphi-eng/khoscriptnhatphi/main/keys.lua"
-- Giao diện nhập Key
local GuiRoot = Instance.new("ScreenGui")
GuiRoot.Name = "NhatPhi_KeyAndMenuGui"
GuiRoot.ResetOnSpawn = false
GuiRoot.IgnoreGuiInset = true
GuiRoot.Parent = CoreGui

local Card = Instance.new("Frame")
Card.Size = UDim2.fromOffset(340, 190)
Card.Position = UDim2.fromScale(0.5, 0.5)
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.BackgroundColor3 = Color3.fromRGB(25, 27, 34)
Card.BorderSizePixel = 0
Card.Parent = GuiRoot

Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -20, 0, 34)
Header.Position = UDim2.fromOffset(10, 10)
Header.BackgroundTransparency = 1
Header.Text = "NHẬP KEY KÍCH HOẠT"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 15
Header.Parent = Card

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -30, 0, 38)
KeyBox.Position = UDim2.fromOffset(15, 52)
KeyBox.BackgroundColor3 = Color3.fromRGB(38, 42, 52)
KeyBox.Text = ""
KeyBox.PlaceholderText = "Nhập key của bạn..."
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(140, 148, 162)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 13
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = Card

Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 22)
StatusLabel.Position = UDim2.fromOffset(15, 94)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = Card

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(1, -30, 0, 38)
SubmitBtn.Position = UDim2.fromOffset(15, 124)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
SubmitBtn.Text = "XÁC NHẬN KEY"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 13
SubmitBtn.Parent = Card

Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

local checking = false
SubmitBtn.MouseButton1Click:Connect(function()
    if checking then return end
    checking = true
    SubmitBtn.Text = "ĐANG KIỂM TRA..."
    StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    StatusLabel.Text = "Đang kết nối danh sách key..."

    local valid = checkKey(KeyBox.Text)

    if valid then
        StatusLabel.TextColor3 = Color3.fromRGB(90, 235, 130)
        StatusLabel.Text = "Key hợp lệ! Đang tải (" .. LOAD_DURATION .. "s)..."
        SubmitBtn.Text = "THÀNH CÔNG"

        task.wait(LOAD_DURATION)
        GuiRoot:Destroy()
        openMainMenu()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 95, 95)
        StatusLabel.Text = "Key không đúng hoặc đã bị khóa!"
        SubmitBtn.Text = "XÁC NHẬN KEY"
        checking = false
    end
end)
