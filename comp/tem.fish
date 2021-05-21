set -l SUBCOMMANDS add rm put ls repo config init env git cd fish-init

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

function complete_files_
    complete -C"nOnExIsTeNtCoMmAndZIOAGA2329jdbfaFkahDf21234h8z43 $argv"
end

# Return 0 if the last token is the one provided as argument
function last_arg_
    string match -q -- $argv[1] (commandline -cpo | tail -1)
end

function ls_
    set -l comp (commandline -ct)
    # Iterate through repository paths
    for repo in (tem repo -lp)
        pushd "$repo"
        if [ "$argv[1]" = '/' ]
            __fish_complete_directories "$comp" ''
        else
            complete_files_ "$comp"
        end
        popd
    end
end

# Generate completions for -R/--repo option
function complete_R_
    # Last cmdline token
    set -l comp (commandline -ct)
    tem repo -l | read -zl repos
    tem repo -ln | read -zl repo_names
    if [ -z "$comp" ]
        string replace -a ' @ ' \t "$repos" | string replace "/home/$USER" '~'
        __fish_complete_directories "$comp"
    # TODO escape any parts of $comp matchable by regex
    else if string match -rq "^$comp.*" "$repo_names"
        string replace -a ' @ ' \t "$repos" | string replace "/home/$USER" '~'
    else
        __fish_complete_directories "$comp"
    end
end

# Generate completions for tem repo
function repo_completions_
    argparse --ignore-unknown 'R/repo=+' -- (commandline -cpo)
    if [ (count $_flag_R) -gt 0 ]             # commandline has -R options
        tem repo -ln (printf -- "-R\n%s\n" $_flag_R)
    else                                      # commandline has no -R options
        tem repo -ln
    end
end
# }}}

# {{{ Defaults
complete -c tem -n "not __fish_seen_subcommand_from $SUBCOMMANDS" -f -a "$SUBCOMMANDS"
complete -c tem -s 'h' -l 'help' -d 'Print help' -f
complete -c tem -s 'R' -l 'repo' -d 'Used repositories' -a "(complete_R_)" -frk
# }}}

# {{{ tem put

complete_put_ -f\
    -a "(ls_)"\
    -n 'not last_arg_ -d && not last_arg_ -o'

complete_put_ -s 'o' -l 'output' -rkF -d 'Destination file'

complete_put_ -s 'd' -l 'directory' -rf -d 'Destination directory'\
    -a "(__fish_complete_directories)"

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
