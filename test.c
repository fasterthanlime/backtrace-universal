
#ifdef __MINGW32__
#include <windows.h>
#else
#include <stddef.h>
#include <dlfcn.h>
#endif

static void foo() {
    int *f = NULL;
    *f = 0;
}

static void bar() {
    foo();
}

static void baz() {
    int x = 0;
    x += 1;
    bar();
}

int main() {
    #ifdef __MINGW32__
    LoadLibraryA("backtrace.dll");
    #else
      #if __linux__
      dlopen("backtrace.so", RTLD_LAZY);
      #else
      dlopen("backtrace.dylib", RTLD_LAZY);
      #endif
    #endif
    baz();

    return 0;
}
