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
    id = models.AutoField('id', primary_key=True)
    agent_name = models.CharField('agent_name', max_length=50, default='')
    direction = models.CharField('direction', max_length=20, default='callin')
    other_number = models.CharField('other_number', max_length=50, default='')
    uuid = models.UUIDField('uuid', max_length=50)
    created_datetime = models.DateTimeField('created_datetime', default=timezone.now)
    answered_datetime = models.DateTimeField('answered_datetime', default=timezone.now)
    hangup_datetime = models.DateTimeField('hangup_datetime', default=timezone.now, null=True, blank=True)
    bleg_uuid = models.UUIDField('bleg_uuid',max_length=50, default=None, null=True, blank=True)
    hangup_cause = models.CharField('hangup_cause', max_length=50, default='')
    toltal_timed = models.CharField('toltal_timed', max_length=20, default='')
    talk_timed = models.CharField('talk_timed',  max_length=20, default='')
    calling_ip = models.CharField('calling_ip', max_length=20, default='')
    called_ip = models.CharField('called_ip', max_length=20, default='')

    class Meta:
        db_table = 'zswitch_cc_agent_cdr'