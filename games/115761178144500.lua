return function(ctx)
    local Players = ctx.Players

    return {
        tabs = {
            {
                Title = "Lobby",
                Icon = "solar:compass-big-bold-duotone",
                build = function(tab)
                    tab:Button({
                        Title = "Remove Prompt Favorite",
                        Desc = "Removing stupid ad",
                        Callback = function()
                            local player = Players.LocalPlayer
                            if not player then
                                return
                            end

                            local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
                            local prompt = playerGui and playerGui:FindFirstChild("PromptFavorite", true)
                            if prompt then
                                prompt:Destroy()
                            end
                        end,
                    })

                    tab:Button({
                        Title = "Disable notification ads",
                        Callback = function()
                            local player = Players.LocalPlayer
                            if not player then
                                return
                            end

                            local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
                            local mainGui = playerGui and playerGui:FindFirstChild("Main")
                            local notifications = mainGui and mainGui:FindFirstChild("Notifications")
                            local manager = notifications and notifications:FindFirstChild("NotificationsManager")
                            if manager and manager:IsA("LocalScript") then
                                manager:Destroy()
                            end

                            if not notifications or not manager then
                                return
                            end

                            if notifications:FindFirstChild("ArgusX_NotificationsManager") then
                                return
                            end

                            local tag = Instance.new("BoolValue")
                            tag.Name = "ArgusX_NotificationsManager"
                            tag.Parent = notifications

                            local TweenService = game:GetService("TweenService")
                            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("ErrorSend")
                            local cache = {}

                            local function getStackedTitle(title, count)
                                if count > 1 then
                                    return title .. " [x" .. tostring(count) .. "]"
                                end
                                return title
                            end

                            remote.OnClientEvent:Connect(function(message, color, author)
                                if message == "🎁 Join Discord server for leaks and exclusive codes!" then
                                    warn("stupid ad detected!")
                                    return
                                end

                                local key = tostring(message) .. "|" .. tostring(author or "")
                                if cache[key] then
                                    local entry = cache[key]
                                    entry.count += 1
                                    local textLabel = entry.instance:FindFirstChild("TextLabel")
                                    if textLabel then
                                        textLabel.Text = getStackedTitle(message, entry.count)
                                    end
                                    if manager:FindFirstChild("Sound") then
                                        manager.Sound:Play()
                                    end
                                    if entry.destroyConnection then
                                        task.cancel(entry.destroyConnection)
                                    end
                                    entry.destroyConnection = task.delay(10, function()
                                        local imageLabel = entry.instance:FindFirstChild("ImageLabel")
                                        if imageLabel then
                                            TweenService:Create(imageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
                                                ImageTransparency = 1,
                                            }):Play()
                                        end
                                        local label = entry.instance:FindFirstChild("TextLabel")
                                        if label then
                                            TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
                                                TextTransparency = 1,
                                            }):Play()
                                        end
                                        task.wait(0.2)
                                        entry.instance:Destroy()
                                        cache[key] = nil
                                    end)
                                else
                                    local template = manager.Parent and manager.Parent:FindFirstChild("Notification_UI")
                                    if not template then
                                        return
                                    end
                                    local clone = template:Clone()
                                    clone.Parent = manager.Parent:FindFirstChild("Actions") or manager.Parent
                                    local textLabel = clone:FindFirstChild("TextLabel")
                                    if textLabel then
                                        textLabel.Text = message
                                        textLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
                                    end
                                    local authorLabel = clone:FindFirstChild("Author")
                                    if author and authorLabel then
                                        authorLabel.Text = author
                                        if author == "InkKingRBLX" then
                                            clone.Verify.Visible = true
                                        else
                                            clone.Verify.Visible = false
                                        end
                                        clone.Dots.Visible = true
                                        clone.Nothing.Visible = true
                                        if textLabel then
                                            textLabel.TextXAlignment = Enum.TextXAlignment.Left
                                        end
                                    elseif authorLabel then
                                        authorLabel.Visible = false
                                        clone.Verify.Visible = false
                                        clone.Dots.Visible = false
                                        clone.Nothing.Visible = false
                                        if textLabel then
                                            textLabel.TextXAlignment = Enum.TextXAlignment.Center
                                        end
                                    end
                                    clone.Visible = true
                                    clone.Size = UDim2.new(0.752, 0, 0, 0)
                                    TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
                                        Size = UDim2.new(0.752, 0, 0.075, 0),
                                    }):Play()
                                    if manager:FindFirstChild("Sound") then
                                        manager.Sound:Play()
                                    end
                                    cache[key] = {
                                        instance = clone,
                                        count = 1,
                                        destroyConnection = task.delay(10, function()
                                            local imageLabel = clone:FindFirstChild("ImageLabel")
                                            if imageLabel then
                                                TweenService:Create(imageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
                                                    ImageTransparency = 1,
                                                }):Play()
                                            end
                                            local label = clone:FindFirstChild("TextLabel")
                                            if label then
                                                TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
                                                    TextTransparency = 1,
                                                }):Play()
                                            end
                                            task.wait(0.2)
                                            clone:Destroy()
                                            cache[key] = nil
                                        end),
                                    }
                                end
                            end)
                        end,
                    })

                    tab:Paragraph({
                        Title = "Teleports",
                        Desc = "TP to any systems positions",
                    })

                    local function tp(x, y, z)
                        local player = Players.LocalPlayer
                        local character = player and player.Character
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(x, y + 3, z)
                        end
                    end

                    tab:Button({ Title = "Spawn", Callback = function() tp(126, 116, 321) end })
                    tab:Button({ Title = "Summon", Callback = function() tp(295, 135, 318) end })
                    tab:Button({ Title = "Exclusive Unit", Callback = function() tp(294, 135, 289) end })
                    tab:Button({ Title = "Season Pass", Callback = function() tp(188, 110, 223) end })
                    tab:Button({ Title = "Hardcore Merchant", Callback = function() tp(49, 110, 289) end })
                    tab:Button({ Title = "Merchant", Callback = function() tp(46, 110, 322) end })
                    tab:Button({ Title = "Heroes", Callback = function() tp(59, 110, 369) end })
                    tab:Button({ Title = "Raid Merchant", Callback = function() tp(92, 110, 417) end })
                    tab:Button({ Title = "Enchants", Callback = function() tp(173, 110, 416) end })
                    tab:Button({ Title = "Crafts", Callback = function() tp(215, 110, 385) end })
                    tab:Button({ Title = "Index", Callback = function() tp(290, 135, 350) end })
                    tab:Button({ Title = "Shop", Callback = function() tp(127, 116, 343) end })
                end,
            },
            {
                Title = "Ingame",
                Icon = "solar:lock-keyhole-unlocked-bold-duotone",
                build = function(tab)
                    tab:Button({
                        Title = "Unlock all Universes and Maps",
                        Callback = function()
                            local player = Players.LocalPlayer
                            if not player then
                                return
                            end

                            local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
                            local gameGui = playerGui and playerGui:FindFirstChild("GameGui")
                            local voting = gameGui and gameGui:FindFirstChild("Voting")
                            local universesContainer = voting and voting:FindFirstChild("Universes")
                            local mapsContainer = voting and voting:FindFirstChild("Maps")

                            local function unlock(container)
                                if not container then
                                    return
                                end
                                for _, child in ipairs(container:GetChildren()) do
                                    if child:IsA("ImageButton") then
                                        child.Interactable = true
                                        local lockedObject = child:FindFirstChild("Locked")
                                        if lockedObject then
                                            lockedObject:Destroy()
                                        end
                                    end
                                end
                            end

                            unlock(universesContainer)
                            unlock(mapsContainer)
                        end,
                    })
                end,
            },
        },
    }
end
