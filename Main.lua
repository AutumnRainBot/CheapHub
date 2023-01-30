--// wait until game loaded

repeat wait() until game:IsLoaded()

--// localizations 

local getupvalues = getupvalues
local getconstants = getconstants
local getinfo = getinfo
local setupvalue = setupvalue
local validlevel = debug.validlevel or debug.isvalidlevel
local replaceclosure = replaceclosure
local getconnections = getconnections
local hookmetamethod = hookmetamethod
local newcclosure = newcclosure
local checkcaller = checkcaller
local getnamecallmethod = getnamecallmethod
local sethiddenproperty = sethiddenproperty
local gethiddenproperty = gethiddenproperty
local firesignal = firesignal


local request = request or syn and syn.request
local protect_gui = syn and function(gui) syn.protect_gui(gui) gui.Parent = game:GetService("CoreGui") end or gethui and function(gui) gui.Parent = gethui() end

local game = game
local workspace = workspace

local setmetatable = setmetatable
local type = type 
local typeof = typeof
local select = select 
local pcall = pcall
local wait = wait
local tick = tick
local getfenv = getfenv 
local setfenv = setfenv

local table_find = table.find 
local table_remove = table.remove
local table_insert = table.insert
local coroutine_yield = coroutine.yield
local coroutine_wrap = coroutine.wrap
local task_wait = task.wait
local task_spawn = task.spawn
local math_random = math.random
local math_clamp = math.clamp
local math_floor = math.floor
local math_abs = math.abs
local math_huge = math.huge
local region3_new = Region3.new
local vector3_new = Vector3.new
local cframe_new = CFrame.new
local cframe_fromeulerangles = CFrame.fromEulerAnglesYXZ
local vector2_new = Vector2.new
local raycast_params_new = RaycastParams.new
local instance_new = Instance.new
local os_time = os.time
local ray_new = Ray.new
local udim2_new = UDim2.new
local string_upper = string.upper
local color3_fromrgb = Color3.fromRGB
local toggle_mob_esp = true
local keyhandler = require(game:GetService("ReplicatedStorage").Modules.ClientManager.KeyHandler)
local stack = getupvalue(getrawmetatable(getupvalue(keyhandler, 8)).__index, 1)[1][1]
local GetKey = stack[89]
local key = stack[64]
getupvalue(GetKey, 2)[0][1][2][4] = "HtttpGet"
local ScriptContext = game:GetService("ScriptContext")
local hook = hookfunction or detour_function
local lplayer = game.Players.LocalPlayer
local character = lplayer.Character
local hum = nil
for i,v in next, getconnections(ScriptContext.Error) do
    v:Disable()
end
--// services handler

local service_cache = {}
local services = setmetatable({}, {
    __index = function(self, index)
        local cached_service = service_cache[index]
        
        if not cached_service then 
            service_cache[index] = select(2, pcall(game.GetService, game, index))
            return service_cache[index]
        end 
        
        return cached_service
    end
})



--// init variables

local player = services.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local ping_stat = services.Stats:WaitForChild("PerformanceStats"):WaitForChild("Ping")



local global_functions = {
    block_random_player = function()
        local block_player 
        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            local target_player = players_list[index]

            if target_player.Name ~= player.Name then
                block_player = target_player
                break
            end
        end

        services.StarterGui:SetCore("PromptBlockPlayer", block_player)

        local container_frame = services.CoreGui.RobloxGui:WaitForChild("PromptDialog"):WaitForChild("ContainerFrame")

        local confirm_button = container_frame:WaitForChild("ConfirmButton")
        local confirm_button_text = confirm_button:WaitForChild("ConfirmButtonText")
        
        if confirm_button_text.Text == "Block" then  
            wait()
            
            local confirm_position = confirm_button.AbsolutePosition
            
            services.VirtualInputManager:SendMouseButtonEvent(confirm_position.X + 10, confirm_position.Y + 45, 0, true, game, 0)
            task_wait()
            services.VirtualInputManager:SendMouseButtonEvent(confirm_position.X + 10, confirm_position.Y + 45, 0, false, game, 0)
        end
    end,

    is_knocked = function()
        local character = player.Character

        if character then 
            return services.CollectionService:HasTag(character, "Knocked") --Remplacer
        end 

        return false
    end
}


--// ui init

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/kanenr/under_ware/main/garbage_ui.lua"))()
local window = library:Window({Name = "CheapHub"})

local tabs = {
    movement = window:Tab({Name = "Movement"}),
    character = window:Tab({Name = "Local"}),
    misc = window:Tab({Name = "Misc"}),
    player_visuals = window:Tab({Name = "Player Visuals"}),
    game_visuals = window:Tab({Name = "Game Visuals"}),
    combat = window:Tab({Name = "Combat"}),
}

local sections = {
    movement_settings = tabs.movement:Section({Name = "Settings"}),
    local_misc = tabs.misc:Section({Name = "Misc"}),

    game_visuals_local = tabs.character:Section({Name = "No Fog / Full Bright"}),

    game_visuals_misc = tabs.game_visuals:Section({Name = "Mobs"}),
    game_visuals_trinket = tabs.game_visuals:Section({Name = "Chest"}),
    game_visuals_map = tabs.game_visuals:Section({Name = "Zones / Map"}),
    game_visuals_drop = tabs.game_visuals:Section({Name = "Bag"}),

    player_visuals_settings = tabs.player_visuals:Section({Name = "Settings"}),
    player_visuals_visual = tabs.player_visuals:Section({Name = "Visual"}),
    player_visuals_emotes = tabs.player_visuals:Section({Name = "Emotes"}),
    
    combat_settings = tabs.combat:Section({Name = "Combat / AutoParry"}),

}


-- // local features

    do
        local local_movement, local_misc = sections.movement_settings, sections.local_misc

        function CharacterStartup(char)
            hum = char:WaitForChild("Humanoid")
        end
        player.CharacterAdded:Connect(function(c)
            character = c
            CharacterStartup(character)
        end)
        
        if character then
            CharacterStartup(character)
        end

        do -- walk speed / jump height
            
            task_spawn(function()
                while task_wait() do
                    if library.flags["Walk Speed"] then 
                        if character.Humanoid.MoveDirection.Magnitude > 0 then
                            character:TranslateBy(character.Humanoid.MoveDirection * library.flags["Walk Speed Boost"]/50)
                        end
                    end
                    if library.flags["Jump Height"] then 
                        if character.Humanoid.MoveDirection.Magnitude > 0 then
                            character:TranslateBy(character.Humanoid.MoveDirection * library.flags["Jump Height Value"]/50)
                        end
                    end
                end
            end)
            local_movement:Toggle({Name = "Walk Speed"})
            local_movement:Slider({Name = "Walk Speed Boost", Min = 0, Max = 200})

            local_movement:Toggle({Name = "Jump Height"})
            local_movement:Slider({Name = "Jump Height Value", Min = 1, Max = 300})
        end

        do -- infinite jump
            services.UserInputService.JumpRequest:Connect(function()
                if library.flags["Infinite Jump"] then
                    local character = character

                    if character then 
                        local humanoid = character:FindFirstChild("Humanoid")

                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)

            local_movement:Toggle({Name = "Infinite Jump"})
        end


        do -- noclip
            local noclip_params = OverlapParams.new()
            noclip_params.MaxParts = 1
            noclip_params.FilterType = Enum.RaycastFilterType.Blacklist
            noclip_params.FilterDescendantsInstances = {workspace.Live}

            local last_noclip_time = tick()

            services.RunService.Stepped:Connect(function()
                if library.flags.NoClip then
                    local character = character

                    if character then
                        local humanoid, humanoid_root_part = character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
                        local head, torso = character:FindFirstChild("Head"), character:FindFirstChild("Torso")

                        if humanoid and humanoid_root_part and head and torso then
                            local fake_humanoid = character

                            if fake_humanoid then
                                if #workspace:GetPartsInPart(torso, noclip_params) == 1 then
                                    last_noclip_time = tick()

                                    local name_part = fake_humanoid

                                    if name_part then
                                        local name_part_head = name_part:FindFirstChild("Head")

                                        if name_part_head then
                                            torso.CanCollide = false
                                            head.CanCollide = false
                                            name_part_head.CanCollide = false
                                        end
                                    end
                                elseif tick() - last_noclip_time <= 0.1 then 
                                    humanoid.JumpPower = 0
                                end
                            end
                        end
                    end
                end
            end)

            local_misc:Toggle({Name = "NoClip"})
        end

        do -- flight
            local player_mouse = player:GetMouse()

            local empty_vector = vector3_new(0, 0, 0)
            local move_vectors = {
                w = vector3_new(0, 0, -1),
                s = vector3_new(0, 0, 1),
                d = vector3_new(1, 0, 0),
                a = vector3_new(-1, 0, 0),
                space = vector3_new(0, 1, 0),
                left_control = vector3_new(0, -1, 0)
            }

            task_spawn(function()
                while task_wait() do
                    if library.flags.Flight then
                        local character = player.Character

                        if character then
                            local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")

                            if humanoid_root_part then
                                local direction = empty_vector
                                local ping = ping_stat:GetValue()
                                local current_cframe = humanoid_root_part.CFrame

                                direction = empty_vector +
                                    (services.UserInputService:IsKeyDown("W") and move_vectors.w or empty_vector) +
                                    (services.UserInputService:IsKeyDown("S") and move_vectors.s or empty_vector) +
                                    (services.UserInputService:IsKeyDown("D") and move_vectors.d or empty_vector) +
                                    (services.UserInputService:IsKeyDown("A") and move_vectors.a or empty_vector) +
                                    (services.UserInputService:IsKeyDown("Space") and move_vectors.space or empty_vector) +
                                    (services.UserInputService:IsKeyDown("LeftControl") and move_vectors.left_control or empty_vector)
                                
                                direction = direction * 0.9

                                direction = direction * (library.flags["Flight Speed"] / 2.5)
                                humanoid_root_part.Velocity = empty_vector
                                humanoid_root_part.RotVelocity = empty_vector
                    
                                if not global_functions.is_knocked() then
                                    if not library.flags["Disable Flight Fall"] and direction.Y < 0.1 then
                                        humanoid_root_part.Velocity = vector3_new(0, -70 + math_random(1, 7), 0)
                                    end
                                end
                    
                                current_cframe = current_cframe * cframe_new(direction)
                    
                                direction = library.flags["Flight Follow Mouse"] and (player_mouse.Hit.Position - camera.CFrame.Position) or camera.CFrame.lookVector*vector3_new(1,1,1)
                                direction = current_cframe.Position + (direction.Unit)

                                if current_cframe.Y > 1e9 then -- do not remove pls
                                    current_cframe = cframe_new(current_cframe.X, math_clamp(current_cframe.Y, -1000, 1e9), current_cframe.Z)
                                end
                    
                                current_cframe = cframe_new(current_cframe.Position,direction)
                                humanoid_root_part.CFrame = current_cframe
                            end
                        end
                    end
                end
            end)

            end
            
        

            local_movement:Toggle({Name = "Flight"})
            local_movement:Slider({Name = "Flight Speed", Min = 1, Max = 5})
            local_movement:Toggle({Name = "Disable Flight Fall"})

            local_movement:Toggle({Name = "Flight Follow Mouse"})

        end


    
    do -- respawn
        sections.local_misc:Button({Name = "Respawn", Callback = function()
            local character = player.Character

            if character then 
                character:BreakJoints()
            end
        end})
    end


    do --mob esp

        function DrawMob(drop)
            --creat the name esp
            local DropText = Drawing.new("Text")
            DropText.Visible = false
            DropText.Center = true
            DropText.Outline = true
            DropText.Font = 1
            DropText.Size = 16
            DropText.OutlineColor = Color3.fromRGB(0, 0, 0);
            DropText.Color = Color3.fromRGB(255, 255, 255);
            

            --update the position of the text
            local function UPDATER()
                local c
                c = game:GetService("RunService").RenderStepped:Connect(function()
                    if drop and drop:FindFirstChild("HumanoidRootPart")then
                        --get drop on screen with 3d position
                        local dropvector, onscreen = camera:WorldToViewportPoint(drop.HumanoidRootPart.Position+Vector3.new(0,4.5,0))
                        local dist = (character:WaitForChild("HumanoidRootPart").Position - drop:FindFirstChild("HumanoidRootPart").Position).Magnitude
                        if library.flags["Mob ESP"] then
                            if onscreen then
                                if dist<=library.flags["ESP Range"] then
                                    DropText.Position = Vector2.new(dropvector.X, dropvector.Y)
                                    DropText.Text = "["..drop.Name:gsub('[%p%d]','').."]".."\n".."["..math.round(drop.Humanoid.Health).." / "..math.round(drop.Humanoid.MaxHealth).."]".."\n"..math.round(dist)
                                    DropText.Visible = true
                                    else
                                        DropText.Visible = false
                                end
                                else
                                DropText.Visible = false
                            end
                                --//toggle esp//--
                            else
                            DropText.Visible = false
                        end
                            --//No Player Found Or Dead//--
                            else
                            DropText.Visible = false
                    end
                end)
            end
            --call the function
            coroutine.wrap(UPDATER)()
        end
        --dist<= library.flags["ESP Range"]
        for i ,v in pairs(game:GetService("Workspace").Live:GetChildren())do
            if v:FindFirstChild("SpawnCF") then
                DrawMob(v)
            end
        end

        game:GetService("Workspace").Live.DescendantAdded:Connect(function(child)
            if child.Name == "HumanoidRootPart" and child.Parent:FindFirstChild("SpawnCF") and child.Parent:FindFirstChild("Target")  then
                DrawMob(child.Parent)
                wait(9e9)
            end
        end)


        sections.game_visuals_misc:Toggle({Name = "Mob ESP"})
        sections.game_visuals_misc:Slider({Name = "ESP Range", Min = 1, Max = 10000})
    end



    do --Chest esp

        function DrawChest(chest)
            --creat the name esp
            local DropText = Drawing.new("Text")
            DropText.Visible = false
            DropText.Center = true
            DropText.Outline = true
            DropText.Font = 1
            DropText.Size = 16
            DropText.OutlineColor = Color3.fromRGB(0, 0, 0);
            DropText.Color = Color3.fromRGB(0, 255, 255);
        
            local DropLine = Drawing.new("Line")
            DropLine.Visible = false
            DropLine.Thickness = 1
            DropLine.Transparency = 0.5
            --update the position of the text
            local function UPDATER()
                local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if chest and chest.Transparency == 0 then
                --get drop on screen with 3d position
                local dropvector, onscreen = camera:WorldToViewportPoint(chest.Position+Vector3.new(0,.45,0))
                local dist = (character:WaitForChild("HumanoidRootPart").Position - chest.Position).Magnitude
                if library.flags["Chest Esp"] then
                    if onscreen then
                        if dist <= library.flags["Chest Range"] then
                            DropLine.Color = DropText.Color
                            DropText.Position = Vector2.new(dropvector.X, dropvector.Y)
                            DropText.Text = "[Chest]".."\n"..math.round(dist)
                            DropText.Visible = true
                            else
                                DropText.Visible = false
                        end
                        else
                        DropText.Visible = false
                        DropLine.Visible = false
                    end
                        --//toggle esp//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
                    --//No Player Found Or Dead//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
            end)
            end
            --call the function
            coroutine.wrap(UPDATER)()
        end
    
        for i ,v in pairs(game:GetService("Workspace").Thrown:GetDescendants())do
            if v.Name =="Lid" then
                DrawChest(v)
            end
        end

        game:GetService("Workspace").Thrown.DescendantAdded:Connect(function(child)
            if child.Name =="Lid" then
                DrawChest(child)
            end
        end)
        
        sections.game_visuals_trinket:Slider({Name = "Chest Range", Min = 1, Max = 10000})
        sections.game_visuals_trinket:Toggle({Name = "Chest Esp"})
    end


    
    do --Area esp
        function DrawArena(Area)
            --creat the name esp
            local DropText = Drawing.new("Text")
            DropText.Visible = false
            DropText.Center = true
            DropText.Outline = true
            DropText.Font = 1
            DropText.Size = 16
            DropText.OutlineColor = Color3.fromRGB(0, 0, 0);
            DropText.Color = Color3.fromRGB(255,0,255);
        
            local DropLine = Drawing.new("Line")
            DropLine.Visible = false
            DropLine.Thickness = 1
            DropLine.Transparency = 0.5
            --update the position of the text
            local function UPDATER()
                local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if Area then
                --get drop on screen with 3d position
                local dropvector, onscreen = camera:WorldToViewportPoint(Area.Position+Vector3.new(0,.45,0))
                local dist = (character:WaitForChild("HumanoidRootPart").Position - Area.Position).Magnitude
                if library.flags["Area Esp"] then
                    if onscreen then
                            DropLine.Color = DropText.Color
                            DropText.Position = Vector2.new(dropvector.X, dropvector.Y)
                            DropText.Text = "["..Area.Parent.Name.."]".."\n"..math.round(dist)
                            DropText.Visible = true
                        else
                        DropText.Visible = false
                        DropLine.Visible = false
                    end
                        --//toggle esp//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
                    --//No Player Found Or Dead//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
            end)
            end
            --call the function
            coroutine.wrap(UPDATER)()
        end
    
        for i ,v in pairs(game:GetService("ReplicatedStorage").MarkerWorkspace.AreaMarkers:GetDescendants())do
            if v:IsA("Part") then
                DrawArena(v)
            end
        end


        game:GetService("ReplicatedStorage").MarkerWorkspace.AreaMarkers.DescendantAdded:Connect(function(child)
            if child:IsA("Part") then
                DrawArena(child)
            end
        end)
    
        sections.game_visuals_map:Toggle({Name = "Area Esp"})

    end


    do --Area esp
        function DrawBag(bag)
            --creat the name esp
            local DropText = Drawing.new("Text")
            DropText.Visible = false
            DropText.Center = true
            DropText.Outline = true
            DropText.Font = 1
            DropText.Size = 16
            DropText.OutlineColor = Color3.fromRGB(0, 0, 0);
            DropText.Color = Color3.fromRGB(0, 255, 255);
        
            local DropLine = Drawing.new("Line")
            DropLine.Visible = false
            DropLine.Thickness = 1
            DropLine.Transparency = 0.5
            --update the position of the text
            local function UPDATER()
                local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if bag and bag.Transparency == 0 and  game:GetService("Workspace").Thrown:FindFirstChild(bag) then
                --get drop on screen with 3d position
                local dropvector, onscreen = camera:WorldToViewportPoint(bag.Position+Vector3.new(0,.45,0))
                local dist = (character:WaitForChild("HumanoidRootPart").Position - bag.Position).Magnitude
                if library.flags["Bag Esp"] then
                    if onscreen then
                        if dist<= library.flags["Bag Range"] then
                            DropLine.Color = DropText.Color
                            DropText.Position = Vector2.new(dropvector.X, dropvector.Y)
                            DropText.Text = "[Bag]".."\n"..math.round(dist)
                            DropText.Visible = true
                            else
                                DropText.Visible = false
                        end
                    else
                        DropText.Visible = false
                        DropLine.Visible = false
                    end
                        --//toggle esp//--
                else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
                    --//No Player Found Or Dead//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
            end)
            end
            --call the function
            coroutine.wrap(UPDATER)()
        end
    
        for i ,v in pairs(game:GetService("Workspace").Thrown:GetChildren())do
            if v.Name == "BagDrop" then
                DrawBag(v)
            end
        end


        game:GetService("Workspace").Thrown.ChildAdded:Connect(function(child)
            if child.Name =="BagDrop" then
                DrawBag(child)
            end
        end)
    
        sections.game_visuals_drop:Toggle({Name = "Bag Esp"})
        sections.game_visuals_drop:Slider({Name = "Bag Range", Min = 1, Max = 10000})
    end


    do --Players esp
        function DrawPlayer(plr)
            --creat the name esp
            local DropText = Drawing.new("Text")
            DropText.Visible = false
            DropText.Center = true
            DropText.Outline = true
            DropText.Font = 1
            DropText.Size = 16
            DropText.OutlineColor = Color3.fromRGB(0, 0, 0);
            DropText.Color = Color3.fromRGB(0, 255, 0);
        
            local DropLine = Drawing.new("Line")
            DropLine.Visible = false
            DropLine.Thickness = 1
            DropLine.Transparency = 0.5
            --update the position of the text
            local function UPDATER()
                local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if plr and plr:FindFirstChild("HumanoidRootPart")  and plr:FindFirstChild("HumanoidRootPart").CFrame and plr:FindFirstChild("HumanoidRootPart").Position and game.Players:FindFirstChild(plr.Name) then
                --get drop on screen with 3d position
                local dropvector, onscreen = camera:WorldToViewportPoint(plr:FindFirstChild("HumanoidRootPart").Position+Vector3.new(0,3.45,0))
                local dist = (character:WaitForChild("HumanoidRootPart").Position - plr:FindFirstChild("HumanoidRootPart").Position).Magnitude

                if library.flags["Player Esp"] and plr and plr:FindFirstChild("HumanoidRootPart") and plr.Name ~=game.Players.LocalPlayer.Name then
                    if onscreen then
                        if dist<= library.flags["Player Range"] then
                            DropLine.Color = DropText.Color
                            DropText.Position = Vector2.new(dropvector.X, dropvector.Y)
                            DropText.Text = plr.Name.."\n".."["..math.round(plr.Humanoid.Health).." / "..math.round(plr.Humanoid.MaxHealth).."]".."\n"..math.round(dist)
                            DropText.Visible = true
                        else
                            DropText.Visible = false
                        end
                    else
                        DropText.Visible = false
                        DropLine.Visible = false
                    end
                        --//toggle esp//--
                else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
                    --//No Player Found Or Dead//--
                    else
                    DropText.Visible = false
                    DropLine.Visible = false
                end
            end)
            end
            --call the function
            coroutine.wrap(UPDATER)()
        end
    
        for i ,v in pairs(game:GetService("Workspace").Live:GetChildren())do
            if v:FindFirstChild("Water") and v:FindFirstChild("HumanoidRootPart") then
                DrawPlayer(v)
            end
        end


        game:GetService("Workspace").Live.DescendantAdded:Connect(function(child)
            if child.Name == "HumanoidRootPart" and child.Parent:FindFirstChild("Water") then
                DrawPlayer(child.Parent)
            end
        end)
    
        sections.player_visuals_visual:Toggle({Name = "Player Esp"})
    
        sections.player_visuals_visual:Slider({Name = "Player Range", Min = 1, Max = 10000})
    end


    do--Fullbright
        
        task_spawn(function()
            while task_wait() do
                if library.flags["Full bright and no fog"] then
                    game.Lighting.Ambient = color3_fromrgb(255,255,255)
                    game.Lighting.Brightness = 3
                end
            end
        end)

        sections.player_visuals_visual:Toggle({Name = "Full bright and no fog"})
    end


    do--No fog
        
        game:GetService("Lighting"):GetPropertyChangedSignal("Ambient"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").Ambient = color3_fromrgb(255, 255, 255)
            end
        end)
        game:GetService("Lighting").GenericBlur:GetPropertyChangedSignal("Enabled"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").GenericBlur.Enabled = false
            end
        end)
        game:GetService("Lighting").DistortionBlur:GetPropertyChangedSignal("Enabled"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").DistortionBlur.Enabled = false
            end
        end)
        game:GetService("Lighting").UnderwaterBlur:GetPropertyChangedSignal("Enabled"):Connect(function()
            if library.flags["No Blur"]then
                game:GetService("Lighting").UnderwaterBlur.Enabled = false
            end
        end)
        game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").FogEnd = 1000000
            end
        end)

        game:GetService("Lighting"):GetPropertyChangedSignal("FogStart"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").FogStart = 1000000
            end
        end)

        game:GetService("Lighting").Atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
            if library.flags["No Blur"] then
                game:GetService("Lighting").Atmosphere.Density = 0
            end
        end)

        sections.game_visuals_local:Toggle({Name = "No Blur"})
        sections.game_visuals_local:Toggle({Name = "Full Bright"})
    end



    do--player too close Alert

        function DetectPlayer(plr)
            local function UPDATER()
                local c
                c = game:GetService("RunService").RenderStepped:Connect(function()
                    if plr and plr:FindFirstChild("HumanoidRootPart")  and plr:FindFirstChild("HumanoidRootPart").CFrame and plr:FindFirstChild("HumanoidRootPart").Position and game.Players:FindFirstChild(plr.Name) then
                        local dist = (player.Character:WaitForChild("HumanoidRootPart").Position - plr:WaitForChild("HumanoidRootPart").Position).Magnitude
                        if library.flags["Player Alert"] and plr and plr:FindFirstChild("HumanoidRootPart") and plr.Name ~=game.Players.LocalPlayer.Name then
                            if dist<=library.flags["Player Alert Range"] then
                                --game.StarterGui:SetCore("SendNotification", {Title = "PLAYER NEARBY";Text = plr.Name;Duration = 3;})
                                print("player nearby : "..plr.Name)
                                wait(9e9)
                            end
                        end
                    end
                end)
            end
            coroutine.wrap(UPDATER)()
        end


        for i ,v in pairs(game:GetService("Workspace").Live:GetChildren())do
            if v:FindFirstChild("Water") and v:FindFirstChild("HumanoidRootPart") then
                DetectPlayer(v)
            end
        end

        game:GetService("Workspace").Live.DescendantAdded:Connect(function(child)
            if child.Name == "HumanoidRootPart" and child.Parent:FindFirstChild("Water") then
                DetectPlayer(child.Parent)
            end
        end)
        sections.player_visuals_visual:Slider({Name = "Player Alert Range", Min = 1, Max = 10000})
        sections.player_visuals_visual:Toggle({Name = "Player Alert"})
    end


    do--emotes
        for i,v in pairs(game:GetService("ReplicatedStorage").Assets.Anims.Gestures:GetChildren())do
            sections.player_visuals_emotes:Button({Name = v.Name, Callback = function()

                --stop animation
                for i,v in pairs(game:GetService("ReplicatedStorage").Assets.Anims.Gestures:GetChildren())do
                    local anim = Instance.new("Animation")
                    anim.AnimationId = v.AnimationId
                    local track = player.Character.Humanoid:LoadAnimation(anim) -- eat
                    track.Looped = false
                    track.Priority = "Action"
                    track:AdjustSpeed(1)
                    track:Stop()
                end

                --play animation
                local anim = Instance.new("Animation")
                anim.AnimationId = v.AnimationId
                local track = player.Character.Humanoid:LoadAnimation(anim) -- eat
                track.Looped = false
                track.Priority = "Action"
                track:AdjustSpeed(1)
                track:Play()
            end})
        end
    end

    do--Auto Parry Players
        function Parry()
            for i, thing in pairs(game:GetService("Workspace").Live:GetChildren()) do
                if thing and thing.Name ~= game.Players.LocalPlayer.Name  and thing:FindFirstChild("HumanoidRootPart") and thing:FindFirstChild("Humanoid")  and (game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position - thing.HumanoidRootPart.Position).Magnitude <= library.flags["Player Auto Parry Range"] then
                    --start player auto parry
                    if thing.RightHand:FindFirstChild("HandWeapon") then
                        local swingspeed = thing.RightHand.HandWeapon.Stats.SwingSpeed.Value
                        local trail = thing.RightHand.HandWeapon:FindFirstChild("WeaponTrail")
                        --check if attacking then parry
                        if trail.Enabled == true then
                            task_wait(swingspeed/4.5)
                            print("parry now")
                            keypress(0x46)
                            keyrelease(0x46)
                            print("release now")
                            repeat task_wait() until not trail.Enabled or thing == nil
                        end
                    end
                end
            end
        end

        --toggle function
        task_spawn(function()
            while task_wait() do
                if library.flags["Player Auto Parry"] then
                    Parry()
                end
            end
        end)

        sections.combat_settings:Slider({Name = "Player Auto Parry Range", Min = 1, Max = 100})
        sections.combat_settings:Toggle({Name = "Player Auto Parry"})
    end

    do--Auto Parry Mobs
        function ParryMobs()
            for i, thing in pairs(game:GetService("Workspace").Live:GetChildren()) do
                if thing and thing:FindFirstChild("HumanoidRootPart") and (game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position - thing.HumanoidRootPart.Position).Magnitude <= library.flags["Mobs Auto Parry Range"] and thing:FindFirstChild("Humanoid") then
            
                    --start Mobs auto parry
                    if thing:FindFirstChild("MegalodauntController") and thing.Humanoid:GetPlayingAnimationTracks()[3] then
                        local trackSharkoAttack = thing.Humanoid:GetPlayingAnimationTracks()[3]
        
                        if trackSharkoAttack.Animation.AnimationId  == "rbxassetid://5121896072" then -- sharko kick foot
                            keypress(0x51)
                            keyrelease(0x51)
                            GetKey("Dodge", key):FireServer("roll",nil,nil,false) 
                        elseif trackSharkoAttack.Animation.AnimationId  == "rbxassetid://5641344204" then -- spikes
                            wait(.1)
                            keypress(0x46)
                            wait(.2)
                            keyrelease(0x46)
                        end
                 

                    end

                    --end for mobs auto parry

                end
            end
        end

        task_spawn(function()
            while wait() do
                if library.flags["Mobs Auto Parry"] then
                    ParryMobs()
                end
            end
        end)

        sections.combat_settings:Slider({Name = "Mobs Auto Parry Range", Min = 1, Max = 200})
        sections.combat_settings:Toggle({Name = "Mobs Auto Parry"})
    end


    do--no fall damage
        local old
        old = hook(Instance.new("RemoteEvent").FireServer, function(self,...)
            local args = {...}
            
            if library.flags["No Fall"] and self.Parent == game:GetService("ReplicatedStorage").Requests then
                if type(arg[1]) == "number" and arg[1] > 10 and type(arg[2]) == "boolean" and arg[2] == false and #args == 2 then
                    wait(9e9)
                    return nil
                end
            end

            return old(self,...)
        end)


        sections.game_visuals_local:Toggle({Name = "No Fall"})
    end


    do -- chat logs
        local chat_logger = instance_new("ScreenGui")

        protect_gui(chat_logger)

        local rounded_frame = instance_new("Frame")

        rounded_frame.Parent = chat_logger
        rounded_frame.BackgroundColor3 = color3_fromrgb(22, 22, 22)
        rounded_frame.Position = udim2_new(0.112, 0, 0.375, 0)
        rounded_frame.Size = udim2_new(0, 350, 0, 200)
        rounded_frame.Visible = false
        rounded_frame.Draggable = true

        local scrolling_frame = instance_new("ScrollingFrame")

        scrolling_frame.Parent = rounded_frame
        scrolling_frame.Active = true
        scrolling_frame.AnchorPoint = vector2_new(0.5, 0)
        scrolling_frame.BackgroundColor3 = color3_fromrgb(255, 255, 255)
        scrolling_frame.BackgroundTransparency = 1
        scrolling_frame.BorderSizePixel = 0
        scrolling_frame.Position = udim2_new(0.515, 0, 0.085, 10)
        scrolling_frame.Size = udim2_new(0, 325, 0, 165)
        scrolling_frame.CanvasSize = udim2_new(0, 0, 0, 0)
        scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrolling_frame.ScrollBarThickness = 0

        local chat_list_layout = instance_new("UIListLayout")

        chat_list_layout.Parent = scrolling_frame
        chat_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        chat_list_layout.SortOrder = Enum.SortOrder.LayoutOrder

        local chat_label = instance_new("TextLabel")
        
        chat_label.Parent = rounded_frame
        chat_label.AnchorPoint = vector2_new(0.5, 0)
        chat_label.BackgroundColor3 = color3_fromrgb(255, 255, 255)
        chat_label.BackgroundTransparency = 1
        chat_label.Position = udim2_new(0.5, 0, 0, 0)
        chat_label.Size = udim2_new(0, 0, 0, 25)
        chat_label.Font = Enum.Font.SourceSans
        chat_label.Text = "Chatlogger"
        chat_label.TextColor3 = color3_fromrgb(255, 255, 255)
        chat_label.TextSize = 20
        chat_label.TextYAlignment = Enum.TextYAlignment.Bottom

        local current_drag
        local drag_input
        local drag_start
        local start_pos
        
        rounded_frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                drag_start = input.Position
                start_pos = rounded_frame.Position
                current_drag = true
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        current_drag = false
                    end
                end)
            end
        end)
        
        rounded_frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                drag_input = input
            end
        end)
        
        services.UserInputService.InputChanged:Connect(function(input)
            if input == drag_input and current_drag then
                local Delta = input.Position - drag_start
                rounded_frame.Position = udim2_new(start_pos.X.Scale, start_pos.X.Offset + Delta.X, start_pos.Y.Scale, start_pos.Y.Offset + Delta.Y)
            end
        end)

        local function log_chat(target_player, text)
            if library.flags["Streamer Mode"] and target_player == player then
                return
            end

            local new_text = instance_new("TextButton")
            new_text.Parent = scrolling_frame
            new_text.BackgroundColor3 = color3_fromrgb(255, 255, 255)
            new_text.BackgroundTransparency = 1
            new_text.Size = udim2_new(1, 0, 0, 25)
            new_text.AutoButtonColor = false
            new_text.Font = Enum.Font.SourceSans
            new_text.TextColor3 = color3_fromrgb(255, 255, 255)
            new_text.Text = ("%s: %s"):format(target_player.Name, text)
            local old_text = ("%s: %s"):format(target_player.Name, text)

            local target_character = target_player.Character
            if target_character then
                if target_player.Backpack:FindFirstChild("Observe") or target_character:FindFirstChild("Observe") then
                    new_text.TextColor3 = color3_fromrgb(90, 149, 200)
                end
                local fake_humanoid = target_character:FindFirstChild("FakeHumanoid", true)
                if fake_humanoid then
                    local rogue_name_part = fake_humanoid.Parent
                    new_text.Text = ("%s: %s"):format(rogue_name_part.Name, text)
                    old_text = ("%s: %s"):format(rogue_name_part.Name, text)
                end
            end
            
            new_text.TextSize = 16
            new_text.TextXAlignment = Enum.TextXAlignment.Left

            new_text.MouseButton1Click:Connect(function()
                if target_player and target_player.Character and target_player.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = target_player.Character.Humanoid
                end
            end)

            new_text.MouseEnter:Connect(function()
                new_text.Text = ("%s: %s"):format(target_player.Name, text)
            end)

            new_text.MouseLeave:Connect(function()
                new_text.Text = old_text
            end)
            
            scrolling_frame.CanvasPosition = vector2_new(0, 10000)
        end

        local players_list = services.Players:GetPlayers()

        for index = 1, #players_list do
            local target_player = players_list[index]
            
            target_player.Chatted:connect(function(message)
                log_chat(target_player, message)
            end)
        end
        
        services.Players.PlayerAdded:Connect(function(target_player)
            target_player.Chatted:connect(function(message)
                log_chat(target_player, message)
            end)
        end)

        sections.local_misc:Toggle({Name = "Chatlogger", Callback = function(state)
            rounded_frame.Visible = state
        end})

        
    end
