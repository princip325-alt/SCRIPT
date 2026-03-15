-- ============================================================
--  BLOX FRUITS — Discord Notify Script (VERSÃO FINAL)
--  Execute no Delta Executor
-- ============================================================

repeat wait() until game:IsLoaded()

print("✅ Blox Fruits detectado! Carregando script principal...")

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

local autoClickActive = false
local bringMobActive = false
local voarActive = false
local liteActive = false
local pegarBausActive = false

setfpscap(120)

local function makeDraggable(dragHandle, targetFrame, frameW, frameH)
    local dragging = false
    local dragStartInput = nil
    local frameStartX = 0
    local frameStartY = 0
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartInput = input.Position
            local screen = workspace.CurrentCamera.ViewportSize
            local absPos = targetFrame.AbsolutePosition
            frameStartX = absPos.X
            frameStartY = absPos.Y
            targetFrame.Position = UDim2.new(0, frameStartX, 0, frameStartY)
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
            local delta = input.Position - dragStartInput
            local screen = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(frameStartX + delta.X, 0, screen.X - frameW)
            local newY = math.clamp(frameStartY + delta.Y, 0, screen.Y - frameH)
            targetFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

local function makeDraggableHold(targetFrame, frameW, frameH, strokeRef)
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
                if strokeRef then
                    for i = 1, 3 do
                        strokeRef.Thickness = 4
                        task.wait(0.1)
                        strokeRef.Thickness = 2
                        task.wait(0.1)
                    end
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if holdTimer then task.cancel(holdTimer) holdTimer = nil end
                    dragging = false
                    holdReady = false
                    dragStartInput = nil
                    frameStartPos = nil
                    if strokeRef then strokeRef.Thickness = 2 end
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
senhaTitulo.Text = "👑 Celestial Hub X 👑"
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

local pinReal = ""
senhaInput:GetPropertyChangedSignal("Text"):Connect(function()
    local novo = senhaInput.Text
    if #novo > #pinReal then
        local adicionado = string.sub(novo, #pinReal + 1)
        pinReal = pinReal .. adicionado
    elseif #novo < #pinReal then
        pinReal = string.sub(pinReal, 1, #novo)
    end
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

repeat task.wait(0.1) until senhaDesbloqueada

-- ============================================================
--  TELA DE BOAS-VINDAS
-- ============================================================
local bemVindoGui = Instance.new("Frame")
bemVindoGui.Size = UDim2.new(0, 300, 0, 140)
bemVindoGui.Position = UDim2.new(0.5, -150, 0.5, -70)
bemVindoGui.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
bemVindoGui.BorderSizePixel = 0
bemVindoGui.ZIndex = 20
bemVindoGui.Parent = screenGui
Instance.new("UICorner", bemVindoGui).CornerRadius = UDim.new(0, 16)

local bvStroke = Instance.new("UIStroke")
bvStroke.Color = Color3.fromRGB(80, 160, 230)
bvStroke.Thickness = 2
bvStroke.Parent = bemVindoGui

-- Emoji de coroa no topo
local bvCoroa = Instance.new("TextLabel")
bvCoroa.Size = UDim2.new(1, 0, 0, 36)
bvCoroa.Position = UDim2.new(0, 0, 0, 8)
bvCoroa.BackgroundTransparency = 1
bvCoroa.Text = "👑"
bvCoroa.TextScaled = true
bvCoroa.Font = Enum.Font.GothamBold
bvCoroa.ZIndex = 21
bvCoroa.Parent = bemVindoGui

-- Bem vindo SR ALLAN
local bvLinha1 = Instance.new("TextLabel")
bvLinha1.Size = UDim2.new(1, -20, 0, 30)
bvLinha1.Position = UDim2.new(0, 10, 0, 46)
bvLinha1.BackgroundTransparency = 1
bvLinha1.TextColor3 = Color3.fromRGB(80, 160, 230)
bvLinha1.Text = "Bem vindo SR ALLAN"
bvLinha1.TextScaled = true
bvLinha1.Font = Enum.Font.GothamBold
bvLinha1.ZIndex = 21
bvLinha1.Parent = bemVindoGui

-- Em que posso te ajudar hoje?
local bvLinha2 = Instance.new("TextLabel")
bvLinha2.Size = UDim2.new(1, -20, 0, 26)
bvLinha2.Position = UDim2.new(0, 10, 0, 78)
bvLinha2.BackgroundTransparency = 1
bvLinha2.TextColor3 = Color3.fromRGB(200, 200, 200)
bvLinha2.Text = "Em que posso te ajudar hoje?"
bvLinha2.TextScaled = true
bvLinha2.Font = Enum.Font.GothamBold
bvLinha2.ZIndex = 21
bvLinha2.Parent = bemVindoGui

-- Barra de progresso do timer
local bvBarBg = Instance.new("Frame")
bvBarBg.Size = UDim2.new(0.85, 0, 0, 5)
bvBarBg.Position = UDim2.new(0.075, 0, 1, -14)
bvBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bvBarBg.BorderSizePixel = 0
bvBarBg.ZIndex = 21
bvBarBg.Parent = bemVindoGui
Instance.new("UICorner", bvBarBg).CornerRadius = UDim.new(1, 0)

local bvBarFill = Instance.new("Frame")
bvBarFill.Size = UDim2.new(1, 0, 1, 0)
bvBarFill.BackgroundColor3 = Color3.fromRGB(80, 160, 230)
bvBarFill.BorderSizePixel = 0
bvBarFill.ZIndex = 22
bvBarFill.Parent = bvBarBg
Instance.new("UICorner", bvBarFill).CornerRadius = UDim.new(1, 0)

-- Animação RGB na borda da tela de boas-vindas
local bvHue = 0
local bvRgbConn = RunService.Heartbeat:Connect(function(dt)
    bvHue = (bvHue + dt * 0.5) % 1
    bvStroke.Color = Color3.fromHSV(bvHue, 1, 1)
end)

-- Botão X para fechar
local bvFechar = Instance.new("TextButton")
bvFechar.Size = UDim2.new(0, 24, 0, 24)
bvFechar.Position = UDim2.new(1, -30, 0, 6)
bvFechar.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
bvFechar.BorderSizePixel = 0
bvFechar.Text = "X"
bvFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
bvFechar.TextScaled = true
bvFechar.Font = Enum.Font.GothamBold
bvFechar.ZIndex = 23
bvFechar.Parent = bemVindoGui
Instance.new("UICorner", bvFechar).CornerRadius = UDim.new(0, 6)

bvFechar.MouseButton1Click:Connect(function()
    bvRgbConn:Disconnect()
    bemVindoGui:Destroy()
end)

-- Barra diminui em 3 segundos e some
task.spawn(function()
    local duracao = 10
    local intervalo = 0.05
    local passos = duracao / intervalo
    for i = passos, 0, -1 do
        if not bemVindoGui or not bemVindoGui.Parent then break end
        bvBarFill.Size = UDim2.new(i / passos, 0, 1, 0)
        task.wait(intervalo)
    end
    bvRgbConn:Disconnect()
    if bemVindoGui and bemVindoGui.Parent then
        bemVindoGui:Destroy()
    end
end)

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
local BTN_W = 100
local BTN_H = 42
local PAD_X = 8
local PAD_Y = 5
local START_Y = 30

local FRAME_W = PAD_X + 3 * (BTN_W + PAD_X)
local FRAME_H = START_Y + 4 * (BTN_H + PAD_Y) + PAD_Y

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
frame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
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
title.Text = "👑 Celestial Hub X 👑"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Active = true
title.AutoButtonColor = false
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

-- ============================================================
--  BOTÃO MINIMIZADO
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

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Color = Color3.fromRGB(255, 0, 0)
rgbStroke.Thickness = 2
rgbStroke.Parent = miniFrame

local miniBtn2 = Instance.new("TextButton")
miniBtn2.Size = UDim2.new(1, 0, 1, 0)
miniBtn2.BackgroundTransparency = 1
miniBtn2.TextColor3 = Color3.fromRGB(255, 215, 0)
miniBtn2.Text = "👑"
miniBtn2.TextScaled = true
miniBtn2.Font = Enum.Font.GothamBold
miniBtn2.Active = true
miniBtn2.Parent = miniFrame

local rgbHue = 0
RunService.Heartbeat:Connect(function(dt)
    rgbHue = (rgbHue + dt * 0.5) % 1
    rgbStroke.Color = Color3.fromHSV(rgbHue, 1, 1)
end)

-- ============================================================
--  TELA DE AVISO
-- ============================================================
local avisoFrame = Instance.new("Frame")
avisoFrame.Size = UDim2.new(0, 300, 0, 150)
avisoFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
avisoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
avisoFrame.BorderSizePixel = 0
avisoFrame.Visible = false
avisoFrame.ZIndex = 30
avisoFrame.Parent = screenGui
Instance.new("UICorner", avisoFrame).CornerRadius = UDim.new(0, 15)

local avisoStroke = Instance.new("UIStroke")
avisoStroke.Color = Color3.fromRGB(255, 50, 50)
avisoStroke.Thickness = 2
avisoStroke.Parent = avisoFrame

local avisoTitulo = Instance.new("TextLabel")
avisoTitulo.Size = UDim2.new(1, -20, 0, 40)
avisoTitulo.Position = UDim2.new(0, 10, 0, 10)
avisoTitulo.BackgroundTransparency = 1
avisoTitulo.TextColor3 = Color3.fromRGB(255, 80, 80)
avisoTitulo.Text = "⚠️ ACESSO NEGADO ⚠️"
avisoTitulo.TextScaled = true
avisoTitulo.Font = Enum.Font.GothamBold
avisoTitulo.ZIndex = 31
avisoTitulo.Parent = avisoFrame

local avisoMensagem = Instance.new("TextLabel")
avisoMensagem.Size = UDim2.new(1, -20, 0, 60)
avisoMensagem.Position = UDim2.new(0, 10, 0, 50)
avisoMensagem.BackgroundTransparency = 1
avisoMensagem.TextColor3 = Color3.fromRGB(255, 255, 255)
avisoMensagem.Text = "VOCÊ NÃO TEM PERMISSÃO PARA DESATIVAR ESSE RECURSO!\nPOR FAVOR, ENTRE EM CONTATO COM UM ADM.\nOBRIGADO!"
avisoMensagem.TextScaled = true
avisoMensagem.Font = Enum.Font.Gotham
avisoMensagem.ZIndex = 31
avisoMensagem.Parent = avisoFrame

local avisoBtn = Instance.new("TextButton")
avisoBtn.Size = UDim2.new(0, 100, 0, 30)
avisoBtn.Position = UDim2.new(0.5, -50, 0, 115)
avisoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
avisoBtn.BorderSizePixel = 0
avisoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
avisoBtn.Text = "OK"
avisoBtn.TextScaled = true
avisoBtn.Font = Enum.Font.GothamBold
avisoBtn.ZIndex = 31
avisoBtn.Parent = avisoFrame
Instance.new("UICorner", avisoBtn).CornerRadius = UDim.new(0, 6)

avisoBtn.MouseButton1Click:Connect(function()
    avisoFrame.Visible = false
end)

-- ============================================================
--  CRIAR BOTÃO
-- ============================================================
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

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -4, 1, 0)
    lbl.Position = UDim2.new(0, 2, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = labelColor
    lbl.Text = labelText
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Parent = btn

    return btn, lbl
end

-- ============================================================
--  LINHA 0: Ativo | Puxar | Voar
-- ============================================================
local ativoBtn, ativoLabel = createBtn2(0, 0, Color3.fromRGB(0,255,80), "ATIVO", Color3.fromRGB(0,255,80))

local cadeadoLabel = Instance.new("TextLabel")
cadeadoLabel.Size = UDim2.new(1, 0, 1, 0)
cadeadoLabel.Position = UDim2.new(0, 0, 0, 0)
cadeadoLabel.BackgroundTransparency = 1
cadeadoLabel.Text = "🔒"
cadeadoLabel.TextScaled = true
cadeadoLabel.TextTransparency = 0.5
cadeadoLabel.TextXAlignment = Enum.TextXAlignment.Center
cadeadoLabel.TextYAlignment = Enum.TextYAlignment.Center
cadeadoLabel.Font = Enum.Font.GothamBold
cadeadoLabel.ZIndex = ativoBtn.ZIndex + 1
cadeadoLabel.Parent = ativoBtn

ativoLabel.Size = UDim2.new(1, 0, 1, 0)
ativoLabel.Position = UDim2.new(0, 0, 0, 0)

ativoBtn.MouseButton1Click:Connect(function()
    avisoFrame.Visible = true
    local som = Instance.new("Sound")
    som.SoundId = "rbxasset://sounds/action_fail.mp3"
    som.Volume = 0.5
    som.Parent = avisoFrame
    som:Play()
    task.wait(2)
    som:Destroy()
end)

local bringMobBtn, bringMobLabel = createBtn2(1, 0, Color3.fromRGB(255,50,50), "PUXAR", Color3.fromRGB(255,50,50))
bringMobBtn.MouseButton1Click:Connect(function()
    bringMobActive = not bringMobActive
    if bringMobActive then
        bringMobLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        bringMobLabel.Text = "PUXAR"
    else
        bringMobLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        bringMobLabel.Text = "PUXAR"
    end
end)

local voarBtn, voarLabel = createBtn2(2, 0, Color3.fromRGB(255,50,50), "VOAR", Color3.fromRGB(255,50,50))
voarBtn.MouseButton1Click:Connect(function()
    voarActive = not voarActive
    if voarActive then
        voarLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        voarLabel.Text = "VOAR"
    else
        voarLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        voarLabel.Text = "VOAR"
    end
end)

-- ============================================================
--  LINHA 1: Sem Afk | Fechar | Vaga
-- ============================================================
local autoClickBtn, autoClickLabel = createBtn2(0, 1, Color3.fromRGB(255,50,50), "SEM AFK", Color3.fromRGB(255,50,50))
autoClickBtn.MouseButton1Click:Connect(function()
    autoClickActive = not autoClickActive
    if autoClickActive then
        autoClickLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        autoClickLabel.Text = "SEM AFK"
    else
        autoClickLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        autoClickLabel.Text = "SEM AFK"
    end
end)

local closeBtn, closeLabel = createBtn2(1, 1, Color3.fromRGB(255,50,50), "FECHAR", Color3.fromRGB(255,50,50))

local mostrarIlhasBtn, mostrarIlhasLabel = createBtn2(2, 1, Color3.fromRGB(255,185,0), "MOSTRAR ILHAS", Color3.fromRGB(255,185,0))

-- ============================================================
--  PAINEL DE ILHAS — DETECTA O MAR AUTOMATICAMENTE
-- ============================================================

-- Função para detectar qual mar o jogador está
local function getMarAtual()
    -- Tenta ler valor oficial do jogo
    local seaValue = RS:FindFirstChild("Sea") or RS:FindFirstChild("CurrentSea")
    if seaValue and seaValue:IsA("IntValue") then
        return seaValue.Value
    end
    -- Tenta pelo nome do workspace
    local wsName = string.lower(workspace.Name)
    if string.find(wsName, "sea3") or string.find(wsName, "third") then return 3 end
    if string.find(wsName, "sea2") or string.find(wsName, "second") then return 2 end
    if string.find(wsName, "sea1") or string.find(wsName, "first") then return 1 end
    -- Tenta pelo objeto "Sea" no workspace
    local seaObj = workspace:FindFirstChild("Sea") or workspace:FindFirstChild("ThirdSea")
        or workspace:FindFirstChild("SecondSea") or workspace:FindFirstChild("FirstSea")
    if seaObj then
        local n = string.lower(seaObj.Name)
        if string.find(n, "third") or string.find(n, "3") then return 3 end
        if string.find(n, "second") or string.find(n, "2") then return 2 end
        return 1
    end
    -- Última alternativa: verifica se ilhas do Sea 3 existem no workspace
    if workspace:FindFirstChild("Port Town", true)
        or workspace:FindFirstChild("Floating Turtle", true)
        or workspace:FindFirstChild("Tiki Outpost", true) then
        return 3
    end
    if workspace:FindFirstChild("Haunted Castle", true)
        or workspace:FindFirstChild("Dark Arena", true) then
        return 2
    end
    return 1
end

local TODAS_ILHAS = {
    [1] = {
        { nome = "Ilha dos Bandidos",       pos = Vector3.new(977, 0, 1186)   },
        { nome = "Ilha das Espadas",        pos = Vector3.new(1463, 0, 1382)  },
        { nome = "Ilha do Naufrágio",       pos = Vector3.new(1506, 0, -338)  },
        { nome = "Ilha do Deserto",         pos = Vector3.new(2280, 0, -1300) },
        { nome = "Ilha Fria",               pos = Vector3.new(2600, 0, 1600)  },
        { nome = "Ilha dos Piratas",        pos = Vector3.new(3200, 0, 200)   },
        { nome = "Ilha dos Marines",        pos = Vector3.new(3900, 0, -400)  },
        { nome = "Ilha do Skylands",        pos = Vector3.new(4500, 0, 800)   },
    },
    [2] = {
        { nome = "Ilha das Flores",         pos = Vector3.new(-300, 0, 1200)  },
        { nome = "Ilha do Cogumelo",        pos = Vector3.new(-900, 0, 400)   },
        { nome = "Ilha do Gelo",            pos = Vector3.new(-1400, 0, -600) },
        { nome = "Ilha Quente",             pos = Vector3.new(-700, 0, 1800)  },
        { nome = "Ilha do Castelo",         pos = Vector3.new(-200, 0, -900)  },
        { nome = "Ilha do Dragão",          pos = Vector3.new(-1800, 0, 700)  },
        { nome = "Ilha dos Zumbis",         pos = Vector3.new(-500, 0, -1500) },
        { nome = "Ilha do Céu",             pos = Vector3.new(-1100, 0, 2000) },
    },
    [3] = {
        { nome = "Port Town",         pos = Vector3.new(-611, 0, 6436)    },
        { nome = "Hydra Island",      pos = Vector3.new(5298, 0, 344)     },
        { nome = "Great Tree",        pos = Vector3.new(3036, 0, -7150)   },
        { nome = "Sea of Treats",     pos = Vector3.new(-1506, 0, -10725) },
        { nome = "Castle on the Sea", pos = Vector3.new(-5437, 0, -2702)  },
        { nome = "Floating Turtle",   pos = Vector3.new(-12165, 0, -8455) },
        { nome = "Haunted Castle",    pos = Vector3.new(-9531, 0, 5763)   },
        { nome = "Tiki Outpost",      pos = Vector3.new(-16642, 0, 435)   },
        { nome = "Submerged Island",  pos = Vector3.new(10533, 0, 9940)   },
        { nome = "Sealed Cavern",     pos = Vector3.new(10437, 0, 9670)   },
    },
}

local ilhasFrame = Instance.new("Frame")
ilhasFrame.Size = UDim2.new(0, 220, 0, 400)
ilhasFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
ilhasFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ilhasFrame.BorderSizePixel = 0
ilhasFrame.Visible = false
ilhasFrame.ZIndex = 15
ilhasFrame.Parent = screenGui
Instance.new("UICorner", ilhasFrame).CornerRadius = UDim.new(0, 12)

local ilhasStroke = Instance.new("UIStroke")
ilhasStroke.Color = Color3.fromRGB(255, 185, 0)
ilhasStroke.Thickness = 2
ilhasStroke.Parent = ilhasFrame

-- Título (atualiza com o mar)
local ilhasTitulo = Instance.new("TextLabel")
ilhasTitulo.Size = UDim2.new(1, -40, 0, 30)
ilhasTitulo.Position = UDim2.new(0, 10, 0, 8)
ilhasTitulo.BackgroundTransparency = 1
ilhasTitulo.TextColor3 = Color3.fromRGB(255, 185, 0)
ilhasTitulo.Text = "🗺️ ILHAS DO SEA ?"
ilhasTitulo.TextScaled = true
ilhasTitulo.Font = Enum.Font.GothamBold
ilhasTitulo.ZIndex = 16
ilhasTitulo.Parent = ilhasFrame

-- Botão fechar X
local ilhasFechar = Instance.new("TextButton")
ilhasFechar.Size = UDim2.new(0, 24, 0, 24)
ilhasFechar.Position = UDim2.new(1, -30, 0, 7)
ilhasFechar.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
ilhasFechar.BorderSizePixel = 0
ilhasFechar.Text = "X"
ilhasFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
ilhasFechar.TextScaled = true
ilhasFechar.Font = Enum.Font.GothamBold
ilhasFechar.ZIndex = 17
ilhasFechar.Parent = ilhasFrame
Instance.new("UICorner", ilhasFechar).CornerRadius = UDim.new(0, 6)

ilhasFechar.MouseButton1Click:Connect(function()
    ilhasFrame.Visible = false
end)

-- ScrollingFrame para a lista
local ilhasScroll = Instance.new("ScrollingFrame")
ilhasScroll.Size = UDim2.new(1, -16, 1, -50)
ilhasScroll.Position = UDim2.new(0, 8, 0, 44)
ilhasScroll.BackgroundTransparency = 1
ilhasScroll.BorderSizePixel = 0
ilhasScroll.ScrollBarThickness = 4
ilhasScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 185, 0)
ilhasScroll.ZIndex = 16
ilhasScroll.Parent = ilhasFrame

local ilhasLayout = Instance.new("UIListLayout")
ilhasLayout.Padding = UDim.new(0, 4)
ilhasLayout.Parent = ilhasScroll

-- Função que popula a lista com as ilhas do mar atual
local todosItens = {}
local ilhaSelecionada = nil
local voandoParaIlha = false

local function popularIlhas()
    -- Limpa itens anteriores
    for _, v in ipairs(todosItens) do
        if v and v.Parent then v:Destroy() end
    end
    todosItens = {}

    local mar = getMarAtual()
    ilhasTitulo.Text = "🗺️ ILHAS DO SEA " .. mar
    local lista = TODAS_ILHAS[mar] or TODAS_ILHAS[3]

    for _, ilha in ipairs(lista) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 28)
        item.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        item.BorderSizePixel = 0
        item.TextColor3 = Color3.fromRGB(255, 255, 255)
        item.Text = "  " .. ilha.nome
        item.TextSize = 13
        item.Font = Enum.Font.GothamBold
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.AutoButtonColor = false
        item.ZIndex = 16
        item.Parent = ilhasScroll
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
        table.insert(todosItens, item)

        item.MouseButton1Click:Connect(function()
            ilhasFrame.Visible = false
            mostrarIlhasLabel.Text = ilha.nome
            mostrarIlhasLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
            ilhaSelecionada = ilha
            voandoParaIlha = true

            -- Captura destino fixo no momento do clique
            local destinoFixo = Vector3.new(ilha.pos.X, 80, ilha.pos.Z)

            task.spawn(function()
                local VELOCIDADE = 270 -- studs por segundo
                local bpIlha = nil
                local bgIlha = nil

                -- Desativa colisão do personagem para atravessar paredes
                local partesComColisao = {}
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if char then
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then
                                p.CanCollide = false
                                table.insert(partesComColisao, p)
                            end
                        end
                    end
                end)

                while voandoParaIlha and running do
                    pcall(function()
                        local char = Players.LocalPlayer.Character
                        if not char then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if not hrp or not hum then return end

                        -- Mantém colisão desativada durante o voo
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            end
                        end

                        local posAtual = hrp.Position
                        local dist2D = Vector2.new(posAtual.X - destinoFixo.X, posAtual.Z - destinoFixo.Z).Magnitude

                        if dist2D < 60 then
                            -- Chegou!
                            voandoParaIlha = false
                            -- Restaura colisão
                            for _, p in ipairs(char:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = true end
                            end
                            if bpIlha then bpIlha:Destroy() bpIlha = nil end
                            if bgIlha then bgIlha:Destroy() bgIlha = nil end
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                            mostrarIlhasLabel.Text = "MOSTRAR ILHAS"
                            mostrarIlhasLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
                            ilhaSelecionada = nil
                            return
                        end

                        -- Direção horizontal para a ilha
                        local dir = Vector3.new(
                            destinoFixo.X - posAtual.X,
                            0,
                            destinoFixo.Z - posAtual.Z
                        ).Unit

                        -- Move direto no CFrame sem física — sem tremor
                        local passo = VELOCIDADE * 0.05
                        hrp.CFrame = CFrame.new(
                            posAtual.X + dir.X * passo,
                            80,
                            posAtual.Z + dir.Z * passo
                        ) * CFrame.Angles(0, math.atan2(dir.X, dir.Z), 0)
                    end)
                    task.wait(0.05)
                end

                -- Cancelado — restaura colisão e limpa
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if not char then return end
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end
                    if bpIlha then bpIlha:Destroy() end
                    if bgIlha then bgIlha:Destroy() end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                end)
            end)
        end)
    end

    ilhasScroll.CanvasSize = UDim2.new(0, 0, 0, #lista * 32)
end

mostrarIlhasBtn.MouseButton1Click:Connect(function()
    if voandoParaIlha then
        -- Cancela o voo
        voandoParaIlha = false
        mostrarIlhasLabel.Text = "MOSTRAR ILHAS"
        mostrarIlhasLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
        ilhaSelecionada = nil
    else
        -- Atualiza lista com o mar atual e abre
        popularIlhas()
        ilhasFrame.Visible = not ilhasFrame.Visible
    end
end)

-- ============================================================
--  LINHA 2: Lite | Vaga | Vaga
-- ============================================================
local liteBtn, liteLabel = createBtn2(0, 2, Color3.fromRGB(255,50,50), "MODO LITE", Color3.fromRGB(255,50,50))
liteBtn.MouseButton1Click:Connect(function()
    liteActive = not liteActive
    if liteActive then
        liteLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        liteLabel.Text = "MODO LITE"
    else
        liteLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        liteLabel.Text = "MODO LITE"
    end
    task.spawn(function() applyLiteMode(liteActive) end)
end)
local pegarBausBtn, pegarBausLabel = createBtn2(1, 2, Color3.fromRGB(255,50,50), "PEGAR BAUS", Color3.fromRGB(255,50,50))
pegarBausBtn.MouseButton1Click:Connect(function()
    pegarBausActive = not pegarBausActive
    if pegarBausActive then
        pegarBausLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        pegarBausLabel.Text = "PEGAR BAUS"
    else
        pegarBausLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        pegarBausLabel.Text = "PEGAR BAUS"
    end
end)
local serverHopBtn, serverHopLabel = createBtn2(2, 2, Color3.fromRGB(255,50,50), "SERVER HOP", Color3.fromRGB(255,50,50))
serverHopBtn.MouseButton1Click:Connect(function()
    -- Muda cor para indicar que está trocando
    serverHopLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    serverHopLabel.Text = "TROCANDO"
    task.wait(0.5)
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId, Players.LocalPlayer)
    end)
    -- Se falhar, volta ao normal
    task.wait(3)
    serverHopLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    serverHopLabel.Text = "SERVER HOP"
end)

-- ============================================================
--  LINHA 3: Vaga | Vaga | Vaga
-- ============================================================
createBtn2(0, 3, Color3.fromRGB(50,50,50), "VAGA", Color3.fromRGB(80,80,80))
createBtn2(1, 3, Color3.fromRGB(50,50,50), "VAGA", Color3.fromRGB(80,80,80))
createBtn2(2, 3, Color3.fromRGB(50,50,50), "VAGA", Color3.fromRGB(80,80,80))

-- ============================================================
--  TELA DE CONFIRMAÇÃO (FECHAR)
-- ============================================================
local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.new(0, 160, 0, 90)
confirmFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
confirmFrame.BorderSizePixel = 0
confirmFrame.Visible = false
confirmFrame.ZIndex = 10
confirmFrame.Parent = screenGui
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 10)
local cfStroke = Instance.new("UIStroke", confirmFrame)
cfStroke.Color = Color3.fromRGB(255, 50, 50)
cfStroke.Thickness = 1.5

local cfTitle = Instance.new("TextLabel")
cfTitle.Size = UDim2.new(1, -10, 0, 30)
cfTitle.Position = UDim2.new(0, 5, 0, 5)
cfTitle.BackgroundTransparency = 1
cfTitle.Text = "Tem certeza que quer fechar?"
cfTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cfTitle.TextScaled = true
cfTitle.Font = Enum.Font.GothamBold
cfTitle.ZIndex = 10
cfTitle.Parent = confirmFrame

local cfSim = Instance.new("TextButton")
cfSim.Size = UDim2.new(0, 65, 0, 28)
cfSim.Position = UDim2.new(0, 8, 0, 52)
cfSim.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
cfSim.BorderSizePixel = 0
cfSim.Text = "Sim"
cfSim.TextColor3 = Color3.fromRGB(255, 255, 255)
cfSim.TextScaled = true
cfSim.Font = Enum.Font.GothamBold
cfSim.ZIndex = 10
cfSim.Parent = confirmFrame
Instance.new("UICorner", cfSim).CornerRadius = UDim.new(0, 6)

local cfNao = Instance.new("TextButton")
cfNao.Size = UDim2.new(0, 65, 0, 28)
cfNao.Position = UDim2.new(0, 84, 0, 52)
cfNao.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
cfNao.BorderSizePixel = 0
cfNao.Text = "Nao"
cfNao.TextColor3 = Color3.fromRGB(255, 255, 255)
cfNao.TextScaled = true
cfNao.Font = Enum.Font.GothamBold
cfNao.ZIndex = 10
cfNao.Parent = confirmFrame
Instance.new("UICorner", cfNao).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    local screen = workspace.CurrentCamera.ViewportSize
    confirmFrame.Position = UDim2.new(0, screen.X/2 - 80, 0, screen.Y/2 - 45)
    confirmFrame.Visible = true
end)

cfSim.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    running = false
    task.wait(0.3)
    screenGui:Destroy()
end)

cfNao.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
end)

-- ============================================================
--  MINIMIZAR / RESTAURAR
-- ============================================================
local function toggleMinimize()
    minimized = not minimized
    if not minimized then
        frame.Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2)
    end
    frame.Visible = not minimized
end

miniBtn2.MouseButton1Click:Connect(toggleMinimize)
makeDraggable(title, frame, FRAME_W, FRAME_H)
makeDraggableHold(miniFrame, 25, 25, rgbStroke)

-- ============================================================
--  FUNÇÃO DE ENVIO
-- ============================================================
local lastWebhookTime = 0
local WEBHOOK_COOLDOWN = 2

local function sendWebhook(webhookUrl, wTitle, emoji, color)
    if not enabled then return end
    local currentTime = tick()
    if currentTime - lastWebhookTime < WEBHOOK_COOLDOWN then
        task.wait(WEBHOOK_COOLDOWN - (currentTime - lastWebhookTime))
    end
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
    if success then
        print("[OK] '" .. wTitle .. "' enviado!")
        lastWebhookTime = tick()
    else
        warn("[ERRO] '" .. wTitle .. "': " .. tostring(err))
    end
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
--  ANTI AFK
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
--  BRING MOB
-- ============================================================
task.spawn(function()
    local DETECT_RANGE = 500
    local LOCK_DIST    = 14

    local function deveIgnorar(obj)
        if obj:FindFirstChildOfClass("Dialog") then return true end
        if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return true end
        for _, v in ipairs(obj:GetDescendants()) do
            if v:IsA("Dialog") or v:IsA("ProximityPrompt") then return true end
        end

        local nome = string.lower(obj.Name)
        local palavras = {
            "quest","giver","dealer","vendedor","missao","missão",
            "shop","merchant","trader","spawn","npc","loja",
            "definir","ponto","inicial","set ","point",
            "boat","ship","barcos","barco","luxury","luxo",
            "fruit","blox","sword","weapon","arma",
            "gacha","cousin","upgrade","ferreiro","blacksmith",
            "advanced","vivid","revendedor","negociante",
            "master","teacher","mestre","professor","instrutor",
            "ability","habilidade","trainer","treinador",
            "arowe","bartilo","swan","chompy","totto","yukora",
            "experimented","experim","citizen","bandit","home",
            "tiki","farmer","barista","fisherman","pescador",
            "mysterious","misterios","plokster","lunoven",
            "tacomura","phoeyu","sharkman","artemetic","artemetico",
            "alchemist","alquimista","uzoth","lucien","erina",
            "trevor","sabi","gerente","nerd","cliente","mordomo",
            "rip_indra","indra","yoshi","hasan","parlus",
            "shafi","espiao","espião","relíquia","reliquia",
            "santuário","santuario","observador","antigo",
            "capitão","capitao","detetive","militar",
            "editor","aura","reward","recompensa","titulo","título",
            "despertar","awakening","honor","honra",
            "refinador","bugiganga","entrega","namorados",
            "inventor","tesouros","scientist","cientista",
            "skeleton","esqueleto","ghostly","fantasma",
            "tombstone","lapide","lápide","strange","estranha",
            "sick","doente","hungry","faminto","horned","chifre",
            "force","força","ancient","antigo","monk","monge",
            "hero","heroi","herói","crypt","cripta",
            "dragon","dragão","dojo","mago","sage","sabio","sábio",
            "hunter","caçador","cacador","elite","spy","spies",
            "shipwright","naval","underwater","submarino",
            "worker","trabalhador","removal","remov",
            "administrator","administrador","perro","guashiem",
            "rodolfo","illicit","ilicito","ilícito",
            "king","rei","death","morte","machine","maquina",
            "drip","gotejamento","candy","doce","artisan","artesao",
            "military","detective","strange","esquisito",
            -- ADICIONADO: NPCs da Marinha que não devem ser puxados
            "recrutador","recruta","marinha","marine","recruit","pirata","pirate","tort","titles","specialist","titulo","títulos",
        }
        for _, p in ipairs(palavras) do
            if string.find(nome, p) then return true end
        end
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("BillboardGui") then
                local hasLevel = false
                for _, lbl in ipairs(v:GetDescendants()) do
                    if lbl:IsA("TextLabel") and string.find(lbl.Text, "%[Lv") then
                        hasLevel = true
                        break
                    end
                end
                if not hasLevel then return true end
            end
            if v:IsA("Highlight") then
                local fc = v.FillColor
                local oc = v.OutlineColor
                if (fc.G > 0.4 and fc.R < 0.4) or (oc.G > 0.4 and oc.R < 0.4) then
                    return true
                end
            end
            if v:IsA("SelectionBox") then
                local c = v.Color3
                if c.G > 0.4 and c.R < 0.4 then
                    return true
                end
            end
        end
        return false
    end

    while running do
        if bringMobActive then
            pcall(function()
                local player = Players.LocalPlayer
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local stackPos
                if voarActive then
                    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0))
                    local groundY = ray and ray.Position.Y or (hrp.Position.Y - 55)
                    stackPos = Vector3.new(hrp.Position.X, groundY + 3, hrp.Position.Z)
                else
                    local lookDir = hrp.CFrame.LookVector
                    local sp = hrp.Position + lookDir * LOCK_DIST
                    stackPos = Vector3.new(sp.X, hrp.Position.Y, sp.Z)
                end

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= char then
                        local enemyHRP = obj:FindFirstChild("HumanoidRootPart")
                        local humanoid = obj:FindFirstChildOfClass("Humanoid")
                        local estaVivo = humanoid
                            and humanoid.Health > 0
                            and humanoid.MaxHealth > 0
                            and humanoid:GetState() ~= Enum.HumanoidStateType.Dead

                        if enemyHRP and estaVivo
                            and not deveIgnorar(obj)
                            and not Players:GetPlayerFromCharacter(obj) then
                            local dist = (enemyHRP.Position - hrp.Position).Magnitude
                            if dist <= DETECT_RANGE then
                                enemyHRP.CFrame = CFrame.new(stackPos)
                                    * CFrame.Angles(0, math.pi, 0)
                                pcall(function() humanoid.WalkSpeed = 0 end)
                                pcall(function() humanoid.JumpPower = 0 end)
                                pcall(function() humanoid.AutoRotate = false end)
                            end
                        end
                    end
                end
            end)
            task.wait(0.08)
        else
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if hum then
                            pcall(function() hum.WalkSpeed = 16 end)
                            pcall(function() hum.JumpPower = 50 end)
                            pcall(function() hum.AutoRotate = true end)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end
end)

-- ============================================================
--  VOAR
-- ============================================================
task.spawn(function()
    local bodyGyro = nil
    local bodyPos = nil
    local voarAnterior = false

    while running do
        if voarActive then
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                if not bodyGyro or not bodyGyro.Parent then
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bodyGyro.P = 9999
                    bodyGyro.D = 100
                    bodyGyro.CFrame = CFrame.new(hrp.Position)
                    bodyGyro.Parent = hrp
                end

                if not bodyPos or not bodyPos.Parent then
                    bodyPos = Instance.new("BodyPosition")
                    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyPos.P = 9999
                    bodyPos.D = 1000
                    bodyPos.Parent = hrp
                end

                -- Sobe reto para cima
                bodyPos.Position = Vector3.new(hrp.Position.X, hrp.Position.Y + 25, hrp.Position.Z)
                bodyGyro.CFrame = CFrame.new(hrp.Position)
            end)
            voarAnterior = true
            task.wait(0.05)
        else
            -- Só limpa quando acabou de desligar
            if voarAnterior then
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if bodyPos then bodyPos:Destroy() bodyPos = nil end
                    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                end)
                voarAnterior = false
            end
            task.wait(0.1)
        end
    end
end)

-- ============================================================
--  PEGAR BAÚS — COM CONTADOR E 3S ENTRE BAÚS
-- ============================================================

-- Label contador de baús
local bauContadorLabel = Instance.new("TextLabel")
bauContadorLabel.Size = UDim2.new(1, 0, 1, 0)
bauContadorLabel.Position = UDim2.new(0, 0, 0, 0)
bauContadorLabel.BackgroundTransparency = 1
bauContadorLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
bauContadorLabel.Text = ""
bauContadorLabel.TextSize = 10
bauContadorLabel.Font = Enum.Font.GothamBold
bauContadorLabel.ZIndex = pegarBausBtn.ZIndex + 1
bauContadorLabel.Parent = pegarBausBtn

task.spawn(function()
    local totalPegos = 0

    while running do
        if pegarBausActive then
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Procura baús em todo workspace
                local baus = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = obj.Name
                        if n == "Silver" or n == "Gold"
                            or n == "Diamond" or n == "Fragment"
                            or n == "Chest1" or n == "Chest2" or n == "Chest3"
                            or n == "SilverLock" or n == "GoldLock"
                            or n == "DiamondLock" or n == "Treasure" then
                            pcall(function()
                                table.insert(baus, {obj = obj, pos = obj.Position})
                            end)
                        end
                    end
                end

                if #baus == 0 then
                    pegarBausLabel.Text = "SEM BAUS"
                    bauContadorLabel.Text = ""
                    task.wait(5)
                    pegarBausLabel.Text = "PEGAR BAUS"
                    return
                end

                -- Ordena por distância
                table.sort(baus, function(a, b)
                    local ok1, da = pcall(function() return (a.pos - hrp.Position).Magnitude end)
                    local ok2, db = pcall(function() return (b.pos - hrp.Position).Magnitude end)
                    if ok1 and ok2 then return da < db end
                    return false
                end)

                -- Pega cada baú
                for i, bau in ipairs(baus) do
                    if not pegarBausActive then break end
                    if not bau.obj or not bau.obj.Parent then continue end

                    pegarBausLabel.Text = "PEGANDO..."
                    bauContadorLabel.Text = ""

                    -- Teleporta para o baú
                    pcall(function()
                        char = Players.LocalPlayer.Character
                        if not char then return end
                        hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        hrp.CFrame = CFrame.new(bau.obj.Position + Vector3.new(0, 3, 0))
                    end)

                    task.wait(0.5)

                    -- Abre o baú
                    pcall(function()
                        char = Players.LocalPlayer.Character
                        if not char then return end
                        hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        firetouchinterest(hrp, bau.obj, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, bau.obj, 1)
                    end)

                    totalPegos = totalPegos + 1

                    -- Contador regressivo de 3 segundos
                    for s = 3, 1, -1 do
                        if not pegarBausActive then break end
                        bauContadorLabel.Text = "Prox: " .. s .. "s"
                        task.wait(1)
                    end
                end
            end)
            task.wait(1)
        else
            totalPegos = 0
            pegarBausLabel.Text = "PEGAR BAUS"
            bauContadorLabel.Text = ""
            task.wait(0.5)
        end
    end
end)

-- ============================================================
--  LOOP PRINCIPAL DE DETECÇÃO
-- ============================================================
print("👑 BF Notify - VERSÃO FINAL! FPS: 120")

while running do
    pcall(checkMirage)
    pcall(checkPrehistoric)
    pcall(checkFullMoon)
    pcall(checkBosses)
    pcall(checkLegendarySword)
    pcall(checkHaki)
    task.wait(5)
end
