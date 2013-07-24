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

# Short prompt string, without git
# PS1=$PS1$currentUserColor$Prompt_User$Color_Off:$BBlue$Prompt_PathShort$Color_Off$currentUserPostfix' '

PS1=$PS1$currentUserColor$Prompt_User$Color_Off:$BBlue$Prompt_PathShort$Color_Off

# From function that called by PS1
# we need to decode colors
#
# We can't store decoded colors because in this case
# There will _bugs_ with detecting of begining of string in readline/bash 
function _color_ps()
{
	local color=${1/\\[/}
	echo ${color/\\]/}
	# To avoid syntax breaking in VIM
	# ]
}

# git
# If REPO/.git/.repository_is_quite_big is exist, than don't request git-status or something like this.
function _custom_prompt_colored_git()
{
	GIT_DIR="$(__gitdir)"
	GIT_PS="$(__git_ps1 " (%s)")"

	which tput &>/dev/null && tput el

	if [ -z $GIT_DIR ]; then
		return
	fi

	local Color_Off=$(_color_ps $Color_Off)
	local Purple=$(_color_ps $Purple)

	if [ -f $GIT_DIR/.repository_is_quite_big ] ||
		[[ $GIT_PS =~ ^\ \(BARE: ]] ||
		[[ $GIT_PS = " (GIT_DIR!)" ]]; then
		echo -en $Purple$GIT_PS$Color_Off
		return
	fi

	AHEAD_BEHIND="$(git_ahead_behind)"
	# Trim behind commits (if there is no one)
	AHEAD_BEHIND="${AHEAD_BEHIND%|0}"

	local Green=$(_color_ps $Green)
	local IRed=$(_color_ps $IRed)

	if [ "$AHEAD_BEHIND" = "0" ]; then
		HAVE_CHANGES=1
		if $(git branch &> /dev/null) && $(git status | grep -q "nothing to commit"); then
			HAVE_CHANGES=0
		fi

		if [ $HAVE_CHANGES = "0" ]; then
			echo -en $Green$GIT_PS
		else
			echo -en $IRed$GIT_PS
		fi
	else
		echo -en $IRed$GIT_PS"["$AHEAD_BEHIND"]"
	fi
	echo -en $Color_Off
}

if [ $(which git) ] ; then
	PS1=$PS1'$(_custom_prompt_colored_git)'
fi

# jobs
PS1=$PS1'$(\
	JOBS_NUM=$(jobs | wc -l); \
	# Doh. jump.
	if [[ -n $AUTOJUMP ]]; then \
		JOBS_NUM=$(( $JOBS_NUM - 1)); \
	fi \
	;
	if [ $JOBS_NUM -gt 0 ]; then \
		echo " ['$ICyan'$JOBS_NUM'$Color_Off']"; \
	fi
)'

PS1=$PS1$currentUserPostfix' '

