#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <vector>

using namespace std;

int main(int argc, char ** argv){

    vector<int> numbers;
    double sum;
    double avg;
    int range;

    if(argc == 1){
        cout << "No arguments entered, I'm done" << endl;
        return 0;
    }

    if(argc <= 4){
        cout << "Please enter more than 3 numerical arguments" << endl;
        return 0;
    }

    if(argc > 10){
        cout << "Please enter less than 10 numerical arguments" << endl;
        return 0;
    }

    if(argc > 4 && argc < 11){

        for(int i = 1; i < argc; i++){
            int temp = atoi(argv[i]);
            if(temp <= -100 || temp >= 100){
                cout << "One of the arguments are out of range." << endl;
                return 0;
            }
            else{
                numbers.push_back(temp);
            }
        }

        for(int j = 0; j < numbers.size(); j++){
            cout << "numbersArray[ " << j << " ]" << " = " << numbers.at(j) << endl;
        }

        int low = numbers.at(0);
        int high = numbers.at(0);

        for(int k = 0; k < numbers.size(); k++){
            sum += numbers.at(k);
            if(numbers.at(k) < low){
                low = numbers.at(k);
            }
            if(numbers.at(k) > high){
                high = numbers.at(k);
            }
        }

        avg = sum/(numbers.size());
        range = high - low;

        cout << "The sum is " << sum << endl;
        cout << "The average is " << fixed << setprecision(1) << avg << endl;
        cout << "The range is " << range << endl;

    }

}