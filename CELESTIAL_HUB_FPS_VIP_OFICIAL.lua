--// CELESTIAL HUB X FPS BOOSTER (VIP)

local player = game.Players.LocalPlayer
local HapticService = game:GetService("HapticService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FPS_PREMIUM"
gui.ResetOnSpawn = false

-- CENTRALIZAR
local function centerFrame(f)
    f.Position = UDim2.new(0.5, -185, 0.5, -200)
end

-- VIBRAÇÃO
local function vibrar()
    task.spawn(function()
        pcall(function()
            if HapticService:IsVibrationSupported(Enum.UserInputType.Touch) then
                HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 1)
                task.wait(0.03)
                HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Small, 0)
            end
        end)
    end)
end

-- BORDA BRANCA
local function addWhiteStroke(ui)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = ui
end

-- ===================== TELA DE LOGIN =====================

local loginFrame = Instance.new("Frame", gui)
loginFrame.Size = UDim2.new(0, 300, 0, 220)
loginFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
loginFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
loginFrame.Active = true
loginFrame.Draggable = true
Instance.new("UICorner", loginFrame).CornerRadius = UDim.new(0, 14)
addWhiteStroke(loginFrame)

local loginTitle = Instance.new("TextLabel", loginFrame)
loginTitle.Size = UDim2.new(1, 0, 0, 36)
loginTitle.Position = UDim2.new(0, 0, 0, 14)
loginTitle.BackgroundTransparency = 1
loginTitle.Text = "CELESTIAL HUB X FPS BOOSTER (VIP)"
loginTitle.TextSize = 12
loginTitle.TextColor3 = Color3.fromRGB(180, 140, 255)
loginTitle.Font = Enum.Font.GothamBold
loginTitle.TextSize = 16

local loginSub = Instance.new("TextLabel", loginFrame)
loginSub.Size = UDim2.new(1, 0, 0, 20)
loginSub.Position = UDim2.new(0, 0, 0, 50)
loginSub.BackgroundTransparency = 1
loginSub.Text = "Digite a senha VIP para continuar"
loginSub.TextColor3 = Color3.fromRGB(140, 140, 155)
loginSub.Font = Enum.Font.Gotham
loginSub.TextSize = 12

local senhaInput = Instance.new("TextBox", loginFrame)
senhaInput.Size = UDim2.new(0, 220, 0, 38)
senhaInput.Position = UDim2.new(0.5, -110, 0, 84)
senhaInput.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
senhaInput.TextColor3 = Color3.fromRGB(255, 255, 255)
senhaInput.PlaceholderText = "🔒 Senha..."
senhaInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
senhaInput.Text = ""
senhaInput.Font = Enum.Font.GothamBold
senhaInput.TextSize = 15
senhaInput.ClearTextOnFocus = false
Instance.new("UICorner", senhaInput).CornerRadius = UDim.new(0, 8)
addWhiteStroke(senhaInput)

-- Lógica para mostrar * imediatamente no primeiro dígito
local senhaReal = ""
senhaInput:GetPropertyChangedSignal("Text"):Connect(function()
    local novo = senhaInput.Text
    local diff = #novo - #senhaReal
    if diff > 0 then
        senhaReal = senhaReal .. novo:sub(#senhaReal + 1)
    elseif diff < 0 then
        senhaReal = senhaReal:sub(1, #novo)
    end
    senhaInput.Text = string.rep("*", #senhaReal)
end)

local entrarBtn = Instance.new("TextButton", loginFrame)
entrarBtn.Size = UDim2.new(0, 220, 0, 38)
entrarBtn.Position = UDim2.new(0.5, -110, 0, 134)
entrarBtn.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
entrarBtn.Text = "ENTRAR"
entrarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
entrarBtn.Font = Enum.Font.GothamBold
entrarBtn.TextSize = 14
Instance.new("UICorner", entrarBtn).CornerRadius = UDim.new(0, 8)
addWhiteStroke(entrarBtn)

local erroLabel = Instance.new("TextLabel", loginFrame)
erroLabel.Size = UDim2.new(1, 0, 0, 22)
erroLabel.Position = UDim2.new(0, 0, 0, 182)
erroLabel.BackgroundTransparency = 1
erroLabel.Text = ""
erroLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
erroLabel.Font = Enum.Font.GothamBold
erroLabel.TextSize = 12
erroLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ===================== FRAME PRINCIPAL (escondido até login) =====================

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 370, 0, 320)
centerFrame(frame)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
frame.Active = true
frame.Draggable = true
frame.Visible = false
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
addWhiteStroke(frame)

-- ===================== TÍTULO DENTRO DO FRAME NO TOPO =====================

local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, -50, 0, 28)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleLabel.Text = "CELESTIAL HUB X FPS BOOSTER (VIP)"
titleLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.BorderSizePixel = 0
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 6)

-- Botão X para fechar
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
addWhiteStroke(closeBtn)

-- Popup de confirmação
local confirmFrame = Instance.new("Frame", gui)
confirmFrame.Size = UDim2.new(0, 260, 0, 130)
confirmFrame.Position = UDim2.new(0.5, -130, 0.5, -65)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
confirmFrame.Active = true
confirmFrame.Visible = false
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 12)
addWhiteStroke(confirmFrame)

local confirmText = Instance.new("TextLabel", confirmFrame)
confirmText.Size = UDim2.new(1, -20, 0, 50)
confirmText.Position = UDim2.new(0, 10, 0, 10)
confirmText.BackgroundTransparency = 1
confirmText.Text = "Deseja realmente encerrar\no script?"
confirmText.TextColor3 = Color3.fromRGB(220, 220, 220)
confirmText.Font = Enum.Font.GothamBold
confirmText.TextSize = 14
confirmText.TextWrapped = true

local simBtn = Instance.new("TextButton", confirmFrame)
simBtn.Size = UDim2.new(0, 100, 0, 36)
simBtn.Position = UDim2.new(0, 14, 0, 76)
simBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
simBtn.Text = "Sim, fechar"
simBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
simBtn.Font = Enum.Font.GothamBold
simBtn.TextSize = 12
Instance.new("UICorner", simBtn).CornerRadius = UDim.new(0, 8)

local naoBtn = Instance.new("TextButton", confirmFrame)
naoBtn.Size = UDim2.new(0, 100, 0, 36)
naoBtn.Position = UDim2.new(1, -114, 0, 76)
naoBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
naoBtn.Text = "← Cancelar"
naoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
naoBtn.Font = Enum.Font.GothamBold
naoBtn.TextSize = 12
Instance.new("UICorner", naoBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
    vibrar()
    confirmFrame.Visible = true
end)

simBtn.MouseButton1Click:Connect(function()
    vibrar()
    -- Mata o script completamente
    gui:Destroy()
end)

naoBtn.MouseButton1Click:Connect(function()
    vibrar()
    confirmFrame.Visible = false
end)

local titleDiv = Instance.new("Frame", frame)
titleDiv.Size = UDim2.new(1, -20, 0, 1)
titleDiv.Position = UDim2.new(0, 10, 0, 42)
titleDiv.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
titleDiv.BorderSizePixel = 0

-- ===================== BOTÃO 〽️ =====================

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0, 25)
openBtn.BackgroundTransparency = 1
openBtn.Text = "〽️"
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Visible = false
addWhiteStroke(openBtn)

-- ===================== SIDEBAR =====================

local sidebar = Instance.new("Frame", frame)
sidebar.Size = UDim2.new(0, 60, 1, -58)
sidebar.Position = UDim2.new(0, 10, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sideDiv = Instance.new("Frame", frame)
sideDiv.Size = UDim2.new(0, 1, 1, -58)
sideDiv.Position = UDim2.new(0, 74, 0, 48)
sideDiv.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
sideDiv.BorderSizePixel = 0

local btnFuncoes = Instance.new("TextButton", sidebar)
btnFuncoes.Size = UDim2.new(1, 0, 0, 60)
btnFuncoes.Position = UDim2.new(0, 0, 0, 8)
btnFuncoes.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
btnFuncoes.Text = "⚡\nFUNÇÕES"
btnFuncoes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFuncoes.Font = Enum.Font.GothamBold
btnFuncoes.TextSize = 9
btnFuncoes.TextWrapped = true
Instance.new("UICorner", btnFuncoes).CornerRadius = UDim.new(0, 8)

local btnInfo = Instance.new("TextButton", sidebar)
btnInfo.Size = UDim2.new(1, 0, 0, 60)
btnInfo.Position = UDim2.new(0, 0, 0, 76)
btnInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
btnInfo.Text = "ℹ️\nINFO"
btnInfo.TextColor3 = Color3.fromRGB(180, 140, 255)
btnInfo.Font = Enum.Font.GothamBold
btnInfo.TextSize = 9
btnInfo.TextWrapped = true
Instance.new("UICorner", btnInfo).CornerRadius = UDim.new(0, 8)

-- ===================== CONTAINER FUNÇÕES =====================

local container = Instance.new("Frame", frame)
container.Size = UDim2.new(0, 278, 1, -58)
container.Position = UDim2.new(0, 82, 0, 48)
container.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

-- ===================== CONTAINER INFORMAÇÕES =====================

local containerInfo = Instance.new("Frame", frame)
containerInfo.Size = UDim2.new(0, 278, 1, -58)
containerInfo.Position = UDim2.new(0, 82, 0, 48)
containerInfo.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
containerInfo.BorderSizePixel = 0
containerInfo.Visible = false
Instance.new("UICorner", containerInfo).CornerRadius = UDim.new(0, 10)

local instaLabel = Instance.new("TextLabel", containerInfo)
instaLabel.Size = UDim2.new(1, -20, 0, 22)
instaLabel.Position = UDim2.new(0, 10, 0, 20)
instaLabel.BackgroundTransparency = 1
instaLabel.Text = "📸 INSTAGRAM DO CRIADOR:"
instaLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
instaLabel.Font = Enum.Font.GothamBold
instaLabel.TextSize = 12
instaLabel.TextXAlignment = Enum.TextXAlignment.Left

local instaBtn = Instance.new("TextButton", containerInfo)
instaBtn.Size = UDim2.new(1, -20, 0, 36)
instaBtn.Position = UDim2.new(0, 10, 0, 48)
instaBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 80)
instaBtn.Text = "@4ll4n_ofc"
instaBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
instaBtn.Font = Enum.Font.GothamBold
instaBtn.TextSize = 14
Instance.new("UICorner", instaBtn).CornerRadius = UDim.new(0, 8)
addWhiteStroke(instaBtn)

local instaHint = Instance.new("TextLabel", containerInfo)
instaHint.Size = UDim2.new(1, -20, 0, 18)
instaHint.Position = UDim2.new(0, 10, 0, 90)
instaHint.BackgroundTransparency = 1
instaHint.Text = "👆 Toque para copiar o perfil"
instaHint.TextColor3 = Color3.fromRGB(120, 120, 135)
instaHint.Font = Enum.Font.Gotham
instaHint.TextSize = 11
instaHint.TextXAlignment = Enum.TextXAlignment.Left

-- Mensagem de copiado (no final de tudo)
local copiadoLabel = Instance.new("TextLabel", containerInfo)
copiadoLabel.Size = UDim2.new(1, -20, 0, 22)
copiadoLabel.Position = UDim2.new(0, 10, 1, -26)
copiadoLabel.BackgroundTransparency = 1
copiadoLabel.Text = ""
copiadoLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
copiadoLabel.Font = Enum.Font.GothamBold
copiadoLabel.TextSize = 12
copiadoLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Divisor
local statsDiv = Instance.new("Frame", containerInfo)
statsDiv.Size = UDim2.new(1, -20, 0, 1)
statsDiv.Position = UDim2.new(0, 10, 0, 115)
statsDiv.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
statsDiv.BorderSizePixel = 0

-- Função para criar card vertical
local function criarStatCard(posY, numero, rotulo)
    local card = Instance.new("Frame", containerInfo)
    card.Size = UDim2.new(1, -20, 0, 30)
    card.Position = UDim2.new(0, 10, 0, posY)
    card.BackgroundColor3 = Color3.fromRGB(40, 20, 80)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    addWhiteStroke(card)

    local num = Instance.new("TextLabel", card)
    num.Size = UDim2.new(0.5, 0, 1, 0)
    num.Position = UDim2.new(0, 10, 0, 0)
    num.BackgroundTransparency = 1
    num.Text = numero
    num.TextColor3 = Color3.fromRGB(200, 150, 255)
    num.Font = Enum.Font.GothamBold
    num.TextSize = 15
    num.TextXAlignment = Enum.TextXAlignment.Left

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.5, -10, 1, 0)
    lbl.Position = UDim2.new(0.5, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = rotulo
    lbl.TextColor3 = Color3.fromRGB(160, 160, 180)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Right
end

criarStatCard(122, "921",   "📸 Posts")
criarStatCard(158, "2.251", "👥 Seguidores")
criarStatCard(194, "136",   "➡️ Seguindo")

instaBtn.MouseButton1Click:Connect(function()
    vibrar()
    setclipboard("@4ll4n_ofc")
    copiadoLabel.Text = "✅ Copiado para área de transferência!"
    task.spawn(function()
        task.wait(2.5)
        copiadoLabel.Text = ""
    end)
end)

-- ===================== LÓGICA DAS ABAS =====================

local function abrirFuncoes()
    container.Visible = true
    containerInfo.Visible = false
    btnFuncoes.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
    btnFuncoes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnInfo.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btnInfo.TextColor3 = Color3.fromRGB(180, 140, 255)
end

local function abrirInfo()
    container.Visible = false
    containerInfo.Visible = true
    btnInfo.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
    btnInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFuncoes.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btnFuncoes.TextColor3 = Color3.fromRGB(180, 140, 255)
end

btnFuncoes.MouseButton1Click:Connect(function() vibrar() abrirFuncoes() end)
btnInfo.MouseButton1Click:Connect(function() vibrar() abrirInfo() end)

-- ===================== FUNÇÃO: CRIAR LINHA =====================

local function criarLinha(parent, posY, nome)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -20, 0, 50)
    row.Position = UDim2.new(0, 10, 0, posY)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 140, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Text = nome
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local divV = Instance.new("Frame", row)
    divV.Size = UDim2.new(0, 1, 0, 30)
    divV.Position = UDim2.new(0, 155, 0.5, -15)
    divV.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divV.BorderSizePixel = 0

    return row
end

local function criarDivisorH(parent, posY)
    local div = Instance.new("Frame", parent)
    div.Size = UDim2.new(1, -20, 0, 1)
    div.Position = UDim2.new(0, 10, 0, posY)
    div.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    div.BorderSizePixel = 0
end

-- ===================== FPS BOOSTER =====================

local rowFPS = criarLinha(container, 10, "FPS Booster")

local fpsBox = Instance.new("Frame", rowFPS)
fpsBox.Size = UDim2.new(0, 28, 0, 28)
fpsBox.Position = UDim2.new(1, -38, 0.5, -14)
fpsBox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
Instance.new("UICorner", fpsBox).CornerRadius = UDim.new(0, 6)
addWhiteStroke(fpsBox)

local fpsBtn = Instance.new("TextButton", rowFPS)
fpsBtn.Size = UDim2.new(0, 28, 0, 28)
fpsBtn.Position = UDim2.new(1, -38, 0.5, -14)
fpsBtn.BackgroundTransparency = 1
fpsBtn.Text = ""

criarDivisorH(container, 68)

-- ===================== SEMPRE DIA =====================

local rowDia = criarLinha(container, 76, "Sempre Dia")

local diaBox = Instance.new("Frame", rowDia)
diaBox.Size = UDim2.new(0, 28, 0, 28)
diaBox.Position = UDim2.new(1, -38, 0.5, -14)
diaBox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
Instance.new("UICorner", diaBox).CornerRadius = UDim.new(0, 6)
addWhiteStroke(diaBox)

local diaBtn = Instance.new("TextButton", rowDia)
diaBtn.Size = UDim2.new(0, 28, 0, 28)
diaBtn.Position = UDim2.new(1, -38, 0.5, -14)
diaBtn.BackgroundTransparency = 1
diaBtn.Text = ""

criarDivisorH(container, 134)

-- ===================== VELOCIDADE =====================

local rowVel = criarLinha(container, 142, "Velocidade")

local velInput = Instance.new("TextBox", rowVel)
velInput.Size = UDim2.new(0, 72, 0, 30)
velInput.Position = UDim2.new(1, -120, 0.5, -15)
velInput.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
velInput.TextColor3 = Color3.fromRGB(255, 255, 255)
velInput.PlaceholderText = "Insira um valor"
velInput.PlaceholderColor3 = Color3.fromRGB(110, 110, 120)
velInput.Text = ""
velInput.Font = Enum.Font.GothamBold
velInput.TextSize = 11
velInput.ClearTextOnFocus = true
Instance.new("UICorner", velInput).CornerRadius = UDim.new(0, 6)
addWhiteStroke(velInput)

local velOkBtn = Instance.new("TextButton", rowVel)
velOkBtn.Size = UDim2.new(0, 36, 0, 30)
velOkBtn.Position = UDim2.new(1, -42, 0.5, -15)
velOkBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
velOkBtn.Text = "OK"
velOkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
velOkBtn.Font = Enum.Font.GothamBold
velOkBtn.TextSize = 13
Instance.new("UICorner", velOkBtn).CornerRadius = UDim.new(0, 6)
addWhiteStroke(velOkBtn)

-- Mensagem abaixo da velocidade
local velMsgLabel = Instance.new("TextLabel", container)
velMsgLabel.Size = UDim2.new(1, -20, 0, 30)
velMsgLabel.Position = UDim2.new(0, 10, 0, 175)
velMsgLabel.BackgroundTransparency = 1
velMsgLabel.Text = ""
velMsgLabel.TextColor3 = Color3.fromRGB(0, 220, 0)
velMsgLabel.Font = Enum.Font.GothamBold
velMsgLabel.TextSize = 12
velMsgLabel.TextXAlignment = Enum.TextXAlignment.Center

criarDivisorH(container, 210)

-- ===================== SUPER PULO =====================

local rowPulo = criarLinha(container, 218, "Super Pulo")

local puloBox = Instance.new("Frame", rowPulo)
puloBox.Size = UDim2.new(0, 28, 0, 28)
puloBox.Position = UDim2.new(1, -38, 0.5, -14)
puloBox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
Instance.new("UICorner", puloBox).CornerRadius = UDim.new(0, 6)
addWhiteStroke(puloBox)

local puloBtn = Instance.new("TextButton", rowPulo)
puloBtn.Size = UDim2.new(0, 28, 0, 28)
puloBtn.Position = UDim2.new(1, -38, 0.5, -14)
puloBtn.BackgroundTransparency = 1
puloBtn.Text = ""

-- ===================== ESTADOS =====================

local fpsAtivo = false
local diaAtivo = false
local puloAtivo = false
local boostLoop = nil
local diaLoop = nil

-- Salva ORIGINAIS do Lighting
local origClock      = Lighting.ClockTime
local origFogEnd     = Lighting.FogEnd
local origFogStart   = Lighting.FogStart
local origFogColor   = Lighting.FogColor
local origBrightness = Lighting.Brightness

local origAtmosphere = {}
local origColorCorrection = {}
local origEffectsEnabled = {}

for _, v in pairs(Lighting:GetChildren()) do
    if v:IsA("Atmosphere") then
        origAtmosphere = {
            Density = v.Density,
            Haze    = v.Haze,
            Glare   = v.Glare,
            Offset  = v.Offset,
            Color   = v.Color,
        }
    elseif v:IsA("ColorCorrectionEffect") then
        origColorCorrection[v] = {
            Brightness = v.Brightness,
            Contrast   = v.Contrast,
            Saturation = v.Saturation,
            TintColor  = v.TintColor,
            Enabled    = v.Enabled,
        }
    elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
        origEffectsEnabled[v] = v.Enabled
    end
end

-- ===================== FPS BOOSTER LÓGICA (com restauração) =====================

local origBoostData = {}

local function salvarEAplicarBoost(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
        if origBoostData[v] == nil then
            origBoostData[v] = { tipo = "efeito", Enabled = v.Enabled }
        end
        v.Enabled = false
    elseif v:IsA("BasePart") then
        if origBoostData[v] == nil then
            origBoostData[v] = { tipo = "part", Material = v.Material, CastShadow = v.CastShadow }
        end
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if origBoostData[v] == nil then
            origBoostData[v] = { tipo = "decal", Transparency = v.Transparency }
        end
        v.Transparency = 1
    end
end

local function restaurarBoost()
    for obj, dados in pairs(origBoostData) do
        pcall(function()
            if dados.tipo == "efeito" then
                obj.Enabled = dados.Enabled
            elseif dados.tipo == "part" then
                obj.Material   = dados.Material
                obj.CastShadow = dados.CastShadow
            elseif dados.tipo == "decal" then
                obj.Transparency = dados.Transparency
            end
        end)
    end
    origBoostData = {}
end

local function startBoost()
    task.spawn(function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            salvarEAplicarBoost(v)
            count += 1
            if count % 50 == 0 then task.wait() end
        end
    end)
    boostLoop = workspace.DescendantAdded:Connect(salvarEAplicarBoost)
end

local function stopBoost()
    if boostLoop then boostLoop:Disconnect(); boostLoop = nil end
    restaurarBoost()
end

local function updateFpsBox()
    fpsBox.BackgroundColor3 = fpsAtivo and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 65)
end

fpsBtn.MouseButton1Click:Connect(function()
    fpsAtivo = not fpsAtivo
    updateFpsBox()
    vibrar()
    if fpsAtivo then startBoost() else stopBoost() end
end)

-- ===================== SEMPRE DIA LÓGICA =====================

local function applyDia()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.FogEnd   = 9e9
    Lighting.FogStart = 9e9

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            pcall(function() v.StarCount = 0 end)
        elseif v:IsA("Atmosphere") then
            v.Density = 0
            v.Haze    = 0
            v.Glare   = 0
            v.Offset  = 0
        elseif v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
            or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end

local function restoreDia()
    Lighting.ClockTime = origClock
    Lighting.Brightness = origBrightness
    Lighting.FogEnd   = origFogEnd
    Lighting.FogStart = origFogStart
    Lighting.FogColor = origFogColor

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            pcall(function() v.StarCount = 3000 end)
        elseif v:IsA("Atmosphere") then
            if origAtmosphere.Density ~= nil then
                v.Density = origAtmosphere.Density
                v.Haze    = origAtmosphere.Haze
                v.Glare   = origAtmosphere.Glare
                v.Offset  = origAtmosphere.Offset
                v.Color   = origAtmosphere.Color
            end
        elseif v:IsA("ColorCorrectionEffect") then
            local orig = origColorCorrection[v]
            if orig then
                v.Brightness = orig.Brightness
                v.Contrast   = orig.Contrast
                v.Saturation = orig.Saturation
                v.TintColor  = orig.TintColor
                v.Enabled    = orig.Enabled
            else
                v.Enabled = true
            end
        elseif v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
            local origEnabled = origEffectsEnabled[v]
            v.Enabled = origEnabled ~= nil and origEnabled or true
        end
    end
end

local function updateDiaBox()
    diaBox.BackgroundColor3 = diaAtivo and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 65)
end

diaBtn.MouseButton1Click:Connect(function()
    diaAtivo = not diaAtivo
    updateDiaBox()
    vibrar()

    if diaAtivo then
        applyDia()
        diaLoop = RunService.Heartbeat:Connect(function()
            if Lighting.ClockTime < 13 or Lighting.ClockTime > 15 then
                Lighting.ClockTime = 14
            end
            if Lighting.FogEnd < 1e8 then
                Lighting.FogEnd   = 9e9
                Lighting.FogStart = 9e9
            end
        end)
    else
        if diaLoop then diaLoop:Disconnect(); diaLoop = nil end
        restoreDia()
    end
end)

-- ===================== VELOCIDADE =====================

local speedValue = 50

local function applySpeed(v)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end

velOkBtn.MouseButton1Click:Connect(function()
    vibrar()
    local v = tonumber(velInput.Text)
    if v and v > 0 then
        if v > 180 then
            velMsgLabel.Text = "⚠️ Não ultrapasse 180!"
            velMsgLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            speedValue = 180
            applySpeed(180)
            task.spawn(function()
                task.wait(2.5)
                velMsgLabel.Text = ""
                velMsgLabel.TextColor3 = Color3.fromRGB(0, 220, 0)
            end)
            return
        end
        speedValue = v
        applySpeed(v)
        velMsgLabel.Text = "✅ Velocidade " .. v .. " aplicada!"
        velMsgLabel.TextColor3 = Color3.fromRGB(0, 220, 0)
        task.spawn(function()
            task.wait(2.5)
            velMsgLabel.Text = ""
        end)
    else
        velMsgLabel.Text = "❌ Valor inválido!"
        velMsgLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.spawn(function()
            task.wait(2.5)
            velMsgLabel.Text = ""
            velMsgLabel.TextColor3 = Color3.fromRGB(0, 220, 0)
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= speedValue then
            hum.WalkSpeed = speedValue
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applySpeed(speedValue)
end)

-- Aplica velocidade inicial imediatamente
applySpeed(speedValue)

-- ===================== TRAVAR CÂMERA LÓGICA =====================

local UserInputService = game:GetService("UserInputService")

-- ===================== SUPER PULO LÓGICA =====================

local origJumpPower = nil

local function updatePuloBox()
    puloBox.BackgroundColor3 = puloAtivo and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 65)
end

puloBtn.MouseButton1Click:Connect(function()
    puloAtivo = not puloAtivo
    updatePuloBox()
    vibrar()

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if puloAtivo then
        if hum then
            origJumpPower = hum.JumpPower
            hum.JumpPower = 180
        end
        -- Mantém o JumpPower ao trocar de personagem
        player.CharacterAdded:Connect(function(newChar)
            if not puloAtivo then return end
            task.wait(0.5)
            local newHum = newChar:FindFirstChildOfClass("Humanoid")
            if newHum then newHum.JumpPower = 180 end
        end)
    else
        if hum then
            hum.JumpPower = origJumpPower or 50
        end
        origJumpPower = nil
    end
end)

-- ===================== MINIMIZAR =====================

local visivel = false
openBtn.MouseButton1Click:Connect(function()
    if contadorAtivo then return end
    visivel = not visivel
    frame.Visible = visivel
    if visivel then centerFrame(frame) end
end)

-- ===================== LOGIN LÓGICA =====================

-- Contador ao lado do botão 〽️
local contadorLabel = Instance.new("TextLabel", gui)
contadorLabel.Size = UDim2.new(0, 130, 0, 40)
contadorLabel.Position = UDim2.new(0, 68, 0, 25)
contadorLabel.BackgroundTransparency = 1
contadorLabel.Text = ""
contadorLabel.TextColor3 = Color3.fromRGB(0, 220, 0)
contadorLabel.Font = Enum.Font.GothamBold
contadorLabel.TextSize = 13
contadorLabel.TextXAlignment = Enum.TextXAlignment.Left
contadorLabel.Visible = false

local contadorAtivo = false

local function iniciarContador()
    contadorAtivo = true
    contadorLabel.Visible = true
    task.spawn(function()
        for i = 10, 1, -1 do
            contadorLabel.Text = "⏳ " .. i .. "s"
            task.wait(1)
        end
        contadorLabel.Text = "✅ Pronto!"
        task.wait(2)
        contadorLabel.Visible = false
        contadorAtivo = false
    end)
end

entrarBtn.MouseButton1Click:Connect(function()
    vibrar()
    local digitado = senhaReal
    if digitado == "gggg" then
        loginFrame.Visible = false
        frame.Visible = false
        openBtn.Visible = true
        iniciarContador()
    else
        erroLabel.Text = "❌ Senha incorreta! Tente novamente."
        senhaReal = ""
        senhaInput.Text = ""
        task.spawn(function()
            task.wait(2.5)
            erroLabel.Text = ""
        end)
    end
end)

-- ===================== INIT =====================

updateFpsBox()
updateDiaBox()
updatePuloBox()
