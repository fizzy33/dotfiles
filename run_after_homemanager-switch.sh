#!/bin/bash

set -e

if [ $USER == "root" ]; then
    sudo -u homemanager chezmoi update
    /home/dev/.nix-profile/bin/mirror-home-manager-profile.py run --force --source /home/homemanager --target ~
    ~/.nix-profile/bin/link-nix-tools
else
    cd ~/.config/home-manager

    export PATH=$PATH:/nix/var/nix/profiles/default/bin/

    echo "running home-manager switch"
    nix-shell --run "home-manager switch -b backup"
fi
