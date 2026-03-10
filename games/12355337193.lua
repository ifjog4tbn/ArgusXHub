return function(ctx)
    local Players = ctx.Players
    local RunService = ctx.RunService or game:GetService("RunService")
    local WindUI = ctx.WindUI

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local DEFAULTS = {
        espEnabled = false,
        tracersEnabled = true,
        healthEnabled = true,
        boxesEnabled = true,
        targetMode = "Enemy",
        espType = "Skeleton",
        espMaxDistance = 250,
        tracerMaxDistance = 250,
        skeletonColor = Color3.fromRGB(255, 255, 255),
        tracerColor = Color3.fromRGB(255, 255, 255),
        healthColor = Color3.fromRGB(0, 255, 0),
    }

    local state = {
        espEnabled = DEFAULTS.espEnabled,
        tracersEnabled = DEFAULTS.tracersEnabled,
        healthEnabled = DEFAULTS.healthEnabled,
        boxesEnabled = DEFAULTS.boxesEnabled,
        targetMode = DEFAULTS.targetMode,
        espType = DEFAULTS.espType,
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
    local loopKillAllEnabled = false
    local loopKillConnection = nil
    local lastLoopAttack = 0
    local CHAMS_NAME = "ArgusX_ESP_Chams"
    local CHAMS_COLOR = Color3.fromRGB(255, 50, 50)
    local TARGET_PART = "Head"
    local LOOP_KILL_INTERVAL = 0.01
    local KILL_ALL_INSTANT_DELAY = 0.03
    local KILL_ALL_MAX_DIST = 200
    local killWeaponMode = "Pistol"

    local ShootGunRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")
    local StabRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Stab")
    local CharacterRayOrigin = nil
    pcall(function()
        CharacterRayOrigin = require(ReplicatedStorage.Modules.CharacterRayOrigin)
    end)

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

    local function clearChams(character)
        if not character then
            return
        end

        local old = character:FindFirstChild(CHAMS_NAME)
        if old then
            old:Destroy()
        end
    end

    local function setChams(character, enabled)
        if not character then
            return
        end

        if not enabled then
            clearChams(character)
            return
        end

        local highlight = character:FindFirstChild(CHAMS_NAME)
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = CHAMS_NAME
            highlight.Parent = character
        end

        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = CHAMS_COLOR
        highlight.OutlineColor = CHAMS_COLOR
        highlight.FillTransparency = 0.45
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    end

    local function shouldShowPlayer(player)
        if state.targetMode == "All" then
            return true
        end

        local myTeam = LocalPlayer and LocalPlayer.Team
        local targetTeam = player.Team
        local myNeutral = LocalPlayer and LocalPlayer.Neutral
        local targetNeutral = player.Neutral

        if myNeutral or targetNeutral then
            return false
        end

        if not myTeam or not targetTeam then
            return false
        end

        if myTeam.Name == "Team1" then
            return targetTeam.Name == "Team2"
        end

        if myTeam.Name == "Team2" then
            return targetTeam.Name == "Team1"
        end

        return targetTeam ~= myTeam
    end

    local function isEnemyPlayer(player)
        return shouldShowPlayer(player)
    end

    local function getAliveTargets()
        local targets = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isEnemyPlayer(player) then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(targets, player)
                end
            end
        end
        return targets
    end

    local function getLocalCharacter()
        return LocalPlayer and LocalPlayer.Character
    end

    local function getEquippedWeapon()
        local character = getLocalCharacter()
        if not character then
            return nil
        end
        return character:FindFirstChildOfClass("Tool")
    end

    local function hasReloadAndFire(tool)
        if not tool then
            return false
        end
        return tool:FindFirstChild("Reload", true) ~= nil and tool:FindFirstChild("Fire", true) ~= nil
    end

    local function findToolByMode(mode)
        local character = getLocalCharacter()
        local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
        local function matches(tool)
            if not tool or not tool:IsA("Tool") then
                return false
            end
            local hasRF = hasReloadAndFire(tool)
            if mode == "Pistol" then
                return hasRF
            end
            if mode == "Knife" then
                return not hasRF
            end
            return false
        end

        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if matches(item) then
                    return item
                end
            end
        end

        if character then
            for _, item in ipairs(character:GetChildren()) do
                if matches(item) then
                    return item
                end
            end
        end

        return nil
    end

    local function equipTool(tool)
        local character = getLocalCharacter()
        if tool and character and tool.Parent ~= character then
            tool.Parent = character
        end
    end

    local function unequipTool(tool)
        local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
        if tool and backpack and tool.Parent ~= backpack then
            tool.Parent = backpack
        end
    end

    local function equipWeaponByType(kind)
        local character = getLocalCharacter()
        local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then
            return nil
        end

        local current = getEquippedWeapon()
        if current then
            current.Parent = backpack
        end

        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local hasGun = item:FindFirstChild("Fire", true) ~= nil
                local hasKnife = item:FindFirstChild("ThrowSound", true) ~= nil
                if (kind == "Gun" and hasGun) or (kind == "Knife" and hasKnife) then
                    item.Parent = character
                    return item
                end
            end
        end

        return nil
    end

    local function shootGun(targetCharacter)
        if not targetCharacter then
            return false
        end

        local character = getLocalCharacter()
        if not character then
            return false
        end

        local part = targetCharacter:FindFirstChild(TARGET_PART) or targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("HumanoidRootPart")
        if not part then
            return false
        end

        local weapon = getEquippedWeapon()
        if not (weapon and weapon:FindFirstChild("Fire", true)) then
            weapon = equipWeaponByType("Gun")
        end
        if not weapon then
            return false
        end

        local origin = nil
        if CharacterRayOrigin then
            local ok, value = pcall(function()
                return CharacterRayOrigin(character)
            end)
            if ok then
                origin = value
            end
        end
        if origin == nil then
            local root = character:FindFirstChild("HumanoidRootPart")
            origin = root and root.Position or Camera.CFrame.Position
        end

        local targetPos = part.Position
        pcall(function()
            weapon:Activate()
        end)
        pcall(function()
            ShootGunRemote:FireServer(origin, targetPos, part, targetPos)
        end)
        return true
    end

    local function stabKnife(targetCharacter)
        if not targetCharacter then
            return false
        end

        local part = targetCharacter:FindFirstChild(TARGET_PART) or targetCharacter:FindFirstChild("Head")
        if not part then
            return false
        end

        local weapon = getEquippedWeapon()
        if not (weapon and weapon:FindFirstChild("ThrowSound", true)) then
            weapon = equipWeaponByType("Knife")
        end
        if not weapon then
            return false
        end

        pcall(function()
            StabRemote:FireServer(part)
        end)
        return true
    end

    local function attackTarget(targetCharacter)
        if killWeaponMode == "Knife" then
            local weapon = getEquippedWeapon()
            if not (weapon and weapon:FindFirstChild("ThrowSound", true)) then
                if not equipWeaponByType("Knife") then
                    return false
                end
                task.wait(0.05)
            end
            return stabKnife(targetCharacter)
        end

        local weapon = getEquippedWeapon()
        if not (weapon and weapon:FindFirstChild("Fire", true)) then
            if not equipWeaponByType("Gun") then
                return false
            end
            task.wait(0.05)
        end
        return shootGun(targetCharacter)
    end

    local function killAllInstant()
        local character = getLocalCharacter()
        local localRoot = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not localRoot then
            return
        end
        if LocalPlayer and LocalPlayer.Neutral then
            return
        end

        local tool = findToolByMode(killWeaponMode)
        if not tool then
            return
        end

        equipTool(tool)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isEnemyPlayer(player) then
                local targetChar = player.Character
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                local humanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                if targetRoot and humanoid and humanoid.Health > 1 then
                    local dist = (targetRoot.Position - localRoot.Position).Magnitude
                    if dist <= KILL_ALL_MAX_DIST then
                        if killWeaponMode == "Pistol" then
                            local myPos = localRoot.Position
                            local victimPos = targetRoot.Position
                            local dir = victimPos - myPos
                            if dir.Magnitude > 0 then
                                local thirdPos = victimPos + dir.Unit * 50
                                pcall(function()
                                    ShootGunRemote:FireServer(myPos, thirdPos, targetRoot, victimPos)
                                end)
                            end
                        else
                            pcall(function()
                                StabRemote:FireServer(targetRoot)
                            end)
                        end
                        task.wait(KILL_ALL_INSTANT_DELAY)
                    end
                end
            end
        end

        unequipTool(tool)
    end

    local function startLoopKillAll()
        if loopKillConnection then
            return
        end

        loopKillConnection = RunService.Heartbeat:Connect(function()
            if not loopKillAllEnabled then
                return
            end
            if LocalPlayer and LocalPlayer.Neutral then
                return
            end

            local now = tick()
            if now - lastLoopAttack < LOOP_KILL_INTERVAL then
                return
            end

            local targets = getAliveTargets()
            for _, player in ipairs(targets) do
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 1 then
                    attackTarget(character)
                    lastLoopAttack = now
                end
            end
        end)
    end

    local function stopLoopKillAll()
        if loopKillConnection then
            loopKillConnection:Disconnect()
            loopKillConnection = nil
        end
    end

    local function colorToArray(color)
        return {
            math.floor((color.R or 0) * 255 + 0.5),
            math.floor((color.G or 0) * 255 + 0.5),
            math.floor((color.B or 0) * 255 + 0.5),
        }
    end

    local function arrayToColor(value, fallback)
        if type(value) == "table" and #value >= 3 then
            local r = tonumber(value[1]) or 255
            local g = tonumber(value[2]) or 255
            local b = tonumber(value[3]) or 255
            return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
        end
        return fallback
    end

    local function getConfigState()
        return {
            espEnabled = state.espEnabled,
            tracersEnabled = state.tracersEnabled,
            healthEnabled = state.healthEnabled,
            boxesEnabled = state.boxesEnabled,
            targetMode = state.targetMode,
            espType = state.espType,
            espMaxDistance = state.espMaxDistance,
            tracerMaxDistance = state.tracerMaxDistance,
            skeletonColor = colorToArray(state.skeletonColor),
            tracerColor = colorToArray(state.tracerColor),
            healthColor = colorToArray(state.healthColor),
            killWeaponMode = killWeaponMode,
            loopKillAllEnabled = loopKillAllEnabled,
        }
    end

    local function applyConfigState(payload)
        if type(payload) ~= "table" then
            return false, "Invalid config payload."
        end

        state.espEnabled = payload.espEnabled == true
        state.tracersEnabled = payload.tracersEnabled ~= false
        state.healthEnabled = payload.healthEnabled ~= false
        state.boxesEnabled = payload.boxesEnabled ~= false

        local targetMode = tostring(payload.targetMode or state.targetMode)
        if targetMode == "Enemy" or targetMode == "All" then
            state.targetMode = targetMode
        end

        local espType = tostring(payload.espType or state.espType)
        if espType == "None" or espType == "Skeleton" or espType == "Chams" then
            state.espType = espType
        end

        state.espMaxDistance = math.clamp(tonumber(payload.espMaxDistance) or state.espMaxDistance, 25, 300)
        state.tracerMaxDistance = math.clamp(tonumber(payload.tracerMaxDistance) or state.tracerMaxDistance, 25, 300)

        state.skeletonColor = arrayToColor(payload.skeletonColor, state.skeletonColor)
        state.tracerColor = arrayToColor(payload.tracerColor, state.tracerColor)
        state.healthColor = arrayToColor(payload.healthColor, state.healthColor)

        local weaponMode = tostring(payload.killWeaponMode or killWeaponMode)
        if weaponMode == "Pistol" or weaponMode == "Knife" then
            killWeaponMode = weaponMode
        end

        local nextLoopState = payload.loopKillAllEnabled == true
        loopKillAllEnabled = nextLoopState
        if nextLoopState then
            startLoopKillAll()
        else
            stopLoopKillAll()
        end

        if state.espEnabled then
            startEsp()
        else
            stopEsp()
        end

        return true
    end

    local function removeEspForPlayer(player)
        local components = espCache[player]
        if not components then
            local character = player.Character
            if character then
                clearChams(character)
            end
            return
        end

        components.Box:Remove()
        components.Tracer:Remove()
        components.HealthBar.Outline:Remove()
        components.HealthBar.Fill:Remove()

        for _, line in pairs(components.SkeletonLines) do
            line:Remove()
        end

        local character = player.Character
        if character then
            clearChams(character)
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
            clearChams(character)
            return
        end

        if not shouldShowPlayer(player) then
            hideComponents(components)
            clearChams(character)
            return
        end

        local distance = (localRoot.Position - hrp.Position).Magnitude
        if distance > state.espMaxDistance then
            hideComponents(components)
            clearChams(character)
            return
        end

        if state.espType == "Chams" then
            setChams(character, true)
        else
            clearChams(character)
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
        local boxPosition = Vector2.new(hrpPos.X - (boxWidth / 2), hrpPos.Y - (boxHeight / 2))

        if state.boxesEnabled then
            components.Box.Size = Vector2.new(boxWidth, boxHeight)
            components.Box.Position = boxPosition
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
            components.HealthBar.Outline.Position = Vector2.new(boxPosition.X - healthBarWidth - 2, boxPosition.Y)
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

            if state.espType == "Skeleton" then
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
            local character = player and player.Character
            if character then
                clearChams(character)
            end
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
                Title = "Combat",
                Icon = "solar:danger-bold-duotone",
                build = function(tab)
                    tab:Section({ Title = "Combat" })

                    tab:Dropdown({
                        Title = "Kill Weapon",
                        Values = { "Pistol", "Knife" },
                        Value = killWeaponMode,
                        Multi = false,
                        Callback = function(option)
                            local selected = typeof(option) == "table" and option[1] or option
                            if selected == "Pistol" or selected == "Knife" then
                                killWeaponMode = selected
                            end
                        end,
                    })

                    tab:Button({
                        Title = "Kill All (Instant)",
                        Callback = function()
                            killAllInstant()
                        end,
                    })

                    tab:Toggle({
                        Title = "Loop Kill All",
                        Value = false,
                        Callback = function(value)
                            loopKillAllEnabled = value
                            if value then
                                startLoopKillAll()
                            else
                                stopLoopKillAll()
                            end
                            if WindUI then
                                WindUI:Notify({
                                    Title = "Loop Kill All",
                                    Content = value and "Enabled" or "Disabled",
                                    Duration = 3,
                                })
                            end
                        end,
                    })
                end,
            },
            {
                Title = "ESP",
                Icon = "solar:eye-scan-bold-duotone",
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

                    tab:Dropdown({
                        Title = "ESP Targets",
                        Values = { "Enemy", "All" },
                        Value = state.targetMode,
                        Multi = false,
                        Callback = function(option)
                            local selected = typeof(option) == "table" and option[1] or option
                            if selected == "Enemy" or selected == "All" then
                                state.targetMode = selected
                            end
                        end,
                    })

                    tab:Dropdown({
                        Title = "ESP Type",
                        Values = { "None", "Skeleton", "Chams" },
                        Value = state.espType,
                        Multi = false,
                        Callback = function(option)
                            local selected = typeof(option) == "table" and option[1] or option
                            if selected == "None" or selected == "Skeleton" or selected == "Chams" then
                                state.espType = selected
                            end
                        end,
                    })

                    tab:Slider({
                        Title = "ESP Max Distance",
                        Step = 1,
                        Value = {
                            Min = 25,
                            Max = 300,
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
                            Min = 25,
                            Max = 300,
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
        getConfigState = getConfigState,
        applyConfigState = applyConfigState,
    }
end
