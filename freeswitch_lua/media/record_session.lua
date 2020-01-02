local rootdir = freeswitch.getGlobalVariable("base_dir");
loadfile(rootdir.."/scripts/include/functions.lua")();
loadfile(rootdir.."/scripts/media/config.lua")();
local api = freeswitch.API();

local caller = session:getVariable("callee_id_number")
local callee = argv[1]
local uuid = session:getVariable("uuid")
local atime = session:getVariable("answer_stamp");
local subpath = os.date("%Y-%m-%d",atime)
local atimestr = os.date("%Y%m%d%H%M%S",atime)
local file =  string.format("%s%s/%s/%s_%s_%s_%s.wav",MEDIA_CFG.record_dir,subpath,caller,uuid,caller,callee,atimestr)
session:execute("record_session",file)