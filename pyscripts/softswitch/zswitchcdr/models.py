'''
@Descripttion: 
@version: 1.0
@Author: Mrhan
@Date: 2019-11-28 11:23:42
@LastEditors: Mrhan
@LastEditTime: 2019-11-29 10:58:00
'''
from django.db import models
from django.utils import timezone
class Cdr(models.Model):
    '''话单
    '''
    id = models.AutoField('id', primary_key=True) #id
    agent_name = models.CharField('agent_name', max_length=50, default='') #坐席工号
    direction = models.CharField('direction', max_length=20, default='callin') #呼入呼出方向
    other_number = models.CharField('other_number', max_length=50, default='')#被叫号码
    uuid = models.UUIDField('uuid', max_length=50)#uuid唯一值
    created_datetime = models.DateTimeField('created_datetime', default=timezone.now)#开始呼叫时间
    answered_datetime = models.DateTimeField('answered_datetime', default=timezone.now)#应答时间
    hangup_datetime = models.DateTimeField('hangup_datetime', default=timezone.now, null=True, blank=True)#挂机时间
    bleg_uuid = models.UUIDField('bleg_uuid',max_length=50, default=None, null=True, blank=True)#b_uuid唯一值
    hangup_cause = models.CharField('hangup_cause', max_length=50, default='')#挂机原因
    toltal_timed = models.CharField('toltal_timed', max_length=20, default='')#呼叫总时间
    talk_timed = models.CharField('talk_timed',  max_length=20, default='')#应答时间
    calling_ip = models.CharField('calling_ip', max_length=20, default='', null=True)#主叫ip
    called_ip = models.CharField('called_ip', max_length=20, default='', null=True)#被叫ip

    class Meta:
        db_table = 'zswitch_cc_agent_cdr'