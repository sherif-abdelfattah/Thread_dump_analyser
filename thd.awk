BEGIN{
        i=0;
        line="";
        while (getline line < FILENAME)
        {
                #Look for the begining of the thread
                gotit=match(line,"prio=.* tid=.* nid=.*");
                if (gotit > 0 )
                {
                        #Found the beginning line
                        #print(line);
                        split(line,thread_parts,"nid=");
                        #print(thread_parts[1],"-----",thread_parts[2]);
                        split(thread_parts[1],thread_name_part,"\"");
                        thread_name=thread_name_part[2];
                        split(thread_parts[2],status_parts,"[");
                        nid_status=status_parts[1];
                        split(nid_status,nid_part," ");
                        nid=nid_part[1];
                        gsub(/0x[0-9,a-f,A-F]+ /,"",nid_status);
                        gsub(/^[0-9,a-f,A-F]+ /,"",nid_status);
                        status=nid_status;
                }
                else if (gotit == 0)
                {
                        #Not a begining line, look for the state
                        isstateSTR=match(line,"java.lang.Thread.State:")
                        if (isstateSTR > 0)
                        {
                                split(line,state_part,": ");
                                state=state_part[2];
                                print(thread_name, "@", nid,"|",state,"@",status,"@" THDNUM+1);
                        }

                }

        }
}
