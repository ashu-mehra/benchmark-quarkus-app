#!/bin/bash

<<comment
./create_cds_archive.sh pd dacapo avrora
./create_cds_archive.sh pd dacapo fop 
./create_cds_archive.sh pd dacapo h2 
./create_cds_archive.sh pd dacapo jython 
./create_cds_archive.sh pd dacapo luindex
comment
./create_cds_archive.sh pd dacapo lusearch-fix 
./create_cds_archive.sh pd dacapo pmd
./create_cds_archive.sh pd dacapo sunflow
./create_cds_archive.sh pd dacapo xalan

