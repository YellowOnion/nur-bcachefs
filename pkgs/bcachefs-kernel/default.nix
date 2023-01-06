{ broken, debug ? false , lib, fetchurl, kernel, kernelPatches, version, ...} @ args:

with lib;

let
  commit = "b2f99e387095350eca2f507d69e63668c8b2788e";
  diffHash = "0vgdli8xbl16yc2dcgm5cirxqwcbvimss0amy4s48cbpwd7ckh9a";
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
