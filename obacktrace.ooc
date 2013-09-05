
// sdk
import os/[Env, Dynlib]
import io/[File, StringReader]
import text/StringTokenizer
import structs/[ArrayList, List]

BacktraceHandler: class {
    
    // singleton
    instance: static This

    get: static func -> This {
        instance
    }

    // DLL
    lib: Dynlib

    // fancy?
    fancy? := true

    // funcs
    registerCallback, provoke: Pointer

    init: func {
        if (Env get("NO_FANCY_BACKTRACE")) {
            fancy? = false
            return
        }

        try {
            lib = Dynlib new("backtrace")
        } catch (e: DynlibException) { lib = null }

        if (!lib) try {
            lib = Dynlib new("./backtrace")
        } catch (e: DynlibException) { lib = null }

        if (lib) {
            initFuncs()

            // get rid of rock's built-in stuff
            Env set("FANCY_BACKTRACE", "1")
        } else {
            // couldn't load :(
            fancy? = false
        }
    }

    initFuncs: func {
        if (!lib) return

        registerCallback = lib symbol("backtrace_register_callback")
        if (!registerCallback) {
            stderr write("Couldn't get registerCallback symbol!\n")
            return
        }

        provoke = lib symbol("backtrace_provoke")
        if (!provoke) {
            stderr write("Couldn't get provoke symbol!\n")
            return
        }
    }

    onBacktrace: func (callback: Func(CString)) {
        if (!lib) return

        f := (registerCallback, null) as Func (Pointer, Pointer)
        c := callback as Closure
        f(c thunk, c context)
    }

    printBacktrace: func {
        if (!lib) return

        f := (provoke, null) as Func
        f()
    }

}

{
    BacktraceHandler instance = BacktraceHandler new()
    BacktraceHandler get() onBacktrace(|ctrace|
        trace := ctrace toString()
        if (Env get("RAW_BACKTRACE")) {
            "[original backtrace]" println()
            trace print()
            return
        }

        "[fancy backtrace]" println()
        lines := trace split('\n')

        frameno := 0
        elements := ArrayList<TraceElement> new()

        for (l in lines) {
            tokens := l split('|') map(|x| x trim())

            if (tokens size <= 4) {
                if (tokens size >= 2) {
                    binary := tokens[0]
                    file := "(from %s)" format(binary)
                    elements add(TraceElement new(frameno, tokens[2], "", file))
                }
            } else {
                filename := tokens[3]
                lineno := tokens[4]

                mangled := tokens[2]
                (package, fullName) := Unmangler unmangle(mangled)
                file := "(at %s:%s)" format(filename, lineno)
                elements add(TraceElement new(frameno, fullName, package, file))
            }
            frameno += 1
        }

        maxSymbolSize := 0
        maxPackageSize := 0
        maxFileSize := 0
        for (elem in elements) {
            if (elem symbol size > maxSymbolSize) {
                maxSymbolSize = elem symbol size
            }
            if (elem package size > maxPackageSize) {
                maxPackageSize = elem package size
            }
            if (elem file size > maxFileSize) {
                maxFileSize = elem file size
            }
        }

        for (elem in elements) {
            "%s  %s  %s  %s" printfln(
                TraceElement pad(elem frameno toString(), 4),
                TraceElement pad(elem symbol, maxSymbolSize),
                TraceElement pad(elem package, maxPackageSize),
                TraceElement pad(elem file, maxFileSize)
            )
        }
    )
}

TraceElement: class {
    frameno: Int
    symbol, package, file: String

    init: func (=frameno, =symbol, =package, =file) {
    }

    pad: static func (s: String, length: Int) -> String {
        if (s size < length) {
            b := Buffer new()
            b append(s)
            for (i in (s size)..length) {
                b append(' ')
            }
            return b toString()
        }
        s
    }
}

Unmangler: class {

    unmangle: static func (s: String) -> (String, String) {
        if (!s contains?("__")) {
            // simple symbol
            return ("", s)
        }

        reader := StringReader new(s)

        package := ""
        while (reader hasNext?()) {
            c := reader read()
            match c {
                case '_' =>
                    if (reader peek() == '_') {
                        // it's the end! skip that second underscore
                        reader read()
                        break // while
                    } else {
                        // package element
                        package += '/'
                    }
                case =>
                    // accumulate
                    package += c
            }
        }

        type := ""
        if (reader peek() upper?()) {
            while (reader hasNext?()) {
                c := reader read()
                match c {
                    case '_' =>
                        // done!
                        break // while
                    case =>
                        // accumulate
                        type += c 
                }
            }
        }

        name := reader readAll()

        fullName := match (type size) {
            case 0 =>
                name
            case =>
                "%s %s" format(type, name)
        }
        
        r1 := "in %s" format(package)
        r2 := "%s()" format(fullName)
        (r1, r2)
    }

}

