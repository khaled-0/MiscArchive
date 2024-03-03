#include <iomanip>
#include <iostream>
#include <limits>

using namespace std;
void showMenu();

inline bool theyAreSame(string x, string y, string z) {
    return (x == y && y == z);
}

const int row = 3, col = 3;
string gameBoard[row][col];
int turnCount = 0;

// Color taken from:  https://stackoverflow.com/a/45300654/16867144
const string X = "\033[1;31;49mX\033[0m";
const string O = "\033[1;32;49mO\033[0m";

// Clears the console (in linux/win11??)
// https://stackoverflow.com/a/43884673/16867144
void clearConsole() {
    cout << "\033c" << endl;
    // this code runs only when compiled in binbows
#if _WIN32
    system("cls");
#endif
}

void printCurrentGameState() {
    cout << setw(15) << " " << gameBoard[0][0] << " | " << gameBoard[0][1] << " | " << gameBoard[0][2] << endl;
    cout << setw(25) << "-----------" << endl;
    cout << setw(15) << " " << gameBoard[1][0] << " | " << gameBoard[1][1] << " | " << gameBoard[1][2] << endl;
    cout << setw(25) << "-----------" << endl;
    cout << setw(15) << " " << gameBoard[2][0] << " | " << gameBoard[2][1] << " | " << gameBoard[2][2] << endl;
    cout << endl;
}

void takeGameInput() {
    cout << "Please give input (Range: 1 to 9), Player "
         << (turnCount % 2 == 0 ? X : O)
         << ": ";

    int input;
    cin >> input;

    if (cin.fail()) {
        cin.clear();
        cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        cout << "Invalid input. Try again." << endl;

        takeGameInput();
        return;
    }

    // thanks Abbasy. Very cool big brain math
    int row = ((input - 1) / 3);
    int column = ((input - 1) % 3);

    if (input < 1 || input > 9 || gameBoard[row][column] == X || gameBoard[row][column] == O) {
        cout << input << " is an invalid move. Please Try again." << endl;
        takeGameInput();
        return;
    }

    gameBoard[row][column] = (turnCount % 2 == 0 ? X : O);
    turnCount++;
}

string getWinPlayer() {
    // Minimum 5 turn required for winning
    if (turnCount < 5) return "";

    // Horizontal checks
    if (theyAreSame(gameBoard[0][0], gameBoard[0][1], gameBoard[0][2]))
        return gameBoard[0][0];

    if (theyAreSame(gameBoard[1][0], gameBoard[1][1], gameBoard[1][2]))
        return gameBoard[1][0];

    if (theyAreSame(gameBoard[2][0], gameBoard[2][1], gameBoard[2][2]))
        return gameBoard[2][0];

    // Vertical checks
    if (theyAreSame(gameBoard[0][0], gameBoard[1][0], gameBoard[2][0]))
        return gameBoard[0][0];

    if (theyAreSame(gameBoard[0][1], gameBoard[1][1], gameBoard[2][1]))
        return gameBoard[0][1];

    if (theyAreSame(gameBoard[0][2], gameBoard[1][2], gameBoard[2][2]))
        return gameBoard[0][2];

    // Corner checks
    if (theyAreSame(gameBoard[0][0], gameBoard[1][1], gameBoard[2][2]))
        return gameBoard[0][0];

    if (theyAreSame(gameBoard[0][2], gameBoard[1][1], gameBoard[2][0]))
        return gameBoard[0][2];

    // Still has input left
    // Just use "auto" https://stackoverflow.com/a/16509095/16867144
    for (auto& arr : gameBoard) {
        for (string val : arr) {
            if (val != X && val != O) return "";
        }
    }

    return "Nobody";  // Draw
}

void setupGameBoard() {
    turnCount = 0;
    int n = 1;
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < col; j++) {
            gameBoard[i][j] = to_string(n);
            n++;
        }
    }
}

void printTitle() {
    cout << endl
         << setw(35)
         << "<<Imagine Game Title Here :3>>"
         << endl
         << endl;
}

void startGameplayLoop() {
    setupGameBoard();

    do {
        clearConsole();
        printTitle();
        printCurrentGameState();
        takeGameInput();
    } while (getWinPlayer() == "");

    clearConsole();
    printTitle();
    printCurrentGameState();
    cout
        << endl
        << setw(32)
        << getWinPlayer() << " Won" << endl
        << endl;

    cin.clear();
    cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    showMenu();
}

void showMenu() {
    cout << "Hit Enter to start | q: Quit" << endl;

    switch (cin.get()) {
        case 'q':
        case 'Q':
            cout << "Bye!" << endl;
            return;

        default:
            startGameplayLoop();
    }
}

int main() {
    printTitle();
    showMenu();
    return 0;
}