#!/bin/bash

if [ $USER == "root" ]; then
    /home/dev/.nix-profile/bin/link-nix-tools
    /home/dev/.nix-profile/bin/mirror-home-manager-profile.py run --force --source /home/dev --target ~
else
    cd ~/.config/home-manager

    export PATH=$PATH:/nix/var/nix/profiles/default/bin/

    echo "running home-manager switch"
    nix-shell --run "home-manager switch -b backup"
fi
