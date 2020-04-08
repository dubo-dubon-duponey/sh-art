#!/usr/bin/env bash
##########################################################################
# Trap
# ------
# Error handling
##########################################################################

# Bash reserved exit codes

#1	Catchall for general errors	let "var1 = 1/0"	Miscellaneous errors, such as "divide by zero" and other impermissible operations
#2	Misuse of shell builtins (according to Bash documentation)	empty_function() {}	Missing keyword or command, or permission problem (and diff return code on a failed binary file comparison).
#126	Command invoked cannot execute	/dev/null	Permission problem or command is not an executable
#127	"command not found"	illegal_command	Possible problem with $PATH or a typo
#128	Invalid argument to exit	exit 3.14159	exit takes only integer args in the range 0 - 255 (see first footnote)
#128+n	Fatal error signal "n"	kill -9 $PPID of script	$? returns 137 (128 + 9)
#130	Script terminated by Control-C	Ctl-C	Control-C is fatal error signal 2, (130 = 128 + 2, see above)
#255*	Exit status out of range	exit -1	exit takes only integer args in the range 0 - 255

# Signals

#0	0	On exit from shell
#1	SIGHUP	Clean tidyup
#2	SIGINT	Interrupt
#3	SIGQUIT	Quit
#6	SIGABRT	Abort
#9	SIGKILL	Die Now (cannot be trapped)
#14	SIGALRM	Alarm Clock
#15	SIGTERM	Terminate

# Important...
# Basically, sending a signal manually, bash will wait for the current command to return (also a direct CTRL+C will not kill subprocesses...)
# https://apple.stackexchange.com/questions/123631/why-does-a-shell-script-trapping-sigterm-work-when-run-manually-but-not-when-ru

# $$ to get the current process pid btw
# $! to get the pid of the process that just launched
# otherwise pid="$(ps -fu "$USER" | grep "whatever" | grep -v "grep" | awk '{print $2}')" <- this sucks big time

# XXX none of this checks arguments

_DC_PRIVATE_TRAP_NO_TERM=

_DC_PRIVATE_TRAP_CLEAN=()

_DC_PRIVATE_SIGNALS=("" "SIGHUP" "SIGINT" "SIGQUIT" "" "" "SIGABRT" "" "" "SIGKILL" "" "" "" "" "SIGALRM" "SIGTERM")

_dc::private::trap::signal() {
  # Drop the line number, it's always 1 with signals
  local _="${1:-}"
  local ex="${2:-1}" # In case all turns to shit, fallback to exit 1
  local idx

  idx=$(( ex - 128 ))
  dc::logger::debug "[SIGNAL TRAPPING] Error at line ${1:-}"
  dc::logger::debug "[SIGNAL TRAPPING] Exit: ${2:-}"
  dc::logger::debug "[SIGNAL TRAPPING] Command was: ${3:-}"
  dc::logger::debug "[SIGNAL TRAPPING] Signal $idx (${_DC_PRIVATE_SIGNALS[idx]})" || true
  exit "$ex"
}

# Trap signals
# Unfortunately, manually sent signals do not forward the exit code for some reason, hence the separate trap declarations
_dc::private::trap::signal::HUP(){
  _dc::private::trap::signal "$1" 129 "$3"
}

_dc::private::trap::signal::INT(){
  _dc::private::trap::signal "$1" 130 "$3"
}

_dc::private::trap::signal::QUIT(){
  _dc::private::trap::signal "$1" 131 "$3"
}

_dc::private::trap::signal::ABRT(){
  _dc::private::trap::signal "$1" 134 "$3"
}

_dc::private::trap::signal::KILL(){
  _dc::private::trap::signal "$1" 137 "$3"
}

_dc::private::trap::signal::ALRM(){
  _dc::private::trap::signal "$1" 142 "$3"
}

_dc::private::trap::signal::TERM(){
  [ "$_DC_PRIVATE_TRAP_NO_TERM" ] && return
  _dc::private::trap::signal "$1" 143 "$3"
}

# Trap exit for the actual cleanup
_dc::private::trap::exit() {
  local lineno="${1:-}"
  local ex="${2:-}"
  local com="${3:-}"
  local i

  if [ "$ex" == 0 ]; then
    dc::logger::debug "[EXIT TRAPPING] Exiting normally"
    return
  fi

  # dc::logger::debug "Error!"
  # XXX should kill possible subprocesses hanging around
  # This would SIGTERM the process group (unfortunately means we would catch it again
  # Prevent re-entrancy with SIGTERM
  #sleep 10 &
  # _DC_PRIVATE_TRAP_NO_TERM=true
  # kill -TERM -$$
  dc::logger::debug "[EXIT TRAPPING] Error at line ${1:-}"
  dc::logger::debug "[EXIT TRAPPING] Exit: ${2:-}"
  dc::logger::debug "[EXIT TRAPPING] Command was: ${3:-}"

  for i in "${_DC_PRIVATE_TRAP_CLEAN[@]}"; do
    dc::logger::debug "[EXIT TRAPPING] Calling clean-up routine: $i"
    "$i" "$ex" "$(dc::error::detail::get)" "$com" "$lineno"
  done

  exit "$ex"
}

_dc::private::trap::err() {
  dc::logger::debug "[ERROR TRAPPING] Error at line ${1:-}"
  dc::logger::debug "[ERROR TRAPPING] Exit: ${2:-}"
  dc::logger::debug "[ERROR TRAPPING] Command was: ${3:-}"
  exit "${2:-}"
}

# experimenting with: code="$(cat -n "$0" |  grep -E "^\s+$lineno\s")" || true
