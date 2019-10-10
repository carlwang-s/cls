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
# @file upgrade_global_val.sh
#
SCRIPT_VER="4.0.1" 
__STRESS_PATH=

__BMC_IMAGE="${__STRESS_PATH}FW_images/BMC/${__BMC_IMGAE_NAME}"
__BIOS_IMAGE="${__STRESS_PATH}FW_images/BIOS/${__BIOS_IMAGE_NAME}"
#__SES_CFG_IMAGE="${__STRESS_PATH}FW_images/SES/${__SES_CFG_NAME}"
__SES_OSA_IMAGE="${__STRESS_PATH}FW_images/SES/${__SES_OSA_NAME}"
__CTL_CPLD_IMAGE="${__STRESS_PATH}FW_images/CPLD/${__CTL_CPLD_IMAGE_NAME}"
__ESM_CPLD_IMAGE="${__STRESS_PATH}FW_images/CPLD/${__ESM_CPLD_IMAGE_NAME}"
__BMC_PATH="${__STRESS_PATH}BMC_tool/${__BMC_TOOL_NAME}"
__VERSION_CTL_FILE="${__STRESS_PATH}Scripts/upgrade_version.sh"

__SOC_X64_FILE="${__STRESS_PATH}BMC_tool/SOC/socflash_x64"
__SOC_32_FILE="${__STRESS_PATH}BMC_tool/SOC/"

__SOC_FILE=
############## define global variable #############################
bmc_key_ver=
bmc_high_edge=
bmc_low_edge=
cmd_report_bmc=
lan1_MAC=
lan8_MAC=
bmc_pri_maj=
bmc_pri_min=
bmc_bkp_maj=
bmc_bkp_min=
bmc_pri_now=
bmc_bkp_now=
bmc_chip_now=
bmc_upgrade_next=
bios_ver=
ses_ver=
ctl_cpld_ver=
ctl_cpld_vermaj=
ctl_cpld_vermin=
cpld_verleast=
esm_cpld_ver=
bmc_upgrade_limit=
glb_os_version=
glb_knl_version=


IPMI_CMD_GET_PRIMARY_BMC_VER="ipmitool raw 0x32 0x8f 0x08 0x01"
IPMI_CMD_GET_BACKUP_BMC_VER="ipmitool raw 0x32 0x8f 0x08 0x02"
BMC_MAJOR_VERSION_PRIMARY="$IPMI_CMD_GET_PRIMARY_BMC_VER |cut -d ' ' -f 2"
BMC_MINOR_VERSION_PRIMARY="$IPMI_CMD_GET_PRIMARY_BMC_VER |cut -d ' ' -f 3"
BMC_MAJOR_VERSION_BACKUP="$IPMI_CMD_GET_BACKUP_BMC_VER |cut -d ' ' -f 2"
BMC_MINOR_VERSION_BACKUP="$IPMI_CMD_GET_BACKUP_BMC_VER |cut -d ' ' -f 3"

#flag to set operation mode
#do bmc version check before upgrade
# bmc_check_flag=
#ver_check check version and return
ver_check_flag=

bmc_upgrade_flag=
bios_upgrade_flag=
ses_upgrade_flag=
ctl_cpld_upgrade_flag=
esm_cpld_upgrade_flag=
soc_bmc_flag=
same_up_flag=			#this flag will upgrade same version
use_soc_flag=
second_bmc_update=
check_pltfm_flag=
check_versionlimit_flag=
