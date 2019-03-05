#include <sys/types.h>
#include <iostream>
#include <cstring>
#include <unistd.h>

using namespace std;

int main(){
	string write_msg, msg_read;
	const short MSG_SIZE = 25;
	char msg_write[ MSG_SIZE ];
	char read_msg[ MSG_SIZE ];
	int fd[2];
	string pemdas[3];
	pid_t pid;
	pipe( fd );
	pid = fork();
	bool done = false;

	if( pid > 0 ){	// in parent	// close unused Read End
		close(fd[0]);
		for(int i = 0; i < 3; i++){
			cout << "PARENT: Enter a message to send: ";
			cin >> write_msg;
			cout << "PARENT, sending: " << write_msg << endl;
			unsigned int size = write_msg.length();
			write_msg.copy( msg_write, write_msg.length(), 0 );
			write( fd[1], msg_write, MSG_SIZE );
			for( int l = 0; l < MSG_SIZE; l++ ){
				msg_write[ l ] = '\0';	// overwrite the message local array
			//write( fd[1], msg_write, MSG_SIZE );	// overwrite the shared memory area
			}


		}
		close(fd[1]);
	}
	else{
		close(fd[1]);
		for(int j = 0; j < 3; j++){
			
			read( fd[0], read_msg, MSG_SIZE );
			msg_read = read_msg;
			pemdas[j] = msg_read;
			
			if(j==0){
				if ( stoi(msg_read) > 99 || stoi(msg_read) < 0 ){
					cout << "Error: Must be between 0 and 99";
					close(fd[0]);
					exit(0);
				}
				cout << "CHILD: value A = " << stoi(msg_read) << endl;
			}
			else if(j==1){
				if( msg_read != "+" && msg_read != "-"){
					cout << "Error: Must be '+' or '-'" << endl;
					close(fd[0]);
					exit(0);
				}
				else{
					if( msg_read == "+"){
						cout << "CHILD: operation addition" << endl;
					}
					else{
						cout << "CHILD: operation subtraction" << endl;
					}
				}
			}
			else if(j==2){
				cout << "CHILD: value B = " << stoi(msg_read) << endl;
				if ( stoi(msg_read) > 99 || stoi(msg_read) < 0){
					cout << "Error: Must be between 0 and 99";
					close(fd[0]);
					exit(0);
				}
				
			}
		}

		if(pemdas[1] == "+"){
			cout << pemdas[0] << " + " << pemdas[2] << " = " << stoi(pemdas[0]) + stoi(pemdas[2]) << endl;
		}
		else if(pemdas[1] == "-"){
			cout << pemdas[0] << " - " << pemdas[2] << " = " << stoi(pemdas[0]) - stoi(pemdas[2]) << endl;
		}

		// all done, close the pipe!
		cout << "Child exiting!" << endl;
		done = true;
		exit(0);
	}
	if(done){
	close( fd[0] );	
	close( fd[1] );
	cout << "PARENT: exiting!" << endl;
		exit(0);
	}
}
