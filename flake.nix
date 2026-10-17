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
      # Non-nix formatting gate (markdown/json/yaml/dockerfile). dprint
      # resolves plugins from URLs at runtime, which the build sandbox
      # forbids — so the check swaps every plugin URL for a fetchurl'd
      # store path in a generated config. Bumping a plugin version in
      # dprint.json without adding its hash here fails eval loudly (the
      # attr lookup names the missing URL).
      dprintCheck =
        pkgs:
        let
          config = builtins.fromJSON (builtins.readFile ./dprint.json);
          pluginHashes = {
            "https://plugins.dprint.dev/json-0.23.0.wasm" =
              "sha256-Ph8bfBQn32vYmBoRqqLEZv3o0RFend5MZSEwRYU5RDw=";
            "https://plugins.dprint.dev/g-plane/pretty_yaml-v0.6.0.wasm" =
              "sha256-QKL92nBAMX6xsjUg86AHaaVXHu2wScTKkXXBue66Aa4=";
            "https://plugins.dprint.dev/markdown-0.22.1.wasm" =
              "sha256-SQb7sDiXdzKq4OIW5LC5V+JyL415KCZgzLNtJ90FHxc=";
            "https://plugins.dprint.dev/dockerfile-0.4.1.wasm" =
              "sha256-3JU2sddEiX0TrT0GIfVR+PNiFD+fbQb/B4Hg4El8t5Q=";
          };
          plugins = map (
            url:
            "${pkgs.fetchurl {
              inherit url;
              hash = pluginHashes.${url};
            }}"
          ) config.plugins;
          offlineConfig = pkgs.writeText "dprint.json" (builtins.toJSON (config // { inherit plugins; }));
        in
        pkgs.runCommand "dms-paste-dprint-check" { nativeBuildInputs = [ pkgs.dprint ]; } ''
          cp -r ${self} src
          chmod -R u+w src
          cp ${offlineConfig} src/dprint.json
          export DPRINT_CACHE_DIR="$(mktemp -d)"
          cd src
          # Normalize the generated (compact) config so only real repo
          # files are judged by the check below.
          dprint fmt dprint.json
          dprint check
          touch "$out"
        '';

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

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Same dprint the `dprint` check builds with, so `nix develop`
          # gives contributors the pinned non-nix formatter (treefmt stays
          # available as `nix fmt` straight from the flake).
          packages = [ pkgs.dprint ];
        };
      });

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

          # dprint check over the repo (see dprintCheck above).
          dprint = dprintCheck pkgs;

          # The FEATURES.md summary counts are re-derived from the table;
          # the derivation also proves the gate bites by running it against
          # a doctored copy that must fail.
          features-counts = pkgs.runCommand "dms-paste-features-counts" { } ''
            ${./tests/features-counts.sh} ${self}/FEATURES.md
            doctored="$(mktemp -d)/FEATURES.md"
            sed 's/— 10 FULLY_FUNCTIONAL/— 9 FULLY_FUNCTIONAL/' ${self}/FEATURES.md > "$doctored"
            if ${./tests/features-counts.sh} "$doctored" >/dev/null 2>&1; then
              echo "FAIL: counts gate accepted a doctored summary (sed leg broken?)"
              exit 1
            fi
            touch "$out"
          '';
        }
      );
    };
}
