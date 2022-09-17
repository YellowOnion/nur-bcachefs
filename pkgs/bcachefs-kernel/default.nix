{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "5a6bf64b47f4c55d6e3e4fe491f43e4da3af1e41";
  diffHash = "0vc30i2a67r10q857z97k33gp24r0r6nsmb28x0bvva1pr5asxzq";
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
