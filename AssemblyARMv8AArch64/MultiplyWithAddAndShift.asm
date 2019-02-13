//Amanda Olearczuk
//UCID : 300 412 03
//Assignment 2
//Subject: CPSC 355 L01

//The following code multiplies 2 numbers and carries on multiplication in the way computer does it (repeated add and shift instructions)

fmt: .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d) \n\n" //Format of string we print later
fmtt: .string "product = 0x%08x multiplier = 0x%08x\n" //Format of string 2 we print later
fmttt: .string "64-bit result = 0x%016lx (%ld)\n" //Format of string 3 we print later
.balign 4 //ensures instructions are correctly formatted
.global main
main: stp x29,x30,[sp,-16]! //Allocate stack space
mov x29,sp                  //Update FP

//1.Initialize the 32bit integers and 64bit long integers.

mov w19,70 //Initialize "multiplier" to 70
mov w20,-16843010 //Initialize "multiplicand" to -16843010
mov w21,0 //Initialize "product" to 0
mov w22,0 //Initialize "i" to 0
mov w23,0 //Initialize "negative" to 0 - which stands for FALSE

mov x24,0 //Initialize "result" to 0
mov x25,0 //Initialize "temp1" to 0
mov x26,0 //Initialize "temp2" to 0

//Define 32bit integers
define(multiplier,w19)
define(multiplicand,w20)
define(product,w21)
define(i,w22)
define(negative,w23)

//Define 64bit long integers
define(result,x24)
define(temp1,x25)
define(temp2,x26)

//2.Print initial values of multiplier,multiplicand in format: 
// multiplier = hexnumber (number) multiplicand = hexnumber (number)

adrp x0,fmt //puts address of formatted string to x0 (x0 will go to function printf)
add x0,x0,:lo12:fmt //argument 1 address of the string 
adrp x1,fmt //puts address of formatted string to x1 (x1 will go to function printf)
add x1,x1,:lo12:fmt //argument 2 address of the string
adrp x2,fmt  //puts address of formatted string to x2 (x2 will go to function printf)
add x2,x2,:lo12:fmt //argument 3 address of the string
adrp x3,fmt //puts address of formatted string to x3 (x3 will go to function printf)
add x3,x3,:lo12:fmt //argument 4 address of the string
		
mov w1,w19 //argument 1 for printf function with hex number corresponding to "multiplier"
mov w2,multiplier //argument 2 for printf with value of "multiplier" 
mov w3,w20 //argument 3 for printf function with value of hex number corresponding to "multiplicand"	
mov w4,multiplicand //argument 4 for printf functtion with value of "multiplicand"

bl printf //function call with arg 1 and 2

//3.Determine if multiplier is negative using if statement

//If block start
	cmp multiplier,0 //Check flags for "multiplier" and zero
	b.ge endif //Check if multiplier>=0 If it is, end the loop
        mov negative,1 //Else, if multiplier is negative, set negative to 1
endif:

//4.Do repeated add and shift instruction

define(i,x27) //define i macro with location x27
mov i,0 //initialize i = 0

//While loop start
top:	
		  //If statement
	          tst multiplier,0x1 //Sets flags without storing the result. Alias for ANDS. Bitmap: 0x1
		  b.eq bitclear //Checks if result is bit set or bit clear
		  add product,product,multiplicand //If bit is set, add product to multiplicand	
	bitclear:	//If bit is clear, continue with the while loop 

	//5.Arithmetic shift right the combined product and multiplier

	asr multiplier,multiplier,1 //Shift multiplier by shift count 1

	//If statement

		   tst product,0x1 //Alias to ANDS, sets flags without storing result. Bitmap: 0x1
		   b.eq bitclearr  //If the set bit is 0, go to bitclear:
		   orr multiplier,multiplier,0x80000000 //Inclusive OR bitwise operation.
		   b next //Exit if/else block	
	bitclearr:	and multiplier,multiplier,0x7FFFFFFF // AND bitwise operation. Bitmask : 0x7FFFFFFF
			b next //Exit if/else block

	next:		asr product,product,1 // Shift right by 1

	add i,i,1 //Incements i by i, so the while loop can continue
test:   cmp i,32
        b.lt top

//6.Adjust product register if multiplier is negative

//If statement
	cmp negative,1 //Check if negative is set to 1
	b.ne endiff   //If negative is set to 0, exit loop
	sub product,product,multiplicand //Subtraction. product = product-multiplicand
	
endiff:


//7.Print out product and multiplier

adrp x0,fmtt //puts address of formatted string to x0 (x0 will go to function printf)
add x0,x0,:lo12:fmtt //argument 1 address of the string 
adrp x1,fmtt //puts address of formatted string to x1 (x1 will go to function printf)
add x1,x1,:lo12:fmtt //argument 2 address of the string

mov w1,product //argument 1 for printf  function with "product"
mov w2,multiplier //argument 2 for printf with value of "multiplier" 

bl printf //function call with arg 1 and 2

//8.Combine product and multiplier together

define(productLongInt,x27) //Define productLongInt
sxtw productLongInt,product //Signed extend word operation. product 32bit becomes productLongInt 64bit.
and temp1,productLongInt,0xFFFFFFFF //And operation stored in temp1
lsl temp1,temp1,32 //Arithmetic Shift Left by 32 of temp1.

define(multiplierLongInt,x28) //Define multiplierLongInt
sxtw multiplierLongInt,multiplier //Sign extend word multiplier 32bit becomes multiplierLongInt 63bit
and temp2,multiplierLongInt,0xFFFFFFFF //And bitwise operation stored in temp2

add result,temp1,temp2 //Adding temp1 + temp2 to achieve a final result

//9.Print out 64-bit result

adrp x0,fmttt //puts address of formatted string to x0 (x0 will go to function printf)
add x0,x0,:lo12:fmttt //argument 1 address of the string 
adrp x1,fmttt //puts address of formatted string to x1 (x1 will go to function printf)
add x1,x1,:lo12:fmttt //argument 2 address of the string

mov x1,result //argument 1 for printf function corresponding to result
mov x2,result //argument 2 for printf function corresponding to result 

bl printf //function call with arg 1 and 2
	 
programend://Endpoint just for gdb testing.

ldp x29,x30,[sp],16 //Restore stack
ret		    //Return to OS










