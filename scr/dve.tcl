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
##                   DVE Configuration to Show  VCD Waveform                      ##
##             Author: Ameer Abdelhadi (ameer.abdelhadi@gmail.com)                ##
## Cell-based interleaved FIFO :: The University of British Columbia :: Nov. 2016 ##
####################################################################################

global env

# define library design kit and synthesis tools variables
# Change these links to your own design kit location
#   TSMC65: library base link
#   LIBNAM: library name
#   LIBCOR: library corner, wc: worst case, tc: typical case, bc: best case
#   LIBDBB: library DBB database link
#   LIBLEF: a link to library LEF files
#   LIBGDS: a link to library GDS files
#   LIBVRL: a link to library Verilog files
#   SYNOPS: a link to Synopsys tools directory
#   TOPMOS: Verilog top module name
set TSMC65 $env(TSMC65)
set LIBNAM $env(LIBNAM)
set LIBCOR $env(LIBCOR)
set LIBDBB $env(LIBDBB)
set LIBLEF $env(LIBLEF)
set LIBGDS $env(LIBGDS)
set LIBVRL $env(LIBVRL)
set SYNOPS $env(SYNOPSYS)

# Design variables
#   VERSTG   : Number of vertical stages
#   HORSTG   : Number of horizontal stages
#   OPRFRQ   : Bus  clock frequency for place and route
#   STAGES   : Core clock frequency for place and route
#   DATAWD   : Bus  clock frequency for timing analysis
#   RUNNAM   : Current run name, used as prefix to file names
#   SYNFRQSCL: Core clock frequency for timing analysis
set VERSTG        $env(VERSTG)
set HORSTG        $env(HORSTG)
set DATAWD        $env(DATAWD)
set OPRFRQ        $env(OPRFRQ)
set RUNNAM        $env(RUNNAM)
set CLKDSYNFRQSCL $env(CLKDSYNFRQSCL)
set ASYNSYNFRQSCL $env(ASYNSYNFRQSCL)

# define environemt variables and output library locatiobs
#   RUNDIR: home directory
#   SCRDIR: scripts directory
#   RTLDIR: RTL directory
#   REPDIR: design reports directory
#   LOGDIR: run logs directory
#   SIMDIR: logic simulation related files
#   STADIR: Static Timing Analysis (STA) related files
#   RCEDIR: RC extraction related files directory
#   CTSDIR: Clock Tree Synthesis (CTS) related files
#   ECODIR: ECO (design changes in p&r) related files
#   ENCDIR: SoC Encounter related files
#   GDSDIR: generated GDS directory
#   NETDIR: netlists directory
#   PWRDIR: power estimates directory
set RUNDIR $env(RUNDIR)
set SCRDIR $env(SCRDIR)
set RTLDIR $env(RTLDIR)
set REPDIR $env(REPDIR)
set LOGDIR $env(LOGDIR)
set NETDIR $env(NETDIR)
set ENCDIR $env(ENCDIR)
set STADIR $env(STADIR)
set CTSDIR $env(CTSDIR)
set ECODIR $env(ECODIR)
set RCEDIR $env(RCEDIR)
set GDSDIR $env(GDSDIR)
set SIMDIR $env(SIMDIR)
set PWRDIR $env(PWRDIR)

# begin dve command
gui_close_window -window TopLevel.2
gui_open_db -file  $SIMDIR/${RUNNAM}.RND.vcd -design "$RUNNAM"
gui_list_select -id Hier.1 fifo_tb
gui_list_expand -id Hier.1 fifo_tb
gui_open_window Wave
gui_list_add -id Wave.1 -from Hier.1 -after {New Group} fifo_tb -insertionbar
gui_zoom -window Wave.1 -full

# Remove these signals from wavefrom
gui_list_select -id Wave.1 fifo_tb.PUTPH1
gui_list_select -id Wave.1 fifo_tb.PUTPH2
gui_list_select -id Wave.1 fifo_tb.GETPH1
gui_list_select -id Wave.1 fifo_tb.GETPH2
gui_list_select -id Wave.1 fifo_tb.TIMEOT
gui_delete_selected -id  Wave.1

# set decimal radix for several signals
gui_list_select -id Wave.1 fifo_tb.put_cnt
gui_list_select -id Wave.1 fifo_tb.get_cnt
gui_list_select -id Wave.1 fifo_tb.failure_cnt
gui_list_select -id Wave.1 fifo_tb.last_get_time
gui_list_set_selected_property -id Wave.1 -radix decimal

# Add these signals to waveform
## gui_list_add -id Wave.1 { signal4 } -insertionbar
## gui_list_add -id Wave.1 { signal5 } -insertionbar

