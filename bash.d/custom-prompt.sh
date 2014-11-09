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
# If REPO/.git/.repository_is_quite_big is exist, than don't request git-status or something like this.
function _custom_prompt_colored_git()
{
	GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)"
	GIT_PS="$(__git_ps1 " (%s)")"

	if [ -z $GIT_DIR ]; then
		return
	fi

	if [ -f $GIT_DIR/.repository_is_quite_big ] ||
		[[ $GIT_PS =~ ^\ \(BARE: ]] ||
		[[ $GIT_PS = " (GIT_DIR!)" ]]; then
		echo -en $Purple$GIT_PS$Color_Off
		return
	fi

	AHEAD_BEHIND="$(git_ahead_behind)"
	# Trim behind commits (if there is no one)
	AHEAD_BEHIND="${AHEAD_BEHIND%|0}"

	HAVE_CHANGES=1
	if $(git branch &> /dev/null) && $(git status | grep -q "nothing to commit"); then
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

function _render_prompt()
{
	PS1=$simpleColoredPromptBegin
	if [ $(which git) ] ; then
		PS1+=$(_custom_prompt_colored_git)
	fi
	PS1+=$(_jobs_prompt)
	if (( $DATE_PROMPT )); then
		PS1+=$(_date_prompt)
	fi
	PS1+=$currentUserPostfix' '
}

# Set window title (Redhat way)
case $TERM in
    xterm*|rxvt*)
        PROMPT_COMMAND="$PROMPT_COMMAND; "'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
    ;;
    screen)
        PROMPT_COMMAND="$PROMPT_COMMAND; "'printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
    ;;
esac
PROMPT_COMMAND+="; _render_prompt"
