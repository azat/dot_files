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

# git
# If REPO/.git/.repository_is_quite_big is exist, than don't request git-status or something like this.
if [ $(which git) ] ; then
	PS1=$PS1'$(
		GIT_DIR="$(__gitdir)" \
		GIT_PS="$(__git_ps1 " (%s)")" \

		if [ -f $GIT_DIR/.repository_is_quite_big ] || [[ $GIT_PS =~ ^\\ \\(BARE: ]]; then \
			echo "'$Purple'"$GIT_PS'$Color_Off'; \
		else \
			git branch &>/dev/null;\
			if [ $? -eq 0 ]; then \
			  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
			  if [ "$?" -eq "0" ]; then \
				 # @4 - Clean repository - nothing to commit
				 echo "'$Green'"$GIT_PS; \
			  else \
				 # @5 - Changes to working tree
				 echo "'$IRed'"$GIT_PS; \
			  fi)'$Color_Off'"; \
			fi \
		fi \
	)'
fi

# jobs
PS1=$PS1'$(\
	JOBS_NUM=$(jobs | wc -l); \
	JOBS_NUM=$(( $JOBS_NUM - 1)); # current job \
	if [ $JOBS_NUM -gt 0 ]; then \
		echo " ['$ICyan'$JOBS_NUM'$Color_Off']"; \
	fi
)'

PS1=$PS1$currentUserPostfix' '


