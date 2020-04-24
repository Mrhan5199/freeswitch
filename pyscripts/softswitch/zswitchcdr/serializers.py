'''
@Descripttion: 
@version: 1.0
@Author: Mrhan
@Date: 2019-11-28 15:32:59
@LastEditors: Mrhan
@LastEditTime: 2019-11-28 17:12:39
'''
from rest_framework import serializers
from zswitchcdr.models import Cdr

class CdrSerializers(serializers.ModelSerializer):
    class Meta:
        model = Cdr
        fields = '__all__'