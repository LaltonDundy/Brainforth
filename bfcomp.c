#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#define MEMSIZE 100000

void execute( const char * filename) {

   // Get File
   FILE *file = fopen(filename, "r") ;
   //Check if reading successfull. Abort if not.
   if(!file){
       printf("something went wrong with: ")   ;
        printf("%s", filename);
       return                                  ;
    }
   // Sanity check rewind
   rewind(file)                                ;
   // Set memory aside from BF program memory
   char array[MEMSIZE] = {0}                   ;
   // the pointer manipulated upon the memory
   char *ptr=array                             ;
   // loop counter
   int  counter = 0                            ;
   // current symbol in program
   char * progptr                              ;
   // Put a pointer at the end of the external file
   fseek(file,SEEK_SET , SEEK_END)             ;
   // Use pointer to give me files size
   const int pSize = ftell(file)               ; 
   // Allocate memory to store extern file
   char program[pSize]                         ;
   // Program pointer
   progptr = program                           ;
   // bring the 'f' pointer back to the beginning of the file
   rewind(file)                                ;
   // copy external program into local memory
   char current                                ;
   while (!feof(file)) {
      fscanf(file, "%c" , &current)            ;
      program[counter++] = current             ;
   }
   // Close access to external file
   fclose(file)                                ;

   // Decrease Program pointer by one since it incs on mainloop
   --progptr                                   ;
mainLoop:
   counter = 0;
   switch( *++progptr ) {

    case '>' : ++ptr                 ; goto mainLoop     ;
    case '<' : --ptr                 ; goto mainLoop     ;
    case '+' : ++*ptr                ; goto mainLoop     ;
    case '-' : --*ptr                ; goto mainLoop     ;
    case '.' : printf("%c", *ptr )   ; goto mainLoop     ;
    case ',' : *ptr=getchar()        ; goto mainLoop     ;
    case '[' :                       ; goto lbrackhandlr ; 
    case ']' :                       ; goto rbrackhandlr ; 
    case EOF :                       ; goto end          ;
    default  :                       ; goto mainLoop     ;
   };

lbrackhandlr:
   if    ( *ptr       ) { goto mainLoop; }
   switch( *++progptr ) {
       case ']' :
           if ( !counter ) {           ; goto mainLoop     ;  }
           else            { counter-- ; goto lbrackhandlr ;  } ;
       case '[' : counter++ ; goto lbrackhandlr ;
       case EOF :           ; goto error1       ;
       default  :           ; goto lbrackhandlr ;
   };

rbrackhandlr:
   switch( *--progptr ) {
       case '[' :
           if ( !counter ) { progptr--   ; goto mainLoop     ;  }
           else            { counter--   ; goto rbrackhandlr ;  } ;
       case ']' : counter++ ; goto rbrackhandlr ;
       case EOF :           ; goto error1       ;
       default  :           ; goto rbrackhandlr ;
   }

error1:
   printf("Unbounded loop");
   return ;

end:
   return ;
}
