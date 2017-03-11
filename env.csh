#!/bin/csh -f

####################################################################################
## Copyright (c) 2016, University of British Columbia (UBC)  All rights reserved. ##
##                                                                                ##
## Redistribution  and  use  in  source   and  binary  forms,   with  or  without ##
## modification,  are permitted  provided that  the following conditions are met: ##
##   * Redistributions   of  source   code  must  retain   the   above  copyright ##
##     notice,  this   list   of   conditions   and   the  following  disclaimer. ##
##   * Redistributions  in  binary  form  must  reproduce  the  above   copyright ##
##     notice, this  list  of  conditions  and the  following  disclaimer in  the ##
##     documentation and/or  other  materials  provided  with  the  distribution. ##
##   * Neither the name of the University of British Columbia (UBC) nor the names ##
##     of   its   contributors  may  be  used  to  endorse  or   promote products ##
##     derived from  this  software without  specific  prior  written permission. ##
##                                                                                ##
## THIS  SOFTWARE IS  PROVIDED  BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" ##
## AND  ANY EXPRESS  OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO,  THE ##
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE ##
## DISCLAIMED.  IN NO  EVENT SHALL University of British Columbia (UBC) BE LIABLE ##
## FOR ANY DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL ##
## DAMAGES  (INCLUDING,  BUT NOT LIMITED TO,  PROCUREMENT OF  SUBSTITUTE GOODS OR ##
## SERVICES;  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER ##
## CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT LIABILITY, ##
## OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE ##
## OF  THIS SOFTWARE,  EVEN  IF  ADVISED  OF  THE  POSSIBILITY  OF  SUCH  DAMAGE. ##
####################################################################################

####################################################################################
##  Defines Design and  Environment Variables and Setup ASIC Synthesis CAD Tools  ##
##             Author: Ameer Abdelhadi (ameer.abdelhadi@gmail.com)                ##
## Cell-based interleaved FIFO :: The University of British Columbia :: Nov. 2016 ##
####################################################################################

####################################################################################
## define environment variables and output library locations; change if necessary ##
####################################################################################

# useXterm: enable to use xterm for each design flow operation;
#           will dump to same console if disabled; enable if no graphics available
# RUNDIR  : RUN directory
# SCRDIR  : scripts directory
# RTLDIR  : RTL directory
# DOCDIR  : Documentation directory
# REPDIR  : design reports directory
# LOGDIR  : run logs directory
# SIMDIR  : logic simulation related files
# STADIR  : Static Timing Analysis (STA) related files
# RCEDIR  : RC extraction related files directory
# CTSDIR  : Clock Tree Synthesis (CTS) related files
# ECODIR  : ECO (design changes in p&r) related files
# ENCDIR  : SoC Encounter related files
# GDSDIR  : generated GDS directory
# NETDIR  : netlists directory
# PWRDIR  : power estimates directory

setenv useXterm  0
setenv RUNDIR $PWD
setenv SCRDIR $RUNDIR/scr
setenv RTLDIR $RUNDIR/rtl
setenv DOCDIR $RUNDIR/doc
setenv REPDIR $RUNDIR/rep
setenv LOGDIR $RUNDIR/log
setenv NETDIR $RUNDIR/net
setenv ENCDIR $RUNDIR/enc
setenv STADIR $RUNDIR/sta
setenv CTSDIR $RUNDIR/cts
setenv ECODIR $RUNDIR/eco
setenv RCEDIR $RUNDIR/rce
setenv GDSDIR $RUNDIR/gds
setenv SIMDIR $RUNDIR/sim
setenv PWRDIR $RUNDIR/pwr

####################################################################################
## define synthesis and simulation variables; change if necessary                 ##
####################################################################################

# CLKDSYNFRQSCL: synthesis frquency scale for clocked design
# ASYNSYNFRQSCL: synthesis frquency scale for asynchronous design
# SIMPUTPERSCL : simulation put clock period scale
# SIMGETPERSCL : simulation get clock period scale
# SIMPUTDTYCYC : simulation put clock duty-cycle
# SIMGETDTYCYC : simulation get clock duty-cycle
# SIMDATALN    : simulation data stream length
# SYNCDP       : brute-force synchronizer depth

setenv CLKDSYNFRQSCL 1.4
setenv ASYNSYNFRQSCL 1
setenv SIMPUTPERSCL  1
setenv SIMGETPERSCL  1
setenv SIMPUTDTYCYC  0.5
setenv SIMGETDTYCYC  0.5
setenv SIMDATALN     1000
#setenv SYNCDP        3

####################################################################################
## clean unrequired files after run; disable if necessary                         ##
####################################################################################

# clnVCD   : clean .vcd files (VCD) from SIM directory
# clnNET   : clean NET (schematic) directory
# clnRCE   : clean RCE directory
# clnSTASDF: clean .sdf files (SDF) from STA directory
# clnSTAREP: clean .rep files (reports) from STA directory
# clnENC   : clean ENC directory
# clnCTS   : clean CTS directory
# clnRUNDIR: clean run directory

setenv clnVCD    0
setenv clnNET    0
setenv clnRCE    0
setenv clnSTASDF 0
setenv clnSTAREP 0
setenv clnENC    0
setenv clnCTS    0
setenv clnRUNDIR 1

####################################################################################
# local switches                                                                  ##
####################################################################################

# useXterm  : Use external xterm to execute runs
# runMatlab : Run Matlab after run, export results from res.csv and generate plots

setenv useXterm  0
setenv runMatlab 0

####################################################################################
## define library design kit variables; change to your own design kit if necessary #
####################################################################################

# TSMC65: library base link
# LIBNAM: library name
# LIBCOR: library corner, wc: worst case, tc: typical case, bc: best case
# LIBDBB: library DBB database link
# LIBLEF: a link to library LEF files
# LIBGDS: a link to library GDS files
# LIBVRL: a link to library Verilog files

#setenv LIBNAM tcbn65lp
 setenv LIBNAM tcbn65gplus
#setenv LIBNUM 200a
 setenv LIBNUM 140b
 setenv LIBCOR wc

 setenv TSMC65  /CMC/kits/tsmc_65nm_libs/$LIBNAM/TSMCHOME/digital/
 setenv LIBDBB $TSMC65/Front_End/timing_power_noise/NLDM/${LIBNAM}_${LIBNUM}/
 setenv LIBLEF $TSMC65/Back_End/lef/${LIBNAM}_200a/lef/
 setenv LIBGDS $TSMC65/Back_End/gds/${LIBNAM}_${LIBNUM}/
 setenv LIBVRL $TSMC65/Front_End/verilog/${LIBNAM}_${LIBNUM}
 setenv LIBSPI $TSMC65/Back_End/spice/${LIBNAM}_200a/${LIBNAM}_200a.spi
 setenv LIBMLW $TSMC65/Back_End/milkyway/${LIBNAM}_200a/

####################################################################################
## setup Synopsys tools; change to your own flow if necessary                     ##
####################################################################################

# unset variable to enable sourcing tools setup scripts
unsetenv CMC_SNPS_SOURCED
unsetenv CMC_SOURCED

# Synopsys DC for logic synthesis (run: dc_shell-xg-t)
source /CMC/scripts/synopsys.icc.2011-SP1.csh
setenv SYNOPSYS /CMC/tools/synopsys/syn_vF-2011.09-SP4
setenv SYNOPS $SYNOPSYS

# Synopsys PrimeTime for static timing analysis (run: pt_shell)
setenv CMC_SNPS_PT_ARCH $CMC_SNPS_ARCH
setenv PATH ${CMC_HOME}/tools/synopsys/pts_vD-2010.06-SP2/${CMC_SNPS_PT_ARCH}/syn/bin:${PATH}

# Synopsys VCS-MX for waveform viewing (run: dve)
setenv CMC_SNPS_VCS_ARCH $CMC_SNPS_ARCH2
setenv VCS_HOME $CMC_HOME/tools/synopsys/vcs-mx_vD-2010.06
setenv PATH ${VCS_HOME}/bin:${PATH}

####################################################################################
## setup Cadence tools; change to your own flow if necessary                      ##
####################################################################################

# Cadence SoC Encouter for place and route (run: encounter)
 source /CMC/scripts/cadence.edi09.12.000.csh

# Cadence NC-SIM for gate-level simulation (run:ncverilog)
source /CMC/scripts/cadence.ius08.20.024.csh

