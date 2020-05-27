#!/bin/bash
echo "----------------Starting the process of OS hardening and docker security----------------"


echo "--------------------######### Step 1: Update system ##########----------------------"
yum update


echo "--------------------######### Step 2: install docker ###########--------------------"
#yum install -y docker
#sudo systemctl start docker


echo "--------------------######### Step 3: install openscap scanner ########### ---------"
yum install -y openscap-scanner


echo "--------------------######### Step 4: install unzip ###########---------------------"
yum install -y unzip


echo "--------------------######### Step 5: Download docker security scanner ###########--"
if [ -e docker-security.zip ]; 
then
    echo "$FILE already exist, not downloading";
else
    echo "Downloading docker security scanner file started" 
    wget http://13.71.87.138:8040/artifactory/libs-release-local/io/mosip/testing/OS-hardening/docker-security.zip";
fi


echo "--------------------######### Step 6: Unzip docker security scanner ###########------"
if [ -d scap-security-guide ] ;
then
    echo "$FILE already exist, not performing unzip";
else
    echo "Unzip Unzip docker security scanner started"
    unzip docker-security.zip ;
fi


echo "--------------------######### Step 7: Changing Permission of the file ###########----"
sudo chmod +x oscap-docker


echo "--------------------######### Step 8: Create Host Report folder ###########----"
if [ -d ./OS_Reports ] ;
then
    echo "folder exist already exist, not creating";
else
    echo "creating report folder"
    sudo mkdir ./OS_Reports;
fi


echo "--------------------######### Step 9: Starting Host OS scanning ############---------"
oscap xccdf eval --report ./OS_Reports/Host-System_report.html --results ./OS_Reports/Host-System_result.xml  --profile PROFILE_ID --fetch-remote-resources DATASTREAM 


echo "--------------------######### Step 10: Starting Host OS Remediation ############------"
oscap xccdf eval --remediate --results ./OS_Result/Host-System_remediate_result.xml --profile PROFILE_ID --fetch-remote-resources DATASTREAM ./OS_Result/Host-System_result.xml


echo "--------------------######### Step 11: Create Images/Container Report folder ###########"
if [ -d ./OS_Reports ] ;
then
    echo "folder exist already exist, not creating";
else
    echo "creating report folder"
    sudo mkdir ./Reports;
fi


echo "--------------------######### Step 12: Creating list of docker images ###########----"
docker system prune -f
#docker images | cut -d " " -f 1 > Image_list.txt
docker images | cut -d " " -f 1 | grep mosipid > Image_list.txt


echo "--------------------######### Step 13: Starting scanning of docker images ###########-"
for image in $(cat Image_list.txt);
do
echo "--*********Scanning docker images: "$image" ***********--"
./oscap-docker image $image xccdf eval --report ./Reports/$image.html --profile PROFILE_ID --fetch-remote-resources DATASTREAM &
BACK_PID=$!
wait $BACK_PID
done


echo "--------------------######### Step 14:Creating list of containers ###########--------"
docker system prune -f
#docker ps -a | grep <docker hub id if any> | awk '{print $2}' > Container_list.txt
docker ps -a | cut -d " " -f 1 > Container_list.txt


echo "--------------------######### Step 15: Starting scanning of containers ###########---"
for container in $(cat Container_list.txt);
do
echo "--*********Scanning container: "$container" ***********--"
./oscap-docker container $container xccdf eval --report ./Reports/$container.html --results ./Reports/$container.xml --profile PROFILE_ID --fetch-remote-resources DATASTREAM &
BACK_PID=$!
wait $BACK_PID
done


echo "--------------------######### Step 16: Starting remediation of containers ###########---"
for container in $(cat Container_list.txt);
do
echo "--*********remediating container: "$container" ***********--"
./oscap-docker container $container xccdf eval --remediate --report ./Reports/$container.html  --profile PROFILE_ID --fetch-remote-resources DATASTREAM ./Reports/$container.xml &
BACK_PID=$!
wait $BACK_PID
done


echo "*******---------######### Step 17: You are now compliance to standarads of CentOS ###########-------***********"
