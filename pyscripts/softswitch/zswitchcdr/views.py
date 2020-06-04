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
from rest_framework.decorators import action

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
        if data['action'] == "AgentCallinRinging":
            data['created_datetime'] = self.format_time(data['created_datetime'])

        if data['action'] == "AgentCalloutRinging":
            data['created_datetime'] = self.format_time(data['created_datetime'])
            data['direction'] = "callout"
        serializer = CdrSerializers(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data["id"], status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(methods=['put'], detail=False, url_path='update-data')
    def update_data(self, request):
        data = request.data.copy()
        cdr = Cdr.objects.filter(agent_name=data['agent_name']).order_by('-id').first()
        if data['action'] == "AgentCallinAndwered":
            data['created_datetime'] = self.format_time(data['created_datetime'])
            data['answered_datetime'] = self.format_time(data['answered_datetime'])

        if data['action'] == "AgentCalloutAndwered":
            data['created_datetime'] = self.format_time(data['created_datetime'])
            data['answered_datetime'] = self.format_time(data['answered_datetime'])
            data['direction'] = "callout"
                  
        if data['action'] == "AgentCallinHangup":
            data['answered_datetime'] = self.format_time(data['answered_datetime'])
            data['created_datetime'] = self.format_time(data['created_datetime'])
            data['hangup_datetime'] = self.format_time(data['hangup_datetime'])
            data['toltal_timed'] = str(data['hangup_datetime'] - data['created_datetime'])
            data['talk_timed'] = str(data['hangup_datetime'] -  data['answered_datetime'])

        if data['action'] == "AgentCalloutHangup":
            data['answered_datetime'] = self.format_time(data['answered_datetime'])
            data['created_datetime'] = self.format_time(data['created_datetime'])
            data['hangup_datetime'] = self.format_time(data['hangup_datetime'])
            data['direction'] = "callout"
            data['toltal_timed'] = str(data['hangup_datetime'] - data['created_datetime'])
            data['talk_timed'] = str(data['hangup_datetime'] -  data['answered_datetime'])
        serializer = CdrSerializers(instance=cdr, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse({"result":"success"}) #py
            #return Response("success")#lua
        else:
            return JsonResponse({"result":"failed"}) #py
            #return Response("failed") #lua

    def list(self, request):
        value = request.GET.get('action')
        if value == "InitSystem":
            return JsonResponse({"result":"success"}) #py
            #return Response('success')#lua
        else:
            return JsonResponse({"result":"failed"}) #py
            #return Response("failed") #lua


