# UserLAnd-Assets-Alpine

A repository for holding Alpine Linux specific assets for UserLAnd

First You Need To Clone The Repo:

`git clone https://github.com/CypherpunkArmory/UserLAnd-Assets-Alpine.git`

Then You Neeed To Build Alpine:

`cd UserLAnd-Assets-Alpine`
`sudo sh scripts/buildArch.sh x86_64 (or any other arch you want)`

the arch can be arm, arm64, x86 or x86_64

### How To Use Alpine-Chroot
alpine-chroot is like the buildArch
script. but for any pc. 

`sudo sh /UserLAnd-Assets-Alpine/Alpine-Chroot.sh`

#### How to use alpine
here are some simple commands:

* add	Add new packages to the running system

* del	Delete packages from the running system

* fix	Attempt to repair or upgrade an installed package

* update	Update the index of available packages

* info	Prints information about installed or available packages

* search	Search for packages or descriptions with wildcard patterns

* upgrade	Upgrade the currently installed packages

* cache	Maintenance operations for locally cached package repository

* version	Compare version differences between installed and available packages

* index	create a repository index from a list of packages

* fetch	download (but not install) packages

* audit	List changes to the file system from pristine package install state

* verify	Verify a package signature

* dot	Create a graphviz graph description for a given package

* policy	Display the repository that updates a given package, plus repositories that also offer the package

### Notes

Maintained By EnderNightLord-Chromebook

About: https://alpinelinux.org/about/

Package Management: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management

<img src="https://github.com/CypherpunkArmory/UserLAnd-Assets-Alpine/blob/master/icons/Alpine_Icon.svg" alt="Alpine_Linux_Icon"/>
