
// ours
import obacktrace

// sdk
import structs/[ArrayList, List]

include windows

RaiseException: extern func (ULong, ULong, ULong, Pointer)

foo: func {
    // Sigsegv
    //f: Int* = null
    //f@ = 0

    // Raise Win32 exception ourselves
    //RaiseException(0, 0, 0, null)

    // ooc exception
    a := ArrayList<Int> new()
    a[0] toString() println()
}

bar: func {
    foo()
}

main: func {
    app := App new()
    app run()
    0
}

App: class {
    init: func

    run: func {
        // Just print a cozy stack trace for now
        BacktraceHandler get() printBacktrace()

        loop(||
            runToo()
        )
    }

    runToo: func {
        bar()
    }
}

