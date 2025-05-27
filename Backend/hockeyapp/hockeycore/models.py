from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from django.contrib.auth.hashers import make_password

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

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
    teams = models.ManyToManyField('Team', through='LeagueTeam', related_name='leagues')

    def __str__(self):
        return f"{self.name} {self.season}"

class Team(models.Model):
    name = models.CharField(max_length=100)
    short_name = models.CharField(max_length=10)
    logo_url = models.URLField(blank=True)
    founded_year = models.IntegerField()
    manager = models.OneToOneField(
        'Manager',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='managed_team'
    )

    def __str__(self):
        return self.name
    
class LeagueTeam(models.Model):
    league = models.ForeignKey(League, on_delete=models.CASCADE)
    team = models.ForeignKey(Team, on_delete=models.CASCADE)
    date_joined = models.DateField(auto_now_add=True)

    class Meta:
        unique_together = ('league', 'team')

    def __str__(self):
        return f"{self.team} in {self.league}"

class Manager(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(unique=True, blank=True, null=True)
    photo = models.URLField(blank=True, default="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")

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
    position = models.CharField(max_length=2, choices=Position.choices, blank=True, null=True)
    jersey_no = models.IntegerField(blank=True, null=True)
    nationality = models.CharField(max_length=100)
    height_cm = models.IntegerField(blank=True, null=True)
    weight_kg = models.IntegerField(blank=True, null=True)
    photo = models.URLField(blank=True, default="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
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
    home_team_score = models.PositiveSmallIntegerField(null=True, blank=True, default=0)
    away_team_score = models.PositiveSmallIntegerField(null=True, blank=True, default=0)
    victor = models.ForeignKey(
        Team,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='won_fixtures'
    )

    def __str__(self):
        return f"{self.home_team_id} vs {self.away_team_id}"


    @property
    def is_draw(self):
        return (self.home_team_score is not None and 
                self.away_team_score is not None and 
                self.home_team_score == self.away_team_score)

    @property
    def score_display(self):
        if self.home_team_score is not None and self.away_team_score is not None:
            return f"{self.home_team_score}-{self.away_team_score}"
        return "TBD"
    
    def save(self, *args, **kwargs):
        # Get the previous state if this is an update
        old_instance = None
        if self.pk:
            old_instance = Fixture.objects.get(pk=self.pk)

        # Check if score changed
        score_changed = self.pk is not None and (
            Fixture.objects.filter(pk=self.pk)
            .exclude(home_team_score=self.home_team_score, away_team_score=self.away_team_score)
            .exists()
        )

        # Check if status has changed
        status_changed = self.pk is not None and (
            Fixture.objects.filter(pk=self.pk)
            .exclude(status=self.status)
            .exists()
        )

        # Check if status has changed to FINISHED
        status_changed_to_finished = (
            old_instance and old_instance != self.status and self.status == self.Status.FINISHED
        )

        # Automatically set victor when scores are updated
        if self.home_team_score is not None and self.away_team_score is not None:
            if self.home_team_score > self.away_team_score:
                self.victor = self.home_team_id
            elif self.home_team_score < self.away_team_score:
                self.victor = self.away_team_id
            else:
                self.victor = None
        super().save(*args, **kwargs)

        # Calculate league standings if:
        # 1. The match was just marked as FINISIHED, or
        # 2. Scores were updated on a FINSIHED match
        if (status_changed_to_finished or (self.status == self.Status.FINISHED and score_changed)):
            self.calculate_league_standings()

        # Notify group if score or status changed
        if score_changed or status_changed:
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f"live_match_{self.id}",
                {
                    "type": "match_update",
                    "data": {
                        "score": self.score_display,
                        "status": self.status,
                    }
                }
            )

    def calculate_league_standings(self):
        """
        Calculate and update league standings for all teams in this fixture's league
        after this match is finished.
        """
        if self.status != self.Status.FINISHED:
            return

        league = self.league_id
        
        # Get all teams in this league through LeagueTeam
        teams_in_league = LeagueTeam.objects.filter(league=league).select_related('team')
        
        # Create a set of team IDs for quick lookup
        league_team_ids = {lt.team.id for lt in teams_in_league}
        
        # Initialize standings dictionary with all teams in the league
        standings = {}
        for lt in teams_in_league:
            standings[lt.team.id] = {  # Using team ID as key for consistency
                'team': lt.team,       # Store the team object
                'played': 0,
                'wins': 0,
                'draws': 0,
                'losses': 0,
                'goals_for': 0,
                'goals_against': 0,
                'points': 0,
            }

        # Get all finished matches in this league
        finished_matches = Fixture.objects.filter(
            league_id=league,
            status=self.Status.FINISHED,
            home_team_score__isnull=False,
            away_team_score__isnull=False
        )

        # Process all matches to calculate standings
        for match in finished_matches:
            home_team = match.home_team_id
            away_team = match.away_team_id
            home_score = match.home_team_score or 0
            away_score = match.away_team_score or 0

            # Only process matches where both teams are in the league
            if home_team.id not in league_team_ids or away_team.id not in league_team_ids:
                continue

            # Update home team stats
            standings[home_team.id]['played'] += 1
            standings[home_team.id]['goals_for'] += home_score
            standings[home_team.id]['goals_against'] += away_score

            # Update away team stats
            standings[away_team.id]['played'] += 1
            standings[away_team.id]['goals_for'] += away_score
            standings[away_team.id]['goals_against'] += home_score

            # Update wins/draws/losses and points
            if home_score > away_score:
                standings[home_team.id]['wins'] += 1
                standings[home_team.id]['points'] += 3
                standings[away_team.id]['losses'] += 1
            elif home_score < away_score:
                standings[away_team.id]['wins'] += 1
                standings[away_team.id]['points'] += 3
                standings[home_team.id]['losses'] += 1
            else:  # draw
                standings[home_team.id]['draws'] += 1
                standings[home_team.id]['points'] += 1
                standings[away_team.id]['draws'] += 1
                standings[away_team.id]['points'] += 1

        # Convert standings to a list and sort by points, goal difference, etc.
        sorted_standings = sorted(
            standings.values(),  # We already have the team objects stored
            key=lambda x: (
                -x['points'],  # Higher points first
                -(x['goals_for'] - x['goals_against']),  # Better GD first
                -x['goals_for'],  # More goals for first
                x['team'].name  # Alphabetical as tiebreaker
            )
        )

        # Update or create LeagueStanding records
        for position, stats in enumerate(sorted_standings, start=1):
            LeagueStanding.objects.update_or_create(
                league_id=league,
                team_id=stats['team'],
                defaults={
                    'played': stats['played'],
                    'wins': stats['wins'],
                    'draws': stats['draws'],
                    'losses': stats['losses'],
                    'goals_for': stats['goals_for'],
                    'goals_against': stats['goals_against'],
                    'points': stats['points'],
                    'position': position,
                }
            )

class MatchEvent(models.Model):
    class Action(models.TextChoices):
        GOAL = 'goal', 'Goal'
        CARD = 'card', 'Card'
        SUBSTITUTION = 'substitution', 'Substitution'
        INJURY = 'injury', 'Injury'

        PERIOD_END = 'period_end', 'Period End'
        SHOT = 'shot', 'Shot'
        PENALTY = 'penalty', 'Penalty'

    fixture = models.ForeignKey(Fixture, on_delete=models.CASCADE)
    minute = models.PositiveSmallIntegerField()
    event_type = models.CharField(
        max_length=12,
        choices=Action.choices,
    )
    player = models.ForeignKey(Player, on_delete=models.CASCADE)
    assisting = models.ForeignKey(
        Player, 
        on_delete=models.SET_NULL, 
        null=True, blank=True, 
        related_name='assists')
    card_type = models.CharField(
        max_length=6,
        choices=[('green', 'Green'), ('yellow', 'Yellow'), ('red', 'Red')],
        null=True, blank=True)
    sub_in = models.ForeignKey(
        Player, on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='sub_in_events'
    )
    sub_out = models.ForeignKey(
        Player, on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='sub_out_events'
    )

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)

        # Notify the WS group of the new/updated event
        channel_layer = get_channel_layer()
        payload = {
            'event_type': self.event_type,
            'minute':      self.minute,
            # team inferred from player.team_id
            'team':        {
                'id': self.player.team_id.id,
                'name': self.player.team_id.name
            },
            'player': {
                'id':   self.player.id,
                'name': f"{self.player.first_name} {self.player.last_name}"
            },
            'time': self.minute,
        }
        
        if self.event_type == MatchEvent.Action.GOAL:
            payload.update({
                'assistant': (
                    { 'id': self.assisting.id,
                      'name': f"{self.assisting.first_name} {self.assisting.last_name}" }
                    if self.assisting else None
                )
            })
        elif self.event_type == MatchEvent.Action.CARD:
            payload['card_type'] = self.card_type
        elif self.event_type == MatchEvent.Action.SUBSTITUTION:
            payload.update({
                'player_in':  {'id': self.sub_in.id,  'name': f"{self.sub_in.first_name} {self.sub_in.last_name}"},
                'player_out': {'id': self.sub_out.id, 'name': f"{self.sub_out.first_name} {self.sub_out.last_name}"}
            })
        # injury needs no extras beyond player/time

        async_to_sync(channel_layer.group_send)(
            f"live_match_{self.fixture.id}",
            {
                "type": "match_event",  
                "data": payload
            }
        )
    
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