/*
 * OverOS hardware-info — read-only Linux hardware inventory.
 * Reads procfs/sysfs; does not mount, write, or change device configuration.
 */
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <system_error>
#include <sys/utsname.h>

namespace fs = std::filesystem;

static std::string read_first_line(const fs::path& path) {
    std::ifstream input(path);
    std::string value;
    if (input.good()) std::getline(input, value);
    return value.empty() ? "unavailable" : value;
}

static void print_memory() {
    std::ifstream input("/proc/meminfo");
    std::string key;
    unsigned long long value = 0;
    std::string unit;
    while (input >> key >> value >> unit) {
        if (key == "MemTotal:") {
            std::cout << "memory_total_kib: " << value << '\n';
            return;
        }
    }
    std::cout << "memory_total_kib: unavailable\n";
}

static void print_cpu() {
    std::ifstream cpu("/proc/cpuinfo");
    std::string line;
    while (std::getline(cpu, line)) {
        if (line.rfind("model name", 0) == 0 ||
            line.rfind("Hardware", 0) == 0 ||
            line.rfind("Processor", 0) == 0) {
            const auto separator = line.find(':');
            std::cout << "cpu:" << (separator == std::string::npos
                ? " unavailable" : line.substr(separator + 1)) << '\n';
            return;
        }
    }
    std::cout << "cpu: see /proc/cpuinfo\n";
}

static void print_graphics() {
    const fs::path drm{"/sys/class/drm"};
    std::error_code error;
    if (!fs::exists(drm, error)) {
        std::cout << "graphics: DRM sysfs unavailable\n";
        return;
    }

    bool found = false;
    for (const auto& entry : fs::directory_iterator(drm, error)) {
        if (error) break;
        const auto name = entry.path().filename().string();
        if (name.rfind("card", 0) != 0 || name.find('-') != std::string::npos)
            continue;
        found = true;
        std::cout << "graphics_device: " << name;
        const auto driver = fs::read_symlink(entry.path() / "device/driver", error);
        if (!error) std::cout << " driver=" << driver.filename().string();
        error.clear();
        std::cout << '\n';
    }
    if (!found) std::cout << "graphics_device: no DRM card found\n";
}

static void print_input_devices() {
    std::ifstream input("/proc/bus/input/devices");
    std::string line;
    unsigned int count = 0;
    while (std::getline(input, line)) {
        if (line.rfind("N: Name=", 0) == 0) {
            std::cout << "input_device: " << line.substr(8) << '\n';
            ++count;
        }
    }
    if (count == 0) std::cout << "input_device: unavailable\n";
}

static void print_block_devices() {
    const fs::path blocks{"/sys/block"};
    std::error_code error;
    if (!fs::exists(blocks, error)) {
        std::cout << "block_device: sysfs unavailable\n";
        return;
    }
    for (const auto& entry : fs::directory_iterator(blocks, error)) {
        if (error) break;
        const auto name = entry.path().filename().string();
        const auto removable = read_first_line(entry.path() / "removable");
        const auto sectors = read_first_line(entry.path() / "size");
        std::cout << "block_device: " << name
                  << " removable=" << removable
                  << " sectors_512=" << sectors << '\n';
    }
}

int main() {
    struct utsname system_info {};
    std::cout << "OverOS hardware inventory (read-only)\n";
    if (uname(&system_info) == 0) {
        std::cout << "kernel: " << system_info.release << '\n';
        std::cout << "architecture: " << system_info.machine << '\n';
    } else {
        std::cout << "kernel: " << read_first_line("/proc/sys/kernel/osrelease") << '\n';
    }
    std::cout << "hostname: " << read_first_line("/proc/sys/kernel/hostname") << '\n';
    std::cout << "firmware_mode: "
              << (fs::exists("/sys/firmware/efi") ? "UEFI" : "legacy-or-unavailable") << '\n';
    print_memory();
    print_cpu();
    print_graphics();
    print_input_devices();
    print_block_devices();
    std::cout << "note: this tool only reads procfs/sysfs; no disks are modified\n";
    return 0;
}
