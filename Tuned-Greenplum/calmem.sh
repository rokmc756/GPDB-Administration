#!/bin/bash
#
#
# VMware Tanzu Support, 
# Staff Product Support Engineer, moonja@vmware.com
# 25, Apr 2023

master_host="rk8-master"

total_swap=$(scale=10; echo "$(grep '^SwapTotal' /proc/meminfo | awk '{print $2}') * 1024" | bc )
total_ram=$(scale=10; echo "$(grep '^MemTotal' /proc/meminfo | awk '{print $2}') * 1024" | bc )
sum_total_swap_ram=$(scale=10; echo "$total_swap + $total_ram" | bc )

enable_rg=$(su - gpadmin -c "ssh gpadmin@$master_host \
'source /usr/local/greenplum-db/greenplum_path.sh && gpconfig -s gp_resource_manager | grep group | grep -v grep | wc -l'")

cal_gp_vmem_rq () {

    const_mem=$(scale=10; echo "7.5 * 1024 * 1024 * 1024" | bc )
    _total_ram=$(scale=10; echo "0.05 * $total_ram" | bc)
    _const_mem=$(scale=10; echo "$const_mem + $_total_ram" | bc)

    if [ $total_ram -gt $(( 256 * 1024 * 1024 * 1024 )) ]; then
        gp_vmem_rq=$(scale=10; echo "$sum_total_swap_ram - $( scale=10; echo "$_const_mem  / 1.17" | bc )" | bc )
        # echo "total_ram is greater than 256G"
    elif [ $total_ram -lt $(( 256 * 1024 * 1024 * 1024 )) ]; then
        gp_vmem_rq=$(scale=10; echo "$sum_total_swap_ram - $( scale=10; echo "$_const_mem  / 1.17" | bc )" | bc )
        # echo "total_ram is less that 256G"
    else
        echo "Exception"
        exit 1
    fi
    
    echo $gp_vmem_rq
    # return $gp_vmem_rq
}

cal_overcommit_ratio() {

    gp_vmem_rq=$( cal_gp_vmem_rq )
    # echo $gp_vmem_rq

    _seg_overcommit_ratio=$(scale=10; echo "$total_ram - $(scale=10; echo "0.026 * $gp_vmem_rq" | bc )" | bc )
    # echo $_seg_overcommit_ratio

    seg_overcommit_ratio=$(scale=10; echo "$_seg_overcommit_ratio / $total_ram" | bc )
    # echo $seg_overcommit_ratio

    # _seg_overcommit_ratio=$(scale=10; echo "0.026 * $gp_vmem_rq" | bc )
    # _seg_overcommit_ratio=$(scale=10; echo "$total_ram - $(scale=10; echo "0.026 * $gp_vmem_rq" | bc )" | bc )

    echo $seg_overcommit_ratio

}

if [ -z "$(pidof postgres)" ]; then

   # echo "It looks greenplum is not running"
   running_gpdb=false;
   cal_gp_vmem_rq $running_gpdb all

else

    # echo "It looks greenplum is now running"
    if [ ! -z "$(ps aux | grep postgres | grep -E 'master' | grep -v grep)" ]; then
        running_gpdb=true
        cal_gp_vmem_rq $running_gpdb master

    elif [ ! -z "$(ps aux | grep postgres | grep -E 'primary|mirror' | grep -v grep)" ]; then
        gpdb_segment=true
        cal_gp_vmem_rq $running_gpdb segment

    else
        running_gpdb=false
        echo "Both GPDB masters and segments are running unexpectedly now!"
        echo "Contact your GPDB administator to check whether the status is normal or not"
        exit 1
    fi

fi

cal_overcommit_ratio

