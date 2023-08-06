{
  broken
, rebaseBroken ? false
, debug ? false
, lib
, fetchurl
, fetchgit
, kernel
, kernelPatches
, variant
, useLocalPatch ? false
, buildLinux
, ...} @ args:

with lib;

let
  commit = "640a004270b29f15aef76abff531816626e28e94";
  diffHash = "1nb31y23sng21mxxll97rbwww1471bvkca73c4rwlv81rfmj0rj6";
  shorthash = lib.strings.substring 0 7 commit;
  kernelVersion = if rebaseBroken
                  then (lib.versions.majorMinor (lib.readFile ../../VERSION)) + ".0"
                  else kernel.version;
  oldPatches = kernelPatches;
  gitVersion = importJSON ./version.json;
  versionInfo = {
    version = "${kernelVersion}-bcachefs-${variant}-${shorthash}";
    modDirVersion = "${kernelVersion}-bcachefs-${variant}-${shorthash}";
    extraMeta.branch = versions.majorMinor kernelVersion;
    extraMeta.broken = broken;
  };
  kernel2 = (if rebaseBroken then
                  buildLinux (args // versionInfo // {
                    src = fetchgit {inherit (gitVersion) url rev sha256;};
                  } // (args.argsOverride or {}))
             else kernel);
in
(kernel2.override (args // {
  argsOverride = versionInfo // (args.argsOverride or { });

  kernelPatches = [({
      name = "bcachefs-${commit}";
      patch = null;
      extraConfig = (''
        LOCALVERSION -bcachefs-${variant}-${shorthash}
        CRYPTO_CRC32C_INTEL y
        BCACHEFS_FS y
        BCACHEFS_POSIX_ACL y
        BCACHEFS_QUOTA y
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
  } // (if rebaseBroken
        then {}
        else {
        patch =
          if useLocalPatch
            then ../../bcachefs-patches
            else fetchurl {
                  name = "bcachefs-${commit}.diff";
                  url  = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=${commit}&id2=v${lib.versions.majorMinor kernelVersion}";
                  sha256 = diffHash;
                };
        })) ] ++ oldPatches;
}))
