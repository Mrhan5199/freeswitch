
local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
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
		if false then
			freeswitch.consoleLog("ERR","\nzswitch callcenter system expire!\n");
		else	
			local ch = e:getHeader("Caller-Channel-Name");
			local ccs = e:getHeader("Channel-Call-State");
			local occs = e:getHeader("Original-Channel-Call-State")	
			local dir = e:getHeader("Caller-Direction");
			local cna = e:getHeader("Caller-Network-Addr");
            local olna = e:getHeader("Other-Leg-Network-Addr");
			local post = false;
			local put = false;
			local agent_record = false;
			local queueAndwered = false;
			local urlparam = {};
			local answerts = 0;
			local ORIGIN_TIME = "0000-00-00 00:00:00"
			if ch~=nil  then 
				--freeswitch.consoleLog("ERR","\n"..e:serialize("text").."\n");
				if string.find(ch,AgentSipIf) and dir == "outbound"  then
					--  callin
					local agent_name = e:getHeader("Caller-Callee-ID-Number");
					local uuid = e:getHeader("Caller-Unique-ID");
					local other_number = e:getHeader("Caller-Caller-ID-Number");
					local bleg_uuid = e:getHeader("Other-Leg-Unique-ID");
					if string.match(agent_name,"^6[0-9][0-9][0-9]$") then
						agent_record = true;
					end				
					if bleg_uuid ==  nil then
						bleg_uuid = "";
					end	
					if nil ~= agent_name  then	
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCallinRinging";
							urlparam["agent_name"] = agent_name;	
							urlparam["uuid"]  = uuid;
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;
							post = true;												
						elseif ccs == "ACTIVE" then		
							urlparam["action"] = "AgentCallinAndwered";
							urlparam["agent_name"] = agent_name;		
							urlparam["uuid"] = uuid;			
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;	
							urlparam["calling_ip"] = cna;
							urlparam["called_ip"] = olna;	
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answered_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");	
							put = true;					
						elseif ccs == "HANGUP" then						    
							urlparam["action"] = "AgentCallinHangup";
							urlparam["agent_name"] = agent_name;			
							urlparam["uuid"] = uuid;			
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;	
							urlparam["calling_ip"] = cna;
							urlparam["called_ip"] = olna;
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answered_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangup_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangup_cause"] = e:getHeader("Hangup-Cause");
							if 	ORIGIN_TIME == urlparam["answered_datetime"] then
								urlparam["answered_datetime"] = urlparam["hangup_datetime"]
							end
							put = true;		
						end
					end						
				elseif  string.find(ch,AgentSipIf) and dir == "inbound" then					
					-- callout
					local agent_name = e:getHeader("Caller-Caller-ID-Number");
					local uuid = e:getHeader("Caller-Unique-ID");
					local other_number = e:getHeader("Caller-Destination-Number");
					local bleg_uuid = e:getHeader("Other-Leg-Unique-ID");
					if string.match(agent_name,"^6[0-9][0-9][0-9]$") then
						agent_record = true;
					end				
					if bleg_uuid ==  nil then
						bleg_uuid = "";
					end	
					if nil ~= agent_name  then							
						if ccs == "RINGING" then						
							urlparam["action"] = "AgentCalloutRinging";
							urlparam["agent_name"] = agent_name;
							urlparam["uuid"]  = uuid;
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));					
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;
							post = true;													
						elseif ccs == "ACTIVE" then
							urlparam["action"] = "AgentCalloutAndwered";
							urlparam["agent_name"] = agent_name;	
							urlparam["uuid"] = uuid;			
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;
							urlparam["calling_ip"] = cna;
							urlparam["called_ip"] = olna;	
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answered_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							answerts = e:getHeader("Caller-Channel-Answered-Time");
							put = true;						
						elseif ccs == "HANGUP" then
							urlparam["action"] = "AgentCalloutHangup";
							urlparam["agent_name"] = agent_name;		
							urlparam["uuid"] = uuid;			
							urlparam["other_number"] = other_number;
							urlparam["bleg_uuid"] = bleg_uuid;
							urlparam["calling_ip"] = cna;
							urlparam["called_ip"] = olna;	
							urlparam["created_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Created-Time"));
							urlparam["answered_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Answered-Time"));
							urlparam["hangup_datetime"] = formatUNIXTimeFromUS(e:getHeader("Caller-Channel-Hangup-Time"));
							urlparam["hangup_cause"] = e:getHeader("Hangup-Cause");	
							if 	ORIGIN_TIME == urlparam["answered_datetime"] then
								urlparam["answered_datetime"] = urlparam["hangup_datetime"]
							end
							put = true;	
						end
					end												
					
				end
			end
			
			if put and ccs == "ACTIVE" and EnableRecord and e:getHeader("Caller-Caller-ID-Name") ~= "zswitch_callcenter_agent_spy" 
				and 0 ~= answerts and agent_record then
				local path =  rootdir..RecoardPath..os.date("%Y-%m-%d",answerts/1000000).."/"..urlparam["agent_name"].."/";
				recfile = path..urlparam["uuid"].."_"..urlparam["agent_name"].."_"..urlparam["other_number"].."_"..os.date("%Y%m%d%H%M%S",answerts/1000000)..".wav";
				api:execute("uuid_record",urlparam["uuid"].." start "..recfile);
			end
	
			if post and agent_record then
				local code = post_http(WebServiceURL,urlparam);
				if code ==nil then
					freeswitch.consoleLog("ERR","\nwebservices error!\n");	
				end
			elseif put and agent_record then
				local code = put_http(WebServiceURL,urlparam);
				if code == "failed" then
					freeswitch.consoleLog("ERR","\n"..code.."\n");
				end
			end			
		end
	end
	freeswitch.msleep(200);
end
freeswitch.consoleLog("INFO","\nagent event thread exit!\n");
