--// Config
local id = 34982427 --// Target GroupId
local banreason = [[Ran a Remote Code Execution Exploit Script. This is not a false ban. 
To appeal join the Community Server and message adudu21
Moderator: @adudu21]] --// Text is filtered
local privatebanreason = "User fell victim to a RCE exploit script thereforce causing them to join a exploiter roblox group, Turtle Hub (V3) made by @Lonegwadiator. - @adudu21" --// Text is unfiltered
--// Services
local plrs = game:GetService("Players")--// Used for BanAsync
local hs = game:GetService("HttpService")--// Used for fetching group members
--// Vars
local url = `https://groups.roproxy.com/v1/groups/{id}/users?sortOrder=Asc&limit=100` --// If roproxy does not work, use another proxy or find a fix.
local urs = {} --// Users in the group
local s = os.clock()--// Debug time
local c = "" --// HTTP Cursor
--// Fetch group members
local function getusers(tarurl)--// Target URL
   local s,r,t,ur=nil,nil,5,url
   if tarurl and tarurl~="" then ur=`{url}&cursor={tarurl}`end
   repeat
      s,r=pcall(function()return hs:GetAsync(ur,true)end)
      if not s then
         if string.find(r,"exceeded") then warn("⚠️RBX RATELIMIT. Waiting 60sec...")task.wait(60)else t=-1 task.wait(1)end
      end
   until s or t==0
   if s then return hs:JSONDecode(r) else warn(`❌Failure: {r}`)return nil end end
--// Fetch group members
print("⏳Fetching group members...")
repeat
   su,er=pcall(function()
      local data = getusers(c)
      for _, u in ipairs(data.data) do
         pcall(function()table.insert(urs,`roblox.com/users/{tostring(u.user.userId)}`)end)
      end
      c=data.nextPageCursor
      print(`⏳On group cursor: {c}`)
   end)
   if not su then warn(`❌Failed adding users onto list: {er}`) end
until not c
--// adudu21's Ban-Wave Developer-Console Script
print("⏳Preparing ban-wave...")
--// Vars
local list = table.concat(urs,",")--// Example:roblox.com/users/1,roblox.com/users/12,roblox.com/users/123
local uids = {}--// Banlist (data extracted from list)
--// Convert list into userids
for u in string.gmatch(list,"roblox.com/users/(%d+)") do table.insert(uids,tonumber(u))end
--// Total userids
local tuids = #uids
--// Roblox's BanAsync limit is 50
print("⏳ Started!")
for n=1,tuids,50 do
   --// Batch of 50
   local batch = {}
   for d=n,math.min(n+50-1,tuids) do table.insert(batch,uids[d])end
   --// Handle errors
   local s,r,t = nil,nil,3
   repeat
      s,r = pcall(function()
         return plrs:BanAsync({UserIds=batch,Duration=-1,DisplayReason=banreason,PrivateReason=privatebanreason,ExcludeAltAccounts=false,ApplyToUniverse=true})  
      end)
      if not s then
         if string.find(r,"NOT_FOUND") then --// Avoid errors from terminated users
            s="t"
         else t-=1 task.wait(0.5)
         end
      end
   until s or t==0
   if s then
      if s=="t" then print(`🔨⚠️User is terminated. Banned: {table.concat(batch, ", ")}`) else print(`🔨Banned: {table.concat(batch, ", ")}`) end
   else warn(`❌Failure: {r}`)
   end
end
print(`✅Finished! Took {os.clock()-s} seconds!`)
