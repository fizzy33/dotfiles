{ config, pkgs, lib, ... }:

let

  system = builtins.currentSystem;

  sources = import ./nix/sources.nix;

  nixpkgs = import sources.nixpkgs-unstable { inherit system; };

  a8-scripts = import sources.a8-scripts { inherit system nixpkgs; };

  runitor = 
    nixpkgs.buildGoModule rec {
      pname = "runitor";
      version = "1.2.0";
      vendorSha256 = null;
      src = nixpkgs.fetchurl {
        url = "https://github.com/bdd/runitor/archive/refs/tags/v1.2.0.tar.gz";
        sha256 = "03a2ayxrfdjbq7mcw87cqg470gg7bbwb34cij0wrbr4vafadkf4h";
      };
    };

  pgbackrest = 
    nixpkgs.stdenv.mkDerivation rec {
      pname = "pgbackrest";
      version = "2.41";

      src = nixpkgs.fetchFromGitHub {
        owner = "pgbackrest";
        repo = "pgbackrest";
        rev = "release/${version}";
        sha256 = "sha256-AaFctLXhzq3Wk+KjxskxazpNEX7UAmXeiJxhYXYwksk=";
      };

      nativeBuildInputs = [ nixpkgs.pkg-config ];
      buildInputs = [ nixpkgs.postgresql nixpkgs.openssl nixpkgs.lz4 nixpkgs.bzip2 nixpkgs.libxml2 nixpkgs.zlib nixpkgs.zstd nixpkgs.libyaml ];

      postUnpack = ''
        sourceRoot+=/src
      '';

      meta = with lib; {
        description = "Reliable PostgreSQL backup & restore";
        homepage = "https://pgbackrest.org/";
        changelog = "https://github.com/pgbackrest/pgbackrest/releases";
        license = licenses.mit;
        maintainers = with maintainers; [ zaninime ];
      };
    };

  linuxOnly = lib.strings.hasInfix "linux" builtins.currentSystem;
  everythingButM1Mac = builtins.currentSystem != "aarch64-darwin";

in
{

  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };

  programs.home-manager.enable = true;

  # The home-manager manual is at:
  #
  #   https://rycee.gitlab.io/home-manager/release-notes.html
  #
  # Configuration options are documented at:
  #
  #   https://rycee.gitlab.io/home-manager/options.html

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  #
  # You need to change these to match your username and home directory
  # path:


  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # If you use non-standard XDG locations, set these options to the
  # appropriate paths:
  #
  # xdg.cacheHome
  # xdg.configHome
  # xdg.dataHome

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
  # programs.direnv.nix-direnv.enableFlakes = true;

  programs.atuin.enable = true;

  programs.atuin.flags = [ "--disable-up-arrow" ];

  # programs.powerline-go.enable = true;

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "bass";
        src = nixpkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "50eba266b0d8a952c7230fca1114cbc9fbbdfbd4";
          sha256 = "0ppmajynpb9l58xbrcnbp41b66g7p0c9l2nlsvyjwk6d16g4p4gy";
        };
      }

      {
        name = "foreign-env";
        src = nixpkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
      }
    ];
    shellAliases = {
      cp    = "cp -iv";
      ls    = "exa --long --git --group --all --sort=.name";
      lx    = "exa --long --git --group --all --sort=.name";
      less  = "less -FSRXc";
      ll    = "ls -FGlAhp";
      lsd   = "ls -FGlAhpd";  #for use with find like `lsd (find .)` 
      mkdir = "mkdir -pv";
      mv    = "mv -iv";
      xt    = "exa --long --git --group --all --tree";
      xl    = "exa --long --git --group --all --sort=.name --sort=type";
      which = "which -a";
      bip   = "echo bip";
    };
  };


  home.packages = [
    a8-scripts.a8-scripts
    nixpkgs.ammonite
    # my-ammonite
    # nixpkgs.activemq
    nixpkgs.awscli
    nixpkgs.bottom
#    nixpkgs.chezmoi
    nixpkgs.curl
    # nixpkgs.diffoscope    
    nixpkgs.direnv
    nixpkgs.drone-cli
    nixpkgs.exa  
    nixpkgs.fish
    nixpkgs.git
    nixpkgs.git-crypt
    nixpkgs.gnupg
    # nixpkgs.haxe_4_0
    nixpkgs.htop
    nixpkgs.httping
    nixpkgs.iftop
    nixpkgs.jdk11
    # this clashes with nettools
    # nixpkgs.inetutils
    nixpkgs.jq
    # my-java
    # nixpkgs.ipython
    nixpkgs.lf
    nixpkgs.mc
    nixpkgs.micro
    nixpkgs.mtr
    nixpkgs.mypy
    nixpkgs.nano
    nixpkgs.ncdu
    nixpkgs.ncftp
    nixpkgs.nettools
    nixpkgs.niv
    nixpkgs.nnn
    pgbackrest
    nixpkgs.pgcli
    # nixpkgs.powerline-go
    nixpkgs.pstree
    nixpkgs.pv
    # my-python3
    nixpkgs.ripgrep
    runitor
    nixpkgs.rsync
    nixpkgs.s3cmd
    nixpkgs.s4cmd
    nixpkgs.starship
    # my-scala
    # my-sbt
    nixpkgs.silver-searcher
    nixpkgs.tea
    nixpkgs.tmux
    nixpkgs.websocat
    nixpkgs.wget
    # nixpkgs.wkhtmltopdf
    nixpkgs.xz
    nixpkgs.zsh
    # my-scala
    # nixpkgs.byobu
    # nixpkgs.tcping
  ] ++
    (if everythingButM1Mac then
       [
         nixpkgs.cached-nix-shell
         nixpkgs.rsnapshot
       ]
     else
       []
    )
  ;

}
