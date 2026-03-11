return function(ctx)
    local Players = ctx.Players
    local RunService = ctx.RunService or game:GetService("RunService")

    local player = Players.LocalPlayer
    local workspaceService = game:GetService("Workspace")
    local giveEvent = game:GetService("ReplicatedStorage"):WaitForChild("GiveEvent")

    local AUTO_TOOL_NAME = "FPV Drone"
    local autoGiveEnabled = false
    local autoGiveConn = nil

    local function getCharacter()
        return player and (player.Character or player.CharacterAdded:Wait())
    end

    local function tpToSafeZone()
        local character = getCharacter()
        if not character then
            return
        end
        character:PivotTo(CFrame.new(Vector3.new(-46.1, 4.706, -45.551)))
    end

    local function destroyInvisibleWalls()
        local function checkAndDestroy(model)
            if model.Name == "Model" and model:IsA("Model") then
                local wallCount = 0
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("BasePart") and child.Name == "Wall" then
                        if child.Color == Color3.fromRGB(165, 0, 0) then
                            wallCount = wallCount + 1
                        end
                    end
                end
                if wallCount >= 1 then
                    model:Destroy()
                end
            end
        end

        for _, obj in ipairs(workspaceService:GetChildren()) do
            checkAndDestroy(obj)
        end
    end

    local function hasToolNamed(name)
        local character = player and player.Character
        local backpack = player and player:FindFirstChild("Backpack")
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") and item.Name == name then
                    return true
                end
            end
        end
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name == name then
                    return true
                end
            end
        end
        return false
    end

    local function giveFpvDrone()
        giveEvent:FireServer()
    end

    local function startAutoGive()
        if autoGiveConn then
            return
        end
        autoGiveConn = RunService.Heartbeat:Connect(function()
            if not autoGiveEnabled then
                return
            end
            if not hasToolNamed(AUTO_TOOL_NAME) then
                giveFpvDrone()
            end
        end)
    end

    local function stopAutoGive()
        if autoGiveConn then
            autoGiveConn:Disconnect()
            autoGiveConn = nil
        end
    end

    return {
        tabs = {
            {
                Title = "Ingame",
                Icon = "solar:bolt-bold-duotone",
                build = function(tab)
                    tab:Button({
                        Title = "Teleport to safe zone",
                        Callback = function()
                            tpToSafeZone()
                        end,
                    })

                    tab:Button({
                        Title = "Destroy invisible walls",
                        Callback = function()
                            destroyInvisibleWalls()
                        end,
                    })

                    tab:Button({
                        Title = "Give fpv drone",
                        Callback = function()
                            giveFpvDrone()
                        end,
                    })

                    tab:Toggle({
                        Title = "Auto give fpv drone",
                        Value = false,
                        Callback = function(value)
                            autoGiveEnabled = value
                            if value then
                                startAutoGive()
                            else
                                stopAutoGive()
                            end
                        end,
                    })
                end,
            },
        },
    }
end
