local Terrain = workspace:WaitForChild("Terrain")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- CONFIGURAÇÕES GLOBAIS V5.1.3 (SINTAXE COMPACTA)
local active = false
local mode = "Add" 
local brushSize = 12 
local currentMaterial = Enum.Material.Grass
local selectedBiome = "Planície"
local isMouseDown = false
local lastGen = 0
local genDelay = 0.08 
local minimized = false
local heightMultiplier = 1.00
local densityStep = 8 

local terrainHistory = {} 
local currentPage = 1
local linesPerPage = 800 -- DOBRADO devido à compactação
local state = { p1 = nil, p2 = nil, m1 = nil, m2 = nil, lastBiomeBtn = nil, lastMatBtn = nil }

local biomes = {
	["Planície"] = {mat = Enum.Material.Grass, decor = Enum.Material.Ground, h = 15},
	["Montanha"] = {mat = Enum.Material.Rock, decor = Enum.Material.Snow, h = 100},
	["Deserto"] = {mat = Enum.Material.Sand, decor = Enum.Material.Sandstone, h = 25},
	["Selva"] = {mat = Enum.Material.LeafyGrass, decor = Enum.Material.Mud, h = 50},
	["Pântano"] = {mat = Enum.Material.Mud, decor = Enum.Material.LeafyGrass, h = 10},
	["Canyon"] = {mat = Enum.Material.Sandstone, decor = Enum.Material.Rock, h = 70},
	["Ártico"] = {mat = Enum.Material.Ice, decor = Enum.Material.Snow, h = 30},
	["Oceano Seco"] = {mat = Enum.Material.Salt, decor = Enum.Material.Sand, h = 5},
	["Vulcão"] = {mat = Enum.Material.Basalt, decor = Enum.Material.CrackedLava, h = 95},
	["Floresta Morta"] = {mat = Enum.Material.Ground, decor = Enum.Material.Slate, h = 40},
	["Abismo"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Basalt, h = 80},
	["Caverna Cristal"] = {mat = Enum.Material.Rock, decor = Enum.Material.Glacier, h = 60},
	["Mina"] = {mat = Enum.Material.Slate, decor = Enum.Material.WoodPlanks, h = 45},
	["Gruta Neon"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Neon, h = 50},
	["Cordilheira"] = {mat = Enum.Material.Slate, decor = Enum.Material.Rock, h = 120},
	["Platô Rubi"] = {mat = Enum.Material.Sandstone, decor = Enum.Material.CrackedLava, h = 40},
	["Vale das Almas"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Neon, h = 35},
	["Fenda Profunda"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Slate, h = 110},
	["Rocha Negra"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Basalt, h = 60},
	["Costa de Sal"] = {mat = Enum.Material.Salt, decor = Enum.Material.Water, h = 15},
	["Cid. Futurista"] = {mat = Enum.Material.Asphalt, decor = Enum.Material.Neon, h = 80},
	["Cid. Cyberpunk"] = {mat = Enum.Material.Metal, decor = Enum.Material.Neon, h = 100},
	["Vila Medieval"] = {mat = Enum.Material.Ground, decor = Enum.Material.Cobblestone, h = 40},
	["Ilha Flutuante"] = {mat = Enum.Material.Grass, decor = Enum.Material.Ground, h = 50},
	["Mundo de Doces"] = {mat = Enum.Material.Salt, decor = Enum.Material.Glacier, h = 30},
	["Cristalino"] = {mat = Enum.Material.Glacier, decor = Enum.Material.Ice, h = 70},
	["Eldritch"] = {mat = Enum.Material.Basalt, decor = Enum.Material.Neon, h = 90},
	["Base Lunar"] = {mat = Enum.Material.Concrete, decor = Enum.Material.Slate, h = 30},
	["Marte"] = {mat = Enum.Material.Sandstone, decor = Enum.Material.Rock, h = 25},
	["Inferno"] = {mat = Enum.Material.Basalt, decor = Enum.Material.CrackedLava, h = 100}
}

local sg = player.PlayerGui:FindFirstChild("EliteGUI") or Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "EliteGUI"

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 260, 0, 520)
mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Active, mainFrame.Draggable = true, true
Instance.new("UICorner", mainFrame)

local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.ZIndex = 10
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Size, title.Position, title.Text = UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 10, 0, 0), "TERRAIN ELITE SUPREME V5.1.3"
title.TextColor3, title.Font, title.TextSize, title.ZIndex = Color3.new(1, 1, 1), Enum.Font.GothamBold, 10, 11
title.BackgroundTransparency, title.TextXAlignment = 1, Enum.TextXAlignment.Left

local content = Instance.new("ScrollingFrame", mainFrame)
content.Size = UDim2.new(1, 0, 1, -40)
content.Position = UDim2.new(0, 0, 0, 40)
content.BackgroundTransparency, content.CanvasSize = 1, UDim2.new(0, 0, 0, 3400)
content.ScrollBarThickness, content.ZIndex = 4, 5

local minBtn = Instance.new("TextButton", header)
minBtn.Size, minBtn.Position, minBtn.Text = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "-"
minBtn.BackgroundColor3, minBtn.TextColor3, minBtn.ZIndex = Color3.fromRGB(200, 50, 50), Color3.new(1, 1, 1), 12
Instance.new("UICorner", minBtn)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 520)
    minBtn.Text = minimized and "+" or "-"
end)

local function isMouseOnUI()
    local objs = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
    for _, o in pairs(objs) do if o:IsDescendantOf(mainFrame) then return true end end
    return false
end

local function createBtn(text, y, color, callback, parent)
	local b = Instance.new("TextButton", parent or content)
	b.Size, b.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, y)
	b.Text, b.BackgroundColor3 = text, color
	b.TextColor3, b.Font, b.TextSize, b.ZIndex = Color3.new(1, 1, 1), Enum.Font.GothamMedium, 10, 7
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function() callback(b) end)
	return b
end

local function createLabel(text, y)
    local l = Instance.new("TextLabel", content)
    l.Size, l.Position, l.Text = UDim2.new(1,0,0,20), UDim2.new(0,0,0,y), "-- "..text.." --"
    l.BackgroundTransparency, l.TextColor3, l.Font, l.TextSize = 1, Color3.new(0.7,0.7,0.7), Enum.Font.GothamBold, 9
    return l
end

createLabel("SISTEMA DE CÓDIGO", 10)
local codeScroll = Instance.new("ScrollingFrame", content)
codeScroll.Size, codeScroll.Position = UDim2.new(0.9, 0, 0, 80), UDim2.new(0.05, 0, 0, 35)
codeScroll.BackgroundColor3, codeScroll.ZIndex = Color3.fromRGB(10, 10, 10), 5
Instance.new("UICorner", codeScroll)

local exportBox = Instance.new("TextBox", codeScroll)
exportBox.Size, exportBox.AutomaticSize, exportBox.Position = UDim2.new(1, -10, 0, 0), Enum.AutomaticSize.Y, UDim2.new(0, 5, 0, 5)
exportBox.BackgroundTransparency, exportBox.TextColor3, exportBox.TextSize = 1, Color3.fromRGB(0, 255, 0), 7
exportBox.MultiLine, exportBox.ClearTextOnFocus, exportBox.TextEditable = true, false, false
exportBox.TextXAlignment, exportBox.TextYAlignment, exportBox.Text, exportBox.ZIndex = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top, "CÓDIGO V5.1.3", 6

local pageLabel = Instance.new("TextLabel", content)
pageLabel.Size, pageLabel.Position = UDim2.new(0.4, 0, 0, 25), UDim2.new(0.3, 0, 0, 120)
pageLabel.BackgroundTransparency, pageLabel.TextColor3, pageLabel.Text = 1, Color3.new(1,1,1), "Pág: 1/1"
pageLabel.Font, pageLabel.TextSize = Enum.Font.GothamBold, 9

local function updateCodeView()
    if #terrainHistory == 0 then exportBox.Text = "HISTÓRICO VAZIO" return end
    local totalPages = math.ceil(#terrainHistory / linesPerPage)
    currentPage = math.clamp(currentPage, 1, totalPages)
    
    local res = {
        "local t=workspace.Terrain local function B(x,y,z,s,m) t:FillBall(Vector3.new(x,y,z),s,m) end",
        "-- Pag "..currentPage.."/"..totalPages
    }
    
    local startIdx = (currentPage - 1) * linesPerPage + 1
    local endIdx = math.min(startIdx + linesPerPage - 1, #terrainHistory)
    
    for i = startIdx, endIdx do
        local d = terrainHistory[i]
        table.insert(res, string.format("B(%.1f,%.1f,%.1f,%.1f,Enum.Material.%s)", d.p.X, d.p.Y, d.p.Z, d.s, d.m.Name))
    end
    
    exportBox.Text = table.concat(res, "\n")
    pageLabel.Text = "Pág: "..currentPage.."/"..totalPages
    task.wait(0.1)
    codeScroll.CanvasSize = UDim2.new(0, 0, 0, exportBox.TextBounds.Y + 10)
end

createBtn("<", 120, Color3.fromRGB(40,40,40), function() currentPage = currentPage - 1 updateCodeView() end).Size = UDim2.new(0.2,0,0,25)
createBtn(">", 120, Color3.fromRGB(40,40,40), function() currentPage = currentPage + 1 updateCodeView() end).Size = UDim2.new(0.2,0,0,25)
content:GetChildren()[#content:GetChildren()-1].Position = UDim2.new(0.05,0,0,120)
content:GetChildren()[#content:GetChildren()].Position = UDim2.new(0.75,0,0,120)

createBtn("GERAR CÓDIGO", 150, Color3.fromRGB(230, 126, 34), function() updateCodeView() end)
createBtn("LIMPAR TUDO", 185, Color3.fromRGB(150, 40, 40), function() terrainHistory = {} updateCodeView() end)

createLabel("CONTROLE DE RELEVO", 230)
local relBtnFrame = Instance.new("Frame", content)
relBtnFrame.Size, relBtnFrame.Position, relBtnFrame.BackgroundTransparency = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 255), 1
local relVal = Instance.new("TextBox", relBtnFrame)
relVal.Size, relVal.Position = UDim2.new(0.4, 0, 1, 0), UDim2.new(0.3, 0, 0, 0)
relVal.BackgroundColor3, relVal.TextColor3, relVal.Text = Color3.fromRGB(40,40,40), Color3.new(1,1,1), "1.00"
relVal.Font, relVal.TextSize = Enum.Font.GothamBold, 10
Instance.new("UICorner", relVal)
createBtn("-", 0, Color3.fromRGB(200, 50, 50), function() heightMultiplier = math.clamp(heightMultiplier - 0.1, 0.1, 10) relVal.Text = string.format("%.2f", heightMultiplier) end, relBtnFrame).Size = UDim2.new(0.25, 0, 1, 0)
createBtn("+", 0, Color3.fromRGB(50, 200, 100), function() heightMultiplier = math.clamp(heightMultiplier + 0.1, 0.1, 10) relVal.Text = string.format("%.2f", heightMultiplier) end, relBtnFrame).Size = UDim2.new(0.25, 0, 1, 0)
relBtnFrame:GetChildren()[2].Position, relBtnFrame:GetChildren()[3].Position = UDim2.new(0,0,0,0), UDim2.new(0.75,0,0,0)

createLabel("DENSIDADE DE GERAÇÃO", 295)
local denBtnFrame = Instance.new("Frame", content)
denBtnFrame.Size, denBtnFrame.Position, denBtnFrame.BackgroundTransparency = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 320), 1
local denVal = Instance.new("TextBox", denBtnFrame)
denVal.Size, denVal.Position = UDim2.new(0.4, 0, 1, 0), UDim2.new(0.3, 0, 0, 0)
denVal.BackgroundColor3, denVal.TextColor3, denVal.Text = Color3.fromRGB(40,40,40), Color3.new(1,1,1), "8.0"
denVal.Font, denVal.TextSize = Enum.Font.GothamBold, 10
Instance.new("UICorner", denVal)
createBtn("-", 0, Color3.fromRGB(200, 50, 50), function() densityStep = math.clamp(densityStep - 1, 3, 20) denVal.Text = string.format("%.1f", densityStep) end, denBtnFrame).Size = UDim2.new(0.25, 0, 1, 0)
createBtn("+", 0, Color3.fromRGB(50, 200, 100), function() densityStep = math.clamp(densityStep + 1, 3, 20) denVal.Text = string.format("%.1f", densityStep) end, denBtnFrame).Size = UDim2.new(0.25, 0, 1, 0)
denBtnFrame:GetChildren()[2].Position, denBtnFrame:GetChildren()[3].Position = UDim2.new(0,0,0,0), UDim2.new(0.75,0,0,0)

createLabel("CONFIGURAÇÕES DO PINCEL", 365)
createBtn("STATUS: OFF", 390, Color3.fromRGB(60,60,60), function(b)
    active = not active
    b.Text = active and "STATUS: ATIVO" or "STATUS: OFF"
    b.BackgroundColor3 = active and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60,60,60)
end)

createBtn("MODO: ADICIONAR", 425, Color3.fromRGB(52, 152, 219), function(b)
    mode = (mode == "Add" and "Sub" or "Add")
    b.Text = mode == "Add" and "MODO: ADICIONAR" or "MODO: BORRACHA"
    b.BackgroundColor3 = mode == "Add" and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(211, 84, 0)
end)

-- CORREÇÃO DEFINITIVA DO RAIO: ZINDEX ALTO + CAPTUREFOCUS
local sizeBox = Instance.new("TextBox", content)
sizeBox.Size, sizeBox.Position = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 460)
sizeBox.BackgroundColor3, sizeBox.Text, sizeBox.TextColor3 = Color3.fromRGB(40,40,40), "12", Color3.new(1,1,1)
sizeBox.ZIndex = 25 -- Garante que receba o clique acima do fundo do ScrollingFrame
Instance.new("UICorner", sizeBox)

sizeBox.Focused:Connect(function() 
	sizeBox.Text = "" -- Limpa ao clicar para facilitar a digitação
end)

sizeBox.FocusLost:Connect(function() 
    local n = tonumber(sizeBox.Text) 
    if n then brushSize = n end 
    sizeBox.Text = tostring(brushSize) 
end)

createLabel("GERADOR DE BIOMAS", 505)
local biomeScroll = Instance.new("ScrollingFrame", content)
biomeScroll.Size, biomeScroll.Position = UDim2.new(0.9, 0, 0, 100), UDim2.new(0.05, 0, 0, 530)
biomeScroll.BackgroundColor3, biomeScroll.ZIndex = Color3.fromRGB(10, 10, 10), 20 
biomeScroll.CanvasSize = UDim2.new(0, 0, 0, 550) 
Instance.new("UICorner", biomeScroll)

local biomeGrid = Instance.new("UIGridLayout", biomeScroll)
biomeGrid.CellSize, biomeGrid.CellPadding = UDim2.new(0, 100, 0, 30), UDim2.new(0, 5, 0, 5)

for name, _ in pairs(biomes) do
	local b = Instance.new("TextButton", biomeScroll)
	b.Text, b.BackgroundColor3, b.TextColor3 = name, Color3.fromRGB(40, 40, 40), Color3.new(1, 1, 1)
	b.Font, b.TextSize, b.ZIndex = Enum.Font.Gotham, 9, 21 
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function()
		if state.lastBiomeBtn then state.lastBiomeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
		selectedBiome, state.lastBiomeBtn = name, b
		b.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	end)
end

createBtn("PONTO 1", 640, Color3.fromRGB(0, 120, 255), function() 
    local conn; conn = mouse.Button1Down:Connect(function()
        if isMouseOnUI() then return end
        local p = mouse.Hit.p
        if state.m1 then state.m1:Destroy() end
        state.m1 = Instance.new("Part", workspace)
        state.m1.Size, state.m1.Position, state.m1.Anchored, state.m1.CanCollide = Vector3.new(2,2,2), p, true, false
        state.m1.Material, state.m1.Color = Enum.Material.Neon, Color3.new(0, 0.5, 1)
        state.p1 = p conn:Disconnect()
    end)
end)

createBtn("PONTO 2", 675, Color3.fromRGB(0, 200, 100), function() 
    local conn; conn = mouse.Button1Down:Connect(function()
        if isMouseOnUI() then return end
        local p = mouse.Hit.p
        if state.m2 then state.m2:Destroy() end
        state.m2 = Instance.new("Part", workspace)
        state.m2.Size, state.m2.Position, state.m2.Anchored, state.m2.CanCollide = Vector3.new(2,2,2), p, true, false
        state.m2.Material, state.m2.Color = Enum.Material.Neon, Color3.new(0, 1, 0.5)
        state.p2 = p conn:Disconnect()
    end)
end)

createBtn("GERAR BIOMA", 710, Color3.fromRGB(255, 140, 0), function()
    if not state.p1 or not state.p2 then return end
    local data = biomes[selectedBiome]
    local min = Vector3.new(math.min(state.p1.X, state.p2.X), math.min(state.p1.Y, state.p2.Y), math.min(state.p1.Z, state.p2.Z))
    local max = Vector3.new(math.max(state.p1.X, state.p2.X), math.max(state.p1.Y, state.p2.Y), math.max(state.p1.Z, state.p2.Z))
    for x = min.X, max.X, densityStep do 
        for z = min.Z, max.Z, densityStep do
            task.wait() 
            local noise = math.noise(x/60, z/60, 555)
            local h = min.Y + (noise + 0.5) * (data.h * heightMultiplier)
            local pos1, pos2 = Vector3.new(x, h, z), Vector3.new(x, h - 8, z)
            Terrain:FillBall(pos1, 6, data.mat)
            Terrain:FillBall(pos2, 10, data.decor)
            table.insert(terrainHistory, {p=pos1, s=6, m=data.mat})
            table.insert(terrainHistory, {p=pos2, s=10, m=data.decor})
        end
    end
end)

createBtn("LIMPAR SELEÇÃO", 745, Color3.fromRGB(211, 84, 0), function()
    if not state.p1 or not state.p2 then return end
    local min = Vector3.new(math.min(state.p1.X, state.p2.X), -500, math.min(state.p1.Z, state.p2.Z))
    local max = Vector3.new(math.max(state.p1.X, state.p2.X), 500, math.max(state.p1.Z, state.p2.Z))
    Terrain:FillBlock(CFrame.new((min + max) / 2), max - min, Enum.Material.Air)
end)

local function setMat(name, btn) 
    local success, mat = pcall(function() return Enum.Material[name] end) 
    if success then 
        if state.lastMatBtn then state.lastMatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end
        currentMaterial, state.lastMatBtn = mat, btn
        btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    end 
end

local categories = {{t="ORGÂNICOS", m={"Grass", "LeafyGrass", "Moss", "Mud", "Ground", "LeafyDirt"}},{t="GEOLÓGICOS", m={"Rock", "Basalt", "Limestone", "Sandstone", "Slate", "Salt", "Sand"}},{t="ESTRUTURAIS", m={"Asphalt", "Pavement", "Brick", "Cobblestone", "Concrete", "WoodPlanks"}},{t="ESPECIAIS", m={"Glacier", "Ice", "Snow", "CrackedLava", "Neon", "Water", "Air"}}}
local currentY = 790
for _, cat in ipairs(categories) do 
    createLabel(cat.t, currentY) currentY = currentY + 25 
    for _, m in ipairs(cat.m) do createBtn(m, currentY, Color3.fromRGB(30, 30, 30), function(b) setMat(m, b) end) currentY = currentY + 35 end 
end

local indicator = Instance.new("Part", workspace)
indicator.Shape, indicator.Material, indicator.Anchored, indicator.CanCollide, indicator.Transparency = Enum.PartType.Ball, Enum.Material.ForceField, true, false, 1

local previewPart = Instance.new("Part")
previewPart.Material, previewPart.Color, previewPart.Transparency, previewPart.Anchored, previewPart.CanCollide = Enum.Material.Neon, Color3.fromRGB(0, 255, 255), 0.6, true, false

RunService.RenderStepped:Connect(function()
    if active then
        mouse.TargetFilter = indicator
        indicator.Size, indicator.Position = Vector3.new(brushSize, brushSize, brushSize), mouse.Hit.p
        indicator.Transparency = isMouseDown and 1 or 0.5
        indicator.Color = mode == "Add" and Color3.new(0, 1, 0.5) or Color3.new(1, 0, 0)
        
        if state.p1 and state.p2 then
            previewPart.Parent = workspace
            local min = Vector3.new(math.min(state.p1.X, state.p2.X), math.min(state.p1.Y, state.p2.Y), math.min(state.p1.Z, state.p2.Z))
            local max = Vector3.new(math.max(state.p1.X, state.p2.X), math.max(state.p1.Y, state.p2.Y), math.max(state.p1.Z, state.p2.Z))
            previewPart.Size, previewPart.CFrame = (max - min) + Vector3.new(0.1, 0.1, 0.1), CFrame.new((min + max) / 2)
        else previewPart.Parent = nil end

        if isMouseDown and not isMouseOnUI() and tick() - lastGen >= genDelay then
            lastGen = tick()
            local p, mat = mouse.Hit.p, (mode == "Add" and currentMaterial or Enum.Material.Air)
            Terrain:FillBall(p, brushSize/2, mat)
            table.insert(terrainHistory, {p=p, s=brushSize/2, m=mat})
        end
    else indicator.Transparency = 1 previewPart.Parent = nil end
end)

mouse.Button1Down:Connect(function() if active and not isMouseOnUI() then isMouseDown = true end end)
mouse.Button1Up:Connect(function() isMouseDown = false end)
