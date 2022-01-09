function tem
    # NOTE: Each entrypoint to vanilla tem should export TEM_SHELL=fish
    set -lx TEM_SHELL "fish"

    # This is just a way to source this file on fish startup (cf. manpage)
    if [ "$argv" = 'fish-init' ]
        env_auto_
        return
    end
    for arg in $argv
        # First non-option argument is a subcommand
        if [ (echo "$arg" | cut -c 1) != "-" ]
            # Call the subcommand that matches $arg
            set -l function __fish_tem"_$arg"
            if functions -q "$function"
                "$function" $argv
                return
            else
                break
            end
        else if contains -- "$arg" '-h' '--help'
            print_extended_help_
            return
        end
    end
    command tem $argv
end

function print_extended_help_
    command tem -h
    echo -e "\nfish commands:\n"
    echo -e "    cd\t\t      \tcd to repository directory"
    echo -e "    env\t\t     \textends the vanilla env subcommand with more features"
    echo -e "    fish-init\t \tcall this in fish startup script to enable advanced functionality"
end
