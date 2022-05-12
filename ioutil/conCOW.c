
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include "ioutil.h"

enum Arg_Index {INDEX_SIZE, INDEX_OBJ, 
				INDEX_JOBS, INDEX_ITER, INDEX_DEVICE, INDEX_MODEL,
				INDEX_OUTPUT, TOTAL_ARGS};

Arg_Spec args[TOTAL_ARGS];
int args_count = TOTAL_ARGS;

struct argp_option options[] = {
//  {"arg_name",INDEX_ARG,		TYPE_ARG,	0, "a short explain",				appear_in_log_filename}
	{"size",	INDEX_SIZE,		ARG_SIZE,	0, "The size of a write",			AO_MANDATORY|AO_APPEAR}, 
	{"obj",		INDEX_OBJ,		ARG_SIZE,	0, "The object size",				AO_MANDATORY|AO_APPEAR},
	{"jobs", 	INDEX_JOBS, 	ARG_INT, 	0, "The number of concurrent jobs", AO_MANDATORY|AO_APPEAR},
	{"iter",	INDEX_ITER,		ARG_INT,	0, "Total number of iterations",	AO_MANDATORY|AO_APPEAR},
	{"device",	INDEX_DEVICE,	ARG_STR,	0, "Device path",					AO_MANDATORY|AO_MULTIPLE},
	{"model", 	INDEX_MODEL,	ARG_STR,	0, "Device model",					AO_ALTERNATE|INDEX_DEVICE},
	{"output",	INDEX_OUTPUT,	ARG_STR,	0, "Output file path (optional)",	AO_NULL},
	{0}
};

int main(int argc, char **argv) {
	
	char *exp_str = "conCOW", *exp_str_full = "concurrentCOW";

	char ** dev_list;
	int dev_count;
	char * device;
	char ssd_model[256];
	int fd;
	long ssd_capacity;
	
	char log_path[256];
	char * log;
	FILE * log_file;
	
	IO_Spec * io_list;
	long write_size = 0;
	long object_size;
	long num_jobs;
	long lat_write;
	long num_iteration = 0;	
	long num_objects;
	
	long *obj_idx_list;

	int first;
	double start_time;
	
	// parse the cmd line args
	if ((fd=args_parser(argc, argv, options)) != SUCCESS) {
		print_err(fd);
		exit(1);
	}
	
	// copy all the args
	write_size=args[INDEX_SIZE].v_size;	
	object_size=args[INDEX_OBJ].v_size;
	num_jobs=args[INDEX_JOBS].v_int;
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
			fprintf(log_file, "\"size(B)\",\"offset(B)\",\"iter\",\"time elapsed(s)\",\"write latency(ns)\"\n");
		}
		
		srand(time(NULL));
		num_objects = ssd_capacity / object_size;
		if (num_iteration*num_jobs >= num_objects) {
			num_iteration = num_objects/num_jobs - 1;
		}
		obj_idx_list = (long *)malloc(sizeof(long)*num_iteration*num_jobs);
		if (!obj_idx_list) {
			print_err(MEMORY_ERROR);	close_device(fd); close_log_file(log_file);
			continue;
		}
		{
			long in, im;
			long M = num_iteration*num_jobs;
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
		// shuffle the array
		for (int j=0; j<num_iteration*num_jobs; j++) {
			int swap_to = rand()%(num_iteration*num_jobs);
			long tmp;
			tmp = obj_idx_list[j];
			obj_idx_list[j] = obj_idx_list[swap_to];
			obj_idx_list[swap_to] = tmp;
		}

		// initialize IO jobs
		if ((io_list=(IO_Spec *)malloc(num_jobs*sizeof(IO_Spec)))==NULL) {
			print_err(MEMORY_ERROR);
			continue;
		}
		for (int j=0; j<num_jobs; j++) {
			io_list[j].type = IO_WRITE;
			io_list[j].size = write_size;
			io_list[j].fd = fd;
			if (posix_memalign(&(io_list[j].buff), ONE_KiB, write_size)!=0) {
				print_err(MEMORY_ERROR);
				continue;
			}
		}
		if (io_container_create(io_list, num_jobs)<=FAILED) {
			print_err(FAILED);
			continue;
		}
		
		first = TRUE;
		start_time = -1;
		
		for (long iter = 0; iter < num_iteration; iter += 1) {
			
			printf("                                      \r");
			printf("Progress: Iterations(%ld/%ld)\r", iter+1, num_iteration);
			fflush(stdout);
			
			for (long j=0; j<num_jobs; j++) {
				io_list[j].offset = obj_idx_list[iter*num_jobs+j] * object_size;
			}
				
			io_container_run();
			if (first) {
				start_time = get_min_t_start(io_list, num_jobs);
				first = FALSE;
			}
			
			latency_sort(io_list, num_jobs);
			for (int j=0; j<num_jobs; j++) {
				fprintf(log_file, "%ld,%ld,%ld,%f,%ld\n", io_list[j].size, io_list[j].offset, iter, io_list[j].t_start-start_time, io_list[j].latency);
			}
		}
		
		io_container_destroy();
		for (int j=0; j<num_jobs; j++) {
			free(io_list[j].buff);
		}
		close_log_file(log_file);
		close_device(fd);
		
		printf("\n%s done\n\n", device);
	}
	
	printf("All done\n");
	
	return 0;
}