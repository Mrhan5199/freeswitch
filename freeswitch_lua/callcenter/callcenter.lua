session:setAutoHangup(false);
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
--	return;
--end
----freeswitch.consoleLog("ERR",cf);
--loadstring(cf)();
--load(cf)();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

--if os.difftime(os.time(ValidDate),os.time()) <0 then
--	freeswitch.consoleLog("ERR","\nsystem expire!\n");
--	return;
--end			

if argv[1] == nil then
	freeswitch.consoleLog("ERR","queue name empty!\n");
	return;
end	

--if not in_array(argv[1],QueueList) then
--	freeswitch.consoleLog("ERR","queue name invalid!\n");
--	return;
--end

local urlparam = {};
urlparam["action"] = "GetVIPNumberLevel";
urlparam["number"] =  session:getVariable("caller_id_number");
local level = 0;
local code,msg,data = request_http(WebServiceURL,urlparam);
if code ~= nil then
	level = code;
end
session:setVariable("hangup_after_bridge","false");
session:setVariable("origination_caller_id_name","zswitch_callcenter_queue");
session:setVariable("origination_callee_id_name",argv[1]);
session:setVariable("cc_export_vars","origination_caller_id_name,origination_callee_id_name");
session:setVariable("cc_base_score",level);
session:execute("callcenter",argv[1]);
--session:execute("info");
local agent = session:getVariable("cc_agent");
if agent ~= nil then
	session:setVariable("exec_after_bridge_app","lua");
    session:setVariable("exec_after_bridge_arg","callcenter/evaluate.lua "..agent);
end
