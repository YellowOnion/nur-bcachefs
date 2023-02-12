{
  kernelVersion ? "6.1",
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs {}
  }:
let
  lib = import ./lib { inherit pkgs; }; # functions

  dotToUnderscore = pkgs.lib.strings.stringAsChars (x: if x == "." then "_" else x);
  mkKernel = broken: name: debug: extraPatches : (pkgs.callPackage ./pkgs/bcachefs-kernel {
    broken = broken;
    debug = debug;
    kernel = pkgs.linuxKernel.kernels."linux_${dotToUnderscore kernelVersion}";
    version = name ;
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ] ++ extraPatches;
    useLocalPatch = false;
  });

  bcachefs-tools = (import (pkgs.fetchgit {
    inherit (pkgs.lib.importJSON ./tools-version.json)
      url rev sha256;
  })).outputs.packages.x86_64-linux.default;
  bcachefs-kernel-kent = mkKernel false "kent-master" false [];
  bcachefs-kernel-kent-debug = mkKernel false "kent-master" true [];
  bcachefs-kernel-woob = mkKernel false "woob-testing" false [
    { name = "woob-bcachefs-testing.patch";
      patch = ./pkgs/bcachefs-kernel/woob.patch; }
    ];
  bcachefs-kernel-woob-debug = mkKernel false "woob-testing" true [
    { name = "woob-bcachefs-testing.patch";
      patch = ./pkgs/bcachefs-kernel/woob.patch; }
  ];
  overlay = (super: final: { inherit bcachefs-tools bcachefs-kernel-kent bcachefs-kernel-woob; });
in
{
  inherit
    bcachefs-tools
    bcachefs-kernel-kent
    bcachefs-kernel-kent-debug
    bcachefs-kernel-woob
    bcachefs-kernel-woob-debug
    lib;
  # The `lib`, `modules`, and `overlay` names are special
  #modules = import ./modules; # NixOS modules
  overlays = [overlay]; # nixpkgs overlays
  bcachefs-iso = ((import "${toString nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;
      modules = [
        ({...}: {
          nixpkgs.overlays = [ overlay ];
        })
        (
          ./iso.nix
        )
      ];
  }).config.system.build.isoImage.overrideAttrs (self: self // { preferLocalBuild = true; }));
}
