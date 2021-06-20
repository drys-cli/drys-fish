set -l SUBCOMMANDS add rm put ls repo config init env git hook cd fish-init

# {{{ Helper functions

# Defines a function complete_*_, where the wildcard is actually
# replaced by each tem subcommand (from $SUBCOMMANDS)
#
# Example:
#
# The function complete_add_ acts as an alias for:
#
#   complete -c tem -n "__fish_seen_subcommand_from add"
#
# Also, additional conditions can be specified using -n and all the other
# options that work for complete will work for this command as well

for cmd in $SUBCOMMANDS
    # NOTE: complete__$cmd will be replaced by __fish_tem_complete_$cmd during make
    eval\
    "function complete__$cmd
         set -l conditions '__fish_seen_subcommand_from $cmd'"'
         argparse -i "n/condition=" -- $argv
         [ -n "$_flag_n" ] && set -l conditions "$conditions && $_flag_n"
         complete -c tem -n "$conditions" $argv
     end'
end

# Complete paths matching $argv
function complete_paths_
    complete -C"nOnExIsTeNtCoMmAndZIOAGA2329jdbfaFkahDf21234h8z43 $argv"
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

# }}}

# {{{ Defaults
complete -c tem -n "not __fish_seen_subcommand_from $SUBCOMMANDS" -f -a "$SUBCOMMANDS"
complete -c tem -s 'h' -l 'help' -d 'Print help' -f
complete -c tem -s 'R' -l 'repo' -d 'Used repositories' -a "(complete_R_)" -frk
complete -c tem -s 'c' -l 'config' -d 'Use different config' -Frk
complete -c tem -l 'reconfigure' -d 'Discard previous config' -f
# }}}

# {{{ tem add

complete_add_ -s 'd' -l 'directory' -rkf -d 'Destination directory'\
    -a "(ls_ /)"

complete_add_ -s 'o' -l 'output' -rkf -d 'Destination file'\
    -a "(ls_)"

# }}}

# {{{ tem rm
complete_rm_ -f -a "(ls_)"
# }}}

# {{{ tem put

complete_put_ -f -a "(ls_)" -n 'not last_arg_ -d -o'

complete_put_ -s 'o' -l 'output' -rkF -d 'Destination file'
complete_put_ -s 'd' -l 'directory' -rf -d 'Destination directory'\
    -a "(__fish_complete_directories)"
complete_put_ -s 'e' -l 'edit' -d 'Edit in default editor'
# complete_put_ -s 'e' -l 'edit' -rk -d 'Edit in default editor' -a '(ls_)'

# }}}

# {{{ tem ls

complete_ls_ -f -a "(ls_)" -n 'not last_arg_ -e -E'
complete_ls_ -s 's' -l 'short' -d 'Print short version'
complete_ls_ -s 'p' -l 'path' -d 'Print full path'
complete_ls_ -s 'x' -l 'command' -d 'Custom command to use'\
    -a "(complete_commands_)"
complete_ls_ -s 'n' -l 'number' -d 'Maximum number of listed entries'
complete_ls_ -s 'e' -l 'edit' -d 'Edit target files'
complete_ls_ -s 'E' -l 'editor' -r -d 'Edit files in a custom editor'\
    -a "(complete_commands_)"
complete_ls_ -s 'r' -l 'recursive' -d 'Recurse into subdirectories'
complete_ls_ -l 'norecursive' -d 'Do not recurse into subdirectories'

# }}}

# {{{ tem repo
complete_repo_ -a "(complete_repos_)" -f
complete_repo_ -s 'l' -l 'list' -d 'List repositories' -f
complete_repo_ -s 'n' -l 'name' -d 'Include repository names in output' -f
complete_repo_ -s 'p' -l 'path' -d 'Print repository full path' -f
complete_repo_ -s 'a' -l 'add' -d 'Add repositories to REPO_PATH' -f
complete_repo_ -s 'r' -l 'remove' -d 'Remove repositories from REPO_PATH' -f
# }}}

# {{{ tem config

complete_config_ -f
complete_config_ -s 'f' -l 'file' -r -a '(__fish_complete_directories)'

# }}}

# {{{ tem cd
complete_cd_ -f -a "(complete -C (commandline -cp | sed 's/cd/repo/') | grep -v -- '^--*.*')"
# }}}

# vim: foldmethod=marker sw=4
