set -l SUBCOMMANDS add rm ls put config repo cd init env

# {{{ Helper functions

# Defines a function __fish_tem_complete_*, where the wildcard is actually
# replaced by each tem subcommand (from $SUBCOMMANDS)
#
# Example:
#
# The function __fish_tem_complete_add acts as an alias for:
#
#   complete -c tem -n "__fish_seen_subcommand_from add"
#
# Also, additional conditions can be specified using -n and all the other
# options that work for complete will work for this command as well

for cmd in $SUBCOMMANDS
    eval\
    "function __fish_tem_complete_$cmd
         set -l conditions '__fish_seen_subcommand_from $cmd'"'
         argparse -i "n/condition=" -- $argv
         [ -n "$_flag_n" ] && set -l conditions "$conditions && $_flag_n"
         complete -c tem -n "$conditions" $argv
     end'
end

function __fish_tem_complete_files
    complete -C"nOnExIsTeNtCoMmAndZIOAGA2329jdbfaFkahDf21234h8z43 $argv"
end

# Return 0 if the last token is the one provided as argument
function __fish_tem_last_arg
    string match -q -- $argv[1] (commandline -cpo | tail -1)
end

function __fish_tem_ls
    set -l comp (commandline -ct)
    # Iterate through repository paths
    for repo in (tem repo -lp)
        pushd "$repo"
        if [ "$argv[1]" = '/' ]
            __fish_complete_directories "$comp" ''
        else
            __fish_tem_complete_files "$comp"
        end
        popd
    end
end

# Generate completions for -R/--repo option
function __fish_tem_complete_R
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
function __fish_tem_repo_completions
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
complete -c tem -s 'R' -l 'repo' -d 'Used repositories' -a "(__fish_tem_complete_R)" -frk
# }}}

# {{{ tem put

__fish_tem_complete_put -f\
    -a "(__fish_tem_ls)"\
    -n 'not __fish_tem_last_arg -d && not __fish_tem_last_arg -o'

__fish_tem_complete_put -s 'o' -l 'output' -rkF -d 'Destination file'

__fish_tem_complete_put -s 'd' -l 'directory' -rf -d 'Destination directory'\
    -a "(__fish_complete_directories)"

# }}}

# {{{ tem add

__fish_tem_complete_add -s 'd' -l 'directory' -rkf -d 'Destination directory'\
    -a "(__fish_tem_ls /)"

__fish_tem_complete_add -s 'o' -l 'output' -rkf -d 'Destination file'\
    -a "(__fish_tem_ls)"

# }}}

# {{{ tem rm
__fish_tem_complete_rm -f -a "(__fish_tem_ls)"
# }}}

# {{{ tem repo
__fish_tem_complete_repo -a "(__fish_tem_repo_completions)" -f
__fish_tem_complete_repo -s 'l' -l 'list' -d 'List repositories' -f
# }}}

# {{{ tem config

__fish_tem_complete_config -f
__fish_tem_complete_config -s 'f' -l 'file' -r -a '(__fish_complete_directories)'

# }}}

# {{{ tem cd
__fish_tem_complete_cd -f -a "(complete -C (commandline -cp | sed 's/cd/repo/') | grep -v -- '^--*.*')"
# }}}

# vim: ft=fish foldmethod=marker sw=4
