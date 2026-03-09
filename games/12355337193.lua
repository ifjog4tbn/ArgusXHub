return function(ctx)
    local Players = ctx.Players
    local TeleportService = ctx.TeleportService

    return {
        tabs = {
            {
                Title = "Combat",
                build = function(tab)
                    tab:Section({ Title = "Kill Aura" })

                    local killAuraEnabled = false
                    local killAuraRange = 14
                    local killAuraCooldown = 0.15
                    local killAuraTeamCheck = true
                    local killAuraTargetPart = "HumanoidRootPart"
                    local killAuraThread = nil

                    local function getLocalCharacter()
                        return Players.LocalPlayer and Players.LocalPlayer.Character
                    end

                    local function getClosestTarget()
                        local localPlayer = Players.LocalPlayer
                        local localCharacter = getLocalCharacter()
                        if not localPlayer or not localCharacter then
                            return nil
                        end

                        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
                        if not localRoot then
                            return nil
                        end

                        local bestPlayer = nil
                        local bestDistance = math.huge

                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= localPlayer then
                                if not killAuraTeamCheck or player.Team ~= localPlayer.Team then
                                    local character = player.Character
                                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                                    local targetPart = character and character:FindFirstChild(killAuraTargetPart)
                                    if humanoid and humanoid.Health > 0 and targetPart then
                                        local dist = (targetPart.Position - localRoot.Position).Magnitude
                                        if dist <= killAuraRange and dist < bestDistance then
                                            bestDistance = dist
                                            bestPlayer = player
                                        end
                                    end
                                end
                            end
                        end

                        return bestPlayer
                    end

                    local function tryActivateWeapon()
                        local localPlayer = Players.LocalPlayer
                        local character = getLocalCharacter()
                        if not localPlayer or not character then
                            return
                        end

                        local backpack = localPlayer:FindFirstChild("Backpack")
                        local weapon = nil
                        local names = { "Knife", "Gun", "Revolver", "Sword", "Weapon" }

                        for _, itemName in ipairs(names) do
                            weapon = character:FindFirstChild(itemName) or (backpack and backpack:FindFirstChild(itemName))
                            if weapon then
                                break
                            end
                        end

                        if weapon and weapon.Parent ~= character then
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                pcall(function()
                                    humanoid:EquipTool(weapon)
                                end)
                            end
                        end

                        if weapon then
                            pcall(function()
                                weapon:Activate()
                            end)
                        end
                    end

                    local function startKillAura()
                        if killAuraThread then
                            return
                        end

                        killAuraThread = task.spawn(function()
                            while killAuraEnabled do
                                local localCharacter = getLocalCharacter()
                                local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                                local targetPlayer = getClosestTarget()
                                local targetCharacter = targetPlayer and targetPlayer.Character
                                local targetPart = targetCharacter and targetCharacter:FindFirstChild(killAuraTargetPart)

                                if localRoot and targetPart then
                                    pcall(function()
                                        localRoot.CFrame = CFrame.new(localRoot.Position, targetPart.Position)
                                    end)
                                    tryActivateWeapon()
                                end

                                task.wait(killAuraCooldown)
                            end

                            killAuraThread = nil
                        end)
                    end

                    tab:Toggle({
                        Title = "Enable Kill Aura",
                        Value = false,
                        Callback = function(value)
                            killAuraEnabled = value
                            if value then
                                startKillAura()
                            end
                        end,
                    })

                    tab:Slider({
                        Title = "Kill Aura Range",
                        Step = 1,
                        Value = {
                            Min = 5,
                            Max = 30,
                            Default = killAuraRange,
                        },
                        Callback = function(value)
                            killAuraRange = value
                        end,
                    })

                    tab:Slider({
                        Title = "Kill Aura Cooldown",
                        Step = 1,
                        Value = {
                            Min = 1,
                            Max = 20,
                            Default = 3,
                        },
                        Callback = function(value)
                            killAuraCooldown = value / 100
                        end,
                    })

                    tab:Toggle({
                        Title = "Team Check",
                        Value = true,
                        Callback = function(value)
                            killAuraTeamCheck = value
                        end,
                    })

                    tab:Dropdown({
                        Title = "Target Part",
                        Values = { "Head", "HumanoidRootPart", "UpperTorso" },
                        Value = killAuraTargetPart,
                        Multi = false,
                        Callback = function(option)
                            local selected = typeof(option) == "table" and option[1] or option
                            if selected then
                                killAuraTargetPart = selected
                            end
                        end,
                    })
                end,
            },
            {
                Title = "Visual",
                build = function(tab)
                    tab:Section({ Title = "ESP" })

                    local espEnabled = false
                    local espTeamCheck = true
                    local espShowName = true
                    local espShowDistance = true
                    local espRainbow = false
                    local espLoopThread = nil

                    local function clearVisuals(character)
                        for _, instance in ipairs(character:GetChildren()) do
                            if instance.Name == "ArgusX_ESP_Highlight" or instance.Name == "ArgusX_ESP_Tag" then
                                instance:Destroy()
                            end
                        end
                    end

                    local function applyVisual(player)
                        local localPlayer = Players.LocalPlayer
                        local character = player.Character
                        local localCharacter = localPlayer and localPlayer.Character
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                        if not character or not root then
                            return
                        end

                        if espTeamCheck and localPlayer and player.Team == localPlayer.Team then
                            clearVisuals(character)
                            return
                        end

                        local highlight = character:FindFirstChild("ArgusX_ESP_Highlight")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "ArgusX_ESP_Highlight"
                            highlight.FillTransparency = 1
                            highlight.OutlineTransparency = 0
                            highlight.Parent = character
                        end
                        highlight.Adornee = character
                        highlight.OutlineColor = espRainbow and Color3.fromHSV((tick() * 0.25) % 1, 1, 1) or Color3.fromRGB(75, 200, 130)

                        local billboard = character:FindFirstChild("ArgusX_ESP_Tag")
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "ArgusX_ESP_Tag"
                            billboard.Size = UDim2.new(0, 180, 0, 40)
                            billboard.StudsOffset = Vector3.new(0, 3.2, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = character

                            local label = Instance.new("TextLabel")
                            label.Name = "Label"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextScaled = true
                            label.Font = Enum.Font.SourceSansBold
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.Parent = billboard
                        end

                        local label = billboard:FindFirstChild("Label")
                        if label then
                            local text = ""
                            if espShowName then
                                text = player.Name
                            end
                            if espShowDistance and localRoot then
                                local distance = math.floor((root.Position - localRoot.Position).Magnitude)
                                text = text ~= "" and (text .. " | " .. distance .. "m") or (distance .. "m")
                            end
                            if text == "" then
                                text = "ESP"
                            end
                            label.Text = text
                        end
                    end

                    local function startESP()
                        if espLoopThread then
                            return
                        end

                        espLoopThread = task.spawn(function()
                            while espEnabled do
                                for _, player in ipairs(Players:GetPlayers()) do
                                    if player ~= Players.LocalPlayer then
                                        applyVisual(player)
                                    end
                                end
                                task.wait(0.1)
                            end

                            for _, player in ipairs(Players:GetPlayers()) do
                                local character = player.Character
                                if character then
                                    clearVisuals(character)
                                end
                            end
                            espLoopThread = nil
                        end)
                    end

                    tab:Toggle({
                        Title = "Enable ESP",
                        Value = false,
                        Callback = function(value)
                            espEnabled = value
                            if value then
                                startESP()
                            end
                        end,
                    })

                    tab:Toggle({
                        Title = "Team Check",
                        Value = true,
                        Callback = function(value)
                            espTeamCheck = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Names",
                        Value = true,
                        Callback = function(value)
                            espShowName = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Show Distance",
                        Value = true,
                        Callback = function(value)
                            espShowDistance = value
                        end,
                    })

                    tab:Toggle({
                        Title = "Rainbow Mode",
                        Value = false,
                        Callback = function(value)
                            espRainbow = value
                        end,
                    })
                end,
            },
            {
                Title = "World",
                build = function(tab)
                    tab:Section({ Title = "Movement" })

                    local localPlayer = Players.LocalPlayer
                    local walkSpeedEnabled = false
                    local walkSpeedValue = 16
                    local jumpPowerEnabled = false
                    local jumpPowerValue = 50
                    local bhopEnabled = false
                    local spinbotEnabled = false
                    local spinSpeed = 20
                    local bigHeadEnabled = false
                    local bigHeadSize = 4
                    local noclipEnabled = false
                    local jobIdValue = ""

                    local function getHumanoid()
                        local character = localPlayer and localPlayer.Character
                        return character and character:FindFirstChildOfClass("Humanoid")
                    end

                    local function applyMovement()
                        local humanoid = getHumanoid()
                        if not humanoid then
                            return
                        end
                        humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or 16
                        humanoid.JumpPower = jumpPowerEnabled and jumpPowerValue or 50
                    end

                    task.spawn(function()
                        while true do
                            local character = localPlayer and localPlayer.Character
                            local humanoid = getHumanoid()
                            local root = character and character:FindFirstChild("HumanoidRootPart")

                            if bhopEnabled and humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end

                            if spinbotEnabled and root then
                                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                            end

                            if bigHeadEnabled and character then
                                for _, player in ipairs(Players:GetPlayers()) do
                                    if player ~= localPlayer and player.Character then
                                        local head = player.Character:FindFirstChild("Head")
                                        if head and head:IsA("BasePart") then
                                            head.Size = Vector3.new(bigHeadSize, bigHeadSize, bigHeadSize)
                                            head.Massless = true
                                        end
                                    end
                                end
                            end

                            if noclipEnabled and character then
                                for _, part in ipairs(character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                            end

                            applyMovement()
                            task.wait(0.08)
                        end
                    end)

                    tab:Toggle({ Title = "Bunny Hop (Auto)", Value = false, Callback = function(value) bhopEnabled = value end })
                    tab:Toggle({
                        Title = "Custom WalkSpeed",
                        Value = false,
                        Callback = function(value)
                            walkSpeedEnabled = value
                            applyMovement()
                        end,
                    })

                    tab:Slider({
                        Title = "WalkSpeed",
                        Step = 1,
                        Value = { Min = 16, Max = 200, Default = 16 },
                        Callback = function(value)
                            walkSpeedValue = value
                            applyMovement()
                        end,
                    })

                    tab:Toggle({
                        Title = "Custom JumpPower",
                        Value = false,
                        Callback = function(value)
                            jumpPowerEnabled = value
                            applyMovement()
                        end,
                    })

                    tab:Slider({
                        Title = "JumpPower",
                        Step = 1,
                        Value = { Min = 50, Max = 300, Default = 50 },
                        Callback = function(value)
                            jumpPowerValue = value
                            applyMovement()
                        end,
                    })

                    tab:Toggle({ Title = "Spin Bot", Value = false, Callback = function(value) spinbotEnabled = value end })

                    tab:Slider({
                        Title = "Spin Speed",
                        Step = 1,
                        Value = { Min = 1, Max = 60, Default = 20 },
                        Callback = function(value)
                            spinSpeed = value
                        end,
                    })

                    tab:Toggle({ Title = "Big Head", Value = false, Callback = function(value) bigHeadEnabled = value end })

                    tab:Slider({
                        Title = "Head Size",
                        Step = 1,
                        Value = { Min = 2, Max = 20, Default = 4 },
                        Callback = function(value)
                            bigHeadSize = value
                        end,
                    })

                    tab:Toggle({ Title = "No Clip", Value = false, Callback = function(value) noclipEnabled = value end })

                    tab:Section({ Title = "Server Rejoin" })
                    tab:Button({
                        Title = "Rejoin Same Server",
                        Callback = function()
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
                            end)
                        end,
                    })
                    tab:Button({
                        Title = "Rejoin Random Server",
                        Callback = function()
                            pcall(function()
                                TeleportService:Teleport(game.PlaceId)
                            end)
                        end,
                    })
                    tab:Input({
                        Title = "Custom JobId",
                        Placeholder = "Paste server JobId",
                        Callback = function(value)
                            jobIdValue = tostring(value or "")
                        end,
                    })
                    tab:Button({
                        Title = "Rejoin from JobId",
                        Callback = function()
                            if jobIdValue ~= "" then
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIdValue, localPlayer)
                                end)
                            end
                        end,
                    })
                end,
            },
        },
    }
end
