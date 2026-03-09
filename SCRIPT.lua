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
            -- Converte posição atual (escala+offset) para pixels absolutos
            local screen = workspace.CurrentCamera.ViewportSize
            local absPos = targetFrame.AbsolutePosition
            frameStartX = absPos.X
            frameStartY = absPos.Y
            -- Garante que o frame passa a usar só offset daqui pra frente
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
--  FRAME PRINCIPAL
-- ============================================================
-- MUDANÇAS: Layout 3x3, fonte ArialBold 18, nomes PT-BR
-- Linha 0: Ativo(0,0) | Puxar(1,0) | Voar(2,0)
-- Linha 1: Sem Afk(0,1) | Fechar(1,1) | Vaga(2,1)
-- Linha 2: Vaga(0,2) | Vaga(1,2) | Vaga(2,2)

local BTN_W = 68
local BTN_H = 28
local PAD_X = 8
local PAD_Y = 5
local START_Y = 30

-- Frame: 3 colunas = PAD_X + 3*(BTN_W+PAD_X) = 8 + 3*76 = 236
-- Altura: START_Y + 3*(BTN_H+PAD_Y) + PAD_Y = 30 + 3*33 + 5 = 134
local FRAME_W = PAD_X + 3 * (BTN_W + PAD_X)  -- 236
local FRAME_H = START_Y + 3 * (BTN_H + PAD_Y) + PAD_Y  -- 134

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
--  CRIAR BOTÃO — ArialBold tamanho 18, grid 3 colunas
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
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = labelColor
    lbl.Text = labelText
    lbl.TextSize = 18
    lbl.Font = Enum.Font.ArialBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Parent = btn

    return btn, lbl
end

-- ============================================================
--  LINHA 0: Ativo | Puxar | Voar
-- ============================================================
local ativoBtn, ativoLabel = createBtn2(0, 0, Color3.fromRGB(0,255,80), "Ativo", Color3.fromRGB(0,255,80))

-- Cadeado centralizado no meio do botão, meio transparente
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

-- "Ativo" centralizado no meio do botão
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

local bringMobBtn, bringMobLabel = createBtn2(1, 0, Color3.fromRGB(255,50,50), "Puxar", Color3.fromRGB(255,50,50))
bringMobBtn.MouseButton1Click:Connect(function()
    bringMobActive = not bringMobActive
    if bringMobActive then
        bringMobLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        bringMobLabel.Text = "Puxar"
    else
        bringMobLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        bringMobLabel.Text = "Puxar"
    end
end)

local voarBtn, voarLabel = createBtn2(2, 0, Color3.fromRGB(255,50,50), "Voar", Color3.fromRGB(255,50,50))
voarBtn.MouseButton1Click:Connect(function()
    voarActive = not voarActive
    if voarActive then
        voarLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        voarLabel.Text = "Voar"
    else
        voarLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        voarLabel.Text = "Voar"
    end
end)

-- ============================================================
--  LINHA 1: Sem Afk | Fechar | Vaga
-- ============================================================
local autoClickBtn, autoClickLabel = createBtn2(0, 1, Color3.fromRGB(255,50,50), "Sem Afk", Color3.fromRGB(255,50,50))
autoClickBtn.MouseButton1Click:Connect(function()
    autoClickActive = not autoClickActive
    if autoClickActive then
        autoClickLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
        autoClickLabel.Text = "Sem Afk"
    else
        autoClickLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        autoClickLabel.Text = "Sem Afk"
    end
end)

local closeBtn, closeLabel = createBtn2(1, 1, Color3.fromRGB(255,50,50), "Fechar", Color3.fromRGB(255,50,50))

createBtn2(2, 1, Color3.fromRGB(50,50,50), "Vaga", Color3.fromRGB(80,80,80))

-- ============================================================
--  LINHA 2: Vaga | Vaga | Vaga
-- ============================================================
createBtn2(0, 2, Color3.fromRGB(50,50,50), "Vaga", Color3.fromRGB(80,80,80))
createBtn2(1, 2, Color3.fromRGB(50,50,50), "Vaga", Color3.fromRGB(80,80,80))
createBtn2(2, 2, Color3.fromRGB(50,50,50), "Vaga", Color3.fromRGB(80,80,80))

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
        local nome = string.lower(obj.Name)
        local palavras = {
            "quest","giver","dealer","vendedor","missao","missão",
            "ponto","inicial","outros","shop","merchant","trader",
            "blacksmith","arowe","bartilo","swan","upgrade","farmer",
            "tiki","barcos","boat","ship","fruit","sword",
            "master","teacher","ability","gacha","cousin","luxury",
            "vivid","advanced","chompy","totto","yukora",
            "experimented","definir","spawn","npc","loja","luxo",
            "blox","citizen","bandit","home","set ","point",
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
                        if enemyHRP and humanoid and humanoid.Health > 0
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
    local ALTURA_VOO = 40
    local bodyPos = nil

    while running do
        if voarActive then
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                if not bodyPos or not bodyPos.Parent then
                    if bodyPos then bodyPos:Destroy() end
                    bodyPos = Instance.new("BodyPosition")
                    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyPos.P = 9999
                    bodyPos.D = 500
                    bodyPos.Parent = hrp
                end

                local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0))
                local groundY = ray and ray.Position.Y or (hrp.Position.Y - ALTURA_VOO)
                local alvoY = groundY + ALTURA_VOO

                if math.abs(hrp.Position.Y - alvoY) > 1 then
                    bodyPos.Position = Vector3.new(hrp.Position.X, alvoY, hrp.Position.Z)
                else
                    bodyPos.Position = hrp.Position
                end

                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
            end)
            task.wait(0.05)
        else
            if bodyPos then
                pcall(function() bodyPos:Destroy() end)
                bodyPos = nil
            end
            pcall(function()
                local char = Players.LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                end
            end)
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
