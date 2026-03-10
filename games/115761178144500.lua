return function(ctx)
    local Players = ctx.Players

    return {
        tabs = {
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
