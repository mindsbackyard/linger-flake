# Linger Flake

A NixOS flake for adding options to control systemd's user linger feature.

Enabling lingering for a user allows her to run a systemd service without an active login session (and keep it running after all login sessions are closed).
See `man loginctl` (`enable-linger`) and `man logind.conf` (`KillUserProcesses=`) for more information.

The flake provides a `nixosModules.default` module which can be included in your NixOS configuration.
Adding the module allows you to control user lingering with the `services.linger` options.

## Further information

See the `example` folder for usage examples and read the options declarations in `flake.nix`.
