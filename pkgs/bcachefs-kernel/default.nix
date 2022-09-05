{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "176718966e14c5f832ead8cea2e0e45aba51f5ef";
  diffHash = "1yjzxba11nfb0yqram5qykqyqsv64wv57zh7l3qp1b2rl6j27bqr";
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
