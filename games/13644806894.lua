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
                                Content = "(Visual only) Team changed, reset pls.",
                                Duration = 4,
                            })
                        else end
                    end

                    tab:Button({ Title = "Civilian", Callback = function() setTeam("Civilian") end })
                    tab:Button({ Title = "Basic Training", Callback = function() setTeam("Basic Training") end })
                    tab:Button({ Title = "Police Department", Callback = function() setTeam("Police Department") end })
                    tab:Button({ Title = "Academy Security Unit", Callback = function() setTeam("Academy Security Unit") end })
                    tab:Button({ Title = "SWAT", Callback = function() setTeam("Special Weapons & Tactics") end })
                    tab:Button({ Title = "Traffic Unit", Callback = function() setTeam("Traffic Unit") end })
                    tab:Button({ Title = "Training & Discipline", Callback = function() setTeam("Training & Discipline") end })
                    tab:Button({ Title = "Police Headquarters", Callback = function() setTeam("Police Headquarters") end })
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

                    tab:Button({ Title = "MFD", Callback = function() cloneTool("MFD") end })
                    tab:Button({ Title = "Clipboard", Callback = function() cloneTool("Clipboard") end })
                    tab:Button({ Title = "Base Access", Callback = function() cloneTool("Base Access") end })
                    tab:Button({ Title = "Props", Callback = function() cloneTool("Props") end })
                    tab:Button({ Title = "BoomBox", Callback = function() cloneTool("BoomBox") end })
                    tab:Button({ Title = "X7", Callback = function() cloneTool("X7") end })
                    tab:Button({ Title = "Breach Shield", Callback = function() cloneTool("Breach Shield") end })
                    tab:Button({ Title = "Riot Shield", Callback = function() cloneTool("Riot Shield") end })
                    tab:Button({ Title = "Flashlight", Callback = function() cloneTool("Flashlight") end })
                    tab:Button({ Title = "Honey Badger", Callback = function() cloneTool("Honey Badger") end })
                end,
            },
        },
    }
end
