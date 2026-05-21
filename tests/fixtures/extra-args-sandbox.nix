# Test fixture: extra platform-specific escape hatches
let
  pkgs = import <nixpkgs> { };
  sandbox = import ../../default.nix { pkgs = pkgs; };
in sandbox.mkSandbox {
  pkg = pkgs.bashInteractive;
  binName = "bash";
  outName = "sandboxed-bash-extras";
  allowedPackages = [ pkgs.coreutils ];
  extraSeatbeltRules = ''
    (allow file-read* (subpath (param "REAL_HOME")))
  '';
  extraBwrapArgs = [
    "--ro-bind-try" "/tmp/agent-sandbox-extra-test" "/tmp/agent-sandbox-extra-test"
  ];
}
