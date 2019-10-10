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

function get_ctl_cpld_version()
{
	cmd="ipmitool raw 0x3a 0x37"
    ctl_cpld_ver=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		return 1
    }
    cmd="echo $ctl_cpld_ver|cut -d ' ' -f 1"
    ctl_cpld_vermaj=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
         log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		 return 1
    }
    cmd="echo $ctl_cpld_ver|cut -d ' ' -f 2"
    cpld_vermin=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		return 1
    }
    cmd="echo $ctl_cpld_ver|cut -d ' ' -f 3"
    cpld_verleast=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		return 1
    }
	ctl_cpld_ver=$ctl_cpld_vermaj$ctl_cpld_vermin$cpld_verleast
	log_only "ctl_cpld_ver is $ctl_cpld_ver"
	return 0
}

function get_esm_cpld_version()
{
	return 0
}

function flash_ctl_cpld_fw()
{
	local cpld_img=$1
	local cmd=
	local cmd_report=

	# check cpld version
	get_ctl_cpld_version
	if [ $? -eq 0 ]
	then
		if [ "$ctl_cpld_ver" = "$__CTL_CPLD_IMG_VER" ];
        then
            if [ "$same_up_flag" = "on" ]
			then 
				print_log "update Controller CPLD ignore same version"
			else
				print_log "Controller CPLD version is same as image!, if you want to update use ./upgrade ctlcpld same"
				return 0
			fi
        fi 
	else
		print_log "get CTL CPLD version error!, do flash CTL CPLD"
	fi

	{
		cmd="./CFUFLASH -cd -d 4 $cpld_img -fb"
		trap "log_only 'FLASH CTL CPLD timeout and quit!!!'; return 1" SIGHUP
		log_only "COMMAND:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
			"Some problem occur in flashing CTL CPLD image!!!"
			return 1
		}
		log_only "RESULT:${cmd_report}"
		
	} &
	child=$!
	{
		trap "log_only 'CTL CPLD Flash timeout protect thread quit!!!'; return 1" SIGHUP
		# trap SIGHUP
		for var1 in {1..6}
		do
			echo "please waiting..."
			sleep 60
		done
		
		log_only "CTL CPLD Flash timeout, stop program thread!!!"
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
	#time out err print
	[[ $? -eq 0 ]] || {
		log_only "RESULT:${cmd_report_bmc}"
		print_log "CTL CPLD update FAIL!!!, if no other hint, means time out occur, please power cycle system and run upgrade again"	
		sleep 5
		kill -s SIGHUP $child2  >/dev/null 2>&1
		return 1
	}
	kill -s SIGHUP $child2 2>/dev/null

	return 0
}

function flash_esm_cpld_fw()
{
	local cpld_img=$1
	local cmd=
	local cmd_report=

	# check esm cpld version
	get_esm_cpld_version
	if [ $? -eq 0 ]
	then
		if [ "$esm_cpld_ver" = "$__ESM_CPLD_IMG_VER" ];
        then
            if [ "$same_up_flag" = "on" ]
			then 
				print_log "update ESM CPLD ignore same version"
			else
				print_log "ESM CPLD version is same as image!, if you want to update use ./upgrade cpld same"
				return 0
			fi
        fi 
	else
		print_log "get ESM CPLD version error!, do flash ESM CPLD"
	fi

	{	
		cmd="sg_ses_microcode -m 0xe -b 3000 -I $cpld_img /dev/sg2"
		trap "log_only 'FLASH ESM CPLD timeout and quit!!!'; return 1" SIGHUP
		log_only "COMMAND:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
			"Some problem occur in flashing ESM CPLD image!!!"
			return 1
		}
		log_only "RESULT:${cmd_report}"
		
	} &
	child=$!
	{
		trap "log_only 'ESM CPLD Flash timeout protect thread quit!!!'; return 1" SIGHUP
		# trap SIGHUP
		for var1 in {1..6}
		do
			echo "please waiting..."
			sleep 60
		done
		
		log_only "ESM CPLD Flash timeout, stop program thread!!!"
			# kill sg_ses_microcode first
		cmd="ps -ef|grep -w sg_ses_microcode|grep -v grep|awk '{print\$2}'"
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
	#time out err print
	[[ $? -eq 0 ]] || {
		log_only "RESULT:${cmd_report_bmc}"
		print_log "ESM CPLD update FAIL!!!, if no other hint, means time out occur, please power cycle system and run upgrade again"	
		sleep 5
		kill -s SIGHUP $child2  >/dev/null 2>&1
		return 1
	}
	kill -s SIGHUP $child2 2>/dev/null
	return 0
}
