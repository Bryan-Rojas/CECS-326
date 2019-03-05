#include <iostream>
#include <string>
#include <unistd.h>
#include <sys/wait.h>

using namespace std;

int main(){
    pid_t pid;
    pid = fork();
    
    if( pid < 0 ){
        cout << "ERROR: Fork failed!\n";
        exit( 1 );    // abort!
    }
    else if( pid == 0 ){    // true inside child
        /*******************************
        Child2
        ******************************/
        pid_t pid1;
        pid1 = fork();

        if( pid1 < 0 ){
            cout << "ERROR: Fork failed!\n";
            exit( 1 );    // abort!
        }
        else if( pid1 == 0 ){    // true inside child
            cout << "CHILD1: about to fork and show a long list of directory contents:\n";
            if( execlp( "ls", "ls", "-l", NULL) == -1 ){
                cout << "ERROR: exec failed can't show directory contents!\n";
            }
            exit( 1 );
        }
        else{    // positive pid means parent
            wait( &pid1 );    // only wait if pd > 0 i.e. inside parent
        }

        /*******************************
        Child3
        ******************************/
        pid_t pid2;
        pid2 = fork();

        if( pid2 < 0 ){
            cout << "ERROR: Fork failed!\n";
            exit( 1 );    // abort!
        }
        else if( pid2 == 0 ){    // true inside child
            cout << "\nCHILD1: about to fork and show hello.cpp contents:\n";
            if( execlp( "more", "more", "hello.cpp", NULL) == -1 ){
                cout << "ERROR: exec failed hello.cpp doesn't exist!\n";
            }
            exit( 1 );
        }
        else{    // positive pid means parent
            wait( &pid2 );    // only wait if pd > 0 i.e. inside parent
        }

        /*******************************
        Child4
        ******************************/
        pid_t pid3;
        pid3 = fork();

        if( pid3 < 0 ){
            cout << "ERROR: Fork failed!\n";
            exit( 1 );    // abort!
        }
        else if( pid3 == 0 ){    // true inside child
            cout << "\nCHILD1: about to fork and compile hello.cpp\n";
            if( execlp( "g++", "g++", "hello.cpp", "-o", "hello.out", NULL) == -1 ){
                cout << "ERROR: exec failed can't compile hello.cpp!\n";
            }
            exit( 1 );
        }
        else{    // positive pid means parent
            wait( &pid3 );    // only wait if pd > 0 i.e. inside parent
        }

         /*******************************
        Child1
        ******************************/
        cout << "\nCHILD1: doing ./hello.out 2\n";
        if( execlp( "./hello.out", "./hello.out", "2", NULL) == -1 ){
                cout << "ERROR: exec failed no ./hello.out file exists!\n";
                exit( 1 );
        }

    }
    else{    // positive pid means parent
        cout << "\nPARENT: Waiting for CHILD1 to exit...\n\n";
        wait( &pid );    // only wait if pd > 0 i.e. inside parent
        cout << "\nPARENT: CHILD1 finally exited\n";
    }
    exit( 0 );
}
