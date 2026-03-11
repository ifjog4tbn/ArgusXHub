return function(ctx)
    local Players = ctx.Players
    local RunService = ctx.RunService or game:GetService("RunService")

    local player = Players.LocalPlayer
    local resourcesFolder = workspace:WaitForChild("Resources")

    local CHECK_INTERVAL = 0.5
    local lastCheck = 0

    local state = {
        maxDistance = 200,
        ores = {
            Clay = {
                enabled = false,
                color = Color3.new(1, 1, 1),
            },
            Coal = {
                enabled = false,
                color = Color3.new(0, 0, 0),
            },
            Copper = {
                enabled = false,
                color = Color3.new(1, 0.5, 0),
            },
            Iron = {
                enabled = false,
                color = Color3.new(1, 1, 1),
            },
            Rock = {
                enabled = false,
                color = Color3.new(0.5, 0.5, 0.5),
            },
            Sand = {
                enabled = false,
                color = Color3.new(1, 1, 0),
            },
            Tin = {
                enabled = false,
                color = Color3.new(0.75, 0.75, 0.75),
            },
            Tree = {
                enabled = false,
                color = Color3.new(0.55, 0.27, 0.07),
            },
        },
    }

    local function getRootPart()
        local character = player and player.Character
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    local function getHighlightName(oreName)
        return "ArgusHighlight_" .. oreName
    end

    local function clearOreHighlights(oreName)
        local name = getHighlightName(oreName)
        for _, model in ipairs(resourcesFolder:GetChildren()) do
            if model:IsA("Model") and model.Name == oreName then
                local existing = model:FindFirstChild(name)
                if existing then
                    existing:Destroy()
                end
            end
        end
    end

    local function updateHighlights()
        local rootPart = getRootPart()
        if not rootPart then
            return
        end

        local items = resourcesFolder:GetChildren()
        for _, model in ipairs(items) do
            if model:IsA("Model") then
                local oreState = state.ores[model.Name]
                if oreState then
                    local highlightName = getHighlightName(model.Name)
                    local existingHighlight = model:FindFirstChild(highlightName)

                    if not oreState.enabled then
                        if existingHighlight then
                            existingHighlight:Destroy()
                        end
                    else
                        local primary = model.PrimaryPart
                        if primary and primary.Name == "Part" then
                            local distance = (rootPart.Position - primary.Position).Magnitude
                            if distance <= state.maxDistance then
                                if not existingHighlight then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = highlightName
                                    highlight.FillTransparency = 1
                                    highlight.OutlineColor = oreState.color
                                    highlight.OutlineTransparency = 0
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = model
                                else
                                    existingHighlight.OutlineColor = oreState.color
                                end
                            else
                                if existingHighlight then
                                    existingHighlight:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastCheck >= CHECK_INTERVAL then
            lastCheck = currentTime
            updateHighlights()
        end
    end)

    return {
        tabs = {
            {
                Title = "ESP",
                Icon = "axe",
                build = function(tab)
                    tab:Slider({
                        Title = "Max Distance",
                        Step = 1,
                        Value = {
                            Min = 10,
                            Max = 2000,
                            Default = state.maxDistance,
                        },
                        Callback = function(value)
                            state.maxDistance = tonumber(value) or state.maxDistance
                        end,
                    })

                    tab:Toggle({
                        Title = "Clay",
                        Value = state.ores.Clay.enabled,
                        Callback = function(value)
                            state.ores.Clay.enabled = value
                            if not value then
                                clearOreHighlights("Clay")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Clay Color",
                        Default = state.ores.Clay.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Clay.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Coal",
                        Value = state.ores.Coal.enabled,
                        Callback = function(value)
                            state.ores.Coal.enabled = value
                            if not value then
                                clearOreHighlights("Coal")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Coal Color",
                        Default = state.ores.Coal.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Coal.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Copper",
                        Value = state.ores.Copper.enabled,
                        Callback = function(value)
                            state.ores.Copper.enabled = value
                            if not value then
                                clearOreHighlights("Copper")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Copper Color",
                        Default = state.ores.Copper.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Copper.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Iron",
                        Value = state.ores.Iron.enabled,
                        Callback = function(value)
                            state.ores.Iron.enabled = value
                            if not value then
                                clearOreHighlights("Iron")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Iron Color",
                        Default = state.ores.Iron.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Iron.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Rock",
                        Value = state.ores.Rock.enabled,
                        Callback = function(value)
                            state.ores.Rock.enabled = value
                            if not value then
                                clearOreHighlights("Rock")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Rock Color",
                        Default = state.ores.Rock.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Rock.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Sand",
                        Value = state.ores.Sand.enabled,
                        Callback = function(value)
                            state.ores.Sand.enabled = value
                            if not value then
                                clearOreHighlights("Sand")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Sand Color",
                        Default = state.ores.Sand.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Sand.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Tin",
                        Value = state.ores.Tin.enabled,
                        Callback = function(value)
                            state.ores.Tin.enabled = value
                            if not value then
                                clearOreHighlights("Tin")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Tin Color",
                        Default = state.ores.Tin.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Tin.color = color
                        end,
                    })

                    tab:Toggle({
                        Title = "Tree",
                        Value = state.ores.Tree.enabled,
                        Callback = function(value)
                            state.ores.Tree.enabled = value
                            if not value then
                                clearOreHighlights("Tree")
                            end
                        end,
                    })

                    tab:Colorpicker({
                        Title = "Tree Color",
                        Default = state.ores.Tree.color,
                        Transparency = 0,
                        Callback = function(color)
                            state.ores.Tree.color = color
                        end,
                    })
                end,
            },
        },
    }
end
