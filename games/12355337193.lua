return function(ctx)
    local Players = ctx.Players
    local RunService = ctx.RunService or game:GetService("RunService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local DEFAULTS = {
        espEnabled = false,
        skeletonEnabled = true,
        tracersEnabled = true,
        healthEnabled = true,
        boxesEnabled = true,
        espMaxDistance = 250,
        tracerMaxDistance = 250,
        skeletonColor = Color3.fromRGB(255, 255, 255),
        tracerColor = Color3.fromRGB(255, 255, 255),
        healthColor = Color3.fromRGB(0, 255, 0),
    }

    local state = {
        espEnabled = DEFAULTS.espEnabled,
        skeletonEnabled = DEFAULTS.skeletonEnabled,
        tracersEnabled = DEFAULTS.tracersEnabled,
        healthEnabled = DEFAULTS.healthEnabled,
        boxesEnabled = DEFAULTS.boxesEnabled,
        espMaxDistance = DEFAULTS.espMaxDistance,
        tracerMaxDistance = DEFAULTS.tracerMaxDistance,
        skeletonColor = DEFAULTS.skeletonColor,
        tracerColor = DEFAULTS.tracerColor,
        healthColor = DEFAULTS.healthColor,
    }

    local bodyConnections = {
        R15 = {
            { "Head", "UpperTorso" },
            { "UpperTorso", "LowerTorso" },
            { "LowerTorso", "LeftUpperLeg" },
            { "LowerTorso", "RightUpperLeg" },
            { "LeftUpperLeg", "LeftLowerLeg" },
            { "LeftLowerLeg", "LeftFoot" },
            { "RightUpperLeg", "RightLowerLeg" },
            { "RightLowerLeg", "RightFoot" },
            { "UpperTorso", "LeftUpperArm" },
            { "UpperTorso", "RightUpperArm" },
            { "LeftUpperArm", "LeftLowerArm" },
            { "LeftLowerArm", "LeftHand" },
            { "RightUpperArm", "RightLowerArm" },
            { "RightLowerArm", "RightHand" },
        },
        R6 = {
            { "Head", "Torso" },
            { "Torso", "Left Arm" },
            { "Torso", "Right Arm" },
            { "Torso", "Left Leg" },
            { "Torso", "Right Leg" },
        },
    }

    local espCache = {}
    local renderConnection = nil

    local function createDrawing(kind, properties)
        local drawing = Drawing.new(kind)
        for prop, value in pairs(properties) do
            drawing[prop] = value
        end
        drawing.Visible = false
        return drawing
    end

    local function createComponents()
        return {
            Box = createDrawing("Square", {
                Thickness = 1,
                Transparency = 1,
                Color = Color3.fromRGB(255, 255, 255),
                Filled = false,
            }),
            Tracer = createDrawing("Line", {
                Thickness = 1,
                Transparency = 1,
                Color = state.tracerColor,
            }),
            HealthBar = {
                Outline = createDrawing("Square", {
                    Thickness = 1,
                    Transparency = 1,
                    Color = Color3.fromRGB(0, 0, 0),
                    Filled = false,
                }),
                Fill = createDrawing("Square", {
                    Thickness = 1,
                    Transparency = 1,
                    Color = state.healthColor,
                    Filled = true,
                }),
            },
            SkeletonLines = {},
        }
    end

    local function hideComponents(components)
        components.Box.Visible = false
        components.Tracer.Visible = false
        components.HealthBar.Outline.Visible = false
        components.HealthBar.Fill.Visible = false

        for _, line in pairs(components.SkeletonLines) do
            line.Visible = false
        end
    end

    local function removeEspForPlayer(player)
        local components = espCache[player]
        if not components then
            return
        end

        components.Box:Remove()
        components.Tracer:Remove()
        components.HealthBar.Outline:Remove()
        components.HealthBar.Fill:Remove()

        for _, line in pairs(components.SkeletonLines) do
            line:Remove()
        end

        espCache[player] = nil
    end

    local function updatePlayerEsp(player, components)
        local character = player.Character
        local localCharacter = LocalPlayer and LocalPlayer.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoid or humanoid.Health <= 0 or not hrp or not localRoot then
            hideComponents(components)
            return
        end

        local distance = (localRoot.Position - hrp.Position).Magnitude
        if distance > state.espMaxDistance then
            hideComponents(components)
            return
        end

        local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or hrpPos.Z <= 0 then
            hideComponents(components)
            return
        end

        local screenWidth = Camera.ViewportSize.X
        local screenHeight = Camera.ViewportSize.Y
        local factor = 1 / (hrpPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
        local boxWidth = math.floor(screenHeight / 25 * factor)
        local boxHeight = math.floor(screenWidth / 27 * factor)

        if state.boxesEnabled then
            components.Box.Size = Vector2.new(boxWidth, boxHeight)
            components.Box.Position = Vector2.new(hrpPos.X - (boxWidth / 2), hrpPos.Y - (boxHeight / 2))
            components.Box.Visible = true
        else
            components.Box.Visible = false
        end

        if state.tracersEnabled and distance <= state.tracerMaxDistance then
            local from = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local to = Vector2.new(hrpPos.X, hrpPos.Y + (boxHeight / 2))
            components.Tracer.From = from
            components.Tracer.To = to
            components.Tracer.Color = state.tracerColor
            components.Tracer.Visible = true
        else
            components.Tracer.Visible = false
        end

        if state.healthEnabled then
            local healthBarWidth = 5
            local healthBarHeight = boxHeight
            local maxHealth = math.max(humanoid.MaxHealth, 1)
            local healthFraction = math.clamp(humanoid.Health / maxHealth, 0, 1)

            components.HealthBar.Outline.Size = Vector2.new(healthBarWidth, healthBarHeight)
            components.HealthBar.Outline.Position = Vector2.new(components.Box.Position.X - healthBarWidth - 2, components.Box.Position.Y)
            components.HealthBar.Outline.Visible = true

            components.HealthBar.Fill.Size = Vector2.new(healthBarWidth - 2, healthBarHeight * healthFraction)
            components.HealthBar.Fill.Position = Vector2.new(
                components.HealthBar.Outline.Position.X + 1,
                components.HealthBar.Outline.Position.Y + healthBarHeight * (1 - healthFraction)
            )
            components.HealthBar.Fill.Color = state.healthColor
            components.HealthBar.Fill.Visible = true
        else
            components.HealthBar.Outline.Visible = false
            components.HealthBar.Fill.Visible = false
        end

        local rigKey = humanoid.RigType and humanoid.RigType.Name or "R15"
        local connections = bodyConnections[rigKey] or bodyConnections.R15

        for _, pair in ipairs(connections) do
            local lineKey = pair[1] .. "-" .. pair[2]
            local line = components.SkeletonLines[lineKey]
            if not line then
                line = createDrawing("Line", {
                    Thickness = 1,
                    Transparency = 1,
                    Color = state.skeletonColor,
                })
                components.SkeletonLines[lineKey] = line
            end

            if state.skeletonEnabled then
                local partA = character:FindFirstChild(pair[1])
                local partB = character:FindFirstChild(pair[2])
                if partA and partB then
                    local posA, visibleA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, visibleB = Camera:WorldToViewportPoint(partB.Position)
                    if visibleA and visibleB and posA.Z > 0 and posB.Z > 0 then
                        line.From = Vector2.new(posA.X, posA.Y)
                        line.To = Vector2.new(posB.X, posB.Y)
                        line.Color = state.skeletonColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end

    local function stopEsp()
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end

        for player, components in pairs(espCache) do
            hideComponents(components)
        end
    end

    local function startEsp()
        if renderConnection then
            return
        end

        renderConnection = RunService.RenderStepped:Connect(function()
            if not state.espEnabled then
                return
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local components = espCache[player]
                    if not components then
                        components = createComponents()
                        espCache[player] = components
                    end
                    updatePlayerEsp(player, components)
                end
            end
        end)
    end

    Players.PlayerRemoving:Connect(function(player)
        removeEspForPlayer(player)
    end)

    return {
        tabs = {
            {
                Title = "ESP",
                build = function(tab)
                    tab:Section({ Title = "ESP Main" })

                    tab:Toggle({
                        Title = "Enable ESP",
                        Value = state.espEnabled,
                        Callback = function(value)
                            state.espEnabled = value
                            if value then
                                startEsp()
                            else
                                stopEsp()
                            end
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Boxes",
                        Value = state.boxesEnabled,
                        Callback = function(value)
                            state.boxesEnabled = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Skeleton",
                        Value = state.skeletonEnabled,
                        Callback = function(value)
                            state.skeletonEnabled = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Tracers",
                        Value = state.tracersEnabled,
                        Callback = function(value)
                            state.tracersEnabled = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Health Bar",
                        Value = state.healthEnabled,
                        Callback = function(value)
                            state.healthEnabled = value
                        end,
                    })

                    tab:Slider({
                        Title = "ESP Max Distance",
                        Step = 1,
                        Value = {
                            Min = 50,
                            Max = 2000,
                            Default = state.espMaxDistance,
                        },
                        Callback = function(value)
                            state.espMaxDistance = tonumber(value) or DEFAULTS.espMaxDistance
                        end,
                    })

                    tab:Slider({
                        Title = "Tracer Max Distance",
                        Step = 1,
                        Value = {
                            Min = 50,
                            Max = 2000,
                            Default = state.tracerMaxDistance,
                        },
                        Callback = function(value)
                            state.tracerMaxDistance = tonumber(value) or DEFAULTS.tracerMaxDistance
                        end,
                    })

                    tab:Section({ Title = "ESP Colors" })

                    tab:Colorpicker({
                        Title = "Skeleton Color",
                        Default = state.skeletonColor,
                        Transparency = 0,
                        Callback = function(color)
                            state.skeletonColor = color
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Tracer Color",
                        Default = state.tracerColor,
                        Transparency = 0,
                        Callback = function(color)
                            state.tracerColor = color
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Health Color",
                        Default = state.healthColor,
                        Transparency = 0,
                        Callback = function(color)
                            state.healthColor = color
                        end,
                    })
                end,
            },
        },
    }
end
