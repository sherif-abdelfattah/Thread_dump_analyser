# Open file from disk
F1 = open("c:\\thds","r")
#fileString = F1.read()

# define an object class to hold the thread object with below variables
class ThreadBlock:
    threadName = ""  # Name of the thread, effectively first line containsing the nid and the thread name
    threadStatus = ""  # Status of the thread as reported by the VM thread while doing the pause to create the dump
    threadId = ""  # The name and the thread ID without the native Id, used as the key of the thread table
    threadState = ""  # The thread state object as seen by the thread itself.
    threadStack = ""  # The List containing all the thread stack traces.
    threadDumpNumber = 0 # A marker number to mark which dump this thread appeared into

# A counter for thread dump number
DumpNumber=0
# The thread list object that will hold the thread blocks.
threadsList = []
# Here we initialize the ThreadBlock object t before the loop, it is empty now, we will sacrifice an empty
# entry to make the code simpler in the loop
t = ThreadBlock()
for line in F1:
    # Check if we are in the line holding the native ID, if the dump doens't have a native ID, we should fail.
    # This needs to be checked before we go in the loop.
    if "nid=" in line:
        # Add the previous entry (empty if this is the first time to enter the loop)
        threadsList.append(t)
        # Initialize the new Thread Block and add the data below.
        t = ThreadBlock()
        t.threadDumpNumber = DumpNumber
        t.threadName = line
        # Extract the thread status from the thread name line.
        t.threadStatus = ''.join(line.split('nid')[1].split()[1:]).split('[')[0]
        # Extract the thread Id without the nid, then add the nid as a separated field
        t.threadId = line.split('nid=')[0] + "||nid" + line.split('nid')[1].split()[0]
    # Below if this is a new thread dump in the same file
    # we need to increment the dump number.
    elif "Full thread dump" in line:
        DumpNumber += 1
    # Add the thread state line
    elif "java.lang.Thread.State" in line:
        t.threadState = line
    # Here we add all the stack traces as a single string.
    # We plan to be able to compare those later to idenify long running threads later on
    else:
        t.threadStack += line
# Add the last thread in the file since the loop is done.
threadsList.append(t)

# By now the threadList should contain the parsed version of all the dumps.
# everything else is presentation work.


print len(threadsList)
# Here we declare the object which will hold the data to be displayed in the table
threadStateTable = []
# This code is 2 loops, first to go on all threads one by one to compare with the rest of the threads
# in the inner loop, this is to build a table with statuses.
for thd in threadsList:
    # We use the thread ID and an entry key for the table.
    threadEntry = thd.threadId
    # inner loop to do the status comparison and append the status and the order of the dumps.
    for thd2 in threadsList:
        # check if the thread ID is the same
        if thd.threadId == thd2.threadId:
            # Append the status of the inner loop matching thread and its dump number.
            threadEntry = threadEntry + '||' + thd2.threadStatus + ':' + str(thd2.threadDumpNumber)
    # Here, since the thread ID might be redundant as the threadList has all the thread entries from all dumps.
    # we need to check if this thread is already in the table or not.
    # if we have the thread in the table then we for sure have obtained all its statuses from the above loop, no need
    # to add it gain.
    if threadEntry not in threadStateTable:
        threadStateTable.append(threadEntry)

print len(threadStateTable)

# print the table
for tableline in threadStateTable:
    print (tableline)

#    print thd.threadStatus
#    print thd.threadName
#    print thd.threadState
#    print thd.threadStack

#print threadsList[10].threadId
#print threadsList[10].threadStatus
#print threadsList[10].threadName
#print threadsList[10].threadState
#print threadsList[10].threadStack

