# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
       <home-manager/nixos> 
    ];
#SSD
fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

systemd.timers."numlockx_boot" = {
wantedBy = [ "timers.target" ];
timerConfig = {
OnStartupSec = "1us";
AccuracySec = "1us";
Unit = "numlockx.service";
};
};

systemd.timers."numlockx_sleep" = {
wantedBy = [
"suspend.target"
"hibernate.target"
"hybrid-sleep.target"
"suspend-then-hibernate.target"
];
after = [
"suspend.target"
"hibernate.target"
"hybrid-sleep.target"
"suspend-then-hibernate.target"
];
timerConfig = {
AccuracySec = "1us";
Unit = "numlockx.service";
};
};

systemd.services."numlockx" = {
script = ''
${pkgs.numlockx}/bin/numlockx on
'';
serviceConfig = {
Type = "oneshot"; # "simple" für Prozesse, die weiterlaufen sollen
};
};

boot = {
    plymouth = {
      enable = true;
      theme = "rings";
      # logo = "/home/sani/boot.jpg";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };
    initrd.systemd.enable = true;
    # Enable "Silent Boot"
    consoleLogLevel = 0;
    # initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 4;

  };

# boot.plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/48x48/apps/nix-snowflake-white.png";


users.users.eve.isNormalUser = true;
system.autoUpgrade.enable  = true;
system.autoUpgrade.allowReboot  = false;
# Home Manager
home-manager.users.sani= { pkgs, ... }: {
home.packages = [ pkgs.atool pkgs.httpie ];
programs.bash.enable = true;
programs.fish.enable = true;
#Auto Upgrade
programs.helix = {
  enable = true;
  settings = {
    theme = "gruvbox";
    editor.cursor-shape = {
      normal = "block";
      insert = "bar";
      select = "underline";
    };
  };
  languages.language = [{
    name = "nix";
    auto-format = true;
    formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
  }];
  themes = {
    autumn_night_transparent = {
      "inherits" = "autumn_night";
      "ui.background" = { };
    };
  };
};
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
};

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  security.polkit.enable = true;
systemd = {
  user.services.polkit-kde-agent-1 = {
    description = "polkit-kde-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };
};

  networking.hostName = "lap"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.enableHidpi = true;
  services.displayManager.sddm.autoNumlock = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
#   qt = {
#   enable = true;
#   platformtheme = "gnome";
#   style = "adwaita";
# };
# programs.dconf.enable = true;
  services.thermald.enable = true;
#   services.tlp = {
#       enable = true;
#       settings = {
#         CPU_SCALING_GOVERNOR_ON_AC = "performance";
#         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

#         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
#         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

#         CPU_MIN_PERF_ON_AC = 0;
#         CPU_MAX_PERF_ON_AC = 70;
#         CPU_MIN_PERF_ON_BAT = 0;
#         CPU_MAX_PERF_ON_BAT = 20;

#        #Optional helps save long term battery health
#        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
#        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

#       };
# };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:swapescape";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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
  # services.xserver.libinput.enable = true;
    programs.partition-manager.enable = true;
# services.fwupd.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sani = {
    isNormalUser = true;
    description = "Sani Sabu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.bluedevil
      kdePackages.kgpg
      kdePackages.okular
      kdePackages.kmail
      # Deps for kmail
      kdePackages.akonadi 
      kdePackages.akonadiconsole 
      kdePackages.akonadi-search
      kdePackages.akonadi-mime
      kdePackages.akonadi-contacts
      # kdePackages.discover
      # kdePackages.partitionmanager
      kdePackages.polkit-kde-agent-1
      freecad
	    gimp
	    inkscape
      google-chrome
      bitwarden
      freecad
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "sani";

  # Install firefox.
  programs.firefox.enable = true;
  services.pcscd.enable = true;
programs.gnupg.agent = {
   enable = true;
  pinentryPackage = pkgs.pinentry-qt;
   enableSSHSupport = true;
};
  programs.neovim = {
	enable = true;
  };

  # Allow unfree packages
  nixpkgs.config={
  allowUnfree = true;
  #Bluetooth
	hardware.bluetooth.enable = true; # enables support for Bluetooth
	hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
	General = {
		Experimental = true;
	};
};
networking.nftables.enable = true;
	#Steam
	programs.steam = {
	  enable = true;
	  #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
	  #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};
	# Enable OpenGL
	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
	    	extraPackages = with pkgs; [
      	    	intel-media-driver # LIBVA_DRIVER_NAME=iHD
      	    	#vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      	    	vaapiVdpau
      	    	libvdpau-va-gl
    		];
	};
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

};
fonts.packages = with pkgs; [
	 ubuntu_font_family
	font-awesome
	noto-fonts
	  (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
	];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
  helix
  google-chrome
  neofetch
  tealdeer
  corefonts
  vistafonts
  foot
  xorg.xeyes
  numlockx
  zellij
  libva-utils
  ripgrep
  bat
  eza
  htop
  mpv
  libreoffice-fresh
  vlc
  fzf
  aria
  ffmpeg
  nixfmt-rfc-style
  rustup
  gnupg
  pciutils
  clinfo
  glxinfo
  vulkan-tools
  wayland-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
