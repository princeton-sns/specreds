
all: singleCOW conCOW writer

singleCOW: singleCOW.c ioutil.c
	gcc ioutil.c singleCOW.c -pthread -o singleCOW

conCOW: conCOW.c ioutil.c
	gcc ioutil.c conCOW.c -pthread -o conCOW

writer: writer.c ioutil.c
	gcc ioutil.c writer.c -pthread -o writer

clean:
	rm -f singleCOW conCOW writer 

