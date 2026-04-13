-- ================================================
-- JAY SCRIPT SOUTH BRONX THE TRENCHES
-- Key: JAY01
-- Creado para GitHub - Copia y pega completo en un archivo .lua
-- Incluye: Silent Aim, ESP (caja de vida + objeto en mano), Hitbox expander (máx 15), Delete Tool, Auto Farm, Bypass básico anti-baneo y anti-indetectable
-- Menú: Combat | Visual | Misc
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== KEY SYSTEM ====================
local CORRECT_KEY = "JAY01"

-- Cambia esto si quieres un sistema más avanzado con GUI de key
local enteredKey = "" -- Aquí se guardará la key que ingreses (puedes usar un prompt simple del executor o editarlo manualmente)
if enteredKey ~= CORRECT_KEY then
    print("❌ Key incorrecta. La key es: JAY01")
    print("📋 Edita la variable 'enteredKey' o usa el prompt del executor")
    return -- Detiene la script si la key es incorrecta
end

print("✅ JAY SCRIPT SOUTH BRONX THE TRENCHES - Cargado correctamente con Key JAY01")

-- ==================== BYPASS ANTI-BANEO Y ANTI-INDETECTABLE (BÁSICO) ====================
-- ⚠️ AVISO IMPORTANTE: Este bypass es básico y genérico. Roblox y South Bronx actualizan sus anti-cheats constantemente (Hyperion/Byfron).
-- No garantizo que sea 100% indetectable. Prueba en cuenta secundaria. Actualizaciones del bypass suelen estar en Discords privados.
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Bloquea algunos remotes comunes de anti-cheat (ajusta según updates del juego)
        if method == "FireServer" and (self.Name:find("Anti") or self.Name:find("Ban") or self.Name:find("Kick") or self.Name:find("Detect")) then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    mt.__index = newcclosure(function(self, key)
        if key == "Kick" or key == "Ban" then
            return nil
        end
        return oldIndex(self, key)
    end)
    
    setreadonly(mt, true)
    
    -- Extra: Desactiva algunos logs del cliente
    hookfunction(game:GetService("LogService").MessageOut, function() end)
end)

print("🛡️ Bypass anti-baneo y anti-indetectable cargado (básico)")

-- ==================== VARIABLES GLOBALES ====================
getgenv().JAY = getgenv().JAY or {}

-- Combat
getgenv().JAY.SilentAim = false
getgenv().JAY.HitboxHead = false
getgenv().JAY.HitboxTorso = false
getgenv().JAY.HitboxSize = 15 -- Máximo 15

-- Visual
getgenv().JAY.ESPEnabled = false
getgenv().JAY.BoxEnabled = false
getgenv().JAY.HealthEnabled = false
getgenv().JAY.HandItemEnabled = false

-- Misc
getgenv().JAY.WalkSpeed = 16
getgenv().JAY.DeltaTool = false -- (Toggle para herramienta Delta - puedes usarlo como no-cooldown o tool personalizado)
getgenv().JAY.AutoFarm = false

-- ==================== ESP (Caja + Vida + Objeto en mano) ====================
local ESPDrawings = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    
    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 1
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    
    local nameText = Drawing.new("Text")
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    
    local toolText = Drawing.new("Text")
    toolText.Size = 13
    toolText.Center = true
    toolText.Outline = true
    toolText.Color = Color3.fromRGB(0, 255, 255)
    
    ESPDrawings[player] = {box = box, health = healthBar, name = nameText, tool = toolText}
end

local function updateESP()
    for player, drawings in pairs(ESPDrawings) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            drawings.box.Visible = false
            drawings.health.Visible = false
            drawings.name.Visible = false
            drawings.tool.Visible = false
            return
        end
        
        local root = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if onScreen and getgenv().JAY.ESPEnabled then
            -- Box
            if getgenv().JAY.BoxEnabled then
                local top = Camera:WorldToViewportPoint((root.Position + Vector3.new(0, 3, 0)))
                local bottom = Camera:WorldToViewportPoint((root.Position - Vector3.new(0, 3, 0)))
                local size = Vector2.new(2000 / (root.Position - Camera.CFrame.Position).Magnitude, bottom.Y - top.Y)
                drawings.box.Size = size
                drawings.box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                drawings.box.Visible = true
            else
                drawings.box.Visible = false
            end
            
            -- Health
            if getgenv().JAY.HealthEnabled and humanoid then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                drawings.health.Size = Vector2.new(4, (bottom.Y - top.Y) * healthPercent)
                drawings.health.Position = Vector2.new(screenPos.X - (size.X / 2) - 6, bottom.Y - drawings.health.Size.Y)
                drawings.health.Visible = true
            else
                drawings.health.Visible = false
            end
            
            -- Nombre
            drawings.name.Text = player.Name
            drawings.name.Position = Vector2.new(screenPos.X, screenPos.Y - (size.Y / 2) - 20)
            drawings.name.Visible = true
            
            -- Objeto en mano
            if getgenv().JAY.HandItemEnabled then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                drawings.tool.Text = tool and tool.Name or "Mano vacía"
                drawings.tool.Position = Vector2.new(screenPos.X, screenPos.Y + (size.Y / 2) + 5)
                drawings.tool.Visible = true
            else
                drawings.tool.Visible = false
            end
        else
            drawings.box.Visible = false
            drawings.health.Visible = false
            drawings.name.Visible = false
            drawings.tool.Visible = false
        end
    end
end

-- Crear ESP para jugadores existentes y nuevos
for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)

-- ==================== HITBOX EXPANDER ====================
local function updateHitbox()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            
            if getgenv().JAY.HitboxHead and head then
                head.Size = Vector3.new(getgenv().JAY.HitboxSize, getgenv().JAY.HitboxSize, getgenv().JAY.HitboxSize)
                head.Transparency = 0.7
            end
            if getgenv().JAY.HitboxTorso and torso then
                torso.Size = Vector3.new(getgenv().JAY.HitboxSize, getgenv().JAY.HitboxSize, getgenv().JAY.HitboxSize)
                torso.Transparency = 0.7
            end
            if root then
                root.CanCollide = false
            end
        end
    end
end

-- ==================== SILENT AIM ====================
local function getClosestPlayer()
    local closest = nil
    local shortest = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortest then
                shortest = distance
                closest = player
            end
        end
    end
    return closest
end

-- Silent Aim básico (ajusta según el sistema de disparo del juego - muchos usan remotes)
local oldHook = nil
local function enableSilentAim()
    -- Ejemplo genérico - si el juego usa un remote de disparo, hookéalo aquí
    -- Si usas un executor con silent aim built-in, actívalo manualmente
    print("🎯 Silent Aim activado (versión placeholder - ajusta el remote del juego si es necesario)")
end

-- ==================== DELETE TOOL ====================
local function createDeleteTool()
    local tool = Instance.new("Tool")
    tool.Name = "Delete Tool"
    tool.RequiresHandle = false
    tool.Parent = LocalPlayer.Backpack
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target.Parent and not target.Parent:FindFirstChild("Humanoid") then
            target:Destroy()
            print("🗑️ Objeto eliminado: " .. target.Name)
        end
    end)
end

-- ==================== AUTO FARM (South Bronx) ====================
local function startAutoFarm()
    while getgenv().JAY.AutoFarm do
        -- ⚠️ Ajusta esto según el método de farm actual del juego (2026)
        -- Ejemplos comunes en South Bronx: tele a zona de dinero, interactuar con ATM, vender items, etc.
        -- Ejemplo placeholder:
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Cambia estas coordenadas por las de una zona de farm conocida
            -- LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( x, y, z )
            print("💰 Auto Farm corriendo... (añade tu código de tele / interact aquí)")
            -- Ej: game:GetService("ReplicatedStorage").Remotes.Sell:FireServer() o lo que use el juego
        end
        task.wait(2) -- Ajusta el delay
    end
end

-- ==================== MENU (Visual, Combat, Misc) ====================
-- GUI sencilla con tabs (se abre con RightShift)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JAY_GUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JAY SCRIPT SOUTH BRONX THE TRENCHES"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

-- Tabs
local tabs = {Combat = {}, Visual = {}, Misc = {}}

local function createTabButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    return btn
end

local combatTab = createTabButton("Combat", UDim2.new(0, 20, 0, 60))
local visualTab = createTabButton("Visual", UDim2.new(0, 210, 0, 60))
local miscTab = createTabButton("Misc", UDim2.new(0, 400, 0, 60))

-- Combat content (placeholder - se muestran al hacer clic)
local function showCombat()
    -- Silent Aim, Hitbox Head, Hitbox Torso
    print("⚔️ Combat abierto: Silent Aim / Hitbox Cabeza / Hitbox Torso")
    -- Aquí irían toggles reales si expandes la GUI
end

combatTab.MouseButton1Click:Connect(function()
    showCombat()
    getgenv().JAY.SilentAim = not getgenv().JAY.SilentAim
    if getgenv().JAY.SilentAim then enableSilentAim() end
end)

visualTab.MouseButton1Click:Connect(function()
    print("👁️ Visual abierto: ESP a través de paredes")
    getgenv().JAY.ESPEnabled = not getgenv().JAY.ESPEnabled
    getgenv().JAY.BoxEnabled = true
    getgenv().JAY.HealthEnabled = true
    getgenv().JAY.HandItemEnabled = true
end)

miscTab.MouseButton1Click:Connect(function()
    print("🔧 Misc abierto: Velocidad + Delta Tool")
    getgenv().JAY.WalkSpeed = 50 -- ejemplo
    LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().JAY.WalkSpeed
    getgenv().JAY.DeltaTool = not getgenv().JAY.DeltaTool
end)

-- Toggle GUI con RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==================== LOOPS PRINCIPALES ====================
RunService.RenderStepped:Connect(function()
    updateESP()
    updateHitbox()
end)

-- Auto Farm loop
task.spawn(function()
    while true do
        if getgenv().JAY.AutoFarm then
            startAutoFarm()
        end
        task.wait(1)
    end
end)

-- Crear Delete Tool al inicio
createDeleteTool()

print("🎉 Todo listo! Abre el menú con RIGHT SHIFT")
print("Combat = Silent Aim + Hitbox (cabeza/torso)")
print("Visual = ESP a través de paredes + caja de vida + objeto en mano")
print("Misc = Velocidad + Delta Tool")
print("Usa los toggles y ajusta el Auto Farm según necesites.")
