function __fish_tem_print_extended_help
    command tem -h
    echo -e "\nfish commands:\n"
    echo -e "    cd\t\t\tcd to repository directory"
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

function tem
    for arg in $argv
        # First non-option argument is a subcommand
        if [ (echo "$arg" | cut -c 1) != "-" ]
            # COMMAND cd
            if [ "$arg" = "cd" ]
                # tem cd --help
                if contains -- '-h' $argv -o contains -- '--help' $argv
                    __fish_tem_cd_help
                    return
                end
                # tem cd arguments...
                set -l argv[(contains -i cd $argv)] 'repo'
                cd (tem $argv -lp | head -1)
                return $status
            # COMMAND IS NOT PART OF THIS FISH EXTENSION
            else; break; end
        else if contains -- "$arg" '-h' '--help'
            __fish_tem_print_extended_help
            return
        end
    end
    command tem $argv
end

# vim: ft=fish
