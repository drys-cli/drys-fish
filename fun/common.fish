# Helper that copies a function with the name 'old' into 'new'
function copy_function_ --argument old new
    functions -e "$new"
    functions -c "$old" "$new"
end

function disable_auto_env_
    set -g env_auto_disable_ 'true'
end

function enable_auto_env_
    set -e env_auto_disable_
end

function env_auto_disabled_
    [ -n "$env_auto_disable_" ]
    return $status
end

# If this directory contains a .tem/ subdir, return $PWD
# Otherwise return the abspath to the first parent dir with a .tem/ subdir
function first_tem_project_
    set -l _PWD "$PWD"
    # Effectively perform `cd ..` until the current directory contains '.tem/env'
    # or '.tem/fish-env'
    while [ "$_PWD" != '/' ]
        if [ -d "$_PWD/.tem" ]
            echo "$_PWD"
            return
        end
        set _PWD (dirname "$_PWD")
    end
    return 1
end
