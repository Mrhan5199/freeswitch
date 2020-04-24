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
    userid = models.SmallIntegerField('userid', default=-1)
    queue = models.CharField('queue', max_length=100, default='', blank=True)
    agent_name = models.CharField('agent_name', max_length=50, default='')
    dir = models.CharField('dir', max_length=20, default='callin')
    other_number = models.CharField('other_number', max_length=50, default='')
    other_area_code = models.CharField('other_area_code', max_length=20, default='', blank=True)
    uuid = models.UUIDField('uuid', max_length=50)
    source = models.CharField('source', max_length=50, default='', null=True, blank=True)
    context = models.CharField('context', max_length=50, default='', null=True, blank=True)
    channel_name = models.CharField('channel_name', max_length=100, default='', null=True, blank=True)
    created_datetime = models.DateTimeField('create_datetime', default=timezone.now)
    answered_datatime = models.DateTimeField('answered_datetime', default=timezone.now)
    hangup_datetime = models.DateTimeField('hangup_datetime', default=timezone.now, null=True, blank=True)
    bleg_uuid = models.UUIDField('bleg_uuid',max_length=50, default=None, null=True, blank=True)
    hangup_cause = models.CharField('hangup_cause', max_length=50, default='')
    toltal_timed = models.CharField('toltal_timed', max_length=20, default='')
    talk_timed = models.CharField('talk_timed',  max_length=20, default='')

    class Meta:
        db_table = 'zswitch_cc_agent_cdr'