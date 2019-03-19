#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/types.h>
#include <time.h>
#include <iostream>

using namespace std;

int main(){
    const int SIZE = 128;
    const char * name = "Challenge";// name of shared memory region
    int shm_fd;//file descriptor variable
    void *ptr;//shared memory pointer
    shm_fd = shm_open(name, O_CREAT | O_RDWR, 0666);
    shm_fd = shm_open(name, O_RDWR, 0666);
    ftruncate(shm_fd, SIZE); // create, truncate shared memory region
    ptr = mmap(0, SIZE, PROT_WRITE | PROT_READ, MAP_SHARED, shm_fd, 0);	// point to shared memory region
    short newValue = 0;
    short value = 0;
    bool first = true;

    if(shm_fd == -1){
        cout << "2: ERROR: Opening shared memory failed\n";
        exit(-1);
    }

    if(ptr == MAP_FAILED){
        cout << "2: ERROR: Map failed\n";
        exit(-1);
    }

    do{
        bool oldData = true;
        while( oldData ){
            newValue = *((short *)ptr);
            if( newValue != value )
                oldData = false;
        }	// end of while( oldData )
        value = newValue;
        
        if(first){
            cout << "2: FIRST Value Received: " << value << endl;
            first = false;
        }
        else{
            cout << "2: Value Recevied: " << value << endl;
        }

        if(value == 1 || value == 2){
            *((short *)ptr) = value;
            break;
        }
        if(value % 2 == 0){
            value /= 2;
            *((short *)ptr) = value;
        }
        else{
            value = 3 * value + 1;
            *((short *)ptr) = value;
        }
        cout << "2: Value to write into shared memory: " << value << endl;
        cout << "2: Awaiting new data in shared memory region" << endl;
    }while( value != 1 || value != 2 );

    if(newValue == 1){
        cout << "2: I lose?" << endl;
    }
    else{
        cout << "2: I WIN!" << endl;
    }

    cout << "2: Attempting to close shared memory region" << endl;
    if(shm_unlink(name) == -1 && newValue != 1){
        cout << "2: ERROR: Error removing shared memory region: " << name << endl;
        exit(-1);
    }

    cout << "2: Successfully closed shared memory region" << endl;
    return 0;

}