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
                    cd_ $argv
                    return $status
                case env
                    env_ $argv
                    return $status
            end
            break
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
    echo -e "    cd\t\t\tcd to repository directory"
    echo -e "    env\t\t\textends the vanilla env subcommand with more features"
    echo -e "    fish-init\t\tcall this in fish startup script to enable advanced functionality"
end
