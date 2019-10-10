#!/bin/bash
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
# @file upgrade.sh
#
# 
# @author Donmi Ni & Simon Sun
#
# @version v0.1
# @par ChangeLog:
# @verbatim
# @endverbatim
# get root user authority.
# Usage: ./upgrade.sh
# ./upgrade.sh help --for help
# command use list:
# ./upgrade.sh --do all upgrade
# ./upgrade.sh allforce --do all module upgrade and use socflash for BMC if necessary
# ./upgrade.sh vercheck  --compare system version with upgrade package file version
# ./upgrade.sh bmc --bmc upgrade with version check"
# ./upgrade.sh bmcforce --do bmc upgrade and use soc if necessary
# ./upgrade.sh ses --do SES upgrade 
# ./upgrade.sh cpld --do cpld upgrade 
# ./upgrade.sh bios --do bios upgrade 
# ./upgrade.sh bmc bios --do bmc bios upgrade 
# ./upgrade.sh all same --do all upgrade and upgrade module even version is same
# ./upgrade.sh bmc same --do bmc upgrade and upgrade bmc even version is same
# ./upgrade.sh ses same --do bmc upgrade and upgrade ses even version is same
# ./upgrade.sh soc --do bmc upgrade without configuration save, this should use only when BMC can't work
# ./upgrade.sh -v show version of script
# @ChangeLog:
# change input para from one to many
#

source ${__STRESS_PATH}Scripts/upgrade_filename1.sh
[[ $? -eq 0 ]] || {
	print_log "Scripts/upgrade_filename.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

source ${__STRESS_PATH}Scripts/upgrade_global_val.sh
[[ $? -eq 0 ]] || {
	print_log "Scripts/upgrade_filename.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

source ${__STRESS_PATH}Scripts/comm_func.sh
[[ $? -eq 0 ]] || {
	echo -e "[`date +"%F_%H-%M-%S"`] ======================== upgrade script begin to run =======================" | tee -a "logall"
	echo -e "[`date +"%F_%H-%M-%S"`] ======================== upgrade script begin to run =======================" >> "log"

	echo -e "[`date +"%F_%H-%M-%S"`] comm_func.sh file doesn't exist" | tee -a "logall"
	echo -e "[`date +"%F_%H-%M-%S"`] comm_func.sh file doesn't exist" >> "log"
	sync
	exit 1
}

print_log "======================== upgrade script begin to run ======================="
source ${__STRESS_PATH}Scripts/lnx_driver.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

source ${__STRESS_PATH}Scripts/upgrade_bmc.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

source ${__STRESS_PATH}Scripts/upgrade_bios.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}
source ${__STRESS_PATH}Scripts/upgrade_ses.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}
source ${__STRESS_PATH}Scripts/upgrade_cpld.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

source ${__STRESS_PATH}Scripts/upgrade_function.sh
[[ $? -eq 0 ]] || {
	print_log "lnx_driver.sh file doesn't exist, please copy it to Scripts directory!!!"
	exit 1
}

############## main #############################
function main()
{
	local Next_A_B=
	local cmd=

	log_only $input_para

	#loop check all para
	if [ "$1" = "" ]
	then 
		upgrade_setflag ""
	else
		for input_para in "$@"
		do 
			x_input=$(echo $input_para |tr [a-z] [A-Z])
			upgrade_setflag $x_input
			[[ $? -eq 0 ]] || {
				if [ "$use_soc_flag" = "on" ] || [ "$ver_check_flag" = "on" ]
				then
					print_log "use_soc_flag is $use_soc_flag, ver_check_flag is $ver_check_flag!!!"
					break
				fi
				return 0
			}
		done
	fi
	
	log_only "ver_check_flag $ver_check_flag,soc_bmc_flag:$soc_bmc_flag"  #,bmc_check_flag $bmc_check_flag"
	log_only "bmc_upgrade_flag $bmc_upgrade_flag,bios_upgrade_flag $bios_upgrade_flag,ses_upgrade_flag $ses_upgrade_flag"
	log_only "ctl_cpld_upgrade_flag $esm_cpld_upgrade_flag,use_soc_flag: $use_soc_flag,same_up_flag:$same_up_flag "

	############################# check all image exists #######################################
	check_image_exist
	rc=$?
	[[ rc -eq 0 ]] || {
		print_log "check_image_exist FAIL, Please check the lost file, return=$rc!!!"
		return 1
	}
	############################################################################################

	################################ get file of bmc key version milstone ######################
	loop_analyze_BMC_keyversion
	rc=$?
	[[ rc -eq 0 ]] || {
		print_log "loop_analyze_BMC_keyversion FAIL(return=$rc), Please check Scripts/upgrade_filename.sh!!!"
		return 1
	}
	############################################################################################
	
	################################ ipmi tool check ###########################################
	if [ "$bmc_upgrade_flag" = "on" ] || [ "$bios_upgrade_flag" = "on" ] || [ "$ver_check_flag" = "on" ] || [ "$check_versionlimit_flag" != "off" ]
	then
		if [ "$use_soc_flag" = "on" ] 
		then
			print_log "It will use socflash to update BMC!"
		else
			ipmi_init
			rc=$?
			[[ rc -eq 0 ]] || {
				print_log "ipmi_init FAIL(return=$rc), you should retry after 5 minutes, if it still fail, please power cycle!!!"
				return 1
			}
		fi
	fi
	############################################################################################

	################################# SES tool check# ##########################################
	if [ "$ses_upgrade_flag" = "on" ] || [ "$cpld_upgrade_flag" = "on" ] || [ "$ver_check_flag" = "on" ] || [ "$check_versionlimit_flag" != "off" ]
	then
		check_ses_update_env
		[[ $? -eq 0 ]] || {
			print_log "check_ses_update_env FAIL, sg_uitiliy is not work, you can install by yourself or use setuptool.sh!!!"
			return 1
		}
	fi

	if [ "$ver_check_flag" = "on" ] || [ "$check_pltfm_flag" != "off" ] || [ "$check_versionlimit_flag" != "off" ]
	then 
		check_bios_env
		rc=$?
		[[ rc -eq 0 ]] || {
			print_log "bios cmd dmidecode is not installed(return=$rc), you can install by yourself or use setuptool.sh!!!"
			# install dmidecode
			return 1
		}
	fi
	############################################################################################
	
	######################### Check the FW version in your system ##############################
	#check version and return
	if [ "$ver_check_flag" = "on" ]
	then
		#do check version
		print_log "Check the FW version in your system."
		check_version
		rc=$?
		[[ rc -eq 0 ]] || {
			log_only "check_version FAIL, return=$rc!!!"
			print_log "Quit!!!"
			return 1
		}
		return 0
	fi
	############################################################################################
	
	################# check pltfm information and return if not target pltform #################
	if [ "$check_pltfm_flag" != "off" ]
	then
		print_log "===================check platform================================"
		platfm_check
		rc=$?
		[[ rc -eq 0 ]] || {
			print_log "The paltform is not FW package target platform: $__PLATFORM_NAME"
			print_log "To gurantee update successfully,please use right FW package!!!"
			print_log "If you still need to update, please append parameter 'nopltfm'"
			print_log "For example, ./upgrade.sh all nopltfm"
			print_log "return=$rc"
			print_log "Script Quit!!!"
			return 1
		}
	fi
	############################################################################################
	 
	######### check running version with compatible FW version return if not compatibl e########
	if [ "$check_versionlimit_flag" != "off" ]
	then
		print_log "=========================check FW compatible==========================="
		upgrade_version_limit_check
		rc=$?
		[[ rc -eq 0 ]] || {
			print_log "Script Quit, return=$rc!!!"
			return 1
		}
	fi
	############################################################################################

	############################## check use soc flag ##########################################
	if [ "$use_soc_flag" != "on"  ]
	then
		if [ "$bmc_upgrade_flag" = "on" ]
		then 
			check_BMC_upgrade_limit
			[[ $? -eq 0 ]] || {
				
				if [ "$bmc_upgrade_limit" = "on" ]
				then
					log_only "check_BMC_upgrade_limit cross version status!!!"
					if [ "$soc_bmc_flag" != "on" ]
					then
						print_log "The BMC FW update needs Socflash tool. There is risk to lose configuration data including BMC MAC Address."
						read -p "Do you want to continue? Please input y to continue: " var_user_soc
						log_only "var_user_soc $var_user_soc"
						
						if [ "$var_user_soc" = "y" ]
						then
							soc_bmc_flag="on"
							print_log "OK. Update BMC with SOCFlash tool!!!"
						else
							print_log "BMC Update Quit!!!"
							return 1
						fi
					# else
						# soc_bmc_flag="on"
						# return 1
					fi
				else
					print_log "check_BMC_upgrade_limit FAIL, can't detect BMC version and use which tool update it!!!"
					return 1
				fi
				
			}	
		fi
	fi
	############################################################################################
	
	################################### BMC update #############################################
	#bmc
    if [[ "$bmc_upgrade_flag" = "on" ]] && [[ "$use_soc_flag" != "on" ]] && [[ "$same_up_flag" != "on" ]]
	then
	   get_BMC_version
	   rc=$?
	   [[ rc -eq 0 ]] || {
			log_only "get BMC version error, return=rc!"
			return 1
		}
	   
	   if [[ "$bmc_bkp_now" = "$__BMC_IMG_VER" ]] && [[ "$bmc_pri_now" = "$__BMC_IMG_VER" ]]
       then 
		  print_log "the both version of BMC is same as update image, skip update BMC ."
		  print_log "if need update with same version, use ./upgrade bmc same"
	      bmc_upgrade_flag="off"
		  log_only "skip upgrade BMC without same option"
	       
	    fi
	fi
	
	if [ "$bmc_upgrade_flag" = "on" ]
	then 
		print_log "======================== BMC update ======================="
		upgrade_suc=
		second_bmc_update="1"
		for tmpcnt in {1..3}
		do
			if [ "$use_soc_flag" = "on" ] 
			then
			print_log "*******************update bmc with soc******************"
				updateBMCwithsoc "$__BMC_IMAGE" "0" "1"
					[[ $? -eq 0 ]] || {
					print_log "Retry BMC update: $tmpcnt"
					log_only "Retry BMC first bank update: $tmpcnt"
					print_log "Wait 3 minutes"
					sleep 60  #sleep 180
					print_log "Wait 2 minutes left"
					sleep 60  #sleep 180
					print_log "Wait 1 minute left"
					sleep 60  #sleep 180
					continue
					
				}	
				upgrade_suc="ok" 
				break
			else
				print_log "*******************update bmc with CFUFLASH******************"
				updateBMC
				[[ $? -eq 0 ]] || {
					print_log "Retry BMC update: $tmpcnt"
					log_only "Retry BMC first bank update: $tmpcnt"
					print_log "Wait 3 minutes"
					sleep 60  #sleep 180
					print_log "Wait 2 minutes left"
					sleep 60  #sleep 180
					print_log "Wait 1 minute left"
					sleep 60  #sleep 180
					continue
					
				}	
				upgrade_suc="ok" 
				break
			fi
		done
		if [ "$upgrade_suc" != "ok" ]
		then
			log_only "BMC update first bank FAIL, Script quit!!!"
			print_log "BMC update FAIL, Script quit!!!"
			return 1
		fi
		print_log "BMC update one chip successfully!!!"
		second_bmc_update="2"
		upgrade_suc=
		for tmpcnt in {1..3}
		do
			if [ "$use_soc_flag" = "on" ] 
			then
					updateBMCwithsoc  "$__BMC_IMAGE" "1" "2"
					[[ $? -eq 0 ]] || {
					print_log "Retry BMC first bank update: $tmpcnt"
					print_log "Wait 3 minutes"
					sleep 60  #sleep 180
					print_log "Wait 2 minutes left"
					sleep 60  #sleep 180
					print_log "Wait 1 minute left"
					sleep 60  #sleep 180
					continue
					
					}	
				upgrade_suc="ok" 
				break
			else
			updateBMC
			[[ $? -eq 0 ]] || {
				print_log "Retry BMC second bank update: $tmpcnt"
				print_log "Wait 3 minutes"
				sleep 60  #sleep 180
				print_log "Wait 2 minutes left"
				sleep 60  #sleep 180
				print_log "Wait 1 minute left"
				sleep 60  #sleep 180
				continue
				
			}	
			upgrade_suc="ok" 
			break
			fi
		done
		if [ "$upgrade_suc" != "ok" ]
		then
			log_only "BMC update second bank FAIL, Script quit!!!"
			print_log "BMC update FAIL, Script quit!!!"
			return 1
		fi
		print_log "BMC update both chips successfully"
	fi
	############################################################################################
	
	################################## BIOS Update #############################################
	#if [ "$bios_upgrade_flag" = "on"  ]
	#then
	#	print_log "======================== BIOS Update ======================="
	#	upgrade_suc=
	#	for tmpcnt in {1..3}
	#	do
	#		flash_bios_fw  "$__BIOS_IMAGE"
	#		[[ $? -eq 0 ]] || {
	#			print_log "Retry BIOS update: $tmpcnt"
	#			print_log "Wait 1 minute left"
	#			sleep 60  
	#			continue
	#		}
	#		upgrade_suc="ok" 
	#		break
	#	done
	#	if [ "$upgrade_suc" != "ok" ]
	#	then
	#		print_log "BIOS update FAIL, Script quit!!!"
	#		return 1
	#	fi
	#	print_log "BIOS update Successfully!!!"
	#fi
	############################################################################################

	#################################### SES  Update ###########################################
	if [ "$ses_upgrade_flag" = "on" ]
	then
		print_log "======================== SES  Update ======================="
		upgrade_suc=
		for tmpcnt in {1..3}
		do
		flash_ses_fw "${__SES_CFG_IMAGE}" "${__SES_OSA_IMAGE}"
			[[ $? -eq 0 ]] || {
				print_log "Retry SES update: $tmpcnt"
				print_log "Wait 1 minute left"
				sleep 60  
				continue
			}
			upgrade_suc="ok" 
			break
		done
		if [ "$upgrade_suc" != "ok" ]
		then
			print_log "SES update FAIL, Script quit!!!"
			return 1
		fi
		print_log "SES update Successfully!!!"
	fi	
	############################################################################################

	#################################### CTL CPLD Update ###########################################
	if [ "$ctl_cpld_upgrade_flag" = "on" ]
	then
		print_log "======================== CTL CPLD Update ======================="
		upgrade_suc=
		for tmpcnt in {1..3}
		do
                flash_ctl_cpld_fw "${__CTL_CPLD_IMAGE}"
                [[ $? -eq 0 ]] || {
                        print_log "retry CTL CPLD update: $tmpcnt"
                        print_log "wait 1 minute left"
                        sleep 60
			continue
		}
		upgrade_suc="ok" 
		break
		done
		if [ "$upgrade_suc" != "ok" ]
		then
			print_log "Contorller CPLD update FAIL, Script quit!!!"
			return 1
		fi
		print_log "Contorller CPLD update Successfully!!!"
	fi
	
	############################################################################################

	#################################### ESM CPLD Update ###########################################
	if [ "$esm_cpld_upgrade_flag" = "on" ]
	then
		print_log "======================== ESM CPLD Update ======================="
		upgrade_suc=
		for tmpcnt in {1..3}
		do
                flash_esm_cpld_fw "${__ESM_CPLD_IMAGE}"
                [[ $? -eq 0 ]] || {
                        print_log "retry ESM CPLD update: $tmpcnt"
                        print_log "wait 1 minute left"
                        sleep 60
			continue
		}
		upgrade_suc="ok" 
		break
		done
		if [ "$upgrade_suc" != "ok" ]
		then
			print_log "ESM CPLD update FAIL, Script quit!!!"
			return 1
		fi
		print_log "ESM CPLD update Successfully!!!"
	fi
	
	############################################################################################
	print_log "======================== Update System FW Successfully!!! ======================="
	print_log "======================== please power cycle the system!!! ======================="
	sync

	sleep 20
	#ipmitool power cycle
	return 0
}

main $*

