{
    description = "git-remote-gcrypt (dr57 fork) with renamed command";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs }:
    let
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
        packages = forAllSystems (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in
        {
            default = pkgs.stdenv.mkDerivation rec {
            pname = "git-remote-gcrypt-dr57";
            version = "1.5"; # change if your fork diverges
            rev = version;

            src = ./.;  # point to the local repo


            outputs = [ "out" "man" ];

            nativeBuildInputs = [
                pkgs.docutils
                pkgs.makeWrapper
            ];

            installPhase = ''
                runHook preInstall

                prefix="$out" ./install.sh

                # Rename the installed command
                mv "$out/bin/git-remote-gcrypt" \
                    "$out/bin/git-remote-gcrypt-dr57"

                wrapProgram "$out/bin/git-remote-gcrypt-dr57" \
                --prefix PATH ":" "${
                    pkgs.lib.makeBinPath [
                    pkgs.gnupg
                    pkgs.curl
                    pkgs.rsync
                    pkgs.coreutils
                    pkgs.gawk
                    pkgs.gnused
                    pkgs.gnugrep
                    ]
                }"

                runHook postInstall
            '';

            };
        }
        );

        apps = forAllSystems (system: {
            default = {
                type = "app";
                program = "${self.packages.${system}.default}/bin/git-remote-gcrypt-dr57";
            };
        });
    };
}
