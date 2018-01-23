#!/bin/bash
# Constants
# ==============

NM_PROG=$(basename $0)
DR_PROG=$(dirname $0)
isabs=$(echo $DR_PROG | grep ^/)
if [ -z "$isabs" ] ; then 
	DR_PROG="$PWD/$DR_PROG"
fi
YES=yes
DEBUG=0
DR_WORK=
IF_METABOLOME=
IF_INDEX=
OF_STOCSYCORR=
VER="0.1.1"

function print_help {
	echo "Usage: $NM_PROG [options] directory"
	echo
	echo "STOCSY"
	echo
	echo "Options:"
	echo "   -g, --debug              Debug mode."
	echo "   -h, --help               Print this help message."
	echo "   -i, --input-file         Set input file."
	echo "   -x, --index              Set index file."
	echo "   -o, --output-file        Set output file."
}
# Error {{{1
# ==========

function error {

	local msg=$1

	echo "ERROR: $msg" >&2

	exit 1
}

# Print debug msg {{{1
# ====================

function print_debug_msg {

	local dbglvl=$1
	local dbgmsg=$2

	[ $DEBUG -ge $dbglvl ] && echo "[DEBUG] $dbgmsg" >&2
}
# Get opt val {{{1
# ================

function get_opt_val {
	[ -n "$2" ] || error "\"$1\" requires a non-empty option argument."
	echo $2
}
# Read args {{{1
# ==============

function read_args {

	local args="$*" # save arguments for debugging purpose
	
	# Read options
	while true ; do
		shift_count=1
		case $1 in
			-g|--debug)                  DEBUG=$((DEBUG + 1)) ;;
			-h|--help)                   print_help ; exit 0 ;;
			-i|--input-file)             IF_METABOLOME=$(get_opt_val $1 $2) ; shift_count=2 ;;
			-x|--input-index)            IF_INDEX=$(get_opt_val $1 $2) ; shift_count=2 ;;
			-o|--output-file-scores)     OF_STOCSYCORR=$(get_opt_val $1 $2) ; shift_count=2 ;;
			-) error "Illegal option $1." ;;
			--) error "Illegal option $1." ;;
			--*) error "Illegal option $1." ;;
			-?) error "Unknown option $1." ;;
			-[^-]*) split_opt=$(echo $1 | sed 's/^-//' | sed 's/\([a-zA-Z]\)/ -\1/g') ; set -- $1$split_opt "${@:2}" ;;
			*) break
		esac
		shift $shift_count
	done
	shift $((OPTIND - 1))
	
	echo $#
	# Read remaining arguments
	# if [ -z "$IF_METABOLOME" ] ; then
		# if [ $# -eq 1 ] ; then
			# [ -d "$DR_WORK" ] || error "\"$DR_WORK\" is not a directory."	
			# DR_WORK="$1"
		# elif [ -d "/mm-ps" ] ; then
			# echo "metabomatching "$VER" : no directory provided."
			# echo "metabomatching "$VER" : using dockerfile directory."
			# DR_WORK="/mm-ps"
			# if [[ $(find /mm-ps -type d -name "ps.*" | wc -c) -eq 0 ]]; then
				# echo "/mm-ps is empty, copying default pseudospectrum."
				# cp -r $DR_PROG/test/ps.test $DR_WORK
			# fi
		# else
			# error "You must specify one, and only one, directory to process."
		# fi
	# else
		# [ $# -eq 0 ] || error "You cannot specify a directory when using the -i option."
		# [ -f "$IF_METABOLOME" ] || error "\"$IF_METABOLOME\" is not a file."
		# [ -n "$OF_STOCSYCORR" ] || error "When using -i option, you must also set -s option."
		# [ -n "$OF_PDF" ] || error "When using -i option, you must also set -S option."
	# fi
	
	# Debug
	print_debug_msg 1 "Arguments are : $args"
	print_debug_msg 1 "Directory to process is: $DR_WORK"
	print_debug_msg 1 "Input file to process is: $IF_METABOLOME"
}

# MAIN {{{1
# =========

read_args "$@"

echo "STOCSY "$VER" : bash passed; running octave."
echo ""

# Set working directory
if [ -n "$IF_METABOLOME" ] ; then
	cp $IF_METABOLOME $DR_WORK/metabolome.csv
fi
if [ -n "$IF_INDEX" ] ; then
	cp $IF_INDEX $DR_WORK/index.csv
fi
# Execute
cd "$DR_WORK"
octave-cli $DR_PROG/stocsy.m

# Move output files
if [ -n "$IF_METABOLOME" ] ; then
	mv $DR_WORK/stocsy.csv $OF_STOCSYCORR
fi
