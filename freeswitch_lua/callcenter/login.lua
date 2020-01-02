local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
--	stream:write("-ERR system not register\n");
--	return;
--end
--loadstring(cf)();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

--if os.difftime(os.time(ValidDate),os.time()) <0 then
--	stream:write("-ERR system expire!");
--	return;
--end	


local api = freeswitch.API();
if argv[1] == nil or argv[2] == nil or argv[3] == nil then
	stream:write("-ERR Args invalid!");
	return;
end

local agent = argv[1];
local queue = argv[2];
--if not in_array(agent,AgentList) or not in_array(queue,QueueList) then
--	stream:write("-ERR agnet or queue invalid!");
--	return;
--end
local result = "-ERR";
if argv[3] == "YES" then
	result = api:execute("callcenter_config","tier add "..queue.." "..agent.." 1 1");	
else
	result = api:execute("callcenter_config","tier del "..queue.." "..agent);	
end
stream:write(result);