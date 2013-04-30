#!/bin/bash

##
## Runs PEP8 and PyLint Validations
##

if [ -z "${1}" ]; then
    echo "A PATH ARGUMENT IS REQUIRED."
    exit 1
elif [[ "$1" = /* ]]; then
    ## Absolute path
    exec_dir="${1}"
else
    ## Relative path
    exec_dir="$(pwd)/${1}"
fi;
if [ ! -d "${exec_dir}" ]; then
    echo "NOT VALID DIRECTORY: ${exec_dir}"
    exit 1
fi;

## Change to dir
cd ${exec_dir}

##
## Get python files
##
files=$(
    find . \
        -type f -and \
        -iname "*.py" -and \
        \( \
            -not \
            \( \
                -iwholename "*/tests/*" -or \
                -iwholename "*/test/*" -or \
                -iwholename "*/.git/*" -or \
                -iwholename "*/migrations/*" -or \
                -iname "test_*.py" \
            \) \
        \)
)

##
## Some pylint message IDs that we use:
##
##  * W0212: Access to a protected member _* of a client class
##

for file in ${files}; do
    pep_res=$(
        pep8 \
            -qq \
            ${file} 2>&1
    )
    pep_status=${?}
    if [ ${pep_status} -ne 0 ]; then
        echo
        echo "CODE DOES NOT PASS PEP8. FILE:"
        echo
        echo "> ${file}"
        echo
        echo -e "${pep_res}"
        echo
        exit 1
    fi
    pylint_res=$(
         pylint \
             --max-args="15" \
             --variable-rgx="[a-z_][a-z0-9_]*" \
             --const-rgx="(([A-Za-z_][A-Za-z0-9_]*)|(__.*__))$" \
             --good-name="getLogLevel,_logLevelName,_levelNames" \
             --disable="W0212" \
             --reports=n \
             ${file} 2>&1
    )
    pylint_status=${?}
    if [ ${pylint_status} -ne 0 ]; then
        echo
        echo "CODE DOES NOT PASS PYLINT. FILE:"
        echo
        echo "> ${file}"
        echo
        echo -e "${pylint_res}"
        echo
        exit 1
    fi
done;

exit 0

