#include<stdio.h>
#include<stdlib.h>
#include<syslog.h>
#include<string.h>

int main( int argc, char *argv[] ) {
    puts("Moops\n");
    
    // open the log file for writing status updates
    openlog(NULL,0,LOG_USER);

    // test for the ccorrect number of arguments
    if (argc != 3) {
        syslog(LOG_ERR, "Invalid number of arguments: %d\n", (argc - 1));
        printf("Invalid number of arguments: %d\n", (argc - 1));
        return EXIT_FAILURE;
    }
    
    // set writefile and writestr as strings equal to the first and second parameters in argv[]
    int argl1=strlen(argv[1]);
    int argl2=strlen(argv[2]);
    printf("Arg 1 is %d characters long and Arg 2 is %d chars long.\n", argl1,argl2);
    char writefile[argl1];
    strcpy(writefile,argv[1]);
    char writestr[argl2];
    strcpy(writestr,argv[2]);
/*    printf("argv[1]: %s\n", argv[1]);
    printf("argv[2]: %s\n", argv[2]);
    printf("writefile: %s\n",writefile);
    printf("writestr: %s\n",writestr);
*/
    // create the file 'writefile' and open it for writing
    FILE *flptr;
    flptr = fopen(writefile, "w");
    if (flptr == NULL) {
        syslog(LOG_ERR, "Problem opening a file pointer.\n");
        return EXIT_FAILURE;
    }

    // write the contents of 'writestr' into the file
    if (fprintf(flptr, "%s\n", writestr) < 0) {
        syslog(LOG_ERR, "Problem writing %s to %s\n", writestr, writefile);
        printf("Problem writing %s to %s\n", writestr, writefile);
        return EXIT_FAILURE;
    }
    syslog(LOG_DEBUG, "Writing %s to %s.\n", writestr, writefile);

    // close the file and exit the program
    fclose(flptr);
    return EXIT_SUCCESS;
}
