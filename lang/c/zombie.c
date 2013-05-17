/*
http://www.unix.com/unix-dummies-questions-answers/100737-how-do-you-create-zombie-process.html

compile and run in one terminal:
$ cc zombie.c -o zombie
$ ./zombie

check in another terminal:
$ ps -e -o pid,ppid,stat,command
*/

#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main ()
{
  pid_t child_pid;

  child_pid = fork ();
  if (child_pid > 0) {
    sleep (60);
  }
  else {
    exit (0);
  }
  return 0;
}
