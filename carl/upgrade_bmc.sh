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

#get the key version number of BMC
function loop_analyze_BMC_keyversion()
{
	for var1 in {1..100}
	do
		analyze_BMC_version_conflict $var1
		[[ $? -eq 0 ]] || {
			# print_log "return val is  $?"
			[[ $analyze_bmc_invalid -eq 0 ]] || {
				# print_log "in equal 2"
				break 1	
			}
			log_only "$[$FUNCNAME] analyze_BMC_version_conflict FAIL!!!"
			return 2
			
		}
	done
	return 0
}

analyze_bmc_invalid=
function analyze_BMC_version_conflict()
{
	analyze_bmc_invalid=0
	if [ $1 -eq 1 ]
	then
		cmd="cat $__VERSION_CTL_FILE |grep BMC|cut -d ',' -f $1|cut -d ':' -f 2|grep -o '[^ ]\+\(\+[^ ]\+\)*'"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			analyze_bmc_invalid=1
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report}"
			return 1
		}
		
		# log_only "key_version: ${cmd_report}"
		if [ "${cmd_report}" = ""  ]
		then
			analyze_bmc_invalid=1
			return 1
		fi
		bmc_key_ver[$1-1]=${cmd_report}
		log_only "bmc version stone${bmc_key_ver[$1-1]}"
	else
		# check whether , is exist
		cmd="cat $__VERSION_CTL_FILE |grep BMC|grep ','"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} !!!"
			log_only "RESULT:${cmd_report}"
			# "${cmd_report}" = ""
			analyze_bmc_invalid=1
			return 1
		}
		if [  "${cmd_report}" = ""   ]
		then
			analyze_bmc_invalid=1
			return 1
		fi

		cmd="cat $__VERSION_CTL_FILE  |grep BMC|cut -d ',' -f $1|grep -o '[^ ]\+\(\+[^ ]\+\)*'"
		cmd_report=`eval ${cmd} 2>&1`
		[[ $? -eq 0 ]] || {
			log_only "$[$FUNCNAME] ${cmd} !!!"
			log_only "RESULT:${cmd_report}"
			analyze_bmc_invalid=1
			return 1
		}
		log_only "key_version 2: ${cmd_report}"
		if [  "${cmd_report}" = ""   ]
		then
			analyze_bmc_invalid=1
			return 1
		fi
		bmc_key_ver[$1-1]=${cmd_report}
		log_only "bmc version 2: ${bmc_key_ver[$1-1]}"
	fi
	return 0
}

function get_BMC_version()
{
	bmc_pri_maj=
	bmc_pri_min=
	bmc_pri_now=
	bmc_bkp_maj=
	bmc_bkp_min=
	bmc_bkp_now=

	bmc_pri_maj=`eval ${BMC_MAJOR_VERSION_PRIMARY} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${BMC_MAJOR_VERSION_PRIMARY} FAIL!!!"
		return 1
    }
	log_only "bmc_pri_maj is $bmc_pri_maj"
	analyze_ipmitool $bmc_pri_maj
	[[ $? -eq 0 ]] || {
		log_only "Get BMC FW version FAIL!!!, BMC is not ready please retry after 5 minutes!"
		
		return 1
	}
	bmc_pri_maj='0x'$bmc_pri_maj
	let bmc_pri_maj=$bmc_pri_maj #convert to hex num
	bmc_pri_min=`eval ${BMC_MINOR_VERSION_PRIMARY} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${BMC_MINOR_VERSION_PRIMARY} FAIL!!!"
		return 1
    }
	log_only "bmc_pri_min is $bmc_pri_min"
	analyze_ipmitool $bmc_pri_min
	[[ $? -eq 0 ]] || {
		log_only "Get BMC FW version FAIL!!!, BMC is not ready please retry after 5 minutes!"		
		return 1
	}
	bmc_pri_min='0x'$bmc_pri_min
	let bmc_pri_min=$bmc_pri_min
	#bmc_pri_now=$bmc_pri_maj"."$bmc_pri_min
	if [[ $bmc_pri_min -ge 9 ]]
	then
	    bmc_pri_now=$bmc_pri_maj"."$bmc_pri_min
	else
	    bmc_pri_now=$bmc_pri_maj".0"$bmc_pri_min
	fi
    bmc_bkp_maj=`eval ${BMC_MAJOR_VERSION_BACKUP} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${BMC_MAJOR_VERSION_BACKUP} FAIL!!!"
		return 1
    }
	log_only "bmc_bkp_maj is $bmc_bkp_maj"
	analyze_ipmitool $bmc_bkp_maj
	[[ $? -eq 0 ]] || {
		log_only "Get BMC FW version FAIL!!!, BMC is not ready please retry after 5 minutes!"		
		return 1
	}
	bmc_bkp_maj='0x'$bmc_bkp_maj
	let bmc_bkp_maj=$bmc_bkp_maj
	bmc_bkp_min=`eval ${BMC_MINOR_VERSION_BACKUP} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only "$[$FUNCNAME] ${BMC_MINOR_VERSION_BACKUP} FAIL!!!"
		return 1
    }
	log_only "bmc_bkp_min is $bmc_bkp_min"
	analyze_ipmitool $bmc_bkp_min
	[[ $? -eq 0 ]] || {
		log_only "Get BMC FW version FAIL!!!, BMC is not ready please retry after 5 minutes!"		
		return 1
	}
	bmc_bkp_min='0x'$bmc_bkp_min
	let bmc_bkp_min=$bmc_bkp_min
	#bmc_bkp_now=$bmc_bkp_maj"."$bmc_bkp_min
	if [[ $bmc_bkp_min -ge 9 ]]
	then
	    bmc_bkp_now=$bmc_bkp_maj"."$bmc_bkp_min
	else
	    bmc_bkp_now=$bmc_bkp_maj".0"$bmc_bkp_min
	fi
	return 0
}

function get_BMC_chip()
{
	cmd="ipmitool raw 0x32 0x8f 0x07"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		return 1
	}
	
	log_only "RESULT:${cmd_report}"
	cmd="echo $cmd_report|cut -d ' ' -f 1"
	bmc_chip_now=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${bmc_chip_now}"
		return 2
	}
	log_only "RESULT:${bmc_chip_now}"
	return 0
}

function check_BMC_upgrade_limit()
{
	bmc_upgrade_limit=""
	get_BMC_version
	[[ $? -eq 0 ]] || {
		return 1
	}
	log_only "$bmc_pri_maj,$bmc_pri_min,$bmc_bkp_maj,$bmc_bkp_min,$bmc_pri_now,$bmc_bkp_now"
	
	get_BMC_version_gap $bmc_pri_now
	[[ $? -eq 0 ]] || {
		log_only "get_BMC_version_gap $bmc_pri_now FAIL !!!"
		return 2
	}
	log_only "low value is: $bmc_low_edge, high value is: $bmc_high_edge"

	test_in_BMC_gap $__BMC_IMG_VER
	[[ $? -eq 0 ]] || {
		bmc_upgrade_limit="on"
		print_log "This image version $__BMC_IMG_VER can't update BMC primary image $bmc_pri_now, please use socflash  "
		return 3
	}
	get_BMC_version_gap $bmc_bkp_now
	[[ $? -eq 0 ]] || {
		log_only "get_BMC_version_gap $bmc_pri_now FAIL!!!"
		return 4
	}
	log_only "low value is: $bmc_low_edge, high value is: $bmc_high_edge"

	test_in_BMC_gap $__BMC_IMG_VER
	[[ $? -eq 0 ]] || {
		bmc_upgrade_limit="on"
		print_log "This image version $__BMC_IMG_VER can't update BMC backup image $bmc_bkp_now, please use socflash  "
		return 5
	}
	return 0
}

#soc_bmc_fw save configuration and use soc 
function soc_bmc_fw()
{
	local filename=$1
	local mse_val=$3
	local chipnum=$2
	print_log "Flashing BMC chip."
	log_only "socflash chip $chipnum with file: $filename, mse is $mse_val"
	cmd="uname -m|grep 64"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] get machine type FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		return 1
	}
	log_only "RESULT:${cmd_report}"
	if [ "$cmd_report" != "" ]
	then
	# use soc 64
	__SOC_FILE="$__SOC_X64_FILE"
	else 
	# use soc 32
	__SOC_FILE=""
	log_only "no 32bit socflash!!!"
	return 1
	fi
	log_only "__SOC_FILE:$__SOC_FILE"
	cmd="chmod a+x $__SOC_FILE"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		return 1
	}
	log_only "RESULT:${cmd_report}"

	#select next boot BMC chip
	cmd="ipmitool raw 0x32 0x8f 0x01 0x$mse_val"
	log_only "COMMAND:${cmd}"
	cmd_report_bmc=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] set BMC boot chip $mse_val FAIL!!!"
		log_only "RESULT:${cmd_report_bmc}"		
		return 1
	}
	log_only "RESULT:${cmd_report_bmc}"
	#save config
	bmc_save_lancfg
	#soc it
	cmd="${__SOC_FILE} if=$filename cs=$chipnum"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		return 1
	}
	
	log_only "RESULT:${cmd_report}"
	log_only "Flash Image-${mse_val} OK. Please wait BMC reboot"
	print_log "Flash one BMC chip OK, Please wait for BMC activate!!!"
	log_only "COMMAND:sleep 240"
	{
		for var1 in {1..4}
		do
		print_log "please waiting..."
		sleep 60
		done
	}
	return 0
}

#use cfuflash to flash bmc
function flash_bmc_fw()
{
	local bmc=$1
	local cmd=
	# local cmd_report=
	local mse_val=$2

	#select next boot BMC chip
	cmd="ipmitool raw 0x32 0x8f 0x01 0x$mse_val"
	log_only "COMMAND:${cmd}"
	cmd_report_bmc=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] set BMC boot chip $mse_val FAIL!!!"
		log_only "RESULT:${cmd_report_bmc}"		
		return 1
	}
	log_only "RESULT:${cmd_report_bmc}"
	# print_log "COMMAND:sleep 120"

	# cmd="./BMC_tool/CFUFLASH_4.116.4/Linux_x86_64/CFUFLASH -cd -d 1   -force-boot –mse $mse_val  $bmc"
	cmd="${__BMC_PATH}CFUFLASH -cd -img-select $mse_val -force-boot $bmc"
	
		
	log_only "COMMAND:${cmd}"
	log_only "Flashing BMC Image-${mse_val}."   #"child is ${child}"
	print_log "Flashing one BMC chip."
	{
		 trap "log_only 'CFUFLASH timeout and quit!!!'; return 1" SIGHUP
		# trap "log_only 'CFUFLASH Thread cat SIGINT';trap SIGINT" SIGINT
		cmd_report_bmc=`eval ${cmd} 2>&1`
		# echo $cmd_report_bmc
		[[ $? -eq 0 ]] || {
			log_only "error return is $?"
			log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only "RESULT:${cmd_report_bmc}"
			analyze_cfuflash ${cmd_report_bmc}			
			return 1
		}
		log_only "RESULT:${cmd_report_bmc}"
		
	
	} &
	
	child=$!
	
	{
		trap "log_only 'Timeout protect Thread quit!!!'; return 0" SIGHUP
		# trap "log_only 'Timeout protect Thread cat SIGINT';trap SIGINT" SIGINT
		# trap SIGHUP
		for var1 in {1..15}
		do
		echo "please waiting..."
		sleep 60
		done
		log_only "BMC Flash timeout, stop program thread!!!"
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
			log_only "BMC update FAIL!!!, if no other hint, means time out occur, please power cycle system and run upgrade again"
			sleep 5
			kill -s SIGHUP $child2  >/dev/null 2>&1
			return 1
		}
	log_only "RESULT:${cmd_report_bmc}"
	kill -s SIGHUP $child2 2>/dev/null
	
	# sleep 30
	# [[ $2 -eq 2 ]] || {	#wait bmc reboot in flash bank 2
		log_only "Flash Image-${mse_val} OK. Please wait BMC reboot"
		print_log "Flash one BMC chip OK, Please wait for BMC activate!!!"
		log_only "COMMAND:sleep 240"
		{
			for var1 in {1..4}
			do
			echo "please waiting..."
			sleep 60
			done
			# echo "please waiting..."
			# sleep 60
			# echo "please waiting...."
			# sleep 60
			# echo "please waiting....."
			# sleep 60
			# echo "please waiting......"
			# sleep 60

		
		}
		# sleep 240
	# }
	
	# log_only "COMMAND:sleep 360"

	return 0
}

function updateBMC()
{
	#get current BMC chip
	bmc_chip_now=""
	get_BMC_chip
	[[ $? -eq 0 ]] || {
		log_only "BMC get flash chip error!!!"
		return 1
	}
	
	if [ $bmc_chip_now = "01" ]
	then
		bmc_upgrade_next="02"
		log_only "bmc_upgrade_target chip: $bmc_upgrade_next"
		print_log "Going to update BMC flash chip 1, secondary chip."
		# get version and compare
		#check BMC
		bmc_bkp_now=""
		get_BMC_version
		[[ $? -eq 0 ]] || {
			log_only "get BMC version error!"
			return 1
		}
		#compare with second chip version
		if [ "$bmc_bkp_now" = "$__BMC_IMG_VER" ];
		then
			if [ "$same_up_flag" != "on" ]
			then
			print_log "the secondary version of BMC is same as update image, skip update BMC secondary chip."
			print_log "if need update with same version, use ./upgrade bmc same"
			if [ "$second_bmc_update" = "1" ]
			then
				#select next boot BMC chip
				cmd="ipmitool raw 0x32 0x8f 0x01 0x02"
				log_only "COMMAND:${cmd}"
				cmd_report_bmc=`eval ${cmd} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only "$[$FUNCNAME] set BMC boot chip 02 FAIL!!!"
					log_only "RESULT:${cmd_report_bmc}"		
					return 1
				}
				print_log "Activate Inactive BMC, Please Wait."
				cmd="ipmitool raw 0x06 0x02"
				log_only "COMMAND:${cmd}"
				cmd_report_bmc=`eval ${cmd} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
					log_only "RESULT:${cmd_report_bmc}"		
					return 1
				}
				log_only "RESULT:${cmd_report_bmc}"
				log_only "COMMAND:sleep 240"
				{
					for var1 in {1..4}
					do
					print_log "please waiting..."
					sleep 60
					done
					

				
				}
				fi
			return 0
			fi
			print_log "update BMC with same version image."
		fi
		
		#upgrade BMC
		#get current BMC chip
		bmc_old_chip=$bmc_chip_now
		#if soc flg is on use soc
		if [ "$soc_bmc_flag" = "on" ]
		then 
			soc_bmc_fw  "$__BMC_IMAGE" "1" "02"
			[[ $? -eq 0 ]] || {
				return 1
			}
		else
			flash_bmc_fw "$__BMC_IMAGE" "02"  #"${PWD}/${__BMC_IMAGE}"  #   
			[[ $? -eq 0 ]] || {
				return 1
			}
		fi

		bmc_chip_now=""
		get_BMC_chip
		[[ $? -eq 0 ]] || {
			log_only "BMC get flash chip error!"
			return 1
		}
		if [ $bmc_upgrade_next != $bmc_chip_now ]
		then 
			log_only "Update BMC chip 1: Secondary flash chip fail,please check the logall!"
			return 1
		fi
		#config restore
		if [ "$soc_bmc_flag" = "on" ]
		then 
			
			bmc_restore_lancfg
		fi
	else
		bmc_upgrade_next="01"
		log_only "bmc_upgrade_target chip: $bmc_upgrade_next"
		print_log "Going to update BMC flash chip 0, first chip."
		bmc_old_chip=$bmc_chip_now
		# get version and compare
		#check BMC
		bmc_pri_now=""
		get_BMC_version
		[[ $? -eq 0 ]] || {
			log_only "get BMC version error!"
			return 1
		}
		#compare with second chip version
		if [ "$bmc_pri_now" = "$__BMC_IMG_VER" ];
		then
			if [ "$same_up_flag" != "on" ]
			then
			print_log "the primary version of BMC is same as update image, skip update BMC first chip."
			print_log "if need update with same version, use ./upgrade bmc same"
			if [ "$second_bmc_update" = "1" ]
			then
				#select next boot BMC chip
				cmd="ipmitool raw 0x32 0x8f 0x01 0x01"
				log_only "COMMAND:${cmd}"
				cmd_report_bmc=`eval ${cmd} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only "$[$FUNCNAME] set BMC boot chip 01 FAIL!!!"
					log_only "RESULT:${cmd_report_bmc}"		
					return 1
				}
				print_log "Activate Inactive BMC, Please Wait."
				cmd="ipmitool raw 0x06 0x02"
				log_only "COMMAND:${cmd}"
				cmd_report_bmc=`eval ${cmd} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
					log_only "RESULT:${cmd_report_bmc}"		
					return 1
				}
				log_only "RESULT:${cmd_report_bmc}"
				log_only "COMMAND:sleep 240"
				{
					for var1 in {1..4}
					do
					print_log "please waiting..."
					sleep 60
					done
					

				
				}
			fi
			return 0
			fi
			print_log "update BMC with same version image."
		fi
		
		#if soc flg is on use soc
		if [ "$soc_bmc_flag" = "on" ]
		then 
			soc_bmc_fw  "$__BMC_IMAGE" "0" "01"
			[[ $? -eq 0 ]] || {
				return 1
			}
		else
			flash_bmc_fw "$__BMC_IMAGE" "01"  #"${PWD}/${__BMC_IMAGE}"  #   
			[[ $? -eq 0 ]] || {
				return 1
			}
		fi

		bmc_chip_now=""
		get_BMC_chip
		[[ $? -eq 0 ]] || {
			log_only "BMC get flash chip error!"
			return 1
		}
		if [ $bmc_upgrade_next != $bmc_chip_now ]
		then 
			log_only "update BMC chip 0: first flash chip fail,please check the logall!"
			return 1
		fi
		#config restore
		if [ "$soc_bmc_flag" = "on" ]
		then 
			bmc_restore_lancfg
		fi
	fi
	return 0
}

function test_in_BMC_gap()
{
	target_v=$1
	# print_log "tested version is $target_v"
	if [ `echo "$target_v < ${bmc_high_edge}" | bc` -eq 1 ]
	then
		if [ `echo "$target_v >= ${bmc_low_edge}" | bc` -eq 1 ]
		then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

#get_BMC_version_gap compare the input,and return global variable
# bmc_high_edge and bmc_low_edge as the limit gap
# key version number is less not equal
# $1 is the given test version number
function get_BMC_version_gap()
{
	target_v=$1
	log_only "the test version is $target_v"
	bmc_high_edge=9999 #very large
	bmc_low_edge=0
	if  [  "${bmc_key_ver[0]}" = ""   ]
	then
		return 0
	fi

	let bmc_keyver_num=${#bmc_key_ver[@]}
	for ((var1=0; var1<$bmc_keyver_num; var1 ++))
	do
		# print_log "print $var1:${bmc_key_ver[$var1]}"
		if [ `echo "$target_v < ${bmc_key_ver[$var1]}" | bc` -eq 1 ]
		then
			bmc_high_edge=${bmc_key_ver[$var1]}
			break
		else
			bmc_low_edge=${bmc_key_ver[$var1]}
		fi
	done
	return 0

}

