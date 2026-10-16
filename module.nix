# Home-manager module wiring the paste workflow into DankMaterialShell.
#
# Consumed as: homeModules.dms-paste (parameterized over the plugin source,
# see flake.nix). REQUIRES the DankMaterialShell home-manager module to be
# imported in the same closure — this module only ASSIGNS into
# programs.dank-material-shell.*, it does not declare those options, so a
# consumer that forgot the DMS module fails loudly at eval instead of
# silently configuring nothing.
{ pluginSrc }:
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.dms-paste;
in
{
  options.programs.dms-paste = {
    enable = lib.mkEnableOption "PasteBot-style paste workflow for DankMaterialShell: clipboard-history direct-paste settings plus the ':s' snippets launcher plugin";

    snippetsDir = lib.mkOption {
      type = lib.types.str;
      default = "~/.local/share/snippets";
      description = ''
        Directory holding one .txt file per snippet (filename = name,
        content = text to paste). The literal "~/" prefix is expanded by
        the plugin at runtime.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      # maxHistory is a clipboardSettings (clsettings.json) key, not a
      # settings.json key. All values below are mkDefault: they encode the
      # PasteBot-parity baseline, and a consumer may override any of them.
      clipboardSettings.maxHistory = lib.mkDefault 100000;

      settings = {
        # Enter/click on a clipboard-history entry pastes it directly into
        # the focused window (DMS synthesizes Ctrl+V via the compositor's
        # virtual-keyboard protocol). Without these, selecting only copies.
        clipboardEnterToPaste = lib.mkDefault true;
        clipboardClickToPaste = lib.mkDefault true;
        # Per-row chrome: only pin (all actions stay in the right-click
        # context menu; the default 3-icon cluster is visual noise).
        clipboardVisibleEntryActions = lib.mkDefault [ "pin" ];
      };

      # Snippets launcher (PasteBot cmd+shift+C replacement): ":s" trigger
      # in the spotlight, ":s > name" captures the live clipboard as a new
      # snippet, ":s -name" trashes matching snippets. Paste actions reuse
      # the DMS clipboard daemon (dms cl copy + send-paste) — no
      # wtype/ydotool/uinput.
      plugins.paste-snippets = {
        src = pluginSrc;
        settings.snippetsDir = cfg.snippetsDir;
      };
    };
  };
}
