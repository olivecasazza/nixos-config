{
  config,
  pkgs,
  lib,
  user,
  inputs,
  ...
}:

let
  #xdg_configHome = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix {
    inherit
      config
      pkgs
      lib
      user
      inputs
      ;
  };
  shared-files = import ../shared/files.nix { inherit config pkgs user; };
in
{
  imports = [
    inputs.nix4nvchad.homeManagerModule
  ];
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user.name}";
    homeDirectory = "/home/${user.name}";
    packages = pkgs.callPackage ./packages.nix { };
    file = shared-files // import ./files.nix { inherit user; };
    stateVersion = "21.05";
  };

  services = {
    # notifications
    mako = {
      enable = true;
      settings = {
        default-timeout = 10000;
      };
    };
  };

  programs = shared-programs // {

  };
}
