# {{{ tem (main command)
function tem
    # This is just a way to source this file on fish startup (cf. manpage)
    if [ "$argv" = 'fish-init' ]
        return
    end
    for arg in $argv
        # First non-option argument is a subcommand
        if [ (echo "$arg" | cut -c 1) != "-" ]
            switch "$arg"
                case cd
                    __fish_tem_cd $argv
                    return $status
                case env
                    __fish_tem_env $argv
                    return $status
            end
            break
        else if contains -- "$arg" '-h' '--help'
            __fish_tem_print_extended_help
            return
        end
    end
    command tem $argv
end

function __fish_tem_print_extended_help
    command tem -h
    echo -e "\nfish commands:\n"
    echo -e "    cd\t\t\tcd to repository directory"
    echo -e "    env\t\t\textends the vanilla env subcommand with more features"
    echo -e "    fish-init\t\tcall this in fish startup script to enable advanced functionality"
end
#}}}

# {{{ tem cd
function __fish_tem_cd_help
    echo -e "usage: tem cd [-h] [-c FILE] [-R REPO] [--reconfigure] [repository]\n"
    echo -e "positional arguments:"
    echo -e "  repository           \trepository name, pseudo-path or path to cd to\n"
    echo -e "optional arguments:"
    echo -e "  -h, --help           \tshow this help message and exit"
    echo -e "  -c FILE, --config FILE"
    echo -e "\t\t\tuse the specified configuration file"
    echo -e "  -R REPO, --repo REPO \tuse the repository REPO (can be used multiple times)"
    echo -e "  --reconfigure        \tdiscard any configuration loaded before reading this option"
end

function __fish_tem_cd
    argparse -i 'h/help' -- $argv
    if [ -n "$_flag_help" ]     # --help option
        __fish_tem_cd_help; return 0
    end
    # Call `tem repo` with the same tem arguments
    set -l argv[(contains -i -- cd $argv)] 'repo'
    cd (command tem $argv -lp | head -1)
    return $status
end
# }}}

# {{{ tem env

# Helper that copies a function with the name 'old' into 'new'
function __fish_tem_copy_function --argument old new
    functions -e "$new"
    functions -c "$old" "$new"
end

function __fish_tem_env
    argparse -i 'h/help' 'S/no-source' 'X/no-exec'  \
        'A/aliases' 'E/editor' 'l/list' -- $argv
    if [ -n "$_flag_help" ]                         # --help option
        __fish_tem_env_help; return 0
    end
    if [ -n "$_flag_aliases" ]                      # --aliases option
        printf "%s '%s'\n" $__fish_tem_env_aliases
        return 0
    end

    # Check for env directory
    if [ -z "$_flag_no_source" -a -d '.tem/fish-env' ]
        if not contains -- "$PWD/.tem/path" $PATH
            set -gx PATH "$PWD/.tem/path" $PATH
        end
        set -gx TEM_ROOTDIR "$PWD"
        __fish_tem_env_exec
    end
    # Also run vanilla command if no -X option was specified
    if [ -z "$_flag_no_exec" ]
        # Options that vanilla `tem env` doesn't recognize were removed by argparse
        command tem $argv
        return $status
    end
end

function __fish_tem_env_help
    command tem env -h
    echo -e "\nfish extension:"
    echo -e "  -S, --no-source\tignore files in .tem/fish-env/"
    echo -e "  -X, --no-exec\t\tignore files in .tem/env/"
    echo -e "  -A, --aliases\t\tlist aliases defined by the command alias"
end

# This will run `tem env` every time the user cd's into a directory that has a
# a .tem/ subdirectory, or one of its parent directories does
function __fish_tem_env_auto --on-variable PWD
    # This variable is used to prevent the rest of this function from
    # being triggered when we modify PWD within this function. That would cause
    # an infinite recursion.
    if [ -n "$__fish_tem_env_auto_disable" ]; return; end

    set -l _PWD "$PWD"
    # Effectively perform `cd ..` until the current directory contains '.tem/env'
    # or '.tem/fish-env'. Then run `tem env` in that directory.
    while [ "$_PWD" != '/' ]
        if [ -d "$_PWD/.tem/fish-env" -o -d "$_PWD.tem/env" ]
            # Disable event-handling for this function temporarily          (*)
            set -g __fish_tem_env_auto_disable 'true'

            pushd "$_PWD"
            set -e __fish_tem_env_aliases
            tem env
            set -l __status $status
            popd

            # Re-enable it                                                  (*)
            set -g __fish_tem_env_auto_disable ''
            return $__status
        end
        set _PWD (dirname "$_PWD")
    end
end

function __fish_tem_env_exec
    # Extend definition of the alias function to record all aliases that were
    # created in the sourced files (to the variable __fish_tem_env_aliases)
    set -g __fish_tem_env_aliases
    __fish_tem_copy_function alias __fish_tem_alias_backup
    function alias --argument name cmd
        __fish_tem_alias_backup "$name" "$cmd"
        set -a __fish_tem_env_aliases "$name" "$cmd"
    end
    # Source the files
    set -l files .tem/fish-env/*
    for file in $files; source "$file"; end
    # Restore function alias to what it was before
    __fish_tem_copy_function __fish_tem_alias_backup alias
end
# }}}

# vim: ft=fish foldmethod=marker
