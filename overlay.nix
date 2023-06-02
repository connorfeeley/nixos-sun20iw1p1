final: prev:

rec {
  # gnu-efi 3.0.17 is broken for riscv but was fixed a few patches later
  gnu-efi = prev.gnu-efi.overrideAttrs (o: {
    version = "3.0.18-pre";
    src = prev.fetchFromGitHub {
      owner = "vathpela";
      repo = o.pname;
      rev = "039ca9d93c1eb5601f5b1a8bd812fd4b7d4de370";
      hash = "sha256-QWTKYePhRUFOaPT+AQCMjrV6MNtTOqyayx8+CQdM1J4=";
    };
  });
  sun20i-d1-spl = prev.callPackage ./spl.nix { };
  ubootLicheeRV = prev.callPackage ./uboot.nix { };
  linux_nezha = prev.callPackage ./linux.nix { };
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor = kernel:
    let origin = prev.linuxKernel.packagesFor kernel; in
    origin // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}
