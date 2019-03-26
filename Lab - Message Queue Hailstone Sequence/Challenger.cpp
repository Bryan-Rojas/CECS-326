#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <cstring>
#include <iostream>
#include <unistd.h>
#include <sys/wait.h>
#include <cstdlib>

using namespace std;

int main() {

	int qid = msgget(
	        ftok(".",'u'), 
	        IPC_EXCL | IPC_CREAT | 0600
	        );

    if( qid < 0 ){
		cout << "Challenger, Q create FAILED!" << endl;
        qid = msgget(
			ftok(".",'u'), 
			IPC_EXCL | 0600
			);
		if(qid < 0){
            cout << "Challenger, Q access FAILED!" << endl;
		}
		else{
            cout << "Challenger, Q access SUCCESS!" << endl;
		}
	}
	else{
		cout << "Challenger, Q create SUCCESS!" << endl;
	}

	struct buf {
		long mtype;
		char g[5];
	};

	buf msg;
	msg.mtype = 0;
	int size = sizeof(msg)-sizeof(long);
	
	do{
		if(msg.mtype % 2 == 1){
	   		msg.mtype = (3 * msg.mtype) + 1;
		}
		else{
	    		msg.mtype = msg.mtype / 2;
		}

        cout << "Challenger, Checking queue..." << endl;
        msgrcv( qid, (struct msgbuf *)&msg, size, msg.mtype, msg.mtype );
        cout << "Challenger, Recevied: " << msg.mtype << endl;
        
		if(msg.mtype == 1){
	    		break;
		}

		if(msg.mtype % 2 == 1){
			msg.mtype = (3 * msg.mtype) + 1;
		}
		else{
			msg.mtype = msg.mtype / 2;
		}

		if(msgsnd( qid, (struct msgbuf *)&msg, size, msg.mtype) < 0){
			cout << "Challenger, sending FAILED!" << endl;
		} 
		else{
			cout << "Challenger, Sending: " << msg.mtype << endl;
		}
	}while(msg.mtype != 1);

	cout << "Challenger, Removing Q" << endl;

	if( msgctl (qid, IPC_RMID, NULL) ){
		cout << "Challenger, Q removal FAILED!" << endl;
    	}
    else{
        cout << "Challenger, Q removal SUCCESS!" << endl;
    }

	exit(0);
}