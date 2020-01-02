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
if argv[1] == nil or argv[2] == nil then
	stream:write("-ERR Args invalid!");
	return;
end

local agent = argv[1];
local status = argv[2];
--if not in_array(agent,AgentList) then
--	stream:write("-ERR agnet invalid!");
--	return;
--end
local result = api:executeString("callcenter_config agent get status "..agent);
if result == "On Break"  and  status == "ONLINE" then
	stream:write("-ERR agent is break!");
	return ;
end
local result = "-ERR ";
if status == "ONLINE" or status =="ACTIVE" then
	result = api:execute("callcenter_config"," agent set status "..agent.." Available");
	result = api:execute("callcenter_config"," agent set state "..agent.." Waiting");
elseif status == "OFFLINE" then
	result = api:execute("callcenter_config"," agent set status "..agent.."  'Logged Out'");
elseif status == "BREAK" then
	result = api:execute("callcenter_config"," agent set status "..agent.."  'On Break'");	
end
stream:write(result);
