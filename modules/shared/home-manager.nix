{
  pkgs,
  lib,
  user,
  ...
}:
{

  nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${user.name}/Repositories/nixos-config"; # sets NH_OS_FLAKE variable for you
  };

  zsh = {
    enable = true;
    history = {
      append = true; # parallel history until shell exit
      ignoreAllDups = true; # remove previous when duplicate commands run
      ignorePatterns = [
        "cd"
        "ls"
        "pwd"
      ];
    };
    shellAliases = {
      cat = "bat";
      ls = "ls --color=auto";
    };
    sessionVariables = {
      EDITOR = "micro";
      # tfenv stuff
      # TFENV_CONFIG_DIR = "$HOME/.local/share/tfenv";
      # PATH = "$HOME/.tfenv/bin:$PATH";
    };
    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [
        "git"
        "zsh-autosuggestions"
        # "enhancd"
      ];
      theme = "robbyrussell";
    };
    plugins = [
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
      {
        name = "enhancd";
        file = "init.sh";
        src = pkgs.fetchFromGitHub {
          owner = "b4b4r07";
          repo = "enhancd";
          rev = "v2.2.1";
          sha256 = "0iqa9j09fwm6nj5rpip87x3hnvbbz9w9ajgm6wkrd5fls8fn8i5g";
        };
      }
    ];
  };

  starship = {
    enable = true;
    enableZshIntegration = true;
    # these are TOML mappings from https://starship.rs/config
    settings = {
      add_newline = true;
      scan_timeout = 10;
      aws.disabled = true;
      gcloud.disabled = true;
        fill.symbol = " ";
      format = "($nix_shell$container$fill$git_metrics\n)$cmd_duration$hostname$shlvl$shell$env_var$jobs$sudo$username$character";
      right_format = "$directory$vcsh$git_branch$git_commit$git_state$git_status$cmake$python$conda$terraform$rust$memory_usage$custom$status$os$battery$time";
      continuation_prompt = "[▸▹ ](dimmed white)";
      cmd_duration = {
        format = "[$duration](bold yellow)";
      };
      git_branch = {
        symbol = "[△](bold italic bright-blue)";
        format = " [$branch(:$remote_branch)]($style)";
        style = "italic bright-blue";
        only_attached = true;
        truncation_length = 11;
        truncation_symbol = "⋯";
        ignore_branches = [
          "main"
        ];
      };
      git_metrics = {
        disabled = false;
        format = "([+$added](italic dimmed green))([-$deleted](italic dimmed red))";
        ignore_submodules = true;
      };
      git_status = {
        format = "([⎪$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed⎥]($style))";
        style = "bold dimmed blue";
        ahead = "[▴$count](italic green)|";
        behind = "[▿$count](italic red)|";
        conflicted = "[◪◦](italic bright-magenta)";
        deleted = "[✕](italic red)";
        diverged = "[◇ ▴┤[$ahead_count](regular white)│▿┤[$behind_count](regular white)│](italic bright-magenta)";
        modified = "[●◦](italic yellow)";
        renamed = "[◎◦](italic bright-blue)";
        staged = "[▪┤[$count](bold white)│](italic bright-cyan)";
        stashed = "[◃◈](italic white)";
        untracked = "[◌◦](italic bright-yellow)";
      };
      nix_shell = {
        symbol = "❄";
        format = "[*⎪$state⎪](bold dimmed blue) [$name](italic dimmed white)";
        impure_msg = "[⌽](bold dimmed red)";
        unknown_msg = "[◌](bold dimmed yellow)";
        pure_msg = "[⌾](bold dimmed green)";
      };
      terraform = {
        format = "[🌎⎪$workspace⎪](bold dimmed purple)";
      };
    };
  };

  ghostty = {
    enable = true;
    settings = {
      font-size = 14;
      font-family = "JetBrainsMono Nerd Font Mono";
      theme = "Monokai Soda";
      cursor-style = "block";
      shell-integration-features = "no-cursor";
      clipboard-paste-protection = false;
      copy-on-select = true;
      window-decoration = "none";
      # term = "xterm-256color";
      macos-titlebar-proxy-icon = "hidden";
      # config-file = "~/.config/ghostty/extra"; # for testing shaders atm
      command = "/etc/profiles/per-user/${user.name}/bin/zsh";
      keybind = [
        "cmd+shift+d=close_surface"
        "cmd+shift+e=new_split:down"
        "cmd+shift+o=new_split:right"
      ];
    };
  };

  git = {
    enable = true;
    userName = user.fullName;
    userEmail = user.email;
    ignores = [
      ".DS_Store"
      ".swp"
      ".vscode"
    ];
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      safe.directory = "/home/${user.name}/Repositories/nixos-config";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      credential = {
        "https://github.com" = {
          helper = "!gh auth git-credential";
        };
      };
    };
  };
  gh = {
    enable = true;
    gitCredentialHelper.enable = false; # https://github.com/NixOS/nixpkgs/issues/169115
  };
  direnv = {
    enable = true;
    config = {
      global = {
        hide_env_diff = true;
        warn_timeout = 0;
      };
    };
  };
  nvchad = {
    enable = true;
    extraPlugins = ''
      return {
        {"equalsraf/neovim-gui-shim",lazy=false},
        {"lervag/vimtex",lazy=false},
        {"nvim-lua/plenary.nvim"},
        {
          'xeluxee/competitest.nvim',
          dependencies = 'MunifTanjim/nui.nvim',
          config = function() require('competitest').setup() end,
        },
      }
    '';
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nixd
      #(python3.withPackages(ps: with ps; [
      #  python-lsp-server
      #  flake8
      #]))
    ];

    chadrcConfig = ''
      local M = {}

      M.base46 = {
        theme = "solarized_osaka",
      }

      M.nvdash = { load_on_startup = true }
    '';
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ''
        IdentityFile /home/${user.name}/.ssh/id_ed25519_casazza_info
      '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
        IdentityFile /Users/${user.name}/.ssh/id_ed25519_casazza_info
      '')

    ];
  };
}
// import ./vscode { inherit pkgs lib; }
