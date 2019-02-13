//amanda Olearczuk
//cpsc 355
//Assignment 5
//30041203



//The following program implements a data structure : queue. Operations such as enqueue, dequeue, displayqueue are available. 


.data

//Global values declaration

.global head
.global tail
.global queue

head: .word -1
tail: .word -1
queue: .word 0,0,0,0,0,0,0,0

.text

//Constants declaration

QUEUESIZE: .word 8
MODMASK: .word 0x7
FALSE: .word 0
TRUE: .word 1

//Print formats declaration

overflow_msg: .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
underflow_msg: .string "\Queue underflow! Cannot dequeue from an empty queue.\n"
empty_msg: .string "\nEmpty queue\n"
current_msg: .string "\nCurrent queue contents:\n"
head_msg: .string " <-- head of queue"
tail_msg: .string " <--tail of queue"
space_msg: .string "\n"
item_msg: .string " %d"

//**********************************************This function adds a value to queue***********************************

.balign 4
 
enqueueAlloc = -(16 + 4) & -16										//Alloc space for stack frame plus 4 bit integer - creates 12 pad bytes
enqueueDealloc = -enqueueAlloc

.global enqueue
enqueue: stp x29,x30,[sp,enqueueAlloc]!
         mov x29,sp

	//Store 1st argument on stack
	str w0,[x29,16]
         
	//First if statement - check if queue is full	

         bl queueFull

	cmp w0,1											//Compare 1/0 with 1 to see if queue is full
	b.ne queueEmptyCheck										//If queue isn't full, check if it's empty
		
		adrp x0,overflow_msg
		add x0,x0,:lo12:overflow_msg
	
		bl printf										//Queue is full- print message to user and exit function
		b exitEnqueue

	//Second if/else statement - check if queue is empty

	queueEmptyCheck:

		bl queueEmpty
		
		cmp w0,1
		b.ne QueueNotEmpty
			
			//head = 0 , tail =0
			adrp x9,head
			add x9,x9,:lo12:head								//Address of head

			adrp x10,tail
			add x10,x10,:lo12:tail								//Address of tail 
			
			mov w11,0
			
			str w11,[x9]  									//Store 0 to head
			str w11,[x10]									//Store 0 to tail
			
                        b exitEnqueue


		QueueNotEmpty: 
			
			//tail++ & MODMASK
			
			adrp x9,tail
			add x9,x9,:lo12:tail								//Address of tail

			ldr w10,[x9]									//load value of tail
			
			add w10,w10,1 									//tail++
			
			adrp x11,MODMASK
			add x11,x11,:lo12:MODMASK
			
			ldr w12,[x11]									//load value of MODMASK
			
			and w10,w10,w12									//tail++ & MODMASK = tail

			str w10,[x9]									//store new value of tail by it's address		



exitEnqueue:
		
	//Set queue[tail] = value;

	adrp x9,tail
	add x9,x9,:lo12:tail
	
	ldr w10,[x9]											//w10 contails value of tail

	ldr w11,[x29,16]										//w11 has "value" that user input to the function
	
	adrp x12,queue
	add x12,x12,:lo12:queue

	str w11,[x12,w10,SXTW 2]                                                                        //offset = index*element size = tail's index * 4 (int)

	ldp x29,x30,[sp],enqueueDealloc
	ret


//*******************************************This function removes a value from queue*************************************8


w19_size = 4
allocDequeue = - (16 + w19_size) & -16
deallocDequeue = -allocDequeue

.balign 4
.global dequeue
dequeue: stp x29,x30,[sp,allocDequeue]!
         mov x29,sp
	
	str w19,[x29,16]										//Store w19 on stack
	
	define(value,w19)

	bl queueEmpty											//returns 1 if queue is empty
	cmp w0,1											//check flags
	b.ne contin											//If queue isnt empty, continue with code
	
		adrp x0,underflow_msg
		add x0,x0,:lo12:underflow_msg
		bl printf										//Print underflow message

		mov w0,-1										//Return -1
		
		b exitDequeue
	
	contin:
	
	adrp x9,head
	add x9,x9,:lo12:head										//x9 - address of head
	ldr w10,[x9]											//w10 - value of head

	adrp x11,queue
	add x11,x11,:lo12:queue										//x11- address of tail
	ldr value,[x11,w10,SXTW 2]									//load value with queue[head]

	adrp x11,tail
	add x11,x11,:lo12:tail
	ldr w12,[x11]											//w12 - value of tail

	cmp w10,w12											//Compare head and tail
	b.ne tryElse
		
		mov w13,-1
		str w13,[x9]										//store -1 in head
		str w13,[x11]										//store 01 in tail
	
		b lastStatement

	tryElse:
		add w10,w10,1										//head++
		adrp x14,MODMASK
		add x14,x14,:lo12:MODMASK	
		ldr w15,[x14]										//w15 - value of MODMASK
		
		and w10,w10,w15										//head++ & MODMASK
		str w10,[x9]										//Store new head to address

lastStatement:
	
	mov w0,value											//Return value

exitDequeue:	
		
	ldr w19,[x29,16]										//Restore w19

	ldp x29,x30,[sp],deallocDequeue
	ret


//**************************************** This leaf function checks if queue is full*****************************

.balign 4
.global queueFull
queueFull: stp x29,x30,[sp,-16]!
           mov x29,sp
	
	//Calculate tail++ & MODMASK

	adrp x9,tail
	add x9,x9,:lo12:tail 										//Address of tail loaded
	
	ldr w10,[x9]	     										//tail stored in register

	add w10,w10,1											//tail++
	
	adrp x11,MODMASK
	add x11,x11,:lo12:MODMASK									//Address of MODMASK loaded
	
	ldr w12,[x11]											//MODMASK stored in register

	and w10,w10,w12											//tail++ & MODMASK stored in register

	//Load head	

	adrp x9,head
	add x9,x9,:lo12:head
	
	ldr w11,[x9]											//head  stored in register

	//Check if queue is full

	cmp w10,w11											//Compare (tail++ & MODMASK) with head
	b.ne queueNotFull

        	adrp x10,TRUE
		add x10,x10,:lo12:TRUE									//Load register with 1 (true)
   		
		ldr w0,[x10]										//w0 contains return value -> integer
        
		b exitQueueFull

	queueNotFull:

		adrp x10,FALSE
		add x10,x10,:lo12:FALSE									//Load register with 0 (false)

      		ldr w0,[x10] 										//w0 contains return value -> integer 
	
	exitQueueFull:
 
	ldp x29,x30,[sp],16
	ret



//*******************This is a leaf function that checks if queue is empty*********************************

.balign 4
.global queueEmpty
queueEmpty: stp x29,x30,[sp,-16]!
            mov x29,sp

	adrp x9,head
	add x9,x9,:lo12:head										//head loaded into register

        ldr w10,[x9]

	cmp w10,-1											//compare head with -1
       	b.ne queueNotEmpty
 		
		adrp x10,TRUE
                add x10,x10,:lo12:TRUE                                                                  //Load register with 1 (true)

                ldr w0,[x10]                                                                              //w0 contains return value -> integer

		b exitQueueEmpty	

	queueNotEmpty:
	
		adrp x10,FALSE
                add x10,x10,:lo12:FALSE                                                                 //Load register with 0 (false)

                ldr w0,[x10]                                                                              //w0 contains return value -> integer 

	exitQueueEmpty:

	ldp x29,x30,[sp],16
	ret



//**************************This function displays queue in a nice format to the user***************************


w19_size = 8
w20_size = 8
w21_size = 8

w19_s = 0
w20_s = 8
w21_s = 16

allocDisplay = -(16 + w19_size + w20_size + w21_size) & -16
deallocDisplay = -allocDisplay

.balign 4
.global display
display: stp x29,x30,[sp,allocDisplay]!
         mov x29,sp

	//Store registerx w19,w20,w21 on stack	

         add x9,x29,32                                         						//x9 holds base address for w19,w20,w21 on stack

	str w19,[x9,w19_s]
	str w20,[x9,w20_s]
	str w21,[x9,w21_s] 										//Store w19,w20,w21 on stack

	define(count,w21)
	define(i,w19)
	define(j,w20)

	//first if statement if(queueEmpty())
	
	bl queueEmpty
	
	cmp w0,1											//Check if queue is empty
	b.ne continue 											//If queue isnt empty, continue with code
	
		adrp x0,empty_msg
		add x0,x0,:lo12:empty_msg
		
		bl printf										//Print message to user that queue is empty
		
		b exitDisplay
	
	continue:
	
	//initialize count

	adrp x9,tail
	add x9,x9,:lo12:tail
        ldr w10,[x9] 											//w10 contains value of tail

	adrp x9,head
	add x9,x9,:lo12:head
	ldr w11,[x9]											//w11 contains value of head

	sub w9,w10,w11     										//tail - head
	add count,w9,1											//count = tail - head +1

	//Seacond if statement if(count<=0)

	cmp count,0											//Compare count and 0
	b.gt cont											//If count > 0  continue with code
		
		adrp x9,QUEUESIZE
		add x9,x9,:lo12:QUEUESIZE
		ldr w10,[x9]										//w10 has value of QUEUESIZE

		add count,count,w10									//count = count + queuesize
	
	cont:

	adrp x0,current_msg
        add x0,x0,:lo12:current_msg
        bl printf                                                                               	//Print current contents of a queue

	adrp x9,head
	add x9,x9,:lo12:head
	ldr w10,[x9]											//w10 contains value of head

	mov i,w10											// i = head

	//While loop start 
	mov j,0												//Initialize j to 0

	test:	cmp j,count										//Compare j and count
		b.ge exitDisplay


		adrp x0,item_msg
		add x0,x0,:lo12:item_msg								//Address of string to print
	
		adrp x9,queue
		add x9,x9,:lo12:queue									//x9 contains base address for queue

		ldr w1,[x9,i,SXTW 2]									//offset = index * element size , w1 contains queue[i]

		bl printf

		//Inner if statement if(i==head)

		adrp x9,head
		add x9,x9,:lo12:head
		ldr w10,[x9]										//w10 contains value of head
		
		cmp i,w10										//Does i=head ?
		b.ne	iNotEqualHead

			adrp x0,head_msg
			add x0,x0,:lo12:head_msg
		
			bl printf									//Print head message

		iNotEqualHead:
	
		//Inner if statement if(i==tail)
	
		adrp x9,tail
                add x9,x9,:lo12:tail
                ldr w10,[x9]                                                                            //w10 contains value of tail

		cmp i,w10
		b.ne iNotEqualTail
		
			adrp x0,tail_msg
                        add x0,x0,:lo12:tail_msg

                        bl printf                                                                       //Print tail message
		
		iNotEqualTail:
	
		//For loop bottom stuff	
	
		adrp x0,space_msg
		add x0,x0,:lo12:space_msg
		
		bl printf										//print a space "\n"

		adrp x9,MODMASK
		add x9,x9,:lo12:MODMASK
		ldr w10,[x9]										//w10 has MODMASK

		add w11,i,1										//w11 has i++		

		ands i,w11,w10										//i = i++ & MODMASK		

		add j,j,1
		b test

exitDisplay: 
		//Restore w19,w20,w21
		add x9,x29,32                                                                          //x9 contains base address for registers
		
		ldr w19,[x9,w19_s]
		ldr w20,[x9,w20_s]
		ldr w21,[x9,w21_s]
		
	ldp x29,x30,[sp],deallocDisplay
	ret

