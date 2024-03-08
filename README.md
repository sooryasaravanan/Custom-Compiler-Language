# CS-152-Project-Phase 0
Programing Language Name: WIP-L[^1]
Extension Name: Example.wip[^1]
Compilier Name: WIP-LC[^1]

|     Language Feature                              | Code Example                 |
|---------------------------------------------------|------------------------------|
| Integer Scalar Variables                          | inte x eq 0;                      |
| One-Dimensional Arrays of Integers                | inte arr x(5);                   |
| Assignment Statements                             | inte x eq 1;                 |
| Arithmetic Operators ("+")                        | inte x eq 1++2;               |
| Arithmetic Operators ("-")                        | inte x eq 2--1;               |
| Arithmetic Operators ("*")                        | inte x eq 2**1;               |
| Arithmetic Operators ("/")                        | inte x eq 2//1;               |
| Arithmetic Operators ("%")                        | inte x eq 2%%1;               |
| Relational Operators ("<")                        | i(x << y);                   |
| Relational Operators ("<=")                        | i(x <<= y);                   |
| Relational Operators (">=")                        | i(x >>= y);                   |
| Relational Operators ("==")                       | i(x EE y);                   |
| Relational Operators (">")                        | i(x >> y);                   |
| Relational Operators ("!=")                       | i(x N= y);                   |
| While Loop            | inte x eq 0; <br> W(x EE 8){x eq x++1;}                  |
| While Loop ("Continue")      | W(x EE 8){ <br> x eq x++1; <br> i(x EE 2){Con}}                   |
| While Loop (Includes "Break")      | W(x EE 8){ <br> x eq x++1; <br> i(x EE 2){Br}}                   |
| If-then-else Statements                           | i(x EE 1){ <br> x eq 2; <br> } <br> e{x eq 1;}                      |
| Read Statements                                   | Read a;                  |
| Write Statements                                  | Write a;                |
| Comments                                          | ^^communication, <br> ^* is <br> key <br>*^                    |
| Functions (Take and return single scalar results) | function add(inte x, inte y) {<br> x eq 1; <br> y eq 2; <br> inte z eq x++y; <br> return z;}|

* WIP is case sensative
* Valid Identifier must start with (a-z) and can have letters and numbers after whether it be upper or lower case, 
  cannot contain special characters ($, &, #, ...)
* Comment on the same line would look like this (^ This is a comment ^)
* Comment on different lines would look like this (^* This is a comment *^)
* The WIP compilier will ignore whitespaces

| Language Feature | Token Name   |
|------------------|--------------|
| inte             | INTEGER      |
| (                | ARRAY_OPEN   |
| )                | ARRAY_CLOSE  |
| eq               | EQUAL        |
| ++               | ADD          |
| --               | SUB          |
| **               | MULTI        |
| //               | DIV          |
| <<               | LESS-THAN    |
| EE               | EQUALITY     |
| >>               | GREATER-THAN |
| >=               | GREATER-EQUAL|
| <=               | LESS-EQUAL   |
| N=               | NOT-EQUAL    |
| W                | WHILE-LOOP   |
| Br               | BREAK        |
| Con              | CONTINUE     |
| i                | IF           |
| e                | ELSE         |
| read             | READ         | 
| write            | WRITE        |
| ^^               | COMMENT      |
| 0-9              | NUMBER       |
| A-Z a-z          | ALPHA        |
| ;                | SEMICOLON    |
| {                | OPEN_BRACKET |
| }                | CLOSE_BRACKET|
| string           | STRING       |
| %%               | MOD          |
| arr              | ARRAY        |


