-- NhatPhi Admin Menu v7.7 - Premium Edition (Head/Body Toggle + Strict FOV + Aim 90% + ESP Fix)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Biến cấu hình
local speedValue = 50
local jumpValue = 50
local flySpeed = 50
local aimFOV = 120          -- Bán kính vòng tròn FOV (pixel)
local aimStrength = 0.9     -- Độ bám aim (0.9 = 90%)

local isApplied = false
local isFlying = false
local isNoclip = false
local isESP = false
local isAimbot = false
local isAimHead = false     -- false: Aim Thân (HumanoidRootPart) | true: Aim Đầu (Head)
local isAutoKill = false

local flyBV, flyBG = nil, nil
local espHighlights = {}
local espTracers = {}
local isKilling = false
local autoKillCoroutine = nil

-- Xóa Gui cũ
if CoreGui:FindFirstChild("NhatPhi_AdminMenu") then
    CoreGui.NhatPhi_AdminMenu:Destroy()
end
if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("NhatPhi_AdminMenu") then
    LocalPlayer.PlayerGui.NhatPhi_AdminMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NhatPhi_AdminMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Nút mở menu
local OpenBtn = Instance.new("TextButton")
OpenBtn.Parent = ScreenGui
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
OpenBtn.Text = "⚡"
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 24
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(100, 150, 255)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 560)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BackgroundTransparency = 0.05
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 80, 180)

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ NhatPhi Menu"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local FPS = Instance.new("TextLabel")
FPS.Parent = Header
FPS.Size = UDim2.new(0.3, 0, 1, 0)
FPS.Position = UDim2.new(0.7, 0, 0, 0)
FPS.BackgroundTransparency = 1
FPS.Text = "FPS: 60"
FPS.Font = Enum.Font.SourceSans
FPS.TextSize = 13
FPS.TextColor3 = Color3.fromRGB(150, 200, 255)
FPS.TextXAlignment = Enum.TextXAlignment.Right

-- Body
local Body = Instance.new("ScrollingFrame")
Body.Parent = MainFrame
Body.Position = UDim2.new(0, 0, 0, 55)
Body.Size = UDim2.new(1, 0, 1, -65)
Body.BackgroundTransparency = 1
Body.CanvasSize = UDim2.new(0, 0, 0, 560)
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = Color3.fromRGB(60, 80, 180)

-- Hàm tạo nút toggle
local function createToggle(y, icon, text, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Parent = Body
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = icon .. "  " .. text .. "  ❌"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(45, 45, 65)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = color or Color3.fromRGB(35, 55, 90)
            btn.Text = icon .. "  " .. text .. "  ✅"
            btn.TextColor3 = Color3.fromRGB(100, 255, 150)
            btn.UIStroke.Color = Color3.fromRGB(50, 150, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            btn.Text = icon .. "  " .. text .. "  ❌"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.UIStroke.Color = Color3.fromRGB(45, 45, 65)
        end
        onClick(state)
    end)
    return btn
end

-- Hàm tạo ô nhập thông số gọn gàng
local function createInputRow(y, labelText, defaultStr, onCommit)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = Body
    lbl.Position = UDim2.new(0.05, 0, 0, y + 1)
    lbl.Size = UDim2.new(0.4, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = Body
    box.Position = UDim2.new(0.48, 0, 0, y)
    box.Size = UDim2.new(0.24, 0, 0, 28)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = defaultStr
    box.Font = Enum.Font.SourceSans
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", box).Color = Color3.fromRGB(45, 45, 65)

    box.FocusLost:Connect(function()
        onCommit(box)
    end)
    return box
end

-- Khai báo trước hàm Auto Kill
local startAutoKill, stopAutoKill

-- Tạo các nút
local btnSpeed = createToggle(8, "🏃", "Tăng Tốc", Color3.fromRGB(35, 55, 90), function(s) isApplied = s end)
local btnFly = createToggle(52, "✈️", "Chế Độ Bay", Color3.fromRGB(35, 55, 90), function(s) isFlying = s end)
local btnNoclip = createToggle(96, "🔮", "Xuyên Tường", Color3.fromRGB(35, 55, 90), function(s) isNoclip = s end)
local btnESP = createToggle(140, "👁️", "ESP + Dây Địch", Color3.fromRGB(35, 55, 90), function(s) isESP = s end)
local btnAimbot = createToggle(184, "🎯", "Aimbot (FOV + 90%)", Color3.fromRGB(35, 55, 90), function(s) isAimbot = s end)
local btnAimHead = createToggle(228, "🧠", "Bám Đầu (Tắt = Thân)", Color3.fromRGB(35, 55, 90), function(s) isAimHead = s end)
local btnAutoKill = createToggle(272, "💀", "Auto Kill", Color3.fromRGB(180, 30, 30), function(s)
    isAutoKill = s
    if s then
        startAutoKill()
    else
        stopAutoKill()
    end
end)

-- Các ô nhập thông số
createInputRow(318, "🏃 Tốc Độ:", "50", function(box)
    local num = tonumber(box.Text)
    if num then speedValue = num else box.Text = tostring(speedValue) end
end)

createInputRow(352, "⬆️ Nhảy:", "50", function(box)
    local num = tonumber(box.Text)
    if num then jumpValue = num else box.Text = tostring(jumpValue) end
end)

createInputRow(386, "✈️ Tốc Bay:", "50", function(box)
    local num = tonumber(box.Text)
    if num then flySpeed = num else box.Text = tostring(flySpeed) end
end)

createInputRow(420, "🎯 FOV (px):", tostring(aimFOV), function(box)
    local num = tonumber(box.Text)
    if num and num >= 10 and num <= 1000 then
        aimFOV = num
    else
        box.Text = tostring(aimFOV)
    end
end)

createInputRow(454, "🎚️ Độ Aim (%):", "90", function(box)
    local num = tonumber(box.Text)
    if num and num >= 1 and num <= 100 then
        aimStrength = num / 100
    else
        box.Text = tostring(math.round(aimStrength * 100))
    end
end)

-- Nút đóng
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Body
CloseBtn.Position = UDim2.new(0.05, 0, 0, 492)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 32)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
CloseBtn.Text = "🔒 Ẩn Menu"
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", CloseBtn).Color = Color3.fromRGB(120, 60, 60)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Xử lý mở menu
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- === CORE FUNCTION ===
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if isApplied then
        hum.WalkSpeed = speedValue
        hum.UseJumpPower = true
        hum.JumpPower = jumpValue
    end

    if isNoclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- === HÀM KIỂM TRA KẺ ĐỊCH & TRẠNG THÁI HỢP LỆ ===
local function isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if player.Parent ~= Players then return false end

    local myTeam = LocalPlayer.Team
    local targetTeam = player.Team

    if myTeam and targetTeam and myTeam == targetTeam then
        return false
    end

    return true
end

local function getValidTargetParts(player)
    if not isEnemy(player) then return nil, nil, nil, nil end
    local char = player.Character
    if not char or not char.Parent or not char:IsDescendantOf(workspace) then return nil, nil, nil, nil end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hum or hum.Health <= 0 or not hrp or not hrp.Parent then
        return nil, nil, nil, nil
    end

    return char, hum, hrp, head
end

local function getAimPosition(char, hrp, head)
    if isAimHead and head and head.Parent then
        return head.Position
    end
    if hrp and hrp.Parent then
        return hrp.Position
    end
    if head and head.Parent then
        return head.Position
    end
    return nil
end

-- === ESP + SỢI DÂY (TRACERS) + TỰ ĐỘNG KHI HỒI SINH ===
local function createTracerLine()
    if typeof(Drawing) == "table" and typeof(Drawing.new) == "function" then
        local ok, line = pcall(function()
            local l = Drawing.new("Line")
            l.Visible = false
            l.Color = Color3.fromRGB(255, 60, 60)
            l.Thickness = 1.8
            l.Transparency = 0.85
            return l
        end)
        if ok and line then
            return line
        end
    end
    return nil
end

local function removeHighlight(player)
    if espHighlights[player] then
        pcall(function() espHighlights[player]:Destroy() end)
        espHighlights[player] = nil
    end
end

local function removeTracer(player)
    if espTracers[player] then
        pcall(function()
            espTracers[player].Visible = false
            espTracers[player]:Remove()
        end)
        espTracers[player] = nil
    end
end

local function removePlayerESP(player)
    removeHighlight(player)
    removeTracer(player)
end

local function ensureHighlight(player, char)
    local hl = espHighlights[player]
    if not hl or not hl.Parent or hl.Adornee ~= char then
        removeHighlight(player)
        local ok, newHl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = Color3.fromRGB(255, 50, 50)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.4
            h.OutlineTransparency = 0
            h.Adornee = char
            h.Parent = char
            return h
        end)
        if ok and newHl then
            espHighlights[player] = newHl
        end
    end
end

Players.PlayerRemoving:Connect(function(p)
    removePlayerESP(p)
end)

local function updateESP()
    local cam = workspace.CurrentCamera
    local currentPlayers = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            currentPlayers[p] = true
        end
    end

    for p, _ in pairs(espHighlights) do
        if not currentPlayers[p] or not isESP then
            removeHighlight(p)
        end
    end
    for p, _ in pairs(espTracers) do
        if not currentPlayers[p] or not isESP then
            removeTracer(p)
        end
    end

    if not isESP then return end

    local viewportSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local origin = Vector2.new(viewportSize.X / 2, viewportSize.Y)

    for player, _ in pairs(currentPlayers) do
        local char, _, hrp = getValidTargetParts(player)

        if char and hrp and cam then
            ensureHighlight(player, char)

            if not espTracers[player] then
                espTracers[player] = createTracerLine()
            end

            local line = espTracers[player]
            if line then
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                local validScreen = onScreen
                    and screenPos.Z > 0
                    and screenPos.X >= 0 and screenPos.X <= viewportSize.X
                    and screenPos.Y >= 0 and screenPos.Y <= viewportSize.Y

                if validScreen then
                    line.From = origin
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Color = Color3.fromRGB(255, 60, 60)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        else
            removeHighlight(player)
            if espTracers[player] then
                espTracers[player].Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- === FLY ===
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if isFlying and hrp then
        local cam = workspace.CurrentCamera
        if not flyBV or flyBV.Parent ~= hrp then
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        end
        if not flyBG or flyBG.Parent ~= hrp then
            flyBG = Instance.new("BodyGyro", hrp)
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.P = 9e4
        end

        flyBG.CFrame = cam.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        flyBV.Velocity = (moveDir.Magnitude > 0) and (moveDir.Unit * flySpeed) or Vector3.new(0, 0.1, 0)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end)

-- === VÒNG TRÒN FOV (DRAWING API) ===
local fovCircle = nil
if typeof(Drawing) == "table" and typeof(Drawing.new) == "function" then
    pcall(function()
        local c = Drawing.new("Circle")
        c.Visible = false
        c.Color = Color3.fromRGB(100, 180, 255)
        c.Thickness = 1.5
        c.NumSides = 64
        c.Filled = false
        c.Transparency = 0.75
        fovCircle = c
    end)
end

local function getFOVCenter(cam)
    local vp = cam.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

-- === CHỈ LẤY KẺ ĐỊCH NẰM BÊN TRONG TÂM VÒNG TRÒN FOV ===
local function getClosestEnemyInsideFOV()
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not cam or not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local center = getFOVCenter(cam)
    local closest = nil
    local minCenterDist = aimFOV

    for _, player in pairs(Players:GetPlayers()) do
        local targetChar, _, targetHrp, targetHead = getValidTargetParts(player)
        local checkPos = getAimPosition(targetChar, targetHrp, targetHead)
        if checkPos then
            local screenPos, onScreen = cam:WorldToViewportPoint(checkPos)
            if onScreen and screenPos.Z > 0 then
                local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if distFromCenter <= minCenterDist then
                    minCenterDist = distFromCenter
                    closest = player
                end
            end
        end
    end

    return closest
end

-- === HÀM LẤY KẺ ĐỊCH GẦN NHẤT (CHO AUTO KILL) ===
local function getClosestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closest = nil
    local minDist = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        local _, _, targetHrp = getValidTargetParts(player)
        if targetHrp then
            local dist = (targetHrp.Position - hrp.Position).Magnitude
            if dist < minDist and dist < 500 then
                minDist = dist
                closest = player
            end
        end
    end
    return closest
end

-- === HÀM AIM 90% (HỖ TRỢ BÁM ĐẦU HOẶC THÂN TRONG FOV) ===
local function aimAtEnemy()
    if not isAimbot then return end

    local target = getClosestEnemyInsideFOV()
    if not target then return end

    local targetChar, _, hrp, head = getValidTargetParts(target)
    local targetPos = getAimPosition(targetChar, hrp, head)

    if targetPos then
        local cam = workspace.CurrentCamera
        if cam then
            local currentCF = cam.CFrame
            local desiredCF = CFrame.lookAt(currentCF.Position, targetPos)
            local alpha = math.clamp(aimStrength, 0.01, 1)
            cam.CFrame = currentCF:Lerp(desiredCF, alpha)
        end
    end
end

-- === CẬP NHẬT FOV & AIMBOT KHI GIỮ CHUỘT TRÁI ===
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if fovCircle then
        if isAimbot and cam then
            fovCircle.Position = getFOVCenter(cam)
            fovCircle.Radius = aimFOV
            fovCircle.Color = isAimHead and Color3.fromRGB(255, 180, 70) or Color3.fromRGB(100, 180, 255)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    if isAimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        aimAtEnemy()
    end
end)

-- === AUTO KILL ===
local function moveToPosition(character, targetPos, stopDistance)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local distance = (targetPos - hrp.Position).Magnitude

    if distance <= stopDistance then
        return true
    end

    local moveDirection = (targetPos - hrp.Position).Unit
    local speed = flySpeed or 50

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = moveDirection * speed
    bv.Parent = hrp

    local startTime = tick()
    while isAutoKill and (tick() - startTime) < 3 do
        local currentDist = (targetPos - hrp.Position).Magnitude
        if currentDist <= stopDistance then
            bv:Destroy()
            return true
        end
        task.wait(0.05)
    end

    bv:Destroy()
    return false
end

local function simulateClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
end

local function autoKillLoop()
    while isAutoKill and LocalPlayer and LocalPlayer.Character do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not hrp then
            task.wait(0.5)
            continue
        end

        local target = getClosestEnemy()

        if target then
            local targetChar, _, targetHrp, targetHead = getValidTargetParts(target)
            if targetHrp then
                local targetPos = targetHrp.Position
                local distance = (targetPos - hrp.Position).Magnitude

                if distance > 15 then
                    local wasFlying = isFlying

                    if not wasFlying then
                        isFlying = true
                    end

                    moveToPosition(char, targetPos, 10)

                    if not wasFlying then
                        isFlying = false
                    end
                end

                local newDistance = (targetHrp.Position - hrp.Position).Magnitude

                if newDistance <= 20 then
                    local aimPos = getAimPosition(targetChar, targetHrp, targetHead) or targetHrp.Position
                    local cam = workspace.CurrentCamera
                    if cam and aimPos then
                        local currentCF = cam.CFrame
                        local desiredCF = CFrame.lookAt(currentCF.Position, aimPos)
                        cam.CFrame = currentCF:Lerp(desiredCF, math.clamp(aimStrength, 0.01, 1))
                    end

                    for i = 1, 8 do
                        if not isAutoKill then break end
                        simulateClick()
                        task.wait(0.1)
                    end
                end
            end
        else
            task.wait(0.5)
        end

        task.wait(0.1)
    end
end

startAutoKill = function()
    if autoKillCoroutine then
        coroutine.close(autoKillCoroutine)
        autoKillCoroutine = nil
    end

    isKilling = true
    autoKillCoroutine = coroutine.create(autoKillLoop)
    coroutine.resume(autoKillCoroutine)

    print("💀 Auto Kill đã được bật!")
end

stopAutoKill = function()
    isKilling = false
    isAutoKill = false
    if autoKillCoroutine then
        coroutine.close(autoKillCoroutine)
        autoKillCoroutine = nil
    end
    print("💀 Auto Kill đã được tắt!")
end

-- Update FPS
local fc, lu = 0, tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    local now = tick()
    if now - lu >= 0.5 then
        FPS.Text = "FPS: " .. math.round(fc / (now - lu))
        fc = 0
        lu = now
    end
end)

print("=== NhatPhi Admin Menu v7.7 - Premium Edition ===")
print("🧠 Đã thêm nút Bám Đầu (Tắt = Thân), giữ FOV + Aim 90%")
