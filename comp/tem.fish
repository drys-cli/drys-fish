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

# Return 0 if the last token is the one provided as argument
function last_arg_
    string match -q -- $argv[1] (commandline -cpo | tail -1)
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
function repo_completions_
    argparse --ignore-unknown 'R/repo=+' -- (commandline -cpo)
    if [ (count $_flag_R) -gt 0 ]             # commandline has -R options
        command tem repo -ln (printf -- "-R\n%s\n" $_flag_R)
    else                                      # commandline has no -R options
        command tem repo -ln
    end
end
# }}}

# {{{ Defaults
complete -c tem -n "not __fish_seen_subcommand_from $SUBCOMMANDS" -f -a "$SUBCOMMANDS"
complete -c tem -s 'h' -l 'help' -d 'Print help' -f
complete -c tem -s 'R' -l 'repo' -d 'Used repositories' -a "(complete_R_)" -frk
complete -c tem -s 'c' -l 'config' -d 'Use different config' -Frk
complete -c tem -l 'reconfigure' -d 'Discard previous config' -f
# }}}

# {{{ tem put

complete_put_ -f\
    -a "(ls_)"\
    -n 'not last_arg_ -d && not last_arg_ -o'

complete_put_ -s 'o' -l 'output' -rkF -d 'Destination file'
complete_put_ -s 'd' -l 'directory' -rf -d 'Destination directory'\
    -a "(__fish_complete_directories)"
complete_put_ -s 'e' -l 'edit' -d 'Edit in default editor'
# complete_put_ -s 'e' -l 'edit' -rk -d 'Edit in default editor' -a '(ls_)'

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

# {{{ tem repo
complete_repo_ -a "(repo_completions_)" -f
complete_repo_ -s 'l' -l 'list' -d 'List repositories' -f
# }}}

# {{{ tem config

complete_config_ -f
complete_config_ -s 'f' -l 'file' -r -a '(__fish_complete_directories)'

# }}}

# {{{ tem cd
complete_cd_ -f -a "(complete -C (commandline -cp | sed 's/cd/repo/') | grep -v -- '^--*.*')"
# }}}

# vim: foldmethod=marker sw=4
