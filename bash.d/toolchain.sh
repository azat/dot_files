function c_const_generate()
{
    local headers=$(cat <<-EOL
        stdint.h limits.h \
        stdio.h stdlib.h unistd.h fcntl.h \
        sys/types.h sys/stat.h \
        sys/socket.h netinet/in.h arpa/inet.h
        errno.h
EOL
)
    for header in $@ $headers; do
        printf "#include <%s>\n" "$header"
    done
}
function c_const()
{
    const="$1"
    shift

    c_const_generate $@ | g++ -E -dM -xc++ - | fgrep $const | fgrep define
    c_const_generate $@ | g++ -E -xc++ - | fgrep $const | fgrep typedef
}

export NINJA_STATUS=$'\e[37m[\e[92m%w\e[37m][\e[92m%P\e[37m][\e[92m%f/%t\e[37m]\e[0m '
