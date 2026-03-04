## Git-LFSのWSL側設定
```
$ curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
[sudo] password for kazama: 
Detected operating system as Ubuntu/noble.
Checking for curl...
Detected curl...
Checking for gpg...
Detected gpg...
Detected apt version as 2.8.3
Running apt-get update... done.
Installing apt-transport-https... done.
Installing /etc/apt/sources.list.d/github_git-lfs.list...done.
Importing packagecloud gpg key... Packagecloud gpg key imported to /etc/apt/keyrings/github_git-lfs-archive-keyring.gpg
done.
Running apt-get update... done.

The repository is setup! You can now install packages.
$ sudo apt-get install git-lfs
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  git-lfs
0 upgraded, 1 newly installed, 0 to remove and 22 not upgraded.
Need to get 8,919 kB of archives.
After this operation, 19.2 MB of additional disk space will be used.
Get:1 https://packagecloud.io/github/git-lfs/ubuntu noble/main amd64 git-lfs amd64 3.7.0 [8,919 kB]
Fetched 8,919 kB in 1s (8,030 kB/s)
Selecting previously unselected package git-lfs.
(Reading database ... 94474 files and directories currently installed.)
Preparing to unpack .../git-lfs_3.7.0_amd64.deb ...
Unpacking git-lfs (3.7.0) ...
Setting up git-lfs (3.7.0) ...
Git LFS initialized.
Processing triggers for man-db (2.12.0-4build2) ...
```
```
$ git lfs install
Updated Git hooks.
Git LFS initialized.
$ cat .gitattributes
*.docx filter=lfs diff=lfs merge=lfs -text
*.xlsx filter=lfs diff=lfs merge=lfs -text
$ cat .lfsconfig
[lfs]
        url = http://192.168.10.20:8080/git/Gijutsubu/CMVP.git/info/lfs
```


ls /mnt/c/git-credential-manager

