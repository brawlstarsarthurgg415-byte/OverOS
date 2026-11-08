/*
 * overosctl — safe, read-only first-stage system inspection command.
 * Mutating service/package/disk commands will only be added with explicit
 * confirmation and dedicated safety checks.
 */
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <sys/utsname.h>
#include <unistd.h>

namespace fs = std::filesystem;

namespace {
std::string read_line(const fs::path& path) {
    std::ifstream in(path);
    std::string value;
    if (in && std::getline(in, value)) return value;
    return "indisponivel";
}

void help() {
    std::cout
        << "overosctl — controle e diagnostico do OverOS\n\n"
        << "Uso:\n"
        << "  overosctl help       Mostra esta ajuda\n"
        << "  overosctl version    Mostra a versao do utilitario\n"
        << "  overosctl status     Mostra estado basico do sistema\n"
        << "  overosctl hardware   Executa o inventario de hardware\n\n"
        << "Esta versao nao altera discos, particoes, rede ou servicos.\n";
}

int status() {
    struct utsname info {};
    std::cout << "OverOS — status\n";
    if (uname(&info) == 0) {
        std::cout << "kernel: " << info.release << '\n';
        std::cout << "architecture: " << info.machine << '\n';
    } else {
        std::cout << "kernel: indisponivel\n";
    }
    std::cout << "hostname: " << read_line("/proc/sys/kernel/hostname") << '\n';
    std::cout << "uptime_seconds: " << read_line("/proc/uptime") << '\n';
    std::cout << "memory: " << read_line("/proc/meminfo") << '\n';
    std::cout << "root_filesystem: " << (fs::exists("/proc/1") ? "procfs presente" : "procfs ausente") << '\n';
    return 0;
}
}

int main(int argc, char** argv) {
    if (argc != 2) {
        help();
        return argc == 1 ? 0 : 2;
    }
    const std::string command = argv[1];
    if (command == "help" || command == "--help" || command == "-h") {
        help();
        return 0;
    }
    if (command == "version" || command == "--version") {
        std::cout << "overosctl 0.2.0\n";
        return 0;
    }
    if (command == "status") return status();
    if (command == "hardware") {
        const char* executable = "/usr/bin/overos-hardware-info";
        if (access(executable, X_OK) != 0) executable = "./overos-hardware-info";
        execlp("overos-hardware-info", "overos-hardware-info", static_cast<char*>(nullptr));
        execl(executable, executable, static_cast<char*>(nullptr));
        std::cerr << "Nao foi possivel iniciar overos-hardware-info.\n";
        return 127;
    }
    std::cerr << "Comando desconhecido: " << command << "\n";
    help();
    return 2;
}
