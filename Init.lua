local Games = {
    [13644806894] = "https://gist.githubusercontent.com/Offsetmanager/dc87c86e007207112513fddebccad167/raw/90695c5219393db3568f9c9e33c0df028f6f7454/gistfile1.txt",
    [2768379856] = "https://gist.githubusercontent.com/Offsetmanager/7c6e0b737d5874652a3a05cfc230efae/raw/9ab4441cffd3c3e5eef4c39b7fff0c3ad170bf21/gistfile1.txt",
}
local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local url = Games[game.PlaceId]
if url then loadstring(game:HttpGet(url))() else LocalPlayer:Kick("Not found your game, ask hub owner for help.") end
