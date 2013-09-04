
// ours
import obacktrace

// sdk
import os/[Env]
import io/[File, StringReader]
import text/StringTokenizer
import structs/[ArrayList, List]

include windows

RaiseException: extern func (ULong, ULong, ULong, Pointer)

foo: func {
    //f: Int* = null
    //f@ = 0
    //RaiseException(0, 0, 0, null)

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

    name: String

    init: func {
        name = "myapp"

        BacktraceHandler get() onBacktrace(|backtrace|
            handleBacktrace(backtrace toString())
        )
    }

    run: func {
        loop(||
            runToo()
        )
    }

    runToo: func {
        bar()
    }

    handleBacktrace: func (trace: String) {
        if (Env get("NO_FANCY_BACKTRACE")) {
            "[original backtrace]" println()
            trace print()
            return
        }

        "[backtrace]" println()
        lines := trace split('\n')

        // skip 3 frames: RaiseException, throw and throwImpl
        for (i in 0..3) lines removeAt(0)

        frameno := 0
        elements := ArrayList<TraceElement> new()

        for (l in lines) {
            tokens := l split('|') map(|x| x trim())

            if (tokens size <= 4) {
                if (tokens size >= 2) {
                    elements add(TraceElement new(frameno, tokens[2], "", ""))
                }
            } else {
                filename := tokens[3]
                //filenameTokens := filename split(File separator)
                //filenameTokens = filenameTokens[-1] split('/')
                //filename = filenameTokens[-1]

                lineno := tokens[4]

                mangled := tokens[2]
                (package, fullName) := Unmangler unmangle(mangled)
                file := "(%s:%s)" format(filename, lineno)
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
            "%4d  %s  %s  %s" printfln(
                elem frameno,
                pad(elem symbol, maxSymbolSize),
                pad(elem package, maxPackageSize),
                pad(elem file, maxFileSize)
            )
        }
    }

    pad: func (s: String, length: Int) -> String {
        if (s size < length) {
            return s + " " * (length - s size)
        }
        s
    }

}

TraceElement: class {
    frameno: Int
    symbol, package, file: String

    init: func (=frameno, =symbol, =package, =file) {
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

