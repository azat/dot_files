export GPG_TTY=$(tty)

function restore_gpg_agent()
{
    export GPG_AGENT_INFO=$(find /tmp/gpg-*/S.gpg-agent -user $USER):$(pgrep -u$USER gpg-agent):1
}
