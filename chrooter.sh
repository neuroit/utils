#/bin/bash                                                                                                                                            
# manage chroot environment                                                                                                                           
#                                                                                                                                                     

function bootstrap {
    if [ ! -d $isolroot ]; then
        echo "Create: $isolroot"
        mkdir $isolroot
        apt-get debootstrap
        isolroot=/mnt/data/isol
        mkdir $isolroot
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

isolroot=${2:-"/data/mnt/isolroot"}
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
      echo -e "option unknown.\n"
      echo -e $opts
      exit 1
      ;;
  esac
done
