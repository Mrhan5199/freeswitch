
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
--local cf = DecryptFile(rootdir.."/scripts/callcenter/reg.sn");
--if cf == nil then
--	freeswitch.consoleLog("ERR","\nsystem not register ,please call qq:674822668!\n");
--	return;
--end
--load(cf)();
loadfile(rootdir.."/scripts/callcenter/config.lua")();

if argv[1] ~= nil and argv[1] == "stop" then
	local event = freeswitch.Event("CUSTOM","ZSWITCH:AGENT-EVENT-THREAD");
	event:addHeader("Action", "stop");
	event:fire();
	return ;
end
local CtrlEvent = freeswitch.EventConsumer("CUSTOM","ZSWITCH:AGENT-EVENT-THREAD");
local AgentEvent = freeswitch.EventConsumer("CHANNEL_CALLSTATE");
if CtrlEvent == nil or AgentEvent == nil then
	freeswitch.consoleLog("ERR","\nblind event failure ! agent event thread start failure!\n");
end
freeswitch.consoleLog("INFO","\nagent event thread start!\n");
local api = freeswitch.API();
local prevTime = os.date("*t");
while true do
	local ce = CtrlEvent:pop();
	if ce~= nil and "stop" == ce:getHeader("action") then
		break;	
	end
	while true do
		local e = AgentEvent:pop();
		if e == nil then
			break;
		end
		
		local currTime = os.date("*t");
		if currTime.year ~= prevTime.year or currTime.month  ~= prevTime.month or currTime.day ~= prevTime.day then
			local urlparam = {};
			urlparam["action"] = "ResetToadyStatistics";
			request_http(WebServiceURL,urlparam);
		end
		prevTime = currTime;
		if false then
		  
			freeswitch.consoleLog("ERR","\nzswitch callcenter system expire!\n");
		else	
			local ch = e:getHeader("Caller-Channel-Name");
			local ccs = e:getHeader("Channel-Call-State");	
			local dir = e:getHeader("Caller-Direction");
			local req = false;
			local agent_record = false;
			local agent_record_1 = false;
			local queueAndwered = false;
			local urlparam = {};
			local answerts = 0;
			
			--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");
			if ch~=nil  then 
				--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");
				
				if   string.find(ch,AgentSipIf) and dir == "outbound" and e:getHeader("Caller-Orig-Caller-ID-Name") == "zswitch_callcenter_queue" then
					-- callcenter callin
					local agent = e:getHeader("Caller-Callee-ID-Number");
					local queue = e:getHeader("Caller-Callee-ID-Name");
					local uuid = e:getHeader("Caller-Unique-ID");
					local otherNumber = e:getHeader("Caller-Caller-ID-Number");
					local bleguuid = "";
					if agent ~= nil and queue ~= nil  then
					--if agent ~= nil and queue ~= nil and in_array(agent,AgentList) and in_array(queue,QueueList) then					
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCallinRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = queue;	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							req = true;													
						elseif ccs == "ACTIVE" then
							urlparam["action"] = "AgentCallinAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = queue;			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							queueAndwered = true;
							urlparam["blegUUID"] = "";	
							local res = api:execute("uuid_getvar",uuid.." Other-Leg-Unique-ID");
							if res ~= nil then
								urlparam["blegUUID"] = res;
							end
							req = true;	
						elseif ccs == "HANGUP" then
							urlparam["action"] = "AgentCallinHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = queue;			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							urlparam["startTime"] = "";
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");	
							req = true;	
						end
					end
				elseif  string.find(ch,AgentSipIf) and dir == "outbound" and (e:getHeader("Caller-Caller-ID-Name") == "zswitch_callcenter_agent_spy" or e:getHeader("Caller-Orig-Caller-ID-Name") == "zswitch_callcenter_agent_spy") then				
					--agent spy	
					--freeswitch.consoleLog("INFO","\nagent spy!\n");	
					local agent = e:getHeader("Caller-Callee-ID-Number");
					local uuid = e:getHeader("Caller-Unique-ID");
					local otherNumber = e:getHeader("Caller-Caller-ID-Number");	
					if ccs == "HANGUP" then 
						agent = e:getHeader("Caller-Caller-ID-Number");
						otherNumber = e:getHeader("Caller-Callee-ID-Number");
					end	
					local bleguuid = "";
					if agent~=nil  then
					--if agent~=nil and in_array(agent,AgentList) then
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCallinRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							req = true;													
						elseif ccs == "ACTIVE" then							
							urlparam["action"] = "AgentCallinAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							req = true;						
						elseif ccs == "HANGUP" then							
							urlparam["action"] = "AgentCallinHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;	
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));							
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");							
							req = true;	
						end						
					end	
				elseif  e:getHeader("Caller-Orig-Caller-ID-Name") == "zswitch_callcenter_agent_click" then
					-- click callout	
					--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");	
					local bch = e:getHeader("Other-Leg-Channel-Name");	
						
					if string.find(ch,AgentSipIf) and ccs == "RINGING" and dir == "outbound" then
						local agent = e:getHeader("Caller-Callee-ID-Number");
						if nil ~= agent then	
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Caller-ID-Number");
							urlparam["action"] = "AgentCalloutRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = "";
							req = true;
						end	
					elseif   string.find(ch,AgentSipIf) and ccs == "ACTIVE" and dir == "outbound"  and e:getHeader("Original-Channel-Call-State") == "RINGING"   then
						local agent = e:getHeader("Caller-Callee-ID-Number");
						if nil ~= agent then		
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Caller-ID-Number");
							urlparam["action"] = "AgentCalloutAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = "";
							req = true;
						end
					elseif   string.find(ch,AgentSipIf) and ccs == "HANGUP" and dir == "outbound"  and e:getHeader("Original-Channel-Call-State") == "RINGING"   then
						local agent = e:getHeader("Caller-Callee-ID-Number");
						if nil ~= agent then	
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Caller-ID-Number");
							urlparam["action"] = "AgentCalloutHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");								
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = "";
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");
							req = true;
						end
					elseif   bch~= nil and string.find(bch,AgentSipIf) and (ccs == "RINGING" or ccs == "EARLY") and dir == "outbound"   then	
						local agent = e:getHeader("Caller-Caller-ID-Number");
						--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");	
						if nil ~= agent then	
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Destination-Number");
							urlparam["action"] = "AgentCalloutRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = "";
							req = true;
						end	
					elseif   bch~= nil and string.find(bch,AgentSipIf) and ccs == "ACTIVE" and dir == "outbound"     then
						--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");
						local agent = e:getHeader("Caller-Caller-ID-Number");
						if nil ~= agent then	
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Callee-ID-Number");
							urlparam["action"] = "AgentCalloutAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = e:getHeader("Other-Leg-Unique-ID");
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							req = true;
						end
					elseif   bch~= nil and string.find(bch,AgentSipIf) and ccs == "HANGUP" and dir == "outbound"     then
						local agent = e:getHeader("Caller-Caller-ID-Number");
						if nil ~= agent  then	
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Callee-ID-Number");
							urlparam["action"] = "AgentCalloutHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = e:getHeader("Other-Leg-Unique-ID");
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");	
							req = true;
						end	
					elseif   bch == nil and string.find(ch,AgentSipIf) and ccs == "HANGUP" and dir == "outbound"     then
						local agent = e:getHeader("Caller-Caller-ID-Number");
						if nil ~= agent  then
						--if nil ~= agent and in_array(agent,AgentList) then						
							local uuid = e:getHeader("Caller-Unique-ID");
							local otherNumber = e:getHeader("Caller-Orig-Caller-ID-Number");
							urlparam["action"] = "AgentCalloutHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = "";
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");	
							req = true;
						end						
					end				
				elseif string.find(ch,AgentSipIf) and dir == "outbound"  then
					--  callin
					local agent = e:getHeader("Caller-Callee-ID-Number");
					local uuid = e:getHeader("Caller-Unique-ID");
					local otherNumber = e:getHeader("Caller-Caller-ID-Number");
					local bleguuid = e:getHeader("Other-Leg-Unique-ID");
					if string.match(agent,"^6[0-9][0-9][0-9]$") then
						agent_record = true;
					elseif string.match(agent,"^7[0-9][0-9][0-9]$") then
						agent_record_1 = true;
					end				
					if bleguuid ==  nil then
						bleguuid = "";
					end	
					if nil ~= agent  then	
					--if nil ~= agent and in_array(agent,AgentList)  then	
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCallinRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							req = true;													
						elseif ccs == "ACTIVE" then
							
							urlparam["action"] = "AgentCallinAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;	
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							req = true;						
						elseif ccs == "HANGUP" then						    
							urlparam["action"] = "AgentCallinHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;	
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");	
							req = true;	
						end
					end						
				elseif  string.find(ch,AgentSipIf) and dir == "inbound" then					
					-- callout
					--freeswitch.consoleLog("INFO","\ncallout!\n");
					local agent = e:getHeader("Caller-Caller-ID-Number");
					local uuid = e:getHeader("Caller-Unique-ID");
					local otherNumber = e:getHeader("Caller-Destination-Number");
					local bleguuid = e:getHeader("Other-Leg-Unique-ID");
					if string.match(agent,"^6[0-9][0-9][0-9]$") then
						agent_record = true;
					elseif string.match(agent,"^7[0-9][0-9][0-9]$") then
						agent_record_1 = true;
					end				
					if bleguuid ==  nil then
						bleguuid = "";
					end	
					if nil ~= agent  then		
					--if nil ~= agent and in_array(agent,AgentList)  then					
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCalloutRinging";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";	
							urlparam["UUID"]  = uuid;
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));					
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;
							req = true;													
						elseif ccs == "ACTIVE" then
							urlparam["action"] = "AgentCalloutAndwered";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;	
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							req = true;						
						elseif ccs == "HANGUP" then
							urlparam["action"] = "AgentCalloutHangup";
							urlparam["agent"] = agent;
							urlparam["queue"] = "";			
							urlparam["UUID"] = uuid;			
							urlparam["otherNumber"] = otherNumber;
							urlparam["blegUUID"] = bleguuid;	
							urlparam["startTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answerTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangupTime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangupCase"] = e:getHeader("Hangup-Cause");	
							req = true;	
						end
					end												
					
				end
			end
			
			if req and ccs == "ACTIVE" and EnableRecord and e:getHeader("Caller-Caller-ID-Name") ~= "zswitch_callcenter_agent_spy" 
				and 0 ~= answerts and agent_record then
				local path =  rootdir..RecoardPath..os.date("%Y-%m-%d",answerts/1000000).."/"..urlparam["agent"].."/";
				recfile = path..urlparam["UUID"].."_"..urlparam["agent"].."_"..urlparam["otherNumber"].."_"..os.date("%Y%m%d%H%M%S",answerts/1000000)..".wav";
				api:execute("uuid_record",urlparam["UUID"].." start "..recfile);
			elseif req and ccs == "ACTIVE" and EnableRecord and e:getHeader("Caller-Caller-ID-Name") ~= "zswitch_callcenter_agent_spy"
					and 0 ~= answerts and agent_record_1 then
					local path =  rootdir..RecoardPath..os.date("%Y-%m-%d",answerts/1000000).."/"..urlparam["agent"].."/";
					recfile = path..urlparam["UUID"].."_"..urlparam["agent"].."_"..urlparam["otherNumber"].."_"..os.date("%Y%m%d%H%M%S",answerts/1000000)..".wav";
					api:execute("uuid_record",urlparam["UUID"].." start "..recfile);
			end
	
			if req and agent_record then
				local code,msg,data = request_http(WebServiceURL,urlparam);
				if code ==nil or code ~= 0 then
					if msg ~= nil then
						freeswitch.consoleLog("ERR","\n"..msg.."\n");
					else
						freeswitch.consoleLog("ERR","\nwebservices error!\n");
					end	
				elseif  PlayWorkNumber and queueAndwered then					
					local cmd = rootdir.."/scripts/callcenter/playWorkNo.lua "..urlparam["UUID"].." "..msg;
					api:execute("luarun",cmd);			
				end
			elseif req and agent_record_1 then
				local code,msg,data = request_http(WebServiceURL_1,urlparam);
				if code ==nil or code ~= 0 then
					if msg ~= nil then
						freeswitch.consoleLog("ERR","\n"..msg.."\n");
					else
						freeswitch.consoleLog("ERR","\nwebservices error!\n");
					end	
				elseif  PlayWorkNumber and queueAndwered then					
					local cmd = rootdir.."/scripts/callcenter/playWorkNo.lua "..urlparam["UUID"].." "..msg;
					api:execute("luarun",cmd);			
				end
			end			
		end
	end
	freeswitch.msleep(200);
end
freeswitch.consoleLog("INFO","\nagent event thread exit!\n");
