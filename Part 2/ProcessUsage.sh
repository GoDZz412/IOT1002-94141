#!/bin/bash
#Name: Minh Nhat Tran (Billy)
#Student ID: A00332627

#Define log file name
LOGFILE=~/ProcessUsageReport-$(date +"%Y-%m-%d").log

#Clear or create the log file
>"$LOGFILE"

#Variable to count the number of the process get killed
Process_Killed_Count=0

echo "Top 5 processes by CPU usage"
echo "-----------------------------------------------------"

#Display the top 5 processes sorted by CPU usage
ps -eo user,pid,%cpu,lstart,cmd --sort=-%cpu | head -n 6
echo "-----------------------------------------------------"

#Ask the users if they want to proceed with killing non-root processes
read -p "Do you want to kill any non-root processes from this list? (Y/N): " confirm
echo "-----------------------------------------------------"

#Check the user's answer
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
	#Exit the program if users do not want to kill any process
	echo "No process were killed! Exiting..."
	exit 0
fi

#Process each of the top 5 processes
while read USER PID CPU START_DAY START_MONTH START_DATE START_TIME START_YEAR CMD; do
	#Ignore any empty or invalid lines
	[[ -z "$PID" ]] && continue
	
	#Prevent the bash script from killing itself (in case the bash script is in the top 5 CPU usage)
	if [[ "$PID" -eq "$BASHPID" ]]; then
		continue
	fi
	
	#Only kill processes not owned by root
	if [[ "$USER" != "root" ]]; then
		#kill -9 "$PID" 2>/dev/null #Force kill process command
		echo "Would kill process $CMD (PID: $PID, User: $USER, CPU: $CPU%)" #Safe test (comment the kill line)
		KILL_TIME=$(date)
		DEPARTMENT=$(id -gn "$USER" 2>/dev/null)
		
		#Write all details into the log file
		{
			echo "------------------------------------------"
			echo "User: $USER"
			echo "Department (Primary Group): $DEPARTMENT"
			echo "Process ID: $PID"
			echo "CPU Usage: $CPU%"
			echo "Process Started: $START_DAY $START_MONTH $START_DATE $START_TIME $START_YEAR"
			echo "Process Killed: $KILL_TIME"
			echo "Command: $CMD"
			echo "------------------------------------------"
		} >> "$LOGFILE"
		
		#Increase the count variable
		((Process_Killed_Count++))
	fi
done < <(ps -eo user,pid,%cpu,lstart,cmd --sort=-%cpu | head -n 6 | tail -n 5)

#Display final summary
echo "-----------------------------------------------------"
echo "Process Management Summary"
echo "Total processes killed: $Process_Killed_Count"
echo "Log file saved to: $LOGFILE"

exit 0
