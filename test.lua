local CSGService = game:GetService("NonReplicatedCSGDictionaryService")
local MouseService = game:GetService("MouseService")

local sessionID = getgenv().__AR_SESSION

if not sessionID or type(sessionID) ~= "string" then
    return
end

local initialMarker = CSGService:FindFirstChild(sessionID)
if not initialMarker then
    return
end

local responseMarker = Instance.new("StringValue")
responseMarker.Name = sessionID
responseMarker.Value = "Confirm"
responseMarker.Parent = MouseService
