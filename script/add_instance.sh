#!/bin/bash
BASEDIR=$(cd "$(dirname "$0")"; pwd)/..

source ./io.sh
source ./plugins.sh
source ./bundles.sh
source ./credentials.sh

IFS=""

liferay_path=$BASEDIR/images/liferay/
database_path=$BASEDIR/images/database
instance_path=$BASEDIR/instances
backups_folder=$BASEDIR/backups

download_base_url="https://web.liferay.com/group/customer/downloads?p_p_id=3_WAR_osbportlet&p_p_lifecycle=1&p_p_state=maximized&_3_WAR_osbportlet_fileName="

instance=
version=
service_pack=
fix_pack=
database=
backup=

userInput "Select a name for the new instance: "  instance

instance_path=$instance_path/$instance

if [ -d "$instance_path" ]; then
    
    printAction "The instance $instance already exists"
    userInput "Do you want to override the current instance (y/n) " override
    
    if [ "$addPlugins" == "n" ];then    
        exit
    fi

    rm -r $instance_path
fi

#Bundle
printMenuAndInput "Available bundles" `getBundles` "Select the bundle to use: "  versionIndex
versionIndex=$((versionIndex-1))
version=`getBundleName $versionIndex`

#Service Pack
printMenuAndInput "Available service packs" `getServicePacks $versionIndex` "Select the service pack to use: "  servicePackIndex
servicePackIndex=$((servicePackIndex-1))
service_pack=`getServicePackName $versionIndex $servicePackIndex`

#Fix Pack
printMenuAndInput "Available fix packs" `getFixPacks $versionIndex $servicePackIndex` "Select the fix pack to use: "  fixPackIndex
fixPackIndex=$((fixPackIndex-1))
fix_pack=`getFixPackName $versionIndex $servicePackIndex $fixPackIndex`

if [ ! -d "$liferay_path/bundles/$version/$service_pack/$fix_pack" ]; then
    mkdir -p $liferay_path/bundles/$version/$service_pack/$fix_pack
    bundleUrl=`./jq-osx-amd64 -r .bundles[$versionIndex].servicepack[$servicePackIndex].fixpack[$fixPackIndex].url ./bundles.json`
    printAction "Downloading bundle from $bundleUrl"
    curl -X POST -u $credentials "$download_base_url$bundleUrl" -D ./headers.txt
    url=($(cat ./headers.txt | grep Location: | cut -d ':' -f3))
    rm ./headers.txt
    curl -o "$liferay_path/bundles/$version/$service_pack/$fix_pack/bundle.zip" "http:${url%$'\r'}"
fi

#Summary
printAction "Selected bundle $version - $service_pack - $fix_pack"

mkdir -p $instance_path/{sql_files,portal_files/{libs,data,deploy,config}}

loadPlugins $liferay_path $version $instance_path

printMenu "Available database engines" `ls -d $database_path/* | rev | cut -f1 -d '/' | rev` 
read -p "Select the database to use: "  database

printMenu "Available backups" `ls -d $backups_folder/* | rev | cut -f1 -d '/' | rev`
read -p "Select the backup to use: "  backup

cp 	$BASEDIR/docker-compose.template $instance_path/docker-compose.template 
cp 	$database_path/sql/create_schema.sql $instance_path/sql_files/create-schema.sql 
cp  $liferay_path/config/portal-setup-wizard.properties $instance_path/portal_files/config/portal-setup-wizard.properties

case $database in
	mysql )
		sed -e "s/\${liferay_version}/$version/" -e "s/\${liferay_sp}/$service_pack/" -e "s/\${instance}/$instance/" -e "s/\${liferay_fp}/$fix_pack/" $BASEDIR/docker-mysql-compose.template > $instance_path/docker-compose.yml 
		cp $database_path/mysql/drivers/mysql.jar                      $instance_path/portal_files/libs/
        cp $database_path/mysql/config/portal-setup-wizard.properties  $instance_path/portal_files/config/portal-setup-wizard.properties
		;;
	* )
		sed -e "s/\${liferay_version}/$version/" -e "s/\${liferay_sp}/$service_pack/" -e "s/\${instance}/$instance/" -e "s/\${liferay_fp}/$fix_pack/" $BASEDIR/docker-compose.template > $instance_path/docker-compose.yml 
		# At least one jar needs to be present, if not built will fails as docker doen't allow conditional buildings
		cp $BASEDIR/images/aux/empty.jar $instance_path/portal_files/libs/
		;;
esac

if [ ! -z "$backup" ] ; then
    cp -r   $backups_folder/$backup/data/*           $instance_path/portal_files/data
    cp      $backups_folder/$backup/sql/*            $instance_path/sql_files/
    cp      $backups_folder/$backup/portal_config/*  $instance_path/portal_files/config/
fi

echo $instance " " $version " " $service_pack " " $fix_pack " has been created"

echo "Building docker images"

docker-compose -f $instance_path/docker-compose.yml up -d
