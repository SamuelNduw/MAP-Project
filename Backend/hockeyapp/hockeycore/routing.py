from django.urls import re_path
from .consumers import LiveMatchConsumer

websocket_urlpatterns = [
    re_path(r'^ws/match/(?P<fixture_id>\d+)/$', LiveMatchConsumer.as_asgi())
]