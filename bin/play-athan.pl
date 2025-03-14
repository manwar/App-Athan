#!/usr/bin/env perl

use v5.38;
use Time::Piece;
use FFI::Platypus;
use Time::HiRes qw(usleep);
use POSIX qw(strftime setsid);

our $VERBOSE = $ENV{ATHAN_VERBOSE} || 0;

my $TIME = $ARGV[0];
die "Usage: $0 <athan_time_folder> <athan_folder> <mosque_code> <log_folder>\nERROR: Missing athan time foler.\n"
    unless (defined $TIME);

my $ATHAN = $ARGV[1];
die "Usage: $0 <athan_time_folder> <athan_folder> <mosque_code> <log_folder>\nERROR: Missing athan foler.\n"
    unless (defined $ATHAN);

my $MOSQUE = $ARGV[2] || 'hcm';
my $LOG = $ARGV[3] || '/tmp';

my $year_month = localtime->strftime('%Y-%m');
my ($year, $month) = split /\-/, $year_month, 2;

my $TIME_FILE = sprintf("%s/%s-%04d-%02d.txt", $TIME, lc($MOSQUE), $year, $month);
my $LOG_FILE  = sprintf("%s/athan-app.log", $LOG);

log_it(sprintf("Athan app started for [$MOSQUE] @ %s.", current_time()));

$SIG{'TERM'} = $SIG{'HUP'} = $SIG{'INT'} = sub {
    log_it(sprintf("Athan app stopped for [$MOSQUE] @ %s.", current_time())) and exit 0;
};

my %scheduled_times = read_scheduled_times();
while (1) {
    my $current_time = current_time();
    if (exists $scheduled_times{$current_time}) {
        play_athan($scheduled_times{$current_time});
    }
    else {
        log_it("Heartbeat: ". current_time(1)) if $VERBOSE;
    }
    sleep 10;
}

#
#
# METHODS

sub current_time($ss_also=0) {
    my $now = localtime;
    if ($ss_also) {
        return $now->strftime('%Y-%m-%d %I:%M:%S');
    }
    else {
        return $now->strftime('%Y-%m-%d %I:%M');
    }
}

sub read_scheduled_times {
    open(my $fh, '<', $TIME_FILE)
        or die "Could not open file '$TIME_FILE' $!";
    my %scheduled_times;
    while (my $line = <$fh>) {
        chomp($line);
        my ($time, $type) = split /\|/, $line, 2;
        $scheduled_times{$time} = $type;
    }
    close $fh;
    return %scheduled_times;
}

sub log_it($message) {
    open(my $log_fh, '>>', $LOG_FILE)
        or die "Could not open '$LOG_FILE': $!";
    print $log_fh $message, "\n";
    close $log_fh;
}

sub play_athan($type) {

    # Initialize FFI
    my $ffi = FFI::Platypus->new;
    $ffi->lib('/usr/lib/x86_64-linux-gnu/libSDL2.so');
    $ffi->lib('/usr/lib/x86_64-linux-gnu/libSDL2_mixer.so');

    # Define SDL2 and SDL2_mixer functions
    $ffi->attach('SDL_Init' => ['int'] => 'int');
    $ffi->attach('Mix_OpenAudio' => ['int', 'uint16', 'int', 'int'] => 'int');
    $ffi->attach('Mix_LoadMUS' => ['string'] => 'opaque');
    $ffi->attach('Mix_PlayMusic' => ['opaque', 'int'] => 'int');
    $ffi->attach('Mix_PlayingMusic' => [] => 'int');
    $ffi->attach('Mix_HaltMusic' => [] => 'void');
    $ffi->attach('Mix_FreeMusic' => ['opaque'] => 'void');
    $ffi->attach('Mix_CloseAudio' => [] => 'void');
    $ffi->attach('SDL_Quit' => [] => 'void');
    $ffi->attach('SDL_PollEvent' => ['opaque'] => 'int');
    $ffi->attach('SDL_Delay' => ['uint32'] => 'void');

    # Constants
    use constant SDL_INIT_AUDIO => 0x00000010;
    use constant MIX_DEFAULT_FORMAT => 32784;
    use constant MIX_DEFAULT_CHANNELS => 2;
    use constant MIX_DEFAULT_FREQUENCY => 44100;
    use constant SDL_QUIT => 0x100;

    # Initialize SDL and SDL_mixer
    SDL_Init(SDL_INIT_AUDIO);
    Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 20480);

    my $athan_file;
    if (defined $type && ($type eq 'F')) {
        $athan_file = sprintf("%s/fajar-athan.mp3", $ATHAN);
    }
    else {
        $athan_file = sprintf("%s/regular-athan.mp3", $ATHAN);
    }

    # Load the MP3 file
    my $music = Mix_LoadMUS($athan_file);
    die "ERROR: Failed to load $athan_file." unless $music;

    my $message = "Playing athan at " . localtime->strftime('%Y-%m-%d %H:%M') . "\n";
    log_it($message);

    # Play the athan file
    Mix_PlayMusic($music, 0);

    # Wait for the playback to finish
    while (Mix_PlayingMusic()) {
        usleep(50_000);
    }

    # Clean up
    Mix_HaltMusic();
    Mix_FreeMusic($music);
    Mix_CloseAudio();
    SDL_Quit();
}
