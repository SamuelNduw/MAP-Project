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

from rest_framework.decorators import authentication_classes, permission_classes
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

# class LoginView(APIView):
#     def post(self, request):
#         email = request.data.get('email')
#         password = request.data.get('password')

#         user = User.objects.filter(email=email).first()

#         if user is None or not user.check_password(password):
#             return Response(
#                 {'error': 'Invalid credentials'},
#                 status=status.HTTP_401_UNAUTHORIZED
#             )
#         refresh = RefreshToken.for_user(user)
#         return Response({
#             'email': user.email,
#             'access': str(refresh.access_token),
#             'refresh': str(refresh),
#         })

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

class PlayerViewSet(ReadOnlyViewSet):
    queryset = Player.objects.all()
    serializer_class = PlayerSerializer
    permission_classes = [IsAdmin]

class ManagerViewSet(ReadOnlyViewSet):
    queryset = Manager.objects.all()
    serializer_class = ManagerSerializer
    permission_classes = [IsAdmin]

class StaffViewSet(ReadOnlyViewSet):
    queryset = Staff.objects.all()
    serializer_class = StaffSerializer
    permission_classes = [IsAdmin]

class FixtureViewSet(ReadOnlyViewSet):
    queryset = Fixture.objects.all()
    serializer_class = FixtureSerializer
    permission_classes = [IsAdmin]

class PublicLeagueViewSet(ReadOnlyViewSet):
    queryset = League.objects.all()
    serializer_class = LeagueSerializer
    # Add any filters for public view
    filterset_fields = ['status']

class PublicTeamViewSet(ReadOnlyViewSet):
    queryset = Team.objects.all()
    serializer_class = PublicTeamSerializer

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