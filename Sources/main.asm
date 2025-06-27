   
;********************************************************************************************
;* COE538 Fall22 Project: Robot Guidance Problem                                            *
;*                                                                                          *
;* Group Members:                                                                           *
;*                                                                                          *
;* Arnold Cobo  501188889 Sec 1                                                             *
;* Timmy  Ngo   501031027 Sec 14                                                            *
;* Bryan  Serra 500961228 Sec 5                                                             *
;*                                                                                          *
;* TA/Lab Instructor: Ravi Chaudhari                                                        *
;*                                                                                          *
;* Demo Due: Monday, Dec 5                                                                  *
;* Report Due: Friday, Dec 9                                                                *
;********************************************************************************************

; export symbols
            XDEF Entry, _Startup                ; export 'Entry' symbol
            ABSENTRY Entry                      ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		        INCLUDE 'derivative.inc' 

;********************************************************************************************
;*                                     Equates Section                                      *   
;********************************************************************************************

LCD_DAT         EQU   PORTB                     ; LCD data port, bits - PB7,...,PB0
LCD_CNTR        EQU   PTJ                       ; LCD control port, bits - PJ6(RS),PJ7(E)
LCD_E           EQU   $80                       ; LCD E-signal pin
LCD_RS          EQU   $40                       ; LCD RS-signal pin
START           EQU   0                         ; START state value
FWD             EQU   1                         ; FORWARD state value
REV             EQU   2                         ; REVERSE state value
RT_TRN          EQU   3                         ; RIGHT TURN state value
LT_TRN          EQU   4                         ; LEFT TURN state value
ALL_STP         EQU   6                         ; ALL STOP state value

; Guider definitions from Guider PDF

BASE_BOW        EQU   $C0                       ; Path detection threshold A
BASE_PORT       EQU   $CA                       ; "" B
BASE_MID        EQU   $CA                       ; "" C
BASE_STAR       EQU   $CA                       ; "" D
THRESH_E        EQU   $67                       ; If SENSOR_LINE < THRESH_E then robot moves left
THRESH_F        EQU   $B0                       ; If SENSOR_LINE > THRESH_F then robot moves right

; Distance definitions

INC_DIS         EQU   30                        ; INCREMENT distance
FWD_DIS         EQU   1500                      ; FORWARD distance
REV_DIS         EQU   1000                      ; REVERSE distance
STR_DIS         EQU   1000                      ; STRAIGHT distance
TRN_DIS         EQU   12500                     ; TURN distance
UTRN_DIS        EQU   14000                     ; U-TURN distance


;********************************************************************************************
;*                                      Variable Section                                    *
;********************************************************************************************

                ORG   $3850
                
CRNT_STATE      DC.B  6                         ; Current state register

COUNT1          DC.W  0                         ; initialize 2-byte COUNT1 to $0000
COUNT2          DC.W  0                         ; initialize 2-byte COUNT2 to $0000

; Sensor Detection

; Sensor A-F will be set to 0 if path/tape is not detected
;  else will be set to 1 if path detected in a subroutine.

A_DETN          DC.B  0                         ; SENSOR A detection
B_DETN          DC.B  0                         ; SENSOR B detection
C_DETN          DC.B  0                         ; SENSOR C detection
D_DETN          DC.B  0                         ; SENSOR D detection
E_DETN          DC.B  0                         ; SENSOR E detection
F_DETN          DC.B  0                         ; SENSOR F detection

TEN_THOUS       DS.B  1                         ; 10,000 digit
THOUSANDS       DS.B  1                         ;  1,000 digit
HUNDREDS        DS.B  1                         ;    100 digit
TENS            DS.B  1                         ;     10 digit
UNITS           DS.B  1                         ;      1 digit
BCD_SPARE       DS.B  10                        ; Extra space for decimal point and string terminator
NO_BLANK        DS.B  1                         ; Used in 'leading zero' blanking by BCD2ASC

; Storage Registers (9S12C32 RAM space: $3800 ... $3FFF)

SENSOR_LINE     DC.B  $0                        ; Storage for guider sensor readings
SENSOR_BOW      DC.B  $0                        ; Initialized to test values
SENSOR_PORT     DC.B  $0                        ; 
SENSOR_MID      DC.B  $0                        ; 
SENSOR_STAR     DC.B  $0                        ; 

SENSOR_NUM      DS.B  1                         ; The currently selected sensor
TEMP            DS.B  1                         ; Temporary location

;********************************************************************************************
;*                                     Code Section                                         *
;********************************************************************************************

                ORG   $4000                     ; Where the code starts
Entry:                                                                                     
_Startup:                                                                                  
                LDS   #$4000                    ; Initialize the stack pointer              
                JSR   initPORTS                 ; Initializet the A/D Ports                                          I
                JSR   initAD                    ; Initialize ATD converter                  
                JSR   initLCD                   ; Initialize the LCD                        
                JSR   clrLCD                    ; Clear LCD & home cursor                   
                JSR   initTCNT                  ; Initialize the TCNT                       
                                                ;                                           
                CLI                             ; Enable interrupts                         
                                                ;                                           
                LDX   #msg1                     ; Display msg1                              
                JSR   putsLCD                   ; "                                        
                LDAA  #$C0                      ; Move LCD cursor to the second row        
                JSR   cmd2LCD                   ; "         
                                               
                LDX   #msg2                     ; Display msg2                              
                JSR   putsLCD                   ; "                                        

MAIN: 	      	JSR   UPDT_READING              ; MAIN LOOP                                           
                JSR   UPDT_DISPL                ; "                                           
                LDAA  CRNT_STATE                ; "                                           
                JSR   DISPATCHER                ; "                                           
                BRA   MAIN                                                                 

;********************************************************************************************
;*                                     Data Section                                         *
;********************************************************************************************

msg1 		        DC.B  "Battery volt:",0         ; Battery voltage message
msg2 		        DC.B  "CRNT_ST:",0               ; Current state message
          
          
tab 	  	      DC.B  "START  ",0               ; State
                DC.B  "FWD    ",0               ; "
                DC.B  "REV    ",0               ; "
                DC.B  "ALL_STP",0               ; "
                DC.B  "REV_TRN",0               ; "
                DC.B  "RT_TRN ",0               ; "
                DC.B  "LT_TRN ",0               ; "

;********************************************************************************************
;*                              Subroutines Section                                         *
;********************************************************************************************

; STATE DISPATCHER

; This routine calls the appropraite state handler based on the current state

; Input:    Current state in AccA
; Returns:  None
; Clobbers: Everything

DISPATCHER      CMPA  #START                    ; If its the START state 
                BNE   NOT_START                 ;                                           
                JSR   START_ST                  ;  then call START_ST routine                
                BRA   DISP_EXIT                 ;  and exit                                 

NOT_START       CMPA  #FWD                      ; Else if it equals the FORWARD state       
                BNE   NOT_FORWARD               ;                                          
                JMP   FWD_ST                    ;  then call the FWD_ST routine              

NOT_FORWARD     CMPA  #RT_TRN                   ; Else if it equals the RIGHT_TURN state    
                BNE   NOT_RT_TRN                ;                                           
                JSR   RT_TRN_ST                 ;  then call the RT_TRN_ST routine           
                BRA   DISP_EXIT                 ;  and exit                                  

NOT_RT_TRN      CMPA  #LT_TRN                   ; Else if it equals the LEFT_TURN state     
                BNE   NOT_LT_TRN                ;                                           
                JSR   LT_TRN_ST                 ;  then call LT_TRN_ST routine               
                BRA   DISP_EXIT                 ;  and exit                                  

NOT_LT_TRN      CMPA  #REV                      ; Else if it equals the REVERSE state       
                BNE   NOT_REVERSE               ;                                           
                JSR   REV_ST                    ;  then call the REV_ST routine              
                BRA   DISP_EXIT                 ;  and exit                                  

NOT_REVERSE     CMPA  #ALL_STP                  ; Else if it equals the All STOP STATE      
                BNE   NOT_ALL_STP               ;                                           
                JMP   ALL_STP_ST                ;  then call the ALL_STP_ST routine          

NOT_ALL_STP     NOP                             ; Else the CRNT_STATE is not defined, so no operation    

DISP_EXIT       RTS                             ; Exit from the state dispatcher 

; START STATE HANDLER

; Advances state to the FORWARD state if /FWD-BUMP

; Passed:     Current state in ACCA
; Returns:    New state in ACCA
; Clobbers:   None

START_ST        BRCLR PORTAD0,$04,NO_FWD        ; If /FWD_BUMP
                JSR   INIT_FWD                  ; Initialize the FORWARD state
                MOVB  #FWD,CRNT_STATE           ; Go into the FORWARD state
                BRA   START_EXIT               
                                                ;
NO_FWD          NOP                             ; Else
START_EXIT      RTS                           	;  return to the MAIN routine

; FORWARD STATE HANDLER

FWD_ST          PULD                            
                BRSET PORTAD0,$04,NO_FWD_BUMP   ; If FWD_BUMP then
                JSR   INIT_REV                  ;  initialize the REVERSE routine
                MOVB  #REV,CRNT_STATE           ;  set the state to REVERSE
                JMP   FWD_EXIT                  ;  and return
              
NO_FWD_BUMP     BRSET PORTAD0,$08,NO_REV_BUMP   ; Else if REV_BUMP, then we should stop
                JMP   INIT_ALL_STP              ;  so initialize the ALL_STOP state
                MOVB  #ALL_STP,CRNT_STATE       ;  and change state to ALL_STOP
                JMP   FWD_EXIT                  ;  and return

NO_REV_BUMP     LDAA  D_DETN                    ; Else if D_DETN equals 1 then
                BEQ   NO_RT_TURN                ;  the robot should make a turn
                JSR   INIT_RT_TRN               ;  initialize the RT_TRN state
                MOVB  #RT_TRN,CRNT_STATE        ;  and go to that state
                JMP   FWD_EXIT                  

NO_RT_TURN      LDAA  B_DETN                    ; Else if B_DETN equals 1
                BEQ   NO_LT_TURN                ;  Check if A_DETN equals 1
                LDAA  A_DETN                    ;  If A_DETN equals 1 a FORWARD path exists
                BEQ   LT_TURN                   ;  The robot should continue forward
                BRA   NO_SHFT_LT                ;  Else if A_DETN equals 0
                
LT_TURN         JSR   INIT_LT_TRN               ; The robot should make a LEFT turn
                MOVB  #LT_TRN,CRNT_STATE        ; Initialize the LT_TRN state
                JMP   FWD_EXIT                  ; Set CRNT_STATE to LT_TRN and exit

NO_LT_TURN      LDAA  F_DETN                    ; Else if F_DETN equals 1
                BEQ   NO_SHFT_RT                ;  The robot should shift RIGHT
                JSR   PORTON                    ;  and turn on the LEFT motor
RT_FWD_DIS      LDD   COUNT2                    ;
                CPD   #INC_DIS                  ;
                BLO   RT_FWD_DIS                ; If Dc>Dfwd then
                JSR   INIT_FWD                  ;  Turn motors off
                JMP   FWD_EXIT                  ;  and exit

NO_SHFT_RT      LDAA  E_DETN                    ; Else if E_DETN equals 1
                BEQ   NO_SHFT_LT                ;  The robot should shift LEFT
                JSR   STARON                    ;  and turn on the RIGHT motor
LT_FWD_DIS      LDD   COUNT1                    ;
                CPD   #INC_DIS                  ;
                BLO   LT_FWD_DIS                ; If Dc>Dfwd then
                JSR   INIT_FWD                  ;  Turn motors off
                JMP   FWD_EXIT                  ;  and exit

NO_SHFT_LT      JSR   STARON                    ; Turn motors on
                JSR   PORTON                    ; ""
FWD_STR_DIS     LDD   COUNT1                    ;
                CPD   #FWD_DIS                  ;
                BLO   FWD_STR_DIS               ; If Dc>Dfwd then
                JSR   INIT_FWD                  ;  Turn motors off
                
FWD_EXIT        JMP   MAIN                      ; return to the MAIN routine

; REVERSE STATE HANDLER

REV_ST          LDD   COUNT1                    ; If Dc>Drev then
                CPD   #REV_DIS                  ;  The robot should make a U TURN
                BLO   REV_ST                    ;  so
                JSR   STARFWD                   ;  set Starboard Motor to FWD direction
                LDD   #0                        ; Reset timer
                STD   COUNT1                    ; "
                
REV_U_TRN       LDD   COUNT1                    ; If Dc>Dutrn then
                CPD   #UTRN_DIS                 ;  The robot should stop
                BLO   REV_U_TRN                 ;  so
                JSR   INIT_FWD                  ;  Initialize the FWD state
                MOVB  #FWD,CRNT_STATE           ;  Then set state to FWD
                BRA   REV_EXIT                  ;  and exit
               
REV_EXIT        RTS                             ; return to the MAIN routine

; RIGHT TURN STATE HANDLER

RT_TRN_ST       LDD   COUNT2                    ; If Dc>Dfwd then
                CPD   #STR_DIS                  ; The robot should make a TURN
                BLO   RT_TRN_ST                 ; so
                JSR   STAROFF                   ; Set Starboard Motor to OFF
                LDD   #0                        ; Reset timer
                STD   COUNT2                    ; ""
                
RT_TURN_LOOP    LDD   COUNT2                    ; If Dc>Dfwdturn then
                CPD   #TRN_DIS                  ; The robot should stop
                BLO   RT_TURN_LOOP              ; so
                JSR   INIT_FWD                  ; Initialize the FWD state
                MOVB  #FWD,CRNT_STATE           ; Then set state to FWD
                BRA   RT_TRN_EXIT               ; and exit
            
RT_TRN_EXIT     RTS                             ; return to the MAIN routine

; LEFT TURN STATE HANDLER

LT_TRN_ST       LDD   COUNT1                    ; If Dc>Dfwd then
                CPD   #STR_DIS                  ; The robot should make a TURN
                BLO   LT_TRN_ST                 ; so
                JSR   PORTOFF                   ; Set PORT Motor to OFF
                LDD   #0                        ; Reset timer
                STD   COUNT1                    ; ""
                
LT_TURN_LOOP    LDD   COUNT1                    ; If Dc>Dfwdturn then
                CPD   #TRN_DIS                  ; The robot should stop
                BLO   LT_TURN_LOOP              ; so
                JSR   INIT_FWD                  ; Initialize the FWD state
                MOVB  #FWD,CRNT_STATE           ; Then set state to FWD
                BRA   LT_TRN_EXIT               ; and exit

LT_TRN_EXIT     RTS                             ; return to the MAIN routine

; ALL STOP STATE HANDLER

ALL_STP_ST      BRSET PORTAD0,$04,NO_START      ; If FWD_BUMP
                BCLR  PTT,%00110000             ; Initialize the START state
                MOVB  #START,CRNT_STATE         ; Set CRNT_STATE to START
                BRA   ALL_STOP_EXIT             ; Then exit
                                                ;
NO_START        NOP                             ; Else

ALL_STOP_EXIT   RTS                             ; return to the MAIN routine

; MOTOR CONTROL

; Starboard motor ON
STARON          BSET  PTT,%00100000
                RTS

; Starboard motor OFF
STAROFF         BCLR  PTT,%00100000
                RTS

; Starboard motor FORWARD
STARFWD         BCLR  PORTA,%00000010
                RTS

; Starboard motor REVERSE
STARREV         BSET  PORTA,%00000010
                RTS
; Port motor ON
PORTON          BSET  PTT,%00010000
                RTS

; Port motor OFF
PORTOFF         BCLR  PTT,%00010000
                RTS

; Port motor FORWARD
PORTFWD         BCLR  PORTA,%00000001
                RTS

; Port motor REVERSE
PORTREV         BSET  PORTA,%00000001
                RTS

; INITIALIZE FORWARD STATE

; This routine is called whenever the FORWARD routine is entered and turns both the motors OFF.
; It initializes the timer COUNT1, COUNT2 used in by the FORWARD state. 
 
INIT_FWD        BCLR  PTT,%00110000             ; Turn OFF the drive motors
                LDD   #0                        ; Reset timer
                STD   COUNT1                    ; "
                STD   COUNT2                    ; "
                BCLR  PORTA,%00000011           ; Set FWD direction for both motors
                RTS

; INITIALIZE REVERSE STATE

INIT_REV        BSET  PORTA,%00000011           ; Set REV direction for both motors
                LDD   #0                        ; Reset timer
                STD   COUNT1                    ; ""
                BSET  PTT,%00110000             ; Turn ON the drive motors
                RTS

; INITIALIZE RIGHT TURN STATE

INIT_RT_TRN     BCLR  PORTA,%00000011           ; Set FWD direction for both motors
                LDD   #0                        ; Reset timer
                STD   COUNT2                    ; "
                BSET  PTT,%00110000             ; Turn ON the drive motors
                RTS

; INITIALIZE LEFT TURN STATE

INIT_LT_TRN     BCLR  PORTA,%00000011           ; Set FWD direction for both motors
                LDD   #0                        ; Reset timer
                STD   COUNT1                    ; ""
                BSET  PTT,%00110000             ; Turn ON the drive motors
                RTS

; INITIALIZE ALL STOP STATE

INIT_ALL_STP    BCLR  PTT,%00110000             ; Turn OFF the drive motors
                RTS
                
;********************************************************************************************
;*                            Guider and Sensor Subroutine                                  *
;********************************************************************************************

UPDT_READING    JSR   G_LEDS_ON                 ; Turn ON LEDS
                JSR   READ_SENSORS              ; Take readings from sensors
                JSR   G_LEDS_OFF                ; Turn OFF LEDS
                
                LDAA  #0                        ; Set sensor A detection value to 0
                STAA  A_DETN                    ; Sensor A
                STAA  B_DETN                    ; Sensor B
                STAA  C_DETN                    ; Sensor C
                STAA  D_DETN                    ; Sensor D
                STAA  E_DETN                    ; Sensor E
                STAA  F_DETN                    ; Sensor F
                
CHECK_A         LDAA  SENSOR_BOW                ; If SENSOR_BOW is GREATER than
                CMPA  #BASE_BOW                 ; BASE_BOW
                BLO   CHECK_B                   ;
                INC   A_DETN                    ; Set A_DETN to 1

CHECK_B         LDAA  SENSOR_PORT               ; If SENSOR_PORT is GREATER than
                CMPA  #BASE_PORT                ; BASE_PORT
                BLO   CHECK_C                   ;
                INC   B_DETN                    ; Set B_DETN to 1

CHECK_C         LDAA  SENSOR_MID                ; If SENSOR_MID is GREATER than
                CMPA  #BASE_MID                 ; BASE_MID
                BLO   CHECK_D                   ;
                INC   C_DETN                    ; Set C_DETN to 1
                
CHECK_D         LDAA  SENSOR_STAR               ; If SENSOR_STAR is GREATER than
                CMPA  #BASE_STAR                ; BASE_STAR
                BLO   CHECK_E                   ;
                INC   D_DETN                    ; Set D_DETN to 1

CHECK_E         LDAA  SENSOR_LINE               ; If SENSOR_LINE is LESS than
                CMPA  #THRESH_E                 ; THRESH_E
                BHI   CHECK_F                   ;
                INC   E_DETN                    ; Set E_DETN to 1
                
CHECK_F         LDAA  SENSOR_LINE               ; If SENSOR_LINE is GREATER than
                CMPA  #THRESH_F                 ; THRESH_F
                BLO   UPDT_DONE                 ;
                INC   F_DETN                    ; Set F_DETN to 1
                
UPDT_DONE       RTS

; GUIDER LEDS ON

; This routine enables the guider LEDs so that readings of the sensor
;  correspond to the ’illuminated’ situation.

; Passed: Nothing
; Returns: Nothing
; Side: PORTA bit 5 is changed

G_LEDS_ON       BSET  PORTA,%00100000           ; Set bit 5
                RTS

; GUIDER LEDS ON

; This routine disables the guider LEDs. Readings of the sensor
;  correspond to the ’ambient lighting’ situation.

; Passed: Nothing
; Returns: Nothing
; Side: PORTA bit 5 is changed

G_LEDS_OFF      BCLR  PORTA,%00100000           ; Clear bit 5
                RTS

; READ SENSORS

; This routine reads the eebot guider sensors and puts the results in RAM registers.
; Guider board mux must be set to the appropriate channel using the SELECT_SENSOR routine.

; The A/D conversion mode used in this routine is to read the A/D channel AN1 four times into
;  HCS12 data registers ATDDR0, 1, 2, 3. The only result used in this routine is the value 
;  from AN1, read from ATDDR0.
; However, other routines may wish to use the results in ATDDR1, 2 and 3.
; Consequently, Scan=0, Mult=0 and Channel=001 for the ATDCTL5 control word.

READ_SENSORS    CLR   SENSOR_NUM                ; Select sensor number 0
                LDX   #SENSOR_LINE              ; Point at the start of the sensor array
                
RS_MAIN_LOOP    LDAA  SENSOR_NUM                ; Select the correct sensor input
                JSR   SELECT_SENSOR             ;  on the hardware
                LDY   #400                      ; 20 ms delay to allow the
                JSR   del_50us                  ;  sensor to stabilize
                
                LDAA  #%10000001                ; Start A/D conversion on AN1
                STAA  ATDCTL5
                BRCLR ATDSTAT0,$80,*            ; Repeat until A/D signals done
                
                LDAA  ATDDR0L                   ; A/D conversion is complete in ATDDR0L
                STAA  0,X                       ;  so copy it to the sensor register
                CPX   #SENSOR_STAR              ; If this is the last reading
                BEQ   RS_EXIT                   ; Then exit
                
                INC   SENSOR_NUM                ; Else, increment the sensor number
                INX                             ;  and the pointer into the sensor array
                BRA   RS_MAIN_LOOP              ;  and do it again
                
RS_EXIT         RTS
       
; SELECT SENSOR   

; This routine selects the sensor number passed in AccA. The motor direction bits 0, 1,
;  the guider sensor select bit 5 and the unused bits 6, 7 in the same machine register
;  PORTA are not affect.
; Bits PA2, PA3, PA4 are connect to a 74HC4051 analog mux on the guider board, which selects
;  the guider sensor to be connected to AN1.

SELECT_SENSOR   PSHA                            ; Save the sensor number for the moment

                LDAA  PORTA                     ; Clear the sensor selection bits to zeros
                ANDA  #%11100011                
                STAA  TEMP                      ;  and save it into TEMP
                
                PULA                            ; Get the sensor number
                ASLA                            ; Shift the selection number left, twice
                ASLA
                ANDA  #%00011100                ; Clear irrelevant bit positions
                
                ORAA  TEMP                      ; OR it into the sensor bit positions
                STAA  PORTA                     ; Update the hardware
                
                RTS
                
; Binary to ASCII

; Converts an 8 bit binary value in ACCA to the equivalent ASCII character 2
; character string in accumulator D
; Uses a table-driven method rather than various tricks.

; Passed: Binary value in ACCA
; Returns: ASCII Character string in D
; Side Fx: ACCB is destroyed

HEX_TABLE       FCC '0123456789ABCDEF'          ; Table for converting values

BIN2ASC         PSHA                            ; Save a copy of the input number on the stack
                TAB                             ; and copy it into ACCB
                ANDB #%00001111                 ; Strip off the upper nibble of ACCB
                CLRA                            ; D now contains 000n where n is the LSnibble
                ADDD #HEX_TABLE                 ; Set up for indexed load
                XGDX                
                LDAA 0,X                        ; Get the LSnibble character
                
                PULB                            ; Retrieve the input number into ACCB
                PSHA                            ; and push the LSnibble character in its place
                RORB                            ; Move the upper nibble of the input number
                RORB                            ; into the lower nibble position.
                RORB
                RORB 
                ANDB #%00001111                 ; Strip off the upper nibble
                CLRA                            ; D now contains 000n where n is the MSnibble 
                ADDD #HEX_TABLE                 ; Set up for indexed load
                XGDX                                                               
                LDAA 0,X                        ; Get the MSnibble character into ACCA
                PULB                            ; Retrieve the LSnibble character into ACCB
                
                RTS

;********************************************************************************************
;*                                  Utility Subroutine                                      *
;********************************************************************************************

; Initialize PORTS

initPORTS       BCLR  DDRAD,$FF                 ; Set PORTAD as input
                BSET  DDRA, $FF                 ; Set PORTA as output
                BSET  DDRT, $30                 ; Set channels 4 & 5 of PORTT as output
                
                RTS
                
; Initialize AD Converter

initAD          MOVB  #$C0,ATDCTL2              ; power up AD, select fast flag clear
                JSR   del_50us                  ; wait for 50 us
                MOVB  #$00,ATDCTL3              ; 8 conversions in a sequence
                MOVB  #$85,ATDCTL4              ; res=8, conv-clks=2, prescal=12
                BSET  ATDDIEN,$0C               ; configure pins AN03,AN02 as digital inputs
                
                RTS   

; Initialize LCD

; Initialization of the LCD: 4-bit data width, 2-line display,    
; turn on display, cursor and blinking off. Shift cursor right.

initLCD         BSET  DDRB,%11111111            ; configure pins PB7,...,PB0 for output
                BSET  DDRJ,%11000000            ; configure pins PJ7(E), PJ6(RS) for output
                LDY   #2000                     ; wait for LCD to be ready
                JSR   del_50us                  ; -"-
                LDAA  #$28                      ; set 4-bit data, 2-line display
                JSR   cmd2LCD                   ; -"-
                LDAA  #$0C                      ; display on, cursor off, blinking off
                JSR   cmd2LCD                   ; -"-
                LDAA  #$06                      ; move cursor right after entering a character
                JSR   cmd2LCD                   ; -"-
                
                RTS

; Clear LCD and Cursor

clrLCD          LDAA  #$01                      ; clear cursor and return to home position
                JSR   cmd2LCD                   ; -"-
                LDY   #40                       ; wait until "clear cursor" command is complete
                JSR   del_50us                  ; -"-
                
                RTS
     
; Initialize Timer Count

initTCNT        MOVB  #$80,TSCR1                ; enable TCNT
                MOVB  #$00,TSCR2                ; disable TCNT OVF interrupt, set prescaler to 1
                MOVB  #$FC,TIOS                 ; channels PT1/IC1,PT0/IC0 are input captures
                MOVB  #$05,TCTL4                ; capture on rising edges of IC1,IC0 signals
                MOVB  #$03,TFLG1                ; clear the C1F,C0F input capture flags
                MOVB  #$03,TIE                  ; enable interrupts for channels IC1,IC0
                
                RTS
                
; DELAY
          
; ([Y] x 50us)-delay subroutine. E-clk=41, 67ns.

del_50us:       PSHX                            ; 2 E-clk Protect the X register
eloop:          LDX   #300                      ; 2 E-clk Initialize the inner loop counter
iloop:          NOP                             ; 1 E-clk No operation
                DBNE  X,iloop                   ; 3 E-clk If the inner cntr not 0, loop again
                DBNE  Y,eloop                   ; 3 E-clk If the outer cntr not 0, loop again
                PULX                            ; 3 E-clk Restore the X register
                                                  
                RTS                             ; 5 E-clk Else return
                
; This function sends a command in accumulator A to the LCD

cmd2LCD:        BCLR  LCD_CNTR,LCD_RS           ; select the LCD Instruction Register (IR)
                JSR   dataMov                   ; send data to IR
                
      	        RTS

; This function outputs a NULL-terminated string pointed to by X

putsLCD         LDAA  1,X+                      ; get one character from the string
                BEQ   donePS                    ; reach NULL character?
                JSR   putcLCD
                BRA   putsLCD
                
donePS 	        RTS

; This function outputs the character in accumulator A to LCD

putcLCD         BSET  LCD_CNTR,LCD_RS           ; select the LCD Data register (DR)
                JSR   dataMov                   ; send data to DR
                
                RTS
                
; This function sends data to the LCD IR or DR depending on RS    

dataMov         BSET  LCD_CNTR,LCD_E            ; pull the LCD E-sigal high
                STAA  LCD_DAT                   ; send the upper 4 bits of data to LCD
                BCLR  LCD_CNTR,LCD_E            ; pull the LCD E-signal low to complete the write oper.
                
                LSLA                            ; match the lower 4 bits with the LCD data pins
                LSLA                            ; -"-
                LSLA                            ; -"-
                LSLA                            ; -"-
                
                BSET  LCD_CNTR,LCD_E            ; pull the LCD E signal high
                STAA  LCD_DAT                   ; send the lower 4 bits of data to LCD
                BCLR  LCD_CNTR,LCD_E            ; pull the LCD E-signal low to complete the write oper.
                
                LDY   #1                        ; adding this delay will complete the internal
                JSR   del_50us                  ;  operation for most instructions
                
                RTS


; INTEGER TO BCD CONVERSION

; This routine converts a 16 bit binary number in .D into
; BCD digits in BCD_BUFFER.

int2BCD         XGDX                            ; Save the binary number into .X
                LDAA  #0                        ; Clear the BCD_BUFFER
                STAA  TEN_THOUS
                STAA  THOUSANDS
                STAA  HUNDREDS
                STAA  TENS
                STAA  UNITS
                STAA  BCD_SPARE
                STAA  BCD_SPARE+1

                CPX   #0                        ; Check for a zero input
                BEQ   CON_EXIT                  ;  and if so, exit

                XGDX                            ; Not zero, get the binary number back to .D as dividend
                LDX   #10                       ; Setup 10 (Decimal!) as the divisor
                IDIV                            ; Divide: Quotient is now in .X, remainder in .D
                STAB  UNITS                     ; Store remainder
                CPX   #0                        ; If quotient is zero,
                BEQ   CON_EXIT                  ;  then exit

                XGDX                            ;  else swap first quotient back into .D
                LDX   #10                       ;  and setup for another divide by 10
                IDIV
                STAB  TENS
                CPX   #0
                BEQ   CON_EXIT

                XGDX                            ;  else swap first quotient back into .D
                LDX   #10                       ;  and setup for another divide by 10
                IDIV
                STAB  HUNDREDS
                CPX   #0
                BEQ   CON_EXIT

                XGDX                            ;  else swap first quotient back into .D
                LDX   #10                       ;  and setup for another divide by 10
                IDIV
                STAB  THOUSANDS
                CPX   #0
                BEQ   CON_EXIT

                XGDX                            ;  else swap first quotient back into .D
                LDX   #10                       ;  and setup for another divide by 10
                IDIV
                STAB  TEN_THOUS

CON_EXIT        RTS                             ; Completed conversion
      
; BCD TO ASCII CONVERSION

; This routine converts the BCD number in the BCD_BUFFER
;  into ascii format, with leading zero suppression.
; Leading zeros are converted into space characters.
; The flag 'NO_BLANK' starts cleared and is set once a non-zero
;  digit has been detected
; The 'units' digit is never blanked, even if it and all the
;  preceding digits are zero.

BCD2ASC         LDAA  #$0                       ; Initialize the blanking flag
                STAA  NO_BLANK

C_TTHOU         LDAA  TEN_THOUS                 ; Check the 'ten_thousands' digit
                ORAA  NO_BLANK
                BNE   NOT_BLANK1

ISBLANK1        LDAA  #$20                      ; It's blank
                STAA  TEN_THOUS                 ;  so store a space
                BRA   C_THOU                    ;  and check the 'thousands' digit

NOT_BLANK1      LDAA  TEN_THOUS                 ; Get the 'ten_thousands' digit
                ORAA  #$30                      ; Convert to ascii
                STAA  TEN_THOUS
                LDAA  #$1                       ; Signal that we have seen a 'non-blank' digit
                STAA  NO_BLANK

C_THOU          LDAA  THOUSANDS                 ; Check the thousands digit for blankness
                ORAA  NO_BLANK                  ; If it's blank and 'no-blank' is still zero
                BNE   NOT_BLANK2
                     
ISBLANK2        LDAA  #$30                      ; Thousands digit is blank
                STAA  THOUSANDS                 ;  so store a space
                BRA   C_HUNS                    ;  and check the hundreds digit

NOT_BLANK2      LDAA  THOUSANDS                 ; (similar to 'ten_thousands' case)
                ORAA  #$30
                STAA  THOUSANDS
                LDAA  #$1
                STAA  NO_BLANK

C_HUNS          LDAA  HUNDREDS                  ; Check the hundreds digit for blankness
                ORAA  NO_BLANK                  ; If it's blank and 'no-blank' is still zero
                BNE   NOT_BLANK3

ISBLANK3        LDAA  #$20                      ; Hundreds digit is blank
                STAA  HUNDREDS                  ;  so store a space
                BRA   C_TENS                    ;  and check the tens digit
                     
NOT_BLANK3      LDAA  HUNDREDS                  ; (similar to 'ten_thousands' case)
                ORAA  #$30
                STAA  HUNDREDS
                LDAA  #$1
                STAA  NO_BLANK

C_TENS          LDAA  TENS                      ; Check the tens digit for blankness
                ORAA  NO_BLANK                  ; If it's blank and 'no-blank' is still zero
                BNE   NOT_BLANK4
                     
ISBLANK4        LDAA  #$20                      ; Tens digit is blank
                STAA  TENS                      ;  so store a space
                BRA   C_UNITS                   ;  and check the units digit

NOT_BLANK4      LDAA  TENS                      ; (similar to 'ten_thousands' case)
                ORAA  #$30
                STAA  TENS

C_UNITS         LDAA  UNITS                     ; No blank check necessary, convert to ascii.
                ORAA  #$30
                STAA  UNITS

                RTS                             ; Completed Conversion
                

;********************************************************************************************
;*                       Update Display (Battery Voltage + Current State)                   *
;********************************************************************************************

UPDT_DISPL      MOVB  #$90,ATDCTL5              ; R-just., uns., sing. conv., mult., ch=0, start
                BRCLR ATDSTAT0,$80,*            ; Wait until the conver. seq. is complete
                
                LDAA  ATDDR0L                   ; Load the ch0 result - battery volt - into A
            
                LDAB  #39                       ; AccB = 39
                MUL                             ; AccD = 1st result x 39
                ADDD  #600                      ; AccD = 1st result x 39 + 600
                
                JSR   int2BCD
                JSR   BCD2ASC
                
                LDAA  #$8D                      ; move LCD cursor to the 1st row, end of msg1
                JSR   cmd2LCD                   ;  "                
                
                LDAA  TEN_THOUS                 ; output the TEN_THOUS ASCII character
                JSR   putcLCD                   ;  "
                
                LDAA  THOUSANDS                 ; output the THOUSANDS ASCII character
                JSR   putcLCD                   ;  "
                
                LDAA  #'.'                      ; output the "." ASCII character
                JSR   putcLCD                   ;  "
                
                LDAA  HUNDREDS                  ; output the HUNDREDS ASCII character
                JSR   putcLCD                   ;  "                

;-------------------------                
                LDAA  #$C6                      ; Move LCD cursor to the 2nd row, end of msg2
                JSR   cmd2LCD                   ;
                
                LDAB  CRNT_STATE                ; Display current state
                LSLB                            ; "
                LSLB                            ; "
                LSLB                            ; "
                LDX   #tab                      ; "
                ABX                             ; "
                JSR   putsLCD                   ; "

		            RTS       

; Interrupt Service Routine: COUNT1

ISR1            MOVB  #$01,TFLG1                ; clear the C0F input capture flag
                INC   COUNT1                    ; increment COUNT1
                RTI
                
; Interrupt Service Routine: COUNT2

ISR2            MOVB  #$02,TFLG1                ; clear the C1F input capture flag
                INC   COUNT2                    ; increment COUNT2 
                RTI
                
;********************************************************************************************
;*                                  Interrupt Vectors                                       *
;********************************************************************************************
                ORG   $FFFE
                DC.W  Entry                     ; Reset Vector

                ORG   $FFEE
                DC.W  ISR1                      ; COUNT1 INT

                ORG   $FFEC
                DC.W  ISR2                      ; COUNT2 INT

  
