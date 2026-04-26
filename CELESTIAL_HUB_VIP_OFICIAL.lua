-- ============================================================
--  BLOX FRUITS — Discord Notify Script (VERSÃO FINAL)
--  Execute no Delta Executor v2147483647.716 or Delta X [2147483647.0]
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
local SENHA_CORRETA = "5555"
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

-- Botão de fechar (X) na progressGui
local progressCloseBtn = Instance.new("TextButton")
progressCloseBtn.Size = UDim2.new(0, 30, 0, 30)
progressCloseBtn.Position = UDim2.new(1, -40, 0, 8)
progressCloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
progressCloseBtn.BorderSizePixel = 0
progressCloseBtn.Text = "❌"
progressCloseBtn.TextSize = 16
progressCloseBtn.Font = Enum.Font.GothamBold
progressCloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
progressCloseBtn.ZIndex = 13
progressCloseBtn.Parent = progressGui
Instance.new("UICorner", progressCloseBtn).CornerRadius = UDim.new(0, 6)
local progressCloseStroke = Instance.new("UIStroke", progressCloseBtn)
progressCloseStroke.Color = Color3.fromRGB(100, 50, 50)
progressCloseStroke.Thickness = 1.5

progressCloseBtn.MouseButton1Click:Connect(function()
    progressGui.Visible = false
end)

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
--  FRAME PRINCIPAL — ABAS ESQUERDA / CONTEÚDO DIREITA
-- ============================================================
local FRAME_W   = 420
local FRAME_H   = 320
local TAB_W     = 110
local TITLE_H   = 28

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
frame.Position = UDim2.new(0.5, -FRAME_W/2, 0, -10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = false
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(40, 40, 55)
frameStroke.Thickness = 1.5

-- Título no topo
local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, TITLE_H)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Text = "👑 Celestial Hub X 👑"
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.BorderSizePixel = 0
title.Active = true
title.AutoButtonColor = false
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Linha sob o título
local titleSep = Instance.new("Frame")
titleSep.Size = UDim2.new(1, 0, 0, 1)
titleSep.Position = UDim2.new(0, 0, 0, TITLE_H)
titleSep.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleSep.BorderSizePixel = 0
titleSep.Parent = frame

-- Coluna esquerda — ScrollingFrame para as abas
local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(0, TAB_W, 1, -TITLE_H - 1)
tabScroll.Position = UDim2.new(0, 0, 0, TITLE_H + 1)
tabScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 2
tabScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabScroll.ClipsDescendants = true
tabScroll.Parent = frame

local tabCol = tabScroll -- alias para compatibilidade

local tabLayout = Instance.new("UIListLayout")
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabScroll

-- Linha divisória vertical
local divLine = Instance.new("Frame")
divLine.Size = UDim2.new(0, 1, 1, -TITLE_H - 1)
divLine.Position = UDim2.new(0, TAB_W, 0, TITLE_H + 1)
divLine.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
divLine.BorderSizePixel = 0
divLine.Parent = frame

-- Coluna direita — ScrollingFrame para o conteúdo
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, -TAB_W - 1, 1, -TITLE_H - 1)
contentScroll.Position = UDim2.new(0, TAB_W + 1, 0, TITLE_H + 1)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroll.ClipsDescendants = true
contentScroll.Parent = frame

local contentCol = contentScroll -- alias para compatibilidade

-- Abas e painéis
local ABAS = {"🔎 STATUS", "🏠 Farming", "🎣 Auto Fishing", "⚔️ Quest ━ Items", "🌋 Volcano Dojo", "🌊 Sea Event", "👑 Raça V4", "🍒 Raid ━ Frutas", "🍏 Frutas ━ Ver Estoque", "📌 Teleportar", "👤 Pvp ━ Player", "🛒 Shop", "⚙️ Configurações", "👑 ADM"}
local abaAtiva = "🔎 STATUS"
local paineis = {}
local abaBtns = {}
local TAB_H = 44

local indicadores = {}

for i, nome in ipairs(ABAS) do
    -- Container da aba
    local abaContainer = Instance.new("Frame")
    abaContainer.Size = UDim2.new(1, 0, 0, TAB_H)
    abaContainer.BackgroundTransparency = 1
    abaContainer.BorderSizePixel = 0
    abaContainer.LayoutOrder = i
    abaContainer.Parent = tabScroll

    -- Botão da aba — fundo escuro arredondado igual Redz Hub
    local abaBtn = Instance.new("TextButton")
    abaBtn.Size = UDim2.new(1, -8, 0, TAB_H - 6)
    abaBtn.Position = UDim2.new(0, 4, 0, 3)
    abaBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    abaBtn.BackgroundTransparency = 0.2
    abaBtn.BorderSizePixel = 0
    abaBtn.Text = nome
    abaBtn.TextSize = 11
    abaBtn.Font = Enum.Font.GothamBold
    abaBtn.TextColor3 = Color3.fromRGB(130, 130, 150)
    abaBtn.TextWrapped = true
    abaBtn.TextXAlignment = Enum.TextXAlignment.Center
    abaBtn.Parent = abaContainer
    Instance.new("UICorner", abaBtn).CornerRadius = UDim.new(0, 8)
    abaBtns[nome] = abaBtn

    -- Traço roxo na lateral ESQUERDA (igual Redz Hub)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.55, 0)
    indicator.Position = UDim2.new(0, 0, 0.225, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 80, 220)
    indicator.BorderSizePixel = 0
    indicator.Visible = nome == abaAtiva
    indicator.Parent = abaBtn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    indicadores[nome] = indicator

    -- Painel conteúdo (direita)
    local painel = Instance.new("Frame")
    painel.Size = UDim2.new(1, 0, 1, 0)
    painel.BackgroundTransparency = 1
    painel.BorderSizePixel = 0
    painel.Visible = nome == abaAtiva
    painel.Parent = contentCol
    paineis[nome] = painel

    abaBtn.MouseButton1Click:Connect(function()
        abaAtiva = nome
        contentScroll.CanvasPosition = Vector2.new(0, 0)
        for _, n in ipairs(ABAS) do
            paineis[n].Visible = n == nome
            abaBtns[n].TextColor3 = n == nome
                and Color3.fromRGB(255, 255, 255)
                or Color3.fromRGB(130, 130, 150)
            abaBtns[n].BackgroundColor3 = n == nome
                and Color3.fromRGB(35, 32, 55)
                or Color3.fromRGB(22, 22, 30)
            abaBtns[n].BackgroundTransparency = n == nome and 0 or 0.2
            if indicadores[n] then
                indicadores[n].Visible = n == nome
            end
        end
    end)
end

-- Destaca aba inicial
abaBtns[abaAtiva].TextColor3 = Color3.fromRGB(255, 255, 255)
abaBtns[abaAtiva].BackgroundColor3 = Color3.fromRGB(35, 32, 55)
abaBtns[abaAtiva].BackgroundTransparency = 0

-- Faz o contentScroll crescer com o conteúdo dos painéis
local function atualizarScrollConteudo()
    local painel = paineis[abaAtiva]
    if not painel then return end
    -- Calcula altura total dos filhos
    local maxY = 0
    for _, c in ipairs(painel:GetChildren()) do
        if c:IsA("GuiObject") then
            local bottom = c.Position.Y.Offset + c.Size.Y.Offset
            if bottom > maxY then maxY = bottom end
        end
    end
    -- Só ativa scroll se conteúdo for maior que o frame
    if maxY > FRAME_H - TITLE_H - 10 then
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, maxY + 10)
    else
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end

-- Atualiza scroll ao trocar aba
for _, nome in ipairs(ABAS) do
    abaBtns[nome].MouseButton1Click:Connect(function()
        task.wait(0.05)
        atualizarScrollConteudo()
    end)
end

-- ============================================================
--  CRIAR ITEM — checkbox style
-- ============================================================
local ITEM_H   = 44
local ITEM_PAD = 6

local COR_OFF  = Color3.fromRGB(150, 150, 150)
local COR_ON   = Color3.fromRGB(0, 255, 80)
local COR_GOLD = Color3.fromRGB(255, 185, 0)

local function toggleBtn(btn, estado)
    -- Remove tudo que tiver dentro
    for _, child in ipairs(btn:GetChildren()) do
        if child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
            child:Destroy()
        end
    end
    
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "ToggleSwitch"
    toggleSwitch.Size = UDim2.new(0, 50, 0, 28)
    toggleSwitch.Position = UDim2.new(1, -58, 0.5, -14)
    toggleSwitch.BackgroundColor3 = estado and Color3.fromRGB(100, 180, 100) or Color3.fromRGB(150, 150, 150)
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.Parent = btn
    Instance.new("UICorner", toggleSwitch).CornerRadius = UDim.new(0, 14)
    
    local bolinha = Instance.new("Frame")
    bolinha.Name = "Bolinha"
    bolinha.Size = UDim2.new(0, 24, 0, 24)
    bolinha.Position = estado and UDim2.new(0, 24, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    bolinha.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bolinha.BorderSizePixel = 0
    bolinha.Parent = toggleSwitch
    Instance.new("UICorner", bolinha).CornerRadius = UDim.new(0, 12)
    
    -- Animação suave da bolinha
    local tweenInfo = TweenInfo.new(
        0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.InOut
    )
    local tween = TweenService:Create(bolinha, tweenInfo, {
        Position = estado and UDim2.new(0, 24, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    })
    tween:Play()
end

local function criarItem(painel, row, nomeTexto, corNome)
    local itemY = ITEM_PAD + row * (ITEM_H + ITEM_PAD)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -12, 0, ITEM_H)
    bg.Position = UDim2.new(0, 6, 0, itemY)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    bg.BorderSizePixel = 0
    bg.Parent = painel
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", bg).Color = Color3.fromRGB(38, 38, 52)

    local nomeLbl = Instance.new("TextLabel")
    nomeLbl.Size = UDim2.new(0.72, 0, 1, 0)
    nomeLbl.Position = UDim2.new(0, 10, 0, 0)
    nomeLbl.BackgroundTransparency = 1
    nomeLbl.TextColor3 = corNome or Color3.fromRGB(210, 210, 210)
    nomeLbl.Text = nomeTexto
    nomeLbl.TextSize = 15
    nomeLbl.Font = Enum.Font.GothamBold
    nomeLbl.TextXAlignment = Enum.TextXAlignment.Left
    nomeLbl.Parent = bg

    -- Checkbox quadrado
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, -38, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Active = true
    btn.Parent = bg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(55, 55, 70)
    s.Thickness = 1.5

    -- Checkmark (visto de confirmacao)
    local check = Instance.new("TextLabel")
    check.Name = "CheckMark"
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = COR_ON
    check.TextScaled = true
    check.Font = Enum.Font.GothamBold
    check.Visible = false
    check.Parent = btn

    return btn, nomeLbl
end

local function criarItemSimples(painel, row, nomeTexto, corNome)
    local itemY = ITEM_PAD + row * (ITEM_H + ITEM_PAD)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, ITEM_H)
    btn.Position = UDim2.new(0, 6, 0, itemY)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    btn.BorderSizePixel = 0
    btn.Text = nomeTexto
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = corNome or COR_OFF
    btn.Active = true
    btn.Parent = painel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(38, 38, 52)
    s.Thickness = 1
    return btn
end

-- ============================================================
--  ABA STATUS — Contador de tempo + stats
-- ============================================================
local scriptStartTime = tick()

-- Título Status
local statusTitulo = Instance.new("TextLabel")
statusTitulo.Size = UDim2.new(1, -12, 0, 30)
statusTitulo.Position = UDim2.new(0, 6, 0, 8)
statusTitulo.BackgroundTransparency = 1
statusTitulo.TextColor3 = Color3.fromRGB(255, 215, 0)
statusTitulo.Text = "⏱️ Tempo Ativo"
statusTitulo.TextSize = 15
statusTitulo.Font = Enum.Font.GothamBold
statusTitulo.TextXAlignment = Enum.TextXAlignment.Left
statusTitulo.Parent = paineis["🔎 STATUS"]

-- Card contador
local cardTempo = Instance.new("Frame")
cardTempo.Size = UDim2.new(1, -12, 0, 44)
cardTempo.Position = UDim2.new(0, 6, 0, 42)
cardTempo.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cardTempo.BorderSizePixel = 0
cardTempo.Parent = paineis["🔎 STATUS"]
Instance.new("UICorner", cardTempo).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cardTempo).Color = Color3.fromRGB(38, 38, 52)

local tempoNome = Instance.new("TextLabel")
tempoNome.Size = UDim2.new(0.5, 0, 1, 0)
tempoNome.Position = UDim2.new(0, 10, 0, 0)
tempoNome.BackgroundTransparency = 1
tempoNome.TextColor3 = Color3.fromRGB(180, 180, 180)
tempoNome.Text = "Tempo no servidor"
tempoNome.TextSize = 14
tempoNome.Font = Enum.Font.GothamBold
tempoNome.TextXAlignment = Enum.TextXAlignment.Left
tempoNome.Parent = cardTempo

local tempoValor = Instance.new("TextLabel")
tempoValor.Size = UDim2.new(0.45, 0, 1, 0)
tempoValor.Position = UDim2.new(0.53, 0, 0, 0)
tempoValor.BackgroundTransparency = 1
tempoValor.TextColor3 = Color3.fromRGB(0, 255, 80)
tempoValor.Text = "00:00:00"
tempoValor.TextSize = 15
tempoValor.Font = Enum.Font.GothamBold
tempoValor.TextXAlignment = Enum.TextXAlignment.Right
tempoValor.Parent = cardTempo

-- Card Players
local cardPlayers = Instance.new("Frame")
cardPlayers.Size = UDim2.new(1, -12, 0, 44)
cardPlayers.Position = UDim2.new(0, 6, 0, 92)
cardPlayers.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cardPlayers.BorderSizePixel = 0
cardPlayers.Parent = paineis["🔎 STATUS"]
Instance.new("UICorner", cardPlayers).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cardPlayers).Color = Color3.fromRGB(38, 38, 52)

local playersNome = Instance.new("TextLabel")
playersNome.Size = UDim2.new(0.5, 0, 1, 0)
playersNome.Position = UDim2.new(0, 10, 0, 0)
playersNome.BackgroundTransparency = 1
playersNome.TextColor3 = Color3.fromRGB(180, 180, 180)
playersNome.Text = "Jogadores no server"
playersNome.TextSize = 14
playersNome.Font = Enum.Font.GothamBold
playersNome.TextXAlignment = Enum.TextXAlignment.Left
playersNome.Parent = cardPlayers

local playersValor = Instance.new("TextLabel")
playersValor.Size = UDim2.new(0.45, 0, 1, 0)
playersValor.Position = UDim2.new(0.53, 0, 0, 0)
playersValor.BackgroundTransparency = 1
playersValor.TextColor3 = Color3.fromRGB(80, 160, 230)
playersValor.Text = "0"
playersValor.TextSize = 15
playersValor.Font = Enum.Font.GothamBold
playersValor.TextXAlignment = Enum.TextXAlignment.Right
playersValor.Parent = cardPlayers

-- Card Dispositivo (MOBILE ou PC)
local cardDispositivo = Instance.new("Frame")
cardDispositivo.Size = UDim2.new(1, -12, 0, 44)
cardDispositivo.Position = UDim2.new(0, 6, 0, 142)
cardDispositivo.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cardDispositivo.BorderSizePixel = 0
cardDispositivo.Parent = paineis["🔎 STATUS"]
Instance.new("UICorner", cardDispositivo).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cardDispositivo).Color = Color3.fromRGB(38, 38, 52)

local dispositivoNome = Instance.new("TextLabel")
dispositivoNome.Size = UDim2.new(0.5, 0, 1, 0)
dispositivoNome.Position = UDim2.new(0, 10, 0, 0)
dispositivoNome.BackgroundTransparency = 1
dispositivoNome.TextColor3 = Color3.fromRGB(180, 180, 180)
dispositivoNome.Text = "Dispositivo"
dispositivoNome.TextSize = 14
dispositivoNome.Font = Enum.Font.GothamBold
dispositivoNome.TextXAlignment = Enum.TextXAlignment.Left
dispositivoNome.Parent = cardDispositivo

local dispositivoValor = Instance.new("TextLabel")
dispositivoValor.Size = UDim2.new(0.45, 0, 1, 0)
dispositivoValor.Position = UDim2.new(0.53, 0, 0, 0)
dispositivoValor.BackgroundTransparency = 1
dispositivoValor.TextColor3 = Color3.fromRGB(255, 200, 0)
dispositivoValor.Text = "?"
dispositivoValor.TextSize = 15
dispositivoValor.Font = Enum.Font.GothamBold
dispositivoValor.TextXAlignment = Enum.TextXAlignment.Right
dispositivoValor.Parent = cardDispositivo

-- ============================================================
--  CARD: TEMPO DO SERVIDOR (uptime via DistributedGameTime)
-- ============================================================
local cardServidorUptime = Instance.new("Frame")
cardServidorUptime.Size = UDim2.new(1, -12, 0, 44)
cardServidorUptime.Position = UDim2.new(0, 6, 0, 192)
cardServidorUptime.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cardServidorUptime.BorderSizePixel = 0
cardServidorUptime.Parent = paineis["🔎 STATUS"]
Instance.new("UICorner", cardServidorUptime).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cardServidorUptime).Color = Color3.fromRGB(38, 38, 52)

local servidorUptimeNome = Instance.new("TextLabel")
servidorUptimeNome.Size = UDim2.new(0.55, 0, 1, 0)
servidorUptimeNome.Position = UDim2.new(0, 10, 0, 0)
servidorUptimeNome.BackgroundTransparency = 1
servidorUptimeNome.TextColor3 = Color3.fromRGB(180, 180, 180)
servidorUptimeNome.Text = "Tempo do Servidor"
servidorUptimeNome.TextSize = 13
servidorUptimeNome.Font = Enum.Font.GothamBold
servidorUptimeNome.TextXAlignment = Enum.TextXAlignment.Left
servidorUptimeNome.Parent = cardServidorUptime

local servidorUptimeValor = Instance.new("TextLabel")
servidorUptimeValor.Size = UDim2.new(0.42, 0, 1, 0)
servidorUptimeValor.Position = UDim2.new(0.56, 0, 0, 0)
servidorUptimeValor.BackgroundTransparency = 1
servidorUptimeValor.TextColor3 = Color3.fromRGB(255, 140, 0)
servidorUptimeValor.Text = "00:00:00"
servidorUptimeValor.TextSize = 15
servidorUptimeValor.Font = Enum.Font.GothamBold
servidorUptimeValor.TextXAlignment = Enum.TextXAlignment.Right
servidorUptimeValor.Parent = cardServidorUptime

-- ============================================================
--  CARD: HORA ATUAL COM SELETOR DE FUSO HORARIO
-- ============================================================
local FUSOS = {
    { nome = "Brasil (BRT -3)",          offset = -3   },
    { nome = "Portugal (WET UTC+0)",     offset = 0    },
    { nome = "EUA - New York (EST -5)",  offset = -5   },
    { nome = "EUA - Los Angeles (-8)",   offset = -8   },
    { nome = "Londres (GMT UTC+0)",      offset = 0    },
    { nome = "Franca/Alemanha (CET +1)", offset = 1    },
    { nome = "Russia - Moscou (+3)",     offset = 3    },
    { nome = "Dubai (GST +4)",           offset = 4    },
    { nome = "India (IST +5:30)",        offset = 5.5  },
    { nome = "China (CST +8)",           offset = 8    },
    { nome = "Japao (JST +9)",           offset = 9    },
    { nome = "Australia - Sydney (+10)", offset = 10   },
    { nome = "Africa do Sul (SAST +2)",  offset = 2    },
    { nome = "Mexico (CST -6)",          offset = -6   },
    { nome = "Argentina (ART -3)",       offset = -3   },
    { nome = "Colombia/Peru (-5)",       offset = -5   },
    { nome = "Chile (CLT -4)",           offset = -4   },
    { nome = "UTC (Padrao Global)",      offset = 0    },
}
local fusoAtualIdx = 1

local cardHora = Instance.new("Frame")
cardHora.Size = UDim2.new(1, -12, 0, 110)
cardHora.Position = UDim2.new(0, 6, 0, 242)
cardHora.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
cardHora.BorderSizePixel = 0
cardHora.Parent = paineis["🔎 STATUS"]
Instance.new("UICorner", cardHora).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cardHora).Color = Color3.fromRGB(38, 38, 52)

local horaLabel = Instance.new("TextLabel")
horaLabel.Size = UDim2.new(0.5, 0, 0, 28)
horaLabel.Position = UDim2.new(0, 10, 0, 4)
horaLabel.BackgroundTransparency = 1
horaLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
horaLabel.Text = "Hora Atual"
horaLabel.TextSize = 13
horaLabel.Font = Enum.Font.GothamBold
horaLabel.TextXAlignment = Enum.TextXAlignment.Left
horaLabel.Parent = cardHora

local horaValor = Instance.new("TextLabel")
horaValor.Size = UDim2.new(0.42, 0, 0, 28)
horaValor.Position = UDim2.new(0.56, 0, 0, 4)
horaValor.BackgroundTransparency = 1
horaValor.TextColor3 = Color3.fromRGB(100, 220, 255)
horaValor.Text = "00:00:00"
horaValor.TextSize = 15
horaValor.Font = Enum.Font.GothamBold
horaValor.TextXAlignment = Enum.TextXAlignment.Right
horaValor.Parent = cardHora

-- Data + Dia da semana (linha abaixo da hora)
local dataValor = Instance.new("TextLabel")
dataValor.Size = UDim2.new(1, -12, 0, 20)
dataValor.Position = UDim2.new(0, 6, 0, 34)
dataValor.BackgroundTransparency = 1
dataValor.TextColor3 = Color3.fromRGB(180, 255, 180)
dataValor.Text = "Seg, 01/01/2026"
dataValor.TextSize = 12
dataValor.Font = Enum.Font.GothamBold
dataValor.TextXAlignment = Enum.TextXAlignment.Right
dataValor.Parent = cardHora

local fusoBtnEsq = Instance.new("TextButton")
fusoBtnEsq.Size = UDim2.new(0, 28, 0, 26)
fusoBtnEsq.Position = UDim2.new(0, 6, 0, 60)
fusoBtnEsq.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
fusoBtnEsq.BorderSizePixel = 0
fusoBtnEsq.Text = "<"
fusoBtnEsq.TextColor3 = Color3.fromRGB(200, 200, 200)
fusoBtnEsq.TextSize = 16
fusoBtnEsq.Font = Enum.Font.GothamBold
fusoBtnEsq.Parent = cardHora
Instance.new("UICorner", fusoBtnEsq).CornerRadius = UDim.new(0, 6)

local fusoBtnDir = Instance.new("TextButton")
fusoBtnDir.Size = UDim2.new(0, 28, 0, 26)
fusoBtnDir.Position = UDim2.new(1, -34, 0, 60)
fusoBtnDir.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
fusoBtnDir.BorderSizePixel = 0
fusoBtnDir.Text = ">"
fusoBtnDir.TextColor3 = Color3.fromRGB(200, 200, 200)
fusoBtnDir.TextSize = 16
fusoBtnDir.Font = Enum.Font.GothamBold
fusoBtnDir.Parent = cardHora
Instance.new("UICorner", fusoBtnDir).CornerRadius = UDim.new(0, 6)

local fusoNomeLabel = Instance.new("TextLabel")
fusoNomeLabel.Size = UDim2.new(1, -76, 0, 26)
fusoNomeLabel.Position = UDim2.new(0, 38, 0, 60)
fusoNomeLabel.BackgroundTransparency = 1
fusoNomeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
fusoNomeLabel.Text = FUSOS[fusoAtualIdx].nome
fusoNomeLabel.TextSize = 11
fusoNomeLabel.Font = Enum.Font.GothamBold
fusoNomeLabel.TextXAlignment = Enum.TextXAlignment.Center
fusoNomeLabel.TextWrapped = true
fusoNomeLabel.Parent = cardHora

fusoBtnEsq.MouseButton1Click:Connect(function()
    fusoAtualIdx = fusoAtualIdx - 1
    if fusoAtualIdx < 1 then fusoAtualIdx = #FUSOS end
    fusoNomeLabel.Text = FUSOS[fusoAtualIdx].nome
end)
fusoBtnDir.MouseButton1Click:Connect(function()
    fusoAtualIdx = fusoAtualIdx + 1
    if fusoAtualIdx > #FUSOS then fusoAtualIdx = 1 end
    fusoNomeLabel.Text = FUSOS[fusoAtualIdx].nome
end)

local DIAS_SEMANA = {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
local MESES = {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}

local function formatarFuso(utcTimestamp, offsetHoras)
    local totalSeg = utcTimestamp + math.floor(offsetHoras * 3600)
    -- Hora
    local h = math.floor((totalSeg / 3600) % 24)
    local m = math.floor((totalSeg / 60) % 60)
    local s = math.floor(totalSeg % 60)
    local hora = string.format("%02d:%02d:%02d", h, m, s)
    -- Data via os.date com offset manual
    local d = os.date("!*t", totalSeg)
    local diaSemana = DIAS_SEMANA[d.wday]  -- wday: 1=Dom .. 7=Sab
    local data = string.format("%s, %02d/%02d/%04d", diaSemana, d.day, d.month, d.year)
    return hora, data
end

-- Loop atualiza status
task.spawn(function()
    while running do
        pcall(function()
            -- Tempo ativo do jogador
            local elapsed = tick() - scriptStartTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            tempoValor.Text = string.format("%02d:%02d:%02d", h, m, s)
            -- Players
            playersValor.Text = tostring(#Players:GetPlayers()) .. "/" .. tostring(Players.MaxPlayers)
            -- Dispositivo
            local lastInput = UIS:GetLastInputType()
            if lastInput == Enum.UserInputType.Touch or lastInput == Enum.UserInputType.Gamepad1 then
                dispositivoValor.Text = "📲 MOBILE"
                dispositivoValor.TextColor3 = Color3.fromRGB(100, 200, 255)
            else
                dispositivoValor.Text = "🖥️ PC"
                dispositivoValor.TextColor3 = Color3.fromRGB(255, 185, 0)
            end
            -- Tempo do servidor (workspace.DistributedGameTime = segundos desde que o server abriu)
            local serverUptime = workspace.DistributedGameTime
            local su_h = math.floor(serverUptime / 3600)
            local su_m = math.floor((serverUptime % 3600) / 60)
            local su_s = math.floor(serverUptime % 60)
            servidorUptimeValor.Text = string.format("%02d:%02d:%02d", su_h, su_m, su_s)
            -- Hora atual no fuso selecionado
            local horaStr, dataStr = formatarFuso(os.time(), FUSOS[fusoAtualIdx].offset)
            horaValor.Text = horaStr
            dataValor.Text = dataStr
        end)
        task.wait(1)
    end
end)

-- ============================================================
--  ABA 🏠 Farming
-- ============================================================
local farmingPanel = paineis["🏠 Farming"]

local armamentos = {"Melee", "Sword", "Gun", "Blox Fruit"}
local selectedArma = "Melee"
local armaDropdownAberto = false

-- Linha: "Selecionar Armamento" + botão Select
local armaRow = Instance.new("Frame")
armaRow.Size = UDim2.new(1, -12, 0, 44)
armaRow.Position = UDim2.new(0, 6, 0, 10)
armaRow.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
armaRow.BorderSizePixel = 0
armaRow.Parent = farmingPanel
Instance.new("UICorner", armaRow).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", armaRow).Color = Color3.fromRGB(38, 38, 52)

local armaLabel = Instance.new("TextLabel")
armaLabel.Size = UDim2.new(0.55, 0, 1, 0)
armaLabel.Position = UDim2.new(0, 10, 0, 0)
armaLabel.BackgroundTransparency = 1
armaLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
armaLabel.Text = "Selecionar Armamento"
armaLabel.TextSize = 13
armaLabel.Font = Enum.Font.GothamBold
armaLabel.TextXAlignment = Enum.TextXAlignment.Left
armaLabel.Parent = armaRow

local armaBtn = Instance.new("TextButton")
armaBtn.Size = UDim2.new(0, 100, 0, 30)
armaBtn.Position = UDim2.new(1, -108, 0.5, -15)
armaBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 55)
armaBtn.BorderSizePixel = 0
armaBtn.Text = selectedArma
armaBtn.TextSize = 12
armaBtn.Font = Enum.Font.GothamBold
armaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
armaBtn.Parent = armaRow
Instance.new("UICorner", armaBtn).CornerRadius = UDim.new(0, 8)
local armaBtnStroke = Instance.new("UIStroke", armaBtn)
armaBtnStroke.Color = Color3.fromRGB(100, 80, 220)
armaBtnStroke.Thickness = 1.5

-- Dropdown fora (screenGui)
-- Cálculo exato: N itens × 32px + (N-1) gaps de 2px + 4px padding top/bottom
local armaContentH = #armamentos * 32 + (#armamentos - 1) * 2 + 4
local armaDropdownOuter = Instance.new("Frame")
armaDropdownOuter.Size = UDim2.new(0, 160, 0, armaContentH)
armaDropdownOuter.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
armaDropdownOuter.BorderSizePixel = 0
armaDropdownOuter.Visible = false
armaDropdownOuter.ZIndex = 50
armaDropdownOuter.ClipsDescendants = true
armaDropdownOuter.Parent = screenGui
Instance.new("UICorner", armaDropdownOuter).CornerRadius = UDim.new(0, 10)
local armaStroke = Instance.new("UIStroke", armaDropdownOuter)
armaStroke.Color = Color3.fromRGB(100, 80, 220)
armaStroke.Thickness = 1.5

local armaDropdown = Instance.new("ScrollingFrame")
armaDropdown.Size = UDim2.new(1, 0, 1, 0)
armaDropdown.BackgroundTransparency = 1
armaDropdown.BorderSizePixel = 0
armaDropdown.ScrollBarThickness = 3
armaDropdown.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 220)
armaDropdown.CanvasSize = UDim2.new(0, 0, 0, armaContentH)
armaDropdown.ElasticBehavior = Enum.ElasticBehavior.Never
armaDropdown.ZIndex = 51
armaDropdown.Parent = armaDropdownOuter

local armaLayout = Instance.new("UIListLayout")
armaLayout.Padding = UDim.new(0, 2)
armaLayout.Parent = armaDropdown

local armaPad = Instance.new("UIPadding")
armaPad.PaddingTop = UDim.new(0, 2)
armaPad.PaddingBottom = UDim.new(0, 2)
armaPad.PaddingLeft = UDim.new(0, 4)
armaPad.PaddingRight = UDim.new(0, 4)
armaPad.Parent = armaDropdown

for _, arma in ipairs(armamentos) do
    local opt = Instance.new("TextButton")
    opt.Size = UDim2.new(1, 0, 0, 32)
    opt.BackgroundColor3 = arma == selectedArma and Color3.fromRGB(35, 32, 55) or Color3.fromRGB(28, 26, 42)
    opt.BorderSizePixel = 0
    opt.Text = arma
    opt.TextSize = 13
    opt.Font = Enum.Font.GothamBold
    opt.TextColor3 = arma == selectedArma and Color3.fromRGB(100, 80, 220) or Color3.fromRGB(210, 210, 210)
    opt.ZIndex = 51
    opt.Parent = armaDropdown
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6)

    opt.MouseButton1Click:Connect(function()
        selectedArma = arma
        armaBtn.Text = arma
        -- NÃO fecha: apenas atualiza a seleção visual
        for _, c in ipairs(armaDropdown:GetChildren()) do
            if c:IsA("TextButton") then
                c.TextColor3 = c.Text == arma and Color3.fromRGB(100, 80, 220) or Color3.fromRGB(210, 210, 210)
                c.BackgroundColor3 = c.Text == arma and Color3.fromRGB(35, 32, 55) or Color3.fromRGB(28, 26, 42)
            end
        end
    end)
end

-- Divisória decorativa
local armaDivisoria = Instance.new("TextLabel")
armaDivisoria.Size = UDim2.new(1, -12, 0, 24)
armaDivisoria.Position = UDim2.new(0, 6, 0, 60)
armaDivisoria.BackgroundTransparency = 1
armaDivisoria.TextColor3 = Color3.fromRGB(130, 130, 150)
armaDivisoria.Text = "─── ⋆⋅⋆⋅🌟⋅⋆⋅⋆ ───"
armaDivisoria.TextSize = 13
armaDivisoria.Font = Enum.Font.GothamBold
armaDivisoria.TextXAlignment = Enum.TextXAlignment.Center
armaDivisoria.Parent = farmingPanel

-- Fecha todos os dropdowns abertos (chamado ao ativar qualquer toggle/botão)
local function fecharTodosDropdowns()
    if armaDropdownAberto then
        armaDropdownOuter.Visible = false
        armaDropdownAberto = false
    end
    if bossDropdownAberto then
        bossDropdownOuter.Visible = false
        bossDropdownAberto = false
    end
end

-- Toggle igual Redz Hub
local function criarToggleRedz(painel, posY, texto)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -12, 0, 44)
    bg.Position = UDim2.new(0, 6, 0, posY)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    bg.BorderSizePixel = 0
    bg.Parent = painel
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", bg).Color = Color3.fromRGB(38, 38, 52)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Text = texto
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = bg

    -- Track (fundo do toggle)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 48, 0, 26)
    track.Position = UDim2.new(1, -58, 0.5, -13)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    track.Parent = bg
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    -- Bolinha
    local bolinha = Instance.new("Frame")
    bolinha.Size = UDim2.new(0, 20, 0, 20)
    bolinha.Position = UDim2.new(0, 3, 0.5, -10)
    bolinha.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bolinha.BorderSizePixel = 0
    bolinha.Parent = track
    Instance.new("UICorner", bolinha).CornerRadius = UDim.new(1, 0)

    local ativo = false

    -- Botão invisível sobre tudo
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = bg

    btn.MouseButton1Click:Connect(function()
        fecharTodosDropdowns()
        ativo = not ativo
        track.BackgroundColor3 = ativo
            and Color3.fromRGB(0, 120, 220)
            or  Color3.fromRGB(60, 60, 70)
        TweenService:Create(bolinha, TweenInfo.new(0.15), {
            Position = ativo
                and UDim2.new(0, 25, 0.5, -10)
                or  UDim2.new(0, 3, 0.5, -10)
        }):Play()
    end)

    return btn, ativo
end

local autoFarmLevelBtn  = criarToggleRedz(farmingPanel, 90,  "Auto Farm Level")
local farmLevelNewBtn   = criarToggleRedz(farmingPanel, 140, "Farm Level New")
local autoKillBtn       = criarToggleRedz(farmingPanel, 190, "Auto Kill Near ━ Mob Aura")

-- Divisória decorativa 2
local armaDivisoria2 = Instance.new("TextLabel")
armaDivisoria2.Size = UDim2.new(1, -12, 0, 24)
armaDivisoria2.Position = UDim2.new(0, 6, 0, 242)
armaDivisoria2.BackgroundTransparency = 1
armaDivisoria2.TextColor3 = Color3.fromRGB(130, 130, 150)
armaDivisoria2.Text = "─── ⋆⋅⋆⋅🌟⋅⋆⋅⋆ ───"
armaDivisoria2.TextSize = 13
armaDivisoria2.Font = Enum.Font.GothamBold
armaDivisoria2.TextXAlignment = Enum.TextXAlignment.Center
armaDivisoria2.Parent = farmingPanel

-- Boss Section
local bosses = {
    "Gorilla King", "Bobby", "Yeti", "Vice Admiral",
    "Warden", "Chief Warden", "Flamingo", "Magma Admiral",
    "Fishman Lord", "Cyborg", "Diamond", "Jeremy",
    "Fajita", "Don Swan", "Greybeard", "Beautiful Pirate",
    "Tide Keeper", "Longma", "Cake Queen", "Rip_Indra"
}
local selectedBoss = "Gorilla King"
local bossDropdownAberto = false

-- Linha: "Auto Selecionar Boss" + botão
local bossRow = Instance.new("Frame")
bossRow.Size = UDim2.new(1, -12, 0, 44)
bossRow.Position = UDim2.new(0, 6, 0, 272)
bossRow.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
bossRow.BorderSizePixel = 0
bossRow.Parent = farmingPanel
Instance.new("UICorner", bossRow).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", bossRow).Color = Color3.fromRGB(38, 38, 52)

local bossLabel = Instance.new("TextLabel")
bossLabel.Size = UDim2.new(0.55, 0, 1, 0)
bossLabel.Position = UDim2.new(0, 10, 0, 0)
bossLabel.BackgroundTransparency = 1
bossLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
bossLabel.Text = "Auto Selecionar Boss"
bossLabel.TextSize = 12
bossLabel.Font = Enum.Font.GothamBold
bossLabel.TextXAlignment = Enum.TextXAlignment.Left
bossLabel.Parent = bossRow

local bossBtn = Instance.new("TextButton")
bossBtn.Size = UDim2.new(0, 100, 0, 30)
bossBtn.Position = UDim2.new(1, -108, 0.5, -15)
bossBtn.BackgroundColor3 = Color3.fromRGB(35, 32, 55)
bossBtn.BorderSizePixel = 0
bossBtn.Text = selectedBoss
bossBtn.TextSize = 11
bossBtn.Font = Enum.Font.GothamBold
bossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bossBtn.Parent = bossRow
Instance.new("UICorner", bossBtn).CornerRadius = UDim.new(0, 8)
local bossBtnStroke = Instance.new("UIStroke", bossBtn)
bossBtnStroke.Color = Color3.fromRGB(100, 80, 220)
bossBtnStroke.Thickness = 1.5

-- Dropdown fora (screenGui)
local bossDropdownOuter = Instance.new("Frame")
bossDropdownOuter.Size = UDim2.new(0, 180, 0, math.min(#bosses * 36 + 8, 250))
bossDropdownOuter.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
bossDropdownOuter.BorderSizePixel = 0
bossDropdownOuter.Visible = false
bossDropdownOuter.ZIndex = 50
bossDropdownOuter.ClipsDescendants = true
bossDropdownOuter.Parent = screenGui
Instance.new("UICorner", bossDropdownOuter).CornerRadius = UDim.new(0, 10)
local bossDDStroke = Instance.new("UIStroke", bossDropdownOuter)
bossDDStroke.Color = Color3.fromRGB(100, 80, 220)
bossDDStroke.Thickness = 1.5

local bossDropdown = Instance.new("ScrollingFrame")
bossDropdown.Size = UDim2.new(1, 0, 1, 0)
bossDropdown.BackgroundTransparency = 1
bossDropdown.BorderSizePixel = 0
bossDropdown.ScrollBarThickness = 3
bossDropdown.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 220)
bossDropdown.CanvasSize = UDim2.new(0, 0, 0, #bosses * 34 + 6)
bossDropdown.ElasticBehavior = Enum.ElasticBehavior.Never
bossDropdown.ZIndex = 51
bossDropdown.Parent = bossDropdownOuter

local bossLayout = Instance.new("UIListLayout")
bossLayout.Padding = UDim.new(0, 2)
bossLayout.Parent = bossDropdown

local bossPad = Instance.new("UIPadding")
bossPad.PaddingTop = UDim.new(0, 2)
bossPad.PaddingBottom = UDim.new(0, 2)
bossPad.PaddingLeft = UDim.new(0, 4)
bossPad.PaddingRight = UDim.new(0, 4)
bossPad.Parent = bossDropdown

for _, boss in ipairs(bosses) do
    local opt = Instance.new("TextButton")
    opt.Size = UDim2.new(1, 0, 0, 32)
    opt.BackgroundColor3 = boss == selectedBoss and Color3.fromRGB(35, 32, 55) or Color3.fromRGB(28, 26, 42)
    opt.BorderSizePixel = 0
    opt.Text = boss
    opt.TextSize = 12
    opt.Font = Enum.Font.GothamBold
    opt.TextColor3 = boss == selectedBoss and Color3.fromRGB(100, 80, 220) or Color3.fromRGB(210, 210, 210)
    opt.ZIndex = 51
    opt.Parent = bossDropdown
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 6)

    opt.MouseButton1Click:Connect(function()
        selectedBoss = boss
        bossBtn.Text = boss
        -- NÃO fecha: apenas atualiza a seleção visual
        for _, c in ipairs(bossDropdown:GetChildren()) do
            if c:IsA("TextButton") then
                c.TextColor3 = c.Text == boss and Color3.fromRGB(100, 80, 220) or Color3.fromRGB(210, 210, 210)
                c.BackgroundColor3 = c.Text == boss and Color3.fromRGB(35, 32, 55) or Color3.fromRGB(28, 26, 42)
            end
        end
    end)
end

bossBtn.MouseButton1Click:Connect(function()
    if bossDropdownAberto then
        bossDropdownOuter.Visible = false
        bossDropdownAberto = false
        return
    end
    bossDropdownAberto = true
    local frame_pos = frame.AbsolutePosition
    local contentX = frame_pos.X + TAB_W + 1
    local contentY = frame_pos.Y + TITLE_H + 1
    local contentW = FRAME_W - TAB_W - 1
    local contentH = FRAME_H - TITLE_H - 1
    local ddW = bossDropdownOuter.AbsoluteSize.X
    local ddH = bossDropdownOuter.AbsoluteSize.Y
    local centerX = contentX + (contentW - ddW) / 2
    local centerY = contentY + (contentH - ddH) / 2
    bossDropdownOuter.Position = UDim2.new(0, centerX, 0, centerY)
    bossDropdownOuter.Visible = true
end)

-- Fecha dropdown de boss ao tocar fora ou no botão (handled via fecharTodosDropdowns)

-- Toggle: Auto Farm Boss
local autoFarmBossBtn = criarToggleRedz(farmingPanel, 322, "Auto Farm Boss")

-- Divisória decorativa 3 (acima do Raid Pirata)
local armaDivisoria3 = Instance.new("TextLabel")
armaDivisoria3.Size = UDim2.new(1, -12, 0, 24)
armaDivisoria3.Position = UDim2.new(0, 6, 0, 374)
armaDivisoria3.BackgroundTransparency = 1
armaDivisoria3.TextColor3 = Color3.fromRGB(130, 130, 150)
armaDivisoria3.Text = "─── ⋆⋅⋆⋅🌟⋅⋆⋅⋆ ───"
armaDivisoria3.TextSize = 13
armaDivisoria3.Font = Enum.Font.GothamBold
armaDivisoria3.TextXAlignment = Enum.TextXAlignment.Center
armaDivisoria3.Parent = farmingPanel

-- Toggle: Raid Pirata
local raidPirataBtn = criarToggleRedz(farmingPanel, 404, "Raid Pirata")

-- Divisória decorativa 4 (abaixo do Raid Pirata)
local armaDivisoria4 = Instance.new("TextLabel")
armaDivisoria4.Size = UDim2.new(1, -12, 0, 24)
armaDivisoria4.Position = UDim2.new(0, 6, 0, 454)
armaDivisoria4.BackgroundTransparency = 1
armaDivisoria4.TextColor3 = Color3.fromRGB(130, 130, 150)
armaDivisoria4.Text = "─── ⋆⋅⋆⋅🌟⋅⋆⋅⋆ ───"
armaDivisoria4.TextSize = 13
armaDivisoria4.Font = Enum.Font.GothamBold
armaDivisoria4.TextXAlignment = Enum.TextXAlignment.Center
armaDivisoria4.Parent = farmingPanel

-- Toggle: Ver Status dos Olhos
local verStatusOlhosBtn = criarToggleRedz(farmingPanel, 484, "Ver Status dos Olhos")

-- Toggle: Auto Farm Tirano
local autoFarmTiranoBtn = criarToggleRedz(farmingPanel, 534, "Auto Farm Tirano")

-- Toggle: Ativar Boss Tirano da Tiki
local bossTiranoTikiBtn = criarToggleRedz(farmingPanel, 584, "Ativar Boss Tirano da Tiki")

-- Divisória decorativa 5
local armaDivisoria5 = Instance.new("TextLabel")
armaDivisoria5.Size = UDim2.new(1, -12, 0, 24)
armaDivisoria5.Position = UDim2.new(0, 6, 0, 634)
armaDivisoria5.BackgroundTransparency = 1
armaDivisoria5.TextColor3 = Color3.fromRGB(130, 130, 150)
armaDivisoria5.Text = "─── ⋆⋅⋆⋅🌟⋅⋆⋅⋆ ───"
armaDivisoria5.TextSize = 13
armaDivisoria5.Font = Enum.Font.GothamBold
armaDivisoria5.TextXAlignment = Enum.TextXAlignment.Center
armaDivisoria5.Parent = farmingPanel

-- 6 toggles Xwong
local checkBoneBtn    = criarToggleRedz(farmingPanel, 664, "Quantidade de Ossos")
local farmBoneBtn     = criarToggleRedz(farmingPanel, 714, "Farm Ossos")
local bossFoiceBtn    = criarToggleRedz(farmingPanel, 764, "Boss da Foice")
local tradeBoneBtn    = criarToggleRedz(farmingPanel, 814, "Trade Ossos")
local autoPrayBtn     = criarToggleRedz(farmingPanel, 864, "Oracao Automatica")
local autoTryLuckBtn  = criarToggleRedz(farmingPanel, 914, "Tentar Sorte Automatica")

armaBtn.MouseButton1Click:Connect(function()
    if armaDropdownAberto then
        armaDropdownOuter.Visible = false
        armaDropdownAberto = false
        return
    end
    armaDropdownAberto = true
    local frame_pos = frame.AbsolutePosition
    local contentX = frame_pos.X + TAB_W + 1
    local contentY = frame_pos.Y + TITLE_H + 1
    local contentW = FRAME_W - TAB_W - 1
    local contentH = FRAME_H - TITLE_H - 1
    local ddW = armaDropdownOuter.AbsoluteSize.X
    local ddH = armaDropdownOuter.AbsoluteSize.Y
    local centerX = contentX + (contentW - ddW) / 2
    local centerY = contentY + (contentH - ddH) / 2
    armaDropdownOuter.Position = UDim2.new(0, centerX, 0, centerY)
    armaDropdownOuter.Visible = true
end)

-- Fecha dropdown de arma ao tocar fora ou no botão (handled via fecharTodosDropdowns)

-- ============================================================
--  ABA 🎣 Auto Fishing — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA ⚔️ Quest ━ Items — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 🌋 Volcano Dojo — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 🌊 Sea Event — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 👑 Raça V4 — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 🍒 Raid ━ Frutas — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 🍏 Frutas ━ Ver Estoque — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 📌 Teleportar — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 👤 Pvp ━ Player — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA 🛒 Shop — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

-- ============================================================
--  ABA ⚙️ Configurações — (em branco)
-- ============================================================
-- (conteúdo a adicionar)

local resetBtn = criarItemSimples(paineis["👑 ADM"], 1, "RESET SCRIPT", Color3.fromRGB(255, 185, 0))
resetBtn.MouseButton1Click:Connect(function()
    voarActive = false
    autoClickActive = false
    bringMobActive = false
    pegarBausActive = false
    liteActive = false
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0, 180, 0, 36)
    msg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    msg.BackgroundTransparency = 0
    msg.BorderSizePixel = 0
    msg.TextColor3 = Color3.fromRGB(0, 255, 80)
    msg.Text = "Reset Successful!"
    msg.TextScaled = true
    msg.Font = Enum.Font.GothamBold
    msg.ZIndex = 20
    local admPanel = paineis["👑 ADM"]
    local absPos = admPanel.AbsolutePosition
    local absSize = admPanel.AbsoluteSize
    msg.Position = UDim2.new(0, absPos.X + (absSize.X/2) - 90, 0, absPos.Y + 160)
    Instance.new("UICorner", msg).CornerRadius = UDim.new(0, 8)
    msg.Parent = screenGui
    task.wait(2)
    msg:Destroy()
end)

local closeBtn = criarItemSimples(paineis["👑 ADM"], 2, "FECHAR", Color3.fromRGB(255, 80, 80))

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

-- Conexão do click
miniBtn2.MouseButton1Click:Connect(function()
    minimized = not minimized
    if not minimized then
        frame.Position = UDim2.new(0.5, -FRAME_W/2, 0, -10)
    end
    frame.Visible = not minimized
end)

local rgbHue = 0
RunService.Heartbeat:Connect(function(dt)
    rgbHue = (rgbHue + dt * 0.5) % 1
    rgbStroke.Color = Color3.fromHSV(rgbHue, 1, 1)
end)

-- ============================================================
--  TELA DE AVISO (declarada antes do ativoBtn usá-la)
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
avisoBtn.Size = UDim2.new(0, 60, 0, 30)
avisoBtn.Position = UDim2.new(0.5, -30, 0, 115)
avisoBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
avisoBtn.BorderSizePixel = 0
avisoBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
avisoBtn.Text = "❌"
avisoBtn.TextScaled = true
avisoBtn.Font = Enum.Font.GothamBold
avisoBtn.ZIndex = 31
avisoBtn.Parent = avisoFrame
Instance.new("UICorner", avisoBtn).CornerRadius = UDim.new(0, 6)
local avisoStroke2 = Instance.new("UIStroke", avisoBtn)
avisoStroke2.Color = Color3.fromRGB(100, 50, 50)
avisoStroke2.Thickness = 1.5

avisoBtn.MouseButton1Click:Connect(function()
    avisoFrame.Visible = false
end)

-- ============================================================
--  PAINEL DE ILHAS — DETECTA O MAR AUTOMATICAMENTE
-- ============================================================
local ativoBtn, ativoLbl = criarItem(paineis["👑 ADM"], 0, "ATIVO", COR_GOLD)
-- Centraliza o texto ATIVO e esconde o checkbox
ativoLbl.Size = UDim2.new(1, 0, 1, 0)
ativoLbl.Position = UDim2.new(0, 0, 0, 0)
ativoLbl.TextXAlignment = Enum.TextXAlignment.Center
ativoBtn.Visible = false  -- esconde o cadeado/checkbox
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
-- Botão invisível sobre o item inteiro para capturar clique
local ativoBtnOver = Instance.new("TextButton")
ativoBtnOver.Size = UDim2.new(1, 0, 1, 0)
ativoBtnOver.BackgroundTransparency = 1
ativoBtnOver.Text = ""
ativoBtnOver.ZIndex = 5
ativoBtnOver.Parent = ativoLbl.Parent
ativoBtnOver.MouseButton1Click:Connect(function()
    avisoFrame.Visible = true
    local som = Instance.new("Sound")
    som.SoundId = "rbxasset://sounds/action_fail.mp3"
    som.Volume = 0.5
    som.Parent = avisoFrame
    som:Play()
    task.wait(2)
    som:Destroy()
end)

-- ============================================================
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
cfSim.BackgroundColor3 = Color3.fromRGB(30, 160, 50)
cfSim.BorderSizePixel = 0
cfSim.Text = "Sim"
cfSim.TextColor3 = Color3.fromRGB(255, 255, 255)
cfSim.TextScaled = true
cfSim.Font = Enum.Font.GothamBold
cfSim.ZIndex = 10
cfSim.Parent = confirmFrame
Instance.new("UICorner", cfSim).CornerRadius = UDim.new(0, 6)

local cfNao = Instance.new("TextButton")
cfNao.Size = UDim2.new(0, 50, 0, 28)
cfNao.Position = UDim2.new(0, 85, 0, 52)
cfNao.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
cfNao.BorderSizePixel = 0
cfNao.Text = "❌"
cfNao.TextColor3 = Color3.fromRGB(255, 100, 100)
cfNao.TextScaled = true
cfNao.Font = Enum.Font.GothamBold
cfNao.ZIndex = 10
cfNao.Parent = confirmFrame
Instance.new("UICorner", cfNao).CornerRadius = UDim.new(0, 6)
local cfNaoStroke = Instance.new("UIStroke", cfNao)
cfNaoStroke.Color = Color3.fromRGB(100, 50, 50)
cfNaoStroke.Thickness = 1.5

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
        frame.Position = UDim2.new(0.5, -FRAME_W/2, 0, -10)
    end
    frame.Visible = not minimized
end

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
--  ANTI CHEAT — DETECTA VELOCIDADE ANORMAL E EXPLOITS
-- ============================================================
local antiCheatActive = true
local lastPosCheck = nil
local lastTimeCheck = tick()

task.spawn(function()
    while running do
        if antiCheatActive then
            pcall(function()
                local player = Players.LocalPlayer
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local currentTime = tick()
                local timeDelta = currentTime - lastTimeCheck
                
                if lastPosCheck and timeDelta > 0.05 then
                    local dist = (hrp.Position - lastPosCheck).Magnitude
                    local velocity = dist / timeDelta
                    
                    -- Limite de velocidade: 500 studs/s (muito acima do normal)
                    if velocity > 500 and not voarActive then
                        warn("⚠️ VELOCIDADE SUSPEITA DETECTADA: " .. math.floor(velocity) .. " studs/s")
                    end
                end
                
                lastPosCheck = hrp.Position
                lastTimeCheck = currentTime
            end)
        end
        task.wait(0.1)
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
            -- ADICIONADO: outros NPCs que não devem ser puxados
            "outros","other","others",
        }
        for _, p in ipairs(palavras) do
            if string.find(nome, p) then return true end
        end
        -- REGRA PRINCIPAL: só puxar NPCs que tenham BillboardGui com [Lv (inimigos com level)
        local temLevelTag = false
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("BillboardGui") then
                for _, lbl in ipairs(v:GetDescendants()) do
                    if lbl:IsA("TextLabel") and string.find(lbl.Text, "%[Lv") then
                        temLevelTag = true
                        break
                    end
                end
            end
            if temLevelTag then break end
        end
        if not temLevelTag then return true end

        for _, v in ipairs(obj:GetChildren()) do
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
--  VOAR — PARADO NO AR, CONTROLE PELO JOYSTICK / WASD
--  Camera olhando pra cima = voa pra cima; total 3D
-- ============================================================
task.spawn(function()
    local bodyGyro    = nil
    local bodyPos     = nil
    local voarAnt     = false
    local posLocked   = nil

    local VEL = 120              -- velocidade aumentada

    while running do
        if voarActive then
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                local hrp  = char:FindFirstChild("HumanoidRootPart")
                local hum  = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                if not bodyPos or not bodyPos.Parent then
                    posLocked = hrp.Position + Vector3.new(0, 15, 0)
                    hum.WalkSpeed  = 0
                    hum.JumpPower  = 0
                    hum.AutoRotate = false

                    bodyPos          = Instance.new("BodyPosition")
                    bodyPos.MaxForce = Vector3.new(1,1,1) * 1e5
                    bodyPos.P        = 80000
                    bodyPos.D        = 4000
                    bodyPos.Position = posLocked
                    bodyPos.Parent   = hrp

                    bodyGyro           = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(0,1,0) * 1e5
                    bodyGyro.P         = 80000
                    bodyGyro.D         = 400
                    bodyGyro.CFrame    = hrp.CFrame
                    bodyGyro.Parent    = hrp
                end

                local cam  = workspace.CurrentCamera
                local dt   = 0.05
                local move = Vector3.new(0, 0, 0)

                -- PC: WASD usa o LookVector COMPLETO (inclui angulo vertical da camera)
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    move = move + cam.CFrame.LookVector        -- inclui cima/baixo da camera
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    move = move - cam.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    move = move - cam.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    move = move + cam.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    move = move + Vector3.new(0,1,0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                    move = move - Vector3.new(0,1,0)
                end

                -- MOBILE: joystick avanca na direcao da camera (inclui eixo vertical)
                local md = hum.MoveDirection
                if md.Magnitude > 0.05 then
                    -- move na direcao da camera usando o joystick como intensidade
                    local forward = cam.CFrame.LookVector * md.Z
                    local right   = cam.CFrame.RightVector * md.X
                    move = forward + right
                end

                if move.Magnitude > 0 then
                    posLocked = posLocked + move.Unit * VEL * dt
                end

                bodyPos.Position = posLocked
                bodyGyro.CFrame  = CFrame.new(posLocked,
                    posLocked + cam.CFrame.LookVector)
            end)
            voarAnt = true
            task.wait(0.05)
        else
            if voarAnt then
                pcall(function()
                    local char = Players.LocalPlayer.Character
                    if not char then return end
                    local hum  = char:FindFirstChildOfClass("Humanoid")
                    if bodyPos  then bodyPos:Destroy()  bodyPos  = nil end
                    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                    posLocked = nil
                    if hum then
                        hum.WalkSpeed  = 16
                        hum.JumpPower  = 50
                        hum.AutoRotate = true
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
                voarAnt = false
            end
            task.wait(0.1)
        end
    end
end)

-- ============================================================
--  TIME GUI — substituido por aba TIME (ver acima)
-- ============================================================
local timeGui = Instance.new("Frame") -- stub vazio para compatibilidade
timeGui.Size = UDim2.new(0,0,0,0)
timeGui.Visible = false
timeGui.Parent = screenGui

-- ============================================================
--  PEGAR BAÚS — VARREDURA POR ILHA (Mar 1, 2 e 3)
-- ============================================================

local NOMES_BAU = {
    "Chest1","Chest2","Chest3",
    "Silver","Gold","Diamond",
    "SilverLock","GoldLock","DiamondLock",
}

-- Todas as ilhas dos 3 mares com suas posições
local ILHAS = {
    -- ===== MAR 1 =====
    { nome = "Starter Island",      pos = Vector3.new(999,   124, 1553)  },
    { nome = "Marine Starter",      pos = Vector3.new(-2172,  10, 1498)  },
    { nome = "Jungle",              pos = Vector3.new(-680,  244, 2114)  },
    { nome = "Pirate Village",      pos = Vector3.new(-1310, 100,  330)  },
    { nome = "Desert",              pos = Vector3.new(941,    70, -570)  },
    { nome = "Snow Mountain",       pos = Vector3.new(1175,  207,-2400)  },
    { nome = "Marine Fortress",     pos = Vector3.new(-3079,  61,  534)  },
    { nome = "Skylands (Mar 1)",    pos = Vector3.new(927,   843,-1293)  },
    { nome = "Fountain City",       pos = Vector3.new(-4750, 375, 3120)  },
    -- ===== MAR 2 =====
    { nome = "Kingdom of Rose",     pos = Vector3.new(-232,    9,-3588)  },
    { nome = "Green Zone",          pos = Vector3.new(1507,    9,-4360)  },
    { nome = "Graveyard",           pos = Vector3.new(4232,    9,-3461)  },
    { nome = "Snow Island",         pos = Vector3.new(3959,    9, -827)  },
    { nome = "Hot and Cold",        pos = Vector3.new(4280,    9,  804)  },
    { nome = "Magma Village",       pos = Vector3.new(3553,    9, 2025)  },
    { nome = "Underwater City",     pos = Vector3.new(918,  -1000,-1670) },
    { nome = "Skylands (Mar 2)",    pos = Vector3.new(2800,  800,-3200)  },
    { nome = "Dark Arena",          pos = Vector3.new(-2027,   9,-3753)  },
    -- ===== MAR 3 =====
    { nome = "Port Town",           pos = Vector3.new(-5887, 295,-3744)  },
    { nome = "Hydra Island",        pos = Vector3.new(-7234,  96,-2349)  },
    { nome = "Great Tree",          pos = Vector3.new(-9083, 400,-2024)  },
    { nome = "Floating Turtle",     pos = Vector3.new(-12655,800,-2024)  },
    { nome = "Haunted Castle",      pos = Vector3.new(-7613,   9, 1079)  },
    { nome = "Sea of Treats",       pos = Vector3.new(-11963,  9, 1442)  },
    { nome = "Castle on the Sea",   pos = Vector3.new(-6250, 350, 3200)  },
    { nome = "Ice Castle (Mar 3)",  pos = Vector3.new(-8700, 200,-3800)  },
}

local function ehNomeBau(nome)
    for _, n in ipairs(NOMES_BAU) do
        if nome == n then return true end
    end
    return false
end

-- Encontra baús num raio de 600 studs ao redor de uma posição
local function encontrarBausProximos(centro)
    local baus  = {}
    local vistos = {}
    local RAIO  = 5000

    local function processarObj(obj)
        if not obj:IsA("BasePart") then return end
        if not ehNomeBau(obj.Name) then return end
        if (obj.Position - centro).Magnitude > RAIO then return end
        local root = (obj.Parent and obj.Parent:IsA("Model")) and obj.Parent or obj
        if vistos[root] then return end
        if root:IsA("Model") and root:FindFirstChildOfClass("Humanoid") then return end
        vistos[root] = true
        table.insert(baus, {root = root, parte = obj})
    end

    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if worldOrigin then
        for _, obj in ipairs(worldOrigin:GetDescendants()) do
            processarObj(obj)
        end
    end

    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name ~= "_WorldOrigin"
            and child.Name ~= "Camera"
            and not Players:GetPlayerFromCharacter(child) then
            for _, obj in ipairs(child:GetDescendants()) do
                processarObj(obj)
            end
        end
    end

    return baus
end

-- Voa passo a passo via CFrame — sem oscilação, velocidade controlada
local function voarAte(hrp, destino, timeoutMax)
    local char = Players.LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed  = 0
        hum.JumpPower  = 0
        hum.AutoRotate = false
    end

    -- Noclip contínuo durante todo o voo
    local noclipConn = RunService.Stepped:Connect(function()
        if not char or not char.Parent then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    local VELOCIDADE = 110  -- studs por segundo
    local PASSO      = 0.05

    local chegou = false
    local t      = 0

    while t < (timeoutMax or 60) do
        if not pegarBausActive then break end
        if not hrp or not hrp.Parent then break end

        local dist = (hrp.Position - destino).Magnitude
        if dist < 4 then
            chegou = true
            break
        end

        -- Move uma fatia em direção ao destino
        local dir       = (destino - hrp.Position).Unit
        local movimento = math.min(VELOCIDADE * PASSO, dist)
        hrp.CFrame      = CFrame.new(hrp.Position + dir * movimento)

        task.wait(PASSO)
        t = t + PASSO
    end

    -- Para o noclip e restaura colisão
    noclipConn:Disconnect()
    if char and char.Parent then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end

    if hum then
        hum.WalkSpeed  = 16
        hum.JumpPower  = 50
        hum.AutoRotate = true
    end

    return chegou
end

-- Voa até o baú e fica até ele ser coletado
local function coletarBau(hrp, bau)
    local char = Players.LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not bau.parte or not bau.parte.Parent then return false end

    local pos     = bau.parte.Position
    local destino = Vector3.new(pos.X, pos.Y + 2, pos.Z)

    -- Voa fisicamente até o baú
    voarAte(hrp, destino, 20)

    if not hrp or not hrp.Parent then return false end
    if not bau.parte or not bau.parte.Parent then return true end

    -- Monta lista de todas as partes do modelo
    local partes = {}
    if bau.root and bau.root:IsA("Model") then
        for _, p in ipairs(bau.root:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(partes, p)
            end
        end
    end
    if #partes == 0 then table.insert(partes, bau.parte) end

    if hum then
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end

    -- Dispara firetouchinterest em todas as partes até o baú sumir
    local coletado = false
    local timeout  = 0
    while timeout < 5 do
        if not pegarBausActive then break end
        if not bau.parte or not bau.parte.Parent then
            coletado = true
            break
        end
        if not hrp or not hrp.Parent then break end

        pcall(function()
            for _, parte in ipairs(partes) do
                firetouchinterest(hrp, parte, 0)
            end
            task.wait(0.05)
            for _, parte in ipairs(partes) do
                firetouchinterest(hrp, parte, 1)
            end
        end)

        task.wait(0.2)
        timeout = timeout + 0.25
    end

    if hum then
        hum.WalkSpeed  = 16
        hum.JumpPower  = 50
        hum.AutoRotate = true
    end

    return coletado
end

task.spawn(function()
    local ilhaIdx = 1
    while running do
        if pegarBausActive then
            local char = Players.LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then
                task.wait(1)
            else
                local ilha = ILHAS[ilhaIdx]

                -- Voa fisicamente até a ilha
                pegarBausLabel.Text = "✈ " .. ilha.nome
                voarAte(hrp, ilha.pos, 25)

                if not pegarBausActive then
                    ilhaIdx = 1
                else
                    -- Busca baús nessa ilha
                    char = Players.LocalPlayer.Character
                    hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if char and hrp then
                        local baus = encontrarBausProximos(ilha.pos)

                        if #baus > 0 then
                            pegarBausLabel.Text = ilha.nome .. " (" .. #baus .. ")"
                            for i, bau in ipairs(baus) do
                                if not pegarBausActive then break end
                                char = Players.LocalPlayer.Character
                                hrp  = char and char:FindFirstChild("HumanoidRootPart")
                                if not char or not hrp then break end

                                if bau.parte and bau.parte.Parent then
                                    pegarBausLabel.Text = ilha.nome .. " " .. i .. "/" .. #baus
                                    coletarBau(hrp, bau)
                                end
                            end
                        end
                    end

                    -- Avança para a próxima ilha
                    ilhaIdx = ilhaIdx + 1
                    if ilhaIdx > #ILHAS then
                        ilhaIdx = 1
                        pegarBausLabel.Text = "🔄 Reiniciando rota..."
                        task.wait(2)
                    end
                end
            end
        else
            ilhaIdx = 1
            pegarBausLabel.Text = "PEGAR BAÚS"
            task.wait(0.5)
        end
    end
end)

-- ============================================================
--  LOOP PRINCIPAL DE DETECÇÃO
-- ============================================================
print("👑 BF Notify - VERSÃO FINAL! FPS: 120")

-- ✅ CORREÇÃO: task.spawn para não bloquear o resto do script
task.spawn(function()
    while running do
        pcall(checkMirage)
        pcall(checkPrehistoric)
        pcall(checkFullMoon)
        pcall(checkBosses)
        pcall(checkLegendarySword)
        pcall(checkHaki)
        task.wait(5)
    end
end)

-- ============================================================
--  ABA ⚙️ CONFIG — (em branco)
-- ============================================================

local cfgPanel = paineis["⚙️ Configurações"]
local cfgY = 6

-- Helper: cria toggle row no painel de config (mantido para compatibilidade)
do end -- CONFIG vazio

-- ============================================================
--  ABA 🛒 SHOP — (em branco)
-- ============================================================

local shopPanel = paineis["🛒 Shop"]
local shopY = 6

-- SHOP vazio
