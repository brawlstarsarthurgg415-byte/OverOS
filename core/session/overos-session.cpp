#include <cstdlib>
#include <iostream>
#include <string>
#include <unistd.h>

namespace {
void clear_screen() {
    std::cout << "\033[2J\033[H";
}

void pause() {
    std::cout << "\nPressione Enter para voltar...";
    std::string ignored;
    std::getline(std::cin, ignored);
}

void show_header() {
    std::cout << "\033[1;36m"
              << "  ==============================\n"
              << "          O V E R O S\n"
              << "  ==============================\n"
              << "\033[0m"
              << "  Sistema independente • modo inicial\n\n";
}

void show_system_info() {
    clear_screen();
    show_header();
    char hostname[256]{};
    if (gethostname(hostname, sizeof(hostname)) == 0) {
        hostname[sizeof(hostname) - 1] = '\0';
        std::cout << "Computador: " << hostname << '\n';
    } else {
        std::cout << "Computador: indisponivel\n";
    }
    std::cout << "Kernel: " << "consulte /proc/sys/kernel/osrelease\n";
    std::cout << "Memoria: consulte /proc/meminfo\n";
    std::cout << "\nEsta sessao ainda nao inicia servicos graficos.\n";
    pause();
}
}

int main() {
    for (;;) {
        clear_screen();
        show_header();
        std::cout << "  [1] Meu computador\n"
                  << "  [2] Terminal\n"
                  << "  [3] Sobre o OverOS\n"
                  << "  [0] Encerrar sessao\n\n"
                  << "  Escolha: " << std::flush;

        std::string choice;
        if (!std::getline(std::cin, choice)) return 0;
        if (choice == "1") {
            show_system_info();
        } else if (choice == "2") {
            clear_screen();
            std::cout << "Terminal do OverOS\n"
                      << "Digite exit para retornar.\n\n";
            if (access("/bin/sh", X_OK) == 0) {
                const int result = std::system("/bin/sh");
                if (result == -1) std::cout << "Falha ao iniciar o shell.\n";
            } else {
                std::cout << "Shell ainda nao instalado nesta imagem.\n";
            }
            pause();
        } else if (choice == "3") {
            clear_screen();
            show_header();
            std::cout << "OverOS 0.2 — prototipo de espaco de usuario.\n"
                      << "Construido principalmente com C e C++.\n"
                      << "Nenhuma instalacao em disco e realizada.\n";
            pause();
        } else if (choice == "0") {
            return 0;
        }
    }
}
