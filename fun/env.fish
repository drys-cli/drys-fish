function env_
    argparse -i 'h/help' 'S/no-source' 'X/no-exec'  \
        'A/aliases' 'E/editor' 'l/list' -- $argv
    if [ -n "$_flag_help" ]                         # --help option
        env_help_
        return 0
    end
    if [ -n "$_flag_aliases" ]                      # --aliases option
        [ -n "$env_aliases_" ] && printf "%s '%s'\n" $env_aliases_
        return 0
    end

    if [ -z "$_flag_no_source" ]
        if [ -d '.tem' ]; and not contains -- "$PWD/.tem/path" $PATH
            set -gx PATH "$PWD/.tem/path" $PATH
        end
        if [ -d '.tem/fish-env' ]
            set -gx TEM_ROOTDIR "$PWD"
            env_exec_
        end
    end
    # Also run vanilla command if no -X option was specified
    if [ -z "$_flag_no_exec" ]
        # Options that vanilla `tem env` doesn't recognize were removed by argparse
        command tem $argv
        return $status
    end
end

function env_help_
    command tem env -h
    echo -e "\nfish extension:"
    echo -e "  -S, --no-source\tignore files in .tem/fish-env/"
    echo -e "  -X, --no-exec\t\tignore files in .tem/env/"
    echo -e "  -A, --aliases\t\tlist aliases defined by the command alias"
end

# This will run `tem env` every time the user cd's into a directory that has a
# a .tem/ subdirectory, or one of its parent directories does
function env_auto_ --on-variable PWD
    # This variable is used to prevent the rest of this function from
    # being triggered when we modify PWD within this function. That would cause
    # an infinite recursion.
    if [ -n "$env_auto_disable_" ]; return; end

    set -l _PWD "$PWD"
    # Effectively perform `cd ..` until the current directory contains '.tem/env'
    # or '.tem/fish-env'. Then run `tem env` in that directory.
    while [ "$_PWD" != '/' ]
        if [ -d "$_PWD/.tem/fish-env" -o -d "$_PWD.tem/env" ]
            # Disable event-handling for this function temporarily          (*)
            set -g env_auto_disable_ 'true'

            pushd "$_PWD"
            set -e env_aliases_
            tem env
            set -l __status $status
            popd

            # Re-enable it                                                  (*)
            set -g env_auto_disable_ ''
            return $__status
        end
        set _PWD (dirname "$_PWD")
    end
end

function env_exec_
    # Extend definition of the alias function to record all aliases that were
    # created in the sourced files (to the variable env_aliases_)
    set -g env_aliases_
    copy_function_ alias alias_backup_
    function alias --argument name cmd
        alias_backup_ "$name" "$cmd"
        set -a env_aliases_ "$name" "$cmd"
    end
    # Source the files
    set -l files .tem/fish-env/*
    for file in $files; source "$file"; end
    # Restore function alias to what it was before
    copy_function_ alias_backup_ alias
end