# Brainforth
### Brainfuck but with a forth dictionary. 

Here is an obvious fact: Brainfuck is hard to write in.

But what if we could extend it to a point where it is bearable?

Here is the result, Brainforth.

The Forth langauge gives a simple and direct way to extend itself.
The mechanism in which it does so is called a dictionary. 
A dictionary is made up of words and their definitions. All words are
both global in respect to scope and local in respect to change. 

Now let's give a notiriously hard language a dictionary to explore how
well this idea works. 

## Usage

Run the build.sh file. Then there should be an executable "bforth".
This executable takes lists of Brainforth files, concats them into one file,
pours the compiled brainfuck code into a file called 'output' and then runs it.

If you want files to compile but not run, 
there is a "-norun" flag option you can give the compiler when compiling 
that will do just that.

## Future Work

Like other Forth implementations, the language is mainly wrote in itself from it's primatives.
Unlike other Forth implementations, it is not exactly clear what are the first steps to continue 
Brainforth's extension into the relm of decent languages. Creating a standard Brainforth Base file 
will be of a continued effort and any thoughts or help is welcomed
