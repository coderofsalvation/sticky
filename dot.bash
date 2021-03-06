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

empty () 
{ 
    [[ "${#1}" == 0 ]] && return 0 || return 1
}

isset () 
{ 
    [[ ! "${#1}" == 0 ]] && return 0 || return 1
}

last () 
{ 
    [[ ! -n $1 ]] && return 1;
    echo "$(eval "echo \${$1[@]:(-1)}")"
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
    code="$(echo -e "$code" | sed  's/.*\[\].*//g;s/\t/=/g;s/","\?/./g;s/[,.]"/./g;s/.*=[{\[].*//g;s/\"\]=/]=/g;s/\]=/"\]=/g' )";
    [[ -n "$2" ]] && code="$code\necho echo \${$varname['$2']}";
    eval "$code"
}

mappipe () 
{ 
    func="$1";
    shift;
    ( while read -r line; do
        $func "$@" "$line";
    done )
}


set +e # no need to exit shell on error

{
  complete -r cd
} &>/dev/null


dotgetcachefile(){
  local type="${1}"
  echo ~/.dot.bash.cache.$type
}

dotcache(){
  local type="${1}"
  local value="${2}"
  local cachesize="${3}"
  local cachefile=$(dotgetcachefile "$type")
  if empty "$cachesize"; then
    cachesize=15
  fi
  if [[ ! -f "$cachefile" ]]; then
    touch "$cachefile" && chmod 700 "$cachefile"
  fi
  if fgrep -q "$value" "$cachefile" &>/dev/null; then
    return 0
  fi
  head -n15 "$cachefile" > "$cachefile".tmp
  echo -e "$value\n$(<$cachefile.tmp)" > "$cachefile"
  rm "$cachefile".tmp
}

declare -A LISTENERS

.pub(){
  listeners=${LISTENERS[$1]}
  shift;
  for listener in $listeners; do
    eval "$listener $@"
  done
}

.sub(){
  #if ! test "${LISTENERS['$1']+isset}"
  #  LISTENERS["$1"]=""
  LISTENERS["$1"]+="$2 " # we can get away with this since functionnames never contain spaces
}


_(){
  if [[ -n $CMD ]]; then
    set -x; ${CMD} "$@"; set +x
  fi
}

.push(){
  PS1_OLD="$PS1"
  CMD_SHORT=$1
  CMD=$@
  export PS1="\u@\H \[\033[1;34m\]$CMD_SHORT \$ \[\033[0m\]"
}

.pop(){
  CMD=""
  export PS1="$PS1_OLD"
}

STICK=0
CMD=""
PS1_OLD=""

prompt_on_top(){
  tput cup 0 0
  tput el
  tput el1
}

sticky_hook(){
  if [[ $STICK == "0" || "$BASH_COMMAND" == "$PROMPT_COMMAND" || -n "$COMP_LINE" ]]; then
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

trap sticky_hook DEBUG

.gitbranch(){
  branch="$( git branch 2>&1 | grep "^*" | sed 's/ //g;s/^*//g'  )"
  [[ ${#branch} > 0 ]] && echo "($branch)"
}

.pretty(){
  local str=$(cat)
  # check whether json
  local first=${str:0:1}
  local last=${str:$((${#str}-1))}
  if [[ $first == "{" || $first == "[" ]]; then
    if [[ $last == "}" || $last == "]" ]]; then
      if which python2 &>/dev/null; then
        echo "$str" | python -mjson.tool
        return 0
      fi
      if which node &>/dev/null; then
        node -e "console.log(JSON.stringify(JSON.parse(process.argv[1]), null, 2));" "$str"
        return 0
      fi
    fi
  fi
  echo "$str"
}

.linenumbers(){
  cat -n | sed 's/\t/  /g'
}

.escape(){
  cat | sed 's/"/\\"/g' | .implode '\\n'
}

.wrap(){
  echo "$(printf "$*" "$(cat)" )" | .template
}

completeWrap(){
  local cmd="${1}"
  local cur="${2}"
  echo ".wrap" >> /tmp/log.txt
  if [[ $cmd == ".wrap" ]]; then
    .complete '%s' true
    .complete '{"user":"${USER}@${HOSTNAME}","timestamp":"'$(date +%s)'","output":"%s"}' true
    .complete '<output><text><![CDATA[%s]]></output>' true
  fi
}

complete -o noquote -F dotcomplete -o filenames .wrap
.sub onComplete completeWrap # subscribe to onComplete event

.implode(){
  local separator="${1}"
  cat | sed ':a;N;$!ba;s/\n/'"$separator"'/g'
}

.markdown(){
  cat | awk '{ print "    "$0 }'
}

.template(){
  if [[ -n $1 ]]; then
    printf "$1" "$(cat)" > $tmpfile.input
  else
    echo -n "$(cat)" > $tmpfile.input
  fi
  awk '{while(match($0,"[$]{[^}]*}")) {var=substr($0,RSTART+2,RLENGTH -3);gsub("[$]{"var"}",ENVIRON[var])}}1' < $tmpfile.input
  rm $tmpfile.input
}

.markdown.render(){
  cat - > /tmp/.markdown
  curl -s -X POST -H "Content-Type: text/x-markdown" --data-binary @/tmp/.markdown https://api.github.com/markdown/raw
}

.json.path(){
  declare -A json
  {
  if [[ ! -n $2 ]]; then
    cat | json_decode json $1
    return 0
  fi
  if [[ ${1:0:1} == "{" ]]; then
    echo "$1" | json_decode json $2
  else
    if [[ ! -n $1 ]]; then
      echo "file not found: $1"
      return 0
    fi
    cat $1 | json_decode json $2
  fi
  } 2>/dev/null
}



.json.request(){
  local url="${1}"
  if [[ ! -n $url ]]; then
    echo "usage: .json.<method> url [curl_arguments]"
    return 0
  fi
  shift;
  dotcache url "$url"
  if [[ "$*" =~ "GET" ]]; then
    curl -s -L -H 'Content-Type: application/json' "$@" "$url"
  else
    cat | curl -s -L -H 'Content-Type: application/json' "$@" "$url" --data @-
  fi
}

.is.json(){
  local str="${1}"
  local json=0
  local first=${str:0:1}
  local last=${str:$((${#str}-1))}
  if [[ $first == "{" || $first == "[" ]]; then
    if [[ $last == "}" || $last == "]" ]]; then
      return 0
    fi
  fi
  return 1
}

.json.get(){
  local url="${1}"
  .json.request $url -X GET "$@"
}

.json.post(){
  local url="${1}"
  local str=$(cat)
  shift
  if ! .is.json "$str"; then
    str=$(echo "$str" | .wrap '{"user":"${USER}","host":"'$(hostname)'","date":"'$(date | .escape)'","timestamp":"'$(date +%s)'","output":"%s"}' )
  fi
  echo "$str" | .json.request $url -X POST "$@"
}

.json.put(){
  local url="${1}"
  local str=$(cat)
  shift
  if ! .is.json "$str"; then
    str=$(echo "$str" | .wrap '{"user":"${USER}","host":"'$(hostname)'","date":"'$(date | .escape)'","timestamp":"'$(date +%s)'","output":"%s"}' )
  fi
  echo "$str" | .json.request $url -X PUT "$@"
}

.json.delete(){
  local url="${1}"
  local str=$(cat)
  shift
  if ! .is.json "$str"; then
    str=$(echo "$str" | .wrap '{"user":"${USER}","host":"'$(hostname)'","date":"'$(date | .escape)'","timestamp":"'$(date +%s)'","output":"%s"}' )
  fi
  echo "$str" | .json.request $url -X DELETE "$@"
}

.json.options(){
  local url="${1}"
  local str=$(cat)
  if ! .is.json "$str"; then
    str=$(echo "$str" | .wrap '{"user":"${USER}","host":"'$(hostname)'","date":"'$(date | .escape)'","timestamp":"'$(date +%s)'","output":"%s"}' )
  fi
  echo "$str" | .json.request $url -X OPTIONS "$@"
}


completeJsonRequest(){
  local cmd="${1}"
  local cur="${2}"
  if [[ $cmd =~ .json ]]; then
    if [[ ! $COMP_LINE =~ http ]]; then
      cat $(dotgetcachefile url) | mappipe addUrlToCompletion
      return 0
    fi
  fi
}

complete -o noquote -F dotcomplete .json.get
complete -o noquote -F dotcomplete .json.post
complete -o noquote -F dotcomplete .json.put
complete -o noquote -F dotcomplete .json.delete

.sub onComplete completeJsonRequest # subscribe to onComplete event


export CURL_HOST=""

_sethostfromurl(){
  local url="${1}"
  CURL_HOST="${url/*\/\//}"
  CURL_HOST="${CURL_HOST/:*/}"
  CURL_HOST="${CURL_HOST/\/*/}"
  export CURL_HOST=$CURL_HOST
}


.curl(){
  if [[ "$*" =~ http ]]; then
    local url="$*"
    url="${url/* http/http}"
    url="${url/ */}"
    _sethostfromurl "$url"
    if [[ ! "$url" =~ ".html" ]]; then
      dotcache url "$url"
    fi
  fi
  if [[ "$*" =~ "--data " ]]; then
    local line="$*"
    dotcache $CURL_HOST".payload" "'${line/*--data /}'"
  fi
  \curl -s "$@"
}

alias curl=".curl"

addUrlToCompletion(){
  local line="${1}"
  .complete "$line"
}

addUrlToCompletionLiteral(){
  local line="${1}"
  .complete "$line" true
}

completeCurl(){
  local cmd="${1}"
  local cur="${2}"
  local line="${3}"
  echo "curl " >> /tmp/log.txt
  if [[ $cmd =~ curl ]]; then
    echo "cur='$cur' line='$line'" > /tmp/log.txt
    if [[ $line == "-H" ]]; then
      .complete "flop"
      return 0
    fi
    if [[ ! $COMP_LINE =~ '-X' ]]; then
      .complete "-X"
      return 0
    fi
    if [[ ! $COMP_LINE =~ (POST|PUT|GET|DELETE|OPTIONS) ]]; then
      .complete GET
      .complete POST
      .complete PUT
      .complete DELETE
      .complete OPTIONS
      return 0
    fi
    if [[ ! $COMP_LINE =~ http ]]; then
      cat $(dotgetcachefile url) | awk -F'/' '{ print $1"//"$2$3  }' | mappipe addUrlToCompletion
      return 0
    fi
    if [[ $COMP_LINE =~ http ]]; then
      local lastchar=${cur:$((${#cur}-1)):1}
      local url="${COMP_LINE/* http/http}"
      url="${url/ */}"
      _sethostfromurl "$url"
      if [[ $lastchar == "/" ]]; then
        fgrep "$url" $(dotgetcachefile url) &>/dev/null
        if [[ $? == 0 ]]; then
          fgrep "$url" $(dotgetcachefile url) | sed -r 's/(http:|https:)//g' | mappipe addUrlToCompletion
          return 0
        fi
      fi
    fi
    if [[ ! $COMP_LINE =~ '-H' ]]; then
      .complete "-H"
      .complete "--user"
      return 0
    fi
    if [[ ${#cur} == 0 && $COMP_LINE =~ '-H' && ! $COMP_LINE =~ 'Content-Type:' ]]; then
      .complete 'Content-Type:' true
      return 0
    fi
    if [[ ! $COMP_LINE =~ '--data' ]]; then
      .complete "--data"
      return 0
    fi
    if [[ -f $(dotgetcachefile $CURL_HOST".payload") ]]; then
      cat $(dotgetcachefile $CURL_HOST".payload") | mappipe addUrlToCompletionLiteral
    fi
    return 0
  fi
}

complete -o noquote -F dotcomplete -o nospace -o filenames curl

.sub onComplete completeCurl # subscribe to onComplete event

.complete(){
  local str="${1}"
  local quoted="${2}"
  if ! empty $quoted; then
    str=$( echo "$str" | .escape | sed 's/ /\\ /g' | .wrap "\"'%s'\"" )
  fi
  echo "$str" >> $tmpfile.dotcompletions
}

dotcomplete(){
  # speed-improv: autocorrect typos in mysqltables or bash directories
  bind 'set completion-ignore-case on'
  bind 'set show-all-if-ambiguous off'
  #bind 'set TAB:menu-complete'
  # do completions
  COMPREPLY=()   # Array variable storing the possible completions.
  cur=${COMP_WORDS[COMP_CWORD]}
  local cmd="${COMP_WORDS[0]}"
  {
  :>$tmpfile.dotcompletions # empty completions
  .pub onComplete $cmd $cur # fill up completions
  local dotcompletions="$(cat $tmpfile.dotcompletions | .implode ' ')"
  } &>/dev/null
  if ! empty $dotcompletions; then
    COMPREPLY=( $( compgen -W "$dotcompletions" -- $cur ) )
  fi
  return 0
}

declare -A original_completions
original_completions['ls']=$(complete -p | grep ' ls$' | awk '{print $3}')
original_completions['cd']=$(complete -p | grep ' cd$' | awk '{print $3}')

setdefaultcomplete(){
  local cmd="${COMP_WORDS[0]}"
  bind 'set show-all-if-ambiguous on'
  ${original_completions[$cmd]}
  return 0
}

complete -F setdefaultcomplete -o bashdefault ls

