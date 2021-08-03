set -l SUBCOMMANDS add rm put ls repo config init env git hook cd

# {{{ Helper functions

# Complete the subcommand provided as the first argument.
# The rest of the arguments are the same as fish's `complete`. The option
# '-c tem' is implicit.
function complete_ --argument-names cmd
     set -l conditions "__fish_seen_subcommand_from $cmd"
     argparse -i "n/condition=" -- $argv[2..]
     [ -n "$_flag_n" ] && set -l conditions "$conditions && $_flag_n"
     complete -c tem $argv -n "$conditions"
end

# Complete paths matching $argv
function complete_paths_
    complete -C"nOnExIsTeNtCoMmAndZIOAGA2329jdbfaFkahDf21234h8z43 $argv"
end

# Return success if the command line contains no positional arguments
function no_positional_args_
    set -l -- args    (commandline -po)         # cmdline broken up into list
    set -l -- cmdline (commandline -p)          # single string
    set -l -- n       (count $args)             # number of cmdline tokens
    for i in (seq 2 $n)
        set -l arg $args[$i]
        [ -z "$arg" ] && continue               # can be caused by '--' argument

        # If the the last token is a positional argument and there is no
        # trailing space, we ignore it
        [ "$i" = "$n" ] && [ (string sub -s -1 "$cmdline") != ' ' ] && break

        if string match -rvq '^-' -- "$arg"     # doesn't start with -
            return 1
        end
    end
    # contains a '--' argument
    string match -r -- '\s--\s' "$cmdline" && return 1
    return 0
end

# Return success if the last cmdline token is one of those provided as arguments
function last_arg_
    contains -- (commandline -cpo | tail -1) $argv
end

# Complete paths but look only inside tem repos
# If '/' is specified as an argument, only directories are considered
function ls_
    set -l cmdline (commandline -po)
    set -l last (commandline -ct)
    argparse -i 'R/repo=+' -- $cmdline
    # Iterate through repository paths
    for repo in (command tem repo -lp $_flag_R)
        pushd "$repo"
        if [ "$argv[1]" = '/' ]
            __fish_complete_directories "$last" ''
        else
            complete_paths_ "$last"
        end
        popd
    end
end

# Generate completions for -R/--repo option
function complete_R_
    # Last cmdline token
    set -l last (commandline -ct)
    command tem repo -l | read -zl repos
    command tem repo -ln | read -zl repo_names
    if [ -z "$last" ]
        string replace -a ' @ ' \t "$repos" | string replace "/home/$USER" '~'
        __fish_complete_directories "$last"
    else if echo "$repo_names" | string match -rq "^$last.*"
        string replace -a ' @ ' \t "$repos" | string replace "/home/$USER" '~'
    else
        __fish_complete_directories "$last"
    end
end

# Generate completions for tem repo
function complete_repos_
    argparse --ignore-unknown 'R/repo=+' -- (commandline -cpo)
    if [ (count $_flag_R) -gt 0 ]             # commandline has -R options
        command tem repo -ln (printf -- "-R\n%s\n" $_flag_R)
    else                                      # commandline has no -R options
        command tem repo -ln
    end
end

function complete_commands_
    # 1. List all files in path
    # 2. Remove extra lines in ls output
    # 3. Append an 'Executable' description to each entry
    command ls -1 $PATH 2>/dev/null |\
        string match -rv '.*/.*' | string match -rv '^$' |\
        sed 's/$/\tExecutable/'
end

# Add --editor and -e options for command "$argv[1]"
function complete_edit_options_
    # TODO The double underscores are not a mistake. It is a trick that enables
    # the substitutions from the Makefile to work properly
    complete_ "$argv[1]" -s 'e' -l 'edit'   -f   -d "Open in default editor"
    complete_ "$argv[1]" -s 'E' -l 'editor' -rkf -d "Open in specified editor" -a "(complete_commands_)"
end

# }}}

# {{{ Defaults
complete -c tem -n no_positional_args_ -f -a "$SUBCOMMANDS"
complete -c tem -l 'help'      -s 'h'  -d 'Print help'
complete -c tem -l 'version'   -s 'v'  -d 'Print version'          -n no_positional_args_
complete -c tem -l 'debug'             -d 'Start debugger'
complete -c tem -l 'init-user'         -d 'Initialize user config' -n no_positional_args_
complete -c tem -l 'repo'      -s 'R'  -d 'Used repositories'      -a "(complete_R_)" -frk
complete -c tem -l 'config'    -s 'c'  -d 'Use different config'   -Frk
# }}}

# {{{ tem add
complete_ add -l 'output'    -s 'o' -rkf -d 'Destination file'      -a "(ls_)"
complete_ add -l 'directory' -s 'd' -rkf -d 'Destination directory' -a "(ls_ /)"
complete_ add -l 'move'      -s 'm' -f   -d 'Move the file'
complete_ add -l 'recursive' -s 'r' -f   -d 'Recurse into subdirectories'

complete_edit_options_ add
# }}}

# {{{ tem rm
complete_ rm -f -a "(ls_)"
# }}}

# {{{ tem put
complete_ put -f -a "(ls_)" -n 'not last_arg_ -d -o'

complete_ put -l 'output'    -s 'o' -rkF -d 'Destination file'
complete_ put -l 'directory' -s 'd' -rf  -d 'Destination directory' -a "(__fish_complete_directories)"

complete_edit_options_ put
# }}}

# {{{ tem ls
complete_ ls -f -a "(ls_)" -n 'not last_arg_ -e -E'
complete_ ls -l 'short'       -s 's'     -d 'Print short version'
complete_ ls -l 'path'        -s 'p'     -d 'Print full path'
complete_ ls -l 'command'     -s 'x'     -d 'Custom command to use'              -a "(complete_commands_)"
complete_ ls -l 'number'      -s 'n' -rf -d 'Maximum number of listed entries'
complete_ ls -l 'recursive'   -s 'r'     -d 'Recurse into subdirectories'
complete_ ls -l 'norecursive'            -d 'Do not recurse'

complete_edit_options_ ls
# }}}

# {{{ tem repo
complete_ repo -a "(complete_repos_)" -f
complete_ repo -l 'list'   -s 'l' -d 'List repositories' -f
complete_ repo -l 'name'   -s 'n' -d 'Include repository names in output' -f
complete_ repo -l 'path'   -s 'p' -d 'Print repository full path' -f
complete_ repo -l 'add'    -s 'a' -d 'Add repositories to REPO_PATH' -f
complete_ repo -l 'remove' -s 'r' -d 'Remove repositories from REPO_PATH' -f
# }}}

# {{{ tem config
complete_ config -f
complete_ config -l 'file'      -s 'f' -r -d 'Configuration file'       -a '(__fish_complete_directories)'
complete_ config -l 'global'    -s 'g' -f -d 'Use user configuration'
complete_ config -l 'local'     -s 'l' -f -d 'Use local configuration'
complete_ config -l 'instance'  -s 'i' -f -d 'Print config from this instance'

complete_edit_options_ config
# }}}

# {{{ tem init
complete_ init -l 'example-hooks' -s 'H' -d 'Generate example hooks'
complete_ init -l 'example-env'   -s 'n' -d 'Generate example env scripts'
complete_ init -l 'as-repo'       -s 'r' -d 'Initialize as repo'
complete_ init -l 'force'         -s 'f' -d 'Force overwrite'
complete_ init -l 'verbose'       -s 'v' -d 'Show generated files'

complete_edit_options_ init
# }}}

# {{{ tem env
# TODO Move stuff from here to the dot subcommand
complete_ env -f -a "(command ls -1 .tem/env 2>/dev/null)"
complete_ env -l 'exec'    -s 'x'   -d "Execute files"
complete_ env -l 'new'     -s 'n'   -d "New empty file"
complete_ env -l 'add'     -s 'a'   -d "Add files"
complete_ env -l 'delete'  -s 'D'   -d "Delete files"
complete_ env -l 'list'    -s 'l'   -d "List files"

# TODO rethink this one
# TODO filter directories for template
complete_ env -l 'template' -s 't' -r -d "Template as root directory"
complete_ env -l 'force'    -s 'f'    -d "Disregard warnings"
complete_ env -l 'verbose'  -s 'v'    -d "Report status of runs"
complete_ env -l 'ignore'   -s 'I'    -d "Files to ignore"

# TODO Remove from here and add to dot subcommand
complete_ env -l 'subdir'             -d "Alternative subdirectory"
complete_ env -l 'root'               -d "Files to ignore"

complete_edit_options_ env
# }}}

# {{{ tem cd
complete_ cd -f -a "(complete -C (commandline -cp | sed 's/cd/repo/') | grep -v -- '^--*.*')"
complete_ cd -l 'path'     -s 'p' -f -d "cd to .tem/path"
complete_ cd -l 'env'      -s 'e' -f -d "cd to .tem/env"
complete_ cd -l 'fish-env' -s 'f' -f -d "cd to .tem/fish-env"
complete_ cd -l 'hooks'    -s 'H' -f -d "cd to .tem/hooks"
# }}}

# vim: foldmethod=marker sw=4
