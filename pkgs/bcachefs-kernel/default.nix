{ lib, fetchurl, kernel, kernelPatches, ...} @ args:

with lib;

let
  commit = "d43f6c8b445809df1e8eb716c857e6bd73def1d7";
  diffHash = "1c73d7picni9n7yb132q6zaj2y709mpjb3abx3nzcmh3rqk1dzln";
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
