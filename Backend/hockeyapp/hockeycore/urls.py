from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenRefreshView
)
from rest_framework import routers
from .views import *

router = routers.DefaultRouter()
# Admin enpoints
router.register(r'admin/leagues', LeagueViewSet)
router.register(r'admin/teams', TeamViewSet)
router.register(r'admin/players', PlayerViewSet)
router.register(r'admin/managers', ManagerViewSet)
router.register(r'admin/staff', StaffViewSet)
router.register(r'admin/fixtures', FixtureViewSet)

# Public read-only endpoints
router.register(r'publicleagues', PublicLeagueViewSet, basename='publicleagues')
router.register(r'publicteams', PublicTeamViewSet, basename='publicteams')


urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('protected/', ProtectedView.as_view(), name='protected_view'),
    path('', include(router.urls)),
]