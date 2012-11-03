##########################################################################
package Games::PangZero::ChallengeGame;
##########################################################################

@ISA = qw(Games::PangZero::PlayableGameBase);
use strict;
use warnings;

sub new {
  my ($class) = @_;
  my $self = Games::PangZero::PlayableGameBase->new();
  %{$self} = (%{$self},
    'challenge' => undef,
  );
  bless $self, $class;
}

sub SetGameLevel {
  my ($self, $level) = @_;

  Games::PangZero::SlowEffect::RemoveSlowEffects();
  $self->SUPER::SetGameLevel($level);
  $level             = $#Games::PangZero::ChallengeLevels if $level > $#Games::PangZero::ChallengeLevels;
  $self->{challenge} = $Games::PangZero::ChallengeLevels[$level];
  die unless $self->{challenge};
  $self->SpawnChallenge();
}

sub AdvanceGame {
  my ($self) = @_;

  if ($self->{nextlevel}) {
    Games::PangZero::Music::PlaySound('level');
    $self->SetGameLevel($self->{level} + 1);
    delete $self->{nextlevel};
  }
  if ($self->{playerspawned}) {
    $self->SpawnChallenge();
    $self->{playerspawned} = 0;
  }
  $self->SUPER::AdvanceGame();
}

sub SpawnChallenge {
  my $self = shift;
  my ($challenge, @guys, $balldesc, $ball, $hasBonus, %balls, $numBalls, $ballsSpawned, @ballKeys, $x);

  @guys = $self->PopEveryBall();
  foreach (@guys) {
    $_->{bonusDelay} = 1;
    $_->{invincible} = 1;
  }
  $Games::PangZero::GamePause = 0;
  delete $Games::PangZero::GameEvents{magic};
  $challenge = $self->{challenge};
  die unless $challenge;

  while ($challenge =~ /(\w+)/g) {
    $balldesc = $Games::PangZero::BallDesc{$1};
    warn "Unknown ball in challenge: $1" unless $balldesc;
    $balls{$1}++;
    $numBalls++;
  }
  $ballsSpawned = 0;
  while ($ballsSpawned < $numBalls) {
    foreach (keys %balls) {
      next unless $balls{$_};
      --$balls{$_};
      $balldesc = $Games::PangZero::BallDesc{$_};
      $x = $Games::PangZero::ScreenWidth * ($ballsSpawned * 2 + 1) / ($numBalls * 2) - $balldesc->{width} / 2;
      $x = $Games::PangZero::ScreenWidth - $balldesc->{width} if $x > $Games::PangZero::ScreenWidth - $balldesc->{width};
      $hasBonus = (($balldesc->{width} >= 32) and ($self->Rand(1) < $Games::PangZero::DifficultyLevel->{bonusprobability}));
      $ball = &Games::PangZero::Ball::Spawn($balldesc, $x, ($ballsSpawned % 2) ? 0 : 1, $hasBonus);
      if ($ball->{w} <= 32) {
        $ball->{ismagic} = $ball->{hasmagic} = 0;
      }
      push @Games::PangZero::GameObjects, ($ball) ;
      ++$ballsSpawned;
    }
  }
}

sub OnBallPopped {
  my $self = shift;
  my ($i);

  for ($i = $#Games::PangZero::GameObjects; $i >= 0; --$i) {
    if ($Games::PangZero::GameObjects[$i]->isa('Games::PangZero::Ball')) {
      return;
    }
  }
  $self->{nextlevel} = 1;
}

1;
