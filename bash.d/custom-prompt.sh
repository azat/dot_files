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
simpleColoredPrompt=$PS1$currentUserColor$Prompt_User$Color_Off:$BBlue$Prompt_PathShort$Color_Off$currentUserPostfix' '
unset PS1

# For not simpleColoredPrompt we don't need to escape this flag.
if [ ! $USER = "root" ]; then
	currentUserPostfix='$'
fi

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

	if [ -z $GIT_DIR ]; then
		return
	fi

	which tput &>/dev/null && tput el

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

function _jobs_prompt()
{
	JOBS_NUM=$(jobs | grep -v ' Done ' | wc -l)

	if [ $JOBS_NUM -gt 0 ]; then
		local ICyan=$(_color_ps $ICyan)
		local Color_Off=$(_color_ps $Color_Off)

		echo -en " [$ICyan$JOBS_NUM$Color_Off]"
	fi
}

function _dir_chomp()
{
	local p=${1/#$HOME/\~} b s
	s=${#p}
	while [[ $p != ${p//\/} ]]&&(($s>$2))
	do
		p=${p#/}
		[[ $p =~ \.?. ]]
		b=$b/${BASH_REMATCH[0]}
		p=${p#*/}
		((s=${#b}+${#p}))
	done
	echo ${b/\/~/\~}${b+/}$p
}

function _short_path()
{
	local newPwd=$(echo $PWD | rev | cut -d/ -f-2 | rev)
	if [ ! "$newPwd" = "$PWD" ]; then
		echo "..$newPwd"
		return
	fi

	echo $PWD
}

function _render_prompt()
{
	local currentUserColor=$(_color_ps $currentUserColor)
	local BBlue=$(_color_ps $BBlue)
	local Color_Off=$(_color_ps $Color_Off)

	echo -en $currentUserColor$USER$Color_Off:$BBlue"$(_short_path "$(_dir_chomp)")"$Color_Off
	if [ $(which git) ] ; then
		_custom_prompt_colored_git
	fi
	_jobs_prompt
	echo -en $currentUserPostfix' '
}

PROMPT_COMMAND="$PROMPT_COMMAND && _render_prompt"

