{ debug ? false , lib, fetchurl, kernel, kernelPatches, version, ...} @ args:

with lib;

let
  commit = "d196661739d0d35e9e541065ef5888f363ba945c";
  diffHash = "1ji6c8bx1snnxz0z01w7jxvc5mqg2kimmlhlqipalzqzhcjy4iwm";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = kernel.version;
  oldPatches = kernelPatches;
    in
(kernel.override (args // {
  argsOverride = {

    version = "${kernelVersion}-bcachefs-${version}-${shorthash}";
    modDirVersion = "${kernelVersion}-bcachefs-${shorthash}";
  extraMeta.branch = versions.majorMinor kernelVersion;

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
