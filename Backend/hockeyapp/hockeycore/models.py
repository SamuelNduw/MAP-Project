from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.contrib.auth.hashers import make_password

class UserManager(BaseUserManager):
    def create_user(self, email, full_name, password=None, role='FAN'):
        if not email:
            raise ValueError("Users must have an email address")
        
        email = self.normalize_email(email)
        user = self.model(email=email, full_name=full_name, role=role)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, full_name, password=None):
        user = self.create_user(email, full_name, password, role='ADMIN')
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user
    
class User(AbstractBaseUser, PermissionsMixin):
    class Role(models.TextChoices):
        ADMIN = 'ADMIN'
        MANAGER = 'MANAGER'
        STAFF = 'STAFF'
        FAN = 'FAN'

    user_id = models.AutoField(primary_key=True)
    email = models.EmailField(unique=True, verbose_name='email address')
    full_name = models.CharField(max_length=100)
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.FAN)
    created_at = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']

    def __str__(self):
        return self.email

    @property
    def is_admin(self):
        return self.role == self.Role.ADMIN or self.is_superuser

    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'

class League(models.Model):
    class Status(models.TextChoices):
        SCHEDULED = 'SCHEDULED'
        RUNNING = 'RUNNING'
        COMPLETED = 'COMPLETED'

    name = models.CharField(max_length=100)
    season = models.CharField(max_length=10)
    start_date = models.DateField()
    end_date = models.DateField()
    status = models.CharField(max_length=10, choices=Status.choices, default= Status.SCHEDULED)

    def __str__(self):
        return f"{self.name} {self.season}"

class Team(models.Model):
    name = models.CharField(max_length=100)
    short_name = models.CharField(max_length=10)
    logo_url = models.URLField(blank=True)
    founded_year = models.IntegerField()
    league_id = models.ForeignKey(League, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

class Manager(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(unique=True)
    team_id = models.ForeignKey(Team, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class Staff(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    role_title = models.CharField(max_length=100)
    team_id = models.ForeignKey(Team, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.role_title})"

class Player(models.Model):
    class Position(models.TextChoices):
        GOALKEEPER = 'GK', 'Goalkeeper'
        DEFENDER = 'D', 'Defender'
        MIDFIELDER = 'M', 'Midfielder'
        FORWARD = 'F', 'Forward'

    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    dob = models.DateField()
    position = models.CharField(max_length=2, choices=Position.choices)
    jersey_no = models.IntegerField()
    nationality = models.CharField(max_length=100)
    height_cm = models.IntegerField()
    weight_kg = models.IntegerField()
    team_id = models.ForeignKey(Team, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class Fixture(models.Model):
    class Status(models.TextChoices):
        UPCOMING = 'UPCOMING'
        LIVE = 'LIVE'
        FINISHED = 'FINISHED'

    match_datetime = models.DateField()
    venue = models.CharField(max_length=100)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.UPCOMING)
    league_id = models.ForeignKey(League, on_delete=models.CASCADE)
    home_team_id = models.ForeignKey(Team, on_delete=models.CASCADE, related_name='home_fixtures')
    away_team_id = models.ForeignKey(Team, on_delete=models.CASCADE, related_name='away_fixtures')

    def __str__(self):
        return f"{self.home_team_id} vs {self.away_team_id}"

class MatchEvent(models.Model):
    class Action(models.TextChoices):
        GOAL = 'goal', 'Goal'
        CARD = 'card', 'Card'
        PERIOD_END = 'period_end', 'Period End'
        SHOT = 'shot', 'Shot'
        PENALTY = 'penalty', 'Penalty'

    fixture_id = models.ForeignKey(Fixture, on_delete=models.CASCADE)
    minute = models.IntegerField()
    event_type = models.CharField(
        max_length=10,
        choices=Action.choices,
    )
    player_id = models.ForeignKey(Player, on_delete=models.CASCADE)
    assisting_player_id = models.ForeignKey(Player, on_delete=models.SET_NULL, null=True, blank=True, related_name='assists')

    def __str__(self):
        return f"{self.player_id} - {self.event_type} at {self.minute}'"

class PlayerStat(models.Model):
    player_id = models.ForeignKey(Player, on_delete=models.CASCADE) 
    fixture_id = models.ForeignKey(Fixture, on_delete=models.CASCADE) 
    goals = models.IntegerField(default=0)
    assists = models.IntegerField(default=0)
    minutes_played = models.IntegerField(default=0)
    penalties_minutes = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.player_id} stats for {self.fixture_id}"

class LeagueStanding(models.Model):
    league_id = models.ForeignKey(League, on_delete=models.CASCADE)
    team_id = models.ForeignKey(Team, on_delete=models.CASCADE) 
    played = models.IntegerField(default=0)
    wins = models.IntegerField(default=0)
    draws = models.IntegerField(default=0)
    losses = models.IntegerField(default=0)
    goals_for = models.IntegerField(default=0)
    goals_against = models.IntegerField(default=0)
    points = models.IntegerField(default=0)
    position = models.IntegerField()

    def __str__(self):
        return f"{self.team_id} - Position {self.position}"

    class Meta:
        ordering = ['position']