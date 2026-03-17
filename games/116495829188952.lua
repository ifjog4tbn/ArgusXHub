return function(ctx)
    local RunService = ctx.RunService or game:GetService("RunService")

    local state = {
        mode = "In UI",
        enabled = false,
    }

    local updateConn = nil
    local infoGui = nil
    local fuelEnabled = false
    local fuelConn = nil
    local fuelGui = nil

    local espState = {
        maxDistance = 500,
        enabled = {},
        colors = {},
    }
    local espConn = nil
    local espActive = false
    local nameToCategory = nil

    local function findDistanceLabel()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:GetAttribute("Rojo_Target_PrimaryPart") ~= nil then
                local label = obj
                    :FindFirstChild("RequiredComponents")
                if label then
                    label = label:FindFirstChild("Controls")
                end
                if label then
                    label = label:FindFirstChild("DistanceDial")
                end
                if label then
                    label = label:FindFirstChild("SurfaceGui")
                end
                if label then
                    label = label:FindFirstChild("TextLabel")
                end
                if label and label:IsA("TextLabel") then
                    return label
                end
            end
        end
        return nil
    end

    local function findFuelImageLabel()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:GetAttribute("Rojo_Target_PrimaryPart") ~= nil then
                local label = obj
                    :FindFirstChild("RequiredComponents")
                if label then
                    label = label:FindFirstChild("Controls")
                end
                if label then
                    label = label:FindFirstChild("Fuel")
                end
                if label then
                    label = label:FindFirstChild("SurfaceGui")
                end
                if label then
                    label = label:FindFirstChild("ImageLabel")
                end
                if label and label:IsA("ImageLabel") then
                    return label
                end
            end
        end
        return nil
    end

    local function ensureGui()
        if infoGui and infoGui.Parent then
            return infoGui
        end

        local ArgusInfo = Instance.new("ScreenGui")
        local DistanceInfo = Instance.new("TextLabel")

        ArgusInfo.Name = "ArgusInfo"
        ArgusInfo.Parent = game.CoreGui
        ArgusInfo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        DistanceInfo.Name = "DistanceInfo"
        DistanceInfo.Parent = ArgusInfo
        DistanceInfo.BackgroundColor3 = Color3.new(1, 1, 1)
        DistanceInfo.BackgroundTransparency = 1
        DistanceInfo.BorderColor3 = Color3.new(0, 0, 0)
        DistanceInfo.BorderSizePixel = 0
        DistanceInfo.Position = UDim2.new(-0.000850919052, 0, 0.935763896, 0)
        DistanceInfo.Size = UDim2.new(0.119979583, 0, 0.0642361119, 0)
        DistanceInfo.Font = Enum.Font.Unknown
        DistanceInfo.Text = "5 m"
        DistanceInfo.TextColor3 = Color3.new(0, 0.666667, 1)
        DistanceInfo.TextScaled = true
        DistanceInfo.TextSize = 14
        DistanceInfo.TextStrokeColor3 = Color3.new(0, 0.666667, 1)
        DistanceInfo.TextWrapped = true

        infoGui = ArgusInfo
        return infoGui
    end

    local function destroyGui()
        if infoGui then
            infoGui:Destroy()
            infoGui = nil
        end
    end

    local function ensureFuelGui()
        if fuelGui and fuelGui.Parent then
            return fuelGui
        end

        local ArgusFuel = Instance.new("ScreenGui")
        local ImageLabel = Instance.new("ImageLabel")
        local Gauge = Instance.new("Frame")
        local Frame = Instance.new("Frame")
        local TextLabel1 = Instance.new("TextLabel")
        local TextLabel2 = Instance.new("TextLabel")

        ArgusFuel.Name = "ArgusFuel"
        ArgusFuel.Parent = game.CoreGui
        ArgusFuel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        ImageLabel.Name = "ImageLabel"
        ImageLabel.Parent = ArgusFuel
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.881314814, 0, 0.149305552, 0)
        ImageLabel.Rotation = 1
        ImageLabel.Size = UDim2.new(0.108743757, 0, 0.219265506, 0)
        ImageLabel.Image = "rbxassetid://117265293674887"

        Gauge.Name = "Gauge"
        Gauge.Parent = ImageLabel
        Gauge.AnchorPoint = Vector2.new(0.5, 0.5)
        Gauge.BackgroundColor3 = Color3.new(1, 1, 1)
        Gauge.BorderColor3 = Color3.new(0, 0, 0)
        Gauge.BorderSizePixel = 0
        Gauge.Position = UDim2.new(0.5, 0, 0.5, 0)
        Gauge.Rotation = 120
        Gauge.Size = UDim2.new(0.0399999991, 0, 0.0399999991, 0)
        Gauge.ZIndex = 0

        Frame.Name = "Frame"
        Frame.Parent = Gauge
        Frame.BackgroundColor3 = Color3.new(0, 0, 0)
        Frame.BorderColor3 = Color3.new(0, 0, 0)
        Frame.BorderSizePixel = 0
        Frame.Size = UDim2.new(10, 0, 0.699999988, 0)

        TextLabel1.Name = "TextLabel1"
        TextLabel1.Parent = ArgusFuel
        TextLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel1.BackgroundColor3 = Color3.new(1, 1, 1)
        TextLabel1.BackgroundTransparency = 1
        TextLabel1.BorderColor3 = Color3.new(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Position = UDim2.new(0.864558101, 0, 0.197958261, 0)
        TextLabel1.Size = UDim2.new(0.0283354931, 0, 0.019097222, 0)
        TextLabel1.Font = Enum.Font.DenkOne
        TextLabel1.Text = "Empty"
        TextLabel1.TextColor3 = Color3.new(0.568627, 0, 0)
        TextLabel1.TextScaled = true
        TextLabel1.TextSize = 20
        TextLabel1.TextWrapped = true

        TextLabel2.Name = "TextLabel2"
        TextLabel2.Parent = ArgusFuel
        TextLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel2.BackgroundColor3 = Color3.new(1, 1, 1)
        TextLabel2.BackgroundTransparency = 1
        TextLabel2.BorderColor3 = Color3.new(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0.902608633, 0, 0.197958261, 0)
        TextLabel2.Size = UDim2.new(0.0283354931, 0, 0.019097222, 0)
        TextLabel2.Font = Enum.Font.DenkOne
        TextLabel2.Text = "Full"
        TextLabel2.TextColor3 = Color3.new(0.568627, 0, 0)
        TextLabel2.TextScaled = true
        TextLabel2.TextSize = 20
        TextLabel2.TextWrapped = true

        fuelGui = ArgusFuel
        return fuelGui
    end

    local function destroyFuelGui()
        if fuelGui then
            fuelGui:Destroy()
            fuelGui = nil
        end
    end

    local function syncGuiObject(dst, src)
        if not dst or not src then
            return
        end
        if dst:IsA("GuiObject") and src:IsA("GuiObject") then
            dst.BackgroundColor3 = src.BackgroundColor3
            dst.BackgroundTransparency = src.BackgroundTransparency
            dst.BorderColor3 = src.BorderColor3
            dst.BorderSizePixel = src.BorderSizePixel
            dst.LayoutOrder = src.LayoutOrder
            dst.ZIndex = src.ZIndex
            dst.Position = src.Position
            dst.Size = src.Size
            dst.Rotation = src.Rotation
            dst.Visible = src.Visible
            dst.AnchorPoint = src.AnchorPoint
        end
        if dst:IsA("ImageLabel") and src:IsA("ImageLabel") then
            dst.Image = src.Image
            dst.ImageColor3 = src.ImageColor3
            dst.ImageTransparency = src.ImageTransparency
            dst.ScaleType = src.ScaleType
            dst.SliceCenter = src.SliceCenter
            dst.SliceScale = src.SliceScale
            dst.ImageRectOffset = src.ImageRectOffset
            dst.ImageRectSize = src.ImageRectSize
        end
        if dst:IsA("TextLabel") and src:IsA("TextLabel") then
            dst.Text = src.Text
            dst.TextColor3 = src.TextColor3
            dst.TextTransparency = src.TextTransparency
            dst.TextScaled = src.TextScaled
            dst.TextSize = src.TextSize
            dst.TextStrokeColor3 = src.TextStrokeColor3
            dst.TextStrokeTransparency = src.TextStrokeTransparency
            dst.TextWrapped = src.TextWrapped
            dst.Font = src.Font
            dst.TextXAlignment = src.TextXAlignment
            dst.TextYAlignment = src.TextYAlignment
        end
    end

    local function startFuelSync()
        if fuelConn then
            return
        end
        fuelConn = RunService.RenderStepped:Connect(function()
            if not fuelEnabled then
                return
            end
            local source = findFuelImageLabel()
            if not source or not source.Parent then
                return
            end
            local gui = ensureFuelGui()
            local dstImage = gui:FindFirstChild("ImageLabel")
            if not dstImage then
                return
            end
            syncGuiObject(dstImage, source)

            local srcGauge = source:FindFirstChild("Gauge")
            local dstGauge = dstImage:FindFirstChild("Gauge")
            if srcGauge and dstGauge then
                syncGuiObject(dstGauge, srcGauge)
                local srcFrame = srcGauge:FindFirstChild("Frame")
                local dstFrame = dstGauge:FindFirstChild("Frame")
                if srcFrame and dstFrame then
                    syncGuiObject(dstFrame, srcFrame)
                end
            end

            local src1 = nil
            local src2 = nil
            local sourceGui = source.Parent
            if sourceGui then
                local labels = {}
                for _, child in ipairs(sourceGui:GetChildren()) do
                    if child:IsA("TextLabel") then
                        table.insert(labels, child)
                    end
                end
                if #labels >= 2 then
                    table.sort(labels, function(a, b)
                        return a.Position.X.Scale < b.Position.X.Scale
                    end)
                    src1 = labels[1]
                    src2 = labels[2]
                else
                    src1 = sourceGui:FindFirstChild("TextLabel1")
                    src2 = sourceGui:FindFirstChild("TextLabel2")
                end
            end
            local dst1 = gui:FindFirstChild("TextLabel1")
            local dst2 = gui:FindFirstChild("TextLabel2")
            if src1 and dst1 then
                syncGuiObject(dst1, src1)
            end
            if src2 and dst2 then
                syncGuiObject(dst2, src2)
            end
        end)
    end

    local function stopFuelSync()
        if fuelConn then
            fuelConn:Disconnect()
            fuelConn = nil
        end
        destroyFuelGui()
    end

    local function buildCategoryMap()
        local map = {}
        local rs = game:GetService("ReplicatedStorage")
        local assets = rs:FindFirstChild("Assets")
        local objectModels = assets and assets:FindFirstChild("ObjectModels")
        if not objectModels then
            return map
        end
        for _, categoryFolder in ipairs(objectModels:GetChildren()) do
            if categoryFolder:IsA("Folder") then
                for _, item in ipairs(categoryFolder:GetChildren()) do
                    if item:IsA("Model") then
                        if map[item.Name] == nil then
                            map[item.Name] = categoryFolder.Name
                        end
                    end
                end
            end
        end
        return map
    end

    local function getRootPart()
        local character = game.Players.LocalPlayer.Character
        if not character then
            return nil
        end
        return character:FindFirstChild("HumanoidRootPart")
    end

    local function getModelPosition(model)
        if model.PrimaryPart then
            return model.PrimaryPart.Position
        end
        local part = model:FindFirstChildWhichIsA("BasePart")
        return part and part.Position or nil
    end

    local function clearHighlight(model)
        local h = model:FindFirstChild("ArgusHighlight")
        if h then
            h:Destroy()
        end
    end

    local function updateEsp()
        if not espActive then
            return
        end
        local root = getRootPart()
        if not root then
            return
        end
        if not nameToCategory or next(nameToCategory) == nil then
            nameToCategory = buildCategoryMap()
        end
        local folder = workspace:FindFirstChild("ObjectModels")
        if not folder then
            return
        end
        for _, model in ipairs(folder:GetChildren()) do
            if model:IsA("Model") then
                local category = nameToCategory and nameToCategory[model.Name] or nil
                local enabled = category and espState.enabled[category] or false
                if enabled then
                    local pos = getModelPosition(model)
                    local withinRange = false
                    if pos then
                        withinRange = (pos - root.Position).Magnitude <= espState.maxDistance
                    end
                    if withinRange then
                        local h = model:FindFirstChild("ArgusHighlight")
                        if not h then
                            h = Instance.new("Highlight")
                            h.Name = "ArgusHighlight"
                            h.FillTransparency = 1
                            h.OutlineTransparency = 0
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Parent = model
                        end
                        h.OutlineColor = espState.colors[category] or Color3.new(1, 1, 1)
                    else
                        clearHighlight(model)
                    end
                else
                    clearHighlight(model)
                end
            end
        end
    end

    local function startEsp()
        if espConn then
            return
        end
        local last = 0
        espConn = RunService.Heartbeat:Connect(function()
            local now = tick()
            if now - last >= 0.35 then
                last = now
                updateEsp()
            end
        end)
    end

    local function stopEsp()
        if espConn then
            espConn:Disconnect()
            espConn = nil
        end
    end

    local function setEspActive()
        for _, enabled in pairs(espState.enabled) do
            if enabled then
                espActive = true
                startEsp()
                return
            end
        end
        espActive = false
        stopEsp()
        local folder = workspace:FindFirstChild("ObjectModels")
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    clearHighlight(model)
                end
            end
        end
    end

    local function setToggleDesc(toggle, text)
        if toggle and toggle.SetDesc then
            toggle:SetDesc(text)
        end
    end

    local function startUpdates(toggle)
        if updateConn then
            return
        end
        updateConn = RunService.RenderStepped:Connect(function()
            if not state.enabled then
                return
            end

            local label = findDistanceLabel()
            local text = label and label.Text or ""

            if state.mode == "In UI" then
                destroyGui()
                setToggleDesc(toggle, text)
            else
                local gui = ensureGui()
                local distanceLabel = gui and gui:FindFirstChild("DistanceInfo")
                if distanceLabel then
                    distanceLabel.Text = text
                end
                setToggleDesc(toggle, nil)
            end
        end)
    end

    local function stopUpdates(toggle)
        if updateConn then
            updateConn:Disconnect()
            updateConn = nil
        end
        setToggleDesc(toggle, nil)
        destroyGui()
    end

    return {
        tabs = {
            {
                Title = "Info",
                Icon = "solar:speedometer-bold-duotone",
                build = function(tab)
                    local toggleRef = nil

                    tab:Dropdown({
                        Title = "Info Type",
                        Values = { "In UI", "Ingame" },
                        Value = state.mode,
                        Multi = false,
                        Callback = function(option)
                            local selected = typeof(option) == "table" and option[1] or option
                            if selected == "In UI" or selected == "Ingame" then
                                state.mode = selected
                                if state.enabled and toggleRef then
                                    if selected == "In UI" then
                                        destroyGui()
                                    end
                                end
                            end
                        end,
                    })

                    toggleRef = tab:Toggle({
                        Title = "Train distance",
                        Value = false,
                        Callback = function(value)
                            state.enabled = value
                            if value then
                                startUpdates(toggleRef)
                            else
                                stopUpdates(toggleRef)
                            end
                        end,
                    })

                    tab:Toggle({
                        Title = "Fuel UI",
                        Value = false,
                        Callback = function(value)
                            fuelEnabled = value
                            if value then
                                startFuelSync()
                            else
                                stopFuelSync()
                            end
                        end,
                    })
                end,
            },
            {
                Title = "ESP",
                Icon = "solar:diamond-bold-duotone",
                build = function(tab)
                    espState.maxDistance = 500
                    espState.enabled = {
                        Ammo = false,
                        AprilFools = false,
                        Decoration = false,
                        Easter = false,
                        Equipment = false,
                        Material = false,
                        Medical = false,
                        Misc = false,
                        Valuable = false,
                        Weapon = false,
                    }
                    espState.colors = {
                        Ammo = Color3.new(0, 0, 0),
                        AprilFools = Color3.new(1, 1, 1),
                        Decoration = Color3.fromRGB(101, 67, 33),
                        Easter = Color3.fromRGB(255, 105, 180),
                        Equipment = Color3.fromRGB(128, 128, 128),
                        Material = Color3.fromRGB(60, 60, 60),
                        Medical = Color3.fromRGB(0, 102, 255),
                        Misc = Color3.fromRGB(255, 0, 0),
                        Valuable = Color3.fromRGB(0, 255, 0),
                        Weapon = Color3.fromRGB(255, 255, 0),
                    }

                    tab:Slider({
                        Title = "Max Distance",
                        Step = 1,
                        Value = {
                            Min = 15,
                            Max = 5000,
                            Default = espState.maxDistance,
                        },
                        Callback = function(value)
                            espState.maxDistance = value
                        end,
                    })

                    local function addEspToggle(name)
                        tab:Toggle({
                            Title = name,
                            Value = false,
                            Callback = function(value)
                                espState.enabled[name] = value
                                setEspActive()
                            end,
                        })
                        if tab.Colorpicker then
                            tab:Colorpicker({
                                Title = name .. " Color",
                                Value = espState.colors[name],
                                Callback = function(value)
                                    espState.colors[name] = value
                                end,
                            })
                        elseif tab.ColorPicker then
                            tab:ColorPicker({
                                Title = name .. " Color",
                                Value = espState.colors[name],
                                Callback = function(value)
                                    espState.colors[name] = value
                                end,
                            })
                        end
                    end

                    addEspToggle("Ammo")
                    addEspToggle("AprilFools")
                    addEspToggle("Decoration")
                    addEspToggle("Easter")
                    addEspToggle("Equipment")
                    addEspToggle("Material")
                    addEspToggle("Medical")
                    addEspToggle("Misc")
                    addEspToggle("Valuable")
                    addEspToggle("Weapon")
                end,
            },
        },
    }
end
