function parseJson {
	./jq-osx-amd64 -r $1 ./bundles.json | while ((index++)); read x; do echo $index. $x; done
}

function parseJsonValue {
	./jq-osx-amd64 -r $1 ./bundles.json
}

function getBundles {
	parseJson .bundles[].name
}

function getBundleName {
	parseJsonValue .bundles[$1].name
}

function getServicePacks {
	parseJson .bundles[$1].servicepack[].name
}

function getServicePackName {
	parseJsonValue .bundles[$1].servicepack[$2].name
}

#function getFixPacks {
#	parseJson .bundles[$1].servicepack[$2].fixpack[].name
#}

#function getFixPackName {
#	parseJsonValue .bundles[$1].servicepack[$2].fixpack[$3].name
#}
