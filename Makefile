.PHONY: all clean

DEBUG_FLAGS:=-fno-pie -g
LINUX_FLAGS:=-D_GNU_SOURCE

all: backtrace.so test otest

backtrace.so : backtrace.c
	gcc ${LINUX_FLAGS} ${DEBUG_FLAGS} -DBUILDING_BACKTRACE_LIB -fPIC -O2 -shared -Wall -o $@ $^ -lbfd -liberty -lz

test : test.c
	gcc ${LINUX_FLAGS} ${DEBUG_FLAGS} -Wall -o $@ $^ -ldl

otest : otest.ooc
	rock -v -g --nolines -o=$@ $^ -ldl

clean :
	@rm -f backtrace.so test otest
	@rm -rf .libs rock_tmp 
