(beta) interactive toolbelt for bash hipsters

<img src="https://media.giphy.com/media/ZcqHDQUJm1nZC/giphy.gif" width="320"/>

## Usage

put this in `~/.bashrc`:

    [[ -t 0  ]] && { 
      source path/to/dot.bash 
      PS1="[\u@\H\[\033[34m\]\w]\[\033[0m\] \$(.gitbranch) \[\033[1;34m\]$ \[\033[0m\]" # optional
    }    

> NOTE: the optional lines will display gitbranch in prompt

# Why 

Bash equalivent of lodash/underscore for interactive purposes, plus:

* promote command stacking instead of writing oneliners

# .stick

Always keep your prompt at the top. Handy for mysql/mongodb queries etc.

    [username@peach/home/username] (master) $ ls -la
    drwxr-xr-x  271 username  www-data   12K Dec 28 08:46 projects
    drwxrwxrwx   27 username  username       4.0K Dec 27 18:07 tmp
    drwxr-xr-x    3 username  username        16K Dec 27 17:24 Pictures
    drwxr-xr-x 3894 username  username       132K Dec 26 22:05 .npm
    drwx------    4 username  username       4.0K Dec 26 21:49 .gconf
    drwxr-xr-x   33 username  username       4.0K Dec 26 21:49 .cache
    drwxr-xr-x   57 username  username       104K Dec 24 18:02 Downloads
    drwx------    8 username  username       4.0K Dec 24 00:21 .Skype
    drwxr-xr-x    7 username  username       4.0K Dec 21 08:19 .nvm
    drwxr-xr-x    2 username  username       4.0K Dec 16 20:39 .dpd
    drwxr-xr-x   24 username  username       4.0K Dec 16 12:45 .gimp-2.8
    drwx------    2 username  username       4.0K Dec 13 19:01 .git-credential-cache
    drwxr-xr-x    3 username  username       4.0K Dec 12 18:20 .gnupg
    drwxr-xr-x    5 username  username       4.0K Dec 12 11:01 Audio
    drwx------   47 username  username       4.0K Dec  4 00:40 .config
    drwx------    2 username  username       4.0K Nov 25 14:54 .docker
    drwxr-xr-x   12 username  username       4.0K Nov 24 11:12 dotfiles
    drwxr-xr-x    4 username  username       4.0K Nov 21 10:43 .wine
    drwxr-xr-x    3 username  username       4.0K Nov 11 13:47 sqlpad
    drwxr-xr-x    6 username  username       4.0K Nov  6 11:47 .renoise

> NOTE: type '.unstick' to undo stick-to-top

# .push
# .pop
# _

Easy commandstacking = readable oneliners

> NOTE: use `.pop` to remove the pushed command

*curl*:
    
    $ .stick
    $ .push curl -H 'Content-Type: application/json' --user admin:password -v 
    curl $ _ -X POST http://foo.com --data '{}'
    +  curl -H 'Content-Type: application/json' -v -X POST http://foo.com '{}'
    ..(curl output)..
 
*mongodb*:
 
    $ .stick 
    $ .push mongo 192.169.0.5:9999/foo --eval
    mongo $ db.foo.find({})

# .json.get

Evaluate a key-path from a json-file or string

    $ .json.get package.json repository.type 
    git 

    $ .json.get '{"foo":['one','two']}' foo.0
    one

# .pretty
# .prettylines

    $ cat foo.json | .pretty
    $ cat foo.json | .prettylines | .markdown

# .markdown
# .markdown.render
    
    $ cat foo.json | .prettylines | .markdown
    $ cat foo.json | .prettylines | .markdown | .wrap "# json ${USER} output\n\n%s' | .markdown.render > foo.html

# .wrap

wrap template around stdin & env-vars.

> NOTE: piped content is substituted by '%s'

    $ world="WORLD"; echo "hello ${world}"
    hello WORLD

    $ ls -la | .markdown | .wrap '# ls -la output\n\n%s ${USER}' | .markdown.render
    <h1>ls -la output</h1>
    <pre>
    total 757M
    drwx------  2 sqz  sqz  4.0K Dec 28 21:25 vbjdwRv
    drwxrwxrwt 33 root root  48K Dec 28 21:25 .
    drwx------  2 sqz  sqz  4.0K Dec 28 18:09 vZIos2X
    drwx------  2 sqz  sqz  4.0K Dec 28 17:15 vzwsR4d
    </pre>
    <p>
      Wed Dec 28 21:26:44 CET 2016 john
    </p>

    $ echo -n '{ "foo": "%s", "user":"${USER}" }' > template.json
    $ date | .wrap "$(<template.json)" | .pretty
    {
       "user" : "foo",
       "date" : "Wed Dec 28 21:40:11 CET 2016"
    }

    $ date | .wrap "$(<template.json)" | curl -X POST http://localhost:3000/ping -d @-

# project scope:

* wrappers 
* small functions
* offline utilities  (with markdown as exception)
* make use of installed devlangs (python/perl/awk)
