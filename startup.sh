#!/bin/bash

EIDIR=/ensembl/easy-import
CONFDIR=/import/conf
DATADIR=/import/data
EXPORTCORE=0
ORTHORUN=0
PREPAREGENETREES=0
RUNGENETREES=0
IMPORTORTHO=0

DEFAULTINI="$CONFDIR/default.ini"
OVERINI="$CONFDIR/overwrite.ini"

while getopts "eoprid:" OPTION
do
  case $OPTION in
    e)  EXPORTCORE=1;;       # export_core_sequences.pl
    o)  ORTHORUN=1;;         # run ORTHOFINDER
    p)  PREPAREGENETREES=1;; # prepare_genetrees.pl
    r)  RUNGENETREES=1;;     # run_genetrees.pl
    i)  IMPORTORTHO=1;;      # import_orthogroup_files.pl
    d)  DATABASE=$OPTARG;;   # core database name
  esac
done

# check database has been specified
if [ -z ${DATABASE+x} ]; then
  echo "ERROR: database variable (-e DATABASE=dbname) has not been set"
  exit
fi

if ! [ -d $DATABASE ]; then
  mkdir -p $DATADIR/$DATABASE
fi

cd $DATADIR/$DATABASE

if ! [ -d log ]; then
  mkdir -p log
fi

# check if $DEFAULTINI file exists
if ! [ -s $DEFAULTINI ]; then
  DEFAULTINI=
fi

# check if $OVERINI file exists
if ! [ -s $OVERINI ]; then
  OVERINI=
fi

if ! [ -z $INI ]; then
  OVERINI="$CONFDIR/$INI $OVERINI"
fi

# check main ini file exists
if ! [ -s $CONFDIR/$DATABASE.ini ]; then
  echo "ERROR: no compara DATABASE $DATABASE.ini exists in conf dir"
  exit
fi

DBINI=$CONFDIR/$DATABASE.ini

#DISPLAY_NAME=$(awk -F "=" '/SPECIES.DISPLAY_NAME/ {print $2}' $DBINI | perl -pe 's/^\s*// and s/\s*$// and s/\s/_/g')
#ASSEMBLY=${DISPLAY_NAME}_$(awk -F "=" '/ASSEMBLY.DEFAULT/ {print $2}' $DBINI | perl -pe 's/^\s*// and s/\s*$// and s/\s/_/g')

if ! [ $EXPORTCORE -eq 0 ]; then
  echo "exporting core sequences for compara"
  perl $EIDIR/compara/export_core_sequences.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/export_core_sequences.err)
fi

if ! [ $PREPAREGENETREES -eq 0 ]; then
  echo "preparing files for genetrees"
  perl $EIDIR/compara/prepare_files_for_genetrees.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/prepare_files_for_genetrees.err)
fi

if ! [ $RUNGENETREES -eq 0 ]; then
  echo "running genetrees"
  perl $EIDIR/compara/run_genetrees.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/run_genetrees.err)
fi

cd ../
