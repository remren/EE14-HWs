	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	; *** HW7 - Problem 1: Password Sequence ***
		MOV	r0, #0
		
		B	g_LED_i			; green_LED_initialize
g_LED_p						; green_LED_post

		B	r_LED_i			; red_LED_initialize
r_LED_p						; red_LED_post

		B	a_Joy_i			; all_Joystick_initialize
a_Joy_p						; all_Joystick_post
		
		B	check
		
		ENDP

	; *** SUBROUTINES ***
		; Enable the clock to GPIO Port E - Green LED
g_LED_i	PROC
		LDR r0, =RCC_BASE
		LDR r1, [r0, #RCC_AHB2ENR]
		ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
		STR r1, [r0, #RCC_AHB2ENR]

		; MODE: 00: Input mode, 01: General purpose output mode
		;       10: Alternate function mode, 11: Analog mode (reset state)
		LDR r0, =GPIOE_BASE
		LDR r1, [r0, #GPIO_MODER]
		BIC r1, r1, #(0x3<<16)
		ORR r1, r1, #(0x1<<16)
		STR r1, [r0, #GPIO_MODER]
		B	g_LED_p	

;g_TOG	LDR r0, =GPIOE_BASE
;		LDR r1, [r0, #GPIO_ODR]
;		EOREQ r1, r1, #(1<<8)
;		STR r1, [r0, #GPIO_ODR]
;		B	post_g_TOG
		
		; Enable the clock to GPIO Port B - Red LED
r_LED_i LDR r0, =RCC_BASE
		LDR r1, [r0, #RCC_AHB2ENR]
		ORR r1, r1, #RCC_AHB2ENR_GPIOBEN
		STR r1, [r0, #RCC_AHB2ENR]

		; MODE: 00: Input mode, 01: General purpose output mode
		;       10: Alternate function mode, 11: Analog mode (reset state)
		LDR r0, =GPIOB_BASE
		LDR r1, [r0, #GPIO_MODER]
		BIC r1, r1, #(0x3<<4)
		ORR r1, r1, #(0x1<<4)
		STR r1, [r0, #GPIO_MODER]
		B	r_LED_p
		
;r_TOG	LDR r0, =GPIOB_BASE
;		LDR r1, [r0, #GPIO_ODR]
;		EOREQ r1, r1, #(1<<2)
;		STR r1, [r0, #GPIO_ODR]
;		B	post_r_TOG
		
r_ON_L	LDR r0, =GPIOB_BASE			; redLED_ON_Lock
		LDR r1, [r0, #GPIO_ODR]
		EOR r1, r1, #(1<<2)
		STR r1, [r0, #GPIO_ODR]
		ADD r4, #0x01				; Locks red LED to being ON, in edge case where a 5th input is 
		B	post_r_ON_L				; entered and we enter the loop on the first "edge" of the press

		; Enable the clock to GPIO Port A - Center Button
a_Joy_i	LDR r0, =RCC_BASE
		LDR r1, [r0, #RCC_AHB2ENR]
		ORR r1, r1, #RCC_AHB2ENR_GPIOAEN
		STR r1, [r0, #RCC_AHB2ENR]
		
		LDR r0, =GPIOA_BASE			; Initialize Joystick
		LDR r1, [r0, #GPIO_MODER]
;		BIC r1, r1, #0x3			; Set PA.0, Center Button's MODER,	to 00 - Input
		BIC r1, r1, #(0x3<<2*1)		; Set PA.1, Left Button's MODER, 	to 00 - Input
		BIC r1, r1, #(0x3<<2*2)		; Set PA.2, Right Button's MODER, 	to 00 - Input
		BIC r1, r1, #(0x3<<2*3)		; Set PA.3, Up Button's MODER, 		to 00 - Input
		BIC r1, r1, #(0x3<<2*5)		; Set PA.5, Down Button's MODER, 	to 00 - Input
		STR r1, [r0, #GPIO_MODER]
		
		LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_PUPDR]	; These buttons already have a pull-down resistor
		BIC r1, r1, #(0x3<<2*1)		; Set PA.1, Left Button's PUPDR, 	to 10 - Pull Down
		ORR r1, r1, #(0x2<<2*1)
		BIC r1, r1, #(0x3<<2*2)		; Set PA.2, Right Button's PUPDR, 	to 10 - Pull Down
		ORR r1, r1, #(0x2<<2*2)
		BIC r1, r1, #(0x3<<2*3)		; Set PA.3, Up Button's PUPDR, 		to 10 - Pull Down
		ORR r1, r1, #(0x2<<2*3)
		BIC r1, r1, #(0x3<<2*5)		; Set PA.5, Down Button's PUPDR, 	to 10 - Pull Down
		ORR r1, r1, #(0x2<<2*5)
		STR r1, [r0, #GPIO_PUPDR]
		B	a_Joy_p
		
pwd_L	
		LDR r0, =GPIOB_BASE			; turn red LED OFF
		LDR r1, [r0, #GPIO_ODR]
		AND r1, r1, #(0<<2)
		STR r1, [r0, #GPIO_ODR]
		
		LDR r0, =GPIOE_BASE			; turn green LED ON
		LDR r1, [r0, #GPIO_ODR]
		ORR r1, r1, #(1<<8)
		STR r1, [r0, #GPIO_ODR]
stop 	B 		stop     			; dead loop & program hangs here

check
		LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_IDR]	
		ORR r1, #0x4000
		MOV r2, r1					; Save current IDR to previous
		MOV r4, #0x00				; r4 is the number of inputs
		MOV r5, #0x00				; r5 is the running tally for the password
loop								; Start of While Loop
		LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_IDR]		; Check IDR again
		ORR r1, #0x4000
		CMP r1, r2
		BEQ	loop					; Inputs should take 2 loops to increment something, we get the "back edge" of the input.

		MOV r3, r2
		AND r3, #0x08				; Check Up
		CMP r3, #0x08				; Should be equal if Up was input
		ADDEQ r4, #0x01				; Add 1 to number of inputs if input was received
		ADDEQ r5, #0x01				; Up should always begin a chunk for checking the password
		
		MOV r3, r2
		AND r3, #0x20				; Check Down
		CMP r3, #0x20
		ADDEQ r4, #0x01				; Add 1 if Down Received
		BNE skipD					; If DOWN is not received, then skip the tally process
		CMP r5, #0x01				; If the next input is DOWN and the tally indicates a 1, then the previous input was an UP
		ADDEQ r5, #0x01				; If equal, add 1 to tally, continuing password		
		MOVNE r5, #0x00				; Else, set tally back to 0, restarting password process
skipD

		MOV r3, r2
		AND r3, #0x02				; Check Left
		CMP r3, #0x02
		ADDEQ r4, #0x01				; Add 1 if Left Received
		BNE skipL
		CMP r5, #0x02
		ADDEQ r5, #0x01
		MOVNE r5, #0x00
skipL
		
		MOV r3, r2
		AND r3, #0x04				; Check Right
		CMP r3, #0x04
		ADDEQ r4, #0x01				; Add 1 if Right Received
		BNE skipR
		CMP r5, #0x03
		ADDEQ r5, #0x01
		MOVNE r5, #0x00
skipR
		
		MOV r2, r1					; Save current state of IDR to previous
		
		CMP r4, #0x04				; If 4 inputs have been received since the start, red LED should be on.
		BEQ r_ON_L
post_r_ON_L
		
		CMP r5, #0x04				; If correct password has been input, lock out program
		BEQ pwd_L		

;		B g_TOG
;post_g_TOG

;		B r_TOG
;post_r_TOG

;		B	g_ON			; green_ON
;post_g_ON					; post_green_ON

		B 		loop				; End of While Loop
		ENDP
			
					
		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
array 	DCD		1, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8
size  	DCD		11

		END

