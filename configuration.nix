# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).




{ config, lib, pkgs, ... }:

{
	fileSystems."/home/stephin/data" = {
	device = "/dev/nvme0n1p3";
	fsType = "ext4";
  	};

environment.sessionVariables.NIXOS_OZONE_WL = "1";
nixpkgs.config = {
	allowUnfree = true;
	firefox = {
		enableGoogleTalkPlugin = true;
		#enableAdobeFlash = false;
    		};
    	chromium = {
  	#   enablePepperFlash = false; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works 
    		};
  	};

#Bluetooth
	hardware.bluetooth.enable = true; # enables support for Bluetooth
	hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
	hardware.bluetooth.settings = {
	General = {
		Enable = "Source,Sink,Media,Socket";
		};
  	};
	services.blueman.enable = true;
	#Steam
	programs.steam = {
	  enable = true;
	  #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
	  #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
	};

#Unfree
	nixpkgs.config.allowUnfreePredicate = pkg:
	  builtins.elem (lib.getName pkg) [
	    # Add additional package names here
	    "nvidia-x11"
	    "nvidia-settings"
	    "nvidia-persistenced"
	    "steam"
	    "steam-original"
	    "steam-run"
	  ];
#nixpkgs.config.packageOverrides = pkgs: {
#    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#  };

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

#Nvidia
	
	security.polkit.extraConfig = ''
	  polkit.addRule(function(action, subject) {
	    if (
	      subject.isInGroup("users")
	        && (
	          action.id == "org.freedesktop.login1.reboot" ||
	          action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
	          action.id == "org.freedesktop.login1.power-off" ||
	          action.id == "org.freedesktop.login1.power-off-multiple-sessions"
	        )
	      )
	    {
	      return polkit.Result.YES;
	    }
	  })
	'';


#Nvidia

	# Load nvidia driver for Xorg and Wayland
	services.xserver.videoDrivers = ["nvidia"];
	hardware.nvidia = {
	
	  # Modesetting is required.
	  modesetting.enable = true;
	  # Power off permission to regular users
	  # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
	  powerManagement.enable = true;
	  # Fine-grained power management. Turns off GPU when not in use.
	  # Experimental and only works on modern Nvidia GPUs (Turing or newer).
	  powerManagement.finegrained = true;
	
	  # Use the NVidia open source kernel module (not to be confused with the
	  # independent third-party "nouveau" open source driver).
	  # Support is limited to the Turing and later architectures. Full list of 
	  # supported GPUs is at: 
	  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
	  # Only available from driver 515.43.04+
	  # Currently alpha-quality/buggy, so false is currently the recommended setting.
	  open = false;
	
	  # Enable the Nvidia settings menu,
	      # accessible via `nvidia-settings`.
	  nvidiaSettings = true;
	
	  # Optionally, you may need to select the appropriate driver version for your specific GPU.
	  package = config.boot.kernelPackages.nvidiaPackages.stable;
	
	#Prime
	prime = {
	offload = {
			enable = true;
			enableOffloadCmd = true;
		};
		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
	};

	};



specialisation={
block_nvidia.configuration={
boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';
  
  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
};
};
	security.polkit.enable = true;
	programs.hyprland.enable = true;
  
	imports =
	  [ # Include the results of the hardware scan.
	 "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/dell/g3/3779" 
	  #<nixos-hardware/dell/g3/3779>
	    ./hardware-configuration.nix
	  ];

  # Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;


   networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
   # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
   programs.nm-applet.enable = true;
  # Set your time zone.
   time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
   console = {
     #font = "Lat2-Terminus16";
     #keyMap = "gb";
     useXkbConfig = true; # use xkb.options in tty.
   };
	fonts.packages = with pkgs; [
	 ubuntu_font_family
	font-awesome
	noto-fonts
	  (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
	];
  # Enable the X11 windowing system.
  # services.xserver.enable = true;

#Thunar
	programs.thunar.enable = true;
	programs.thunar.plugins = with pkgs.xfce; [
  		thunar-archive-plugin
  		thunar-volman
	];
services.tumbler.enable = true; # Thumbnail support for images
  

  # Configure keymap in X11
	services.xserver.xkb.layout = "gb";
	services.xserver.xkb.options = "caps:swapescape";
# services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
    services.gvfs.enable = true;
    services.fwupd.enable = true;
    #services.tlp.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
  # Enable sound.
   sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
   services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.stephin = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
     initialPassword = "pw123";
     packages = with pkgs; [
     superTuxKart
       	tree
       	bitwarden
	font-manager
	brave
	audacity
	freecad
	gimp
	inkscape
	nicotine-plus
	w3m-nox
	vscodium
     ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
environment.systemPackages = with pkgs; [
	gamescope
	gamemode
	python3
	wireguard-tools
	wget
	lshw
	librewolf
	qbittorrent
	libgcc
	firefox
	killall
	aria
	rhythmbox
	clang
      # Replace llvmPackages with llvmPackages_X, where X is the latest LLVM version (at the time of writing, 16)
      	llvmPackages.bintools
      	rustup
	ffmpeg
	libsForQt5.kdenlive
	glaxnimate
	grim
	powertop
	flameshot
	slurp
	ydotool
	protonup-qt
	neofetch
	helvum
	pavucontrol
	#keybase-gui
	polkit_gnome
	joplin-desktop
	fuse
	fzf
	lf
	wlogout
	gtk4
	gtk3
	pkg-config
	cmake
	gvfs
	glib
	libnotify
	jq
	handlr-regex
	vlc
	libreoffice-fresh
	zathura
	lutris
	imv
	git
	mpv
	wf-recorder
	wl-clipboard
	brightnessctl
	#udisks
	htop
	wob
	dunst
	meson
	ninja
	eza
	cliphist
	bat
	ripgrep
	playerctl
	envsubst
	foot
	kitty
	gparted
	neovim
	waybar
	wofi
	#polkit_gnome
	xorg.xeyes
	tealdeer
	unzip
	gnome.gnome-disk-utility
	zoxide
	starship
	swayidle
	swaylock
	dracula-theme
	gnome3.adwaita-icon-theme
	xdg-utils
	wayland
	#Wine
    # support both 32- and 64-bit applications
    #wineWowPackages.stable
    ## support 32-bit only
    #wine
    ## support 64-bit only
    #(wine.override { wineBuild = "wine64"; })
    # wine-staging (version with experimental features)
    wineWowPackages.staging
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
   ];

  programs.sway.enable = true;
#environment.systemPackages = with pkgs; [
#  fishPlugins.done
#  fishPlugins.fzf-fish
#  fishPlugins.forgit
#  fishPlugins.hydro
#  fzf
#  fishPlugins.grc
#  grc
#];


  programs.fish.enable= true;
  xdg = {
  portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
};


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  #Pipewire
  security.rtkit.enable = true;
    services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
     # If you want to use JACK applications, uncomment this
  #jack.enable = true;
  };
  environment.etc = {
	"wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
		bluez_monitor.properties = {
			["bluez5.enable-sbc-xq"] = true,
			["bluez5.enable-msbc"] = true,
			["bluez5.enable-hw-volume"] = true,
			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
		}
	'';
};
 # services.polkit-gnome-authentication-agent-1.enable = true;
  services.udisks2.enable=true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
   system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
