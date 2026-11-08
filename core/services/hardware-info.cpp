/*
 * OverOS hardware-info — read-only Linux hardware inventory.
 * Reads procfs/sysfs; does not change device or system configuration.
 */
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <unistd.h>

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

int main() {
    std::cout << "OverOS hardware inventory (read-only)\n";
    std::cout << "kernel: " << read_first_line("/proc/sys/kernel/osrelease") << '\n';
    std::cout << "hostname: " << read_first_line("/proc/sys/kernel/hostname") << '\n';
    print_memory();

    const fs::path cpuinfo{"/proc/cpuinfo"};
    std::ifstream cpu(cpuinfo);
    std::string line;
    bool printed_cpu = false;
    while (std::getline(cpu, line)) {
        if (line.rfind("model name", 0) == 0 ||
            line.rfind("Hardware", 0) == 0 ||
            line.rfind("Processor", 0) == 0) {
            std::cout << "cpu: " << line.substr(line.find(':') + 1) << '\n';
            printed_cpu = true;
            break;
        }
    }
    if (!printed_cpu) std::cout << "cpu: see /proc/cpuinfo\n";

    const fs::path drm{"/sys/class/drm"};
    if (fs::exists(drm)) {
        for (const auto& entry : fs::directory_iterator(drm)) {
            const auto name = entry.path().filename().string();
            if (name.find("card") == 0 && name.find('-') == std::string::npos)
                std::cout << "graphics_device: " << name << '\n';
        }
    } else {
        std::cout << "graphics_device: DRM sysfs unavailable\n";
    }

    std::cout << "note: this tool only reads system information\n";
    return 0;
}
