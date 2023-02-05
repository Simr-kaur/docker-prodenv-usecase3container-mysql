#!/bin/bash

clear
echo "-----------------------------------------------------------------------"
read -p "Enter the name of container, you want to run on mysql image:->" con
echo "-----------------------------------------------------------------------"
read -p "Enter the name of custom network you want to create" net
echo "-----------------------------------------------------------------------"
docker network create --driver bridge $net
echo "-----------------------------------------------------------------------"
echo "********************* $net, Network is created ************************"
echo "-----------------------------------------------------------------------"
read -p "Enter the name of volume you want to create, to attach container:->" vol
echo "------------------------------------------------------------------------"
echo "----------------------------$vol is created-----------------------------"
echo "------------------------------------------------------------------------"
docker container run -d --name $con -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v $vol:/usr/local/ --network $net mysql
echo "-------------------------------------------------------------------"
echo "************ $con, container is running successfully ***************"
echo "--------------------------------------------------------------------"
read -p "Enter the name of file 1 you need to create inside container,which is use for creating database:->" file1
echo "--------------------------------------------------------------------------------------------------------------------------"
read -p "Enter the name of file 2 you need to create inside container, which is used for changing the database to work:->" file2
echo "-------------------------------------------------------------------------------------------------------------------------"
read -p "Enter the name of file 3 you need to create inside container,which is used for creating table :->" file3
echo "-------------------------------------------------------------------------------------------------------------------------"
read -p "Enter the name of file 4 you need to create inside the container, for inserting values in table :->" file4
echo "-------------------------------------------------------------------------------------------------------------------------"
read -p "Enter the name of file 5 you need to create inside the container, for displaying table of database:->" file5
echo "-------------------------------------------------------------------------------------------------------------------------"
docker exec --user root $con touch /usr/local/$file1 
docker exec --user root $con touch /usr/local/$file2
docker exec --user root $con touch /usr/local/$file3
docker exec --user root $con touch /usr/local/$file4
docker exec --user root $con touch /usr/local/$file5
echo "--------------------------------------------------------------------------------------------"
echo "------$file1,$file2,$file3,$file4,$file5 -> 5files are created inside the container---------"
echo "--------------------------------------------------------------------------------------------",
docker exec -i $con bash -c "cat > /usr/local/$file1" << -EOF
CREATE DATABASE db; 
-EOF
docker exec -i $con bash -c "cat > /usr/local/$file2" << -EOF
use db
-EOF
docker exec -i $con bash -c "cat > /usr/local/$file3" << -EOF
CREATE TABLE student_info(s_id int, name varchar(20),phone int);
-EOF
docker exec -i $con bash -c "cat > /usr/local/$file4" << -EOF
INSERT INTO student_info (s_id,name,phone) Values (1,'Simran',987);
-EOF
docker exec -i $con bash -c "cat > /usr/local/$file5" << -EOF
select *from db.student_info;
-EOF
echo "-----------------------------------------------------------------------"
echo "************Content of files inserted in all five files****************"
echo "-----------------------------------------------------------------------"
read -p "Enter the name of 2nd container you want to run on Mysql image:->" con1
echo "---------------------------------------------------------------------------------------------------"
echo "**********************Going inside $con1, which is based on read only conatiner********************"
echo "---------------------------------------------------------------------------------------------------"
docker run -it --name $con1 --volume $vol:/usr/local/:ro --read-only --network $net -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql bin/bash
echo "------------------------------------------------------------------------------------------"
read -p "Enter the name of 3rd container where we can see the result of mysql files:->" con2
echo "----------------------------------------------------------------------------------------"
docker container run -d --name $con2 -e MYSQL_ALLOW_EMPTY_PASSWORD=true -v $vol:/usr/local/ --network $net mysql
echo "---------------------------------------------------------------------------------------------------------"
echo "----------------------------$con2 is running successfully-----------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------"
docker exec --user root $con2 apt-get -y update
docker exec --user root $con2 apt-get -y install python3
echo "-----------------------------------------------------------------"
echo "--------Third party app is not installing in this container------"
echo "---------------------------------------------------------------------------------"
echo "---Going into container for using mysql result for veiwing result as a end user---"
echo "----------------------------------------------------------------------------------"
for i in 1
do
	docker exec -it $con2 bash

done
echo "--------DONE---------------"
