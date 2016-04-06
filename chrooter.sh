#/bin/bash                                                                                                                                            
# manage chroot environment on ubuntu                                                                                                                        
#                                                                                                                                                     

function bootstrap {
    if [ ! -d $isolroot ]; then
        echo "Creating $isolroot"
        mkdir $isolroot
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -q
        apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" debootstrap
        debootstrap $ubuntu_version $isolroot
    else
        echo "Directory $isolroot exists already. Choose another one."
        exit 0
    fi
}

function mountchroot {
     mount -t proc proc $isolroot/proc
     mount -t sysfs -o rw,noexec,nosuid,nodev none $isolroot/sys
     mount -o bind /dev $isolroot/dev
}

function umountchroot {
     umount $isolroot/proc
     umount $isolroot/sys
     umount $isolroot/dev
}

function do_chroot {
  chroot $isolroot
}

isolroot=${2:-"/isolroot"}
ubuntu_version=${3:-"trusty"}

opts="-b bootstrap a new root in $isolroot\n-m mount fs in $isolroot\n-u umount fs in $isolroot\n-c chroot into $isolroot"
while getopts "bmuc" opt; do
  case $opt in
    b)
      bootstrap
      ;;
    m)
      mountchroot
      ;;
    u)
      umountchroot
      ;;
    c)
      do_chroot
      ;;
   \?)
      echo -e "\noptions:\n$opts\n"
      echo -e "usage:\n    chrooter.sh <option> <path to new root> <ubuntu version to install>"
      exit 1
      ;;
  esac
done
