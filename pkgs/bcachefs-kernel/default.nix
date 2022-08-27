{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "9411d4be6133f41942ea84a160173f3bc68db246";
  diffHash = "1a9fk0vm3dnan65hi9xw0w24gkd0kbkjnr5wkmhlkz5gcy2z3p0s";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {

  version = "${kernelVersion}-bcachefs-unstable-${shorthash}";
  extraMeta.branch = versions.majorMinor kernelVersion;

  } // (args.argsOverride or { });

  kernelPatches = [{
      name = "bcachefs-${commit}";
      patch = fetchurl {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = "BCACHEFS_FS y";
  }] ++ oldPatches;
}))
