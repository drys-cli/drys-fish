function cd_help_
    echo -e "usage: tem cd [-h] [-c FILE] [-R REPO] [--reconfigure] [repository]\n"
    echo -e "positional arguments:"
    echo -e "  repository           \trepository name, pseudo-path or path to cd to\n"
    echo -e "optional arguments:"
    echo -e "  -p, --path           \tcd to '.tem/path' if available"
    echo -e "  -e, --env            \tcd to '.tem/env' if available"
    echo -e "  -f, --fish-env       \tcd to '.tem/fish-env' if available"
    echo -e "  -H, --hooks          \tcd to '.tem/hooks' if available\n"
    echo -e "general options:"
    echo -e "  -h, --help           \tshow this help message and exit"
    echo -e "  -c FILE, --config FILE"
    echo -e "\t\t\tuse the specified configuration file"
    echo -e "  -R REPO, --repo REPO \tuse the repository REPO (can be used multiple times)"
    echo -e "  --reconfigure        \tdiscard any configuration loaded before reading this option"
end

function cd_
    set -l args 'h/help' 'e/env' 'p/path' 'f/fish-env' 'H/hooks'
    # Parse and remove recognized options
    argparse -i $args -- $argv
    # Used to report unrecognized options
    argparse $args -- $argv 2>/dev/null
    if [ "$status" != 0 ]
        echo "tem: error: unrecognized arguments: $argv[2]"
        return 2
    end
    # TODO WHY THE HELL IS _flag_env NOT SET HERE??
    # The following shows that _flag_env is not empty:
    # set -S _flag_env
    # But this shows that _flag_env is empty:
    # echo "$_flag_env"
    # HOW THE HELL IS THIS POSSIBLE?????
    if [ -n "$_flag_help" ]     # --help option
        cd_help_; return
    end
    for x in path fish-env hooks env 
        if [ -n (eval echo '$_flag_'(string replace '-' '_' "$x")) ]
            set -l tem_project (first_tem_project_)
            if [ -d "$tem_project/.tem/$x" ]
                disable_auto_env_
                cd "$tem_project/.tem/$x/"
                enable_auto_env_
                return
            else
                echo "tem: error: '.tem/$x/' does not exist" >&2
                return 1
            end
        end
    end
    # Call `tem repo` with the same tem arguments
    set -l argv[(contains -i -- cd $argv)] 'repo'
    set -l dest (command tem $argv -lp | head -1)
    [ -n "$dest" ] && cd "$dest"
end
