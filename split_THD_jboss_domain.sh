set -x
#

export LANG=C

FILE=$1
i=0
OLD_IFS=$IFS
IFS='
'

STARTLINE=(`grep -in "Full thread dump" ${FILE} |cut -d":" -f1`)
ENDLINE=(`grep -in "JNI global references" ${FILE} |cut -d":" -f1`)

if [ "x${#ENDLINE[@]}" = "x" ]
then
        for ((i=0;i<${#STARTLINE[@]};i++))
        do
                END=${STARTLINE[$(($i + 1))]}
                if [ "x$END" = "x" ]
                then
                        END=$(wc -l ${FILE} |cut -d " " -f1)
                fi
                tail -n +$((${STARTLINE[$i]} - 1)) ${FILE} | head -n $(($END + 1 - ${STARTLINE[$i]} ))|sed 's/\[Server:img-server-1\] //g'>thd_${i}
                #awk -v FILENAME=thd_${i} -v THDNUM=${i} -f $(dirname $0)/thd.awk |sort -n -t "|" -k1>stat_${i}
        done
elif [ "x${#ENDLINE[@]}" != "x" ]
then
        for ((i=0;i<${#STARTLINE[@]};i++))
        do
                tail -n +$((${STARTLINE[$i]} - 1)) ${FILE} | head -n $((${ENDLINE[$i]} - ${STARTLINE[$i]} + 8))|sed 's/\[Server:img-server-1\] //g' >thd_${i}
                #awk -v FILENAME=thd_${i} -v THDNUM=${i} -f $(dirname $0)/thd.awk |sort -n -t "|" -k1 >stat_${i}
        done
fi
