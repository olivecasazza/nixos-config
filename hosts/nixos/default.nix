{
  config,
  pkgs,
  user,
  ...
}:

let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFANRx9iLMadyw64Z6Kijk1aUB9ZrP1oYVPt8+bAhDI"
  ];
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in
{
  imports = [
    ../../modules/shared
    ../../modules/shared/cachix
    ./hardware-configuration.nix
  ];

  nix = {
    nixPath = [ "nixos-config=/home/${user.name}/Repositories/nixos-config:/etc/nixos" ];
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      allowed-users = [ "${user.name}" ];
      auto-optimise-store = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };

  services = {
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    hardware.bolt.enable = true;
    upower.enable = true;
    thermald.enable = true;
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  networking = {
    hostName = "spectre";
    usePredictableInterfaceNames = true;
    networkmanager.enable = true;
    useDHCP = false;
  };
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = true; # Set to false for key-based authentication
    # ports = [ 22 ]; # Default SSH port, uncomment if needed
    # settings = {
    #   PermitRootLogin = "prohibit-password"; # Example setting
    # };
  };
  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };
  users.users = {
    ${user.name} = {
      description = "${user.fullName}";
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "networkmanager"
        "video" # hotplug devices and thunderbolt
        "dialout" # TTY access
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };
    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };
  fonts.packages = with pkgs; [
    dejavu_fonts
    jetbrains-mono
    font-awesome
  ];
  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    inetutils
  ];
  system.stateVersion = "21.05"; # Don't change this
}
