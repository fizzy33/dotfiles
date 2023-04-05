{ config, pkgs, lib, ... }:

let

  system = builtins.currentSystem;

#  sources = import /Users/glen/code/accur8/sync/nix/sources.nix;

#  nixpkgs = import sources."nixpkgs-unstable" { inherit system; };

#  a8-scripts = import sources.a8-scripts { inherit system nixpkgs; };

  my-java = pkgs.jdk11.overrideAttrs (oldAttrs: rec {
    postFixup = (oldAttrs.postFixup or "") + ''
       rm $out/share/man
    '';
  });

  my-scala = pkgs.scala.override { jre = my-java; };
  my-ammonite = pkgs.ammonite_2_13.override { jre = my-java; };
  
  my-sbt = pkgs.sbt.override { jre = my-java; };

  my-python3-packages = python-packages: with python-packages; [
    munch
    setuptools
  ]; 

  my-python3 = pkgs.python3.withPackages my-python3-packages;

  runitor = 
    pkgs.buildGoModule rec {
      pname = "runitor";
      version = "0.8.0";
      vendorSha256 = null;
      src = pkgs.fetchurl {
        url = "https://github.com/bdd/runitor/archive/refs/tags/v1.2.0.tar.gz";
        sha256 = "71489ba9b0103f16080495ea9671dd86638c338faf5cb0491f93f5d5128006c3";
      };
    };

  # a8-scripts = 
  #   stdenv.mkDerivation {
  #     src = "a8-scripts";
  #   };

  linuxOnly = lib.strings.hasInfix "linux" builtins.currentSystem;
  everythingButM1Mac = builtins.currentSystem != "aarch64-darwin";

in 
{

  # if builtins.pathExists ./true.nix then import ./true.nix else true;

  programs.home-manager.enable = true;

  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  home.stateVersion = "22.11";


  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "50eba266b0d8a952c7230fca1114cbc9fbbdfbd4";
          sha256 = "0ppmajynpb9l58xbrcnbp41b66g7p0c9l2nlsvyjwk6d16g4p4gy";
        };
      }

      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
      }
    ];

    shellAliases = {
      bobbob = "exa";
    };

  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
  # programs.direnv.nix-direnv.enableFlakes = true;

  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.go.enable = true;

  services.lorri.enable = linuxOnly;

  home.packages = [
    # a8-scripts.a8-scripts
    my-ammonite
#    pkgs.activemq
    pkgs.awscli
    # pkgs.bloop
    pkgs.bottom
    pkgs.certbot-full
    pkgs.chezmoi
#    pkgs.python310Packages.certbot-dns-route53
    pkgs.curl
#   pkgs.diffoscope    
    pkgs.direnv
    pkgs.drone-cli
    pkgs.exa  
    pkgs.fish
    pkgs.git
    pkgs.git-crypt
    pkgs.gnupg
    pkgs.graalvm11
#    pkgs.haxe_4_0
    pkgs.htop
    pkgs.httping
    pkgs.iftop
    pkgs.inetutils
    pkgs.jq
#    my-java
#    pkgs.ipython
    pkgs.lf
    pkgs.linode-cli
    pkgs.micro
    pkgs.mosh
    pkgs.mtr
    pkgs.nano
    pkgs.ncdu
    pkgs.ncftp
    pkgs.niv
    pkgs.nnn
    (pkgs.pass.withExtensions (ext: with ext; [pkgs.passExtensions.pass-import])) 
#    pkgs.pgcli
    pkgs.powerline-go
    pkgs.pstree
    pkgs.pv
    my-python3
    pkgs.ripgrep
    pkgs.rsync
#    pkgs.rsnapshot
    pkgs.s3cmd
    pkgs.s4cmd
    pkgs.mypy
    pkgs.runitor
    my-scala
#    my-sbt
    pkgs.silver-searcher
    pkgs.stack
    pkgs.tea
    pkgs.tmux
    pkgs.websocat
    pkgs.wget
    pkgs.xz
    pkgs.zsh
#    my-scala
  ] ++ 
    (if linuxOnly then 
       [
         pkgs.byobu
#        pkgs.tcping
       ] 
     else   
       []
    ) ++
    (if everythingButM1Mac then
       [
         pkgs.cached-nix-shell
       ]
     else
       []
    )
  ;

}
