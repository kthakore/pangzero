package Games::PangZero::Music;

use SDL::Mixer ':init';
use SDL::Mixer::Samples;
use SDL::Mixer::Channels;
use SDL::Mixer::Music;
use SDL::Mixer::MixChunk;
use SDL::Mixer::MixMusic;

sub LoadMusic {
  my ($filename) = @_;
  
  return undef unless -f $filename;
  return SDL::Mixer::Music::load_MUS($filename);
}

sub LoadSounds {
  my $init_flags = SDL::Mixer::init( MIX_INIT_MP3 | MIX_INIT_OGG);

  $Mixer = SDL::Mixer::open_audio( 22050, AUDIO_S16, 2, 1024 ) + 1;
  unless($Mixer) {
    warn SDL::get_error();
    return 0;
  }

  my ($soundName, $fileName);
  while (($soundName, $fileName) = each %Games::PangZero::Sounds) {
    $Sounds{$soundName} = SDL::Mixer::Samples::load_WAV("$Games::PangZero::DataDir/$fileName");
  }

  if (-f "$Games::PangZero::DataDir/UPiPang.mp3" && ($init_flags & MIX_INIT_MP3)) {
      $Games::PangZero::music = LoadMusic("$Games::PangZero::DataDir/UPiPang.mp3");
  } elsif (-f "$Games::PangZero::DataDir/UPiPang.ogg" && ($init_flags & MIX_INIT_OGG)) {
      $Games::PangZero::music = LoadMusic("$Games::PangZero::DataDir/UPiPang.ogg");
  } else {
      $Games::PangZero::music = LoadMusic("$Games::PangZero::DataDir/UPiPang.mid");
  }
  SetMusicEnabled($Games::PangZero::MusicEnabled);
}

sub PlaySound {
  return unless $Games::PangZero::SoundEnabled;
  my $sound = shift;
  $Mixer and $Sounds{$sound} and SDL::Mixer::Channels::play_channel( -1, $Sounds{$sound}, 0 );
}

sub SetMusicEnabled {
  return $Games::PangZero::MusicEnabled = 0 unless $Games::PangZero::music;
  my $musicEnabled = shift;

  $Games::PangZero::MusicEnabled = $musicEnabled ? 1 : 0;
  if ( (not $musicEnabled) and SDL::Mixer::Music::playing_music() ) {
    SDL::Mixer::Music::halt_music();
  }
  if ($musicEnabled and not SDL::Mixer::Music::playing_music()) {
    SDL::Mixer::Music::play_music($Games::PangZero::music, -1);
  }
}

1;
