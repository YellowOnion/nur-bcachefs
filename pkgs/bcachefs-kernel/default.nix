{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "c996fd92854f809b1cb7faa1f00cf7dd621487b9";
  diffHash = "1lsamdjvg0492f4kj4x11rhh119g3nqmdfbaigaiqzhrqp3c3mdh";
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
