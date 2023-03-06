{ pkgs ? import <nixpkgs> { }
, lib ? import <nixpkgs/lib>
}:
let
  nixos-appstream-data = (import
    (pkgs.fetchFromGitHub {
      owner = "vlinkz";
      repo = "nixos-appstream-data";
      rev = "66b3399e6d81017c10265611a151d1109ff1af1b";
      hash = "sha256-oiEZD4sMpb2djxReg99GUo0RHWAehxSyQBbiz8Z4DJk=";
    })
    { set = "all"; stdenv = pkgs.stdenv; lib = pkgs.lib; pkgs = pkgs; });
in
pkgs.stdenv.mkDerivation rec {
  pname = "nix-software-center";
  version = "0.1.1";

  src = [ ./. ];

  cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-zNE50V8GEhksSm30qZ/cnqSRsKxNJ13s9zUpBDgXJdo=";
  };

  nativeBuildInputs = with pkgs; [
    appstream-glib
    polkit
    gettext
    desktop-file-utils
    meson
    ninja
    pkg-config
    git
    wrapGAppsHook4
  ] ++ (with pkgs.rustPlatform; [
    cargoSetupHook
    rustPackages_1_66.cargo
    rustPackages_1_66.rustc
  ]);

  buildInputs = with pkgs; [
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
    libxml2
    openssl
    wayland
    gnome.adwaita-icon-theme
    desktop-file-utils
    nixos-appstream-data
  ];

  patchPhase = ''
    substituteInPlace ./src/lib.rs \
        --replace "/usr/share/app-info" "${nixos-appstream-data}/share/app-info"
  '';

  postInstall = ''
    wrapProgram $out/bin/nix-software-center --prefix PATH : '${lib.makeBinPath [ pkgs.gnome-console pkgs.sqlite ]}'
  '';
}
