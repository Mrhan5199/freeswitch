local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
local cf = DecryptFile(rootdir.."/scripts/autodial/reg.sn");
if cf == nil then
	freeswitch.consoleLog("ERR","\nautodial system not register ,please call qq:674822668!\n");
	return;
end
--lua 5.1
--loadstring(cf)();
--lua 5.2
load(cf)();
if os.difftime(os.time(ValidDate),os.time()) <0 then
	freeswitch.consoleLog("ERR","autodial system expire!\n");
	return;
end	

if argv[1] == nil or argv[2] == nil or argv[3] == nil then
	freeswitch.consoleLog("ERR","autodial params error!\n");
	return ;
end

loadfile(rootdir.."/scripts/autodial/config.lua")();
loadfile(rootdir.."/scripts/callcenter/config.lua")();
local api = freeswitch.API();
local userid = argv[1];
local groupid = argv[2];
local agent  = argv[3];



local result = parser_cmd_res(api:executeString("callcenter_config agent list "..agent));
if result == nil or result[1] == nil or result[1].name == nil or result[1].contact ==nil then
	stream:write("-ERR agent "..agent.." config not find!");
	return;
end
local _,_,sipurl = string.find(result[1].contact,"(sofia/.+)");
if sipurl == nil then
	_,_,sipurl = string.find(result[1].contact,"(user/.+)");
end

if sipurl == nil then
	stream:write("-ERR agent config error!");
	return;
end
local contact = "{hangup_after_bridge=true,origination_caller_id_name=zswitch_callcenter_agent_click,origination_caller_id_number=click_get_number}"..sipurl;
local result = api:executeString("bgapi originate "..contact.." &lua('"..rootdir.."/scripts/autodial/autodialPS.lua "..userid.." "..groupid.." "..agent.."')");

stream:write(result);