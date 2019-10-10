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

#check all image existance
function check_image_exist()
{
	log_only "Script version is $SCRIPT_VER"
	log_only "Check Image File:"
	log_only "__BMC_IMAGE: $__BMC_IMAGE"
	log_only "__BIOS_IMAGE: $__BIOS_IMAGE"
	#log_only "__SES_CFG_IMAGE: __SES_CFG_IMAGE"
	log_only "__SES_OSA_IMAGE: $__SES_OSA_IMAGE"
	log_only "__CTL_CPLD_IMAGE: $__CTL_CPLD_IMAGE"
	log_only "__ESM_CPLD_IMAGE: $__ESM_CPLD_IMAGE"
	log_only "__VERSION_CTL_FILE: $__VERSION_CTL_FILE"
	log_only "__SOC_X64_FILE: $__SOC_X64_FILE"
	log_only "__BMC_IMG_VER: $__BMC_IMG_VER"
	log_only "__BIOS_IMG_VER: $__BIOS_IMG_VER"
	log_only "__SES_IMG_VER: $__SES_IMG_VER"
	log_only "__CTL_CPLD_IMG_VER: $__CTL_CPLD_IMG_VER"
	log_only "__ESM_CPLD_IMG_VER: $__ESM_CPLD_IMG_VER"
	cmd="uname -a"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
			
		return 1
	}
	log_only "OS Information:${cmd_report}"
	
 if [ ! -f "$__BMC_IMAGE" ]; then 
	print_log "$__BMC_IMAGE doesn't exist, please prepare it!!!"
	return 2 
 fi 
	
 if [ ! -f "$__BIOS_IMAGE" ]; then 
	print_log "$__BIOS_IMAGE doesn't exist, please prepare it!!!"
	return 3 
 fi 
	
#if [ ! -f "$__SES_CFG_IMAGE" ]; then 
#	print_log "$__SES_CFG_IMAGE doesn't exist, please prepare it!!!"
#	return 4 
#fi 
	
 if [ ! -f "$__SES_OSA_IMAGE" ]; then 
	print_log "$__SES_OSA_IMAGE doesn't exist, please prepare it!!!"
	return 5 
 fi 
	
 if [ ! -f "$__CTL_CPLD_IMAGE" ]; then 
	print_log "$__CTL_CPLD_IMAGE doesn't exist, please prepare it!!!"
	return 6
 fi

 if [ ! -f "$__ESM_CPLD_IMAGE" ]; then 
	print_log "$__ESM_CPLD_IMAGE doesn't exist, please prepare it!!!"
	return 7
 fi
	
 if [ ! -f "$__VERSION_CTL_FILE" ]; then 
	print_log "$__VERSION_CTL_FILE doesn't exist, please prepare it!!!"
	return 8 
 fi 
	
 if [ ! -f "$__SOC_X64_FILE" ]; then 
	print_log "$__SOC_X64_FILE doesn't exist, please prepare it!!!"
	return 9
 fi 
	
if [ "$__BMC_IMG_VER"  = ""  ] 
then
	print_log "__BMC_IMG_VER doesn't define, please update upgrade_filename.sh"
	return 10
fi
	
if [ "$__BIOS_IMG_VER"  = ""  ] 
then
	print_log "__BIOS_IMG_VER doesn't define, please update upgrade_filename.sh"
	return 11
fi
		
if [ "$__SES_IMG_VER"  = ""  ] 
then
	print_log "__SES_IMG_VER doesn't define, please update upgrade_filename.sh"
	return 12
fi
		
if [ "$__CTL_CPLD_IMG_VER"  = ""  ] 
then
	print_log "__CTL_CPLD_IMG_VER doesn't define, please update upgrade_filename.sh"
	return 13
fi

if [ "$__ESM_CPLD_IMG_VER"  = ""  ] 
then
	print_log "__ESM_CPLD_IMG_VER doesn't define, please update upgrade_filename.sh"
	return 14
fi

 return 0
}

function upgrade_setflag()
{
	parain=$1
	print_log "Input parameter: $parain"
	case "$parain" in
		"VERCHECK")
		ver_check_flag="on"
		bios_upgrade_flag="off"
		bmc_upgrade_flag="off"
		ses_upgrade_flag="off"
		ctl_cpld_upgrade_flag="off"
		esm_cpld_upgrade_flag="off"
		return 1
		;;
		"BMCFORCE")
		# bmc_check_flag="off"
		soc_bmc_flag="on"
		bmc_upgrade_flag="on"
		# bios_upgrade_flag="off"
		# ses_upgrade_flag="off"
		# cpld_upgrade_flag="off"
		;;
		"BMC")
		bmc_upgrade_flag="on"
		# bios_upgrade_flag="off"
		# ses_upgrade_flag="off"
		# cpld_upgrade_flag="off"
		;;
		"BIOS")
		bios_upgrade_flag="on"
		# bmc_check_flag="off"
		# bmc_upgrade_flag="off"
		# ses_upgrade_flag="off"
		# cpld_upgrade_flag="off"
		;;
		"SES")
		ses_upgrade_flag="on"
		# bmc_check_flag="off"
		# bmc_upgrade_flag="off"
		# bios_upgrade_flag="off"
		# cpld_upgrade_flag="off"
		;;
		"CTLCPLD")
		ctl_cpld_upgrade_flag="on"
		;;
		"ESMCPLD")
		esm_cpld_upgrade_flag="on"
		;;
		"ALLFORCE")
		soc_bmc_flag="on"
		bmc_upgrade_flag="on"
		bios_upgrade_flag="on"
		ses_upgrade_flag="on"
		ctl_cpld_upgrade_flag="on"
		esm_cpld_upgrade_flag="on"
		;;
		"ALL")
		bmc_upgrade_flag="on"
		bios_upgrade_flag="on"
		ses_upgrade_flag="on"
		ctl_cpld_upgrade_flag="on"
		esm_cpld_upgrade_flag="on"
		;;
		"SOC")
		use_soc_flag="on"   #will not use ipmitool raw 0x32 0x8f 0x07 get bmc version
		bmc_upgrade_flag="on"
		bios_upgrade_flag="off"
		# bmc_check_flag="off"
		ses_upgrade_flag="off"
		ctl_cpld_upgrade_flag="off"
		esm_cpld_upgrade_flag="off"
		return 1
		;;
		"SAME")
		same_up_flag="on"
		;;
		"-V")
		echo "upgrade.sh version is $SCRIPT_VER"
		return 1
		;;
		"HELP")
		echo "command use list:"
		echo "		./upgrade.sh --do all update"
		echo "		./upgrade.sh allforce --do all module update and use socflash for BMC if necessary"
		echo "		./upgrade.sh vercheck  --compare system version with update package file version"
		echo "		./upgrade.sh bmc --bmc update with version check"
		echo "		./upgrade.sh bmcforce --do bmc update and use soc if necessary"
		echo "		./upgrade.sh ses --do SES update "
		echo "		./upgrade.sh ctlcpld --do ctl cpld update "
		echo "		./upgrade.sh esmcpld --do esm cpld update "
		echo "		./upgrade.sh bios --do bios update "
		echo "		./upgrade.sh bmc bios --do bmc bios update "
		echo "		./upgrade.sh all same --do all update and update module even version is same"
		echo "		./upgrade.sh allforce same --do all module update and use socflash for BMC if necessary even version is same"
		echo "		./upgrade.sh bmc same --do bmc update and update bmc even version is same"
		echo "		./upgrade.sh ses same --do bmc update and update ses even version is same"
		echo "		./upgrade.sh soc --do bmc update without configuration save, this should use only when BMC can't work "
		echo "		nopltfm option used to ignore platform check. For exg. ./upgrade.sh all nopltfm "
		echo "		noverlimit option used to ignore FW version limit check. For exg. ./upgrade.sh all noverlimit "
		echo "		./upgrade.sh -v show version of script"
		return 1
		;;
		"")
		bmc_upgrade_flag="on"
		bios_upgrade_flag="on"
		ses_upgrade_flag="on"
		ctl_cpld_upgrade_flag="on"
		esm_cpld_upgrade_flag="on"
		;;
		"NOPLTFM")
		check_pltfm_flag="off"
		;;
		"NOVERLIMIT")
		check_versionlimit_flag="off"
		;;
		*)
		print_log "Some error input parameters and quit!!!"
		return 1
		;;
	esac
	return 0
}

function get_FW_version()
{
        #check BMC
        get_BMC_version
		[[ $? -eq 0 ]] || {
			log_only "get BMC version error!"
			return 1
		}
		
        #check BIOS
        get_BIOS_version
		[[ $? -eq 0 ]] || {
			log_only "get BIOS version error!"
			return 1
		}
		
		#check SES
		get_ses_version
		[[ $? -eq 0 ]] || {
			log_only "get SES version error!"
			return 1
		}

       		#check CTL CPLD
        	get_ctl_cpld_version
		[[ $? -eq 0 ]] || {
			log_only "get cpld version error!"
			return 1
		}

		#check ESM CPLD
        	get_esm_cpld_version
		[[ $? -eq 0 ]] || {
			log_only "get cpld version error!"
			return 1
		}
		
	print_log  "Version of FW now running in system: "
        print_log  "BMC main ver is:$bmc_pri_now"
        print_log  "BMC bkup ver is:$bmc_bkp_now"
        print_log  "BIOS ver is:$bios_ver"
        print_log  "SES ver is:$ses_ver"
        print_log  "CTL CPLD ver is:$ctl_cpld_ver"
        print_log  "ESM CPLD ver is:$esm_cpld_ver"
        
		return 0
}

function compare_FW_version()
{
		local return_flag=
		
        #compare version
         if [ "$bmc_pri_now" != "$__BMC_IMG_VER" ];
         then
		 	return_flag="false"
            print_log "BMC Primary update fail,target to update to version:$__BMC_IMG_VER, now running version $bmc_pri_now!"
		else
			print_log "BMC Primary chip running FW version $bmc_pri_now is same as the update file image version,update successfully. "
		fi
		
        if [ "$bmc_bkp_now" != "$__BMC_IMG_VER" ];
        then
           	return_flag="false"
            print_log "BMC Secondary update fail,target to update to version:$__BMC_IMG_VER, now running version $bmc_bkp_now!"
        else
			print_log "BMC Secondary chip running FW version $bmc_bkp_now is same as the update file image version,update successfully. "
		fi
        
        if [ "$bios_ver" != "$__BIOS_IMG_VER" ];
         then
            return_flag="false"
            print_log "BIOS update fail,target to update to version:$__BIOS_IMG_VER, now running version: $bios_ver!"
    	else
			print_log "BIOS  chip running FW version $bios_ver is same as the update file image version,update successfully. "
		fi
        
		if [ "$ses_ver" != "$__SES_IMG_VER" ];
		then
			return_flag="false"
			print_log "SES update fail,target to update to version:$__SES_IMG_VER, now running version: $ses_ver!"
		else
			print_log "SES  chip running FW version $ses_ver is same as the update file image version,update successfully. "
		fi
        
		if [ "$ctl_cpld_ver" != "$__CTL_CPLD_IMG_VER" ]  
		then
			return_flag="false"
			print_log "CTL CPLD update fail,target to update to version:$__CTL_CPLD_IMG_VER, now running version: $ctl_cpld_ver!"
		else
			print_log "CTL CPLD  chip running FW version $ctl_cpld_ver is same as the update file image version,update successfully. "
		fi

		if [ "$esm_cpld_ver" != "$__ESM_CPLD_IMG_VER" ]  
		then
			return_flag="false"
			print_log "ESM CPLD update fail,target to update to version:$__ESM_CPLD_IMG_VER, now running version: $ESM_cpld_ver!"
		else
			print_log "ESM CPLD  chip running FW version $esm_cpld_ver is same as the update file image version,update successfully. "
		fi
        
		if [ "$return_flag" != "false" ]
		then
			print_log "All FW version are same as target to update FW version, Update successfully!"
			return 0
		else 
			return 1
		fi
}

function check_version()
{
	get_FW_version
	[[ $? -eq 0 ]] || {
		log_only "get version error!"
		return 1
	}
	compare_FW_version
	[[ $? -eq 0 ]] || {
		log_only "version compare fail!"
		print_log "FW version of running is not same as FW image to update!!!"
		return 1
	}
	return 0
}

function analyze_ipmitool()
{
	for i in $@; do
    # echo $i
	if [ "$i"  = "failed"  ] 
	then 
		print_log "BMC is not ready, please run upgrade script after 5 minutes. If it still can't work,please power cycle it!!!"
		return 1
	fi
	if [ "$i"  = "Invalid"  ] 
	then 
		print_log "BMC is not ready, please run upgrade script after 5 minutes. If it still can't work,please power cycle it!!!"
		return 1
	fi
	if [ "$i"  = "Get"  ] 
	then 
		print_log "BMC is not ready, please run upgrade script after 5 minutes. If it still can't work,please power cycle it!!!"
		return 1
	fi
	
	done
	# print_log "BMC is not ready, please run upgrade script after 5 minutes. If it still can't work,please power cycle it!!!"
		
	return 0

}

function anaylyze_ipmi_init()
{


	for i in $@; do
    # echo $i
	if [ "$i"  = "RAW"  ] 
	then 
		print_log "BMC is not ready, please run upgrade script after 5 minutes"
		return 1
	fi
	if [ "$i"  = "found"  ] 
	then 
		print_log "Ipmitool not found, please install it or use setuptool.sh to install it."
		return 1
	fi
	
	done
	# print_log "BMC is not ready, please run upgrade script after 5 minutes"
	return 0
}

#mount ipmi driver
function ipmi_init()
{
	local cmd=
	local cmd_report=

	#chmod app
	print_log  "======================== init ipmi ======================="
	cmd="chmod a+x ${__BMC_PATH}CFUFLASH "
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "${__BMC_PATH}CFUFLASH permission modificaiton fail, please chmod a+x ${__BMC_PATH}CFUFLASH by root authority!"
		return 1
	}
	log_only "RESULT:${cmd_report}"


	cmd="modprobe ipmi_devintf"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "There is some problems in installing ipmi driver ipmi_devintf."
		print_log "Retry after 5 minutes, power cycle if it doesn't work."
		return 2
	}
	log_only "RESULT:${cmd_report}"

	cmd="modprobe ipmi_si"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "There is some problems in installing ipmi driver ipmi_si."
		print_log "Retry after 5 minutes, power cycle if it doesn't work."
		
		return 3
	}
	log_only "RESULT:${cmd_report}"

	cmd="modprobe ipmi_msghandler"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "There is some problems in installing ipmi driver ipmi_msghandler."
		print_log "Retry after 5 minutes, power cycle if it doesn't work."
		
		return 4
	}
	log_only "RESULT:${cmd_rleport}"

#print ipmi command available
	cmd='lsmod|grep ipmi'
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"
		print_log "Please make sure ipmitool installed. You can install it by using setuptool.sh"
		return 5
	}
	log_only "RESULT:${cmd_report}"

	cmd="ipmitool raw 6 1"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!, ipimtool is abnormal!"
		log_only "RESULT:${cmd_report}"
		anaylyze_ipmi_init ${cmd_report}
		return 6
	}
	log_only "RESULT:${cmd_report}"
	analyze_ipmitool ${cmd_report}
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!, BMC is not ready please retry after 5 minutes!"
		return 7
	}
	return 0
}

# print the least FW version 
function print_least_FW_version()
{
	print_log "Not compatible FW version has potential risk, it may cause update FW failure!!"
	print_log "Please use FW Package $__COMPATIBLE_PACKAGE_VERSION to update first!!!"
	print_log "Including BMC version: ${__BMC_VERSION_VECTOR[0]}"
	print_log "Including BIOS version: ${__BIOS_VERSION_VECTOR[0]}"
	print_log "Including SES version: ${__SES_VERSION_VECTOR[0]}"
	print_log "Including CPLD version: ${__CTL_CPLD_VERSION_VECTOR[0]}"
	print_log "Including CPLD version: ${__ESM_CPLD_VERSION_VECTOR[0]}"
	print_log "You can also append parameter: 'noverlimit' to ignore this if you insist updating"
	print_log "For example ./upgrade.sh all noverlimit to pass this check!!!"
}

function upgrade_version_limit_check()
{
	get_FW_version
	[[ $? -eq 0 ]] || {
		log_only "get version error!"
		return 1
	}
	for tmpj in {0..3}
	do
		 upgrade_ver_check_vectorelement $tmpj
		if [ $? -eq 0 ]
		then
			return 0
		fi
	done
	
	print_least_FW_version
	return 2
}

function platfm_check()
{
	#get BIOS version
	
    get_BIOS_version
	[[ $? -eq 0 ]] || {
		print_log "get BIOS version error!"
		return 1
	}
	#grep key word
	cmd="echo $bios_ver | grep $__PLTFM_ID"
    cmd_report=`eval ${cmd} 2>&1`
    [[ $? -eq 0 ]] || {
        log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only  "RESULT: ${cmd_report}"
		return 2
    }
	return 0
}

function upgrade_ver_check_vectorelement()
{

	# get BMC version vector
	# check BMC
	#print_log "upgrade_ver_check_vectorelement $1"
	
		if [ "$bmc_pri_now" != ${__BMC_VERSION_VECTOR[$1]} ]
        then
		 	return 1
		fi

		if [ "$bmc_bkp_now" != ${__BMC_VERSION_VECTOR[$1]} ]
				then
					return 1
				fi
		if [ "$bios_ver" != ${__BIOS_VERSION_VECTOR[$1]} ]
				then
					return 1
				fi

		if [ "$ses_ver" != ${__SES_VERSION_VECTOR[$1]} ]
				then
					return 1
				fi

		if [ "$ctl_cpld_ver" != ${__CTL_CPLD_VERSION_VECTOR[$1]} ]
				then
					return 1
				fi
		if [ "$esm_cpld_ver" != ${__ESM _CPLD_VERSION_VECTOR[$1]} ]
				then
					return 1
				fi

	return 0
}

# updateBMCwithsoc
# use soc without ipmitool command
function updateBMCwithsoc()
{
	local filename=$1
	local chipnum=$2
	local bmcchip=$3
	
	log_only "socflash chip $chipnum with file: $filename"
	cmd="uname -m|grep 64"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] get machine type FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		print_log "Can't detect OS machine type i686 or x86_64!!!"
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
		print_log "No 32bit socflash tool,quit!!!"
		return 2
	fi
	
	log_only "__SOC_FILE:$__SOC_FILE"
	cmd="chmod a+x $__SOC_FILE"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		print_log "$__SOC_FILE maybe not exist or permission change fail!!!"
		return 3
	}
	log_only "RESULT:${cmd_report}"
	
	#save config, this will not done here because BMC is not working.
	#soc it
	cmd="${__SOC_FILE} if=$filename cs=$chipnum"
	log_only "COMMAND:${cmd}"
	cmd_report=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
		log_only "RESULT:${cmd_report}"		
		return 4
	}
	log_only "RESULT:${cmd_report}"
	log_only "Flash Image-${bmcchip} OK. Please wait BMC reboot and activate!!!"
	if [ "${chipnum}" = "0" ]
	then
		print_log "Flash Flash-${chipnum}: BMC Primary Bank OK. Please wait BMC reboot and activate!!!"
	else
		print_log "Flash Flash-${chipnum}: BMC Secondary Bank OK. Please wait BMC reboot and activate!!!"
	fi
	
	log_only "COMMAND:sleep 240"
	{
		for var1 in {1..4}
		do
		echo "Please waiting..."
		sleep 60
		done
	}
	return 0
}

function analyze_cfuflash()
{
	para=$1
	log_only "para is $para"

	for i in $@; do
    # echo $i
	if [ "$i"  = "Flasher"  ] 
	then 
		log_only "BMC is not ready, please run upgrade script after 5 minutes"
		echo "BMC is not ready, please run upgrade script after 5 minutes"
		return 0
	fi
	if [ "$i"  = "restarted"  ] 
	then 
		log_only "BMC is not ready, please run upgrade script after 5 minutes"
		echo "BMC is not ready, please run upgrade script after 5 minutes"
		return 0
	fi
	if [ "$i"  = "Permission"  ] 
	then 
		log_only "Tools permission is not ready, please use chmod a+x CFUFLASH"
		echo "Tools permission is not ready, please use chmod a+x CFUFLASH"
		return 0
	fi
	done
	# cmd="echo $para|grep -w Flasher"
	# cmd_report=`eval ${cmd} 2>&1`
	# [[ $? -eq 0 ]] || {
	# 		print_log "${cmd} no success"
	# 		return 1
	# }
	# if [ "${cmd_report}" != ""  ] 
	# then 
	# 	print_log "BMC is not ready, please run upgrade script after 2 minutes"
	# fi

	return 0
}

#save lan 1 and lan 8 MAC
function bmc_save_lancfg()
{
	# get LAN1
	cmd="ipmitool lan print 1|grep 'MAC'"
	log_only "COMMAND Check:${cmd}"
	lan1cfg=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${lan1cfg} FAIL!!!"

	}
    log_only "RESULT: lan1 cfg is $lan1cfg"
	lan1_MAC=""
	cmd="decode_LAN $lan1cfg"
	log_only "COMMAND Check:${cmd}"
	lan1_MAC=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "decode_LAN lan1_MAC FAIL!!!"
		lan1_MAC=""
	}
    log_only "RESULT: lan1 lan1_MAC is $lan1_MAC"

	# get LAN 8
	cmd="ipmitool lan print 8|grep 'MAC'"
	log_only "COMMAND Check:${cmd}"
	lan8cfg=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "$[$FUNCNAME] ${lan8cfg} FAIL!!!"
		
	}
    log_only "RESULT: lan8 cfg is $lan8cfg"
	lan8_MAC=""
	cmd="decode_LAN $lan8cfg"
	log_only "COMMAND Check:${cmd}"
	lan8_MAC=`eval ${cmd} 2>&1`
	[[ $? -eq 0 ]] || {
		log_only "decode_LAN lan8_MAC FAIL!!!"
		lan8_MAC=""
	}
    log_only "RESULT: lan8 lan8_MAC is $lan8_MAC"
	return 0
}

function decode_LAN()
{
	local tmpMAC=
	inputp="$*"
		
	if [ "$inputp" != "" ]
	then
		for tmpi in {2..7}
		do
			cmd="echo $inputp|cut -d ':' -f $tmpi |grep -o '[^ ]\+\(\+[^ ]\+\)*'"
			cmd_report=`eval ${cmd} 2>&1`
			if [ $? -eq 0 ] 
			then
				tmpMAC="$tmpMAC 0x$cmd_report"
			else
				log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
				log_only "RESULT: $cmd_report"
				return 1
			fi

		done
		# log_only "MAC is $tmpMAC"
		#log_only "$tmpMAC"
		echo $tmpMAC
		return 0
	else
		return 1
	fi
}

#restore lan 1 and lan 8 MAC
function bmc_restore_lancfg()
{
	local set_mac_flag=""
	# restore LAN 1
	if [ "$lan1_MAC" != "" ]
	then
		cmd="ipmitool raw 0xc 1 1 0xc2 0"	#eth0
		log_only "COMMAND Check:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		if [ $? -eq 0 ]  
		then 
			log_only "RESULT: ${cmd_report}"
			for loopcnt in {1..3}
			do
				sleep 40
				cmd1="ipmitool raw 0xc 1 1 0x5 $lan1_MAC"
				log_only "COMMAND Check:${cmd1}"
				cmd_report1=`eval ${cmd1} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only  "$[$FUNCNAME] ${cmd1} FAIL!!!"
					log_only  "RESULT:${cmd_report1}"
					continue
				}
				set_mac_flag="ok"
				break
			done
			log_only  "RESULT:${cmd_report1}"
			if [ "$set_mac_flag" != "ok" ]
			then
				print_log "Some Issue in config BMC Lan 1 MAC, please check it."
			fi
		else
			log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only  "RESULT:${cmd_report}"
		fi		
	else
		print_log  "BMC LAN1 is no value!!!"	
    	print_log "Please check it."
	fi
	# restore LAN 8
	set_mac_flag=""
	if [ "$lan8_MAC" != "" ]
	then
		cmd="ipmitool raw 0xc 1 8 0xc2 1"  #eth1
		log_only "COMMAND Check:${cmd}"
		cmd_report=`eval ${cmd} 2>&1`
		if [ $? -eq 0 ]  
		then 
			log_only "RESULT: ${cmd_report}"
			for loopcnt in {1..3}
			do
				sleep 40
				cmd1="ipmitool raw 0xc 1 8 0x5 $lan8_MAC"
				log_only "COMMAND Check:${cmd1}"
				cmd_report1=`eval ${cmd1} 2>&1`
				[[ $? -eq 0 ]] || {
					log_only  "$[$FUNCNAME] ${cmd1} FAIL!!!"
					log_only  "RESULT:${cmd_report1}"
					continue
					
				}
				set_mac_flag="ok"
				break
			done
			log_only  "RESULT:${cmd_report1}"
			if [ "$set_mac_flag" != "ok" ]
			then
				print_log "Some Issue in config BMC Lan 8 MAC, please check it."
			fi
		else
			log_only  "$[$FUNCNAME] ${cmd} FAIL!!!"
			log_only  "RESULT:${cmd_report}"
		fi		
		
    else
		print_log  "BMC LAN8 is no value!!!"
		print_log "Please check it."
	fi
}

function get_driver_path()
{
	
	log_only "COMMAND:get_os_type"
	get_os_type
	[[ $? -eq 0 ]] || {
		log_only "get_driver_path get_os_type FAIL!!!"
		return 1
	}
	log_only "RESULT:get_os_type"
	
	
	log_only "COMMAND:get_kernel_version"
	get_kernel_version
	[[ $? -eq 0 ]] || {
		log_only "get_driver_path] get_kernel_version FAIL!!!"
		return 1
	}
	log_only "RESULT:get_kernel_version"
}

#this function get os kernel version
function get_kernel_version()
{
    
	cmd="uname -r|cut -d '-' -f 1"
	log_only "COMMAND:${cmd}"
	knl_version=`eval ${cmd} 2>&1`

    if [ $? -ne 0 ]
    then
        log_only "$[$FUNCNAME] ${cmd} FAIL!!!"
        log_only "RESULT:${knl_version}"
		return 1
    fi
   
	glb_knl_version="$knl_version"
	log_only "RESULT:${knl_version}"
    return 0
}

#this function get os type eg. centos ubuntu redhat
function get_os_type()
{

	cmd="cat /proc/version | grep  Ubuntu "
	log_only "COMMAND:${cmd}"
	rest=`eval ${cmd} 2>&1`

    if [ $? -eq 0 ]
    then
		os_version="Ubuntu"
        log_only "RESULT:${rest}"
		glb_os_version="$os_version"
		log_only "os type is $glb_os_version"
		return 0
    fi
    
	cmd="cat /proc/version | grep  Red "
	log_only "COMMAND:${cmd}"
	rest=`eval ${cmd} 2>&1`

    if [ $? -eq 0 ]
    then
		os_version="Redhat"
        log_only "RESULT:${rest}"
		glb_os_version="$os_version"
		log_only "os type is $glb_os_version"
		return 0
    fi
    
	glb_os_version="not found"
	log_only "RESULT:${glb_os_version}"
    return 1
}

# trap sigint 2 to avoid mistake ctrl c
trap "proc_SIGINT" SIGINT
function proc_SIGINT()
{
	log_only "User send ctrl+C,Get SIGINT,force to quit upgrade.sh !!!"
	exit 1
	# trap SIGINT #quit trap sigint
}

