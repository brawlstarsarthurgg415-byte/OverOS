#!/usr/bin/env bash
set -Eeuo pipefail
mkdir -p out downloads
rm -f out/*.iso out/*.log

docker run --rm \
  --privileged \
  --device /dev/kvm \
  --security-opt label=disable \
  -v "$PWD:/work" -w /work \
  fedora:latest bash -euxo pipefail -c '
    dnf -y install lorax-lmc-novirt pykickstart anaconda-tui anaconda-core \
      lorax lsof squashfs-tools xorriso grub2-efi-x64 shim-x64 \
      qemu-kvm qemu-img edk2-ovmf virt-install libvirt-client curl
    mkdir -p /work/downloads /work/out
    rm -rf /work/lmc-result
    ISO_DIR="https://download.fedoraproject.org/pub/fedora/linux/releases/45/Everything/x86_64/iso"
    ISO_NAME="$(curl --fail --location --retry 3 --silent --show-error "$ISO_DIR/" | grep -oE "Fedora-Everything-netinst-x86_64-45-[^<>[:space:]]+\\.iso" | sort -V | tail -n 1)"
    if [ -z "$ISO_NAME" ]; then
      echo "Não foi possível localizar a ISO netinst do Fedora 45." >&2
      exit 1
    fi
    curl --fail --location --retry 3 "$ISO_DIR/$ISO_NAME" --output /work/downloads/Fedora-Everything-netinst.iso
    test -s /usr/share/edk2/ovmf/OVMF_CODE.fd
    test -e /dev/kvm
    livemedia-creator \
      --make-iso --virt \
      --iso /work/downloads/Fedora-Everything-netinst.iso \
      --ks fedora/touch-live.ks \
      --project "Fedora Touch Live" \
      --releasever 45 \
      --resultdir /work/lmc-result \
      --logfile /work/out/livemedia-creator.log \
      --volid FEDORA_TOUCH
    shopt -s nullglob
    generated_isos=(/work/lmc-result/*.iso)
    if [ "${#generated_isos[@]}" -ne 1 ] || [ ! -s "${generated_isos[0]}" ]; then
      echo "livemedia-creator did not produce exactly one non-empty ISO." >&2
      find /work/lmc-result -maxdepth 2 -type f -printf "%p (%s bytes)\\n" >&2 || true
      exit 1
    fi
    cp "${generated_isos[0]}" /work/out/
  ' 2>&1 | tee out/build.log

sudo apt-get update
sudo apt-get install -y xorriso
bash fedora/grub/patch-iso-grub.sh out

shopt -s nullglob
isos=(out/*.iso)
if [ "${#isos[@]}" -ne 1 ] || [ ! -s "${isos[0]}" ]; then
  echo "Expected exactly one non-empty final ISO in out/." >&2
  exit 1
fi
echo "Validated ISO: ${isos[0]} ($(stat -c%s "${isos[0]}") bytes)"
