-- ============================================================
--  BLOX FRUITS — Discord Notify Script
--  Execute no Delta Executor
-- ============================================================

local WEBHOOKS = {
    boss        = "https://discord.com/api/webhooks/1479587891393990767/KHDJG4kVU72wSoHcqogXB-pd4e3ywx8vKnIgtLuvIeVyxH4WSF18b6DPU3VvQnuB7P77",
    full_moon   = "https://discord.com/api/webhooks/1479588313609273625/JYkXbAQNwXbknI2WNHyoCgUvDqkswDNE50Dbp3rwbKcWpqLlz1u-pvZy-SAZKADaePP0",
    haki        = "https://discord.com/api/webhooks/1479588709870604448/9R7G6x3oDlH9N3vbNj70F411qyg3yrA7dh4MD30czt670qfQnS8rIhEL8L1G3vfYTvTl",
    legendary   = "https://discord.com/api/webhooks/1479589180064530573/YBMVQB9d687nhlzIVtMnaYsF6rduT8TTuicNRFFdYWydD-dqv8AzP4RIUL-bLx5FoFyC",
    mirage      = "https://discord.com/api/webhooks/1479589521916952576/lEOQGxoDcBLS4iHB1u7TNjI1UwhQG1nT--8CM_Y0GJfrJ4Br7bkmiFLExZ11KCOHjWSJ",
    prehistoric = "https://discord.com/api/webhooks/1479589997106696293/Jlhoua_zGM4R6JmiDZfFKLknrHGXfjlltgvp-E3uOKFYPmWztXhrY7WeGGPEnqPDzLpo",
}

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local notified = {}
local running = true
local enabled = true
local liteMode = false
local minimized = true

-- ============================================================
--  120 FPS
-- ============================================================
setfpscap(120)

-- ============================================================
--  ARRASTAR — sem pulo no início
-- ============================================================
local function makeDraggable(dragHandle, targetFrame, frameW, frameH)
    local dragging = false
    local dragStartInput = nil
    local frameStartPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartInput = input.Position           -- posição do dedo ao tocar
            frameStartPos = targetFrame.Position      -- posição do frame ao tocar
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and dragStartInput and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            -- delta desde o início do toque (sem acúmulo)
            local delta = input.Position - dragStartInput
            local screen = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(frameStartPos.X.Offset + delta.X, 0, screen.X - frameW)
            local newY = math.clamp(frameStartPos.Y.Offset + delta.Y, 0, screen.Y - frameH)
            targetFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Arrastar com segurar 1 segundo (coroa)
local function makeDraggableHold(targetFrame, frameW, frameH)
    local dragging = false
    local holdTimer = nil
    local holdReady = false
    local dragStartInput = nil
    local frameStartPos = nil

    targetFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then

            holdReady = false
            holdTimer = task.delay(1, function()
                holdReady = true
                dragging = true
                dragStartInput = input.Position
                frameStartPos = targetFrame.Position
                -- Feedback visual: borda pisca
                for i = 1, 3 do
                    rgbStroke.Thickness = 4
                    task.wait(0.1)
                    rgbStroke.Thickness = 2
                    task.wait(0.1)
                end
            end)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if holdTimer then task.cancel(holdTimer) holdTimer = nil end
                    dragging = false
                    holdReady = false
                    dragStartInput = nil
                    frameStartPos = nil
                    rgbStroke.Thickness = 2
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and holdReady and dragStartInput and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = input.Position - dragStartInput
            local screen = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(frameStartPos.X.Offset + delta.X, 0, screen.X - frameW)
            local newY = math.clamp(frameStartPos.Y.Offset + delta.Y, 0, screen.Y - frameH)
            targetFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- ============================================================
--  GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BFNotifyGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

-- ============================================================
--  TELA DE SENHA
-- ============================================================
local SENHA_CORRETA = "159753"
local senhaDesbloqueada = false

local senhaGui = Instance.new("Frame")
senhaGui.Size = UDim2.new(0, 260, 0, 180)
senhaGui.Position = UDim2.new(0.5, -130, 0.5, -90)
senhaGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
senhaGui.BorderSizePixel = 0
senhaGui.ZIndex = 20
senhaGui.Parent = screenGui
Instance.new("UICorner", senhaGui).CornerRadius = UDim.new(0, 14)

local senhaStroke = Instance.new("UIStroke")
senhaStroke.Color = Color3.fromRGB(80, 160, 230)
senhaStroke.Thickness = 2
senhaStroke.Parent = senhaGui

local senhaTitulo = Instance.new("TextLabel")
senhaTitulo.Size = UDim2.new(1, 0, 0, 40)
senhaTitulo.Position = UDim2.new(0, 0, 0, 8)
senhaTitulo.BackgroundTransparency = 1
senhaTitulo.TextColor3 = Color3.fromRGB(80, 160, 230)
senhaTitulo.Text = "👑 SCRIPT DE UM VERDADEIRO ADM 👑"
senhaTitulo.TextScaled = true
senhaTitulo.Font = Enum.Font.GothamBold
senhaTitulo.ZIndex = 21
senhaTitulo.Parent = senhaGui

local senhaSubtitulo = Instance.new("TextLabel")
senhaSubtitulo.Size = UDim2.new(1, 0, 0, 25)
senhaSubtitulo.Position = UDim2.new(0, 0, 0, 48)
senhaSubtitulo.BackgroundTransparency = 1
senhaSubtitulo.TextColor3 = Color3.fromRGB(180, 180, 180)
senhaSubtitulo.Text = "🔒 Digite o PIN:"
senhaSubtitulo.TextScaled = true
senhaSubtitulo.Font = Enum.Font.GothamBold
senhaSubtitulo.ZIndex = 21
senhaSubtitulo.Parent = senhaGui

local senhaInput = Instance.new("TextBox")
senhaInput.Size = UDim2.new(0.8, 0, 0, 36)
senhaInput.Position = UDim2.new(0.1, 0, 0, 80)
senhaInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
senhaInput.BorderSizePixel = 0
senhaInput.TextColor3 = Color3.fromRGB(255, 255, 255)
senhaInput.PlaceholderText = "••••••"
senhaInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
senhaInput.Text = ""
senhaInput.TextScaled = true
senhaInput.Font = Enum.Font.GothamBold
senhaInput.ClearTextOnFocus = true
senhaInput.ZIndex = 21
senhaInput.Parent = senhaGui
Instance.new("UICorner", senhaInput).CornerRadius = UDim.new(0, 8)

-- Esconde o PIN real e mostra apenas *
local pinReal = ""
senhaInput:GetPropertyChangedSignal("Text"):Connect(function()
    local novo = senhaInput.Text
    if #novo > #pinReal then
        -- Adicionou caractere
        local adicionado = string.sub(novo, #pinReal + 1)
        pinReal = pinReal .. adicionado
    elseif #novo < #pinReal then
        -- Apagou caractere
        pinReal = string.sub(pinReal, 1, #novo)
    end
    -- Mostra só asteriscos
    senhaInput.Text = string.rep("*", #pinReal)
end)

local senhaStrokeInput = Instance.new("UIStroke")
senhaStrokeInput.Color = Color3.fromRGB(60, 60, 60)
senhaStrokeInput.Thickness = 1
senhaStrokeInput.Parent = senhaInput

local senhaBtn = Instance.new("TextButton")
senhaBtn.Size = UDim2.new(0.8, 0, 0, 36)
senhaBtn.Position = UDim2.new(0.1, 0, 0, 126)
senhaBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 230)
senhaBtn.BorderSizePixel = 0
senhaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
senhaBtn.Text = "ENTRAR"
senhaBtn.TextScaled = true
senhaBtn.Font = Enum.Font.GothamBold
senhaBtn.ZIndex = 21
senhaBtn.Parent = senhaGui
Instance.new("UICorner", senhaBtn).CornerRadius = UDim.new(0, 8)

local senhaErro = Instance.new("TextLabel")
senhaErro.Size = UDim2.new(1, 0, 0, 20)
senhaErro.Position = UDim2.new(0, 0, 1, 5)
senhaErro.BackgroundTransparency = 1
senhaErro.TextColor3 = Color3.fromRGB(255, 50, 50)
senhaErro.Text = ""
senhaErro.TextScaled = true
senhaErro.Font = Enum.Font.GothamBold
senhaErro.ZIndex = 21
senhaErro.Parent = senhaGui

local function tentarSenha()
    if pinReal == SENHA_CORRETA then
        senhaDesbloqueada = true
        senhaGui:Destroy()
    else
        senhaErro.Text = "❌ PIN incorreto! Fechando..."
        task.wait(1.5)
        screenGui:Destroy()
    end
end

senhaBtn.MouseButton1Click:Connect(tentarSenha)
senhaInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then tentarSenha() end
end)

-- Aguarda senha antes de continuar
repeat task.wait(0.1) until senhaDesbloqueada

-- ============================================================
--  CONTADOR DE PROGRESSO LITE
-- ============================================================
local progressGui = Instance.new("Frame")
progressGui.Size = UDim2.new(0, 260, 0, 100)
progressGui.Position = UDim2.new(0.5, -130, 0.4, 0)
progressGui.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
progressGui.BackgroundTransparency = 0.2
progressGui.BorderSizePixel = 0
progressGui.Visible = false
progressGui.ZIndex = 10
progressGui.Parent = screenGui
Instance.new("UICorner", progressGui).CornerRadius = UDim.new(0, 16)

local progressStroke = Instance.new("UIStroke")
progressStroke.Color = Color3.fromRGB(255, 185, 0)
progressStroke.Thickness = 2
progressStroke.Parent = progressGui

local progressTitle = Instance.new("TextLabel")
progressTitle.Size = UDim2.new(1, 0, 0.35, 0)
progressTitle.Position = UDim2.new(0, 0, 0.05, 0)
progressTitle.BackgroundTransparency = 1
progressTitle.TextColor3 = Color3.fromRGB(255, 185, 0)
progressTitle.Text = "⚡ Aplicando Modo Lite..."
progressTitle.TextScaled = true
progressTitle.Font = Enum.Font.GothamBold
progressTitle.ZIndex = 11
progressTitle.Parent = progressGui

local progressPercent = Instance.new("TextLabel")
progressPercent.Size = UDim2.new(1, 0, 0.5, 0)
progressPercent.Position = UDim2.new(0, 0, 0.45, 0)
progressPercent.BackgroundTransparency = 1
progressPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
progressPercent.Text = "0%"
progressPercent.TextScaled = true
progressPercent.Font = Enum.Font.GothamBold
progressPercent.ZIndex = 11
progressPercent.Parent = progressGui

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.85, 0, 0.12, 0)
barBg.Position = UDim2.new(0.075, 0, 0.84, 0)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.ZIndex = 11
barBg.Parent = progressGui
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 12
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

-- ============================================================
--  MODO LEVE COM PROGRESSO
-- ============================================================
local function applyLiteMode(active)
    progressGui.Visible = true
    progressPercent.Text = "0%"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    progressTitle.Text = active and "⚡ Aplicando Modo Lite..." or "🔄 Restaurando..."
    progressTitle.TextColor3 = active and Color3.fromRGB(255, 185, 0) or Color3.fromRGB(100, 200, 255)

    local descendants = workspace:GetDescendants()
    local total = #descendants
    local processed = 0

    for _, obj in ipairs(descendants) do
        if obj:IsA("BasePart") then
            obj.CastShadow = not active
            if active then obj.Material = Enum.Material.SmoothPlastic end
        end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = not active
        end
        processed = processed + 1
        if processed % 50 == 0 then
            local pct = math.floor((processed / total) * 100)
            progressPercent.Text = pct .. "%"
            barFill.Size = UDim2.new(pct / 100, 0, 1, 0)
            task.wait()
        end
    end

    Lighting.GlobalShadows = not active
    Lighting.FogEnd = active and 1000000 or 1000
    settings().Rendering.QualityLevel = active and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic

    progressPercent.Text = "100%"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    progressTitle.Text = active and "✅ Modo Lite Ativo!" or "✅ Restaurado!"
    progressTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
    task.wait(1.5)
    progressGui.Visible = false
end

-- ============================================================
--  FRAME PRINCIPAL
-- ============================================================
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 176)
frame.Position = UDim2.new(0, 10, 0.45, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = false
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 22)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(80, 160, 230)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "👑 SCRIPT DE UM VERDADEIRO ADM 👑"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Active = true
title.AutoButtonColor = false
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- Título sem botão minimizar


-- ============================================================
--  BOTÃO MINIMIZADO — 25x25 com coroa e borda RGB
-- ============================================================
local miniFrame = Instance.new("Frame")
miniFrame.Size = UDim2.new(0, 25, 0, 25)
miniFrame.Position = UDim2.new(0, 48, 0, 30)
miniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
miniFrame.BorderSizePixel = 0
miniFrame.Active = true
miniFrame.Visible = true
miniFrame.Parent = screenGui
Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 6)

-- Borda RGB animada
local rgbStroke = Instance.new("UIStroke")
rgbStroke.Color = Color3.fromRGB(255, 0, 0)
rgbStroke.Thickness = 2
rgbStroke.Parent = miniFrame

-- Emoji coroa
local miniBtn2 = Instance.new("TextButton")
miniBtn2.Size = UDim2.new(1, 0, 1, 0)
miniBtn2.BackgroundTransparency = 1
miniBtn2.TextColor3 = Color3.fromRGB(255, 215, 0)
miniBtn2.Text = "👑"
miniBtn2.TextScaled = true
miniBtn2.Font = Enum.Font.GothamBold
miniBtn2.Active = true
miniBtn2.Parent = miniFrame

-- ============================================================
--  ANIMAÇÃO RGB NA BORDA
-- ============================================================
local rgbHue = 0
RunService.Heartbeat:Connect(function(dt)
    rgbHue = (rgbHue + dt * 0.5) % 1
    rgbStroke.Color = Color3.fromHSV(rgbHue, 1, 1)
end)

-- ============================================================
--  CRIAR BOTÃO 2x2
-- ============================================================
-- Layout: col=0 esquerda, col=1 direita | row=0 cima, row=1 baixo
local BTN_W = 60
local BTN_H = 28
local PAD_X = 6
local PAD_Y = 5
local START_Y = 28

local function createBtn2(col, row, dotColor, labelText, labelColor)
    local x = PAD_X + col * (BTN_W + PAD_X)
    local y = START_Y + row * (BTN_H + PAD_Y)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Active = true
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 6, 0.5, -4)
    dot.BackgroundColor3 = dotColor
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, BTN_W - 20, 0, BTN_H)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = labelColor
    lbl.Text = labelText
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = btn

    return btn, dot, lbl
end

-- Linha 1: Ativo | Lite
-- Linha 2: AutoClick | BringMob
-- Linha 3: Fechar
local toggleBtn, toggleDot, toggleLabel = createBtn2(0, 0, Color3.fromRGB(0,255,80), "Ativo", Color3.fromRGB(0,255,80))
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        notified = {}
        toggleDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
        toggleLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        toggleLabel.Text = "Ativo"
    else
        toggleDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        toggleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        toggleLabel.Text = "Pausado"
    end
end)

local liteBtn, liteDot, liteLabel = createBtn2(1, 0, Color3.fromRGB(255,50,50), "Lite", Color3.fromRGB(255,50,50))
liteBtn.MouseButton1Click:Connect(function()
    liteMode = not liteMode
    task.spawn(function() applyLiteMode(liteMode) end)
    if liteMode then
        liteDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
        liteLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        liteLabel.Text = "Lite ON"
    else
        liteDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        liteLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        liteLabel.Text = "Lite"
    end
end)

-- Botão AutoClick — começa DESATIVADO
local autoClickActive = false
local autoClickBtn, autoClickDot, autoClickLabel = createBtn2(0, 1, Color3.fromRGB(255,50,50), "AutoClick", Color3.fromRGB(255,50,50))
autoClickBtn.MouseButton1Click:Connect(function()
    autoClickActive = not autoClickActive
    if autoClickActive then
        autoClickDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
        autoClickLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        autoClickLabel.Text = "AutoClick"
    else
        autoClickDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        autoClickLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        autoClickLabel.Text = "AutoClick"
    end
end)

-- Botão BringMob — começa DESATIVADO
local bringMobActive = false
local bringMobBtn, bringMobDot, bringMobLabel = createBtn2(1, 1, Color3.fromRGB(255,50,50), "BringMob", Color3.fromRGB(255,50,50))
bringMobBtn.MouseButton1Click:Connect(function()
    bringMobActive = not bringMobActive
    if bringMobActive then
        bringMobDot.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
        bringMobLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        bringMobLabel.Text = "BringMob"
    else
        bringMobDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        bringMobLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        bringMobLabel.Text = "BringMob"
    end
end)

local closeBtn, closeDot, closeLabel = createBtn2(0, 2, Color3.fromRGB(255,50,50), "Fechar", Color3.fromRGB(255,50,50))
closeBtn.MouseButton1Click:Connect(function()
    running = false
    task.wait(0.3)
    screenGui:Destroy()
end)

-- ============================================================
--  MINIMIZAR / RESTAURAR
-- ============================================================
local function toggleMinimize()
    minimized = not minimized
    if not minimized then
        -- Centraliza na tela ao abrir
        local screen = workspace.CurrentCamera.ViewportSize
        frame.Position = UDim2.new(0, screen.X/2 - 70, 0, screen.Y/2 - 100)
    end
    frame.Visible = not minimized
    -- coroa sempre visível, não esconde nunca
end

-- Apenas a coroa flutuante abre/fecha o painel
miniBtn2.MouseButton1Click:Connect(toggleMinimize)

-- Arrastar frame principal pelo título
makeDraggable(title, frame, 140, 176)
-- Arrastar coroa segurando 1 segundo
makeDraggableHold(miniFrame, 25, 25)

-- ============================================================
--  MOB LOCK — Silent Aim 100 studs
-- ============================================================
local MOB_RANGE = 100

local function getNearestEnemy()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest = nil
    local nearestDist = MOB_RANGE

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local objHrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and objHrp then
                -- Não atacar outros jogadores
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == obj then isPlayer = true break end
                end
                if not isPlayer then
                    local dist = (hrp.Position - objHrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = objHrp
                    end
                end
            end
        end
    end
    return nearest
end

-- Loop MobLock — trava câmera no inimigo mais próximo
task.spawn(function()
    while running do
        if mobLockActive then
            pcall(function()
                local target = getNearestEnemy()
                if target then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.1)
        end
    end
end)

-- ============================================================
--  FUNÇÃO DE ENVIO
-- ============================================================
local function sendWebhook(webhookUrl, wTitle, emoji, color)
    if not enabled then return end
    local jobId = game.JobId
    local players = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    local timeOfDay = Lighting.TimeOfDay
    local teleportScript = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", "' .. jobId .. '")'
    local data = {
        embeds = {{
            title = emoji .. " " .. wTitle,
            color = color,
            fields = {
                { name = "🏝️ Spawn :", value = "🟢", inline = true },
                { name = "⏰ Time Of Day :", value = timeOfDay, inline = true },
                { name = "👥 Players :", value = players, inline = true },
                { name = "🔑 Job-Id :", value = jobId, inline = false },
                { name = "📜 Script :", value = "```\n" .. teleportScript .. "\n```", inline = false },
            },
            footer = { text = "Blox Fruits Notify Bot" }
        }}
    }
    local jsonData = game:GetService("HttpService"):JSONEncode(data)
    local success, err = pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)
    if success then print("[OK] '" .. wTitle .. "' enviado!")
    else warn("[ERRO] '" .. wTitle .. "': " .. tostring(err)) end
end

-- ============================================================
--  DETECÇÕES
-- ============================================================
local function checkMirage()
    local mirage = workspace:FindFirstChild("<Mirage Island>")
    if mirage and not notified["mirage"] then
        notified["mirage"] = true
        sendWebhook(WEBHOOKS.mirage, "Maru Hub Mirage Notify", "🌮", 0x00BFFF)
    elseif not mirage then notified["mirage"] = false end
end

local function checkPrehistoric()
    local prehistoricWS = workspace:FindFirstChild("<Prehistoric Island>")
    local prehistoricRS = RS:FindFirstChild("<Prehistoric Island>")
    if (prehistoricWS or prehistoricRS) and not notified["prehistoric"] then
        notified["prehistoric"] = true
        sendWebhook(WEBHOOKS.prehistoric, "Prehistoric Island Ativa!", "🌋", 0x228B22)
    elseif not prehistoricWS and not prehistoricRS then
        notified["prehistoric"] = false
    end
end

local function checkFullMoon()
    local blueMoon = workspace:FindFirstChild("Full Moon", true)
        or workspace:FindFirstChild("FullMoon", true)
        or workspace:FindFirstChild("BlueMoonWisp", true)
        or workspace:FindFirstChild("MoonShrine", true)
    if blueMoon and not notified["full_moon"] then
        notified["full_moon"] = true
        sendWebhook(WEBHOOKS.full_moon, "Lua Cheia Ativa!", "🌑", 0xFFD700)
    elseif not blueMoon then notified["full_moon"] = false end
end

local BOSSES = {
    "Stone [Lv. 1550] [Boss]", "Longma [Lv. 2000] [Boss]",
    "Cake Queen [Lv. 2175] [Boss]", "Beautiful Pirate [Lv. 1950] [Boss]",
    "Kilo Admiral [Lv. 1750] [Boss]", "rip_indra",
    "Greybeard", "Darkbeard", "God of Destruction",
    "Island Empress", "Wandering Nightmare", "Longma", "Stone",
}

local function checkBosses()
    for _, bossName in ipairs(BOSSES) do
        local boss = workspace:FindFirstChild(bossName, true)
        local key = "boss_" .. bossName
        if boss and not notified[key] then
            notified[key] = true
            sendWebhook(WEBHOOKS.boss, "Boss Apareceu! - " .. bossName, "👻", 0xFF0000)
        elseif not boss then notified[key] = false end
    end
end

local function checkLegendarySword()
    local sword = workspace:FindFirstChild("Legendary Sword Dealer", true)
    if sword and not notified["legendary"] then
        notified["legendary"] = true
        sendWebhook(WEBHOOKS.legendary, "Espada Lendária Disponível!", "🤺", 0xFFAA00)
    elseif not sword then notified["legendary"] = false end
end

local lastHakiCheck = 0
local function checkHaki()
    local currentTime = tick()
    if currentTime - lastHakiCheck > 2700 then
        if lastHakiCheck > 0 then notified["haki"] = false end
        lastHakiCheck = currentTime
    end
    local hakiEvent = RS:FindFirstChild("HakiColor", true)
    if hakiEvent and not notified["haki"] then
        notified["haki"] = true
        sendWebhook(WEBHOOKS.haki, "Haki Colors Mudou!", "🎨", 0x800080)
    end
end

-- ============================================================
--  ANTI AFK — Auto Click 35ms (controlado pelo botão)
-- ============================================================
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    while running do
        if autoClickActive then
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.035)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            task.wait(0.035)
        else
            task.wait(0.1)
        end
    end
end)

-- ============================================================
--  BRING MOB — puxa inimigos até o jogador (100 studs)
-- ============================================================
task.spawn(function()
    local BRING_DISTANCE = 100
    while running do
        if bringMobActive then
            pcall(function()
                local player = Players.LocalPlayer
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if bringMobActive and obj:IsA("Model") and obj ~= char then
                        local enemyHRP = obj:FindFirstChild("HumanoidRootPart")
                        local humanoid = obj:FindFirstChildOfClass("Humanoid")
                        if enemyHRP and humanoid and humanoid.Health > 0 then
                            local dist = (enemyHRP.Position - hrp.Position).Magnitude
                            if dist <= BRING_DISTANCE then
                                -- Teletransporta o inimigo até o jogador
                                enemyHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        else
            task.wait(0.2)
        end
    end
end)

-- ============================================================
--  LOOP PRINCIPAL
-- ============================================================
print("👑 BF Notify ATIVO! FPS: 120")

while running do
    pcall(checkMirage)
    pcall(checkPrehistoric)
    pcall(checkFullMoon)
    pcall(checkBosses)
    pcall(checkLegendarySword)
    pcall(checkHaki)
    task.wait(5)
end
