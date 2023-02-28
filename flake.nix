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
      # SHA hashes are downloadable from links like
      # https://releases.hashicorp.com/terraform/1.3.9/terraform_1.3.9_SHA256SUMS
      download_hashes = with flake-utils.lib; {
        "1.3.7" = {
          system.x86_64-linux =
            "sha256:b8cf184dee15dfa89713fe56085313ab23db22e17284a9a27c0999c67ce3021e";
          system.aarch64-linux =
            "sha256:5b491c555ea8a62dda551675fd9f27d369f5cdbe87608d2a7367d3da2d38ea38";
          system.x86_64-darwin =
            "sha256:b00465acc7bdef57ba468b84b9162786e472dc97ad036a9e3526dde510563e2d";
          system.aarch64-darwin =
            "sha256:6cda396999c9a27cb90c4902913c10ac0afe1bfceb957ed50a4298c5872979cf";
        };
        "1.3.8" = {
          system.x86_64-linux =
            "sha256:9d9e7d6a9b41cef8b837af688441d4fbbd84b503d24061d078ad662441c70240";
          system.aarch64-linux =
            "sha256:a42bf3c7d6327f45d2b212b692ab4229285fb44dbb8adb7c39e18be2b26167c8";
          system.x86_64-darwin =
            "sha256:3cb29f95962947b0dbdf3f83338121879426d723ba60007e7c264c3c8a2add8f";
          system.aarch64-darwin =
            "sha256:4547a47be08350a3eb6e44fd28e957cf515c3a2b52e04f134366a08b1fbf03ec";
        };
        "1.3.9" = {
          system.x86_64-linux =
            "sha256:53048fa573effdd8f2a59b726234c6f450491fe0ded6931e9f4c6e3df6eece56";
          system.aarch64-linux =
            "sha256:da571087268c5faf884912c4239c6b9c8e1ed8e8401ab1dcb45712df70f42f1b";
          system.x86_64-darwin =
            "sha256:ca78815afd657f887de7f9b74014dc4bddffe80fd28028179b271a3c4f64f29a";
          system.aarch64-darwin =
            "sha256:9df6fc8a9264bba1058e6e9383f43af2ee816088e61925e5bc45128ad8b6e9ad";
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
          terraform_1_3 = terraform_1_3_9;
          terraform_1_3_7 = build_package "1.3.7";
          terraform_1_3_8 = build_package "1.3.8";
          terraform_1_3_9 = build_package "1.3.9";
        };

        formatter = pkgs.nixfmt;
      });
}
