{ lib, fetchurl, kernel, kernelPatches, version, ...} @ args:

with lib;

let
  commit = "8ae9f3af830a0cd8aed7de278f6021974720119b";
  diffHash = "1bdvr90ldgrifawikra05gcgdhr54jiljv4pn1ib86qyhxlrhfvw";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {

    version = "${kernelVersion}-bcachefs-${version}-${shorthash}";
  extraMeta.branch = versions.majorMinor kernelVersion;

  } // (args.argsOverride or { });

  kernelPatches = [{
      name = "bcachefs-${commit}";
      patch = fetchurl {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = ''
        BCACHEFS_FS y
        BCACHEFS_POSIX_ACL y
        BCACHEFS_QUOTA y
      '';
  }] ++ oldPatches;
}))
