{
  home-manager,
  self,
}: {
  system,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.zen-browser;

  applicationName = "Zen Browser";
  modulePath = [
    "programs"
    "zen-browser"
  ];

  mkFirefoxModule = import "${home-manager.outPath}/modules/programs/firefox/mkFirefoxModule.nix";
in {
  imports = [
    (mkFirefoxModule {
      inherit modulePath;
      name = applicationName;
      wrappedPackageName = "zen-browser-unwrapped";
      unwrappedPackageName = "zen-browser";
      visible = true;
      platforms = {
        linux = {
          vendorPath = ".zen";
          configPath = ".zen";
        };
        darwin = {
          configPath = "Library/Application Support/Zen";
        };
      };
    })
  ];

  options.programs.zen-browser = {
    enable = lib.mkEnableOption "zen-browser";
  };

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
      package = cfg.package.overrideAttrs (prevAttrs: {
        passthru =
          (prevAttrs.passthru or {})
          // {
            inherit applicationName;
            binaryName = "zen";

            ffmpegSupport = true;
            gssSupport = true;
            gtk3 = pkgs.gtk3;
          };
      });

      policies = {
        DisableAppUpdate = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisablePocket = true;
      };

      profiles."default" = {
        id = 0;
        isDefault = true;
      };
    };
  };
}
