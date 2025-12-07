#!/bin/bash
#Name: Minh Nhat Tran (Billy)
#Student ID: A00332627

echo "Hello Jeffrey"

#Declare varriables
input_file="EmployeeNames.csv" #the file to read
user_count=0 #count new user added
group_count=0 #count new group added

#Check whether the file exists
if [ ! -f "$input_file" ]; then
	echo "Error! File $input_file not found"
	exit 1
fi

#Loop to go through all records in the input file
while IFS=',' read -r FirstName LastName Department
do
	#Delete extra space and '\r' character from csv file created on Windows
	FirstName=$(echo "$FirstName" | tr -d '\r' | xargs)
	LastName=$(echo "$LastName" | tr -d '\r' | xargs)
	Department=$(echo "$Department" | tr -d '\r' | xargs)

	#Create username from firstname and lastname
	username=$(echo "${FirstName:0:1}${LastName:0:7}" | tr '[:upper:]' '[:lower:]')
	echo "Processing: $FirstName $LastName ($Department) -> $username"
	
	#Check whether username exists in the system
	if id "$username" &>/dev/null; then
		echo "Error! User $username already exists. Skip to next user..."
		continue
	fi
	
	#Check whether the group exists in the system
	if getent group "$Department" > /dev/null; then
		echo "Group $Department already exists"
	else
		#If the group does not exist, add it to the system
		groupadd "$Department"
		#echo "Would add new group" #safe test
		echo "Group $Department created"
		((group_count++))
	fi
	
	#If the user exists, check whether that user belongs to a group or not
	if id -nG "$username" 2>/dev/null | grep -qw "$Department"; then
		echo "User $username is already in group $Department. Skip to next user..."
		continue
	fi
	
	#If the user does not be long to any group, add that user to the group
	useradd -m -g "$Department" "$username"
	#echo "Would add new user" #safe test
	if [ $? -eq 0 ]; then
		echo "User $username created and added to group $Department"
		((user_count++))
	else
		echo "Error creating user $username"
	fi 
done < <(tail -n +2 "$input_file") #Skip the header

#Display the number of new user and group added
echo "new user added: $user_count"
echo "new group added: $group_count"
