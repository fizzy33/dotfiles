#!/bin/sh

cd ~/.config/nixpkgs

export PATH=$PATH:/nix/var/nix/profiles/default/bin/

nix-shell --run "home-manager switch -b backup"
