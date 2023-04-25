#!/bin/bash

. /usr/lib/tuned/functions

start() {
    # kernel.shmall = _PHYS_PAGES / 2 # See Shared Memory Pages
    # kernel.shmmax = kernel.shmall * PAGE_SIZE
    # sysctl -w kernel.shmall="$(expr $(getconf _PHYS_PAGES) / 2)"
    # sysctl -w kernel.shmmax="$(expr $(getconf _PHYS_PAGES) / 2 \* $(getconf PAGE_SIZE))"

    # To calculate a safe value for vm.overcommit_ratio when resource queue-based resource management is active,
    # irst determine the total memory available to Greenplum Database processes, gp_vmem_rq.
    # If the total system memory is less than 256 GB, use this formula:

    # gp_vmem_rq = ((SWAP + RAM) – (7.5GB + 0.05 * RAM)) / 1.7
    # If the total system memory is equal to or greater than 256 GB, use this formula:
    # gp_vmem_rq = ((SWAP + RAM) – (7.5GB + 0.05 * RAM)) / 1.17
    # where SWAP is the swap space on the host in GB, and RAM is the number of GB of RAM installed on the host.
    # When resource queue-based resource management is active, use gp_vmem_rq to calculate the vm.overcommit_ratio
    # value with this formula:
    # vm.overcommit_ratio = (RAM - 0.026 * gp_vmem_rq) / RAM

    # Increase vm.min_free_kbytes to ensure PF_MEMALLOC requests from network and storage drivers are easily satisfied.
    # This is especially critical on systems with large amounts of system memory. The default value is often far too low on these systems. Use this awk command to set vm.min_free_kbytes to a recommended 3% of system physical memory:
    # sysctl -w vm.min_free_kbytes=$(awk 'BEGIN {OFMT = "%.0f";} /MemTotal/ {print "", $2 * .03;}' /proc/meminfo)
    # echo $(awk 'BEGIN {OFMT = "%.0f";} /MemTotal/ {print "", $2 * .03;}' /proc/meminfo)

    # vm.overcommit_memory = 2 # See Segment Host Memory
    # vm.overcommit_ratio = 95 # See Segment Host Memory
    # net.ipv4.ip_local_port_range = 10000 65535 # See Port Settings
    # vm.dirty_background_ratio = 0 # See System Memory

    sysctl -p

    return "$?"

}

stop() {
    if [ "$1" = "full_rollback" ]
    then
        return "?"
        # teardown_kvm_mod_low_latency
        # enable_ksm
    fi
    return "$?"
}

process $@
