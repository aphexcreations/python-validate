#!/bin/bash

##
## Runs PEP8 and PyLint Validations
##

if [ -z "${1}" ]; then
    echo "A PATH ARGUMENT IS REQUIRED."
    echo "IT CAN EITHER BE A FILE OR DIRECTORY PATH."
    exit 1
elif [[ "$1" = /* ]]; then
    ## Absolute path
    start_point="${1}"
else
    ## Relative path
    start_point="$(pwd)/${1}"
fi;

if [ -d "${start_point}" ]; then
    ##
    ## Is a Directory
    ##

    ## Change to dir
    cd ${start_point}

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
elif [ -f "${start_point}" ]; then
    ##
    ## Is a file
    ##

    ## Change to dir
    cd $(dirname ${start_point})
    files="${start_point}"
else
    ##
    ## Something else
    ##
    echo "PATH ARGUMENT IS NOT A VALID DIRECTORY OR FILE PATH."
    exit 1
fi;


##
## Some pylint message IDs that we use:
##
##  - W0212: Access to a protected member _* of a client class
##  - F0401: Unable to import module
##  - W0232: Class has no __init__ method
##  - R0201: Method could be a function
##  - W0142: Used * or ** magic
##  - W0511: Used when a warning note as FIXME or XXX is detected
##  - W0613: Unused argument %r Used when a function or
##           method argument is not used.
##

for file in ${files}; do
    pep_res=$(pep8 ${file} 2>&1)
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
             --max-locals="20" \
             --max-args="15" \
             --variable-rgx="[a-z_][a-z0-9_]{,30}" \
             --const-rgx="(([A-Za-z_][A-Za-z0-9_]*)|(__.*__))$" \
             --argument-rgx="[a-z_][a-z0-9_]{,30}$" \
             --generated-members="hashlib.md5" \
             --bad-functions="eval,exec,execfile" \
             --min-public-methods="1" \
             --max-returns="10" \
             --max-branchs="33" \
             --disable="W0212,F0401,W0232,R0201,W0142,W0511,W0613" \
             --reports="n" \
             --include-ids="y" \
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

