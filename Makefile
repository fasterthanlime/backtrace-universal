.PHONY: all clean

all : backtrace.dll test.exe otest.exe

backtrace.dll : backtrace.c
	gcc -DBUILDING_BACKTRACE_LIB -O2 -shared -Wall -o $@ $^ -lbfd -lintl -liberty -limagehlp

test.exe : test.c
	gcc -g -Wall -o $@ $^

otest.exe : otest.ooc
	rock -v -g -o=$@ $^

clean :
	@rm -f backtrace.dll test.exe otest.exe
	@rm -rf .libs rock_tmp
