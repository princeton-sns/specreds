
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include "ioutil.h"

enum Arg_Index {INDEX_SIZE, INDEX_OBJ,
				INDEX_ITER, INDEX_DEVICE, INDEX_MODEL,
				INDEX_OUTPUT, TOTAL_ARGS};

Arg_Spec args[TOTAL_ARGS];
int args_count = TOTAL_ARGS;

struct argp_option options[] = {
//  {"arg_name",INDEX_ARG,		TYPE_ARG,	0, "a short explain",				appear_in_log_filename}
	{"size",	INDEX_SIZE,		ARG_SIZE,	0, "The size of a write",			AO_MANDATORY|AO_APPEAR}, 
	{"obj",		INDEX_OBJ,		ARG_SIZE,	0, "The object size",				AO_MANDATORY|AO_APPEAR},
	{"iter",	INDEX_ITER,		ARG_INT,	0, "Total number of iterations",	AO_MANDATORY|AO_APPEAR},
	{"device",	INDEX_DEVICE,	ARG_STR,	0, "Device path",					AO_MANDATORY|AO_MULTIPLE},
	{"model", 	INDEX_MODEL,	ARG_STR,	0, "Device model",					AO_ALTERNATE|INDEX_DEVICE},
	{"output",	INDEX_OUTPUT,	ARG_STR,	0, "Output file path (optional)",	AO_NULL},
	{0}
};

int main(int argc, char **argv) {
	
	char *exp_str = "singleCOW", *exp_str_full = "singleCOW";

	char ** dev_list;
	int dev_count;
	char * device;
	char ssd_model[256];
	int fd;
	long ssd_capacity;
	
	char log_path[256];
	char * log;
	FILE * log_file;
	
	IO_Spec io;
	long write_size = 0;
	long object_size;
	long num_iteration = 0;	
	long lat_write;
	long num_objects;

	long *obj_idx_list;
	
	double start_time;
	
	// parse the cmd line args
	if ((fd=args_parser(argc, argv, options)) != SUCCESS) {
		print_err(fd);
		exit(1);
	}
	
	// copy all the args
	write_size=args[INDEX_SIZE].v_size;	
	object_size=args[INDEX_OBJ].v_size;
	num_iteration=args[INDEX_ITER].v_int;
	dev_list=(char**)(args[INDEX_DEVICE].v_multi);
	log=args[INDEX_OUTPUT].v_str;		dev_count=args[INDEX_DEVICE].d_multi;
	
	for (int i = 0; i < dev_count; i++) {
	
		device = dev_list[i];
	
		// open the device
		if ((fd = open_device(device, O_DIRECT | O_WRONLY, ssd_model, &ssd_capacity )) <= FAILED) {
			print_err(DEVICE_ERROR);
			continue;
		}
		else {
			printf("Exp: %s\nDevice: %s\nModel: %s\nCapacity: %ld Bytes\n"
				, exp_str_full, device, ssd_model, ssd_capacity);
		}

		// create and open the log file
		if ((log_file = open_log_file(log_path, log, exp_str, ssd_model, ssd_capacity))==NULL) {
			print_err(FILE_HANDLING_ERROR);	close_device(fd);
			continue;
		}
		else {
			printf("Output: %s\n", log_path);
			fprintf(log_file, "\"size(B)\",\"offset(B)\",\"iteration\",\"time elapsed(s)\",\"write latency(ns)\"\n");
		}
		
		obj_idx_list = (long *)malloc(sizeof(long)*num_iteration);
		if (!obj_idx_list) {
			print_err(MEMORY_ERROR);	close_device(fd); close_log_file(log_file);
			continue;
		}
		srand(time(NULL));
		num_objects = (ssd_capacity / object_size)-1;
		if (num_iteration >= num_objects) {
			num_iteration = num_objects-1;
		}
		{
			long in, im;
			long M = num_iteration;
			long N = num_objects;

			im = 0;

			for (in = 0; in < N && im < M; ++in) {
			  int rn = N - in;
			  int rm = M - im;
			  if (rand() % rn < rm)    
			    /* Take it */
			    obj_idx_list[im++] = in + 1; /* +1 since your range begins from 1 */
			}

			assert(im == M);
		}

		// for (long j=0; j<num_iteration; j++) {
		// 	printf("%ld ", obj_idx_list[j]);
		// }

		io.type = IO_WRITE;
		io.fd = fd;
		if (posix_memalign(&(io.buff), ONE_KiB, write_size)!=0) {
			print_err(MEMORY_ERROR);	close_device(fd); close_log_file(log_file);
			continue;
		}
		
		io.size = write_size;
		start_time = -1;
		
		for (long iter = 0; iter < num_iteration; iter += 1) {
			
			printf("                                      \r");
			printf("Progress: Iterations(%ld/%ld)\r", iter+1, num_iteration);
			fflush(stdout);
			
			io.offset = obj_idx_list[iter] * object_size;

			lat_write = perform_io_2g(&io);
			if (start_time < 0) {
				start_time = io.t_start;
			}
			
			fprintf(log_file, "%ld,%ld,%ld,%f,%ld\n", io.size, io.offset, iter, io.t_start-start_time, lat_write);
		}
		
		free(io.buff);
		close_log_file(log_file);
		close_device(fd);
		
		printf("\n%s done\n\n", device);
	}
	
	printf("All done\n");
	
	return 0;
}
