//Amanda Olearczuk
//CPSC 355
//Assignment 6

//The following program takes a file from command line, reads 8 bytes at a time and calculated cubes of these floats. 
//The results are printed in format: Input:       Cube:

.text
errorClosingFile: .string "Error: Closing file\n"
errorCLArguments: .string "Error: Wrong number of command line arguments\n"
errorOpeningFile: .string "Error: Opening file\n"
InputOutputPrint: .string "Input: %.10f Cube: %.10f\n"

define(argc,w20)											//Number of arguments passed from command line
define(argv,x21)											//Base address for command line argument array
define(fd,w19)												//File descriptor to be used later
define(i,x22)												// i used for a while loop later to read file. It will have either val 0 or 1
buf_size = 8												//Reading 8 bytes at a time from file
allocMain = -(16 + buf_size) &16									//alloc memory
deallocMain = -allocMain										//dealloc memory

.balign 4
.global main
main: stp x29,x30,[sp,allocMain]!
      mov x29,sp
	
	//Do actions for command line arguments
	mov argc,w0											//Store num of arg passed from command line
	mov argv,x1											//Store base address for arguments
	
	cmp argc,2											//check if there's only 1 command line argument
	b.ne ErrorCLArguments										//if not, print error and exit

	//Read pathname from command line
	ldr x9,[argv,8]                                                                                 //x9 contains pathname from command line

	//Open file
	
	mov w0,-100											//filename is relative to working directory so dirfd = -100
	mov x1,x9											//arg 2 - pathname 
	mov w2,0											//flags 0 -> open file for read only
	mov w3,0											//Mode - > not used since we are not creating a new file
	mov x8,56											//openat system request
	svc 0												//System call for openat
	
	//error checking

	cmp w0,0											//error check. is w0 = -1 it means error
	b.lt ErrorOpeningFile										//If there was an error opening file, print it and exit
	mov fd,w0											//save file descriptor if file opened successfully
	
	//Read 8 bytes at a time from file and display the cube result

	test: 							
		mov w0,fd
		add x1,x29,16										//Which file to read? fd 
		mov w2,8										//read 8 bytes
		mov x8,63										//63 for reading file request
		svc 0											//sys call
	
		//Error check if we read 8 bytes. If not, exit loop cause we reached end of file
		cmp x0,8
		b.ne exitWhileLoop

		ldr d0,[x1] 										//d0 contains 8 bytes from buffer
		fmov d8,d0   										//d8 contains input (from buffer)

		bl cube 										//fun call
		fmov d9,d0 										//d9 - cube result
	
		adrp x0,InputOutputPrint								//Argument 1 - string format
		add x0,x0,:lo12:InputOutputPrint
		fmov d0,d8										//Argument 2 - input 
		fmov d1,d9										//Argument 3 - output
		bl printf
		b test											

exitWhileLoop:												//Exit while loop if no more bytes to read


	//Close file
	
	mov w0,fd											//file to close 
	mov x8,57											//Close IO request
	svc 0												//sys call

	cmp w0,0
	b.lt ErrorClosingFile	

	b exitMain

ErrorClosingFile:
	
	//Print error, exit main
	adrp x0,errorClosingFile
	add x0,x0,:lo12:errorClosingFile
	
	bl printf

	b exitMain

ErrorOpeningFile:

	//Print error exit main
	adrp x0,errorOpeningFile
	add x0,x0,:lo12:errorOpeningFile
	
	bl printf

	b exitMain

ErrorCLArguments:

	//Print error exit main
	adrp x0,errorCLArguments
	add x0,x0,:lo12:errorCLArguments
	
	bl printf
	
	b exitMain

exitMain:
	
	ldp x29,x30,[sp],deallocMain
	ret


.text
f1: .double 0r3.0											//3.0 used for some calculations
f2: .double 0r1.0e-10											//1.0e-10 used for some calculations

define(y,d16)
define(dy,d17)
define(dydx,d18)
define(x,d19)
define(error,d20)											//Error is abs(dy)
define(a,d21)												//a is input * 1.0e-10
define(input,d22)											//Input from function
define(temp,d23)											//Temp for some immediate result of calculation
define(temp1,d24)

.balign 4
.global cube
cube: stp x29,x30,[sp,-16]!
	mov x29,sp

	fmov input,d0											//Move input to function into safe spot
	
	adrp x0,f1
	add x0,x0,:lo12:f1
	ldr d1,[x0]											//d1 now contains value of f1 = 3.0

	adrp x2,f2
	add x2,x2,:lo12:f2
	ldr d3,[x2]											//d3 contains f2 = 1.0e-10

	fdiv x,input,d1 										//x = input /3.0

	//Post test while loop starts
	
cont:   fmul temp,x,x											//x*x = temp
	fmul y,x,temp											//x*x*x=y
	fsub dy,y,input											//dy= y-i
	fmul temp,x,x											//temp=x*x
	fmul dydx,temp,d1										//temp*f1
	fdiv temp,dy,dydx										//temp=dy/dydx
	fsub x,x,temp											//x- (dy/dydx)

	fabs error,dy											//abs(dy) = error
	fmul a,input,d3											//a = input * f2 

	fcmp error,a											// if error < a , result is complete
	b.lt exitCube											
	b cont												//if error > a, contunue with loop

exitCube:
	
	fmov d0,x											//Move return value  to d0

	ldp x29,x30,[sp],16
	ret
