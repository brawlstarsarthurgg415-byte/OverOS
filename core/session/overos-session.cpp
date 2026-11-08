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
    std::cout << "\033[1;36m";
    std::cout << "  ____                 ___  ____\n";
    std::cout << " / __ \\__   _____ _ __/ _ \\/ ___|\n";
    std::cout << "| |  | \\ \\ / / _ \\ '__| | | \\___ \\n";
    std::cout << "| |__| |\\ V /  __/ |  | |_| |___) |\n";
    std::cout << " \\____/  \\_/ \\___|_|   \\___/|____/\n";
    std::cout << "\033[0m";
    std::cout << "  Sistema independente • modo inicial\n\n";
}

void show_system_info() {
    clear_screen();
    show_header();
    std::cout << "Computador: ";
    char hostname[256]{};
    if (gethostname(hostname, sizeof(hostname)) == 0) std::cout << hostname;
    else std::cout << "indisponivel";
    std::cout << "\nKernel: ";
    std::cout << "consulte /proc/sys/kernel/osrelease\n";
    std::cout << "Memoria: consulte /proc/meminfo\n";
    std::cout << "\nEste prototipo ainda nao inicializa servicos graficos.\n";
    pause();
}
}

int main() {
    for (;;) {
        clear_screen();
        show_header();
        std::cout << "  [1] Meu computador\n";
        std::cout << "  [2] Terminal\n";
        std::cout << "  [3] Sobre o OverOS\n";
        std::cout << "  [0] Encerrar sessao\n\n";
        std::cout << "  Escolha: " << std::flush;

        std::string choice;
        if (!std::getline(std::cin, choice)) return 0;
        if (choice == "1") {
            show_system_info();
        } else if (choice == "2") {
            clear_screen();
            std::cout << "Terminal do OverOS (shell disponivel no ambiente)\n";
            std::cout << "Digite exit para retornar.\n\n";
            const char* shell = access("/bin/sh", X_OK) == 0 ? "/bin/sh" : nullptr;
            if (shell) std::system(shell);
            else std::cout << "Shell ainda nao instalado nesta imagem.\n";
            pause();
        } else if (choice == "3") {
            clear_screen();
            show_header();
            std::cout << "OverOS 0.1 — prototipo de espaco de usuario.\n";
            std::cout << "Construido com C e C++.\n";
            std::cout << "Nenhuma instalacao em disco e realizada.\n";
            pause();
        } else if (choice == "0") {
            return 0;
        }
    }
}
