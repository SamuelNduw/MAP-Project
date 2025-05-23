from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.viewsets import GenericViewSet
from rest_framework.mixins import (
    RetrieveModelMixin,
    ListModelMixin,
    CreateModelMixin,
    UpdateModelMixin,
    DestroyModelMixin
)
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import *
from .models import *
from .permissions import IsAdmin, IsReadOnly
from rest_framework.viewsets import ReadOnlyModelViewSet

from rest_framework.filters import SearchFilter, OrderingFilter
from django_filters.rest_framework import DjangoFilterBackend

from rest_framework.decorators import authentication_classes, permission_classes, action
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication

class RegisterView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            refresh = RefreshToken.for_user(user)
            return Response({
                'user': serializer.data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
    
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
class ProtectedView(APIView):
    def get(self, request):
        return Response({"message": "This is a protected view!"})
    

class AdminOnlyViewSet(
    CreateModelMixin,
    RetrieveModelMixin,
    UpdateModelMixin,
    DestroyModelMixin,
    ListModelMixin,
    GenericViewSet
):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAdmin]

class ReadOnlyViewSet(
    RetrieveModelMixin,
    ListModelMixin,
    GenericViewSet
):
    permission_classes = [IsReadOnly]


class LeagueViewSet(AdminOnlyViewSet):
    queryset = League.objects.all()
    serializer_class = LeagueSerializer

class TeamViewSet(AdminOnlyViewSet):
    queryset = Team.objects.all()
    serializer_class = TeamSerializer

class PlayerViewSet(AdminOnlyViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer
    permission_classes = [IsAdmin]

    filter_backends = [DjangoFilterBackend]
    filterset_fields = {
        'team_id': ['exact'],
    }

class ManagerViewSet(ReadOnlyViewSet):
    queryset = Manager.objects.all()
    serializer_class = ManagerSerializer
    permission_classes = [IsAdmin]

class StaffViewSet(ReadOnlyViewSet):
    queryset = Staff.objects.all()
    serializer_class = StaffSerializer
    permission_classes = [IsAdmin]

class FixtureViewSet(AdminOnlyViewSet):
    queryset = Fixture.objects.all().select_related(
        'home_team_id', 'away_team_id', 'league_id', 'victor'
    )
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = {
        'league_id': ['exact'],
        'status': ['exact'],
        'match_datetime': ['exact', 'gte', 'lte'],
        'home_team_id': ['exact'],
        'away_team_id': ['exact'],
    }
    search_fields = ['home_team_id__name', 'away_team_id__name', 'venue']
    ordering_fields = ['match_datetime', 'league_id__name']
    ordering = ['match_datetime']

    def get_serializer_class(self):
        if self.action == 'list':
            return DetailedFixtureSerializer
        if self.action == 'retrieve':
            return DetailedFixtureSerializer
        if self.action == 'create':
            return CreateFixtureSerializer
        if self.action == 'update' or self.action == 'partial_update':
            return UpdateFixtureSerializer
        return DetailedFixtureSerializer

    @action(detail=True, methods=['post'])
    def update_score(self, request, pk=None):
        fixture = self.get_object()
        serializer = UpdateFixtureSerializer(fixture, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.UPCOMING)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def live(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.LIVE)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def finished(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.FINISHED)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

class PublicFixtureViewSet(ReadOnlyViewSet):
    queryset = Fixture.objects.all().select_related(
        'home_team_id', 'away_team_id', 'league_id', 'victor',
    ).prefetch_related('matchevent_set')
    
    def get_serializer_class(self):
        # if self.action == 'retrieve':
            return PublicFixtureDetailSerializer
        # return PublicFixtureSerializer
    
    # Keep all the existing filter and action methods
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = {
        'league_id': ['exact'],
        'status': ['exact'],
        'match_datetime': ['exact', 'gte', 'lte'],
    }
    search_fields = ['home_team_id__name', 'away_team_id__name', 'venue']
    ordering_fields = ['match_datetime']
    ordering = ['match_datetime']

    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.UPCOMING)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def live(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.LIVE)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def finished(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.FINISHED)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

class SimpleFixtureViewSet(ReadOnlyModelViewSet):
    """
    A simple viewset for viewing fixtures with basic information including scores.
    Uses PublicFixtureSerializer for all actions.
    """
    queryset = Fixture.objects.all().select_related(
        'home_team_id', 'away_team_id', 'league_id'
    )
    serializer_class = SimpleFixtureSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = {
        'league_id': ['exact'],
        'status': ['exact'],
        'match_datetime': ['exact', 'gte', 'lte'],
    }
    search_fields = ['home_team_id__name', 'away_team_id__name', 'venue']
    ordering_fields = ['match_datetime']
    ordering = ['match_datetime']

    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.UPCOMING)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def live(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.LIVE)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)

    @action(detail=False, methods=['get'])
    def finished(self, request):
        queryset = self.filter_queryset(
            self.get_queryset().filter(status=Fixture.Status.FINISHED)
        )
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(page, many=True)
        return self.get_paginated_response(serializer.data)
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
class MatchEventViewSet(AdminOnlyViewSet):
    queryset = MatchEvent.objects.all().select_related(
        'fixture', 'player', 'assisting', 'sub_in', 'sub_out'
    )
    serializer_class = MatchEventSerializer2

    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['fixture', 'event_type', 'player']

class PublicMatchEventViewSet(ReadOnlyViewSet):
    queryset = MatchEvent.objects.all().select_related(
        'fixture', 'player', 'assisting', 'sub_in', 'sub_out'
    )
    serializer_class = MatchEventSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['fixture', 'event_type', 'player']

class PublicLeagueViewSet(ReadOnlyViewSet):
    queryset = League.objects.all()
    serializer_class = LeagueSerializer
    # Add any filters for public view
    filterset_fields = ['status']

class PublicTeamViewSet(ReadOnlyViewSet):
    queryset = Team.objects.all()
    serializer_class = PublicTeamSerializer

class PublicPlayerViewSet(ReadOnlyViewSet):
    """
    Public read-only viewset for player data with filtering and search capabilities.
    """
    queryset = Player.objects.all().select_related('team_id')
    serializer_class = PublicPlayerSerializer
    
    # Add filtering, searching, and ordering capabilities
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = {
        'team_id': ['exact'],
        'position': ['exact'],
        'jersey_no': ['exact', 'gte', 'lte'],
    }
    search_fields = [
        'first_name',
        'last_name',
        'team_id__name',
        'team_id__short_name',
        'nationality',
    ]
    ordering_fields = [
        'last_name',
        'first_name',
        'jersey_no',
        'team_id__name',
    ]
    ordering = ['last_name']  # Default ordering

    @action(detail=False, methods=['get'])
    def by_team(self, request):
        """
        Custom endpoint to get players grouped by team
        """
        team_id = request.query_params.get('team_id')
        if not team_id:
            return Response(
                {'error': 'team_id parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            players = self.get_queryset().filter(team_id=team_id)
            serializer = self.get_serializer(players, many=True)
            return Response(serializer.data)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

@authentication_classes([JWTAuthentication])
@permission_classes([IsAdmin])
class AddTeamToLeagueView(APIView):
    def post(self, request):
        serializer = LeagueTeamSerializer(data=request.data)
        if serializer.is_valid():
            # Check if the team is already in the league
            league_id = serializer.validated_data['league'].id
            team_id = serializer.validated_data['team'].id
            if LeagueTeam.objects.filter(league_id=league_id, team_id=team_id).exists():
                return Response(
                    {'error': 'This team is already in the league'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)