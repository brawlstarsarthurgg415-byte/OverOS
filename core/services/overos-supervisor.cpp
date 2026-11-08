/*
 * OverOS service supervisor prototype.
 * Starts only absolute executable paths from an administrator-owned config.
 * No shell is invoked. This is not yet integrated into PID 1.
 */
#include <cerrno>
#include <csignal>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>

namespace {
volatile std::sig_atomic_t stop_requested = 0;

void handle_signal(int) {
    stop_requested = 1;
}

struct Service {
    std::string path;
    pid_t pid = 0;
};

bool load_config(const std::string& path, std::vector<Service>& services) {
    std::ifstream input(path);
    if (!input) {
        std::cerr << "Nao foi possivel abrir a configuracao: " << path << '\n';
        return false;
    }

    std::string line;
    unsigned int line_number = 0;
    while (std::getline(input, line)) {
        ++line_number;
        const auto first = line.find_first_not_of(" \t\r");
        if (first == std::string::npos || line[first] == '#') continue;
        const auto last = line.find_last_not_of(" \t\r");
        const std::string executable = line.substr(first, last - first + 1);
        if (executable.front() != '/') {
            std::cerr << "Linha " << line_number
                      << ": caminho precisa ser absoluto\n";
            return false;
        }
        for (const auto& service : services) {
            if (service.path == executable) {
                std::cerr << "Linha " << line_number << ": servico duplicado\n";
                return false;
            }
        }
        services.push_back({executable, 0});
    }
    return !services.empty();
}

bool start(Service& service) {
    if (access(service.path.c_str(), X_OK) != 0) {
        std::cerr << "Executavel indisponivel: " << service.path << '\n';
        return false;
    }
    const pid_t child = fork();
    if (child < 0) {
        std::cerr << "fork falhou: " << std::strerror(errno) << '\n';
        return false;
    }
    if (child == 0) {
        (void)setsid();
        execl(service.path.c_str(), service.path.c_str(), (char*)nullptr);
        _exit(127);
    }
    service.pid = child;
    std::cout << "servico iniciado: " << service.path
              << " (pid " << child << ")\n";
    return true;
}

int check_config(const std::string& path) {
    std::vector<Service> services;
    if (!load_config(path, services)) return 2;
    std::cout << "Configuracao valida: " << services.size()
              << " servico(s)\n";
    for (const auto& service : services) std::cout << service.path << '\n';
    return 0;
}
}

int main(int argc, char** argv) {
    if (argc == 3 && std::string(argv[1]) == "--check-config")
        return check_config(argv[2]);
    if (argc > 2) {
        std::cerr << "Uso: overos-supervisor [arquivo-config]\n";
        return 2;
    }

    const std::string config = argc == 2 ? argv[1] : "/etc/overos/services.conf";
    std::vector<Service> services;
    if (!load_config(config, services)) return 2;

    struct sigaction action {};
    action.sa_handler = handle_signal;
    sigemptyset(&action.sa_mask);
    action.sa_flags = 0;
    (void)sigaction(SIGTERM, &action, nullptr);
    (void)sigaction(SIGINT, &action, nullptr);
    (void)sigaction(SIGQUIT, &action, nullptr);

    for (auto& service : services) (void)start(service);

    while (!stop_requested) {
        int status = 0;
        pid_t child = 0;
        while ((child = waitpid(-1, &status, WNOHANG)) > 0) {
            for (auto& service : services) {
                if (service.pid == child) {
                    std::cout << "servico terminou: " << service.path << '\n';
                    service.pid = 0;
                    break;
                }
            }
        }
        for (auto& service : services) {
            if (stop_requested) break;
            if (service.pid == 0) (void)start(service);
        }
        sleep(1);
    }

    for (const auto& service : services)
        if (service.pid > 0) (void)kill(service.pid, SIGTERM);

    for (int attempt = 0; attempt < 5; ++attempt) {
        bool any_running = false;
        for (auto& service : services) {
            if (service.pid <= 0) continue;
            const pid_t result = waitpid(service.pid, nullptr, WNOHANG);
            if (result == service.pid || (result < 0 && errno == ECHILD))
                service.pid = 0;
            else
                any_running = true;
        }
        if (!any_running) return 0;
        sleep(1);
    }

    for (const auto& service : services)
        if (service.pid > 0) (void)kill(service.pid, SIGKILL);
    for (auto& service : services) {
        if (service.pid > 0) {
            while (waitpid(service.pid, nullptr, 0) < 0 && errno == EINTR) {}
            service.pid = 0;
        }
    }
    return 0;
}
