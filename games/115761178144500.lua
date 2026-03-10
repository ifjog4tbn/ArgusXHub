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
