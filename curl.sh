#!/bin/bash

# NOTE 以下为控制字符数出，使用 echo -e 可以控制屏幕输出的格式
# NOTE 控制字符为不可见字符，可能会造成日志文件的过滤出现不可控结果
bla="\033[30m"     # 30 40 black   #000
red="\\033[31m"    # 31 41 red     #c33
gre="\\033[32m"    # 32 42 green   #3c3
yel="\\033[33m"    # 33 43 yellow  #cc3
blu="\\033[34m"    # 34 44 blue    #33c
mag="\\033[35m"    # 35 45 magenta #c3c
cya="\\033[36m"    # 36 46 cyan    #3cc
whi="\\033[37m"    # 37 47 white   #ccc
cle="\\033[0m"     # clear

reD="\\033[4;31m"  # 31 41 red   #c33
grE="\\033[4;32m"  # 32 42 green #3c3
RED="\\033[41;37m" # 37 47 white on red   #ccc #c33
BLU="\\033[44;37m" # 37 47 white on blue  #ccc #33c
GRE="\\033[42;37m" # 37 47 white on green #ccc #3c3
bol="\\033[1m"     # bold
und="\\033[4m"     # underline

filter=$(seq -s '=' 1 120 | tr -dc '=')
beginline="${gre}${filter}${cle}\\n"
line="${blu}${filter}${cle}\\n"
endline="${red}${filter}${cle}"

# source /Users/vanton/works/hhighlighter/h.sh

h() {
	param=(
		"/ip/"
		"Ping"
		"Traceroute"
		"Connection:"
		"Location:"
		"Server:"
		"Connection refused"
		"Connection failed"
		"HTTP/1.1 200 OK"
		"HTTP/1.1 301 Moved Permanently"
		"HTTP/1.1 400 Bad Request"
		"HTTP/1.1 500 Internal Server Error"
	)
	_OPTS=" -iQ "
	n_flag=

	# set zsh compatibility
	[[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

	local _i=0

	if [[ -n $H_COLORS_FG ]]; then
		local _CSV="$H_COLORS_FG"
		local OLD_IFS="$IFS"
		IFS=','
		local _COLORS_FG=()
		for entry in $_CSV; do
			_COLORS_FG=("${_COLORS_FG[@]}" "$entry")
		done
		IFS="$OLD_IFS"
	else
		_COLORS_FG=(
			"underline bold red"
			"underline bold green"
			"underline bold yellow"
			"underline bold blue"
			"underline bold magenta"
			"underline bold cyan"
		)
	fi

	if [[ -n $H_COLORS_BG ]]; then
		local _CSV="$H_COLORS_BG"
		local OLD_IFS="$IFS"
		IFS=','
		local _COLORS_BG=()
		for entry in $_CSV; do
			_COLORS_BG=("${_COLORS_BG[@]}" "$entry")
		done
		IFS="$OLD_IFS"
	else
		_COLORS_BG=(
			"bold on_red"
			"bold on_green"
			"bold black on_yellow"
			"bold on_blue"
			"bold on_magenta"
			"bold on_cyan"
			"bold black on_white"
		)
	fi

	if [[ -z $n_flag ]]; then
		# inverted-colors-last scheme
		_COLORS=("${_COLORS_FG[@]}" "${_COLORS_BG[@]}")
	else
		# inverted-colors-first scheme
		_COLORS=("${_COLORS_BG[@]}" "${_COLORS_FG[@]}")
	fi

	if [ -n "$ZSH_VERSION" ]; then
		local WHICH="whence"
	else
		[ -n "$BASH_VERSION" ]
		local WHICH="type -P"
	fi

	if ! ACKGREP_LOC="$($WHICH ack-grep)" || [ -z "$ACKGREP_LOC" ]; then
		if ! ACK_LOC="$($WHICH ack)" || [ -z "$ACK_LOC" ]; then
			echo "ERROR: Could not find the ack or ack-grep commands"
			return 1
		else
			local ACK=$($WHICH ack)
		fi
	else
		local ACK=$($WHICH ack-grep)
	fi

	for keyword in "${param[@]}"; do
		# echo "!! "${keyword}
		local _COMMAND=$_COMMAND"$ACK $_OPTS --noenv --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" '$keyword' |"
		_i=$_i+1
	done
	# trim ending pipe
	_COMMAND=${_COMMAND%?}
	# echo "$_COMMAND"
	cat - | eval $_COMMAND

}

# ?? android
echo -e "${beginline}"

# echo -e "# ${RED}(Android) 139.196.120.46:26132${cle}"
# curl -x 139.196.120.46:26132 -IL http://ipip.net/ip.html | h
echo -e "# ${RED}(Android) 139.196.120.46:20124${cle}"
# curl -x 139.196.120.46:20124 -IL http://ipip.net/ip.html | h
curl -x 139.196.120.46:20124 -vL https://pv.sohu.com/cityjson?ie=utf-8 | h

# ?? 0.99
# echo -e "${line}"
# echo -e "# ${RED}(0.99) 139.196.120.46:20123${cle}"
# curl -x 139.196.120.46:20099 -IL http://ipip.net/ip.html | h

# ?? US
# echo -e "${line}"
# echo -e "# ${RED}(US) 139.196.120.46:30000${cle}"
# curl -x 139.196.120.46:30000 -U frpc:abcdefg -IL https://ipip.net/ip.html | h

echo -e "${endline}"
