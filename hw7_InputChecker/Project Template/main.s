;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************

;*************************************  32L476GDISCOVERY ***************************************************************************
; STM32L4:  STM32L476VGT6 MCU = ARM Cortex-M4 + FPU + DSP, 
;           LQFP100, 1 MB of Flash, 128 KB of SRAM
;           Instruction cache = 32 lines of 4x64 bits (1KB)
;           Data cache = 8 lines of 4x64 bits (256 B)
;
; Joystick (MT-008A): 
;   Right = PA2        Up   = PA3         Center = PA0
;   Left  = PA1        Down = PA5
;
; User LEDs: 
;   LD4 Red   = PB2    LD5 Green = PE8
;   
; CS43L22 Audio DAC Stereo (I2C address 0x94):  
;   SAI1_MCK = PE2     SAI1_SD  = PE6    I2C1_SDA = PB7    Audio_RST = PE3    
;   SAI1_SCK = PE5     SAI1_FS  = PE4    I2C1_SCL = PB6                                           
;
; MP34DT01 Digital MEMS microphone 
;    Audio_CLK = PE9   Audio_DIN = PE7
;
; LSM303C eCompass (a 3D accelerometer and 3D magnetometer module): 
;   MEMS_SCK  = PD1    MAG_DRDY = PC2    XL_CS  = PE0             
;   MEMS_MOSI = PD4    MAG_CS  = PC0     XL_INT = PE1       
;                      MAG_INT = PC1 
;
; L3GD20 Gyro (three-axis digital output): 
;   MEMS_SCK  = PD1    GYRO_CS   = PD7
;   MEMS_MOSI = PD4    GYRO_INT1 = PD2
;   MEMS_MISO = PD3    GYRO_INT2 = PB8
;
; ST-Link V2 (Virtual com port, Mass Storage, Debug port): 
;   USART_TX = PD5     SWCLK = PA14      MFX_USART3_TX   MCO
;   USART_RX = PD6     SWDIO = PA13      MFX_USART3_RX   NRST
;   PB3 = 3V3_REG_ON   SWO   = PB3      
;
; Quad SPI Flash Memory (128 Mbit)
;   QSPI_CS  = PE11    QSPI_D0 = PE12    QSPI_D2 = PE14
;   QSPI_CLK = PE10    QSPI_D1 = PE13    QSPI_D3 = PE15
;
; LCD (24 segments, 4 commons)
;   VLCD = PC3
;   COM0 = PA8     COM1  = PA9      COM2  = PA10    COM3  = PB9
;   SEG0 = PA7     SEG6  = PD11     SEG12 = PB5     SEG18 = PD8
;   SEG1 = PC5     SEG7  = PD13     SEG13 = PC8     SEG19 = PB14
;   SEG2 = PB1     SEG8  = PD15     SEG14 = PC6     SEG20 = PB12
;   SEG3 = PB13    SEG9  = PC7      SEG15 = PD14    SEG21 = PB0
;   SEG4 = PB15    SEG10 = PA15     SEG16 = PD12    SEG22 = PC4
;   SEG5 = PD9     SEG11 = PB4      SEG17 = PD10    SEG23 = PA6
; 
; USB OTG
;   OTG_FS_PowerSwitchOn = PC9    OTG_FS_VBUS = PC11     OTG_FS_DM = PA11  
;   OTG_FS_OverCurrent   = PC10   OTG_FS_ID   = PC12    OTG_FS_DP = PA12  
;
; PC14 = OSC32_IN      PC15 = OSC32_OUT
; PH0  = OSC_IN        PH1  = OSC_OUT 
; 
; PA4  = DAC1_OUT1 (NLMFX0 WAKEUP)   PA5 = DAC1_OUT2 (Joy Down)
; PA3  = OPAMP1_VOUT (Joy Up)        PB0 = OPAMP2_VOUT (LCD SEG21)
;
;*****************************************************************************************************************


	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
		MOV	r0, #0
		
		B	g_LED_i			; green_LED_initialize
g_LED_p						; green_LED_post

		B	r_LED_i			; red_LED_initialize
r_LED_p						; red_LED_post

		B	a_Joy_i			; all_Joystick_initialize
a_Joy_p						; all_Joystick_post
		
		B	check
		
stop 	B 		stop     		; dead loop & program hangs here
		
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
		
;g_ON	LDR r0, =GPIOE_BASE
;		LDR r1, [r0, #GPIO_ODR]
;		ORR r1, r1, #(1<<8)
;		STR r1, [r0, #GPIO_ODR]
;		B	post_g_ON		
		
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

check
		LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_IDR]	
		ORR r1, #0x4000
		MOV r2, r1					; Save current IDR to previous
		MOV r4, #0x00				; r4 is the number of inputs
		MOV r5, #0x00				; r5 is the running tally for the password
loop	
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
		

;		B g_TOG
;post_g_TOG

;		B r_TOG
;post_r_TOG

;		B	g_ON			; green_ON
;post_g_ON					; post_green_ON

		B 		loop	

		ENDP
			
					
		ALIGN
		AREA	myData, DATA, READWRITE

		; *** DECLARATIONS ***
array 	DCD		1, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8
size  	DCD		11

		END

