#!/bin/bash
SCRIPT=$(readlink -f "$0") && cd $(dirname "$SCRIPT")

# --- Script Init ---
set -euET -o pipefail
shopt -s inherit_errexit 2>/dev/null || echo "WARNING: Unable to set inherit_errexit. Possibly unsupported by this shell, Subprocess failures may not be detected."

LOG_DIR=log
mkdir -p $LOG_DIR
rm -R -f $LOG_DIR/*


touch $LOG_DIR/stderror.err
ktools_monitor.sh $$ $LOG_DIR & pid0=$!

exit_handler(){
   exit_code=$?

   # disable handler
   trap - QUIT HUP INT KILL TERM ERR EXIT

   kill -9 $pid0 2> /dev/null
   if [ "$exit_code" -gt 0 ]; then
       # Error - run process clean up
       echo 'Ktools Run Error - exitcode='$exit_code

       set +x
       group_pid=$(ps -p $$ -o pgid --no-headers)
       sess_pid=$(ps -p $$ -o sess --no-headers)
       script_pid=$$
       printf "Script PID:%d, GPID:%s, SPID:%d
" $script_pid $group_pid $sess_pid >> $LOG_DIR/killout.txt

       ps -jf f -g $sess_pid > $LOG_DIR/subprocess_list
       PIDS_KILL=$(pgrep -a --pgroup $group_pid | awk 'BEGIN { FS = "[ \t\n]+" }{ if ($1 >= '$script_pid') print}' | grep -v celery | egrep -v *\\.log$  | egrep -v *startup.sh$ | sort -n -r)
       echo "$PIDS_KILL" >> $LOG_DIR/killout.txt
       kill -9 $(echo "$PIDS_KILL" | awk 'BEGIN { FS = "[ \t\n]+" }{ print $1 }') 2>/dev/null
       exit $exit_code
   else
       # script successful
       exit 0
   fi
}
trap exit_handler QUIT HUP INT KILL TERM ERR EXIT

check_complete(){
    set +e
    proc_list="eve evepy getmodel gulcalc fmcalc summarycalc eltcalc aalcalc aalcalcmeanonly leccalc pltcalc ordleccalc modelpy gulpy fmpy gulmc summarypy eltpy pltpy aalpy lecpy"
    has_error=0
    for p in $proc_list; do
        started=$(find log -name "${p}_[0-9]*.log" | wc -l)
        finished=$(find log -name "${p}_[0-9]*.log" -exec grep -l "finish" {} + | wc -l)
        if [ "$finished" -lt "$started" ]; then
            echo "[ERROR] $p - $((started-finished)) processes lost"
            has_error=1
        elif [ "$started" -gt 0 ]; then
            echo "[OK] $p"
        fi
    done
    if [ "$has_error" -ne 0 ]; then
        false # raise non-zero exit code
    else
        echo 'Run Completed'
    fi
}
# --- Setup run dirs ---

find output -type f -not -name '*summary-info*' -not -name '*.json' -exec rm -R -f {} +

rm -R -f work/*
mkdir -p work/kat/

rm -R -f /tmp/6NwhLmzlki/
mkdir -p /tmp/6NwhLmzlki/fifo/
mkdir -p work/gul_S1_summaryleccalc
mkdir -p work/gul_S1_summary_palt
mkdir -p work/gul_S1_summary_altmeanonly
mkdir -p work/gul_S2_summaryleccalc
mkdir -p work/gul_S2_summary_palt
mkdir -p work/gul_S2_summary_altmeanonly

mkfifo /tmp/6NwhLmzlki/fifo/gul_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_P8

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P1.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P1.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P1
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P1

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P2.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P2.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P2
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P2

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P3.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P3.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P3
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P3

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P4.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P4.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P4
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P4

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P5.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P5.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P5
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P5

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P6.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P6.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P6
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P6

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P7.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P7.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P7
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P7

mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_summary_P8.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_summary_P8.idx
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P8
mkfifo /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P8



# --- Do ground up loss computes ---


( pltcalc -S work/kat/gul_S1_plt_sample_P1 -Q work/kat/gul_S1_plt_quantile_P1 -M work/kat/gul_S1_plt_moment_P1 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P1 ) 2>> $LOG_DIR/stderror.err & pid1=$!
( eltcalc -Q work/kat/gul_S1_elt_quantile_P1 -M work/kat/gul_S1_elt_moment_P1 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P1 ) 2>> $LOG_DIR/stderror.err & pid2=$!
( summarycalctocsv -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P1 > work/kat/gul_S1_elt_sample_P1 ) 2>> $LOG_DIR/stderror.err & pid3=$!
( pltcalc -S work/kat/gul_S2_plt_sample_P1 -Q work/kat/gul_S2_plt_quantile_P1 -M work/kat/gul_S2_plt_moment_P1 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P1 ) 2>> $LOG_DIR/stderror.err & pid4=$!
( eltcalc -Q work/kat/gul_S2_elt_quantile_P1 -M work/kat/gul_S2_elt_moment_P1 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P1 ) 2>> $LOG_DIR/stderror.err & pid5=$!
( summarycalctocsv -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P1 > work/kat/gul_S2_elt_sample_P1 ) 2>> $LOG_DIR/stderror.err & pid6=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P2 -Q work/kat/gul_S1_plt_quantile_P2 -M work/kat/gul_S1_plt_moment_P2 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P2 ) 2>> $LOG_DIR/stderror.err & pid7=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P2 -M work/kat/gul_S1_elt_moment_P2 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P2 ) 2>> $LOG_DIR/stderror.err & pid8=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P2 > work/kat/gul_S1_elt_sample_P2 ) 2>> $LOG_DIR/stderror.err & pid9=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P2 -Q work/kat/gul_S2_plt_quantile_P2 -M work/kat/gul_S2_plt_moment_P2 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P2 ) 2>> $LOG_DIR/stderror.err & pid10=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P2 -M work/kat/gul_S2_elt_moment_P2 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P2 ) 2>> $LOG_DIR/stderror.err & pid11=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P2 > work/kat/gul_S2_elt_sample_P2 ) 2>> $LOG_DIR/stderror.err & pid12=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P3 -Q work/kat/gul_S1_plt_quantile_P3 -M work/kat/gul_S1_plt_moment_P3 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P3 ) 2>> $LOG_DIR/stderror.err & pid13=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P3 -M work/kat/gul_S1_elt_moment_P3 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P3 ) 2>> $LOG_DIR/stderror.err & pid14=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P3 > work/kat/gul_S1_elt_sample_P3 ) 2>> $LOG_DIR/stderror.err & pid15=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P3 -Q work/kat/gul_S2_plt_quantile_P3 -M work/kat/gul_S2_plt_moment_P3 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P3 ) 2>> $LOG_DIR/stderror.err & pid16=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P3 -M work/kat/gul_S2_elt_moment_P3 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P3 ) 2>> $LOG_DIR/stderror.err & pid17=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P3 > work/kat/gul_S2_elt_sample_P3 ) 2>> $LOG_DIR/stderror.err & pid18=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P4 -Q work/kat/gul_S1_plt_quantile_P4 -M work/kat/gul_S1_plt_moment_P4 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P4 ) 2>> $LOG_DIR/stderror.err & pid19=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P4 -M work/kat/gul_S1_elt_moment_P4 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P4 ) 2>> $LOG_DIR/stderror.err & pid20=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P4 > work/kat/gul_S1_elt_sample_P4 ) 2>> $LOG_DIR/stderror.err & pid21=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P4 -Q work/kat/gul_S2_plt_quantile_P4 -M work/kat/gul_S2_plt_moment_P4 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P4 ) 2>> $LOG_DIR/stderror.err & pid22=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P4 -M work/kat/gul_S2_elt_moment_P4 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P4 ) 2>> $LOG_DIR/stderror.err & pid23=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P4 > work/kat/gul_S2_elt_sample_P4 ) 2>> $LOG_DIR/stderror.err & pid24=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P5 -Q work/kat/gul_S1_plt_quantile_P5 -M work/kat/gul_S1_plt_moment_P5 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P5 ) 2>> $LOG_DIR/stderror.err & pid25=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P5 -M work/kat/gul_S1_elt_moment_P5 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P5 ) 2>> $LOG_DIR/stderror.err & pid26=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P5 > work/kat/gul_S1_elt_sample_P5 ) 2>> $LOG_DIR/stderror.err & pid27=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P5 -Q work/kat/gul_S2_plt_quantile_P5 -M work/kat/gul_S2_plt_moment_P5 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P5 ) 2>> $LOG_DIR/stderror.err & pid28=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P5 -M work/kat/gul_S2_elt_moment_P5 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P5 ) 2>> $LOG_DIR/stderror.err & pid29=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P5 > work/kat/gul_S2_elt_sample_P5 ) 2>> $LOG_DIR/stderror.err & pid30=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P6 -Q work/kat/gul_S1_plt_quantile_P6 -M work/kat/gul_S1_plt_moment_P6 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P6 ) 2>> $LOG_DIR/stderror.err & pid31=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P6 -M work/kat/gul_S1_elt_moment_P6 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P6 ) 2>> $LOG_DIR/stderror.err & pid32=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P6 > work/kat/gul_S1_elt_sample_P6 ) 2>> $LOG_DIR/stderror.err & pid33=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P6 -Q work/kat/gul_S2_plt_quantile_P6 -M work/kat/gul_S2_plt_moment_P6 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P6 ) 2>> $LOG_DIR/stderror.err & pid34=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P6 -M work/kat/gul_S2_elt_moment_P6 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P6 ) 2>> $LOG_DIR/stderror.err & pid35=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P6 > work/kat/gul_S2_elt_sample_P6 ) 2>> $LOG_DIR/stderror.err & pid36=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P7 -Q work/kat/gul_S1_plt_quantile_P7 -M work/kat/gul_S1_plt_moment_P7 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P7 ) 2>> $LOG_DIR/stderror.err & pid37=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P7 -M work/kat/gul_S1_elt_moment_P7 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P7 ) 2>> $LOG_DIR/stderror.err & pid38=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P7 > work/kat/gul_S1_elt_sample_P7 ) 2>> $LOG_DIR/stderror.err & pid39=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P7 -Q work/kat/gul_S2_plt_quantile_P7 -M work/kat/gul_S2_plt_moment_P7 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P7 ) 2>> $LOG_DIR/stderror.err & pid40=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P7 -M work/kat/gul_S2_elt_moment_P7 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P7 ) 2>> $LOG_DIR/stderror.err & pid41=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P7 > work/kat/gul_S2_elt_sample_P7 ) 2>> $LOG_DIR/stderror.err & pid42=$!
( pltcalc -H -S work/kat/gul_S1_plt_sample_P8 -Q work/kat/gul_S1_plt_quantile_P8 -M work/kat/gul_S1_plt_moment_P8 < /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P8 ) 2>> $LOG_DIR/stderror.err & pid43=$!
( eltcalc -s -Q work/kat/gul_S1_elt_quantile_P8 -M work/kat/gul_S1_elt_moment_P8 < /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P8 ) 2>> $LOG_DIR/stderror.err & pid44=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P8 > work/kat/gul_S1_elt_sample_P8 ) 2>> $LOG_DIR/stderror.err & pid45=$!
( pltcalc -H -S work/kat/gul_S2_plt_sample_P8 -Q work/kat/gul_S2_plt_quantile_P8 -M work/kat/gul_S2_plt_moment_P8 < /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P8 ) 2>> $LOG_DIR/stderror.err & pid46=$!
( eltcalc -s -Q work/kat/gul_S2_elt_quantile_P8 -M work/kat/gul_S2_elt_moment_P8 < /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P8 ) 2>> $LOG_DIR/stderror.err & pid47=$!
( summarycalctocsv -s -o < /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P8 > work/kat/gul_S2_elt_sample_P8 ) 2>> $LOG_DIR/stderror.err & pid48=$!

tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P1 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P1 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P1 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P1 work/gul_S1_summary_palt/P1.bin work/gul_S1_summary_altmeanonly/P1.bin work/gul_S1_summaryleccalc/P1.bin > /dev/null & pid49=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P1.idx work/gul_S1_summary_palt/P1.idx work/gul_S1_summaryleccalc/P1.idx > /dev/null & pid50=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P1 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P1 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P1 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P1 work/gul_S2_summary_palt/P1.bin work/gul_S2_summary_altmeanonly/P1.bin work/gul_S2_summaryleccalc/P1.bin > /dev/null & pid51=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P1.idx work/gul_S2_summary_palt/P1.idx work/gul_S2_summaryleccalc/P1.idx > /dev/null & pid52=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P2 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P2 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P2 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P2 work/gul_S1_summary_palt/P2.bin work/gul_S1_summary_altmeanonly/P2.bin work/gul_S1_summaryleccalc/P2.bin > /dev/null & pid53=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P2.idx work/gul_S1_summary_palt/P2.idx work/gul_S1_summaryleccalc/P2.idx > /dev/null & pid54=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P2 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P2 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P2 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P2 work/gul_S2_summary_palt/P2.bin work/gul_S2_summary_altmeanonly/P2.bin work/gul_S2_summaryleccalc/P2.bin > /dev/null & pid55=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P2.idx work/gul_S2_summary_palt/P2.idx work/gul_S2_summaryleccalc/P2.idx > /dev/null & pid56=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P3 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P3 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P3 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P3 work/gul_S1_summary_palt/P3.bin work/gul_S1_summary_altmeanonly/P3.bin work/gul_S1_summaryleccalc/P3.bin > /dev/null & pid57=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P3.idx work/gul_S1_summary_palt/P3.idx work/gul_S1_summaryleccalc/P3.idx > /dev/null & pid58=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P3 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P3 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P3 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P3 work/gul_S2_summary_palt/P3.bin work/gul_S2_summary_altmeanonly/P3.bin work/gul_S2_summaryleccalc/P3.bin > /dev/null & pid59=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P3.idx work/gul_S2_summary_palt/P3.idx work/gul_S2_summaryleccalc/P3.idx > /dev/null & pid60=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P4 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P4 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P4 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P4 work/gul_S1_summary_palt/P4.bin work/gul_S1_summary_altmeanonly/P4.bin work/gul_S1_summaryleccalc/P4.bin > /dev/null & pid61=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P4.idx work/gul_S1_summary_palt/P4.idx work/gul_S1_summaryleccalc/P4.idx > /dev/null & pid62=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P4 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P4 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P4 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P4 work/gul_S2_summary_palt/P4.bin work/gul_S2_summary_altmeanonly/P4.bin work/gul_S2_summaryleccalc/P4.bin > /dev/null & pid63=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P4.idx work/gul_S2_summary_palt/P4.idx work/gul_S2_summaryleccalc/P4.idx > /dev/null & pid64=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P5 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P5 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P5 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P5 work/gul_S1_summary_palt/P5.bin work/gul_S1_summary_altmeanonly/P5.bin work/gul_S1_summaryleccalc/P5.bin > /dev/null & pid65=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P5.idx work/gul_S1_summary_palt/P5.idx work/gul_S1_summaryleccalc/P5.idx > /dev/null & pid66=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P5 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P5 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P5 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P5 work/gul_S2_summary_palt/P5.bin work/gul_S2_summary_altmeanonly/P5.bin work/gul_S2_summaryleccalc/P5.bin > /dev/null & pid67=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P5.idx work/gul_S2_summary_palt/P5.idx work/gul_S2_summaryleccalc/P5.idx > /dev/null & pid68=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P6 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P6 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P6 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P6 work/gul_S1_summary_palt/P6.bin work/gul_S1_summary_altmeanonly/P6.bin work/gul_S1_summaryleccalc/P6.bin > /dev/null & pid69=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P6.idx work/gul_S1_summary_palt/P6.idx work/gul_S1_summaryleccalc/P6.idx > /dev/null & pid70=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P6 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P6 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P6 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P6 work/gul_S2_summary_palt/P6.bin work/gul_S2_summary_altmeanonly/P6.bin work/gul_S2_summaryleccalc/P6.bin > /dev/null & pid71=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P6.idx work/gul_S2_summary_palt/P6.idx work/gul_S2_summaryleccalc/P6.idx > /dev/null & pid72=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P7 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P7 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P7 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P7 work/gul_S1_summary_palt/P7.bin work/gul_S1_summary_altmeanonly/P7.bin work/gul_S1_summaryleccalc/P7.bin > /dev/null & pid73=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P7.idx work/gul_S1_summary_palt/P7.idx work/gul_S1_summaryleccalc/P7.idx > /dev/null & pid74=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P7 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P7 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P7 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P7 work/gul_S2_summary_palt/P7.bin work/gul_S2_summary_altmeanonly/P7.bin work/gul_S2_summaryleccalc/P7.bin > /dev/null & pid75=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P7.idx work/gul_S2_summary_palt/P7.idx work/gul_S2_summaryleccalc/P7.idx > /dev/null & pid76=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P8 /tmp/6NwhLmzlki/fifo/gul_S1_plt_ord_P8 /tmp/6NwhLmzlki/fifo/gul_S1_elt_ord_P8 /tmp/6NwhLmzlki/fifo/gul_S1_selt_ord_P8 work/gul_S1_summary_palt/P8.bin work/gul_S1_summary_altmeanonly/P8.bin work/gul_S1_summaryleccalc/P8.bin > /dev/null & pid77=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S1_summary_P8.idx work/gul_S1_summary_palt/P8.idx work/gul_S1_summaryleccalc/P8.idx > /dev/null & pid78=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P8 /tmp/6NwhLmzlki/fifo/gul_S2_plt_ord_P8 /tmp/6NwhLmzlki/fifo/gul_S2_elt_ord_P8 /tmp/6NwhLmzlki/fifo/gul_S2_selt_ord_P8 work/gul_S2_summary_palt/P8.bin work/gul_S2_summary_altmeanonly/P8.bin work/gul_S2_summaryleccalc/P8.bin > /dev/null & pid79=$!
tee < /tmp/6NwhLmzlki/fifo/gul_S2_summary_P8.idx work/gul_S2_summary_palt/P8.idx work/gul_S2_summaryleccalc/P8.idx > /dev/null & pid80=$!

( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P1 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P1 < /tmp/6NwhLmzlki/fifo/gul_P1 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P2 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P2 < /tmp/6NwhLmzlki/fifo/gul_P2 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P3 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P3 < /tmp/6NwhLmzlki/fifo/gul_P3 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P4 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P4 < /tmp/6NwhLmzlki/fifo/gul_P4 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P5 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P5 < /tmp/6NwhLmzlki/fifo/gul_P5 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P6 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P6 < /tmp/6NwhLmzlki/fifo/gul_P6 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P7 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P7 < /tmp/6NwhLmzlki/fifo/gul_P7 ) 2>> $LOG_DIR/stderror.err  &
( summarycalc -m -i  -1 /tmp/6NwhLmzlki/fifo/gul_S1_summary_P8 -2 /tmp/6NwhLmzlki/fifo/gul_S2_summary_P8 < /tmp/6NwhLmzlki/fifo/gul_P8 ) 2>> $LOG_DIR/stderror.err  &

socket-server 1447 > /dev/null & spid=$!
trap 'kill -TERM -"$spid" 2>/dev/null' INT TERM
( ( eve 1 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P1  ) 2>> $LOG_DIR/stderror.err ) &  pid81=$!
( ( eve 2 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P2  ) 2>> $LOG_DIR/stderror.err ) &  pid82=$!
( ( eve 3 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P3  ) 2>> $LOG_DIR/stderror.err ) &  pid83=$!
( ( eve 4 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P4  ) 2>> $LOG_DIR/stderror.err ) &  pid84=$!
( ( eve 5 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P5  ) 2>> $LOG_DIR/stderror.err ) &  pid85=$!
( ( eve 6 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P6  ) 2>> $LOG_DIR/stderror.err ) &  pid86=$!
( ( eve 7 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P7  ) 2>> $LOG_DIR/stderror.err ) &  pid87=$!
( ( eve 8 8 | gulmc --socket-server='1447' --random-generator=1  --model-df-engine='oasis_data_manager.df_reader.reader.OasisPandasReader' --vuln-cache-size 200 -S10 -L0 -a1  > /tmp/6NwhLmzlki/fifo/gul_P8  ) 2>> $LOG_DIR/stderror.err ) &  pid88=$!

wait $pid1 $pid2 $pid3 $pid4 $pid5 $pid6 $pid7 $pid8 $pid9 $pid10 $pid11 $pid12 $pid13 $pid14 $pid15 $pid16 $pid17 $pid18 $pid19 $pid20 $pid21 $pid22 $pid23 $pid24 $pid25 $pid26 $pid27 $pid28 $pid29 $pid30 $pid31 $pid32 $pid33 $pid34 $pid35 $pid36 $pid37 $pid38 $pid39 $pid40 $pid41 $pid42 $pid43 $pid44 $pid45 $pid46 $pid47 $pid48 $pid49 $pid50 $pid51 $pid52 $pid53 $pid54 $pid55 $pid56 $pid57 $pid58 $pid59 $pid60 $pid61 $pid62 $pid63 $pid64 $pid65 $pid66 $pid67 $pid68 $pid69 $pid70 $pid71 $pid72 $pid73 $pid74 $pid75 $pid76 $pid77 $pid78 $pid79 $pid80 $pid81 $pid82 $pid83 $pid84 $pid85 $pid86 $pid87 $pid88

kill -0 "$spid" 2>/dev/null && kill -9 "$spid"

# --- Do ground up loss kats ---

kat work/kat/gul_S1_plt_sample_P1 work/kat/gul_S1_plt_sample_P2 work/kat/gul_S1_plt_sample_P3 work/kat/gul_S1_plt_sample_P4 work/kat/gul_S1_plt_sample_P5 work/kat/gul_S1_plt_sample_P6 work/kat/gul_S1_plt_sample_P7 work/kat/gul_S1_plt_sample_P8 > output/gul_S1_splt.csv & kpid1=$!
kat work/kat/gul_S1_plt_quantile_P1 work/kat/gul_S1_plt_quantile_P2 work/kat/gul_S1_plt_quantile_P3 work/kat/gul_S1_plt_quantile_P4 work/kat/gul_S1_plt_quantile_P5 work/kat/gul_S1_plt_quantile_P6 work/kat/gul_S1_plt_quantile_P7 work/kat/gul_S1_plt_quantile_P8 > output/gul_S1_qplt.csv & kpid2=$!
kat work/kat/gul_S1_plt_moment_P1 work/kat/gul_S1_plt_moment_P2 work/kat/gul_S1_plt_moment_P3 work/kat/gul_S1_plt_moment_P4 work/kat/gul_S1_plt_moment_P5 work/kat/gul_S1_plt_moment_P6 work/kat/gul_S1_plt_moment_P7 work/kat/gul_S1_plt_moment_P8 > output/gul_S1_mplt.csv & kpid3=$!
kat work/kat/gul_S1_elt_quantile_P1 work/kat/gul_S1_elt_quantile_P2 work/kat/gul_S1_elt_quantile_P3 work/kat/gul_S1_elt_quantile_P4 work/kat/gul_S1_elt_quantile_P5 work/kat/gul_S1_elt_quantile_P6 work/kat/gul_S1_elt_quantile_P7 work/kat/gul_S1_elt_quantile_P8 > output/gul_S1_qelt.csv & kpid4=$!
kat work/kat/gul_S1_elt_moment_P1 work/kat/gul_S1_elt_moment_P2 work/kat/gul_S1_elt_moment_P3 work/kat/gul_S1_elt_moment_P4 work/kat/gul_S1_elt_moment_P5 work/kat/gul_S1_elt_moment_P6 work/kat/gul_S1_elt_moment_P7 work/kat/gul_S1_elt_moment_P8 > output/gul_S1_melt.csv & kpid5=$!
kat work/kat/gul_S1_elt_sample_P1 work/kat/gul_S1_elt_sample_P2 work/kat/gul_S1_elt_sample_P3 work/kat/gul_S1_elt_sample_P4 work/kat/gul_S1_elt_sample_P5 work/kat/gul_S1_elt_sample_P6 work/kat/gul_S1_elt_sample_P7 work/kat/gul_S1_elt_sample_P8 > output/gul_S1_selt.csv & kpid6=$!
kat work/kat/gul_S2_plt_sample_P1 work/kat/gul_S2_plt_sample_P2 work/kat/gul_S2_plt_sample_P3 work/kat/gul_S2_plt_sample_P4 work/kat/gul_S2_plt_sample_P5 work/kat/gul_S2_plt_sample_P6 work/kat/gul_S2_plt_sample_P7 work/kat/gul_S2_plt_sample_P8 > output/gul_S2_splt.csv & kpid7=$!
kat work/kat/gul_S2_plt_quantile_P1 work/kat/gul_S2_plt_quantile_P2 work/kat/gul_S2_plt_quantile_P3 work/kat/gul_S2_plt_quantile_P4 work/kat/gul_S2_plt_quantile_P5 work/kat/gul_S2_plt_quantile_P6 work/kat/gul_S2_plt_quantile_P7 work/kat/gul_S2_plt_quantile_P8 > output/gul_S2_qplt.csv & kpid8=$!
kat work/kat/gul_S2_plt_moment_P1 work/kat/gul_S2_plt_moment_P2 work/kat/gul_S2_plt_moment_P3 work/kat/gul_S2_plt_moment_P4 work/kat/gul_S2_plt_moment_P5 work/kat/gul_S2_plt_moment_P6 work/kat/gul_S2_plt_moment_P7 work/kat/gul_S2_plt_moment_P8 > output/gul_S2_mplt.csv & kpid9=$!
kat work/kat/gul_S2_elt_quantile_P1 work/kat/gul_S2_elt_quantile_P2 work/kat/gul_S2_elt_quantile_P3 work/kat/gul_S2_elt_quantile_P4 work/kat/gul_S2_elt_quantile_P5 work/kat/gul_S2_elt_quantile_P6 work/kat/gul_S2_elt_quantile_P7 work/kat/gul_S2_elt_quantile_P8 > output/gul_S2_qelt.csv & kpid10=$!
kat work/kat/gul_S2_elt_moment_P1 work/kat/gul_S2_elt_moment_P2 work/kat/gul_S2_elt_moment_P3 work/kat/gul_S2_elt_moment_P4 work/kat/gul_S2_elt_moment_P5 work/kat/gul_S2_elt_moment_P6 work/kat/gul_S2_elt_moment_P7 work/kat/gul_S2_elt_moment_P8 > output/gul_S2_melt.csv & kpid11=$!
kat work/kat/gul_S2_elt_sample_P1 work/kat/gul_S2_elt_sample_P2 work/kat/gul_S2_elt_sample_P3 work/kat/gul_S2_elt_sample_P4 work/kat/gul_S2_elt_sample_P5 work/kat/gul_S2_elt_sample_P6 work/kat/gul_S2_elt_sample_P7 work/kat/gul_S2_elt_sample_P8 > output/gul_S2_selt.csv & kpid12=$!
wait $kpid1 $kpid2 $kpid3 $kpid4 $kpid5 $kpid6 $kpid7 $kpid8 $kpid9 $kpid10 $kpid11 $kpid12


( aalcalc -Kgul_S1_summary_palt -o > output/gul_S1_palt.csv ) 2>> $LOG_DIR/stderror.err & lpid1=$!
( aalcalcmeanonly -Kgul_S1_summary_altmeanonly -o > output/gul_S1_altmeanonly.csv ) 2>> $LOG_DIR/stderror.err & lpid2=$!
( ordleccalc  -Kgul_S1_summaryleccalc -F -f -O output/gul_S1_ept.csv ) 2>> $LOG_DIR/stderror.err & lpid3=$!
( aalcalc -Kgul_S2_summary_palt -o > output/gul_S2_palt.csv ) 2>> $LOG_DIR/stderror.err & lpid4=$!
( aalcalcmeanonly -Kgul_S2_summary_altmeanonly -o > output/gul_S2_altmeanonly.csv ) 2>> $LOG_DIR/stderror.err & lpid5=$!
( ordleccalc  -Kgul_S2_summaryleccalc -F -f -O output/gul_S2_ept.csv ) 2>> $LOG_DIR/stderror.err & lpid6=$!
wait $lpid1 $lpid2 $lpid3 $lpid4 $lpid5 $lpid6

rm -R -f work/*
rm -R -f /tmp/6NwhLmzlki/

check_complete
