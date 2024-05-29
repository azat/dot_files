# on X restarts it maybe reseted, while usually it is run under systemd --user
if [ ! -v SSH_AUTH_SOCK ]; then
    export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent.socket
fi
