#!/bin/sh

show_help(){
    echo "Usage: $0 [options] SubjectFolder

    Required arguments:
    -f|--subject-dir [SubjectFolder]    (directory name only)
    -F|--study-dir [StudyFolder]        (path the study directory)


    Optional arguments:
    -d|--distortion-correction     
    -r|--coregistration          
    -N|--fit-noddi              
    -K|--fit-dki
    -D|--fit-dti
    -w|--prep-wmh
    -m|--prep-wmh-shells
    -c|--prep-clusters
    -s|--prep-shells
    -W|--measure-wmh
    -M|--measure-wmh-shells
    -C|--measure-clusters
    -S|--measure-shells
    -a|--all                            (default)
    -q|--sge-submit
    -X|--script-dir [ScriptDir]">&2
    exit 1
}

TRUE=0
FALSE=""

#################################################
#               Argument Flags
#################################################
ALL=$TRUE
SUBJECT_DIR=$FALSE
STUDY_DIR=$(pwd)
SGE_SUBMIT=$FALSE
DISTORTION_CORRECTION=$FALSE
COREGISTRATION=$FALSE
FIT_NODDI=$FALSE
FIT_DKE=$FALSE
FIT_DTI=$FALSE
PREP_WMH=$FALSE
PREP_WMH_SHELLS=$FALSE
PREP_CLUSTERS=$FALSE
PREP_CLUSTER_SHELLS=$FALSE
MEASURE_WMH=$FALSE
MEASURE_WMH_SHELLS=$FALSE
MEASURE_CLUSTERS=$FALSE
MEASURE_CLUSTER_SHELLS=$FALSE
SCRIPTS_DIR="$DTIPIPE"
#################################################
#               Argument Parsing
#################################################
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--subject-dir)
        SUBJECT_DIR="$2"
        shift
        shift        
    ;;
    -F|--study-dir)
        STUDY_DIR="$2"
        shift
        shift        
    ;;
    -X|--script-dir)
        SCRIPTS_DIR="$2"
        export DTIPIPE="$2"
        shift
        shift        
    ;;
    -d|--distortion-correction)
        ALL=$FALSE
        DISTORTION_CORRECTION=$TRUE
        shift # past argument
    ;;
    -r|--coregistration)
        ALL=$FALSE
        COREGISTRATION=$TRUE
        shift # past argument
    ;;
    -N|--fit-noddi)
        ALL=$FALSE
        FIT_NODDI=$TRUE
        shift # past argument
    ;;
    -K|--fit-dki)
        ALL=$FALSE
        FIT_DKE=$TRUE
        shift # past argument
    ;;
    -D|--fit-dti)
        ALL=$FALSE
        FIT_DTI=$TRUE
        shift # past argument
    ;;
    -w|--prep-wmh)
        ALL=$FALSE
        PREP_WMH=$TRUE
        shift # past argument
    ;;
    -m|--prep-wmh-shells)
        ALL=$FALSE
        PREP_WMH_SHELLS=$TRUE
        shift # past argument
    ;;
    -c|--prep-clusters)
        ALL=$FALSE
        PREP_CLUSTERS=$TRUE
        shift # past argument
    ;;
    -s|--prep-shells)
        ALL=$FALSE
        PREP_CLUSTER_SHELLS=$TRUE
        shift # past argument
    ;;  
    -W|--measure-wmh)
        ALL=$FALSE
        MEASURE_WMH=$TRUE
        shift # past argument
    ;;
    -M|--measure-wmh-shells)
        ALL=$FALSE
        MEASURE_WMH_SHELLS=$TRUE
        shift # past argument
    ;;
    -C|--measure-clusters)
        ALL=$FALSE
        MEASURE_CLUSTERS=$TRUE
        shift # past argument
    ;;
    -S|--measure-shells)
        ALL=$FALSE
        MEASURE_CLUSTER_SHELLS=$TRUE
        shift # past argument
    ;;
    -q|--sge-submit)
        SGE_SUBMIT=$TRUE
        shift # past argument  
    ;;
    -a|--all)
        ALL=$TRUE
        shift # past value
    ;;
    *|-h|--help)    # unknown option
    show_help
    ;;
esac
done

if [ $ALL ]; then
    DISTORTION_CORRECTION=$TRUE
    COREGISTRATION=$TRUE
    FIT_NODDI=$TRUE
    FIT_DKE=$TRUE
    FIT_DTI=$TRUE
    PREP_WMH=$TRUE
    PREP_WMH_SHELLS=$TRUE
    PREP_CLUSTERS=$TRUE
    PREP_CLUSTER_SHELLS=$TRUE
    MEASURE_WMH=$TRUE
    MEASURE_WMH_SHELLS=$TRUE
    MEASURE_CLUSTERS=$TRUE
    MEASURE_CLUSTER_SHELLS=$TRUE
fi

#################################################
#           Argument Validation
#################################################
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "ERROR: Could not find scripts directory: ${SCRIPTS_DIR}.">&2 
    exit 1
fi
if [ ! -d "$STUDY_DIR" ]; then
    echo "ERROR: Could not find study directory: ${STUDY_DIR}.">&2
    exit 1
fi
if [ ! $SUBJECT_DIR ]; then
    echo "ERROR: no subject directory specified.">&2
fi
if [ ! -d "$STUDY_DIR/$SUBJECT_DIR" ]; then
    echo "ERROR: Could not find subject: ${SUBJECT_DIR}.">&2
    exit 1
fi


#################################################
#           Execute Scripts
#################################################
cd "$STUDY_DIR/$SUBJECT_DIR"
process="$SCRIPTS_DIR/scripts/processing"
mkdir -p logs/out
mkdir -p logs/err

# prepare some special stuff for queue submittion
if [ $SGE_SUBMIT ]; then
    module load fsl/5.0.11
    module load mrtrix
    module load python/3.6.6
    module load matlab/R2018a
    out='logs/out/${script_name}.out'
    err='logs/err/${script_name}.err'
    script='$process/${script_name}.sh'
    name='${script_name}_${SUBJECT_DIR}'
    qsub_command="qsub -pe mpi \$slots -q long.q -V -cwd -o $out -e $err -N $name -hold_jid \$holds $script"
fi

if [ $DISTORTION_CORRECTION ]; then
    script_name=distortion_correction
    if [ $SGE_SUBMIT ]; then
        slots=6
        holds=tmp
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $COREGISTRATION ]; then
    script_name=coregister
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="distortion_correction_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $FIT_NODDI ]; then
    script_name=calculate_noddi
    if [ $SGE_SUBMIT ]; then
        slots=12
        holds="coregister_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $FIT_DKE ]; then
    script_name=calculate_kurtosis
    if [ $SGE_SUBMIT ]; then
        slots=12
        holds="coregister_${SUBJECT_DIR}"
        module unload matlab
        module load matlab/MCR-R2012a
        module load dke
        eval $qsub_command 
        module unload dke
        module unload matlab
        module load matlab/R2018a
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $FIT_DTI ]; then
    script_name=fit_tensors
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="coregister_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $PREP_WMH ]; then
    script_name=prepare_wmh_vs_nawm
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="distortion_correction_${SUBJECT_DIR}"
        holds="$holds,calculate_noddi_${SUBJECT_DIR}"
        holds="$holds,calculate_kurtosis_${SUBJECT_DIR}"
        holds="$holds,fit_tensors_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $PREP_WMH_SHELLS ]; then
    script_name=prep_wmh_shells
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prepare_wmh_vs_nawm_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $PREP_CLUSTERS ]; then
    script_name=prep_clusters
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prepare_wmh_vs_nawm_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $PREP_CLUSTER_SHELLS ]; then
    script_name=prep_cluster_shells
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prep_clusters_${SUBJECT_DIR}"
        holds=",$holds,prep_wmh_shells_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $MEASURE_WMH ]; then
    script_name=compare_wmh_vs_nawm
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prepare_wmh_vs_nawm_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $MEASURE_WMH_SHELLS ]; then
    script_name=compare_wmh_shells
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prep_wmh_shells_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $MEASURE_CLUSTERS ]; then
    script_name=measure_clusters
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prep_clusters_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
if [ $MEASURE_CLUSTER_SHELLS ]; then
    script_name=measure_cluster_shells
    if [ $SGE_SUBMIT ]; then
        slots=1
        holds="prep_cluster_shells_${SUBJECT_DIR}"
        eval $qsub_command 
    else
        $process/${script_name}.sh>\
            logs/out/${script_name}.out 2>\
            logs/err/${script_name}.err
    fi
fi
