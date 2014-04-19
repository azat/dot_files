
# clean make
function cm()
{
    make $* > /dev/null
}

function c_const()
{
    const="$1"
    additional_headers="$2"
    headers=$(cat <<-EOL
        stdint.h stdio.h stdlib.h unistd.h fcntl.h \
        sys/types.h sys/stat.h \
        sys/socket.h netinet/in.h arpa/inet.h
EOL
)
    (
        for header in $additional_headers $headers; do
            printf "#include <%s>\n" "$header"
        done
    ) | g++ -E -dM -xc++ - | fgrep $1 | fgrep define
}
