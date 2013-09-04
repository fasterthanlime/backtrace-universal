
// ours
import obacktrace

// sdk
import os/Terminal
import io/File
import text/StringTokenizer
import structs/[ArrayList, List]

include windows

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
    app := App new()
    app run()
    0
}

App: class {

    name: String

    init: func {
        name = "myapp"
        "Just starting out app %s" printfln(name)

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
        Terminal setFgColor(Color red)
        "We just got called back in %s!" printfln(name)
        Terminal reset()

        "Original backtrace =\n%s" printfln(trace)

        "Backtrace =" println()
        lines := trace split('\n')
        frameno := 0

        for (l in lines) {
            output := "%4d   " format(frameno)

            tokens := l split('|') map(|x| x trim())
            if (tokens size <= 4) {
                if (tokens size >= 2) {
                    output += tokens[2]
                }
            } else {
                baseFuncName := tokens[2]
                t3 := baseFuncName split("__")

                filename := tokens[3]
                filenameTokens := filename split(File separator)
                filenameTokens = filenameTokens[-1] split('/')
                filename = filenameTokens[-1]

                lineno := tokens[4]

                if (t3 size >= 2) {
                    i := 1
                    while (t3[i] empty?()) {
                        i += 1
                    }
                    funcName := t3[i]

                    package := t3[0] replaceAll('_', '/')

                    if (funcName[0] upper?() && funcName contains?('_')) {
                        funcParts := funcName split('_')
                        realName := match (funcParts size) {
                            case 2 =>
                                "%s#%s" format(funcParts[0], funcParts[1])
                            case 3 =>
                                "%s#%s~%s" format(funcParts[0], funcParts[1], funcParts[2])
                        }
                        output += "%s\t %s" format(package, realName)
                    } else {
                        output += "%s\t %s" format(package, funcName)
                    }
                } else {
                    output += t3[0]
                }
                output += " \t(in %s:%s)" format(filename, lineno)
                output println()
            }
            frameno += 1
        }

        Terminal setFgColor(Color red)
        "Done!" println()
        Terminal reset()
    }

    pad: func (s: String, length: Int) -> String {
        if (s size < length) {
            return s + " " * (length - s size)
        }
        s
    }

}

