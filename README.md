# scripts
neat little helpers

---

## print-locks.pl
This script is meant to help find possible locking and synchronization issues
by printing functions that call into other functions while holding a lock. It
is then easy to find out whether or not a violation of the locking scheme is
happening.

*How it works:*
The script has a hard coded list of sysnchronization locks (mutex, spinlocks)
that are used in the code being processed. It walks through the code trying to
find a function body. If one has been found, it is checked whether one of the
known locks (-> the hard coded list) matches in it. If so, the script looks for
a call to another function while holding the lock.   
The output is printed with the same indention level as the source code. This is
done because the script does not follow the possible execution paths of the
code.
