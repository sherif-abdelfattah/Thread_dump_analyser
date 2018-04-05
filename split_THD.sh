#set -x
#

export LANG=C

FILE=$1
i=0
OLD_IFS=$IFS
IFS='
'

STARTLINE=(`grep -n "Full thread dump Java HotSpot(TM)" ${FILE} |cut -d":" -f1`)
ENDLINE=(`grep -n "JNI global references" ${FILE} |cut -d":" -f1`)

if [ "x${#ENDLINE[@]}" = "x" ]
then
        for ((i=0;i<${#STARTLINE[@]};i++))
        do
                END=${STARTLINE[$(($i + 1))]}
                if [ "x$END" = "x" ]
                then
                        END=$(wc -l ${FILE} |cut -d " " -f1)
                fi
                tail -n +$((${STARTLINE[$i]} - 1)) ${FILE} | head -n $(($END + 1 - ${STARTLINE[$i]} ))>thd_${i}
                awk -v FILENAME=thd_${i} -v THDNUM=${i} -f $(dirname $0)/thd.awk |sort -n -t "|" -k1>stat_${i}
        done
elif [ "x${#ENDLINE[@]}" != "x" ]
then
        for ((i=0;i<${#STARTLINE[@]};i++))
        do
                tail -n +$((${STARTLINE[$i]} - 1)) ${FILE} | head -n $((${ENDLINE[$i]} - ${STARTLINE[$i]} + 8)) >thd_${i}
                awk -v FILENAME=thd_${i} -v THDNUM=${i} -f $(dirname $0)/thd.awk |sort -n -t "|" -k1 >stat_${i}
        done
fi

##set -x
j=2
k=2
if [ "${i}" -gt "1" ]
then
        join -t "|" stat_0 stat_1 -a 1 -a 2 >stat_final_2
        k=2
        for ((j=2;j<${i};j++))
        do
                k=$(( ${j} + 1))
                join -t "|" stat_final_${j} stat_${j} -a 1 -a 2 >stat_final_${k}
        done
        mv stat_final_${k} stat_final_final_${k}
else
        mv stat_0 stat_final_final_1
fi
