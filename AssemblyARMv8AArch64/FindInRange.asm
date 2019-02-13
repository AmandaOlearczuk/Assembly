//Amanda Olearczuk
//UCID : 300 412 03
//Assignment 1 - Optimized version
//Subject: CPSC 355 L01

//The following program finds the maximum of y = (-5x^3 -31x^2 + 4x +31) for the range of x -6<=x<=5.
//It prints current x and y value with each loop iteration and also current maximum value with each iteration.

fmt: .string "Current x = %d, Current y = %d, Current maximum y = %d\n" //Format of string we print later

.balign 4 //ensures instructions are correctly formatted
.global main
main: stp x29,x30,[sp,-16]! //allocate stack space
mov x29,sp //update FP (frame pointer register)

//Below are hard coded values for "y" formula
mov x21,-5 //-5 is the value in the y = -5x^3 - 31x^2 + 4x + 31 formula. We store it in x21 register
mov x22,-31 //-31 is value in the "y" formula, we store 31 is x22 register
mov x23,4 //4 is the value in the "y" formula, we store it in x23 register
mov x24,31 //31 is the value in the "y" formula, we store it in x24 register

//Below are variables for while loop that keep changing with each loop iteration
mov x19,-6 //Initial value of x, will change by each loop iteration
define(currX,x19) //currentX is x used with each loop iteration. Initial value is -6, stored in x19

mov x20,-29	//Initial value of maxY
define(maxY,x20) //Current maximum Y, initial value is -29 stored in register x20

mov x25,0 //this is calculated "y" from formula, changes with each loop iteration
define(calcY,x25) //calculated y changed with each loop iteration for given x, initial value is 0 stored in x25.

mov x26, 0 //Set value of x26 to 0. (Initial value of "y" formula multiplication part ; (-31)*(x)*(x))
mov x27,0 //Set value of x27 to 0. (Initial value of "y" formula multiply part ;  4*x+31

//While loop start

	b test //Jumps to test (Goes to check while conditional on bottom)

        //Loop body start (pre-test loop)

        //1.y value is calculated using formula: y = -5(x)(x)(x) + (-31(x)(x)) + 4(x) + 31

top:    mul calcY,x21,currX      //Multiplies -5 * x  
        mul calcY,calcY,currX    //Multiplies -5x * x       
        mul calcY,calcY,currX    //Multiplies (-5x^2) * x 
        mul x26,x22,currX        //Multiply -31 * x
        mul x26,x26,currX        //Multiply (-31x) * x
        add calcY,calcY,x26      //Add (-5x^3) + (-31x^2)
        madd x27,x23,currX,x24   //Multiplies 4 * x and adds 31 to result
	add calcY,calcY,x27      //Adds (-5x^3)+(-31x^2) to 4x+31 for final result stored in calcY
	
        //2. Check if y value calc. from formula stored in is bigger than current maximum Y stored

        //If block start
        maxYTest:       cmp calcY,maxY //Check flags for calculated y, and maximum y
                        b.le endif //Check if y<=maxY, if so, go to endif and do nothing
                        mov maxY,calcY //Else, if y>maxY, move value of y to maxY. 
        endif:	

        //3. Print maximum y as well as current values of y and x
        adrp x0,fmt //puts address of formatted string to x0 (x0 will go to function printf)
        add x0,x0,:lo12:fmt //argument 1 address of the string 
        adrp x1,fmt //puts address of formatted string to x1 (x1 will go to function printf)
        add x1,x1,:lo12:fmt //argument 2 address of the string
        adrp x2,fmt  //puts address of formatted string to x2 (x2 will go to function printf)
        add x2,x2,:lo12:fmt //argument 3 address of the string

        mov x1,currX //argument 1 for printf function with value of current x
        mov x2,calcY //argument 2 for printf function with value of current y calc. from "y" formula 
        mov x3,maxY //argument 3 for printf function with value of maximum y     

        bl printf //function call with arg 1 and 2

        //4.Reset values to their initial state
        mov calcY,xzr //Reset "y" formula value register to zero
        mov x26,xzr //Reset value of (-31)*x*x from "y" formula to zero
        mov x27,xzr //Reset value of 4*x part from "y" formula to zero

        //5.Increment x by 1 
        add currX,currX,1 //Increment current x by one (x++ equivalent)

	//While loop condition
test:   cmp currX,6 //This line sets flags. (6 is the terminating value in while loop so  when x>=6 - loop terminates)
        b.lt top //Check if x is less than 6, if so, go to top.
        

done:
//While loop end         

ldp x29,x30,[sp],16 //restore stack
ret //return to OS                                                                                                                                                                                                                                                                                                                             






                                        
