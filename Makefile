.PHONY: all clean

all : backtrace.dll test.exe

backtrace.dll : backtrace.c
	gcc -O2 -shared -Wall -o $@ $^ -lbfd -lintl -liberty -limagehlp

test.exe : test.c
	gcc -gstabs -Wall -o $@ $^

otest.exe : test.ooc
	rock -v -g -o $@ $^

clean :
	@rm -f backtrace.dll test.exe otest.exe
