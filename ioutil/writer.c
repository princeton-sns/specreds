
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include "ioutil.h"

enum Arg_Index {INDEX_OMAP, INDEX_OBJ,
				INDEX_DEVICE, INDEX_MODEL,
				TOTAL_ARGS};

Arg_Spec args[TOTAL_ARGS];
int args_count = TOTAL_ARGS;

struct argp_option options[] = {
//  {"arg_name",INDEX_ARG,		TYPE_ARG,	0, "a short explain",				appear_in_log_filename}
	{"omap",	INDEX_OMAP,		ARG_STR,	0, "The input omap file path",		AO_MANDATORY}, 
	{"obj",		INDEX_OBJ,		ARG_SIZE,	0, "The object size",				AO_MANDATORY|AO_APPEAR},
	{"device",	INDEX_DEVICE,	ARG_STR,	0, "Device path",					AO_MANDATORY|AO_MULTIPLE},
	{"model", 	INDEX_MODEL,	ARG_STR,	0, "Device model",					AO_ALTERNATE|INDEX_DEVICE},
	{0}
};

int main(int argc, char **argv) {
	
	char *exp_str = "writer", *exp_str_full = "writer";

	char ** dev_list;
	int dev_count;
	char * device;
	char ssd_model[256];
	int fd;
	long ssd_capacity;
	
	char * omap_path;
	FILE * omap_file;
	char * omap;
	long omap_size;
	long omap_idx;

	IO_Spec * io_list;
	long write_size = 4096;
	long object_size;
	long num_jobs = 4;
	long job_idx = 0;

	long *obj_idx_list;
	
	double start_time;
	
	// parse the cmd line args
	if ((fd=args_parser(argc, argv, options)) != SUCCESS) {
		print_err(fd);
		exit(1);
	}
	
	// copy all the args
	omap_path=args[INDEX_OMAP].v_str;
	object_size=args[INDEX_OBJ].v_size;
	dev_list=(char**)(args[INDEX_DEVICE].v_multi);
	dev_count=args[INDEX_DEVICE].d_multi;
	
    omap_file = fopen(omap_path, "r");
    if (NULL == omap_file) {
        print_err(FILE_HANDLING_ERROR);
        return -FILE_HANDLING_ERROR;
    }
    fseek(omap_file, 0L, SEEK_END);
	omap_size = ftell(omap_file);
	rewind(omap_file);

	omap = (char *)malloc(sizeof(char)*omap_size);
	if (!omap) {
		print_err(MEMORY_ERROR); 
		return -MEMORY_ERROR; 
	}

	omap_idx = 0;
	while (!feof(omap_file)) {
        omap[omap_idx] = fgetc(omap_file);
        omap_idx += 1;
    }
    fclose(omap_file);

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
		
		job_idx = 0;
		for (omap_idx = 0; omap_idx < omap_size; omap_idx += 1) {
			
			if (omap[omap_idx] == '1') {
				io_list[job_idx].offset = omap_idx*object_size + (object_size-write_size);
				job_idx += 1;
			}

			if (job_idx == num_jobs) {
				io_container_run();
				job_idx = 0;

				printf("                                      \r");
				printf("Progress: %ld%%\r", (omap_idx+1)*100/omap_size);
				fflush(stdout);
			} 
		}
		
		io_container_destroy();
		for (int j=0; j<num_jobs; j++) {
			free(io_list[j].buff);
		}
		close_device(fd);
		
		printf("\n%s done\n\n", device);
	}
	
	printf("All done\n");
	
	return 0;
}