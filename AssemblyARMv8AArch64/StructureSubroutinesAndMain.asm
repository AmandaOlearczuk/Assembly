//Amanda Olearczuk
//300 412 03
//CPSC355
//Assignment 4

//The program below carries a main function and from there, a series of sub-functions that manipulate contents of the initialized structures in main called ; first and second

FALSE = 0
TRUE = 1
box_size = 4*5  						//5 values * 4 bytes each = size of structure
alloc = -(16 + box_size + box_size) & -16 			//Allocate space for 2 structures and frame record
dalloc = -alloc                                                 //Bytes to deallocate is a negation of alloc

//Formats of strings we will use later
stringFIRST: .string "first"					//String for the printBox function argument
stringSECOND: .string "second"                                  //String for the printBox function argument
fmtInit: .string "Initial Box values:\n"                                //String for printf argument
fmtAfter: .string "\nChanged box values:\n"                             //String for printf argument

.balign 4
.global main
main: stp x29,x30,[sp,alloc]!
      mov x29,sp

      first_s = 16 						//first structure is right under frame record
      second_s = first_s + box_size 				//16 + 20 offset, second is under first

      box_origin_s = 0 						//offset for origin
      box_origin_x_s = 0 					//Nested offset for origin.x
      box_origin_y_s = 4 					//Nested offset for origin.y

      box_size_s = 8 						//Offset for size
      box_size_w_s = 0 						//Nested offset for size.width
      box_size_h_s = 4 						//Nested offset for size.height

      box_area_s = 16 						//Offset for area

      add x8,x29,first_s 					//Set x8 to address of top of the first box structure
      bl newBox                                                 //Call newBox to initialize  values of first box structure

      add x8,x29,second_s                                       //Set x8 to address of top of the second box structure
      bl newBox                                                 //Call newBox to initialize values of second box structure

      //Print values of initialized structures

      adrp x0,fmtInit                                           //x0 is first argument passed to printf to print string at fmtInit: above main
      add x0,x0,:lo12:fmtInit
      
      bl printf

      //Print first structure
	
      adrp x0,stringFIRST				       //x0 contains address of the string - first argument to function printBox
      add x0,x0,:lo12:stringFIRST
      add x1,x29,first_s				       //x1 is the second argument for printBox function, contains exact address for "first" structure      
      bl printBox					       //Call printBox with x0 - String and x1 - pointer to first structure

      //Print second structure

      adrp x0,stringSECOND                                     //x0 contains address of the string - first argument to printBox function
      add x0,x0,:lo12:stringSECOND                           
      add x1,x29,second_s                                      //x1 is second argument for printBox, contains exact address to second structure we pass                           
      bl printBox 					       //Call printBox with x0 - String and x1 - pointer to second structure
       
      add x0,x29,first_s			               //x0 contains exact address of start of first box structure
      add x1,x29,second_s			               //x1 contains exact address of start of second box structure
      bl equal                                                 //Function call to see if these 2 structures are equal - result in w0

      //Check if structures are equal, and if they are, do move and expand operations

      cmp w0,wzr 					       //Compare if w0 == 0, if w0 == 0 , structures aren't equal, if w0 == 1 , structures are equal
      b.eq end						       //If w0 == 0 == wzr == 0 , exit the if statement since structures aren't equal
	
      //Move function
      
      add x0,x29,first_s                                      //First argument for move function is a pointer to first structure
      mov w1,-5                                               //Second argument is deltaX
      mov w2,7                                                //Third argument is deltaY

      bl move                                                 //Call function move with above arguments	
      
     //expand function

      add x0,x29,second_s                                     //First argument for expand function is a pointer to second structure
      mov w1,3                                                //Second argument for expand function is an int factor
      bl expand
end:

     //Print updated structures

      adrp x0,fmtAfter                                           //x0 is first argument passed to printf to print string at fmtInit: above main
      add x0,x0,:lo12:fmtAfter

      bl printf

      //Print first structure

      adrp x0,stringFIRST                                      //x0 contains address of the string - first argument to function printBox
      add x0,x0,:lo12:stringFIRST
      add x1,x29,first_s                                       //x1 is the second argument for printBox function, contains exact address for "first" structure      
      bl printBox                                              //Call printBox with x0 - String and x1 - pointer to first structure

      //Print second structure

      adrp x0,stringSECOND                                     //x0 contains address of the string - first argument to printBox function
      add x0,x0,:lo12:stringSECOND
      add x1,x29,second_s                                      //x1 is second argument for printBox, contains exact address to second structure we pass                           
      bl printBox   


ldp x29,x30,[sp],dalloc						//Restore pair
ret								//return to OS


//Move function below, moves x and y coordinates of box by factors deltaX and deltaY

.balign 4                                                     //Machine instructions below must be word aligned
move: stp x29,x30,[sp,-16]!
      mov x29,sp                                              //Make FP == SP initially

      define(str_base_r,x9)                                   //Base address for this structure
      mov str_base_r,x0                                       //Initialize to x0 - argument passed with the address
       
      ldr w10,[str_base_r,box_origin_s + box_origin_x_s]      //Load w10 with current origin.x value
      add w10,w10,w1                                          //Add origin.x to delta X contained in w1
      str w10,[str_base_r,box_origin_s + box_origin_x_s]      //Store the updated origin.x value to address

      ldr w10,[str_base_r,box_origin_s + box_origin_y_s]      //Load w10 with current origin.y value
      add w10,w10,w2                                          //add origin.y to deltaY contained in w2
      str w10,[str_base_r,box_origin_s + box_origin_y_s]      //Store updated origin.y to address

      ldp x29,x30,[sp],16                                   //Restore register pair
      ret                                                   //Return to calling code

	
//newBox initializing function below

define(box_base_r,x9)
allocNEWBOX = -(16 + box_size) & -16 				//Allocate space for 1 box structure and frame record itself
dallocNEWBOX = -allocNEWBOX
box_s = 16							//Offset for box structure is 16 - just after the frame record which is 16 bytes long

.balign 4							//Machine instructions below must be word aligned too!
//Registers used: x9,w10,w11
newBox: stp x29,x30,[sp,allocNEWBOX]!
        mov x29,sp

	add box_base_r,x29,box_s				//box_base_r contains exact address of top of structure

	//Store values to local structure on stack

	str wzr,[box_base_r,box_origin_s + box_origin_x_s]     //Store 32bit 0 to local origin.x
	str wzr,[box_base_r,box_origin_s + box_origin_y_s]     //Store 32bit 0 to local origin.y

	mov w10,1 					       //Initialize w10 to 32-bit 1
	str w10,[box_base_r,box_size_s + box_size_w_s]         //Store 32bit 1 to local size.width
	str w10,[box_base_r,box_size_s + box_size_h_s]         //Store 32bit 1 to local size.height

	str w10,[box_base_r,box_area_s]			       //Store 32bit size.width * size.height = 1 to area

	//Load w11 with value from local structure and then put this value into an actual structure from main()

	ldr w11,[box_base_r,box_origin_s + box_origin_x_s]     //Load origin.x from local stack
	str w11,[x8,box_origin_s + box_origin_x_s]             //Place loaded origin.x to actual structure from main()

	ldr w11,[box_base_r,box_origin_s + box_origin_y_s]     //Load origin.y from local stack
	str w11,[x8,box_origin_s + box_origin_y_s]             //Place loaded origin.y to actual structure from main()

	ldr w11,[box_base_r,box_size_s + box_size_w_s]        //Load size.width from local stack
	str w11,[x8,box_size_s + box_size_w_s]	              //Store loaded size.width to actual structure in main()

	ldr w11,[box_base_r,box_size_s + box_size_h_s]        //Load size.height from local stack
        str w11,[x8,box_size_s + box_size_h_s]                //Store loaded size.height to actual structure in main()

	ldr w11,[box_base_r,box_area_s]			      //Load area from local stack
	str w11,[x8,box_area_s]				      //Store loaded area to actual main()

	//End the function

	ldp x29,x30,[sp],dallocNEWBOX			      //Restore register pair
	ret 						      //Return to calling code, main()


//equal function below , checks if 2 structures are equal

result_size = 4
allocEQUAL = -(16 + result_size) & -16 			     //Space allocated for int RESULT and frame record itself
dallocEQUAL = - allocEQUAL
//Registers used: x9,x10,x11,w12,w13,w14,w15
.balign 4
equal: stp x29,x30,[sp,allocEQUAL]!                          //Allocate space for method
       mov x29,sp                                            //Make FP = FP

      define(first_base_r,x9)				     //Let first_base_r be exact address for first structure in main
      define(second_base_r,x10)                              //Let second_base_r be exact address to top of second structure in main

      mov first_base_r,x0                                    //Initialize first_base_r to argument address from main
      mov second_base_r,x1                                   //Initialize second_base_r to argument address from main

      result_s = 16 					     //result offset

      mov w14,FALSE                                          //Move value of FALSE to w14
      mov w15,TRUE                                          //Move TRUE to w15
      str w14,[x29,result_s]                     //Store 0 to result on stack

      ldr w0,[x29,result_s]                        //Load return variable from stack - at this point it's 0

      //Start comparing variables of first and second structures

      define(a,w12) 			                      //temp for first compared value
      define(c,w13)			                      //temp for second comp

      //First comparison: b1.origin.x == b2.origin.x

      ldr a,[first_base_r,box_origin_s + box_origin_x_s]     //Load first compared variable with b1.origin.x
      ldr c,[second_base_r,box_origin_s + box_origin_x_s]    //Load second compared variable with b2.origin.x

      cmp a,c
      b.ne exit                                              //If b1.origin.x != b2.origin.x , exit the loop

      //Second comparison: b1.origin.y == b2.origin.y

      ldr a,[first_base_r,box_origin_s + box_origin_y_s]     //Load a with b1.origin.y
      ldr c,[second_base_r,box_origin_s + box_origin_y_s]    //Load b with b2.origin.y

      cmp a,c                                                //If b1.origin.y != b2.origin.y, exit loop
      b.ne exit

      //Third comparison: b1.size.width == b2.size.width

      ldr a,[first_base_r,box_size_s + box_size_w_s]        //Load a with b1.size.w
      ldr c,[second_base_r,box_size_s + box_size_w_s]       //Load b with b2.size.w

      cmp a,c                                               //If b1.size.w != b2.size.w , exit loop
      b.ne exit

      //Fourth comparison: b1.size.height == b2.size.height

      ldr a,[first_base_r,box_size_s + box_size_h_s]       //Load a with b1.size.h
      ldr c,[second_base_r,box_size_s + box_size_h_s]      //Load b with b2.size.h

      cmp a,c						   //Compare b1's and b2's heights
      b.ne exit                                            //If they are not the same, exit loop

      //By this point, all structure's values are same

      str w15,[x29,result_s]			   //Store result variable on stack with TRUE so value 1 if all conditions above hold

      ldr w0,[x29,result_s]                      //Load the RETURN variable from stack to w0 if all conditions above hold

      exit:



     ldp x29,x30,[sp],dallocEQUAL                         //Restores pair
     ret  


//printBox function below, prints the contents of box 


fmt: .string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n" //Format of string we will use for this function
.balign 4
printBox: stp x29,x30,[sp,-16]!                            //Allocate 16bytes on stack for printBox function's frame record   
	  mov x29,sp

          mov x10,x0                                       //x10 stores the string value passed as an argument to this function

	  define(struct_base_r,x9)
	  mov x9,x1                                        //Store base address for structure in x9 passed for this function

	  adrp x0,fmt                                      //first argument is address to string which is a format to print 
          add x0,x0,:lo12:fmt
          
	  mov x1,x10                                             //x1 is the address to string for argument for printf
          ldr w2,[struct_base_r,box_origin_s + box_origin_x_s]   //Access origin.x variable of the structure passed as argument - store in w2
	  ldr w3,[struct_base_r,box_origin_s + box_origin_y_s]   //Access origin.y var of structure - store in w3
	  ldr w4,[struct_base_r,box_size_s + box_size_w_s]       //Access size.width var of structure - store in w4
          ldr w5,[struct_base_r,box_size_s + box_size_h_s]       //Access size.height var of structure - store in w5
          ldr w6,[struct_base_r,box_area_s]                      //Access area var of structure - store in w6

	  bl printf
 
          ldp x29,x30,[sp],16                                   //Restore reguster pair
	  ret                                                   //Return to calling code


//Expand function - multiplies x.width and x.height by an integer factor, and updates the area

expand: stp x29,x30,[sp,-16]!
        mov x29,sp

	define(structEXPAND_base_r,x9)
        mov x9,x0	                                        //Set x9 to structEXPAND_base_r with base address of the passed structure

	ldr w10,[structEXPAND_base_r,box_size_s + box_size_w_s] //Load w10 with size.width
        mul w10,w10,w1                                          //multiply size.width by factor
	str w10,[structEXPAND_base_r,box_size_s + box_size_w_s] //store the updated size.width

	ldr w10,[structEXPAND_base_r,box_size_s + box_size_h_s] //load w10 with size.height
        mul w10,w10,w1                                          //multiply size.height by factor
	str w10,[structEXPAND_base_r,box_size_s + box_size_h_s] //store updated side.height

	ldr w10,[structEXPAND_base_r,box_area_s]               //load w10 with value of area
        ldr w11,[structEXPAND_base_r,box_size_s + box_size_w_s] //load w11 with value of size.width
        ldr w12,[structEXPAND_base_r,box_size_s + box_size_h_s] //load w12 with value of size.height

	mul w10,w11,w12                                         //multiply width and height and store in w10
	str w10,[structEXPAND_base_r,box_area_s]               //store area back to structure address



       ldp x29,x30,[sp],16                                     //restore pair
       ret                                                     //return to calling code



                                                          
