# Example
# rlwrap -H ftp.history bash -c 'nc_proxy bob 21'
function nc_proxy()
{
    local h=$1
    local p=$2
    local proxy=${3:-"localhost"}
    local proxy_port=${4:-"9050"}
    socat - SOCKS4:$proxy:$(tor-resolve $h $proxy:$proxy_port):$p,socksport=$proxy_port
}
