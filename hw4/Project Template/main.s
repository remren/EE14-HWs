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
	
	;*** Problem 4: x = x * y + z - x ***
	; Let r3 be the assigned x.
	MOV r0, 0xFFFF ; x = r0
	MOV r1, 0x0004 ; y = r1
	MOV r2, 0x0005 ; z = r2
	MUL r3, r0, r1 ; x = x * y
	ADD r3, r3, r2 ; x = x + z
	SUB r3, r3, r0 ; x = x - x
	LSL r3, #16
	LSR r3, #16 ; This is to only get the bottom 16 bits.
	
	;*** Problem 5: x = x % y ***
	; Let r4 be the assigned x.
	MOV r4, 0x03 ; Initial x
	MOV r5, 0x11 ; Initial y
	UDIV r6, r4, r5 ; r6 gets remainder
	MUL r7, r5, r6 ; remainder * y
	SUB r4, r4, r7
	
	;*** Problem 6: y = 3x^3 - 7x^2 + 10x - 11 ***
	; Let r12 be the assigned y.
	MOV r8, 0xFFFFFFFB ; Initial x
	MUL r9, r8, r8 ; x^2
	MUL r10, r9, r8 ; x^3
	MOV r11, 0x03 ; 3
	MUL r11, r11, r10 ; 3x^3
	MOV r12, 0x00 ; Set y default to 0
	ADD r12, r11 ; y += 3x^3
	MOV r11, 0x07 ; 7
	MUL r10, r9, r11 ; 7x^2
	SUB r12, r12, r10 ; y -= 7x^2
	MOV r11, 0x0A ; 10
	MUL r10, r8, r11 ; 10x
	ADD r12, r10 ; y += 10x
	SUB r12, r12, 0x0B ; y -= 11
	
	;*** Problem 7: x = x % y ***
	; Let r4 be the assigned x.
	MOV r4, 0x03 ; Initial x
	MOV r5, 0x11 ; Initial y
	UDIV r6, r4, r5 ; r6 gets remainder
	MUL r7, r5, r6 ; remainder * y
	SUB r4, r4, r7
	
stop 	B 		stop     		; dead loop & program hangs here

	ENDP
					
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
	END
