{
  description = "Terraform binary downloaded from Hashicorp";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    let
      download_suffixes = with flake-utils.lib; {
        system.x86_64-linux = "linux_amd64";
        system.aarch64-linux = "linux_arm64";
        system.x86_64-darwin = "darwin_amd64";
        system.aarch64-darwin = "darwin_arm64";
      };
      download_hashes = with flake-utils.lib; {
        "1.3.7" = {
          system.x86_64-linux =
            "sha256:b8cf184dee15dfa89713fe56085313ab23db22e17284a9a27c0999c67ce3021e";
          system.aarch64-linux =
            "sha256:5b491c555ea8a62dda551675fd9f27d369f5cdbe87608d2a7367d3da2d38ea38";
          system.x86_64-darwin =
            "sha256:aa111cd80d84586697d1643c6c21452d34f70e5bc639e4106856f59382351397";
          system.aarch64-darwin =
            "sha256:8860db524d1a51435cbed731902c7de1595348c09dd5b3a342024405c8e7ef74";
        };
      };
    in with flake-utils.lib;
    eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        download_tf = version:
          let
            suffix = download_suffixes.system.${system};
            hash = download_hashes.${version}.system.${system};
          in pkgs.fetchurl {
            inherit hash;
            url = "https://releases.hashicorp.com/terraform/" + version
              + "/terraform_" + version + "_" + suffix + ".zip";
          };
        build_package = version:
          pkgs.stdenv.mkDerivation {
            name = "terraform-" + version;
            nativeBuildInputs = [ pkgs.unzip ];
            buildInputs = [ pkgs.unzip ];
            src = download_tf version;

            unpackPhase = "unzip $src";

            buildPhase = "";

            installPhase = ''
              mkdir -p $out/bin
              cp terraform $out/bin/terraform
              chmod 755 $out/bin/terraform
            '';
          };
      in {
        packages = rec {
          default = terraform_1_3;
          terraform_1_3 = terraform_1_3_7;
          terraform_1_3_7 = build_package "1.3.7";
        };

        formatter = pkgs.nixfmt;
      });
}
