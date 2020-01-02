
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
--	return;
--end
--loadstring(cf)();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

if argv[1] ~= nil and argv[1] == "stop" then
	local event = freeswitch.Event("CUSTOM","ZSWITCH:CALLCENTER-EVENT-THREAD");
	event:addHeader("Action", "stop");
	event:fire();
	return ;
end

local CtrlEvent = freeswitch.EventConsumer("CUSTOM","ZSWITCH:CALLCENTER-EVENT-THREAD");
local CCEvent = freeswitch.EventConsumer("CUSTOM","callcenter::info");
if CtrlEvent == nil or CCEvent == nil then
	freeswitch.consoleLog("ERR","\nblind event failure ! callcenter event thread start failure!\n");
end

freeswitch.consoleLog("INFO","\ncallcenter event thread start!\n");
while true do
	local ce = CtrlEvent:pop();
	if ce~= nil and "stop" == ce:getHeader("action") then
		break;	
	end
	while true do
		e = CCEvent:pop();
		if e == nil then
			break;
		end
		if false then
		--if os.difftime(os.time(ValidDate),os.time()) <0 then
			freeswitch.consoleLog("ERR","\nsystem expire!\n");
		else
			local req = false;
			local urlparam = {};
			local action = e:getHeader("CC-Action");
			if action == "agent-status-change" then
				local agent = e:getHeader("CC-Agent");
				if agent~= nil  then
				--if agent~= nil and in_array(agent,AgentList) then
					urlparam["action"] = "AgentStatusChange";
					urlparam["agent"] = agent;
					urlparam["status"] = e:getHeader("CC-Agent-Status");
					req = true;
				end			
			elseif action == "member-queue-start" then
				local queue = e:getHeader("CC-Queue");
				if queue ~=nil then
				--if queue ~=nil and in_array(queue,QueueList) then
					urlparam["action"] = "MemberJoin";
					urlparam["queue"] = queue;
					urlparam["caller"] = e:getHeader("CC-Member-CID-Number");
					urlparam["UUID"] = e:getHeader("CC-Member-Session-UUID");
					req = true;		
				end		
			elseif action == "member-queue-end" then
				local queue = e:getHeader("CC-Queue");
				if queue~= nil  then
				--if queue~= nil and in_array(queue,QueueList) then
					--freeswitch.consoleLog("ERR",e:serialize("text"));
					urlparam["action"] = "MemberLeave";
					urlparam["queue"] = queue;
					urlparam["joinTime"] =  formatUNIXTimeFromSEC(e:getHeader("CC-Member-Joined-Time"));
					urlparam["leaveTime"] = formatUNIXTimeFromSEC(e:getHeader("CC-Member-Leaving-Time"));
					urlparam["callAgnetTime"] = formatUNIXTimeFromSEC(e:getHeader("CC-Agent-Called-Time"));
					urlparam["agentAnswerTime"] = formatUNIXTimeFromSEC(e:getHeader("CC-Agent-Answered-Time"));	
					urlparam["UUID"] = e:getHeader("CC-Member-Session-UUID");
					urlparam["caller"] = e:getHeader("CC-Member-CID-Number");
					if e:getHeader("CC-Cause") == "Terminated"  then						
						urlparam["cause"] = e:getHeader("CC-Hangup-Cause");
					else				
						urlparam["cause"] = e:getHeader("CC-Cancel-Reason");				
					end
					req = true;
				end	
			end	
			if req then
				local code,msg,data = request_http(WebServiceURL,urlparam);
				if code~=nil and code ~= 0 and msg ~= nil  then
					freeswitch.consoleLog("ERR","\n"..msg.."\n");
				end
			end	
		end		
	end
	freeswitch.msleep(200);
end
freeswitch.consoleLog("INFO","\ncallcenter event thread exit!\n");
