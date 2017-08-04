curl -X POST -u guillermo.gutierrez@liferay.com:liferayO2495BU "https://web.liferay.com/group/customer/downloads?p_p_id=3_WAR_osbportlet&p_p_lifecycle=1&p_p_state=maximized&_3_WAR_osbportlet_fileName=/portal/6.2.10.19/liferay-portal-tomcat-6.2-ee-sp18-20170306151705459.zip" -D ./text.txt
url=($(cat text.txt | grep Location: | cut -d ':' -f3))
url=${url%$'\r'}
rm ./text.txt
curl -o "./bundle.zip" "http:$url"