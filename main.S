/*
 * main.S - ECE 540 project #1 starter code for microAptiv_UP MIPS core
 * running on Nexys4 DDR FPGA target board
 *
 * Copyright Srivatsa Yogendra, 2017
 * Modified by Ram Bhattarai, Srijana Sapkota, and Surya Ravikumar
 * Licensed to Ram Bhattarai, Srijana Sapkota, and Surya Ravikumar
 * 
 * Created By:		Srivatsa Yogendra
 * Last Modified:	01-Oct-2017 (RK)
 *
 * Description:
 * Reads the switches on the FPGA board and writes
 * the values to the LEDs and the seven segment display
 *
 * Assumes the existance of an AHB-Lite peripheral for the 8 digit
 * 7-segment display on the Nexys4 DDR.  The peripheral has 4 memory
 * mapped I/O registers:
 *	PORT_SEVENSEG_EN - (8 bits) Individual enables for each digit. Set bit to 0 to enable digit
 *									Digit7 = bit[7], Digit6 = bit[6], Digit5 = bit[5], Digit4 = bit[4],
 *									Digit3 = bit[3], Digit2 = bit[2], Digit1 = bit[1], Digit0 = bit[0]
 *	PORT_SEVENSEG_HGH = (32 bits) Value of digit.  Each digit has the range of 31:0, top 3 bits ignored
 *									Digit7 = bits[31:24], Digit6 = bits[23:16],
 *									Digit5 = bits[15:8] , Digit4 = bits[7:0]
 *	PORT_SEVENSEG_LOW = (32 bits) Value of digit.  Each digit has the range of 31:0, top 3 bits ignored
 *									Digit3 = bits[31:24], Digit2 = bits[23:16],
 *									Digit1 = bits[15:8] , Digit0 = bits[7:0]
 *	PORT_SEVENSEG_DP - (8 bits) Individual decimal points for each digit. Set bit to 0 to turn on the decimal point
 *									DP7 = bit[7], DP6 = bit[6], DP5 = bit[5], DP4 = bit[4],
 *									DP3 = bit[3], DP2 = bit[2], DP1 = bit[1], DP0 = bit[0]
 */


/* FOR PROJECT 1 , Change the below addresses to
 * the addresses of your peripherals
 */

PORT_SEVENSEG_EN 	= 0xbf700000		# (o) 7 Segment enable
PORT_SEVENSEG_HGH	= 0xbf700004		# (o) 7 Segment Higher Display
PORT_SEVENSEG_LOW	= 0xbf700008		# (o) 7 Segment Lower Display
PORT_SEVENSEG_DP	= 0xbf70000C		# (o) 7 segment Decimal Point Display
PORT_PUSH_BTN       = 0xbf800008        # (o) Push button

//Motion Indicator actions
STOP       = 0x0                   //Steady
LMF        = 0x04                  //Left Motor Forward----Turn Right 1x speed--5hz speed--Chase Clockwise
RMF        = 0x01                  //Right Button - Right Motor Forward---Turn Left 1x speed--5hz speed---Chase Counter Clockwise
LMR        = 0x10                  //Another name: UP-----Left Motor Reverse--Turn Left 1x speed--Chase Counter Clockwise--5hz
RMR        = 0x08                  //Another name: Down----Right Motor Reverse---Turn Right 1x Speed--Chase CLockwise--5hz
LEFT_RIGHT = 0x05                  //Left Wheel & Right Wheel is pressed---Forward--a blinks with 1hz
UP_DOWN    = 0x18                  //UP and DOWN--- Reverse---d blinks at 1 hz speed
UP_RIGHT   = 0x11                  //Turn left 2x speed---10 hz speed
LEFT_DOWN  = 0x0C                  //Turn Right 2x speed---10 hz speed
RLUD       = 0x1D                  //All of the button are presssed, STOP
MIDDLE     = 0x02                  //Center


.globl main
main:
   lui   $12, 0xbf80    				# $12 = address of LEDs (0xbf800000)
   addiu $13, $12, 4    				# $13 = address of switches
   li    $14, PORT_SEVENSEG_EN			# $14 = address of the 7 segment enable
   li 	 $15, PORT_SEVENSEG_HGH			# $15 = address of the higher 7 segment digits
   li 	 $16, PORT_SEVENSEG_LOW			# $16 = address of the lower 7 segment digits
   li 	 $17, PORT_SEVENSEG_DP			# $17 = address of the dp points in 7 segment digits
   li    $18, PORT_PUSH_BTN             # $18 = address of push buttons

   li   $3, 0x0

readIO:

	li 	  $11, 0xF0         # Value to disable all the upper segment and turn on the lower segment
	sw	  $11, 0($14)		# Enable all the displays

	li 	  $11, 0xFFFFFFFF   # Loading value to  clear all the digits of lower segment display
	sw    $11,0($16)        # Storing the value to clear the digits

	li    $11, 0xF7         # Loading value to turn on the decimal digit before the last digit.
	sw    $11, 0($17)		# Turning on the decimal digit before the last digit.
	nop                  	# branch delay slot

MAINFUNCTION:
	lw    $11, 0($18)    					     # read PUSHBUTTON: $18
	and   $4, $11, 0xFFFFFFFF                    # Clear previous states
	and   $11, $11, 0xFF000000                   # Clear the Gloabl register
	beq   $4 ,STOP, stop             		     #IF STOP then go to stop routine
	beq   $4 ,LMF, clockwise5hz             	 #IF only left button is pressed, chase
	beq   $4, RMR, clockwise5hz           	     #Right
	beq   $4, LEFT_DOWN, clockwise10hz           #LEFT and DOWN PUSH BUTTON PRESSED
	beq   $4, RMF, counterclockwise5hz           #RIGHT MOTOR FORWARD---RIGHT Button with 5hz speed
	beq   $4, LMR, counterclockwise5hz           #Left MOTOR REVERSE ---Button
	beq   $4, UP_RIGHT, counterclockwise10hz     #UP and RIGHT PRESSED,
	beq   $4, LEFT_RIGHT, AT1hzblinka            #LEFT and RIGHT BUTTON PRESSED, FORWARD MOTION
	beq   $4, UP_DOWN,AT1hzblinkd                #UP AND DOWN BUTTON PRESSED, REVERSE MOTION
	li    $4, MIDDLE                             #JUST AN EXTRA TO HANDLE THE MIDDLE PUSH BUTTON
	beq   $4, MIDDLE,stop

//NO Button is Pressed
//Holds on to the previous value of compass
stop:
	li  $10, 0x16000000                          #DEFAULT VALUE, TURNS ON SEGMENT g
	or $11, $11, $10                             #OR to keep the previous values
	and $3,$3, 0xffffff
	or $11, $11, $3                              #RETAINING THE PREVIOUS VALUE
	sw $11, 0($16)                               #STORE THE VALUE IN LOW REGISTER
	j MAINFUNCTION                               #JUMP BACK TO MAINFUNCTION

//Motion indicator and increment compass for clockwise with 5hz
clockwise5hz:
    li $11, 0x10000000									#Load Segment A value
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x11000000                                  #Load Segment B Value
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x12000000                                  #Load Value of Segment C
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x13000000                                  #Load Value of Segment D
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x14000000                                  #Load Value of Segment E
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x15000000                                  #Load Value of Segment F
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to increment compass for incrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still
	j MAINFUNCTION                                      #When cycle is completed, go back to comparision function

//Motion indicator and Decrement compass for counterclockwise with 5hz
counterclockwise5hz:
    li $11, 0x10000000                                  #Load Segment A value
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x15000000                                  #Load Value of Segment F
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x14000000                                  #Load Value of Segment E
	sw $11,0($16)										#Store the value on lower segment #Digit 3
	jal DecrementCompass								#Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz											#When returns jump and link to loop 5hz for delay
	jal btncheck										#Check if the button is pressed still

	li $11, 0x13000000                                  #Load Value of Segment D
	sw $11,0($16)										#Store the value on lower segment #Digit 3
	jal DecrementCompass								#Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz											#When returns jump and link to loop 5hz for delay
	jal btncheck										#Check if the button is pressed still

	li $11, 0x12000000                                  #Load Value of Segment C
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass								#Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x11000000                                  #Load Value of Segment B
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop5hz                                         #When returns jump and link to loop 5hz for delay
	jal btncheck                                        #Check if the button is pressed still

	j MAINFUNCTION                                      #When cycle is completed, go back to comparision function

//Motion indicator and increment compass for clockwise with 10hz
clockwise10hz:

	li $11, 0x10000000                                  #Load Value of Segment A
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x11000000                                  #Load Value of Segment B
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x12000000                                  #Load Value of Segment C
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x13000000                                  #Load Value of Segment D
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x14000000                                  #Load Value of Segment E
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x15000000                                  #Load Value of Segment F
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal IncrementCompass                                #Jump and link to Increment compass for Incrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	j MAINFUNCTION                                      #When cycle is completed, go back to comparision function

//Motion indicator and Decrement compass for counterclockwise with 10hz
counterclockwise10hz:
    li $11, 0x10000000                                  #Load Value of Segment A
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x15000000                                  #Load Value of Segment F
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x14000000                                  #Load Value of Segment E
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x13000000                                  #Load Value of Segment D
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x12000000                                  #Load Value of Segment C
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still

	li $11, 0x11000000                                  #Load Value of Segment B
	sw $11,0($16)                                       #Store the value on lower segment #Digit 3
	jal DecrementCompass                                #Jump and link to Decrement compass for Decrementing the compass value
	jal loop10hz                                        #When returns jump and link to loop 10hz for delay
	jal btncheck                                        #Check if the button is pressed still
	j MAINFUNCTION                                      #When cycle is completed, go back to comparision function


#BLINKS THE SEGMENT A
#FORWARD
AT1hzblinka:
    li $24, 0x10000000                                  #Load Value of Segment A
	or $11,$11,$24                                      #OR with the previous value
	and $3,$3, 0xffffff                                 #Hang on to previous value
	or $11, $11, $3                                     #OR with the previous value for compass
	sw $11,0($16)                                       #Store the result in lower 3 digits
	jal loop1hz                                         #Jump and link back once the loop is done
	jal btncheck                                        #Check for the button press
	li $24, 0xFF000000                                  #Load the value to only touch the motion blinker
	or $11,$11,$24                                      #Or that so the value of motion blinker is not changed
	and $3,$3, 0xffffff                                 #Hold the value of the compass and motion blinker
	or $11, $11, $3                                     #add the previous value
	sw $11,0($16)                                       #Store the result in the lower 3 digits of the compass
	jal loop1hz                                         #Jump and link back to the blinker
	jal btncheck                                        #check if the button is still pressed
	b MAINFUNCTION                                      #Return back to the comparing function


#BLINKS THE SEGMENT D
#REVERSE
AT1hzblinkd:
	li $24, 0x13000000                                  #Load Value of Segment D
	or $11,$11,$24                                      #OR with the previous value
	and $3,$3, 0xffffff                                 #Hang on to previous value
	or $11, $11, $3                                     #OR with the previous value for compass
	sw $11,0($16)                                       #Store the result in lower 3 digits
	jal loop1hz                                         #Jump and link back once the loop is done
	jal btncheck                                        #Check for the button press
	li $24, 0xFF000000                                  ##Load the value to only touch the motion blinker
	or $11,$11,$24                                      #Hold the value of the motion blinker
	and $3,$3, 0xffffff                                 #Or that so the value of motion blinker is not changed
	or $11, $11, $3                                     #Hold the value of the compass and motion blinker
	sw $11,0($16)                                       #add the previous value
	jal loop1hz                                         #Store the result in the lower 3 digits of the compass
	jal btncheck                                        #Jump and link back verifying that the button is still pressed
	j MAINFUNCTION                                      #Return back to the comparing function


#LOOP WITH 5HZ SPEED
loop5hz:
	li $8, 5000000                                      #Load the counter value of 5 hz
	li $9, 0                                            #Load the value to a temp register
	loop5:
	addi $9,$9,1                                        #Increment the counter
	bne $9,$8,loop5                                     #Check if the counter is equal to the counter value of 5hz
	jr $ra                                              # If eqaul, jump back to the return address

#LOOP WITH 10 HZ SPEED
loop10hz:
	li $8, 2500000                                      #Load the counter value of 10 hz
	li $9, 0                                            #Load the value to a temp register
	loop10:
	addi $9,$9,1                                        #Increment the counter
	bne $9,$8,loop10                                    #Check if the counter is equal to the counter value of 10hz
	jr $ra                                              #If eqaul, jump back to the return address

#LOOP WITH 1 HZ SPEED
loop1hz:
	li $8, 25000000                                     #Load the counter value of 10 hz
	li $9, 0                                            #Load the value to a temp register
	loop1:
	addi $9,$9,1                                        #Increment the counter
	bne $9,$8,loop1                                     #Check if the counter is equal to the counter value of 10hz
	jr $ra                                              #If eqaul, jump back to the return address

#ROUTINE TO CHECK IF THE BUTTON IS STILL PRESSED
btncheck:
	lw $5, 0($18)
	bne $4, $5,stop
	jr $ra

#INCREMENT COMPASS

IncrementCompass:
	addi  $3, $3, 0x1					    #add 1 to compass value

	andi  $12, $3, 0xf					    #check if ones digit has gone above 9
	li	  $9, 0xa
	bne	  $12, $9, L1
	addi  $3, $3, 0xf6		                #if gone above, adjust so that ones digit is set to 0 and 1 is added to 10s digit

L1:
	andi  $12, $3, 0xf00		            #check if 10s digit has gone above 9
	li	  $9, 0xa00
	bne   $9, $12, L2
	li	  $12, 0xf600
	add  $3, $3, $12			            #if gone above, adjust so that 10s digit is set to 0 and 1 is added to 100s digit
	j L3
L2:
	and  $12, $3, 0x3ffff		            #check if compass reads 359

	li    $9, 0x30600
	bne   $9, $12, L3			            #compare values
	li	  $3, 0x0			                #set it to 0 if it does - round back

L3:
	and  $3, $3, 0x30f0f		            #mask value to write - 3 8-bit values
	or 	  $3, $11, $3			            #OR with motion blinker value
	sw 	  $3, 0($16)					    #write value to lower segment
	jr $ra						            #return



#DECREMENT COMPASS
DecrementCompass:
	and   $3, $3, 0x3ffff				#Mask lower 3 digits to work on
	bne   $3, $0, L4					#check if compass reads 0
	li	  $3, 0x30509					#if yes, set to 359 - round back
	j	  L6							#jump to write

L4:
	addi  $3, $3, -1					#subtract 1 from compass value

	andi  $12, $3, 0xffff	     		#check if 10s digit has gone below 0
	li    $9, 0xffff
	bne   $9, $12, L5
	and	  $3, $3, 0x30000
	or    $3, $3, 0x909					#if yes, set lower 2 digits is set to 99

L5:
	andi  $12, $3, 0xff		    		#check if ones digit has gone below 0
	li    $9, 0xff
	bne   $12, $9, L6					#compare values
	and	  $3, $3, 0x30f00				#if yes, set ones digit to 0
	or    $3, $3, 0x9
	li    $9, 0xfe						#check if ones digit has gone below 0
	bne   $12, $9, L6
	and	  $3, $3, 0x30f00
	or    $3, $3, 0x9					#set ones digit to 9

L6:

	and  $3, $3, 0x30f0f				#mask value to write - 3 8-bit values
	or 	  $3, $11, $3					#OR with motion blinker value
	sw 	  $3, 0($16)					#write value to lower segment

	jr $ra

