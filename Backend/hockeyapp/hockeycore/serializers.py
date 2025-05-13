from rest_framework import serializers
from .models import User, Team, Fixture, League, Player, Manager, Staff

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['user_id', 'email', 'full_name', 'password', 'role']
        extra_kwargs = {
            'password': {'write_only': True},
            'role': {'read_only': True}
        }

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user
    

class LeagueSerializer(serializers.ModelSerializer):
    class Meta:
        model = League
        fields = '__all__'

class TeamSerializer(serializers.ModelSerializer):
    class Meta:
        model = Team
        fields = '__all__'

class PlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = '__all__'

class ManagerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Manager
        fields = '__all__'

class StaffSerializer(serializers.ModelSerializer):
    class Meta:
        model = Staff
        fields = '__all__'

class FixtureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fixture
        fields = '__all__'


class PublicTeamSerializer(serializers.ModelSerializer):
    league_name = serializers.CharField(source='league_id.name', read_only=True)
    
    class Meta:
        model = Team
        fields = ['id', 'name', 'short_name', 'logo_url', 'founded_year', 'league_name']

class PublicFixtureSerializer(serializers.ModelSerializer):
    home_team_name = serializers.CharField(source='home_team_id.name', read_only=True)
    away_team_name = serializers.CharField(source='away_team_id.name', read_only=True)
    league_name = serializers.CharField(source='league_id.name', read_only=True)
    
    class Meta:
        model = Fixture
        fields = [
            'id', 'match_datetime', 'venue', 'status',
            'home_team_name', 'away_team_name', 'league_name'
        ]