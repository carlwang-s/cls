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

function get_ses_version()
{
	 cmd="sg_inq /dev/sg2|grep revision|cut -d ' ' -f 5"
    ses_ver=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		return 1
    }
	log_only "ses version is: $ses_ver"
	return 0
}

function check_ses_update_env()
{
	print_log  "======================== check sg_inq ======================="
	cmd="sg_inq --version"
	log_only  "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only  "RESULT:${cmd_report}"
		print_log "sg_inq command doesn't exist,please install it, you can use setuptool.sh"
		return 1
	}
	log_only  "RESULT:${cmd_report}"

	print_log "======================== check sg_ses_microcode ======================="
	cmd="sg_ses_microcode -V"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		print_log "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "Please install SG_utility tool first! You can use setuptool.sh"
		return 1
	}
	log_only "RESULT:${cmd_report}"

	print_log "======================== check installed cls.ko ======================="
	cmd="lsmod|grep -w cls"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	if [ $? -eq 0 ]
	then 
		log_only "The cls module has been installed in OS system!!!"
	else
		# print_log "$[$FUNCNAME] ${cmd} FAIL!!!"
		# log_only "RESULT:${cmd_report}"
		# return 1
	print_log "======================== make cls.ko ======================="

	cmd="determin_lnx_driver"
	log_only "COMMAND:${cmd}"
	__SES_TOOL_PATH=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${__SES_TOOL_PATH}"
		print_log "No suitable SES driver for this host kernel version, please get driver first!"
		return 1
	}
	log_only "RESULT:${__SES_TOOL_PATH}"

	log_only "======================== modinfo cls.ko ======================="
		cmd="modinfo ${__SES_TOOL_PATH}cls.ko"
		log_only "COMMAND:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
		}
		log_only "RESULT:${cmd_report}"

		print_log "======================== insmod cls.ko ======================="
		cmd="insmod ${__SES_TOOL_PATH}cls.ko"
		log_only "COMMAND:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
			print_log "install SES driver fail, please uninstall old SES switch driver and retry. Or try to power cycle system!"
			print_log "If it still doesn't work, please contact CLS SAE."
			return 1
		}
		log_only "RESULT:${cmd_report}"
	fi
	
	print_log "======================== check cls.ko working ======================="
	cmd="ls /dev/sg2*"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "SES driver can't work, please try to power cycle system or contact support!"
			
		return 1
	}
	log_only "RESULT:${cmd_report}"
}

function flash_ses_fw()
{
	local ses_cfg=$1
	local ses_osa=$2
	local cmd=
	local cmd_report=

	print_log "======================== Update SES fw ======================="
	# check ses version
	get_ses_version
	if [ $? -eq 0 ]
	then
		if [ "$ses_ver" = "$__SES_IMG_VER" ];
        then
            if [ "$same_up_flag" = "on" ]
			then 
				print_log "update SES ignore same version"
			else
				print_log "SES version is same as image!, if you want to update use ./upgrade ses same"
				return 0
			fi
        fi 
	else
		print_log "get SES version error!, do flash SES"
		
	fi

	{
		cmd=" sg_ses_microcode -m 0xe -b 3000 -I $ses_osa /dev/sg2"
		log_only "COMMAND:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
			echo "Some problem occur in flashing SES OSA image!!!"
			return 1
		}
		log_only "RESULT:${cmd_report}"
	
	} &
	child=$!
	{
		trap "log_only 'SES Flash timeout protect thread quit!!!'; return 1" SIGHUP
		# trap SIGHUP
		for var1 in {1..20}
		do
			echo "please waiting..."
			sleep 60
		done
		
		log_only "SES Flash timeout, stop program thread!!!"
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
		print_log "SES update FAIL!!!, if no other hint, means time out occur, please power cycle system and run upgrade again"	
		sleep 5
		kill -s SIGHUP $child2  >/dev/null 2>&1
		return 1
	}
	kill -s SIGHUP $child2 2>/dev/null

	
	return 0
}

function activate_ses_cpld()
{
	cmd="sg_ses_microcode -m 0xf /dev/sg2"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		return 1
	}
	log_only "RESULT:${cmd_report}"	
	
	# # sleep 240
	 log_only "COMMAND:sleep 240s"
	 {
		for var1 in {1..4}
		do
			echo "please waiting..."
			sleep 60
		done	
	 }
	return 0
}

