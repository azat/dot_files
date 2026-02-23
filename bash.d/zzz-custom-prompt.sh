# Custom prompt
# @link http://awesomerails.wordpress.com/2009/09/21/show-last-two-directories-of-pwd-in-bash-prompt/

# Various variables you might want for your PS1 prompt instead
Prompt_Time12h="\T"
Prompt_Time12a="\@"
Prompt_PathShort="\w"
Prompt_PathFull="\W"
Prompt_NewLine="\n"
Prompt_Jobs="\j"
Prompt_User="\u"

PS1='${debian_chroot:+($debian_chroot)}'

# number of trailing directory components to retain when expanding  the  \w  and  \W
PROMPT_DIRTRIM=2
CUSTOM_PROMPT_LAST_COMMAND_STATUS=0

if [ $USER = "root" ] ; then
	currentUserColor=$BRed
	currentUserPostfix='#'
else
	currentUserColor=$BGreen
	currentUserPostfix='\$'
fi

# Simplest PS1
simpleColoredPromptUser=$PS1$currentUserColor$Prompt_User$Color_Off
simpleColoredPromptPath=:$BBlue$Prompt_PathShort$Color_Off
if [ -n "$SSH_CONNECTION" ]; then
	simpleColoredPromptBegin=$simpleColoredPromptUser$currentUserColor@'\h'$Color_Off$simpleColoredPromptPath
else
	simpleColoredPromptBegin=$simpleColoredPromptUser$simpleColoredPromptPath
fi

simpleColoredPrompt=$simpleColoredPromptBegin$currentUserPostfix' '

# git
#
# Disable heavy part of the prompt iff:
# - .git/.repository_is_quite_big is exists
# - git config prompt.disabled isset
function _custom_prompt_colored_git()
{
	GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)"
	GIT_PS="$(__git_ps1 " (%s)")"

	if [ -z $GIT_DIR ]; then
		return
	fi

	if [ -f $GIT_DIR/.repository_is_quite_big ] ||
		[[ "$(git config --type bool prompt.disabled 2>/dev/null)" == true ]] ||
		[[ $GIT_PS =~ ^\ \(BARE: ]] ||
		[[ $GIT_PS = " (GIT_DIR!)" ]]; then
		echo -en $Purple$GIT_PS$Color_Off
		return
	fi

	AHEAD_BEHIND="$(git_ahead_behind)"
	# Trim behind commits (if there is no one)
	AHEAD_BEHIND="${AHEAD_BEHIND%|0}"

	HAVE_CHANGES=1
	if $(git branch &> /dev/null) && $(git status --ignore-submodules | grep -q "nothing to commit"); then
		HAVE_CHANGES=0
	fi

	if [ $HAVE_CHANGES = "0" ]; then
		echo -en $Green$GIT_PS
	else
		echo -en $Yellow$GIT_PS
	fi
	if [ ! "$AHEAD_BEHIND" = 0 ]; then
		echo -en "["$AHEAD_BEHIND"]"
	fi
	echo -en $Color_Off
}

function _jobs_prompt()
{
	JOBS_NUM=$(jobs -p | xargs -r ps -opid | tail -n+2 | wc -l)

	if [ $JOBS_NUM -gt 0 ]; then
		echo -en " [$ICyan$JOBS_NUM$Color_Off]"
	fi
}

function _date_prompt()
{
	echo -en " | $Green$(date +'%Y-%b-%d %H:%M:%S')$Color_Off"
}

function _render_prompt_preamble()
{
	CUSTOM_PROMPT_LAST_COMMAND_STATUS=$?
}


function _prompt_timer_start()
{
	PROMPT_TIMER=${PROMPT_TIMER:-$SECONDS}
}
trap _prompt_timer_start DEBUG
function _prompt_timer_stop()
{
	PROMPT_COMMAND_ELAPSED=$(($SECONDS - $PROMPT_TIMER))
	unset PROMPT_TIMER
}

function _render_prompt()
{
	PS1=
	if [ ! $CUSTOM_PROMPT_LAST_COMMAND_STATUS -eq 0 ]; then
		PS1+="$Red$CUSTOM_PROMPT_LAST_COMMAND_STATUS|"
	fi
	PS1+=$simpleColoredPromptBegin
	if [ $(which git) ] ; then
		PS1+=$(_custom_prompt_colored_git)
	fi
	PS1+=$(_jobs_prompt)
	if (( $DATE_PROMPT )); then
		PS1+=$(_date_prompt)
	fi
	_prompt_timer_stop
	if [ $PROMPT_COMMAND_ELAPSED -gt 3 ]; then
		PS1+=" $White{elapsed: ${PROMPT_COMMAND_ELAPSED}s}$Color_Off"
	fi
	PS1+=$currentUserPostfix' '
}

if [ -n "$PROMPT_COMMAND" ] && [ ! "${PROMPT_COMMAND: -1}" = ';' ]; then
	PROMPT_COMMAND+=';'
fi

# Set window title (Redhat way)
case $TERM in
	xterm*|rxvt*)
		PROMPT_COMMAND+='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"; '
	;;
	screen)
		PROMPT_COMMAND+='printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"; '
	;;
esac
PROMPT_COMMAND="_render_prompt_preamble; $PROMPT_COMMAND _render_prompt"
