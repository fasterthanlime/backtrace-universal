.PHONY: all clean

all : backtrace.dll test.exe otest.exe

backtrace.dll : backtrace.c
	gcc -DBUILDING_BACKTRACE_DLL -O2 -shared -Wall -o $@ $^ -lbfd -lintl -liberty -limagehlp

test.exe : test.c
	gcc -gstabs -Wall -o $@ $^

otest.exe : otest.ooc
	rock -g -o=$@ $^

clean :
	@rm -f backtrace.dll test.exe otest.exe .libs rock_tmp
