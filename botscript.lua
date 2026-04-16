--[[ !! READ BEFORE USING !!
	This script requires an app that can run multiple Roblox windows at once, like 'Roblox Account Manager'
	This is because it's designed to work on multiple bot accounts.
	
	To use this script, first set the OWNER variable below. This tells the script who to listen to for commands.
	Then add the bots' and safe players' names to the OK array. This disables the bots from automatically targeting them.
]]
local OWNER="YOURNAMEHERE"
local OK={
	"bot_123456",
	"bot_676789"
} -- You can add more!
--[[
	Then, inject this script into all of your Roblox windows. An injector like JJSploit does this really well!
	And that's it! You can add as many bot accounts as you want. The rest here is just a list of commands, which are designed to work on all bots at once:
	
	exit: This stops the script entirely
	kill: Off by default. This turns "targeting" on, which forces the bots to always target the player with the lowest health, overriding all other targeting commands.
	target: This turns advanced targeting on, which forces the bots to always target the player with the health closest to theirs. This is best for getting the damage required for ult.
	conflict: On by default. This allows the bots to attack each other if you specifically tell them to.
	peace: Stops bots from attacking each other.
	defend: On by default. Causes the bots to follow you, while enabling "defend" mode, where they attack the last player that attacks you.
	stop: Like defend, but disables "defend" mode, keeping their target instead of changing it if someone attacks you.
	end: Like stop and defend, but doesn't change the mode, and disables targeting mode.
	attack: Causes the bots to attack the nearest player to you.
	attack 'player': Causes the bots to attack the player you specify. This is not case-sensitive, and autocompletes the player's name (you can type 'attack rObLoX' to attack 'robloxnoob' if you wanted to)
	attack dummy: Causes the bots to attack the dummy, rather than a player.
	jump: The exact same as all the attack commands, except the bots teleport to the player before attacking.
	reset: Causes all the bots to die immediately. May not always work if they're being actively attacked.
	explode: Same as reset, but flings the bots upward.
	fling: Causes the bots to constantly fling you.
	fling 'player': Causes the bots to fling the player.
	dance: Causes the bots to do the '/e dance'. You can say 'stop' or 'defend' to stop this.
	go: If "targeting" mode is on, the bots lead you to the player with the lowest health. Otherwise this does nothing.
	go 'player': Causes the bots to lead you to the player you specify.
	spam: Causes the bots to backshot you. Yes.
	spam 'player': Causes the bots to backshot the player.
	up: Causes the bots to push you upwards quickly. Useful for climbing mountains.
	up 'player': Causes the bots to push the player upwards quickly.
	come: Makes it so that the bots follows you closely.
	flee: Makes it so that the bots follow you from far away.
	punch: Makes the bots punch.
	ult: Attempts to trigger the bots' ultimate ability if it's fully charged.
	execute 'move': Causes the bots to use the specified move. You can just type the first few letters of the move.
	execution 'move': The exact same as execute, just an alias.
	orbit: Makes the bots orbit you. This is best paired with a flying script.
	align: Makes the bots form a circle around you, also best paired with a flying script. Note that this uses a special communication method, and you might have to stand still for a few seconds until they find their places.
	check: Prints the ult charge and health of the bots. This also uses a special communication method.
	ok: Makes the bots repeat the next thing you say 4 times within 10 seconds of you saying it. Start your message with 'defend', 'stop', or 'end' to stop this.
	ok 'number': Makes the bots repeat the next thing you say the specified number of times within 10 seconds of you saying it.
	
	Commands aren't case-sensitive, and you can put them in a single chat message separated by commas. For example:
	"come, kill, attack" makes the bots follow you closely, switch to targeting mode, and attack the player with the lowest health
	
	I know it's long, but I mean it's fun so yeah good luck bro
	
	This script was made by "axes (@BHY94)"
]]

function getRoot(name)
	if name and game.Players:FindFirstChild(name) then
		if game.Players:FindFirstChild(name).Character then
			local c=game.Players:FindFirstChild(name).Character
			if c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildWhichIsA("Humanoid") then
				if c.Humanoid.Health>0 then return c.HumanoidRootPart end
			end
		end
	end
end
local vim = game:GetService("VirtualInputManager")
function click(t)
    -- This runs independently in every window you execute it in
    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(t)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    -- this function was made by Gemini because I lowkenuinely never knew about this until like a year after i started the script
end
function hold(key)
    vim:SendKeyEvent(true, Enum.KeyCode[key], false, game) -- Key Down
end
function release(key)
    vim:SendKeyEvent(false, Enum.KeyCode[key], false, game) -- Key Up
end
function tap(key)
    vim:SendKeyEvent(true, Enum.KeyCode[key], false, game) -- Key Down
    task.wait()
    vim:SendKeyEvent(false, Enum.KeyCode[key], false, game) -- Key Up
end
function getDisplayName(name)
    local p=game.Players:FindFirstChild(name)
    if p then return p.DisplayName end
end
local PLAYER=OWNER

local player=game.Players.LocalPlayer
local character=player.Character
local humanoid=character:WaitForChild("Humanoid")
local root=character:WaitForChild("HumanoidRootPart")
function okay(name)
	if name==player.Name or name==OWNER then return false end
	for _,n in ipairs(OK) do
		if n==name then return false end
	end
	return true
end

local blockers={"Prey's Peril","Death Counter"}
local aggressors={"Death Counter","Normal Punch","Shove","Uppercut","Consecutive Punches","Flowing Water","Lethal Whirlwind Stream","Hunter's Grasp","The Final Hunt","Water Stream Cutting Fist","Rock Splitting Fist"}

local target
local bestdistance=0
local defending=true
local attacking=false
local backshotting=false
local backshotin=false
local backshotfling=false
local backshoteveryone=false
local backshotup=false
local backshotorbit=false
local dancing=false
local going=false
local killing=false
local targeting=false
local conflict=true
local exit=false
local rep=false
local repstart=false
local followdist=96
local random=Random.new()
local randy=4
local orbitp=0
local p2rate=0
local aligning=false
local alignList={}
local dealignList={}
local RBXGeneral = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local oroot=getRoot(OWNER)
local ca=game:GetService("TextChatService").MessageReceived:Connect(function(text)
	local sender=nil
	if text.TextSource then sender=text.TextSource.Name end
	if sender==OWNER then
        for _,M in ipairs(string.split(text.Text,",")) do
			local m={}
            for w in string.gmatch(M,"%S+") do table.insert(m,w) end
			
            local good=false
            local gotPlayer=nil
            if #m>1 then
                for _,p in ipairs(game.Players:GetPlayers()) do
                    if p.Name~=player.Name and string.lower(string.sub(p.Name,1,#m[2]))==string.lower(string.sub(m[2],1,#m[2])) then
                        gotPlayer=p.Name
                        break
                    end
                end
            end
            
            if string.lower(m[1])=="exit" then
                exit=true
				good=true
            end
            if player.Name==OWNER then return end
            if string.lower(m[1])=="kill" then
                killing=true
            end
            if string.lower(m[1])=="end" then
                targeting=false
                killing=false
                PLAYER=OWNER
                good=true
            end
            if string.lower(m[1])=="conflict" then
                conflict=true
            end
            if string.lower(m[1])=="peace" then
                conflict=false
            end
            if string.lower(m[1])=="defend" then
                good=true
                PLAYER=OWNER
                defending=true
            end
            if string.lower(m[1])=="stop" then
                good=true
                PLAYER=OWNER
                defending=false
            end
            if string.lower(m[1])=="attack" then
                good=true
                if #m==1 then attacking=true
                elseif #m>1 then
                    if string.lower(m[2])=="dummy" then
                        PLAYER="dummy"
                    elseif getRoot(gotPlayer) then
                        PLAYER=gotPlayer
                    end
                end
            end
            if string.lower(m[1])=="jump" then
                good=true
                if #m==1 then attacking=true
                elseif #m>1 then
                    if string.lower(m[2])=="dummy" then
                        PLAYER="dummy"
                        root.CFrame=workspace.Live:WaitForChild("Weakest Dummy"):WaitForChild("HumanoidRootPart").CFrame
                    elseif getRoot(gotPlayer) then
                        PLAYER=gotPlayer
                        root.CFrame=getRoot(gotPlayer).CFrame
                    end
                    root.AssemblyLinearVelocity=Vector3.zero
                end
            end
            if string.lower(m[1])=="reset" then
                humanoid.Health=0
            end
            if string.lower(m[1])=="explode" then
                root.AssemblyLinearVelocity=Vector3.new(0,400)
                root.AssemblyAngularVelocity=Vector3.new(math.random()-0.5,math.random()-0.5,math.random()-0.5).Unit*100
                humanoid.Health=0
            end
            if string.lower(m[1])=="fling" then
                backshotting=true
                backshotfling=true
                backshotup=false
				backshotorbit=false
                backshoteveryone=false
                if #m==1 then PLAYER=OWNER end
                if gotPlayer then PLAYER=gotPlayer end
                if #m>1 and string.lower(m[2])=="everyone" then backshoteveryone=true end
            end
            if string.lower(m[1])=="dance" then
                local a=Instance.new("Animation")
                a.AnimationId="http://www.roblox.com/asset/?id=182436935"
                humanoid:LoadAnimation(a):Play()
                dancing=true
            end
            if string.lower(m[1])=="go" then
                good=true
                if #m==1 and killing then
                    PLAYER=game.Players:FindFirstChildWhichIsA("Player").Name
                    going=true
                end
                if #m>1 then
                    if string.lower(m[2])=="dummy" then
                        going=true
                        PLAYER="dummy"
                    elseif getRoot(gotPlayer) then
                        going=true
                        PLAYER=gotPlayer
                    end
                end
            end
            if good then
                if backshotting then
                    backshotting=false
                    root.CFrame=oroot.CFrame
                end
                backshotin=false
                dancing=false
				aligning=false
				rep=false
                release("F")
                release("Space")
                if humanoid and humanoid:FindFirstChild("Animator") then
                    for _,a in ipairs(humanoid.Animator:GetPlayingAnimationTracks()) do
                        if a.Animation.AnimationId=="http://www.roblox.com/asset/?id=182436935" then
                            a:Stop()
                            break
                        end
                    end
                end
                root.AssemblyLinearVelocity=Vector3.zero
                root.AssemblyAngularVelocity=Vector3.zero
            end
            if string.lower(m[1])=="spam" then
                backshotting=true
                backshotfling=false
                backshotup=false
				backshotorbit=false
                PLAYER=OWNER
                if gotPlayer then PLAYER=gotPlayer end
            end
            if string.lower(m[1])=="up" then
                backshotting=true
                backshotfling=false
                backshotup=true
				backshotorbit=false
                PLAYER=OWNER
                if gotPlayer then PLAYER=gotPlayer end
            end
            if string.lower(m[1])=="orbit" then
                backshotting=true
                backshotfling=false
                backshotup=false
				backshotorbit=true
                PLAYER=OWNER
                if gotPlayer then PLAYER=gotPlayer end
                orbitp=random:NextNumber(0,2*math.pi)
                p2rate=random:NextNumber(0.1,0.3)
            end
            if string.lower(m[1])=="come" then
                followdist=8
            end
            if string.lower(m[1])=="flee" then
                followdist=96
            end
			if string.lower(m[1])=="ok" then
				rep=true
                repstart=true
				if #m==1 then randy=4
				elseif tonumber(m[2]) and tonumber(m[2])>0 and tonumber(m[2])%1==0 then randy=tonumber(m[2]) end
			end
			if string.lower(m[1])=="align" then
				aligning=true
				alignList={}
				dealignList={}
				RBXGeneral:SendAsync("bot______________!__________")
				local waiting=true
				print("Initiating communication...")
                task.wait(2)
				print("Got "..#alignList.." bots!")
				
				local index=math.random(1,#alignList)
				local great=false
				task.spawn(function()
					while aligning do
						local evaluation=2*math.pi*index/#alignList
						local pos=followdist*oroot.CFrame.UpVector*math.cos(evaluation)-followdist*oroot.CFrame.RightVector*math.sin(evaluation)+oroot.Position
						root.CFrame=CFrame.new(
							pos,
							pos+oroot.CFrame.LookVector
						)
						root.AssemblyLinearVelocity=Vector3.zero
						task.wait()
					end
					root.CFrame=oroot.CFrame
					root.AssemblyLinearVelocity=Vector3.zero
				end)
				
				while not great and aligning do
					task.wait(random:NextNumber(2,4))
					
					great=true
					for _,r in ipairs(alignList) do
						if (r.Position-root.Position).Magnitude<4 and r~=root then
							index=math.random(1,#alignList)
							great=false
							break
						end
					end
					if not great then
						print("Failed, trying again.")
					end
				end
				print("Aligned!")
			end
			if string.lower(m[1])=="execute" or string.lower(m[1])=="execution" then
				local str=""
				for i,msg in ipairs(m) do
					if i>1 then
						str=str..msg
						if i<#m then str=str.." " end
					end
				end
				for _,tool in ipairs(player.Backpack:GetChildren()) do
					if tool:IsA("Tool") and string.lower(string.sub(tool.Name,1,#str))==string.lower(str) then
                        release("F")
                        task.wait()
						humanoid:EquipTool(tool)
                        task.wait()
                        hold("F")
						break
					end
				end
			end
            if string.lower(m[1])=="target" then
                killing=true
                targeting=true
            end
            if string.lower(m[1])=="ult" then
                tap("G")
            end
            if string.lower(m[1])=="punch" then
                click()
            end
            if string.lower(m[1])=="check" then
                local cframe=root.CFrame
                local per=player.PlayerGui.Bar.MagicHealth.Health.Bar.Size.X.Scale
                local awesome=false
                while not awesome do
                    root.CFrame=CFrame.new(10*humanoid.Health+1000,1000*per+1000,5000)
                    root.AssemblyLinearVelocity=Vector3.zero
                    for _,p in ipairs(game.Players:GetPlayers()) do
                        local r=getRoot(p.Name)
                        if p.Name==OWNER and r and math.round(r.Position.X/1000)==3 and math.round(r.Position.Z/1000)==5 and math.round(r.Position.Y/100)==21 then
                            awesome=true
                            break
                        end
                    end
                    task.wait()
                end
                for i=1,10 do
                    root.CFrame=cframe
                    root.AssemblyLinearVelocity=Vector3.zero
                    task.wait(0.05)
                end
            end
            task.wait(0.5)
        end
        if rep then
            if repstart then
                repstart=false
            else
                if RBXGeneral then
					for i=1,randy do
						task.wait(random:NextNumber(0,10/randy))
						RBXGeneral:SendAsync(text.Text)
					end
                end
            end
        end
	elseif text.Text=="bot______________!__________" then
		local r=getRoot(sender)
		if r then table.insert(alignList,r) end
	elseif text.Text=="stay" then
		local r=getRoot(sender)
		if r then table.insert(dealignList,r) end
	end
end)

task.spawn(function()
    while true do
        task.wait()
        if humanoid.Health==0 then
            player.CharacterAdded:Wait()
            character=player.Character
            humanoid=character:WaitForChild("Humanoid")
            root=character:WaitForChild("HumanoidRootPart")
            print("Got a new character")
        end
    end
end)

task.spawn(function()
    while not exit do
        task.wait(900)
        if not exit then tap("Space") end -- anti afk
    end
end)

if player.Name==OWNER then 
    while not exit do
        local awesome=false
        for _,p in ipairs(game.Players:GetPlayers()) do
            local r=getRoot(p.Name)
            if p.Name~=player.Name and r and math.round(r.Position.Z/1000)==5 then
                awesome=true
                break
            end
        end
        if awesome then
            task.wait(player:GetNetworkPing()*4)
            for _,p in ipairs(game.Players:GetPlayers()) do
                local r=getRoot(p.Name)
                if p.Name~=player.Name and r and math.round(r.Position.Z/1000)==5 then
                    RBXGeneral:DisplaySystemMessage(p.Name..": Ult="..math.round((r.Position.Y-1000)/10).."%, Health="..math.round((r.Position.X-1000)/10).."%")
                    task.wait(0.1)
                end
            end
            local cframe=root.CFrame
            while awesome do
                root.CFrame=CFrame.new(3000,2100,5000)
                root.AssemblyLinearVelocity=Vector3.zero
                task.wait()
                awesome=false
                for _,p in ipairs(game.Players:GetPlayers()) do
                    local r=getRoot(p.Name)
                    if p.Name~=player.Name and r and math.round(r.Position.Z/1000)==5 then
                        awesome=true
                        break
                    end
                end
            end
            
                for i=1,10 do
                    root.CFrame=cframe
                    root.AssemblyLinearVelocity=Vector3.zero
                    task.wait(0.05)
                end
        end
        task.wait()
    end
end

local highlight=Instance.new("Highlight")
highlight.Parent=character
highlight.FillTransparency=1
highlight.OutlineTransparency=0
highlight.Enabled=true

function addCFrame(part)
    root.CFrame+=part.AssemblyLinearVelocity/2
    --root.AssemblyLinearVelocity=part.AssemblyLinearVelocity
end
local prehealth=100
if oroot then prehealth=oroot.Parent.Humanoid.Health end
while not exit do
    if killing then
        local besthel=math.huge
        local bestman=nil
        if not targeting then
            for _,p in ipairs(game.Players:GetPlayers()) do
                local r=getRoot(p.Name)
                if r and p.Name~=player.Name and (okay(p.Name) or conflict) and p.Name~=OWNER and r.Parent.Humanoid.Health<besthel then
                    besthel=r.Parent.Humanoid.Health
                    bestman=p.Name
                end
            end
        else
            for _,p in ipairs(game.Players:GetPlayers()) do
                local r=getRoot(p.Name)
                if r and p.Name~=player.Name and (okay(p.Name) or conflict) and p.Name~=OWNER and math.abs(r.Parent.Humanoid.Health+20-humanoid.Health)<besthel then
                    besthel=math.abs(r.Parent.Humanoid.Health+20-humanoid.Health)
                    bestman=p.Name
                end
            end
        end
        PLAYER=bestman
    end
    if backshotting then
        local r=getRoot(PLAYER)
        if r then
            if backshotfling then
                if backshoteveryone then
                    while backshotting and backshotfling do
                        local bestdih=math.huge
                        local bestmah=r
                        for _,p in ipairs(game.Players:GetPlayers()) do
                            local ro=getRoot(p.Name)
                            if defend then
                                if ro and (oroot.Position-ro.Position).Magnitude<bestdih and (okay(p.Name) or conflict) and p.Name~=OWNER then
                                    bestmah=ro
                                    bestdih=(oroot.Position-ro.Position).Magnitude
                                end
                            else
                                if ro and r.AssemblyLinearVelocity.Magnitude<bestdih and (okay(p.Name) or conflict) and p.Name~=OWNER then
                                    bestmah=ro
                                    bestdih=ro.AssemblyLinearVelocity.Magnitude
                                end
                            end
                        end
                        if bestmah then
                            root.CFrame=bestmah.CFrame
                            root.AssemblyAngularVelocity=Vector3.new(math.random()-0.5,math.random()-0.5,math.random()-0.5).Unit*1000
                            root.CFrame+=bestmah.AssemblyLinearVelocity/2
                            root.AssemblyLinearVelocity=bestmah.AssemblyLinearVelocity
                        end
                        task.wait()
                    end
                else
                    while backshotting and backshotfling and r do
                        root.CFrame=r.CFrame
                        root.AssemblyAngularVelocity=Vector3.new(math.random()-0.5,math.random()-0.5,math.random()-0.5).Unit*1000
                        addCFrame(r)
                        root.AssemblyLinearVelocity=r.AssemblyLinearVelocity
                        task.wait()
                    end
                end
            elseif backshotup then
                while backshotting and backshotup and r--[[ and oroot.AssemblyLinearVelocity.Magnitude<50]] do
                    root.CFrame=CFrame.new(
                        Vector3.new(
                            r.Position.X,
                            r.Position.Y-2,
                            r.Position.Z
                        )+r.CFrame.LookVector/2,
                        r.Position+r.CFrame.LookVector/2
                    )
                    root.CFrame+=Vector3.new(r.AssemblyLinearVelocity.X/2,0,r.AssemblyLinearVelocity.Z/2)
                    root.AssemblyLinearVelocity=Vector3.new(0,100,0)
                    task.wait()
                end
                --[[backshotting=false
                backshotup=false]]
            elseif backshotorbit then
				local p2=0
				local d
				while backshotting and backshotorbit and r do
					if followdist==8 then d=8
					else d=24 end
					root.CFrame=CFrame.new(
						Vector3.new(
							d*math.cos(orbitp),
							d*(math.cos(orbitp)*math.cos(p2)+math.sin(orbitp)*math.sin(p2)),
							d*math.sin(orbitp)
						)+r.Position,
						r.Position
					)
					
					orbitp+=0.5
					p2+=p2rate
					root.AssemblyLinearVelocity=Vector3.zero
					task.wait()
				end
			else
                if backshotin then
                    root.CFrame=r.CFrame-r.CFrame.LookVector*4
                    backshotin=false
                else
                    root.CFrame=r.CFrame
                    backshotin=true
                end
                root.AssemblyLinearVelocity=r.AssemblyLinearVelocity
                addCFrame(r)
            end
        end
        
        task.wait(0.1)
        continue
    end
	if going and PLAYER~=player.Name then
        local r=nil
		if PLAYER=="dummy" then
            r=workspace.Live:FindFirstChild("Weakest Dummy")
            if r then r=r:FindFirstChild("HumanoidRootPart") end
		else r=getRoot(PLAYER) end
		if not r then
			going=false
            PLAYER=OWNER
			continue
		end
		if (oroot.Position-r.Position).Magnitude<40 then
			going=false
            PLAYER=OWNER
			continue
		end
		
		humanoid.WalkSpeed=32+(40*(r.Position-oroot.Position).Unit+oroot.Position-root.Position).Magnitude
		humanoid:MoveTo(40*(r.Position-oroot.Position).Unit+oroot.Position)
		
		task.wait(0.1)
		continue
	end

	oroot=getRoot(OWNER)
	if oroot and (defending and oroot.Parent.Humanoid.Health<prehealth) or attacking then
		attacking=false
		local favdist=math.huge
		local favman=nil
		for _,tar in ipairs(game.Players:GetPlayers()) do
			if okay(tar.Name) then
				local r=getRoot(tar.Name)
				if r and (r.Position-oroot.Position).Magnitude<favdist then
					favdist=(r.Position-oroot.Position).Magnitude
					favman=tar.Name
				end
			end
		end
		if favman then PLAYER=favman end
	end
	if PLAYER==OWNER or not PLAYER then
		if oroot then
            humanoid.WalkSpeed=16+(followdist*(root.Position-oroot.Position).Unit+oroot.Position-root.Position).Magnitude
			humanoid:MoveTo(followdist*(root.Position-oroot.Position).Unit+oroot.Position)
			if oroot.Parent.Humanoid.Health<prehealth or attacking then
				attacking=false
				local favdist=math.huge
				local favman=nil
				for _,tar in ipairs(game.Players:GetPlayers()) do
					if okay(tar.Name) then
						local r=getRoot(tar.Name)
						if r and (r.Position-oroot.Position).Magnitude<favdist then
							favdist=(r.Position-oroot.Position).Magnitude
							favman=tar.Name
						end
					end
				end
				if favman then PLAYER=favman end
			end
		end
	else
		local bestdist=math.huge
		local distance=math.huge
		local tear=root
		target=getRoot(PLAYER)
        if PLAYER=="dummy" then target=workspace.Live:WaitForChild("Weakest Dummy"):WaitForChild("HumanoidRootPart") end
		if not target then
            target=root
            PLAYER=OWNER
		else
			bestdistance=(target.Position-root.Position).Magnitude
		end
		--[[for _,tar in ipairs(game.Players:GetPlayers()) do
			if tar.Character and tar.Name~=player.Name and tar.Name~="topologystupid" and tar.Name~="topologysmart" and tar.Name~="BHY94alt" and tar.Name~="BHY94alt3" and tar.Name~="BHY94" then
				car=tar.character
				if car:FindFirstChildWhichIsA("Humanoid") and car:FindFirstChild("HumanoidRootPart") then
					if car.Humanoid.Health>0 then
						if car.HumanoidRootPart.AssemblyLinearVelocity.Magnitude>12 and (car.HumanoidRootPart.Position-root.Position).Magnitude<6 then
							--print("Saving")
							highlight.OutlineColor=Color3.new(0,0,255)
							highlight.Adornee=car
							for _,i in ipairs(blockers) do
								if player.Backpack:FindFirstChild(i) then
									humanoid:EquipTool(player.Backpack:FindFirstChild(i))
									task.wait()
								end
							end
							target=root
							break
						else
							if car.Humanoid.Health<bestdist and car.Humanoid.Health>0 then
								bestdistance=(car.HumanoidRootPart.Position-root.Position).Magnitude
								bestdist=car.Humanoid.Health
								target=car.HumanoidRootPart
							end
							if (car.HumanoidRootPart.Position-root.Position).Magnitude<distance then
								distance=(car.HumanoidRootPart.Position-root.Position).Magnitude
								tear=car.HumanoidRootPart
							end
						end
					end
				end
			end
		end]]
	   
		if target~=root then
			if target.Name=="Trashcan" then
				humanoid.WalkSpeed=32+trashbestdist
				humanoid:MoveTo((root.Position-target.Position).Unit*2+target.Position)
			else
                    hold("F")
				--if humanoid.Health>=target.Parent.Humanoid.Health and humanoid.Health>20 then
					highlight.Adornee=target.Parent
					highlight.OutlineColor=Color3.new(0,255,255)
					humanoid.WalkSpeed=16+bestdistance/2
					humanoid:MoveTo(target.Position)
					if (target.Position-root.Position).Magnitude<8 and target.Parent.Humanoid.Health>0 then
                        release("F")
						highlight.OutlineColor=Color3.new(0,255,0)
                        local punching=true
                        task.delay(2,function()
                            punching=false
                        end)
                        task.delay(1,function()
                            if punching then hold("Space") end
                        end)
						while (target.Position-root.Position).Magnitude<8 and target.Parent.Humanoid.Health>0 and punching do
                            click()
                            task.wait()
                        end
                        punching=false
                        release("Space")
                        if target.Parent.Humanoid.Health>0 then
                            for _,i in ipairs(aggressors) do
                                if player.Backpack:FindFirstChild(i) then
                                    humanoid:EquipTool(player.Backpack:FindFirstChild(i))
                                    task.wait()
                                end
                            end
                        end
					elseif (target.Position-root.Position).Magnitude<32 and (target.Position-root.Position).Magnitude>24 and target.Parent.Humanoid.Health>0 then
                        release("F")
                        tap("Q")
                    end
				--[[else
					highlight.Adornee=character
					highlight.OutlineColor=Color3.new(255,0,0)
					humanoid.WalkSpeed=64
					humanoid:MoveTo(2*root.Position-tear.Position)
				end]]
			end
		else
			-- make it so that they follow the player
		end
	end
    humanoid:UnequipTools()
	if oroot then prehealth=oroot.Parent.Humanoid.Health end
    task.wait(0.1)
end
highlight:Destroy()
ca:Disconnect()
