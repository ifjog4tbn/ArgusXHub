return function(ctx)
    local Players = ctx.Players
    local WindUI = ctx.WindUI

    return {
        tabs = {
            {
                Title = "Police Teams",
                build = function(tab)
                    tab:Section({ Title = "Police Academy Roleplay 2" })

                    local function setTeam(teamName)
                        local teams = game:GetService("Teams")
                        local localPlayer = Players.LocalPlayer
                        local team = teams:FindFirstChild(teamName)
                        if localPlayer and team then
                            localPlayer.Team = team
                            WindUI:Notify({
                                Title = "Argus X",
                                Content = "Team changed to: " .. teamName,
                                Duration = 4,
                            })
                        else
                            WindUI:Notify({
                                Title = "Argus X",
                                Content = "Team not found: " .. teamName,
                                Duration = 4,
                            })
                        end
                    end

                    tab:Button({ Title = "Set Team: Civilian", Callback = function() setTeam("Civilian") end })
                    tab:Button({ Title = "Set Team: Basic Training", Callback = function() setTeam("Basic Training") end })
                    tab:Button({ Title = "Set Team: Police Department", Callback = function() setTeam("Police Department") end })
                    tab:Button({ Title = "Set Team: Academy Security Unit", Callback = function() setTeam("Academy Security Unit") end })
                    tab:Button({ Title = "Set Team: SWAT", Callback = function() setTeam("Special Weapons & Tactics") end })
                    tab:Button({ Title = "Set Team: Traffic Unit", Callback = function() setTeam("Traffic Unit") end })
                    tab:Button({ Title = "Set Team: Training & Discipline", Callback = function() setTeam("Training & Discipline") end })
                    tab:Button({ Title = "Set Team: Police Headquarters", Callback = function() setTeam("Police Headquarters") end })
                end,
            },
            {
                Title = "Police Tools",
                build = function(tab)
                    tab:Section({ Title = "Police Academy Roleplay 2" })

                    tab:Button({
                        Title = "Destroy Shields",
                        Callback = function()
                            local shieldsToRemove = { "Breach Shield", "Riot Shield" }
                            for _, player in ipairs(Players:GetPlayers()) do
                                local character = player.Character
                                if character then
                                    for _, shieldName in ipairs(shieldsToRemove) do
                                        local shield = character:FindFirstChild(shieldName)
                                        if shield then
                                            shield:Destroy()
                                        end
                                    end
                                end
                            end
                        end,
                    })

                    local function cloneTool(toolName)
                        local replicatedStorage = game:GetService("ReplicatedStorage")
                        local cache = replicatedStorage:FindFirstChild("Cache")
                        local toolsFolder = cache and cache:FindFirstChild("Tools")
                        local localPlayer = Players.LocalPlayer
                        if not toolsFolder or not localPlayer then
                            WindUI:Notify({
                                Title = "Argus X",
                                Content = "Tools folder is missing.",
                                Duration = 4,
                            })
                            return
                        end

                        local tool = toolsFolder:FindFirstChild(toolName)
                        if not tool then
                            WindUI:Notify({
                                Title = "Argus X",
                                Content = "Tool not found: " .. toolName,
                                Duration = 4,
                            })
                            return
                        end

                        local backpack = localPlayer:FindFirstChild("Backpack")
                        if backpack then
                            tool:Clone().Parent = backpack
                            WindUI:Notify({
                                Title = "Argus X",
                                Content = "Added tool: " .. toolName,
                                Duration = 4,
                            })
                        end
                    end

                    tab:Button({ Title = "Get Tool: MFD", Callback = function() cloneTool("MFD") end })
                    tab:Button({ Title = "Get Tool: Clipboard", Callback = function() cloneTool("Clipboard") end })
                    tab:Button({ Title = "Get Tool: Base Access", Callback = function() cloneTool("Base Access") end })
                    tab:Button({ Title = "Get Tool: Props", Callback = function() cloneTool("Props") end })
                    tab:Button({ Title = "Get Tool: BoomBox", Callback = function() cloneTool("BoomBox") end })
                    tab:Button({ Title = "Get Tool: X7", Callback = function() cloneTool("X7") end })
                    tab:Button({ Title = "Get Tool: Breach Shield", Callback = function() cloneTool("Breach Shield") end })
                    tab:Button({ Title = "Get Tool: Riot Shield", Callback = function() cloneTool("Riot Shield") end })
                    tab:Button({ Title = "Get Tool: Flashlight", Callback = function() cloneTool("Flashlight") end })
                    tab:Button({ Title = "Get Tool: Honey Badger", Callback = function() cloneTool("Honey Badger") end })
                end,
            },
        },
    }
end
