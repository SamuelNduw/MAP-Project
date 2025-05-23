import json
from channels.generic.websocket import AsyncWebsocketConsumer

class LiveMatchConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.group_name = f"live_match_{self.scope['url_route']['kwargs']['fixture_id']}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def match_update(self, event):
        await self.send(text_data=json.dumps({
            'type': 'score_update',
            **event["data"]
        }))

    async def match_event(self, event):
        await self.send(text_data=json.dumps({
            'type': 'match_event',
            **event["data"]
        }))