#!/bin/bash 
#
#
# Copyright © 2018 Celestica. All Rights Reserved.
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. The name of the CELESTICA may not be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY CELESTICA "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# Export.  The Software is subject to any and all laws, regulations, 
# orders or other restrictions relative to export,
# re-export or redistribution of the Software that may now or in the future be imposed by the government of the United States or foreign governments.
# You agree to comply with all applicable import and export control laws and regulations.
# You will not export, re-export, divert, transfer or disclose, 
# directly or indirectly the Software and any related documentation or materials without strictly complying with all applicable export control laws and regulations. 
#
# $Id$
# $Log$
#
#-------------------------------------------------------------------
# @file upgrade_filename.sh
#

function check_bios_env()
{
	#check BIOS version cmd check
	print_log  "======================== bios env check ======================="
	
    cmd="dmidecode"
	log_only "COMMAND Check:${cmd}"
	test_case=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		print_log "Please install command dmidecode. You can use setuptool.sh"
		return 1
	}
    log_only "$cmd exist"
	return 0
}

function get_BIOS_version()
{
	cmd="dmidecode -t 0|grep Version|cut -d ' ' -f 2"
    bios_ver=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		return 1
    }
	log_only "FUNC:get_BIOS_version bios_ver:$bios_ver"
	return 0
}

function flash_bios_fw()
{
	local bios=$1
	local cmd=
	local cmd_report=

	# check bios version
	get_BIOS_version
	if [ $? -eq 0 ]
	then
		if [ "$bios_ver" = "$__BIOS_IMG_VER" ];
        then
            if [ "$same_up_flag" = "on" ]
			then 
				print_log "update BIOS ignore same version"
			else
				print_log "BIOS version is same as image!, if you want to update use ./upgrade bios same"
				return 0
			fi
        fi 
	else
		log_only "get BIOS version error!, do flash BIOS"
		
	fi

	log_only "COMMAND:sleep 120"
	# sleep 120
	print_log "please wait for environment setup"
	sleep 60
	print_log "please wait... 1 minute"
	sleep 60
	
	print_log "Flashing BIOS, plase wait..."  #"child id is${child}"
	cmd="${__BMC_PATH}CFUFLASH -cd -d 2 $bios"
	log_only "COMMAND:${cmd}"
	{
	trap "log_only 'CFUFLASH BIOS timeout and quit!!!'; return 1" SIGHUP
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		echo "Flashing BIOS Fail"
		return 1
	}
	log_only "RESULT:${cmd_report}"
	}&
	child=$!
	
	{
		trap "log_only 'Timeout protect Thread quit!!!'; return 0" SIGHUP
		# trap SIGHUP
		for var1 in {1..15}
		do
		echo "please waiting..."
		sleep 60
		done
	
		
		log_only "BIOS flash timeout, stop program thread!!!"
			# kill CFUFLASH first
		cmd="ps -ef|grep -w CFUFLASH|grep -v grep|awk '{print\$2}'"
		log_only "COMMAND:${cmd}"
		grep_rel=`eval ${cmd} 2>&1`
		if [ $? = "0" ]
		then

			log_only "RESULT:${grep_rel}"
			kill ${grep_rel} >/dev/null 2>&1
			sleep 1
				
		else
			log_only "COMMAND:${cmd} FAIL!!!"
			log_only "RESULT:${cmd}${grep_rel}"	
		fi
		
		kill -s SIGHUP $child >/dev/null 2>&1
		
		
	}&
	child2=$!
	wait $child
	[[ $? -eq 0 ]] || {  #just use  timeout
		# print_log "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "BIOS update FAIL!!!, if no other hint, means time out occur, please power cycle system and run upgrade again"
		sleep 5	
		kill -s SIGHUP $child2  >/dev/null 2>&1
		return 1
	}
	log_only "RESULT:${cmd_report}"
	kill -s SIGHUP $child2  >/dev/null 2>&1
	print_log "update BIOS OK. Please wait for next step." 
	sleep 30
	log_only "COMMAND:sleep 30"
	
	return 0
}

