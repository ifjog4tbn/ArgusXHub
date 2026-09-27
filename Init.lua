local Games = {
    [13644806894] = "https://gist.githubusercontent.com/Offsetmanager/dc87c86e007207112513fddebccad167/raw/90695c5219393db3568f9c9e33c0df028f6f7454/gistfile1.txt",
    [2768379856] = "https://gist.githubusercontent.com/Offsetmanager/7c6e0b737d5874652a3a05cfc230efae/raw/9ab4441cffd3c3e5eef4c39b7fff0c3ad170bf21/gistfile1.txt",
    [12355337193] = "https://gist.githubusercontent.com/Offsetmanager/c11d6dcc688a099b347c54c5d9be3286/raw/246398e31d48939a81965d949e756f158d6a11a9/12355337193_obf.lua",
    [78475473751685] = "https://gist.githubusercontent.com/Offsetmanager/c617794e7f9791b74877d8148855ba95/raw/7cfe68a14ddeb64cb351332ebbe8be6d8a352dad/gistfile1.txt",
    [133769280473647] = "https://gist.githubusercontent.com/Offsetmanager/05d076822b92e7a19f67323bf1c5fdf5/raw/c9fff90fbf0d8a2131ba2dbb566666d875187bb2/gistfile1.txt",
    [130172344017004] = "https://gist.githubusercontent.com/Offsetmanager/05d076822b92e7a19f67323bf1c5fdf5/raw/c9fff90fbf0d8a2131ba2dbb566666d875187bb2/gistfile1.txt",
    [103854444055060] = "https://gist.githubusercontent.com/Offsetmanager/d17c0ef63e2527419f85a7c1a8c41b52/raw/18f41884910961722c8f83c938e2eabae41d7a0a/gistfile1.txt",
    [537413528] = "https://gist.githubusercontent.com/Offsetmanager/342e7137d1e1e258dc3eb8f1522ef12f/raw/57c098f665876c26c05fceaffb5a5c16e74ee2e1/gistfile1.txt",
}
local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local url = Games[game.PlaceId]
if url then loadstring(game:HttpGet(url))() else LocalPlayer:Kick("Not found your game, ask hub owner for help.") end
