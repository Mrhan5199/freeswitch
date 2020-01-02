local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
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
local number = argv[3];
local uuid = argv[2];
--if not in_array(agent,AgentList) then
--	stream:write("-ERR agnet invalid!");
--	return;
--end

if argv[4] ~= nil and argv[4] =="agent" then
	local result = api:execute("uuid_getvar",uuid.." last_bridge_to");
	uuid = result;	
end
if uuid == nil then
	stream:write("-ERR Can'n find uuid!");
end
api:execute("uuid_setvar",uuid.." hangup_after_bridge false");
api:execute("uuid_setvar",uuid.." exec_after_bridge_app");
api:execute("uuid_setvar",uuid.." exec_after_bridge_arg");
local result = api:execute("uuid_transfer",uuid.." "..number.." XML internal_ctx");
stream:write(result);