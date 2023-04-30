https://docs.vmware.com/en/VMware-Greenplum/6/greenplum-database/install_guide-prep_os.html

1) SELinux                                       # Need to check how it can be set it in tuned

2) Firewalld                                     # Set it in sysctl.conf and need to check if it works

3) Shared Memory                                 # Set it in sysctl.conf and need to check if it works
~~~
vm.overcommit_memory = 2 # See Segment Host Memory
vm.overcommit_ratio = 95 # See Segment Host Memory
~~~

4) Segment Host Memory
~~~
Segment Host Memory
The vm.overcommit_memory Linux kernel parameter is used by the OS to determine how much memory can be allocated to processes. For Greenplum Database, this parameter should always be set to 2.
vm.overcommit_ratio is the percent of RAM that is used for application processes and the remainder is reserved for the operating system. The default is 50 on Red Hat Enterprise Linux.
For vm.overcommit_ratio tuning and calculation recommendations with resource group-based resource management or resource queue-based resource management, refer to Options for Configuring Segment Host Memory in the Geenplum Database Administrator Guide.
~~~

5) Network

6) User Limits                                   #

7) The sysctl.conf                               # Set it in tuned.conf

8) IP Fragment Settings
~~~
When the Greenplum Database interconnect uses UDP (the default),
the network interface card controls IP packet fragmentation and reassemblies.
If the UDP message size is larger than the size of the maximum transmission unit (MTU) of a network,
the IP layer fragments the message.
(Refer to Networking later in this topic for more information about MTU sizes for Greenplum Database.)
The receiver must store the fragments in a buffer before it can reorganize and reassemble the message.
The following sysctl.conf operating system parameters control the reassembly process:

OS Parameter	Description
net.ipv4.ipfrag_high_thresh
 - The maximum amount of memory used to reassemble IP fragments
   before the kernel starts to remove fragments to free up resources.
   The default value is 4194304 bytes (4MB).
net.ipv4.ipfrag_low_thresh
 - The minimum amount of memory used to reassemble IP fragments.
   The default value is 3145728 bytes (3MB). (Deprecated after kernel version 4.17.)
net.ipv4.ipfrag_time
 - The maximum amount of time (in seconds) to keep an IP fragment in memory.
   The default value is 30.

The recommended settings for these parameters for Greenplum Database follow:
net.ipv4.ipfrag_high_thresh = 41943040
net.ipv4.ipfrag_low_thresh = 31457280
net.ipv4.ipfrag_time = 60
~~~

9) System Memory
~~~
For host systems with more than 64GB of memory, these settings are recommended:
vm.dirty_background_ratio = 0
vm.dirty_ratio = 0
vm.dirty_background_bytes = 1610612736 # 1.5GB
vm.dirty_bytes = 4294967296 # 4GB

For host systems with 64GB of memory or less, remove vm.dirty_background_bytes
and vm.dirty_bytes and set the two ratio parameters to these values:
vm.dirty_background_ratio = 3
vm.dirty_ratio = 10

Increase vm.min_free_kbytes to ensure PF_MEMALLOC requests from network and storage drivers are easily satisfied.
This is especially critical on systems with large amounts of system memory.
The default value is often far too low on these systems.
Use this awk command to set vm.min_free_kbytes to a recommended 3% of system physical memory:
$ awk 'BEGIN {OFMT = "%.0f";} /MemTotal/ {print "vm.min_free_kbytes =", $2 * .03;}'
/proc/meminfo >> /etc/sysctl.conf 

Do not set vm.min_free_kbytes to higher than 5% of system memory as doing so might cause out of memory conditions.
~~~

10) System Resources Limits                       # need to check how it can be set

11) Core Dump                                     # Set it in sysctl.conf and ulimit.conf

12) XFS Mount Options                             # Need to check how can get info and set it

13) Disk I/O Settings                            # Need to check how can get info and set it

14) Disk I/O scheduler                           # Set it in tuned.conf and need to check if it works

15) Networking                                   # Need to check how can get info and set it
~~~
The maximum transmission unit (MTU) of a network specifies the size (in bytes) of the largest data packet/frame accepted by a network-connected device. A jumbo frame is a frame that contains more than the standard MTU of 1500 bytes.
Greenplum Database utilizes 3 distinct MTU settings:
The Greenplum Database gp_max_packet_size server configuration parameter. The default max packet size is 8192. This default assumes a jumbo frame MTU.
The operating system MTU setting.
The rack switch MTU setting.
These settings are connected, in that they should always be either the same, or close to the same, value, or otherwise in the order of Greenplum < OS < switch for MTU size.
9000 is a common supported setting for switches, and is the recommended OS and rack switch MTU setting for your Greenplum Database hosts.
~~~

16) Transparent Huge Pages (THP)                     # Set it in tuned.conf and need to check if it works

17) IPC Object Removal                               # Ignore it since RHEL6 would be no longer used for GPDB 4.x or 5.x

18) SSH Connection Threshold                         # Set sshd.conf and need to check if it works

19) Synchronizing System Clocks                      # Set Crony and need to check if it works

20) Creating the Greenplum Administrative User       # Created script and need to check if it works
