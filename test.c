#include <windows.h>

static void foo() {
    int *f=NULL;
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
    LoadLibraryA("backtrace.dll");
    baz();

    return 0;
}
