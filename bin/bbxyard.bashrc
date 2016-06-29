# bbxyard bash run script
# define some useful functions
# @author boxu
# @create 2015.11.19


# color echo
NORMAL=$(tput sgr0)
RED=$(tput setaf 1; tput bold)
BLUE=$(tput setaf 4; tput bold)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3; tput bold)
function red()    { echo -e "$RED$*$NORMAL"; }
function blue()   { echo -e "$BLUE$*$NORMAL"; }
function green()  { echo -e "$GREEN$*$NORMAL"; }
function yellow() { echo -e "$YELLOW$*$NORMAL"; }


# safe tmp work dir
THIS_SCRIPT=$0
[ "${THIS_SCRIPT:0:1}" == "-" ] && THIS_SCRIPT=${THIS_SCRIPT:1}
TMP_DIR=$HOME/var/run/$(basename "$THIS_SCRIPT").$$
function do_init_tmp_dir() { mkdir -p "$TMP_DIR"; }
function do_fini_tmp_dir() { rm -rvf  "$TMP_DIR"; }


# sudo wrap
function invoke_sudo()
{
    # sent the pass and invoke a null command once.
    echo $SUDO_PASSWD | sudo -S cat /dev/null
    # execute the real command
    sudo $@
}

# test can I have root power!
function amiroot()
{
    ROOT_UID=0
    echo "input $1"
    if [ "$UID" = "$ROOT_UID" ]; then
        echo "You are root"
    else
        echo "You are just an ordinary user(but mom loves you too)."
    fi
}

# verify and re-symbol dir link
function verify_dir_symlink()
{
	src_file=$1
	dst_link=$2

	# if dir-link exists unlink
	[ -h "$dst_link" ] && unlink "$dst_link"

	# if dir-real exists rename with date
	if [ -d "$dst_link" ]; then
		NOW=$(date +%Y-%m-%d-%H-%M-%S)
		mv "$dst_link" "$dst_link.$NOW"
	fi

	# re-link
	[ ! -d "$dst_link" ] && ln -s "$src_file" "$dst_link"
}

# get os release name
function get_os_name()
{
    RETVAL=0
    for ((i=0; i<1; ++i))
    {
        os_type=$(uname -s)
        case "$os_type" in
            Linux)
                fr=/etc/issue
                grep -io Ubuntu     "$fr" && break;
                grep -io LinuxMint  "$fr" && break;
                grep -io Redhat     "$fr" && break;
                grep -io CentOS     "$fr" && break;
                grep -io Suse       "$fr" && break;
                ;;
            Darwin)  echo "Darwin"  ;;
            FreeBSD) echo "FreeBSD" ;;
            *)
                echo "Unknown"
                RETVAL=-1
                ;;
        esac
    }
    return $RETVAL
}

# get user bash profile
function get_user_bash_profile()
{
    os_name=$(get_os_name)
    case "$os_name" in
        Ubuntu|Mint|Suse)
            echo "$HOME/.bashrc"
            ;;
        *)
            echo "$HOME/.bash_profile"
            ;;
    esac
    return 0;
}

# git operator
function git_auto_pom()
{
    git commit -am "$1"
    git push origin master
}
