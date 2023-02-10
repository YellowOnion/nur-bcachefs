{
  broken
, debug ? false
, lib
, fetchurl
, kernel
, kernelPatches
, version
, useLocalPatch ? false
, ...} @ args:

with lib;

let
  commit = "5fc458d032ccbf6d0c772af050de3d3b102d7d6e";
  diffHash = "1cnfmlwhajfrr68vf5s90ciih81b9zna2sqc9lqnbcs08vx0vxlh";
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
      patch =
        if useLocalPatch
          then ../../bcachefs-patches
          else fetchurl {
                name = "bcachefs-${commit}.diff";
                url  = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
                sha256 = diffHash;
              };
      extraConfig = (''
        LOCALVERSION -bcachefs-${shorthash}
        CRYPTO_CRC32C_INTEL y
        BCACHEFS_FS y
        BCACHEFS_POSIX_ACL y
        BCACHEFS_QUOTA y
        ALLOC_TAGGING n
        CODETAG_TIME_STATS n
        PERCPU_STATS n
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
