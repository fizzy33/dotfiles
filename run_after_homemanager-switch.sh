#!/bin/sh

cd ~/.config/home-manager

export PATH=$PATH:/nix/var/nix/profiles/default/bin/

echo "running home-manager switch"
nix-shell --run "home-manager switch -b backup"
