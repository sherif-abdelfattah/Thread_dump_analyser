####

FILE=$1
OLD_IFS=${IFS}
IFS='
'

total_dumps=`echo ${FILE} |rev | cut -d"_" -f1`

echo "<html>"
echo "<head>"
echo "<style>"
echo "table, th, td {
    border: 1px solid;
    font-size: 80%; 
}"
echo "</style>"
echo "</head>"
echo "<body>"
echo "<p>Total dumps: ${total_dumps} </p>"
echo "<table style=\"width:100%\">"
echo "<tr>"
echo "<th>Thread Name</th>"
echo "<th>Thread NID</th>"

for i in `seq $total_dumps`
do
        echo "<th> THD_${i} </th>"
done
echo "</tr>"

for LINE in `cat ${FILE}`
do
        thread_NAME=`echo ${LINE}|cut -d"|" -f1|cut -d"@" -f1`
        thread_nid=`echo ${LINE}|cut -d"|" -f1|cut -d"@" -f2`
        thread_stats=`echo ${LINE}|cut -d"|" -f2-`
        #Get number of dumps per thread, could be equal to or less than total_dumps.
        numberOfDumps=`echo ${thread_stats} |awk -F"|" '{print NF}'`
        echo "<tr>"
        echo "<td>${thread_NAME}</td>"
        echo "<td>${thread_nid}</td>"
        for i in `seq ${total_dumps}`
        do
                printed=""
                for j in `seq ${numberOfDumps}`
                do
                        dumpnumber=`echo ${thread_stats}|cut -d"|" -f${j} |cut -d"@" -f3`
                        state=`echo ${thread_stats}|cut -d"|" -f${j} |cut -d"@" -f1,2`
                        state_1=`echo ${thread_stats}|cut -d"|" -f${j} |cut -d"@" -f1`
                        if [ "x${i}" = "x${dumpnumber}" ]
                        then
                                printed="ok"
                                color=""
                                case ${state_1} in
                                        ?RUNNABLE*)
                                                color="darkgreen"
                                        ;;
                                        ?BLOCKED*)
                                                color="red"
                                        ;;
                                        ?WAITING*)
                                                color="orange"
                                        ;;
                                        ?TIMED_WAITING*)
                                                color="lightsalmon"
                                        ;;
                                        *)
                                                color="black"
                                esac

                                echo "<td style=\"color:${color};\">${state}</td>"
                                break
                        fi
                done
                #set -x
                if [ "x${printed}" = "xok" ]
                then
                        :
                else
                        echo "<td>--</td>"
                fi
                #set +x
        done
        echo "</tr>"
done
echo "</table>"
echo "</body>"
echo "</html>"
