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
	
	;*** Chapter 7, Problem 5 ***
			
			LDR		r0, =C		; Load primary address of C
			LDR		r1, =A
			LDR		r2, =B
			
			LDR		r3, =m		; n must also be equal to m
			LDR		r3, [r3]
			LDR		r4, =p
			LDR		r4, [r4]
			
			MOV		r5, #0		; r5 = i			
rowA		
			CMP		r5, r3		; i < m, Iterate through all rows of A
			BGE		stop
			MOV		r6, #0		; r6 = j = 0, set rowB iterator to 0
			B		colB
postB		
			ADD 	r5, #1		; i++, rowA incrementer
			B		rowA

colB		
			CMP 	r6, r3		; j < n, n = m
			BGE		postB
			MOV		r8, #0		; r8 = SUM = 0
			MOV		r7, #0		; r7 = k = 0, set colA iterator to 0
			B		colA
postColA	
			MUL		r11, r5, r3	; i * n
			ADD		r11, r11, r6; + j
			LSL		r11, r11, #2; MULTIPLY BY 4 AS WE HAVE 4 BYTES PER ELEMENT
			STR		r8, [r0, r11]; C[(i * n) + j] = sum
			ADD		r6, #1		; j++, rowB incrementer
			B		colB
colA		
			CMP		r7, r4		; k < p, Iterate through all cols of A
			BGE 	postColA
			B		math
postmath	
			ADD		r8, r8, r9 	; sum += ...
			ADD		r7, #1		; k++, colA incrementer
			B		colA
			
math		
			MUL 	r9, r5, r4	; i * p
			ADD		r9, r7		; + k
			LSL		r9, r9, #2	; multiply by 4 as we have 4 bytes per element
			LDR		r9, [r1, r9]; A[i * p + k]
			
			MUL 	r10, r7, r3	; k * n, where n = m
			ADD		r10, r6		; + j
			LSL		r10, r10, #2; multiply by 4 as we have 4 bytes per element
			LDR		r10, [r2, r10]; B[k * n + j]
			MUL		r9, r9, r10	; A[i * p + k] * B[k * n + j]
			B 		postmath
	
stop 		B 		stop     		; dead loop & program hangs here

	ENDP
	
	ALIGN
	AREA    myData, DATA, READWRITE
m	DCD		4	; A has m rows
p	DCD		3	; A has p cols, B has p rows
n	DCD		4	; B has n cols
	
A	DCD		1,2,3,4,5,6,7,8,9,10,11,12	; Matrix A
B	DCD		1,2,3,4,5,6,7,8,9,10,11,12	; Matrix B
C	SPACE	64							; Reserve 16 words

	END
