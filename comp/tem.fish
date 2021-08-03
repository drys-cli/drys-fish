set -l SUBCOMMANDS add rm put ls repo config init env git hook cd fish-init

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
complete_ add -s 'o' -l 'output'    -rkf -d 'Destination file'      -a "(ls_)"
complete_ add -s 'd' -l 'directory' -rkf -d 'Destination directory' -a "(ls_ /)"
complete_ add -s 'm' -l 'move'      -f   -d 'Move the file'
complete_ add -s 'r' -l 'recursive' -f   -d 'Recurse into subdirectories'

complete_edit_options_ add
# }}}

# {{{ tem rm
complete_ rm -f -a "(ls_)"
# }}}

# {{{ tem put
complete_ put -f -a "(ls_)" -n 'not last_arg_ -d -o'

complete_ put -s 'o' -l 'output' -rkF -d 'Destination file'
complete_ put -s 'd' -l 'directory' -rf -d 'Destination directory'\
    -a "(__fish_complete_directories)"
# }}}

# {{{ tem ls
complete_ ls -f -a "(ls_)" -n 'not last_arg_ -e -E'
complete_ ls -s 's' -l 'short'          -d 'Print short version'
complete_ ls -s 'p' -l 'path'           -d 'Print full path'
complete_ ls -s 'x' -l 'command'        -d 'Custom command to use'              -a "(complete_commands_)"
complete_ ls -s 'n' -l 'number'         -d 'Maximum number of listed entries'
complete_ ls -s 'e' -l 'edit'           -d 'Edit target files'
complete_ ls -s 'E' -l 'editor'      -r -d 'Edit files in a custom editor'      -a "(complete_commands_)"
complete_ ls -s 'r' -l 'recursive'      -d 'Recurse into subdirectories'
complete_ ls        -l 'norecursive'    -d 'Do not recurse'
# }}}

# {{{ tem repo
complete_ repo -a "(complete_repos_)" -f
complete_ repo -s 'l' -l 'list' -d 'List repositories' -f
complete_ repo -s 'n' -l 'name' -d 'Include repository names in output' -f
complete_ repo -s 'p' -l 'path' -d 'Print repository full path' -f
complete_ repo -s 'a' -l 'add' -d 'Add repositories to REPO_PATH' -f
complete_ repo -s 'r' -l 'remove' -d 'Remove repositories from REPO_PATH' -f
# }}}

# {{{ tem config
complete_ config -f
complete_ config -s 'f' -l 'file' -r -a '(__fish_complete_directories)'
# }}}

# {{{ tem env
complete_ env -f -a "(command ls -1 .tem/env 2>/dev/null)"
complete_ env -s 'x' -l 'exec'      -d "Execute files"
complete_ env -s 'n' -l 'new'       -d "New empty file"
complete_ env -s 'a' -l 'add'       -d "Add files"
complete_ env -s 'D' -l 'delete'    -d "Delete files"
complete_ env -s 'l' -l 'list'      -d "List files"

# TODO rethink this one
complete_ env -s 't' -l 'template'  -d "Template as root directory"

complete_ env -s 'v' -l 'verbose'   -d "Report status of runs"
complete_ env -s 'f' -l 'force'     -d "Disregard warnings"
complete_ env -s 'I' -l 'ignore'    -d "Files to ignore"

# TODO Remove from here and add to dot subcommand
complete_ env        -l 'subdir'    -d "Alternative subdirectory"
complete_ env        -l 'root'      -d "Files to ignore"

complete_edit_options_ 'env'
# }}}

# {{{ tem cd
complete_ cd -f -a "(complete -C (commandline -cp | sed 's/cd/repo/') | grep -v -- '^--*.*')"
complete_ cd -s 'p' -l 'path'       -f -d "cd to .tem/path"
complete_ cd -s 'e' -l 'env'        -f -d "cd to .tem/env"
complete_ cd -s 'f' -l 'fish-env'   -f -d "cd to .tem/fish-env"
complete_ cd -s 'H' -l 'hooks'      -f -d "cd to .tem/hooks"
# }}}

# vim: foldmethod=marker sw=4
