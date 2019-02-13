//Amanda Olearczuk
//CPSC 355
//30041203
//Assignment 5

//The following program takes 2 command line arguments that correspond to month and day in format: mm dd,
// and then print the corresponding day, month and season for the input

//Following strings are allowed to change so they are put into .data section
.data
.balign 8

data_month: .string "month"                                                                  //String for month for example "January" that will go into printf function later
data_day: .string "day"
data_season: .string "Winter"                                                                //String for season that will go into printf function default "Winter"
data_suffix: .string "th"                                                                    //Default suffix for day that will go into printf function later

data_collected: .dword data_month,data_day,data_suffix,data_season

fmt: .string "usage: a5b mm dd\n"                                                              //print this if wrong input
data_print: .string "%s %d%s is %s\n"

.text
.balign 4
//Set up month array of pointers

jan_m: .string "January"
feb_m: .string "Febuary"
mar_m: .string "March"
apr_m: .string "April"
may_m: .string "May"
jun_m: .string "June"
jul_m: .string "July"
aug_m: .string "August"
sep_m: .string "September"
oct_m: .string "October"
nov_m: .string "November"
dec_m: .string "December"

month_m : .dword jan_m,feb_m,mar_m,apr_m,may_m,jun_m,jul_m,aug_m,sep_m,oct_m,nov_m,dec_m      //Array of pointers

//Set up season array of pointers

win_m: .string "Winter"
spr_m: .string "Spring"
sum_m: .string "Summer"
fal_m: .string "Fall"

season_m: .dword win_m,spr_m,sum_m,fal_m

suffix_st: .string "st"                                                                        //Suffix for day "st" for example 21st
suffix_nd: .string "nd"                                                                        //Suffix for day "nd"
suffix_rd: .string "rd"                                                                        //Suffix for day "rd"

suffix_data: .dword suffix_st,suffix_nd,suffix_rd

define(argc_r,w19)                                                                            //argc_r is number of command line arguments provided
define(argv_r,x20)                                                                            //argv_r is base address for command line arguments
define(month_m_base_r,x21)                                                                    //base for month array
define(season_m_base_r,x22)                                                                   //base for season array
define(month_digit,x23)                                                                       //Command line month, saved as an integer
define(day_digit,x24)                                                                         //Command line day, saved as an integer
define(remainder,x25)                                                                         //Remainder for calculation of season we will do later
define(month_print_r,x26)								      //Exact address to month_print       
define(data_collected_r,x27)            
define(suffix_data_r,x28)

.global main
main:   stp x29,x30,[sp,-16]!
	mov x29,sp

      	mov argc_r,w0                                                                         //Move number of arguments to w0
        mov argv_r,x1									      //Set up base address of command line arguments to w1
        
	//Base address for suffixes
        adrp suffix_data_r,suffix_data
        add suffix_data_r,suffix_data_r,:lo12:suffix_data

 	//Base address for data collected
        adrp data_collected_r,data_collected
        add data_collected_r,data_collected_r,:lo12:data_collected

        //1.Check if there is 2 arguments passed from command line

	cmp argc_r,3                                                                          //Check w0 argc which is an integer number of arguments, compare it with 2
        b.ne exit  									      //Comment out for gdb use

	//2.Set up base address for month and season pointer arrays

	adrp month_m_base_r,month_m                                                           //Set up base address month_m_base_r for the month pointer array
	add month_m_base_r,month_m_base_r,:lo12:month_m

	adrp season_m_base_r,season_m
	add season_m_base_r,season_m_base_r,:lo12:season_m                                    //Set up base address for season_m_base_r for the season pointer array

	//3.Convert command line 1st argument to digits stored in month_digit ,day_digit

	ldr x0,[argv_r,8]							              //x0 contains string from command line for "month" for example "12"
	bl atoi										      //convert string for example "12" to an integer - returned in w0
        mov month_digit,x0                                                                    //Move returned value to month_digit


	ldr x0,[argv_r,16]                                                                    //Do same for day_digit
	bl atoi
	mov day_digit,x0

	//4.Check if month_digit is in the range 1-12

	cmp month_digit,1                                                                      //If month<1 exit
	b.lt exit
	cmp month_digit,12
	b.gt exit                                                                              //If month>12 exit

       //5.Store month as a string for example "January" in month_print

       sub x11,month_digit,1                                                                  //Index for a month
       mov x9,8
       mul x12,x11,x9                                                                         //index * element size = offset
       ldr x10,[month_m_base_r,x12]		               			              //Load string corresponding to month in to x10 
       str x10,[data_collected_r,0]                                                           //Store the string corresponding to month in data

       //6.Check range for day of the month

	cmp day_digit,1									     //Check if day is positive
	b.lt exit									     //If day is negative exit immediately

	cmp month_digit,2								     //check if month is Febuary
        b.ne elseif                                                                          //if it isn't, keep checking
	     cmp day_digit,29								     //Check if Febuary has <=29 days as it should have
	     b.gt exit                                                                       //If febuary doesn't have <=29 days
	     b dayRangeOk                                                                    //If Feb does have <=29days continue with code

elseif: cmp month_digit,4								     //Check if month is April
	b.ne elseiff                                                                         //If it's not, keep checking
             cmp day_digit,30                                                                //check if april has<=30 days
             b.gt exit                                                                       //If it doesnt, exit
             b dayRangeOk                                                                    //If range of days is ok, continue with code

elseiff: cmp month_digit,6                                                                   //Check if month is June
         b.ne elseifff
             cmp day_digit,30
             b.gt exit
             b dayRangeOk

elseifff: cmp month_digit,9								     //Check if month is September
          b.ne elseiffff
             cmp day_digit,30
	     b.gt exit
             b dayRangeOk

elseiffff: cmp month_digit,11								     //Check if month is november
           b.ne else
             cmp day_digit,30
             b.gt exit
             b dayRangeOk

else:                                                                                        //By this point we know month day range should be b/w 1-31
	cmp day_digit,31
        b.gt exit
        b dayRangeOk


dayRangeOk:                                            

     //8.Check if day ends in 1,2,3 or other for example 21 ends in 1 so we change suffix
  
	mov x10,10                                                                          //Denumerator
	sdiv x9,day_digit,x9                                                                 //day_digit/10 = decimal number with remainder
	msub remainder,x9,x10,day_digit                                                     //Calculated remainder

	cmp remainder,1                                                                     //check if remainder is 1
	b.ne elseif_a								            //if remainder isn't 1, go to elseif_a
									    
 	ldr x11,[suffix_data_r]                                                             //x11 has "st"	       
	str x11,[data_collected_r,16]                                                       //move "st" into suffix_print  

	b RemainderOk

elseif_a: cmp remainder,2                                                                   //check if remainder is do, do similar stuff
          b.ne elseif_b
	  ldr x11,[suffix_data_r,8]
          str x11,[data_collected_r,16] 						     //store in suffix spot "nd"
          b RemainderOk

elseif_b: cmp remainder,3                                                                   //check if remainder is 3
          b.ne RemainderOk
	  ldr x11,[suffix_data_r,16]                                                        //x11 stores "rd"
	  str x11,[data_collected_r,16]                                                     //store "rd" to data
          b RemainderOk

RemainderOk:
                  
 	//9.Find out the season

        //We combine month with day for example March 21st is 321
        //We check if month-day number is in range
        //321-620 is spring
        //620-920 is fall
        //921 - 1220 is winter

          mov x12,100
          mul x9,month_digit,x12
          add x9,x9,day_digit                                                             //Combine month and digit into one

          cmp x9,321                                                                      //check for 321
          b.lt seasonOk                                                                   //if <321, season stays default - winter
          cmp x9,620                                                                      //check for 620      
          b.ge elseif_x                                                                   //season is either summer or fall
       // change season to spring - index 1 in pointer array
	   ldr x11,[season_m_base_r,8]
	   str x11,[data_collected_r,24]
           b seasonOk

elseif_x: cmp w9,920                                                                       //check for 920
          b.ge else_y                                                                      //if month-day>920, season is fall
          //change season to summer - index 2 in pointer array
          ldr x11,[season_m_base_r,16]
          str x11,[data_collected_r,24]
          b seasonOk

else_y: //season is fall
        ldr x11,[season_m_base_r,24]
        str x11,[data_collected_r,24]
        b seasonOk


seasonOk:

       //10.Print result

         adrp x0,data_print
         add x0,x0,:lo12:data_print 							   //String format

         ldr x1,[data_collected_r]                                                         //Arg 1 - month string
         mov x2,day_digit								   //Arg 2 - Day string
	 ldr x3,[data_collected_r,16]							   //Arg 3 - suffix string 
         ldr x4,[data_collected_r,24]							   //Arg 4 - season string
        
	 bl printf

         b PeaceOut                                                                          //Exit whole program without printing error messages

exit: 
      adrp x0,fmt
      add x0,x0,:lo12:fmt
      bl printf                                                                            //Print message that there was wrong input in command line

PeaceOut:

	ldp x29,x30,[sp],16
	ret
