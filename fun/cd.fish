function cd_help_
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

function cd_
    argparse -i 'h/help' -- $argv
    if [ -n "$_flag_help" ]     # --help option
        cd_help_; return 0
    end
    # Call `tem repo` with the same tem arguments
    set -l argv[(contains -i -- cd $argv)] 'repo'
    cd (command tem $argv -lp | head -1)
    return $status
end
