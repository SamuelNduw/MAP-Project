from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User, Team, Fixture, League, Player, Manager, Staff, LeagueTeam, MatchEvent

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
    
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user: User):
        token = super().get_token(user)

        # Add custom claims
        token['email'] = user.email
        token['role'] = user.role
        token['full_name'] = user.full_name

        return token

class LeagueSerializer(serializers.ModelSerializer):
    class Meta:
        model = League
        fields = '__all__'

class TeamSerializer(serializers.ModelSerializer):
    class Meta:
        model = Team
        fields = '__all__'

class LeagueTeamSerializer(serializers.ModelSerializer):
    class Meta:
        model = LeagueTeam
        fields = '__all__'
        read_only_fields = ('date_joined',)

class PlayerSerializer(serializers.ModelSerializer):
    team_name = serializers.CharField(source='team_id.name', read_only=True)
    team_short_name = serializers.CharField(source='team_id.short_name', read_only=True)

    class Meta:
        model = Player
        fields = '__all__'
        extra_kwargs = {
            'position': {'required': False},
            'jersey_no': {'required': False},
            'height_cm': {'required': False},
            'weight_kg': {'required': False},
            'photo': {'required': False},
        }

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

class DetailedFixtureSerializer(serializers.ModelSerializer):
    home_team = TeamSerializer(source='home_team_id', read_only=True)
    away_team = TeamSerializer(source='away_team_id', read_only=True)
    league = LeagueSerializer(source='league_id', read_only=True)
    victor = TeamSerializer(read_only=True)
    
    class Meta:
        model = Fixture
        fields = '__all__'
        extra_kwargs = {
            'home_team_id': {'write_only': True},
            'away_team_id': {'write_only': True},
            'league_id': {'write_only': True},
        }

class CreateFixtureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fixture
        fields = '__all__'

class UpdateFixtureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Fixture
        fields = ['status', 'home_team_score', 'away_team_score', 'venue']
        
    def validate(self, data):
        if 'home_team_score' in data and 'away_team_score' in data:
            if data['home_team_score'] < 0 or data['away_team_score'] < 0:
                raise serializers.ValidationError("Scores cannot be negative")
        return data

class PublicFixtureSerializer(serializers.ModelSerializer):
    home_team = serializers.SerializerMethodField()
    away_team = serializers.SerializerMethodField()
    league = serializers.SerializerMethodField()
    victor = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()
    home_team_score = serializers.IntegerField(source='home_team_score', read_only=True)
    awayteam_score = serializers.IntegerField(source='away_team_score', read_only=True)
    match_events = serializers.SerializerMethodField()
    
    class Meta:
        model = Fixture
        fields = [
            'id', 'match_datetime', 'venue', 'status',
            'home_team', 'away_team', 'league', 'score',
            'home_team_score', 'away_team_score',  
            'victor', 'match_events'
        ]
    
    def get_home_team(self, obj):
        return {
            'id': obj.home_team_id.id,
            'name': obj.home_team_id.name,
            'short_name': obj.home_team_id.short_name,
            'logo_url': obj.home_team_id.logo_url
        }
    
    def get_away_team(self, obj):
        return {
            'id': obj.away_team_id.id,
            'name': obj.away_team_id.name,
            'short_name': obj.away_team_id.short_name,
            'logo_url': obj.away_team_id.logo_url
        }
    
    def get_league(self, obj):
        return {
            'id': obj.league_id.id,
            'name': obj.league_id.name,
            'season': obj.league_id.season
        }
    
    def get_victor(self, obj):
        if obj.victor:
            return {
                'id': obj.victor.id,
                'name': obj.victor.name,
                'short_name': obj.victor.short_name
            }
        return None
    
    def get_score(self, obj):
        return obj.score_display
    
    def get_match_events(self, obj):
        events = MatchEvent.objects.filter(fixture_id=obj).order_by('minute')
        return MatchEventSerializer(events, many=True).data
    
class SimpleFixtureSerializer(serializers.ModelSerializer):
    home_team_name = serializers.CharField(source='home_team_id.name')
    away_team_name = serializers.CharField(source='away_team_id.name')
    home_team_logo_url = serializers.URLField(source='home_team_id.logo_url')
    away_team_logo_url = serializers.URLField(source='away_team_id.logo_url')
    home_team_short_name = serializers.CharField(source='home_team_id.short_name')
    away_team_short_name = serializers.CharField(source='away_team_id.short_name')
    league_name = serializers.CharField(source='league_id.name')
    
    class Meta:
        model = Fixture
        fields = [
            'id', 'match_datetime', 'venue', 'status',
            'home_team_name', 'away_team_name', 'league_name',
            'home_team_score', 'away_team_score', 'home_team_logo_url', 'away_team_logo_url',
            'home_team_short_name', 'away_team_short_name'
        ]

class PublicFixtureDetailSerializer(serializers.ModelSerializer):
    home_team = serializers.SerializerMethodField()
    away_team = serializers.SerializerMethodField()
    league = serializers.SerializerMethodField()
    victor = serializers.SerializerMethodField()
    score = serializers.SerializerMethodField()
    match_events = serializers.SerializerMethodField()
    
    class Meta:
        model = Fixture
        fields = [
            'id', 'match_datetime', 'venue', 'status',
            'home_team', 'away_team', 'league', 'score',
            'victor', 'match_events'
        ]
    
    def get_home_team(self, obj):
        return {
            'id': obj.home_team_id.id,
            'name': obj.home_team_id.name,
            'short_name': obj.home_team_id.short_name,
            'logo_url': obj.home_team_id.logo_url
        }
    
    def get_away_team(self, obj):
        return {
            'id': obj.away_team_id.id,
            'name': obj.away_team_id.name,
            'short_name': obj.away_team_id.short_name,
            'logo_url': obj.away_team_id.logo_url
        }
    
    def get_league(self, obj):
        return {
            'id': obj.league_id.id,
            'name': obj.league_id.name,
            'season': obj.league_id.season
        }
    
    def get_victor(self, obj):
        if obj.victor:
            return {
                'id': obj.victor.id,
                'name': obj.victor.name,
                'short_name': obj.victor.short_name
            }
        return None
    
    def get_score(self, obj):
        return obj.score_display
    
    def get_match_events(self, obj):
        events = MatchEvent.objects.filter(fixture_id=obj).order_by('minute')
        return MatchEventSerializer(events, many=True).data

class MatchEventSerializer(serializers.ModelSerializer):
    player = PlayerSerializer(read_only=True)
    assisting = PlayerSerializer(read_only=True)
    sub_in = PlayerSerializer(read_only=True)
    sub_out = PlayerSerializer(read_only=True)

    class Meta:
        model = MatchEvent
        fields = [
            'id', 'fixture', 'minute', 'event_type',
            'player', 'assisting', 'card_type',
            'sub_in', 'sub_out'
        ]
        read_only_fields = ['id']

    def validate(self, data):
        et = data.get('event_type')
        # enforce presence of subtype fields
        if et == MatchEvent.Action.CARD and not data.get('card_type'):
            raise serializers.ValidationError("`card_type` is required for CARD events")
        if et == MatchEvent.Action.SUBSTITUTION:
            if not data.get('sub_in') or not data.get('sub_out'):
                raise serializers.ValidationError("`sub_in` and `sub_out` are required for SUBSTITUTION")
        return data

class MatchEventSerializer2(serializers.ModelSerializer):
    # player = PlayerSerializer(read_only=True)
    # assisting = PlayerSerializer(read_only=True)
    # sub_in = PlayerSerializer(read_only=True)
    # sub_out = PlayerSerializer(read_only=True)

    class Meta:
        model = MatchEvent
        fields = [
            'id', 'fixture', 'minute', 'event_type',
            'player', 'assisting', 'card_type',
            'sub_in', 'sub_out'
        ]
        read_only_fields = ['id']

    def validate(self, data):
        et = data.get('event_type')
        # enforce presence of subtype fields
        if et == MatchEvent.Action.CARD and not data.get('card_type'):
            raise serializers.ValidationError("`card_type` is required for CARD events")
        if et == MatchEvent.Action.SUBSTITUTION:
            if not data.get('sub_in') or not data.get('sub_out'):
                raise serializers.ValidationError("`sub_in` and `sub_out` are required for SUBSTITUTION")
        return data


class PublicTeamSerializer(serializers.ModelSerializer):
    league_name = serializers.CharField(source='league_id.name', read_only=True)
    
    class Meta:
        model = Team
        fields = ['id', 'name', 'short_name', 'logo_url', 'founded_year', 'league_name']

class PublicPlayerSerializer(serializers.ModelSerializer):
    team_name = serializers.CharField(source='team_id.name', read_only=True)
    team_short_name = serializers.CharField(source='team_id.short_name', read_only=True)
    team_logo = serializers.URLField(source='team_id.logo_url', read_only=True)
    
    class Meta:
        model = Player
        fields = [
            'id',
            'first_name',
            'last_name',
            'position',
            'jersey_no',
            'photo',
            'nationality',
            'dob',
            'height_cm',
            'weight_kg',
            'team_name',
            'team_short_name',
            'team_logo',
        ]
        read_only_fields = fields  # All fields are read-only for public API 

class PublicFixtureSerializer(serializers.ModelSerializer):
    home_team_name = serializers.CharField(source='home_team_id.name', read_only=True)
    away_team_name = serializers.CharField(source='away_team_id.name', read_only=True)
    league_name = serializers.CharField(source='league_id.name', read_only=True)
    
    class Meta:
        model = Fixture
        fields = [
            'id', 'match_datetime', 'venue', 'status',
            'home_team_name', 'away_team_name', 'league_name', 'home_team_score', 'away_team_score'
        ]