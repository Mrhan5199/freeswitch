'''
@Descripttion: 
@version: 1.0
@Author: Mrhan
@Date: 2019-11-28 11:23:42
@LastEditors: Mrhan
@LastEditTime: 2019-12-03 11:46:38
'''
from django.shortcuts import render
from zswitchcdr.models import Cdr
from zswitchcdr.serializers import CdrSerializers
from rest_framework import status, viewsets
from django.http import JsonResponse
from rest_framework.response import Response
import datetime, time
from django.shortcuts import get_object_or_404
# Create your views here.

class CdrViewSet(viewsets.ModelViewSet):
    '''话单视图
    '''
    queryset = Cdr.objects.all()
    serializer_class = CdrSerializers

    def format_time(self, timestamp):
        #tm = timestamp.replace('',' ')
        return datetime.datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')

    def create(self, request):
        data = request.data.copy()
        # if data.get('action','') == "AgentCallinRinging":
        if data['action'] == "AgentCallinRinging":
            data['bleg_uuid'] = data['blegUUID']
            data['queue'] = data['queue']
            data['agent_name'] = data['agent']
            data['other_number'] = data['otherNumber']
            data['uuid'] = data['UUID']
            data['create_datetime'] = self.format_time(data['startTime'])

        if data['action'] == "AgentCalloutRinging":
            data['bleg_uuid'] = data['blegUUID']
            data['queue'] = data['queue']
            data['agent_name'] = data['agent']
            data['other_number'] = data['otherNumber']
            data['uuid'] = data['UUID']
            data['create_datetime'] = self.format_time(data['startTime'])
            data['dir'] = "callout"
        serializer = CdrSerializers(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data["id"], status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, pk):
        cdr = get_object_or_404(Cdr, pk=pk)
        data = request.data.copy()
        if data['action'] == "AgentCallinAndwered":
            data['create_datetime'] = self.format_time(data['startTime'])
            data['answered_datetime'] = self.format_time(data['answerTime'])
            data['queue'] = data['queue']
            data['agent_name'] = data['agent']
            data['uuid'] = data['UUID']
            data['other_number'] = data['otherNumber']
            data['bleg_uuid'] = data['blegUUID']

        if data['action'] == "AgentCalloutAndwered":
            data['create_datetime'] = self.format_time(data['startTime'])
            data['answered_datetime'] = self.format_time(data['answerTime'])
            data['queue'] = data['queue']
            data['agent_name'] = data['agent']
            data['uuid'] = data['UUID']
            data['other_number'] = data['otherNumber']
            data['bleg_uuid'] = data['blegUUID']
            data['dir'] = "callout"
                  
        if data['action'] == "AgentCallinHangup":
            data['answered_datetime'] = self.format_time(data['answerTime'])
            datat['uuid'] = data['UUID']
            data['agent_name'] = data['agent']
            data['create_datetime'] = self.format_time(data['startTime'])
            data['queue'] = data['queue']
            data['other_number'] = data['otherNumber']
            data['hangup_cause'] = data['hangupCase']
            data['hangup_datetime'] = self.format_time(data['hangupTime'])
            data['bleg_uuid'] = data['blegUUID']
            data['toltal_timed'] = str(self.format_time(data['hangupTime']) - self.format_time(data['startTime']))
            data['talk_timed'] = str(self.format_time(data['hangupTime']) - self.format_time(data['answerTime']))

        if data['action'] == "AgentCalloutHangup":
            data['answered_datetime'] = self.format_time(data['answerTime'])
            data['uuid'] = data['UUID']
            data['agent_name'] = data['agent']
            data['create_datetime'] = self.format_time(data['startTime'])
            data['queue'] = data['queue']
            data['other_number'] = data['otherNumber']
            data['hangup_cause'] = data['hangupCase']
            data['hangup_datetime'] = self.format_time(data['hangupTime'])
            data['bleg_uuid'] = data['blegUUID']
            data['dir'] = "callout"
            data['toltal_timed'] = str(self.format_time(data['hangupTime']) - self.format_time(data['startTime']))
            data['talk_timed'] = str(self.format_time(data['hangupTime']) - self.format_time(data['answerTime']))
            print (data['toltal_timed'])
            print (data['talk_timed'])
        serializer = CdrSerializers(instance=cdr, data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data,status=status.HTTP_200_OK)
            
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def list(self, request):
        value = request.GET.get('action')
        if value == "InitSystem":
            return JsonResponse({"result":"success"})
        else:
            return JsonResponse({"result":"error"})


