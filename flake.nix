{
  description = "Pihole docker image & NixOS module for configuring a rootless pihole container (w/ port-forwarding)";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils }: with flake-utils.lib; eachDefaultSystem (curSystem:
    {
      nixosModules.default = { config, pkgs, lib, ... }: with lib; with builtins; let
        cfg = config.services.linger;
      in {
        options = {
          services.linger = {
            enable = mkEnableOption "Lingering for users without active session";

            users = mkOption {
              type = with types; listOf str;
              description = ''
                A list of user names for which lingering should be enabled.
                See `man loginctl` command `enable-linger` for more information.
              '';
              default = [ ];
            };

            manageAllUsers = mkOption {
              type = types.bool;
              description = ''
                If true all lingering users are managed through this module.
                Manually enabled lingering is reset on system activation.
              '';
              default = false;
            };
          };
        };

        config = mkIf cfg.enable {
          system.activationScripts = {
            enableLinger = optionalString cfg.manageAllUsers ''
              ${pkgs.coreutils}/bin/rm /var/lib/systemd/linger/* 2>/dev/null || true;
            '' + ''
              ${pkgs.coreutils}/bin/touch /var/lib/systemd/linger/${toString cfg.users};
            '';
          };
        };
      };
    }
  );
}
