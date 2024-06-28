{ lib
, callPackage
, writeShellScriptBin
, beamPackages
, mix2nix
, fetchFromGitHub
, git
, cmake
, nixosTests
, mobilizon-frontend
, ...
}:

let
  inherit (beamPackages) mixRelease;
  common = callPackage ./common.nix { };
in
mixRelease rec {
  inherit (common) pname version src;

  nativeBuildInputs = [ git cmake ];

  mixNixDeps = import ./deps.nix {
    inherit beamPackages lib;
    overrides = (final: prev:
      (lib.mapAttrs
        (_: value: value.override {
          appConfigPath = src + "/config";
        })
        prev) // {
        fast_html = prev.fast_html.override {
          nativeBuildInputs = [ cmake ];
        };
        ex_cldr = prev.ex_cldr.overrideAttrs (old: {
          # We have to use the GitHub sources, as it otherwise tries to download
          # the locales at build time.
          src = fetchFromGitHub {
            owner = "elixir-cldr";
            repo = "cldr";
            rev = "v${old.version}";
            sha256 = assert old.version == "2.37.5";
              "sha256-T5Qvuo+xPwpgBsqHNZYnTCA4loToeBn1LKTMsDcCdYs=";
          };
          postInstall = ''
            cp $src/priv/cldr/locales/* $out/lib/erlang/lib/ex_cldr-${old.version}/priv/cldr/locales/
          '';
        });
        # Upstream issue: https://github.com/bryanjos/geo_postgis/pull/87
        geo_postgis = prev.geo_postgis.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ final.ecto ];
        });
      });
  };

  # Install the compiled js part
  preBuild = ''
    cp -a "${mobilizon-frontend}/static" ./priv
    chmod 770 -R ./priv
  '';

  postBuild = ''
    mix phx.digest --no-deps-check
  '';

  passthru = {
    tests.smoke-test = nixosTests.mobilizon;
    updateScript = writeShellScriptBin "update.sh" ''
      set -eou pipefail

      ${mix2nix}/bin/mix2nix '${src}/mix.lock' > pkgs/servers/mobilizon/mix.nix
    '';
    elixirPackage = beamPackages.elixir;
  };

  meta = with lib; {
    description = "Mobilizon is an online tool to help manage your events, your profiles and your groups";
    homepage = "https://joinmobilizon.org/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ minijackson erictapen ];
  };
}
