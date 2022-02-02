#!/usr/bin/env bash
#Install mscanner(Modsec+ClamAV) on Apache to prevent malware uploading through websites.
#by Vipin John Wilson

G="\033[32m"
R="\033[31m"
Y="\033[33m"
C="\033[36m"
N="\033[0m"

EA="/usr/local/cpanel/scripts/easyapache --version"
MODEA3="/usr/local/apache/conf/modsec2.user.conf"
MODEA4="/etc/apache2/conf.d/modsec/modsec2.user.conf"
CLAMD="/usr/local/cpanel/3rdparty/bin/clamdscan"
CHKSD="/etc/chkserv.d/chkservd.conf"


###Function to check if clamd is running####
clamd_check ()
{
if [[ -x $CLAMD ]]; then 
	pgrep clamd >/dev/null 2>&1
	local PEVAL=$?
	grep 'clamd:1' $CHKSD >/dev/null 2>&1
	local CHKEVAL=$?
	if [[ $PEVAL -eq 0 ]] && [[ $CHKEVAL -eq 0 ]]; then
		echo -e ""$G"clamd"$N": "$Y"found running..."$N"\n"
	else
		echo -e ""$G"clamd"$N": "$R"not running..."$N"\n"
		echo -e ""$R"Ensure it is installed, listening and enabled in WHM >> Service Manager"$N"\n"
		sleep 1; exit 0;
	fi;
else
	echo -e ""$R"check if clamdscan binary executable $CLAMD exists or if it has got the execute permission 755"$N"\n"
	sleep 1; exit 0;
fi;	
}
###clamd_check ends here####


###Function to check the Apache syntax####
apache_syntax_check ()
{
httpd -t >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
	echo -e ""$C"No syntax errors. Restarting Apache"$N"\n"
	local OSVER=$(rpm -qf --queryformat '%{VERSION}\n' /etc/redhat-release | cut -d. -f1)
	if [[ $OSVER == 6 ]] || [[ $OSVER == 5 ]]; then
		/etc/init.d/httpd restart
		echo -e ""$C"done"$N"\n"
	elif [[ $OSVER == 7 ]]; then
		/usr/bin/systemctl restart httpd
		echo -e ""$C"done"$N"\n"
	else
		echo -e ""$R"Invalid OS Version. Exiting..."$N"\n"
		sleep 1; exit 0;
	fi;
else
	echo -e ""$R"Syntax errors found. Please correct it manually.."$N"\n"
	sleep 1; exit 0;
fi;
}
###apache_syntax_check ends here####


###Download source of mscanner###
compile_ms ()
{
	echo -e ""$C"Downloading source and compiling..."$N"\n"
	/usr/bin/curl -u accessme -o /usr/local/src/mscanner.c http://172.98.74.184/mscanner/mscanner.c -o /usr/local/src/vcp http://172.98.74.184/mscanner/vcp;
	/usr/bin/gcc -v -o /usr/local/src/mscanner /usr/local/src/mscanner.c;
	rm /usr/local/src/mscanner.c >/dev/null 2>&1; 
	mv -fv /usr/local/src/mscanner /usr/local/cpanel/3rdparty/bin/; 
	ln -sv /usr/local/cpanel/3rdparty/bin/mscanner /usr/sbin/mscanner; 
	mv -fv /usr/local/src/vcp /usr/local/cpanel/3rdparty/bin/vcp;
	chmod -v 755 /usr/local/cpanel/3rdparty/bin/vcp;
	ln -sv /usr/local/cpanel/3rdparty/bin/vcp /usr/sbin/vcp
	echo -e "\n"$C"Done.."$N"\n"
}
###Source download function ends here###


####Function to remove any existing mscanner files before installing it fresh####
remove_broken ()
{
	if [[ $EAVAL -eq 0 ]]; then
		sed -i '/SecRequestBodyAccess/d' $MODEA3
		sed -i '/SecTmpSaveUploadedFiles/d' $MODEA3 
		sed -i '/SecAuditEngine/d' $MODEA3
		sed -i '/SecAuditLogRelevantStatus/d' $MODEA3
		sed -i '/SecAuditLogParts/d' $MODEA3
		sed -i '/SecAuditLogType/d' $MODEA3
		sed -i '/SecUploadDir/d' $MODEA3
		sed -i '/SecTmpDir/d' $MODEA3
		sed -i '/SecDataDir/d' $MODEA3
		sed -i '/SecUploadKeepFiles/d' $MODEA3
		sed -i '/SecUploadFileMode/d' $MODEA3
		sed -i '/SecUploadFileLimit/d' $MODEA3
		sed -i '/SecRule/d' $MODEA3
		sed -i '/mdirectives/d' $MODEA3
		sed -i '/mscanner/d' $MODEA3
		rm /usr/local/mdirectives >/dev/null 2>&1
		rm /usr/local/mscanner >/dev/null 2>&1
		unlink /usr/sbin/vcp >/dev/null 2>&1
		rm /usr/local/cpanel/3rdparty/bin/vcp >/dev/null 2>&1
		unlink /usr/sbin/mscanner >/dev/null 2>&1
		rm /usr/local/cpanel/3rdparty/bin/mscanner >/dev/null 2>&1	
		rm /usr/sbin/kvscanner >/dev/null 2>&1
	else 
		sed -i '/SecRequestBodyAccess/d' $MODEA4
		sed -i '/SecTmpSaveUploadedFiles/d' $MODEA4
		sed -i '/SecAuditEngine/d' $MODEA4
		sed -i '/SecAuditLogRelevantStatus/d' $MODEA4
		sed -i '/SecAuditLogParts/d' $MODEA4
		sed -i '/SecAuditLogType/d' $MODEA4
		sed -i '/SecUploadDir/d' $MODEA4
		sed -i '/SecTmpDir/d' $MODEA4
		sed -i '/SecDataDir/d' $MODEA4
		sed -i '/SecUploadKeepFiles/d' $MODEA4
		sed -i '/SecUploadFileMode/d' $MODEA4
		sed -i '/SecUploadFileLimit/d' $MODEA4
		sed -i '/SecRule/d' $MODEA4
		sed -i '/mdirectives/d' $MODEA4
		sed -i '/mscanner/d' $MODEA4
		rm /usr/local/mdirectives >/dev/null 2>&1
		rm /usr/local/mscanner >/dev/null 2>&1
		unlink /usr/sbin/vcp >/dev/null 2>&1
		rm /usr/local/cpanel/3rdparty/bin/vcp >/dev/null 2>&1
		unlink /usr/sbin/mscanner >/dev/null 2>&1
		rm /usr/local/cpanel/3rdparty/bin/mscanner >/dev/null 2>&1
		rm /usr/sbin/kvscanner >/dev/null 2>&1
	fi;
}
####Function to remove any existing mscanner files ends here####


###Function to install mscanner####
inst ()		
{
remove_broken
echo "SecRule FILES_TMPNAMES \"@inspectFile mscanner\" phase:2,t:none,log,block,id:903994099" > /usr/local/mscanner
chmod 600 /usr/local/mscanner
touch /usr/local/mdirectives
chmod 600 /usr/local/mdirectives
local MDIR="/usr/local/mdirectives"
if [[ $EAVAL -eq 0 ]]; then
	echo -e ""$C"Easyapache version 3 detected. Now adding necessary directives to its modsec user configuration file"$N"\n"
	echo "SecRequestBodyAccess On" >> $MDIR
	echo "SecAuditEngine RelevantOnly" >> $MDIR
	echo "SecAuditLogRelevantStatus \"^(?:5|4(?!04))\"" >> $MDIR
	echo "SecAuditLogParts ABIJDEFHKZ" >> $MDIR 
	echo "SecAuditLogType Serial" >> $MDIR
	echo "SecUploadDir /tmp" >> $MDIR
	echo "SecTmpDir /tmp" >> $MDIR
	echo "SecDataDir /tmp" >> $MDIR
	echo "SecUploadKeepFiles RelevantOnly" >> $MDIR
	echo "SecUploadFileMode 0640" >> $MDIR
	echo "SecUploadFileLimit 32" >> $MDIR
	echo "Include /usr/local/mscanner" >> $MDIR
	echo "Include $MDIR" >> $MODEA3
	echo -e ""$C"Directives are added"$N"\n" 
	compile_ms
	echo -e ""$C"Now performing Apache syntax check..."$N"\n"
	apache_syntax_check
else
	echo -e ""$C"Easyapache version 4 detected. Now adding necessary directives to its modsec user configuration file"$N"\n"
	echo "SecRequestBodyAccess On" >> $MDIR
	echo "SecAuditEngine RelevantOnly" >> $MDIR
	echo "SecAuditLogRelevantStatus \"^(?:5|4(?!04))\"" >> $MDIR
	echo "SecAuditLogParts ABIJDEFHKZ" >> $MDIR 
	echo "SecAuditLogType Serial" >> $MDIR
	echo "SecUploadDir /tmp" >> $MDIR
	echo "SecTmpDir /tmp" >> $MDIR
	echo "SecDataDir /tmp" >> $MDIR
	echo "SecUploadKeepFiles RelevantOnly" >> $MDIR
	echo "SecUploadFileMode 0640" >> $MDIR
	echo "SecUploadFileLimit 32" >> $MDIR
	echo "Include /usr/local/mscanner" >> $MDIR
	echo "Include $MDIR" >> $MODEA4
	echo -e ""$C"Directives are added"$N"\n" 
	compile_ms
	echo -e ""$C"Now performing Apache syntax check..."$N"\n"
	apache_syntax_check
fi;
}
###Function to install ends here####


###Function to uninstall####
uninst () 	
{
if [[ $EAVAL -eq 0 ]]; then
	sed -i '/SecRequestBodyAccess/d' $MODEA3
	sed -i '/SecTmpSaveUploadedFiles/d' $MODEA3 
	sed -i '/SecAuditEngine/d' $MODEA3
	sed -i '/SecAuditLogRelevantStatus/d' $MODEA3
	sed -i '/SecAuditLogParts/d' $MODEA3
	sed -i '/SecAuditLogType/d' $MODEA3
	sed -i '/SecUploadDir/d' $MODEA3
	sed -i '/SecTmpDir/d' $MODEA3
	sed -i '/SecDataDir/d' $MODEA3
	sed -i '/SecUploadKeepFiles/d' $MODEA3
	sed -i '/SecUploadFileMode/d' $MODEA3
	sed -i '/SecUploadFileLimit/d' $MODEA3
	sed -i '/SecRule/d' $MODEA3
	sed -i '/mdirectives/d' $MODEA3
	sed -i '/mscanner/d' $MODEA3
	rm /usr/local/mdirectives >/dev/null 2>&1
	rm /usr/local/mscanner >/dev/null 2>&1
	unlink /usr/sbin/vcp >/dev/null 2>&1
	rm /usr/local/cpanel/3rdparty/bin/vcp >/dev/null 2>&1
	unlink /usr/sbin/mscanner >/dev/null 2>&1
	rm /usr/local/cpanel/3rdparty/bin/mscanner >/dev/null 2>&1
	rm /usr/sbin/kvscanner >/dev/null 2>&1
	echo -e "\n"$C"Done.."$N"\n"
	echo -e ""$C"Now performing Apache syntax check..."$N"\n"
	apache_syntax_check	
else
	sed -i '/SecRequestBodyAccess/d' $MODEA4
	sed -i '/SecTmpSaveUploadedFiles/d' $MODEA4
	sed -i '/SecAuditEngine/d' $MODEA4
	sed -i '/SecAuditLogRelevantStatus/d' $MODEA4
	sed -i '/SecAuditLogParts/d' $MODEA4
	sed -i '/SecAuditLogType/d' $MODEA4
	sed -i '/SecUploadDir/d' $MODEA4
	sed -i '/SecTmpDir/d' $MODEA4
	sed -i '/SecDataDir/d' $MODEA4
	sed -i '/SecUploadKeepFiles/d' $MODEA4
	sed -i '/SecUploadFileMode/d' $MODEA4
	sed -i '/SecUploadFileLimit/d' $MODEA4
	sed -i '/SecRule/d' $MODEA4
	sed -i '/mdirectives/d' $MODEA4
	sed -i '/mscanner/d' $MODEA4
	rm /usr/local/mdirectives >/dev/null 2>&1
	rm /usr/local/mscanner >/dev/null 2>&1
	unlink /usr/sbin/vcp >/dev/null 2>&1
	rm /usr/local/cpanel/3rdparty/bin/vcp >/dev/null 2>&1
	unlink /usr/sbin/mscanner >/dev/null 2>&1
	rm /usr/local/cpanel/3rdparty/bin/mscanner >/dev/null 2>&1
	rm /usr/sbin/kvscanner >/dev/null 2>&1
	echo -e "\n"$C"Done.."$N"\n"
	echo -e ""$C"Now performing Apache syntax check..."$N"\n"
	apache_syntax_check
fi;
}
###Function to uninstall ends here####


###Main starts here####
if [[ $# == 0 ]]; then 
	echo -e "\n"$R"No flags given"$N"\n"
	echo -e ""$C"Available flags | -i to install, -u to uninstall"$N"\n"
	sleep 1; exit 0
elif [[ $# > 1 ]]; then
	echo -e "\n"$R"You can pass only one flag at a time"$N"\n"
	sleep 1; exit 0
elif [[ $# == 1 ]]; then
	if [[ $1 == "-u" ]]; then
		echo -e "\n"$C"Uninstalling mscanner :("$N"\n"
		$EA >/dev/null 2>&1; EAVAL=$?;
		uninst
		echo -e ""$C"Uninstallation is over.."$N"\n"
		sleep 1; exit 0
	elif [[ $1 == "-i" ]]; then
		echo -e "\n"$C"Thank you for choosing mscanner :)"$N"\n"
		echo -e ""$C"Kindly note that this will first remove any existing mscanner configuration files and install it fresh.."$N"\n"
		echo -e ""$C"First checking if clamdscan is running fine.."$N"\n"
		clamd_check
		echo -e ""$C"Finding Easyapache version.."$N"\n"
		$EA >/dev/null 2>&1; EAVAL=$?;
		inst
		echo -e ""$C"Installation is over. You're good to go.."$N"\n"
		sleep 1; exit 0
	else 
		echo -e "\n"$R"Unrecognized flag given"$N"\n"
		echo -e ""$C"Valid flags | -i to install, -u to uninstall"$N"\n"
		sleep 1; exit 0
	fi;
else
	echo -e "\n"$R"Exiting... some unknown arguments given"$N"\n"
	sleep 1; exit 0
fi;
###Main ends here####
