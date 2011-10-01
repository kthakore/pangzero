##########################################################################
# CONFIG SAVE/LOAD
##########################################################################

package Games::PangZero::Config;

sub IsMicrosoftWindows {
  return $^O eq 'MSWin32';
}


sub TestDataDir {
  return -f "$Games::PangZero::DataDir/glossyfont.png";   # Should be a file from the latest version.
}

sub FindDataDir {
  return if $Games::PangZero::DataDir and TestDataDir();
  my @guesses = qw( . .. /usr/share/pangzero /usr/share/games/pangzero /usr/local/share/pangzero /opt/pangzero/ /opt/pangzero);
  foreach my $guess (@guesses) {
    $Games::PangZero::DataDir = $guess;
    return if TestDataDir();
    $Games::PangZero::DataDir = "$guess/data";
    return if TestDataDir();
  }
  die "Couldn't find the data directory. Please set it manually.";
}

sub GetConfigFilename {
  if ( IsMicrosoftWindows() ) {
    if ($ENV{USERPROFILE}) {
      return "$ENV{USERPROFILE}\\pangzero.cfg";
    }
    return "$Games::PangZero::DataDir/pangzero.cfg";
  }
  if ($ENV{HOME}) {
    return "$ENV{HOME}/.pangzerorc";
  }
  if (-w $Games::PangZero::DataDir) {
    return "$Games::PangZero::DataDir/pangzero.cfg";
  }
  return "/tmp/pangzero.cfg";
}

sub GetConfigVars {
  my ($i, $j);
  my @result = qw(NumGuys DifficultyLevelIndex WeaponDurationIndex Slippery MusicEnabled SoundEnabled FullScreen ShowWebsite
    DeathBallsEnabled EarthquakeBallsEnabled WaterBallsEnabled SeekerBallsEnabled);
  for ($i=0; $i < scalar @Players; ++$i) {
    for ($j=0; $j < 3; ++$j) {
      push @result, ("Players[$i]->{keys}->[$j]");
    }
    push @result, ("Players[$i]->{colorindex}");
    push @result, ("Players[$i]->{imagefileindex}");
  }
  my ($difficulty, $gameMode);
  for ($difficulty=0; $difficulty < scalar @DifficultyLevels; ++$difficulty) {
    foreach $gameMode ('highScoreTablePan', 'highLevelTablePan', 'highScoreTableCha', 'highLevelTableCha') {
      next if ($Games::PangZero::DifficultyLevels[$difficulty]->{name} eq 'Miki' and $gameMode eq 'highScoreTableCha');
      for ($i=0; $i < 5; ++$i) {
        push @result, "DifficultyLevels[$difficulty]->{$gameMode}->[$i]->[0]", # Name of high score
                      "DifficultyLevels[$difficulty]->{$gameMode}->[$i]->[1]", # High score
      }
    }
  }
  return @result;
}

sub SaveConfig {
  my ($filename, $varname, $value);
  $filename = GetConfigFilename();

  open CONFIG, "> $filename" or return;
  foreach $varname (GetConfigVars()) {
    eval("\$value = \$varname"); die $@ if $@;
    print CONFIG "$varname = $value\n";
  }
  close CONFIG;
}

sub LoadConfig {
  my ($filename, $text, $varname);

  $text = '';
  $filename = GetConfigFilename();
  if (open CONFIG, "$filename") {
    read CONFIG, $text, 16384;
    close CONFIG;
  }
  
  foreach $varname (GetConfigVars()) {
    my $pattern = $varname;
    $pattern =~ s/\[/\\[/g;
    if ($text =~ /$pattern = (.+?)$/m) {
      eval( "\$varname = '$1'" );
    }
  }
  SetDifficultyLevel($Games::PangZero::DifficultyLevelIndex);
  SetWeaponDuration($Games::PangZero::WeaponDurationIndex);
}

sub SetDifficultyLevel {
  my $difficultyLevelIndex = shift;
  if ($difficultyLevelIndex < 0 or $difficultyLevelIndex > $#Games::PangZero::DifficultyLevels) {
    $difficultyLevelIndex = $Games::PangZero::DifficultyLevelIndex;
  }
  $Games::PangZero::DifficultyLevelIndex = $difficultyLevelIndex;
  $Games::PangZero::DifficultyLevel      = $Games::PangZero::DifficultyLevels[$difficultyLevelIndex];
}

sub SetWeaponDuration {
  my $weaponDurationIndex = shift;
  if ($weaponDurationIndex < 0 or $weaponDurationIndex > $#Games::PangZero::WeaponDurations) {
    $weaponDurationIndex = $Games::PangZero::WeaponDurationIndex;
  }
  $Games::PangZero::WeaponDurationIndex = $weaponDurationIndex;
  $Games::PangZero::WeaponDuration      = $Games::PangZero::WeaponDurations[$Games::PangZero::WeaponDurationIndex];
}

1;
