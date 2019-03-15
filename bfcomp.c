#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#define MEMSIZE 100000

void execute( const char * filename) {

    FILE *file = fopen(filename, "r") ;
    if(!file){
       printf("something went wrong with: ")   ;
        printf("%s", filename);
       return                                  ;
    }
   
   rewind(file)                                ;

   char array[MEMSIZE] = {0}                   ;

  // for (int i = 0 ; i < MEMSIZE ; i++ ) {array[i] = '\0';} ;
   

   char *ptr=array                             ;

   int  counter = 0                            ;
   char current                                ;

   char * progptr                              ;


   fseek(file,SEEK_SET , SEEK_END)             ;

   const int pSize = ftell(file)               ; 

   char program[pSize]                         ;
   progptr = program                           ;
   rewind(file)                                ;


   while (!feof(file)) {
      fscanf(file, "%c" , &current)            ;
      program[counter++] = current             ;
   }
   fclose(file)                                ;

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

error2:
   printf("Ran out of memory");
   return ;
end:
   return ;
}
