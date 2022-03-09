{ hostName, diskSize, memorySize, ... }:

{ ... }: {
  virtualbox = {
    vmName = hostName;
    baseImageFreeSpace = diskSize * 1024;
    memorySize = memorySize * 1024;

    params = {
      # tune for macOS, remove warnings
      usbehci = "off";
      graphicscontroller = "vboxvga";

      # CPU
      cpus = "2";

      # disable useless emulation
      audio = "none";
      audioin = "off";
      audioout = "off";

      # add necessary NICs
      nictype1 = "virtio";
      nic1 = "nat";
      nictype2 = "virtio";
      nic2 = "hostonly";
    };
  };
}
