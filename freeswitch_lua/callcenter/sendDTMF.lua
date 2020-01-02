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
local uuid = argv[2];
local dtmf = argv[3]

--if not in_array(agent,AgentList) then
--	stream:write("-ERR agnet invalid!");
--	return;
--end

local cmd = "uuid_send_dtmf "..uuid.." "..dtmf; 
local result = api:executeString(cmd);
stream:write(result);