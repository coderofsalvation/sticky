#!/bin/bash

# Generated by POWSCRIPT (https://github.com/coderofsalvation/powscript)
#
# Unless you like pain: edit the .pow sourcefiles instead of this file

# powscript general settings
set -e                                # halt on error
set +m                                #
SHELL="$(echo $0)"                    # shellname
shopt -s lastpipe                     # flexible while loops (maintain scope)
shopt -s extglob                      # regular expressions
path="$(pwd)"
if [[ "$BASH_SOURCE" == "$0"  ]];then #
  SHELLNAME="$(basename $SHELL)"      # shellname without path
  selfpath="$( dirname "$(readlink -f "$0")" )"
  tmpfile="/tmp/$(basename $0).tmp.$(whoami)"
else
  selfpath="$path"
  tmpfile="/tmp/.dot.tmp.$(whoami)"
fi
#
# generated by powscript (https://github.com/coderofsalvation/powscript)
#

on () 
{ 
    func="$1";
    shift;
    for sig in "$@";
    do
        trap "$func $sig" "$sig";
    done
}

json_decode () 
{ 
    function throw () 
    { 
        echo "json: $*" 1>&2;
        exit 1
    };
    BRIEF=0;
    LEAFONLY=0;
    PRUNE=0;
    function awk_egrep () 
    { 
        local pattern_string=$1;
        gawk '{
      while ($0) {
        start=match($0, pattern);
        token=substr($0, start, RLENGTH);
        print token;
        $0=substr($0, start+RLENGTH);
      }
    }' pattern=$pattern_string
    };
    function json_tokenize () 
    { 
        local GREP;
        local ESCAPE;
        local CHAR;
        if echo "test string" | egrep -ao --color=never "test" &> /dev/null; then
            GREP='egrep -ao --color=never';
        else
            GREP='egrep -ao';
        fi;
        if echo "test string" | egrep -o "test" &> /dev/null; then
            ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})';
            CHAR='[^[:cntrl:]"\\]';
        else
            GREP=awk_egrep;
            ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})';
            CHAR='[^[:cntrl:]"\\\\]';
        fi;
        local STRING="\"$CHAR*($ESCAPE$CHAR*)*\"";
        local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?';
        local KEYWORD='null|false|true';
        local SPACE='[[:space:]]+';
        $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
    };
    function parse_array () 
    { 
        local index=0;
        local ary='';
        read -r token;
        case "$token" in 
            ']')

            ;;
            *)
                while :; do
                    parse_value "$1" "$index";
                    index=$((index+1));
                    ary="$ary""$value";
                    read -r token;
                    case "$token" in 
                        ']')
                            break
                        ;;
                        ',')
                            ary="$ary,"
                        ;;
                        *)
                            throw "EXPECTED , or ] GOT ${token:-EOF}"
                        ;;
                    esac;
                    read -r token;
                done
            ;;
        esac;
        [ "$BRIEF" -eq 0 ] && value=`printf '[%s]' "$ary"` || value=;
        :
    };
    function parse_object () 
    { 
        local key;
        local obj='';
        read -r token;
        case "$token" in 
            '}')

            ;;
            *)
                while :; do
                    case "$token" in 
                        '"'*'"')
                            key=$token
                        ;;
                        *)
                            throw "EXPECTED string GOT ${token:-EOF}"
                        ;;
                    esac;
                    read -r token;
                    case "$token" in 
                        ':')

                        ;;
                        *)
                            throw "EXPECTED : GOT ${token:-EOF}"
                        ;;
                    esac;
                    read -r token;
                    parse_value "$1" "$key";
                    obj="$obj$key:$value";
                    read -r token;
                    case "$token" in 
                        '}')
                            break
                        ;;
                        ',')
                            obj="$obj,"
                        ;;
                        *)
                            throw "EXPECTED , or } GOT ${token:-EOF}"
                        ;;
                    esac;
                    read -r token;
                done
            ;;
        esac;
        [ "$BRIEF" -eq 0 ] && value=`printf '{%s}' "$obj"` || value=;
        :
    };
    function parse_value () 
    { 
        local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0;
        case "$token" in 
            '{')
                parse_object "$jpath"
            ;;
            '[')
                parse_array "$jpath"
            ;;
            '' | [!0-9])
                throw "EXPECTED value GOT ${token:-EOF}"
            ;;
            *)
                value=$token;
                isleaf=1;
                [ "$value" = '""' ] && isempty=1
            ;;
        esac;
        [ "$value" = '' ] && return;
        [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 0 ] && print=1;
        [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 0 ] && print=1;
        [ "$LEAFONLY" -eq 0 ] && [ "$PRUNE" -eq 1 ] && [ "$isempty" -eq 0 ] && print=1;
        [ "$LEAFONLY" -eq 1 ] && [ "$isleaf" -eq 1 ] && [ $PRUNE -eq 1 ] && [ $isempty -eq 0 ] && print=1;
        [ "$print" -eq 1 ] && printf "[%s]\t%s\n" "$jpath" "$value";
        :
    };
    function json_parse () 
    { 
        read -r token;
        parse_value;
        read -r token;
        case "$token" in 
            '')

            ;;
            *)
                throw "EXPECTED EOF GOT $token"
            ;;
        esac
    };
    varname="$1";
    code="$code$( sed 'N;s/\n//g' | json_tokenize | json_parse | awk '{print "'$varname'"$0}')";
    code="$(echo -e "$code" | sed  's/.*\[\].*//g;s/\t/=/g;s/",/./g;s/[,.]"/./g;s/.*=[{\[].*//g;s/\"\]=/]=/g;s/\]=/"\]=/g' | sed -r 's/([A-Za-z_0-9])([\.-])([A-Za-z_0-9])"]/\1-\3"]/g' )";
    eval "$code"
}


set +e # no need to exit shell on error

{
  complete -r cd
} &>/dev/null


_(){
  if [[ -n "$CMD" ]]; then
    set -x; ${CMD} "$@"; set +x
  fi
}

.push(){
  CMD_SHORT=$1
  CMD=$@
  export PS1="$PS1_OLD""\[\033[1;34m\]$CMD_SHORT \$ \[\033[0m\]"
}

.pop(){
  CMD=""
  export PS1="$PS1_OLD"
}

STICK=0
CMD=""

prompt_on_top(){
  tput cup 0 0
  tput el
  tput el1
}

sticky_hook(){
  if [[ "$STICK" == "0" || "$BASH_COMMAND" == "$PROMPT_COMMAND" || -n "$COMP_LINE" ]]; then
    return
  fi
  if [[ "$(uname -a)" =~ "Darwin" ]]; then
    clear && echo ""
  else
    printf "\33[2J"
  fi
}

.stick(){
  STICK=1
  PS1_OLD="$PS1"
  export PROMPT_COMMAND="prompt_on_top"
}

.unstick(){
  STICK=0
  export PS1="$PS1_OLD"
  export PROMPT_COMMAND='PS1="$PS1"'
}

.gitbranch(){
  branch="$( git branch 2>&1 | grep "^*" | sed 's/ //g;s/^*//g'  )"
  [[ ${#branch} > 0 ]] && echo "($branch)"
}


.json.get(){
  if [[ ! -n "$2" ]]; then
    echo "usage: .json.get <file.json> <key>"
    return 0
  fi
  if [[ ! -n "$1" ]]; then
    echo "file not found: "$1""
    return 0
  fi
  declare -A json
  cat "$1" | json_decode json
  echo ${json[$2]}
}
