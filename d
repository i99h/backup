-- Servicios
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local viewportSize = camera.ViewportSize

local ESP = {
    Enabled = true,
    TeamCheck = true,
    FriendCheck = true,
    MaxDistance = 200,
    FadeOut = {
        OnDistance = true,
        OnDeath = false,
        OnLeave = false,
    },
    
    Drawing = {
        Box = {
            Enabled = true,
            Style = "Corner", -- "Corner", "Full", "3D"
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Fill = false,
            FillColor = Color3.fromRGB(255, 255, 255),
            FillTransparency = 0.75,
            Gradient = {
                Enabled = false,
                Color1 = Color3.fromRGB(119, 120, 255),
                Color2 = Color3.fromRGB(0, 0, 0)
            },
            Animation = {
                Enabled = true,
                RotationSpeed = 300
            }
        },
        
        Name = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            ShowDistanceInName = true,
            FriendIndicator = true,
            FriendColor = Color3.fromRGB(0, 255, 0),
            EnemyColor = Color3.fromRGB(255, 0, 0)
        },
        
        Health = {
            Enabled = true,
            Bar = true,
            BarColor = Color3.fromRGB(255, 255, 255),
            BarWidth = 2.5,
            Text = true,
            TextColor = Color3.fromRGB(119, 120, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Gradient = {
                Enabled = true,
                Low = Color3.fromRGB(200, 0, 0),
                Medium = Color3.fromRGB(60, 60, 125),
                High = Color3.fromRGB(119, 120, 255)
            },
            LerpColors = true
        },
        
        Weapon = {
            Enabled = true,
            ShowText = true,
            ShowIcon = true,
            TextColor = Color3.fromRGB(119, 120, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Gradient = {
                Enabled = false,
                Color1 = Color3.fromRGB(255, 255, 255),
                Color2 = Color3.fromRGB(119, 120, 255)
            }
        },
        
        Distance = {
            Enabled = true,
            Position = "Text", -- "Text", "Bottom", "Separate"
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0)
        },
        
        Tracer = {
            Enabled = false,
            Origin = "Bottom", -- "Bottom", "Middle", "Top"
            Color = Color3.fromRGB(255, 255, 255),
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0)
        },
        
        Chams = {
            Enabled = true,
            ThermalEffect = true,
            FillColor = Color3.fromRGB(119, 120, 255),
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(119, 120, 255),
            OutlineTransparency = 0,
            VisibleOnly = true,
            DepthMode = "Occluded" -- "Occluded", "AlwaysOnTop"
        },
        
        OffScreenArrow = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 15,
            Radius = 150,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0)
        },
        
        Text = {
            Size = 11,
            Font = Enum.Font.Code,
            Outline = true
        }
    },
    
    WeaponIcons = {
        ["Wooden Bow"] = "http://www.roblox.com/asset/?id=17677465400",
        ["Crossbow"] = "http://www.roblox.com/asset/?id=17677473017",
        ["Salvaged SMG"] = "http://www.roblox.com/asset/?id=17677463033",
        ["Salvaged AK47"] = "http://www.roblox.com/asset/?id=17677455113",
        ["Salvaged AK74u"] = "http://www.roblox.com/asset/?id=17677442346",
        ["Salvaged M14"] = "http://www.roblox.com/asset/?id=17677444642",
        ["Salvaged Python"] = "http://www.roblox.com/asset/?id=17677451737",
        ["Military PKM"] = "http://www.roblox.com/asset/?id=17677449448",
        ["Military M4A1"] = "http://www.roblox.com/asset/?id=17677479536",
        ["Bruno's M4A1"] = "http://www.roblox.com/asset/?id=17677471185",
        ["Military Barrett"] = "http://www.roblox.com/asset/?id=17677482998",
        ["Salvaged Skorpion"] = "http://www.roblox.com/asset/?id=17677459658",
        ["Salvaged Pump Action"] = "http://www.roblox.com/asset/?id=17677457186",
        ["Military AA12"] = "http://www.roblox.com/asset/?id=17677475227",
        ["Salvaged Break Action"] = "http://www.roblox.com/asset/?id=17677468751",
        ["Salvaged Pipe Rifle"] = "http://www.roblox.com/asset/?id=17677468751",
        ["Salvaged P250"] = "http://www.roblox.com/asset/?id=17677447257",
        ["Nail Gun"] = "http://www.roblox.com/asset/?id=17677484756"
    }
}

local DrawingElement = {}
DrawingElement.__index = DrawingElement

function DrawingElement.new(type, properties)
    local self = setmetatable({}, DrawingElement)
    self.type = type
    self.drawing = Drawing.new(type)
    self:Update(properties)
    return self
end

function DrawingElement:Update(properties)
    for property, value in pairs(properties) do
        pcall(function()
            self.drawing[property] = value
        end)
    end
end

function DrawingElement:Destroy()
    self.drawing:Remove()
end

local PlayerESP = {}
PlayerESP.__index = PlayerESP

function PlayerESP.new(player)
    local self = setmetatable({}, PlayerESP)
    self.player = player
    self.drawings = {}
    self.highlight = nil
    self.connected = false
    return self
end

function PlayerESP:Initialize()
    if ESP.Drawing.Box.Enabled then
        self.drawings.box = DrawingElement.new("Square", {
            Thickness = 1,
            Filled = ESP.Drawing.Box.Fill,
            Color = ESP.Drawing.Box.Color,
            Transparency = ESP.Drawing.Box.Fill and (1 - ESP.Drawing.Box.FillTransparency) or 1
        })
        
        if ESP.Drawing.Box.Outline then
            self.drawings.boxOutline = DrawingElement.new("Square", {
                Thickness = 3,
                Filled = false,
                Color = ESP.Drawing.Box.OutlineColor
            })
        end
    end
    
    if ESP.Drawing.Name.Enabled then
        self.drawings.name = DrawingElement.new("Text", {
            Text = self.player.Name,
            Size = ESP.Drawing.Text.Size,
            Font = ESP.Drawing.Text.Font,
            Color = ESP.Drawing.Name.Color,
            Outline = ESP.Drawing.Name.Outline,
            OutlineColor = ESP.Drawing.Name.OutlineColor,
            Center = true
        })
    end
    
    if ESP.Drawing.Health.Enabled and ESP.Drawing.Health.Bar then
        self.drawings.healthBar = DrawingElement.new("Line", {
            Thickness = ESP.Drawing.Health.BarWidth,
            Color = ESP.Drawing.Health.BarColor
        })
        
        if ESP.Drawing.Health.Outline then
            self.drawings.healthBarOutline = DrawingElement.new("Line", {
                Thickness = ESP.Drawing.Health.BarWidth + 2,
                Color = ESP.Drawing.Health.OutlineColor
            })
        end
    end
    
    if ESP.Drawing.Health.Enabled and ESP.Drawing.Health.Text then
        self.drawings.healthText = DrawingElement.new("Text", {
            Size = ESP.Drawing.Text.Size,
            Font = ESP.Drawing.Text.Font,
            Color = ESP.Drawing.Health.TextColor,
            Outline = ESP.Drawing.Health.Outline,
            OutlineColor = ESP.Drawing.Health.OutlineColor,
            Center = true
        })
    end
    
    if ESP.Drawing.Weapon.Enabled and ESP.Drawing.Weapon.ShowText then
        self.drawings.weapon = DrawingElement.new("Text", {
            Size = ESP.Drawing.Text.Size,
            Font = ESP.Drawing.Text.Font,
            Color = ESP.Drawing.Weapon.TextColor,
            Outline = ESP.Drawing.Weapon.Outline,
            OutlineColor = ESP.Drawing.Weapon.OutlineColor,
            Center = true
        })
    end
    
    if ESP.Drawing.Distance.Enabled and ESP.Drawing.Distance.Position == "Separate" then
        self.drawings.distance = DrawingElement.new("Text", {
            Size = ESP.Drawing.Text.Size,
            Font = ESP.Drawing.Text.Font,
            Color = ESP.Drawing.Distance.Color,
            Outline = ESP.Drawing.Distance.Outline,
            OutlineColor = ESP.Drawing.Distance.OutlineColor,
            Center = true
        })
    end
    
    if ESP.Drawing.Tracer.Enabled then
        self.drawings.tracer = DrawingElement.new("Line", {
            Thickness = 1,
            Color = ESP.Drawing.Tracer.Color
        })
        
        if ESP.Drawing.Tracer.Outline then
            self.drawings.tracerOutline = DrawingElement.new("Line", {
                Thickness = 3,
                Color = ESP.Drawing.Tracer.OutlineColor
            })
        end
    end
    
    if ESP.Drawing.OffScreenArrow.Enabled then
        self.drawings.arrow = DrawingElement.new("Triangle", {
            Filled = true,
            Color = ESP.Drawing.OffScreenArrow.Color,
            Transparency = 0
        })
        
        if ESP.Drawing.OffScreenArrow.Outline then
            self.drawings.arrowOutline = DrawingElement.new("Triangle", {
                Thickness = 3,
                Filled = false,
                Color = ESP.Drawing.OffScreenArrow.OutlineColor
            })
        end
    end
    
    if ESP.Drawing.Chams.Enabled then
        self.highlight = Instance.new("Highlight")
        self.highlight.FillColor = ESP.Drawing.Chams.FillColor
        self.highlight.FillTransparency = ESP.Drawing.Chams.FillTransparency
        self.highlight.OutlineColor = ESP.Drawing.Chams.OutlineColor
        self.highlight.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency
        self.highlight.DepthMode = ESP.Drawing.Chams.DepthMode
        self.highlight.Parent = CoreGui
    end
    
    if ESP.Drawing.Weapon.Enabled and ESP.Drawing.Weapon.ShowIcon then
        local screenGui = CoreGui:FindFirstChild("ESPHolder") or Instance.new("ScreenGui", CoreGui)
        screenGui.Name = "ESPHolder"
        
        self.weaponIcon = Instance.new("ImageLabel")
        self.weaponIcon.BackgroundTransparency = 1
        self.weaponIcon.BorderSizePixel = 0
        self.weaponIcon.Size = UDim2.new(0, 40, 0, 40)
        self.weaponIcon.Parent = screenGui
    end
    
    self.connection = RunService.Heartbeat:Connect(function()
        self:Update()
    end)
    self.connected = true
end

function PlayerESP:Update()
    if not self.connected then return end
    
    local character = self.player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not character or not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
        self:Hide()
        return
    end
    
    local distance = (camera.CFrame.Position - humanoidRootPart.Position).Magnitude
    if distance > ESP.MaxDistance then
        self:Hide()
        return
    end
    
    if ESP.TeamCheck and self.player.Team == localPlayer.Team then
        self:Hide()
        return
    end
    
    local position, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        if ESP.Drawing.OffScreenArrow.Enabled then
            self:UpdateOffScreenArrow(position, distance)
        else
            self:Hide()
        end
        return
    end
    
    local screenPosition = Vector2.new(position.X, position.Y)
    
    self:UpdateBox(screenPosition, character, distance)
    self:UpdateName(screenPosition, distance)
    self:UpdateHealth(screenPosition, humanoid, character, distance)
    self:UpdateWeapon(screenPosition, distance)
    self:UpdateDistance(screenPosition, distance)
    self:UpdateTracer(screenPosition)
    self:UpdateChams(character, distance)
    
    if ESP.FadeOut.OnDistance then
        self:ApplyFadeOut(distance)
    end
end

function PlayerESP:UpdateBox(screenPosition, character, distance)
    if not self.drawings.box then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local size = humanoidRootPart.Size.Y
    local scaleFactor = (size * viewportSize.Y) / (screenPosition.Z * 2)
    local width = 3 * scaleFactor
    local height = 4.5 * scaleFactor
    
    local boxPosition = Vector2.new(screenPosition.X - width/2, screenPosition.Y - height/2)
    local boxSize = Vector2.new(width, height)
    
    if ESP.Drawing.Box.Style == "Corner" then
        self.drawings.box.Visible = false
        self.drawings.boxOutline.Visible = false
    else
        self.drawings.box.Visible = ESP.Drawing.Box.Enabled
        self.drawings.boxOutline.Visible = ESP.Drawing.Box.Enabled and ESP.Drawing.Box.Outline
        
        if self.drawings.box.Visible then
            self.drawings.box.drawing.Position = boxPosition
            self.drawings.box.drawing.Size = boxSize
            
            if self.drawings.boxOutline then
                self.drawings.boxOutline.drawing.Position = boxPosition
                self.drawings.boxOutline.drawing.Size = boxSize
            end
            
            if ESP.Drawing.Box.Gradient.Enabled then

            end
        end
    end
end

function PlayerESP:UpdateName(screenPosition, distance)
    if not self.drawings.name then return end
    
    local nameText = self.player.Name
    if ESP.Drawing.Name.ShowDistanceInName then
        nameText = string.format("%s [%d]", nameText, math.floor(distance))
    end
    
    if ESP.Drawing.Name.FriendIndicator and localPlayer:IsFriendsWith(self.player.UserId) then
        nameText = string.format('[<font color="rgb(%d,%d,%d)">F</font>] %s',
            ESP.Drawing.Name.FriendColor.R * 255,
            ESP.Drawing.Name.FriendColor.G * 255,
            ESP.Drawing.Name.FriendColor.B * 255,
            nameText)
    else
        nameText = string.format('[<font color="rgb(%d,%d,%d)">E</font>] %s',
            ESP.Drawing.Name.EnemyColor.R * 255,
            ESP.Drawing.Name.EnemyColor.G * 255,
            ESP.Drawing.Name.EnemyColor.B * 255,
            nameText)
    end
    
    self.drawings.name.drawing.Text = nameText
    self.drawings.name.drawing.Position = Vector2.new(screenPosition.X, screenPosition.Y - 30)
    self.drawings.name.drawing.Visible = ESP.Drawing.Name.Enabled
end

function PlayerESP:UpdateHealth(screenPosition, humanoid, character, distance)
    if not humanoid then return end
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    
    if self.drawings.healthBar then
        local humanoidRootPart = character.HumanoidRootPart
        local size = humanoidRootPart.Size.Y
        local scaleFactor = (size * viewportSize.Y) / (screenPosition.Z * 2)
        local height = 4.5 * scaleFactor
        
        local barHeight = height * healthPercent
        local barX = screenPosition.X - (3 * scaleFactor)/2 - 6
        local barY = screenPosition.Y + height/2 - barHeight
        
        self.drawings.healthBar.drawing.From = Vector2.new(barX, barY)
        self.drawings.healthBar.drawing.To = Vector2.new(barX, barY + barHeight)
        
        if ESP.Drawing.Health.LerpColors and ESP.Drawing.Health.Gradient.Enabled then
            local color
            if healthPercent > 0.75 then
                color = ESP.Drawing.Health.Gradient.High
            elseif healthPercent > 0.5 then
                color = ESP.Drawing.Health.Gradient.Medium
            elseif healthPercent > 0.25 then
                color = ESP.Drawing.Health.Gradient.Low
            else
                color = ESP.Drawing.Health.Gradient.Low
            end
            self.drawings.healthBar.drawing.Color = color
        end
        
        self.drawings.healthBar.drawing.Visible = ESP.Drawing.Health.Enabled and ESP.Drawing.Health.Bar
        
        if self.drawings.healthBarOutline then
            self.drawings.healthBarOutline.drawing.From = Vector2.new(barX - 1, screenPosition.Y - height/2)
            self.drawings.healthBarOutline.drawing.To = Vector2.new(barX - 1, screenPosition.Y + height/2)
            self.drawings.healthBarOutline.drawing.Visible = ESP.Drawing.Health.Enabled and ESP.Drawing.Health.Bar
        end
    end
    
    if self.drawings.healthText then
        self.drawings.healthText.drawing.Text = string.format("%d", math.floor(humanoid.Health))
        self.drawings.healthText.drawing.Position = Vector2.new(screenPosition.X - 20, screenPosition.Y)
        self.drawings.healthText.drawing.Visible = ESP.Drawing.Health.Enabled and ESP.Drawing.Health.Text and humanoid.Health < humanoid.MaxHealth
    end
end

function PlayerESP:UpdateWeapon(screenPosition, distance)
    local weaponName = "none"
    
    if self.drawings.weapon then
        self.drawings.weapon.drawing.Text = weaponName
        self.drawings.weapon.drawing.Position = Vector2.new(screenPosition.X, screenPosition.Y + 20)
        self.drawings.weapon.drawing.Visible = ESP.Drawing.Weapon.Enabled and ESP.Drawing.Weapon.ShowText
    end
    
    if self.weaponIcon and ESP.WeaponIcons[weaponName] then
        self.weaponIcon.Image = ESP.WeaponIcons[weaponName]
        self.weaponIcon.Position = UDim2.new(0, screenPosition.X - 20, 0, screenPosition.Y + 15)
        self.weaponIcon.Visible = ESP.Drawing.Weapon.Enabled and ESP.Drawing.Weapon.ShowIcon
    end
end

function PlayerESP:UpdateDistance(screenPosition, distance)
    if ESP.Drawing.Distance.Position == "Separate" and self.drawings.distance then
        self.drawings.distance.drawing.Text = string.format("%d studs", math.floor(distance))
        self.drawings.distance.drawing.Position = Vector2.new(screenPosition.X, screenPosition.Y + 40)
        self.drawings.distance.drawing.Visible = ESP.Drawing.Distance.Enabled
    end
end

function PlayerESP:UpdateTracer(screenPosition)
    if not self.drawings.tracer then return end
    
    local origin
    if ESP.Drawing.Tracer.Origin == "Bottom" then
        origin = Vector2.new(viewportSize.X/2, viewportSize.Y)
    elseif ESP.Drawing.Tracer.Origin == "Middle" then
        origin = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    else
        origin = Vector2.new(viewportSize.X/2, 0)
    end
    
    self.drawings.tracer.drawing.From = origin
    self.drawings.tracer.drawing.To = screenPosition
    self.drawings.tracer.drawing.Visible = ESP.Drawing.Tracer.Enabled
    
    if self.drawings.tracerOutline then
        self.drawings.tracerOutline.drawing.From = origin
        self.drawings.tracerOutline.drawing.To = screenPosition
        self.drawings.tracerOutline.drawing.Visible = ESP.Drawing.Tracer.Enabled
    end
end

function PlayerESP:UpdateOffScreenArrow(position, distance)
    if not self.drawings.arrow then return end
    
    local direction = (Vector2.new(position.X, position.Y) - Vector2.new(viewportSize.X/2, viewportSize.Y/2)).Unit
    local radius = ESP.Drawing.OffScreenArrow.Radius * (1 - math.min(distance/ESP.MaxDistance, 1))
    local arrowPosition = Vector2.new(viewportSize.X/2, viewportSize.Y/2) + direction * radius
    
    local angle = math.atan2(direction.Y, direction.X)
    local size = ESP.Drawing.OffScreenArrow.Size
    
    local pointA = arrowPosition
    local pointB = arrowPosition - Vector2.new(
        math.cos(angle + 0.5) * size,
        math.sin(angle + 0.5) * size
    )
    local pointC = arrowPosition - Vector2.new(
        math.cos(angle - 0.5) * size,
        math.sin(angle - 0.5) * size
    )
    
    self.drawings.arrow.drawing.PointA = pointA
    self.drawings.arrow.drawing.PointB = pointB
    self.drawings.arrow.drawing.PointC = pointC
    self.drawings.arrow.drawing.Visible = true
    
    if self.drawings.arrowOutline then
        self.drawings.arrowOutline.drawing.PointA = pointA
        self.drawings.arrowOutline.drawing.PointB = pointB
        self.drawings.arrowOutline.drawing.PointC = pointC
        self.drawings.arrowOutline.drawing.Visible = true
    end
end

function PlayerESP:UpdateChams(character, distance)
    if not self.highlight then return end
    
    self.highlight.Adornee = character
    self.highlight.Enabled = ESP.Drawing.Chams.Enabled
    
    if ESP.Drawing.Chams.ThermalEffect then
        local breatheEffect = math.sin(tick() * 2) * 0.5 + 0.5
        self.highlight.FillTransparency = ESP.Drawing.Chams.FillTransparency * breatheEffect
        self.highlight.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency * breatheEffect
    end
end

function PlayerESP:ApplyFadeOut(distance)
    local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
    
    for _, drawing in pairs(self.drawings) do
        if drawing and drawing.drawing then
            if drawing.type == "Square" or drawing.type == "Line" or drawing.type == "Triangle" then
                drawing.drawing.Transparency = 1 - transparency
            elseif drawing.type == "Text" then
                drawing.drawing.Transparency = 1 - transparency
                if drawing.drawing.Outline then
                    drawing.drawing.OutlineTransparency = 1 - transparency
                end
            end
        end
    end
    
    if self.highlight then
        self.highlight.FillTransparency = ESP.Drawing.Chams.FillTransparency * (1 - transparency)
        self.highlight.OutlineTransparency = ESP.Drawing.Chams.OutlineTransparency * (1 - transparency)
    end
end

function PlayerESP:Hide()
    for _, drawing in pairs(self.drawings) do
        if drawing then
            drawing.drawing.Visible = false
        end
    end
    
    if self.weaponIcon then
        self.weaponIcon.Visible = false
    end
    
    if self.highlight then
        self.highlight.Enabled = false
    end
    
    if self.drawings.arrow then
        self.drawings.arrow.drawing.Visible = false
        if self.drawings.arrowOutline then
            self.drawings.arrowOutline.drawing.Visible = false
        end
    end
end

function PlayerESP:Destroy()
    if self.connection then
        self.connection:Disconnect()
    end
    
    for _, drawing in pairs(self.drawings) do
        if drawing then
            drawing:Destroy()
        end
    end
    
    if self.weaponIcon then
        self.weaponIcon:Destroy()
    end
    
    if self.highlight then
        self.highlight:Destroy()
    end
    
    self.drawings = {}
    self.connected = false
end

local ESPManager = {
    players = {},
    initialized = false
}

function ESPManager:Initialize()
    if self.initialized then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            self:AddPlayer(player)
        end
    end
    
    self.playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        self:AddPlayer(player)
    end)
    
    self.playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)
    
    self.initialized = true
end

function ESPManager:AddPlayer(player)
    if self.players[player] then return end
    
    local playerESP = PlayerESP.new(player)
    playerESP:Initialize()
    self.players[player] = playerESP
end

function ESPManager:RemovePlayer(player)
    if self.players[player] then
        self.players[player]:Destroy()
        self.players[player] = nil
    end
end

function ESPManager:Toggle(enabled)
    ESP.Enabled = enabled
    for _, playerESP in pairs(self.players) do
        if enabled then
            playerESP:Initialize()
        else
            playerESP:Hide()
        end
    end
end

function ESPManager:UpdateSettings(newSettings)
    for key, value in pairs(newSettings) do
        if ESP[key] ~= nil then
            if type(value) == "table" then
                for subKey, subValue in pairs(value) do
                    if ESP[key][subKey] ~= nil then
                        ESP[key][subKey] = subValue
                    end
                end
            else
                ESP[key] = value
            end
        end
    end
end

function ESPManager:Destroy()
    for player, playerESP in pairs(self.players) do
        playerESP:Destroy()
    end
    
    if self.playerAddedConnection then
        self.playerAddedConnection:Disconnect()
    end
    
    if self.playerRemovingConnection then
        self.playerRemovingConnection:Disconnect()
    end
    
    self.players = {}
    self.initialized = false
end

ESPManager:Initialize()

return {
    Manager = ESPManager,
    Settings = ESP,
    
    Toggle = function(enabled)
        ESPManager:Toggle(enabled)
    end,
    
    UpdateSettings = function(newSettings)
        ESPManager:UpdateSettings(newSettings)
    end,
    
    Destroy = function()
        ESPManager:Destroy()
    end
}
