//
//  root.m
//  rootspawn
//
//  Created by Lakr Aream on 2021/12/15.
//

#import <Foundation/Foundation.h>

#import <dlfcn.h>
#import <sysexits.h>
#import <sys/stat.h>

#import "RootMe.h"

/* Set platform binary flag */
#define FLAG_PLATFORMIZE (1 << 1)
int proc_pidpath(pid_t pid, void *buffer, uint32_t buffersize);

#define PROC_PIDPATHINFO_MAXSIZE (2048)

void patch_setuidandplatformize(void) {
    void *handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle)
        return;
    
    dlerror();
    
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t setuidptr =
    (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t entitleptr =
    (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
    
    setuidptr(getpid());
    
    setuid(0);
    
    const char *dlsym_error = dlerror();
    if (dlsym_error) {
        return;
    }
    
    entitleptr(getpid(), FLAG_PLATFORMIZE);
}

void root_check(void) {
    const char *privilegedPrefix = "/Applications/";
    pid_t parentPID = getppid();
    char parentPath[PROC_PIDPATHINFO_MAXSIZE] = {0};
    int status = proc_pidpath(parentPID, parentPath, sizeof(parentPath));
    if (status <= 0) {
        fprintf(stderr, "Permission denied: missing parent info\n");
        exit(EX_NOPERM);
    }
    if (strncmp(parentPath, privilegedPrefix, strlen(privilegedPrefix)) != 0) {
        fprintf(stderr,
                "Permission denied: parent outside the privileged prefix [%s]\n",
                privilegedPrefix);
        exit(EX_NOPERM);
    }
}

void root_me(void) {
    patch_setuidandplatformize();
    
    setuid(0);
    setgid(0);
    
    if (getuid() != 0) {
        fprintf(stderr, "Permission denied: failed to call setuid/setgid\n");
        exit(EX_NOPERM);
    }
}

static char *prefix = "fouldecrypt";

void root_exec(int argc, char* argv[]) {
    if (strcmp(argv[2], "whoami") == 0) {
        printf("root\n");
        exit(0);
    }
    if (strncmp(argv[0], prefix, strlen(prefix)) == 0) {
        chmod(argv[0], 0755);
    }
    execv(argv[2], &argv[2]);
}
