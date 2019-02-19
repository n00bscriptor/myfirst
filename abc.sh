cat /dev/null > /tmp/FSspace.log
cat /dev/null > /tmp/test01
pdw=`pwd`
servername=`uname -n`
echo "Hi Unix Admin, \n" >> /tmp/FSspace.log
echo "The current FS utilization on the server $servername is: \n" >> /tmp/FSspace.log
df -gt . >> /tmp/FSspace.log
##Testing something new##
a=$(df -gt $pdw | tail -1 | awk '{print $5}' | sed 's/%//')
##Setting the threshold to 80%##
if [ $a -lt 80 ]
	then
	echo "\nThe FS $pdw ($a% utilized) is already under threshold value, no neeed for housekeeping!" >> /tmp/FSspace.log; echo "\nRegards, \n -FSBot" >> /tmp/FSspace.log
else
	{
		echo "\n The top 10 space consuming files in the FS $pdw are:\n" >> /tmp/FSspace.log
		echo --------------------------------------------------------------- >> /tmp/FSspace.log
		echo 'Owner                             Size (MBs)                              Filename' >> /tmp/FSspace.log
		find . -xdev -ls | sort -nrk7 | head | awk '{print $5 "                 " $7/1024 "                     " $11}' >> /tmp/FSspace.log
		find . -xdev -ls | sort -nrk7 | head | awk '{print $5 "                 " $7/1024 "                     " $11}' > /tmp/test01
		echo --------------------------------------------------------------- >> /tmp/FSspace.log
		
		echo '\n\nPlease drop a mail to the below individuals to perform the housekeeping on thier files. \nAlso please take care of the root owned files if any. \n' >> /tmp/FSspace.log
		
		##Modifying script as per Unix flavors##
		
		
			OS=$(uname)
			if [ $OS == 'AIX' ]
				then
		
						##For loop to find out the gecos of the users##
						for i in `cat /tmp/test01 | awk '{print $1}' | grep -v root | uniq`
						do
							lsuser -a gecos $i >> /tmp/FSspace.log 2>1
							echo "\n" >> /tmp/FSspace.log
						done
		
				else
						if [ $OS == 'Linux' ]
								then
									for i in `cat /tmp/test01 | awk '{print $1}' | grep -v root | uniq`
									do
										getent passwd $i| awk -F":" '{print $5}' >> /tmp/FSspace.log 2>1
										echo "\n" >> /tmp/FSspace.log
									done
		
				else
						echo "OS not supported";exit
				fi
				fi
		
		echo "Regards, \n -FSBot" >> /tmp/FSspace.log
	}
fi

##Mailing the result##
cat /tmp/FSspace.log | mail -s "Largest space consuming files" $(cat /tmp/emailadd)
