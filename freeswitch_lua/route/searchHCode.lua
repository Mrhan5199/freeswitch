
api = freeswitch.API();


hd = {"15","18","17","14"};
for k,v in ipairs(hd) do 
	for s = 0,9,1 do
        for h = 0,9999,1 do
            num = v..s..string.format("%04d",h);
            freeswitch.consoleLog("notice",num.."\n");
            api:executeString("lua route/queryMobileCity.lua "..num.." ".."028");
            freeswitch.msleep(20);
        end
	end
end 




