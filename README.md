# git-clone-gitlab-all-projects-from-a-groups.sh

Bash script to download repositories from a GitLab instance.

The script assume you will clone/pull over SSH.

Requirements: bash, curl, jq

## Download all projects from a group

```sh
./git-clone-gitlab-all-projects-from-a-groups.sh
Options:
  -d, --destination Destination path
  -g, --group-id    ID's group to clone
  -t, --token       Gitlab token
  -u, --gitLab-url  GitLab URL (e.g. https://gitlab.com)
  -h, --help        Display this help and exit
  -v, --version     Output version information and exit

```

It will clone all repos in `group` to the `destination` folder and keep the tree structure. If a repo already exists, it will be pulled.
```
>>> tree
   .
    └── target_group
        └── subgroup1
            └── project-1
            └── subgroup2
                └── project-2
                └── ...
```       

## RUNNING ON WINDOWS
Download : 
* git bash : https://gitforwindows.org/
* jq : https://stedolan.github.io/jq/download/ (put the exe in the git bash directory, could be: C:\Users\XXX\AppData\Local\Programs\Git\usr\bin and rename it 'jq')
