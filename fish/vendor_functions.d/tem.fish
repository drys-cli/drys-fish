function __fish_tem_print_extended_help
    command tem -h
    echo -e "\nfish commands:\n"
    echo -e "    cd\t\t\tcd to repository directory"
    echo -e "    env\t\t\textends the vanilla env subcommand with more features"
end

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

function __fish_tem_env_help
    command tem env -h
    echo -e "\nfish extension:"
    echo -e "  -S, --no-source\tdo not source any files into the current shell"
    echo -e "  -X, --no-exec\t\tdo not execute any files"
    echo -e "  -a, --aliases\t\tlist aliases defined by the command alias"
end

function __fish_tem_command_cd
    argparse -i 'h/help' -- $argv
    if [ -n "$_flag_help" ]     # --help option
        __fish_tem_cd_help; return 0
    end
    # Call `tem repo` with the same tem arguments
    set -l argv[(contains -i -- cd $argv)] 'repo'
    cd (command tem $argv -lp | head -1)
    return $status
end

# This function is run on cd
function __fish_tem_command_env_auto --on-variable PWD
    set scripts (expand '.tem/env/*' 2>/dev/null)
    if [ -d '.tem/env' -a (count $scripts) ]
        tem env
    else
        set -e __fish_tem_env_aliases
    end
end

# Helper that copies a function with the name 'old' into 'new'
function __fish_tem_copy_function --argument old new
    functions -e "$new"
    functions -c "$old" "$new"
end

function __fish_tem_command_env
    argparse -i 'h/help' 'S/no-source' 'X/no-exec' 'a/aliases' -- $argv
    if [ -n "$_flag_help" ]     # --help option
        __fish_tem_env_help; return 0
    end
    if [ -n "$_flag_aliases" ]  # --aliases option
        printf '%s\n' $__fish_tem_env_aliases
    end

    set -le _flag_S _flag_X
    # Check for env directory
    if [ -z "$_flag_no_source" -a -d '.tem/env' ]
        # Extend definition of alias function to record all aliases that were
        # created in the sourced files (to the variable __fish_tem_env_aliases)
        set -g __fish_tem_env_aliases
        __fish_tem_copy_function alias __fish_tem_alias_backup
        function alias --argument name cmd
            __fish_tem_alias_backup "$name" "$cmd"
            set -a __fish_tem_env_aliases "$name"
        end
        # Source the files
        set -l files .tem/env/*.fish
        for file in $files; source "$file"; end
        # Restore alias to what it was before
        __fish_tem_copy_function __fish_tem_alias_backup alias
    end
    # Also run vanilla command if no -X option was specified
    if [ -z "$_flag_no_exec" ]
        # Remove options that the vanilla `tem env` doesn't recognize
        for arg in -S --no-source -X --no-exec
            set -l index (contains -i -- $arg $argv)
            [ -n "$index" ] && set -le argv[$index]
        end
        command tem $argv
        return $status
    end
end

function tem
    for arg in $argv
        # First non-option argument is a subcommand
        if [ (echo "$arg" | cut -c 1) != "-" ]
            switch "$arg"
                case cd
                    __fish_tem_command_cd $argv
                    return $status
                case env
                    __fish_tem_command_env $argv
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

# vim: ft=fish
