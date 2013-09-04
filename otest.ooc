include windows

HModule: cover from HMODULE
LoadLibraryA: extern func (CString) -> HModule
GetProcAddress: extern func (HModule, CString) -> Pointer

RaiseException: extern func (ULong, ULong, ULong, Pointer)

foo: func {
    //f: Int* = null
    //f@ = 0
    RaiseException(0, 0, 0, null)
}

bar: func {
    foo()
}

main: func {
    module := LoadLibraryA("backtrace.dll")
    bar()

    p := GetProcAddress(module, "MingwBacktraceGetBuffer")
    if (!p) {
        "proc not found!" println()
        exit(1)
    }

    getBuffer := (p, null) as Func -> CString
    r := getBuffer()
    "Output gotten: %s" printfln(r)

    0
}
