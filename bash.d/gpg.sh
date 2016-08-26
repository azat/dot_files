export GPG_TTY=$(tty)

function restore_gpg_agent()
{
    local home=/home/azat/.gnupg/S.gpg-agent
    local run=/run/user/$UID/gnupg/S.gpg-agent
    if [ -e $run ]; then
        export GPG_AGENT_INFO=$run:0:1
    elif [ -e $home ]; then
        export GPG_AGENT_INFO=$home:0:1
    else
        export GPG_AGENT_INFO=$(find /tmp/gpg-*/S.gpg-agent -user $USER):$(pgrep -u$USER gpg-agent):1
    fi
}
