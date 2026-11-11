#!/usr/bin/env bash
set -Eeuo pipefail
mkdir -p out downloads cache/dnf
rm -f out/*.iso out/*.log

docker run --rm \
  --privileged \
  --device /dev/kvm \
  --security-opt label=disable \
  -v "$PWD:/work" -v "$PWD/cache/dnf:/var/cache/dnf" -w /work \
  fedora:latest bash -euxo pipefail -c '
    mkdir -p /work/downloads /work/out /work/cache/dnf
    work_uid="$(stat -c %u /work)"
    work_gid="$(stat -c %g /work)"
    trap '\''chown -R "$work_uid:$work_gid" /work/lmc-result /work/out /work/downloads /work/cache 2>/dev/null || true'\'' EXIT
    dnf -y install lorax-lmc-novirt pykickstart anaconda-tui anaconda-core \
      lorax lsof squashfs-tools xorriso grub2-efi-x64 grub2-efi-x64-cdboot \
      grub2-pc-modules shim-x64 \
      qemu-kvm qemu-img edk2-ovmf virt-install libvirt-client curl
    rm -rf /work/lmc-result
    ISO_DIR="https://download.fedoraproject.org/pub/fedora/linux/releases/45/Everything/x86_64/iso"
    ISO_NAME="Fedora-Everything-netinst-x86_64-45-1.4.iso"
    if [ ! -s /work/downloads/Fedora-Everything-netinst.iso ]; then
      curl --fail --location --retry 3 "$ISO_DIR/$ISO_NAME" --output /work/downloads/Fedora-Everything-netinst.iso
    else
      echo "Reusing cached Fedora netinst ISO."
    fi
    test -s /work/downloads/Fedora-Everything-netinst.iso
    test -s /usr/share/edk2/ovmf/OVMF_CODE.fd
    test -e /dev/kvm
    build_succeeded=0
    for attempt in 1 2 3; do
      rm -rf /work/lmc-result
      echo "Starting Fedora image installation attempt $attempt/3."
      if livemedia-creator \
        --make-iso --virt \
        --iso /work/downloads/Fedora-Everything-netinst.iso \
        --ks fedora/touch-live.ks \
        --project "Fedora Touch Live" \
        --releasever 45 \
        --resultdir /work/lmc-result \
        --logfile "/work/out/livemedia-creator-attempt-$attempt.log" \
        --volid FEDORA_TOUCH; then
        build_succeeded=1
        break
      fi

      if [ -f /work/out/virt-install.log ]; then
        cp /work/out/virt-install.log "/work/out/virt-install-attempt-$attempt.log"
      fi
      if [ "$attempt" -eq 3 ] || ! grep -Eiq "No more mirrors to try|Failed to download.*packages|PayloadInstallationError" /work/out/virt-install.log 2>/dev/null; then
        echo "Fedora image installation failed; error is not a retryable mirror/package download failure or retry limit was reached." >&2
        exit 1
      fi
      echo "Package mirror/download failure detected. Refreshing the installer session and retrying in 20 seconds."
      sleep 20
    done
    if [ "$build_succeeded" -ne 1 ]; then
      echo "Fedora image installation did not succeed after three attempts." >&2
      exit 1
    fi
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
