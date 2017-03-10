instance=

while [ "$1" != "" ]; do
    case $1 in
         -i | --instance )    	shift
								instance=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

docker-compose