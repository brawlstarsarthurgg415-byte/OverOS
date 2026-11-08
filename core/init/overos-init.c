/*
 * OverOS init — minimal PID 1 prototype.
 *
 * This is an early development component, not yet a production init system.
 * It never formats disks or attempts an installation.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile sig_atomic_t child_changed = 0;

static void on_sigchld(int signal_number) {
    (void)signal_number;
    child_changed = 1;
}

static void log_line(const char *message) {
    (void)write(STDERR_FILENO, "overos-init: ", 13);
    (void)write(STDERR_FILENO, message, strlen(message));
    (void)write(STDERR_FILENO, "\n", 1);
}

static void mount_virtual_fs(const char *source, const char *target,
                             const char *type, unsigned long flags) {
    if (mount(source, target, type, flags, NULL) == -1 && errno != EBUSY) {
        char buffer[192];
        (void)snprintf(buffer, sizeof(buffer), "mount %s failed: %s",
                       target, strerror(errno));
        log_line(buffer);
    }
}

static void prepare_early_userspace(void) {
    (void)mkdir("/proc", 0555);
    (void)mkdir("/sys", 0555);
    (void)mkdir("/dev", 0755);
    (void)mkdir("/run", 0755);
    mount_virtual_fs("proc", "/proc", "proc", 0);
    mount_virtual_fs("sysfs", "/sys", "sysfs", 0);
    mount_virtual_fs("devtmpfs", "/dev", "devtmpfs", 0);
    mount_virtual_fs("tmpfs", "/run", "tmpfs", 0);
}

int main(void) {
    if (getpid() != 1) {
        log_line("must run as PID 1; refusing to continue");
        return EXIT_FAILURE;
    }

    (void)setsid();
    prepare_early_userspace();

    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = on_sigchld;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_RESTART | SA_NOCLDSTOP;
    (void)sigaction(SIGCHLD, &action, NULL);

    log_line("OverOS early userspace started");
    log_line("starting emergency console");

    for (;;) {
        pid_t child = fork();
        if (child == -1) {
            log_line("fork failed; retrying");
            sleep(2);
            continue;
        }

        if (child == 0) {
            (void)setsid();
            (void)chdir("/");
            execl("/sbin/overos-session", "overos-session", (char *)NULL);
            execl("/bin/sh", "sh", (char *)NULL);
            _exit(127);
        }

        int status = 0;
        while (waitpid(child, &status, 0) == -1 && errno == EINTR) {
        }
        child_changed = 0;
        log_line("console/session exited; restarting fallback");
        sleep(1);
    }
}
