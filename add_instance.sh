instance=
version=
service_pack=
fix_pack=
database=

while [ "$1" != "" ]; do
    case $1 in
        -v | --version )        shift
                                version=$1
                                ;;
        -i | --instance )    	shift
								instance=$1
                                ;;
        -s | --service_pack )    	shift
								service_pack=$1
                                ;;
        -f | --fix_pack )    	shift
								fix_pack=$1
                                ;;
		-d | --db )        		shift
                                database=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

mkdir -p ./instances/$instance/{sql_files,portal_files/{libs,data,deploy,config}}

cp 	./docker-compose.template ./instances/$instance/docker-compose.yml 
cp 	./images/aux/create-schema.sql ./instances/$instance/sql_files/ 

case $database in
	mysql )
		sed -e "s/\${liferay_version}/$version/" -e "s/\${liferay_sp}/$service_pack/" -e "s/\${instance}/$instance/" -e "s/\${liferay_fp}/$fix_pack/" ./docker-mysql-compose.template > ./instances/$instance/docker-compose.yml 
		cp ./images/mysql/drivers/mysql.jar ./instances/$instance/portal_files/libs/
		;;
	* )
		sed -e "s/\${liferay_version}/$version/" -e "s/\${liferay_sp}/$service_pack/" -e "s/\${instance}/$instance/" -e "s/\${liferay_fp}/$fix_pack/" ./docker-compose.template > ./instances/$instance/docker-compose.yml 
		# At least one jar needs to be present, if not built will fails as docker doen't allow conditional buildings
		cp ./images/aux/empty.jar ./instances/$instance/portal_files/libs/
		;;
esac

echo $instance " " $version " " $service_pack " " $fix_pack
