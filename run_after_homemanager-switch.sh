#!/bin/bash

set -e

if [ $USER == "root" ]; then
    
    if id homemanager >/dev/null 2>&1; then
        echo 'homemanager user exists'
    else
        echo "creating homemanager user"
        adduser --disabled-password --gecos "user for canonical homemanager setup" homemanager
        sudo -u homemanager chezmoi init https://fizzy33@github.com/fizzy33/dotfiles
    fi
    
    echo "running chezmoi update on homemanager"
    sudo -u homemanager chezmoi update

    echo "linking homemanager home into root"
    ~homemanager/.nix-profile/bin/mirror-home-manager-profile.py run --force --source ~homemanager --target ~
    
    echo "linking tools from nix store into /usr/local/bin"
    ~/.nix-profile/bin/link-nix-tools run

else
    cd ~/.config/home-manager

    export PATH=$PATH:/nix/var/nix/profiles/default/bin/

    echo "running home-manager switch"
    nix-shell --run "home-manager switch -b backup"
fi
