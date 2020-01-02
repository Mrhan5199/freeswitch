--[[call limit
api command:
lua call_limit.lua @pattern @key  @limits
  @key: Limit the unique name of the calling object, such as phone number, channel name, gateway name, etc.
  @pattern: 
     count-of-day: Limit the number of calls per day.
	 count-of-month: Limit the number of calls per month.
  @limits: Limited number.	 

]]
if session ~= nil then
    session:setAutoHangup(false)
end	

local rootdir = freeswitch.getGlobalVariable("base_dir")
loadfile(rootdir.."/scripts/include/functions.lua")()
local api =  freeswitch.API();

function reset_count_of_day(key)
    if key == nil or key == "all" then
		local keys = string_spilt(api:executeString("db list/call_limit_last_count_of_day/"),",")
		for k,v in ipairs(keys) do
            api:executeString("db delete/call_limit_last_count_of_day/"..v)		
		end
		local keys = string_spilt(api:executeString("db list/call_limit_value_count_of_day/"),",")
		for k,v in ipairs(keys) do
            api:executeString("db delete/call_limit_value_count_of_day/"..v)		
		end	
    else
        api:executeString("db delete/call_limit_value_count_of_day/"..key)	
		api:executeString("db delete/call_limit_last_count_of_day/"..key)	
	end
end

function reset_count_of_month(key)
    if key == nil or key == "all" then
		local keys = string_spilt(api:executeString("db list/call_limit_last_count_of_month/"),",")
		for k,v in ipairs(keys) do
            api:executeString("db delete/call_limit_last_count_of_month/"..v)		
		end
		local keys = string_spilt(api:executeString("db list/call_limit_value_count_of_month/"),",")
		for k,v in ipairs(keys) do
            api:executeString("db delete/call_limit_value_count_of_month/"..v)		
		end	
    else
        api:executeString("db delete/call_limit_value_count_of_month/"..key)	
		api:executeString("db delete/call_limit_last_count_of_month/"..key)	
	end
end

if argv[1] == 'reset' then
	if argv[2] == 'all' or argv[2] == nil then
	    reset_count_of_day("all")
	    reset_count_of_month("all")	
	elseif argv[2] == 'count-of-day' then
	    if argv[3] == nil or argv[3] == "all" then
		    reset_count_of_day("all")
		else
            reset_count_of_day(argv[3])
        end		
    elseif argv[2] == 'count-of-month' then      
	    if argv[3] == nil or argv[3] == "all" then
		    reset_count_of_month("all")
		else
            reset_count_of_month(argv[3])
        end			 
	end
	stream:write("+OK\ncall limit reset. ")
    return
end

if argv[1] == nil then
	freeswitch.consoleLog("ERR","must argv[1] pattern!\n")
	stream:write("false")
	return 
end 
local pattern = argv[1]

if argv[2] == nil then
	freeswitch.consoleLog("ERR","must argv[2] key!\n")
	stream:write("false")
	return
end 
local key= argv[2]


if argv[3] == nil then
	freeswitch.consoleLog("ERR","must argv[1] limits!\n")
	stream:write("false")
	return 
end 
local limits = tonumber(argv[3])



if pattern == 'count-of-day' then
    local last = nil
	if api:executeString("db exists/call_limit_last_count_of_day/"..key) == "false" then
	    last = os.date("%Y%m%d")
	    api:executeString("db insert/call_limit_last_count_of_day/"..key.."/"..last)
	else
        last = api:executeString("db select/call_limit_last_count_of_day/"..key)
    end
	
    local count = 0
	if api:executeString("db exists/call_limit_value_count_of_day/"..key) == "false" then
	    api:executeString("db insert/call_limit_value_count_of_day/"..key.."/0")
	else
        count = tonumber(api:executeString("db select/call_limit_value_count_of_day/"..key)) 	
    end
	
	local current = os.date("%Y%m%d")
	if current ~= last then
	    count = 0
	end
	
	freeswitch.consoleLog("info","Limit the number of calls per day,'"..key.."',limits:"..limits..",count:"..count..".\n")
	if count < limits then
		count = count + 1 
		api:executeString("db insert/call_limit_value_count_of_day/"..key.."/"..count)
		api:executeString("db insert/call_limit_last_count_of_day/"..key.."/"..current)
		stream:write("true")
	else
	    stream:write("false")
    end
elseif pattern == 'count-of-month' then

    local last = nil
	if api:executeString("db exists/call_limit_last_count_of_month/"..key) == "false" then
	    last = os.date("%Y%m")
	    api:executeString("db insert/call_limit_last_count_of_month/"..key.."/"..last)
	else
        last = api:executeString("db select/call_limit_last_count_of_month/"..key)
    end
	
    local count = 0
	if api:executeString("db exists/call_limit_value_count_of_month/"..key) == "false" then
	    api:executeString("db insert/call_limit_value_count_of_month/"..key.."/0")
	else
        count = tonumber(api:executeString("db select/call_limit_value_count_of_month/"..key)) 	
    end
	
	local current = os.date("%Y%m")
	if current ~= last then
	    count = 0
	end
	freeswitch.consoleLog("info","Limit the number of calls per month,'"..key.."',limits:"..limits..",count:"..count..".\n")
	if count < limits then
		count = count + 1 
		api:executeString("db insert/call_limit_value_count_of_month/"..key.."/"..count)
		api:executeString("db insert/call_limit_last_count_of_month/"..key.."/"..current)
		stream:write("true")
	else
        stream:write("false")	
    end
else
    stream:write("false")	
end
