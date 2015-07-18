# Useful in the next cases:
# - your X is buggy
# - you have X, but now you are run some stuff from the remote shell
# - you restart your agent
function restore_ssh_agent()
{
    local pid=$(pgrep -u$USER ssh-agent | head -1)
    local socket=$(sudo lsof -np $pid | awk '/unix/ {print $NF; exit(0);}')

    export SSH_AGENT_PID=$pid
    export SSH_AUTH_SOCK=$socket
}
