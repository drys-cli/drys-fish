function env_
    argparse -i 'h/help' 'S/no-source' 'X/no-exec'  \
        'A/aliases' 'E/editor' 'l/list' -- $argv
    if [ -n "$_flag_help" ]                         # --help option
        env_help_
        return
    end
    if [ -n "$_flag_aliases" ]                      # --aliases option
        [ -n "$env_aliases_" ] && printf "%s '%s'\n" $env_aliases_
        return 0
    end

    if [ -z "$_flag_no_source" ]
        if [ -d '.tem' ] && [ "$PATH[1]" != "$PWD/.tem/path" ]
            set -gx PATH "$PWD/.tem/path" $PATH
        end
        [ -d '.tem/fish-env' ] && env_exec_
    end
    # Also run vanilla command if no -X option was specified
    if [ -z "$_flag_no_exec" ]
        # Bring back options that argparse consumed
        [ -n "$_flag_list" ] && set -la argv '-l'
        # Options that vanilla `tem env` doesn't recognize were removed by argparse
        command tem $argv
        return
    end
end

function env_help_
    command tem env -h
    echo -e "\nfish extension:"
    echo -e "  -S, --no-source\tignore files in .tem/fish-env/"
    echo -e "  -X, --no-exec\t\tignore files in .tem/env/"
    echo -e "  -A, --aliases\t\tlist aliases defined by the command alias"
end

# This will run `tem env` every time the user cd's into a temdir
# or a dir that has a temdir as its (grand)parent
function env_auto_ --on-variable PWD
    # TODO Consider what happens if this function is somehow aborted
    env_auto_disabled_ && return
    disable_auto_env_
    # cd to the first parent directory (or ./) containing .tem/env or
    # .tem/fish-env and run `tem env` there.
    set -l tem_project (first_tem_project_)
    if [ -n "$tem_project" -a \( -d "$tem_project/.tem/env" -o -d "$tem_project/.tem/fish-env" \) ]
        pushd "$tem_project"
        set -e env_aliases_
        tem env
        set -l _status $status
        popd
        enable_auto_env_
        return $_status
    end
    enable_auto_env_
end

# --exec option
function env_exec_
    redefine_alias_
    # Source the files
    set -l files .tem/fish-env/*
    for file in $files; source "$file"; end
    restore_alias_
end

# Extend definition of the `alias` function to record all aliases that were
# created in the sourced files (to the variable env_aliases_)
function redefine_alias_
    set -g env_aliases_
    copy_function_ alias alias_backup_
    function alias --argument name cmd
        alias_backup_ "$name" "$cmd"
        set -a env_aliases_ "$name" "$cmd"
    end
end

# Restore definition of function alias to what it was before
function restore_alias_
    copy_function_ alias_backup_ alias
end
