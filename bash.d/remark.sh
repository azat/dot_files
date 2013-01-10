# @link http://www.cyberciti.biz/open-source/command-line-hacks/remark-command-regex-markup-examples/

BASE_CONFIG_PATH=/usr/share/regex-markup

ping() { `which ping` $@ | remark $BASE_CONFIG_PATH/ping; }
traceroute() { `which traceroute` $@ | remark $BASE_CONFIG_PATH/traceroute; }

