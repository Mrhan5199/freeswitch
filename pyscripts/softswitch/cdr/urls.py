'''
@Descripttion: 
@version: 1.0
@Author: Mrhan
@Date: 2019-11-28 11:13:59
@LastEditors: Mrhan
@LastEditTime: 2019-11-29 09:41:26
'''
"""cdr URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf.urls import url
import zswitchcdr.urls

urlpatterns = [
    url(r'^', include(zswitchcdr.urls)),
    url('admin/', admin.site.urls)
]
