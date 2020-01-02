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
--	freeswitch.consoleLog("ERR","\nsystem expire!\n");
--	return;
--end			

if argv[1] == nil then
	freeswitch.consoleLog("ERR","agent name invalid!\n");
	return;
end	

--if not in_array(argv[1],AgentList) then
--	freeswitch.consoleLog("ERR","agent invalid!\n");
--	return;
--end

local digits = session:playAndGetDigits(1, 1, 3, 3000, "#",rootdir.."/sounds/cc_agent_evaluate_pt.wav", "", "[1-3]");
if string.len(digits)>0 then
	local urlParams = {};
	urlParams["action"] = "MemberEvaluate";
	urlParams["caller"] = session:getVariable("caller_id_number");
	urlParams["callee"] = session:getVariable("destination_number");
	urlParams["uuid"] = session:getVariable("uuid");
	urlParams["agent"] = argv[1];
	urlParams["dtmf"] = digits;
	request_http(WebServiceURL,urlParams);
end
session:streamFile(rootdir.."/sounds/cc_agent_evaluate_end.wav");