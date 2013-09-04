include windows

HModule: cover from HMODULE
LoadLibraryA: extern func (CString) -> HModule
GetProcAddress: extern func (HModule, CString) -> Pointer

BacktraceHandler: class {
    
    // singleton
    instance: static This

    get: static func -> This {
        instance
    }

    // DLL
    module: HModule

    // funcs
    registerCallback: Pointer

    init: func {
        module = LoadLibraryA("backtrace.dll")
        if (!module) {
            // couldn't load backtrace.dll, backtraces disabled
            stderr write("Couldn't load backtrace.dll!\n")
            return
        }

        initFuncs()
    }

    initFuncs: func {
        if (!module) return

        registerCallback = GetProcAddress(module, "backtrace_register_callback")
        if (!registerCallback) {
            // couldn't get callback-registering symbol, backtraces disabled
            stderr write("Couldn't get registerCallback symbol!\n")
            return
        }
    }

    onBacktrace: func (callback: Func(CString)) {
        if (!module) return

        f := (registerCallback, null) as Func (Pointer, Pointer)
        c := callback as Closure
        f(c thunk, c context)
    }

}

{
    BacktraceHandler instance = BacktraceHandler new()
}

