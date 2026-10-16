{
  description = "dms-paste: PasteBot-style paste workflow for DankMaterialShell (Quickshell) — clipboard-history parity, modal-density patches, and the ':s' snippets launcher plugin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      self,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
      treefmtEval = forAllSystems (
        pkgs:
        treefmt-nix.lib.evalModule pkgs (_: {
          programs = {
            nixfmt.enable = true;
            statix.enable = true;
          };
          projectRootFile = "flake.nix";
        })
      );

      patchDms = import ./patch.nix;

      # Eval the home-manager module in isolation. The DMS option tree is
      # stubbed as a freeform attrset: the module only ASSIGNS into
      # programs.dank-material-shell.* (the real options are declared by
      # DMS's own HM module in the consumer), so the stub is exactly the
      # contract surface this repo owns.
      evalModule =
        extraModules:
        nixpkgs.lib.evalModules {
          modules = [
            {
              options.programs.dank-material-shell = nixpkgs.lib.mkOption {
                type = nixpkgs.lib.types.anything;
                default = { };
              };
            }
            self.homeModules.dms-paste
          ]
          ++ extraModules;
        };

      # Fake DMS package carrying the upstream-shaped QML the patcher
      # targets; building patchDms over it exercises every sed/perl/grep
      # guard against realistic text.
      fakeDms =
        pkgs:
        pkgs.stdenv.mkDerivation {
          name = "dms-paste-fixture-dms";
          dontUnpack = true;
          installPhase = ''
            runHook preInstall
            clipDir="$out/share/quickshell/dms/Modals/Clipboard"
            mkdir -p "$clipDir"
            cp ${./tests/fixtures/ClipboardEntry.qml} "$clipDir/ClipboardEntry.qml"
            cp ${./tests/fixtures/ClipboardConstants.qml} "$clipDir/ClipboardConstants.qml"
            runHook postInstall
          '';
        };
    in
    {
      # Composable package patcher: paste-modal density/cleanliness changes
      # for the DankMaterialShell package (see patch.nix). Chain your own
      # overrideAttrs on top of the result for unrelated patches.
      lib.patchDms = patchDms;

      homeModules = {
        dms-paste = import ./module.nix { pluginSrc = "${self}/plugins/snippets"; };
        default = self.homeModules.dms-paste;
      };

      formatter = forAllSystems (
        pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
      );

      checks = forAllSystems (
        pkgs:
        let
          sys = pkgs.stdenv.hostPlatform.system;
          enabled = evalModule [ { programs.dms-paste.enable = true; } ];
          disabled = evalModule [ { programs.dms-paste.enable = false; } ];
          overridden = evalModule [
            {
              programs.dms-paste.enable = true;
              programs.dank-material-shell.settings.clipboardEnterToPaste = false;
            }
          ];
          dms = enabled.config.programs.dank-material-shell;
        in
        {
          formatting = treefmtEval.${sys}.config.build.check self;

          module-contract =
            pkgs.runCommand "dms-paste-module-contract"
              {
                pluginRegistered = toString (dms.plugins ? "paste-snippets");
                srcCarriesPluginJson = toString (
                  builtins.pathExists (dms.plugins.paste-snippets.src + "/plugin.json")
                );
                snippetsDirWired = toString (
                  dms.plugins.paste-snippets.settings.snippetsDir == "~/.local/share/snippets"
                );
                maxHistoryWired = toString (dms.clipboardSettings.maxHistory or null == 100000);
                enterToPasteWired = toString (dms.settings.clipboardEnterToPaste or false);
                clickToPasteWired = toString (dms.settings.clipboardClickToPaste or false);
                visibleActionsWired = toString (dms.settings.clipboardVisibleEntryActions or [ ] == [ "pin" ]);
                noOpWhenDisabled = toString (!(disabled.config.programs.dank-material-shell ? plugins));
                overrideWins = toString (
                  overridden.config.programs.dank-material-shell.settings.clipboardEnterToPaste == false
                );
              }
              ''
                [ "$pluginRegistered" = "1" ] || { echo "FAIL: plugin not registered when enabled"; exit 1; }
                [ "$srcCarriesPluginJson" = "1" ] || { echo "FAIL: plugin src does not point at the plugin directory"; exit 1; }
                [ "$snippetsDirWired" = "1" ] || { echo "FAIL: snippetsDir not wired into plugin settings"; exit 1; }
                [ "$maxHistoryWired" = "1" ] || { echo "FAIL: clipboardSettings.maxHistory missing"; exit 1; }
                [ "$enterToPasteWired" = "1" ] || { echo "FAIL: clipboardEnterToPaste missing"; exit 1; }
                [ "$clickToPasteWired" = "1" ] || { echo "FAIL: clipboardClickToPaste missing"; exit 1; }
                [ "$visibleActionsWired" = "1" ] || { echo "FAIL: clipboardVisibleEntryActions missing"; exit 1; }
                [ "$noOpWhenDisabled" = "1" ] || { echo "FAIL: module leaks assignments when disabled"; exit 1; }
                [ "$overrideWins" = "1" ] || { echo "FAIL: consumer override does not beat the mkDefault baseline"; exit 1; }
                touch "$out"
              '';

          # Real build of patchDms over the fixture package: the inline grep
          # guards fail this build if the patcher or its anchors regress.
          patch-contract = patchDms pkgs (fakeDms pkgs);
        }
      );
    };
}
