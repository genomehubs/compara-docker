#!/bin/bash

EIDIR=/ensembl/easy-import
CONFDIR=/import/conf
DATADIR=/import/data
SETUPDB=0
EXPORTCORE=0
ORTHORUN=0
MAKEFILES=0
IMPORTORTHO=0

DEFAULTINI="$CONFDIR/default.ini"
OVERINI="$CONFDIR/overwrite.ini"

while getopts "seomid:" OPTION
do
  case $OPTION in
    s)  SETUPDB=1;;          # setup_database.pl
    e)  EXPORTCORE=1;;       # export_core_sequences.pl
    o)  ORTHORUN=1;;         # run ORTHOFINDER
    m)  MAKEFILES=1;;        # make_orthogroup_files.pl
    i)  IMPORTORTHO=1;;      # import_orthogroups.pl
    d)  DATABASE=$OPTARG;;   # compara database name
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

# check main ini file exists
if ! [ -s $CONFDIR/$DATABASE.ini ]; then
  echo "ERROR: no compara DATABASE $DATABASE.ini exists in conf dir"
  exit
fi

DBINI=$CONFDIR/$DATABASE.ini

if ! [ $SETUPDB -eq 0 ]; then
  echo "setting up compara database"
  perl $EIDIR/compara/setup_database.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/setup_database.err)
fi

if ! [ $EXPORTCORE -eq 0 ]; then
  echo "exporting core sequences for compara"
  perl $EIDIR/compara/export_core_sequences.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/export_core_sequences.err)
fi

if ! [ $ORTHORUN -eq 0 ]; then
  echo "running Orthofinder"
  if [ -z $THREADS ]; then
    THREADS=4
  fi
  ORTHOFINDER_DIR=$(awk -F "=" '/ORTHOFINDER_DIR/ {print $2}' $DBINI | tr -d ' ')
  FASTA_DIR=$(awk -F "=" '/FASTA_DIR/ {print $2}' $DBINI | tr -d ' ')/canonical_proteins
  VERSION=${ORTHOFINDER_DIR##*_}
  ORTHOFINDER_DIR=$(dirname $ORTHOFINDER_DIR)
  mkdir -p /import/data/tmp
  orthofinder -f $FASTA_DIR -M msa -S diamond -A mafft_and_trim -T raxml-ng -o $ORTHOFINDER_DIR -n $VERSION -t $THREADS -X
fi

if ! [ $MAKEFILES -eq 0 ]; then
  echo "preparing orthogroup files for import"
  perl $EIDIR/compara/make_orthogroup_files.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/make_orthogroup_files.err)
fi

if ! [ $IMPORTORTHO -eq 0 ]; then
  echo "importing orthogroups"
  perl $EIDIR/compara/import_orthogroups.pl $DEFAULTINI $DBINI $OVERINI &> >(tee log/import_orthogroups.err)
fi

cd ../
