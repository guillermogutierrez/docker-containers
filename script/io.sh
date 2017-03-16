function printMenu {
    printf "\n$1\n"
    printf "==================================\n"
    echo $2
    #printf "..................................\n"
    #userInput $3 $4
}

function printMenuAndInput {
    printf "\n$1\n"
    printf "==================================\n"
    echo $2
    printf "..................................\n"
    userInput $3 $4
}

function printAction {
    printf "\n=================================="
    printf "\n$1\n"
    printf "==================================\n"
}

function userInput {
    read -p "$1" $2
    printf "==================================\n"
}
