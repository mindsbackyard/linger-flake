{
  description = ''
    A NixOS flake for adding options to control systemd's user linger feature.

    Enabling lingering for a user allows her to run a systemd service without an active login session (and keep it running after all login sessions are closed).
    See `man loginctl` (`enable-linger`) and `man logind.conf` (`KillUserProcesses=`) for more information.

    The flake provides a `nixosModules.default` module which can be included in your NixOS configuration.
    Adding the module allows you to control user lingering with the `services.linger` options.
  '';

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
            enable = mkEnableOption ''
              Enable lingering for users without active session.

              Note that if you disable this feature after it has been enabled once,
              lingering for users for which it has been active won't be deactivated.
              You have to clean it up by yourself by removing the user-named file under `/var/lib/systemd/linger/`.
            '';

            users = mkOption {
              type = with types; listOf str;
              description = ''
                A list of user names for which lingering should be enabled.
                See `man loginctl` command `enable-linger` for more information.

                Note that if you remove a user from this list this won't disable lingering for her execpt if `services.linger.manageAllUsers` is enbled.
                Otherwise you have to clean it up by yourself by removing the user-named file under `/var/lib/systemd/linger/`.
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
