#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h> // adding this for nanosleep system call
#include <errno.h>
// Optional: use these functions to add debug or error prints to your application
//#define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    // cast the void * parameter to its proper thread_data * type
    DEBUG_LOG("ABOUT TO CAST THE thread_param TO A thread_data STRUCTURE");
    struct thread_data * func_args = (struct thread_data *) thread_param;
    if (func_args == NULL) {
        perror("The cast of the parameter from void * to thread_data * failed.\n");
        return thread_param;
    }
    // set up the waiting periods
    printf("Pre-span milliseconds: %d \n", func_args->wait_to_obtain_ms);
    printf("Post-span milliseconds: %d \n\n", func_args->wait_to_release_ms);
    // Wait for the proper time
    if (usleep(func_args->wait_to_obtain_ms*1000) == -1) {
        DEBUG_LOG("USLEEP MESSED UP IN PRE SPAN");
        return thread_param;
    }
   
    // Get the mutex
    DEBUG_LOG("ABOUT TO LOCK THE MUTECKS");
    int arcc = pthread_mutex_lock(func_args->mutex);
    if (arcc != 0 ) {
        DEBUG_LOG("FAILED TO LOCK THE MOOTEX");
        return thread_param;
    }

    // Wait for the proper time
    if (usleep(func_args->wait_to_release_ms*1000) == -1) {
        DEBUG_LOG("USLEEP MESSED UP IN POST SPAN");
        return thread_param;
    }

    // Release the mutex
    DEBUG_LOG("ABOUT TO UNLOCK THE MYOOTECKS");
    arcc = pthread_mutex_unlock(func_args->mutex);
    if (arcc != 0) {
        DEBUG_LOG("FAILED TO UNLOCK THE MYOOTEX");
        return thread_param;
    }

    DEBUG_LOG("IT SEEMS TO HAVE WORKED, BUT DID IT??");
    func_args->thread_complete_success = true;
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    // Create the thread_data payload for the new thread
    struct thread_data* payload = malloc(sizeof (struct thread_data));
    if (payload == NULL) {
        perror("Malloc for thread_data structure failed\n");
        return false;
    }

    // we don't do the waiting in this function. it happens in the spawned function
    // but we must initialize the thread_data object 
    payload->wait_to_obtain_ms = wait_to_obtain_ms;
    payload->wait_to_release_ms = wait_to_release_ms;
    payload->thread_complete_success = false;
    payload->mutex = mutex;

    int new_thread = pthread_create(thread, NULL, threadfunc, (void*) payload);
    if (new_thread != 0) {
        perror("The pthread was not created.\n");
        printf("Error reported: %d\n", errno);
        free(payload); 
        return false;
    } 
    return true;
}
