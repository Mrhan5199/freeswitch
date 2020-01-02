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


while session:ready() == true do
	session:setVariable("continue_on_fail","true");
	session:setVariable("hangup_after_bridge","false");	
	--session:setVariable("ringback","%(2000, 4000, 440.0, 480.0)");
	--session:setVariable("ringback",rootdir.."/sounds/autodial/callout_wait.wav");
	--session:execute("ring_ready");

	local urlparam = {};
	urlparam["action"] = "getNumber";
	urlparam["userid"] = userid;
	urlparam["groupid"] = groupid;
	urlparam["agent"] = agent;	
	local code,msg,data = request_http(Autodial_WebServiceURL,urlparam);
	
	if code == nil  then	
		freeswitch.consoleLog("ERR","Autodial get number error!\n");
		break;
	end
	
	if code ~= 0  then	
		freeswitch.consoleLog("ERR",msg.."\n");
		break;
	end
	
	_,_,number,numberid,accountid = string.find(msg,"(%d+),(%d+),(.+)");
	if number == nil or numberid == nil then
		freeswitch.consoleLog("ERROR","Autodial  number format  error!\n");
		break;
	end
	freeswitch.consoleLog("INFO","Autodial  call number:"..number.."\n");
	local specialip = freeswitch.getGlobalVariable("local_ip_v4");
	local specialport = freeswitch.getGlobalVariable("special_sip_port");

	urlparam = {};
	urlparam["action"] = "startCall";
	urlparam["userid"] = userid;
	urlparam["numberid"] = numberid;
	urlparam["number"] = number;
	request_http(Autodial_WebServiceURL,urlparam);	
	session:setVariable("autodialps_callee_answered","false");
	session:execute("export","nolocal:execute_on_answer=lua "..rootdir.."/scripts/autodial/onAnswer_autodialPS.lua "..userid.." "..session:get_uuid());
	session:execute("bridge","{call_timeout=20}sofia/callcenter_trunk/"..number.."@"..specialip..":"..specialport);
	local hangcase = session:getVariable("last_bridge_hangup_cause");
	--local hangcase = env:getHeader("last_bridge_hangup_cause");
	if nil == hangcase or string.len(hangcase)<1 then
		hangcase = "Other";
	end
	urlparam = {};
	urlparam["action"] = "hangup";
	urlparam["userid"] = userid;
	urlparam["numberid"] = numberid;
	urlparam["result"] = hangcase;
	request_http(Autodial_WebServiceURL,urlparam);	
	
	if session:getVariable("autodialps_callee_answered") == "true" then
	--if env:getHeader("autodialps_callee_answered") == "true" then
		break;		
	end

	freeswitch.msleep(1000);
end
urlparam = {};
urlparam["action"] = "stop";
urlparam["userid"] = userid;
request_http(Autodial_WebServiceURL,urlparam);			
freeswitch.consoleLog("INFO","Autodial agent exit:"..agent.."\n");


