'''
@Descripttion: 
@version: 1.0
@Author: Mrhan
@Date: 2019-11-28 15:29:53
@LastEditors: Mrhan
@LastEditTime: 2019-11-29 09:26:34
'''
from django.urls import include, path
from rest_framework import routers
from zswitchcdr.views import CdrViewSet

router = routers.DefaultRouter()
router.register(r'webservices', CdrViewSet)

# Wire up our API using automatic URL routing.
# Additionally, we include login URLs for the browsable API.
urlpatterns = [
    path('', include(router.urls))
]