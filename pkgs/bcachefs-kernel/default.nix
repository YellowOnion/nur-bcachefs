{ broken, debug ? false , lib, fetchurl, kernel, kernelPatches, version, ...} @ args:

with lib;

let
  commit = "630ba749d01cad1c9f4fce5ff506b4775b1eb5af";
  diffHash = "1ag75ndkqqq0vzv6x58j1l8v2civ2rzxp2rpwlfw0ji4abm0awzy";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {
    version = "${kernelVersion}-bcachefs-${version}-${shorthash}";
    modDirVersion = "${kernelVersion}-bcachefs-${shorthash}";
    extraMeta.branch = versions.majorMinor kernelVersion;
    extraMeta.broken = broken;

  } // (args.argsOverride or { });

  kernelPatches = [{
      name = "bcachefs-${commit}";
      patch = fetchurl {
        name = "bcachefs-${commit}.diff";
        url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
        sha256 = diffHash;
      };
      extraConfig = (''
        LOCALVERSION -bcachefs-${shorthash}
        CRYPTO_CRC32C_INTEL y
        BCACHEFS_FS y
        BCACHEFS_POSIX_ACL y
        BCACHEFS_QUOTA y
      '' + (if debug then ''
          BCACHEFS_DEBUG y
          BCACHEFS_LOCK_TIME_STATS y
          FTRACE y
          KPROBES y
          FUNCTION_TRACER y
          HWLAT_TRACER y
          TIMERLAT_TRACER y
          OSNOISE_TRACER y
          KALLSYMS y
          KALLSYMS_ALL y
      '' else ""));
  }] ++ oldPatches;
}))
