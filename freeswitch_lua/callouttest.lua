local rootdir = freeswitch.getGlobalVariable("base_dir");
api = freeswitch.API();
count = 100000;
while count>0 do
api:executeString("bgapi lua callcenter/callout.lua 1000 13990879119");
freeswitch.msleep(200);
end