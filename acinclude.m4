AC_DEFUN(UPI_CHECK_SDL_PERL,[
  AC_MSG_CHECKING(for SDL_perl 1.20.0 or later)
  if ! perl -e 'use SDL'; then echo -e "\n    *** I need perl-SDL installed"; exit; fi
  if ! perl -e 'use SDL; ($mj, $mn, $mc) = split /\./, $SDL::VERSION; exit 1 if $mj<1 || $mj ==1 && $mn<20'; then echo -e "\n    *** I need perl-SDL version 1.20.0 or later"; exit; fi
  AC_MSG_RESULT(yes)
])
