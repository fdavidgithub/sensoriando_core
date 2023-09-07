PG_INCLUDE_PATH= -I/usr/include/postgresql

all: compile
debug: compile_debug

compile: 
	gcc -c database.c $(PG_INCLUDE_PATH) -o database.o  
	gcc subscriber.c database.o $(PG_INCLUDE_PATH) -lpq -lpaho-mqtt3c -o subscriber

compile_debug: 
	gcc -c database.c $(PG_INCLUDE_PATH) -DDEBUG -o database.o 
	gcc subscriber.c database.o $(PG_INCLUDE_PATH) -lpq -lpaho-mqtt3c -DDEBUG -o subscriber

clear:
	rm  *.o* *.~ subscriber

