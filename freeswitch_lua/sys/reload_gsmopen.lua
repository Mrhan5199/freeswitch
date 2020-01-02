local api = freeswitch.API();
freeswitch.msleep(10000);
api:execute('gsm','reload');
