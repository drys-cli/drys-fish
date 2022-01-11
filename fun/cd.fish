function cd_help_
    command tem find --help | sed 's/^usage: tem find/usage: tem cd/'
end


function cd_
    argparse -i 'h/help' -- $argv

    if [ -n "$_flag_help" ]
        cd_help_
        return
    end

    # FIXME This isn't 100% general: what if an option argument is equal to "cd"
    set -l modified_argv
    for arg in $argv
        if [ "cd" != "$arg" ]
            set -a modified_argv "$arg"
        end
    end

    cd (tem find $modified_argv)
end
