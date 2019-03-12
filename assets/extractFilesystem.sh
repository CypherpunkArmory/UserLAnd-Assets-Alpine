#!/support/busybox sh

if [ ! -f /support/rootfs.tar.gz ]; then
   /support/busybox cat /support/rootfs.tar.gz.part* > /support/rootfs.tar.gz 
   /support/busybox rm -f /support/rootfs.tar.gz.part*
fi

/support/busybox tar -xzvf /support/rootfs.tar.gz -C /

if [[ $? == 0 ]]; then
	/support/addNonRootUser.sh
	/support/busybox touch /support/.success_filesystem_extraction
	/support/busybox rm -f /support/rootfs.tar.gz
else
	/support/busybox touch /support/.failure_filesystem_extraction
fi
