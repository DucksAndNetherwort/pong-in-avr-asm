#include "avr/io.h"
.global __do_copy_data
; arg1: r24, arg2: r22, result: r24
.macro ldi_w reg:req, val:req ; rlo, val !!USE NUMBER, NOT Rx!!
    ldi \reg, lo8(\val)
    ldi \reg + 1, hi8(\val)
.endm

.global playerUpdateASM
playerUpdateASM:
  push r16
  push r18
  push r22

  lds r24, P1
  lds r22, paddleSize

  in r16, _SFR_IO_ADDR(PINB)
  sbrc r16, 1
  jmp 1f
  cpi r24, 0
  brne 2f
  jmp 1f
2:
  dec r24
1:
  sbrc r16, 0
  jmp 3f
  ldi r18, 8
  sub r18, r22
  mov r22, r18
  cp r24, r22
  brlo 1f
  jmp 3f
1:
  inc r24
3:
  sts P1, r24

  pop r22
  pop r18
  pop r16
ret

.global ballUpdateASM
ballUpdateASM:
  push r23
  push r24
  push r21
  push r22
  push r16
  push r18
  push r25

  lds r23, ball ; ball x
  lds r24, (ball + 1) ; ball y
  lds r21, trajectory ; trajectory x
  lds r22, (trajectory + 1) ; trajectory y
  lds r25, P1


  cpi r24, 7
  brsh 1f
  rjmp 2f
1:
  clr r22
2:

  cpi r24, 1
  brlo 1f
  rjmp 2f
1:
  ser r22
2:

  cpi r23, 15
  brsh 1f
  rjmp 2f
1:
  call resetGameASM
2:

  ldi r18, 14
  cpse r23, r18 ; ball == 14
  rjmp 1f
  cp r23, r25
  brsh 2f ; ball[0] >= P1
  rjmp 1f
2:
  lds r16, paddleSize
  add r25, r16 ; (ball[1] < (P1 + paddleSize))
  cp r24, r25 
  brsh 1f

  clr r21
  lds r18, score
  inc r18
  sts score, r18
1:

  cpi r23, 1
  brne 1f
  ser r21
1:


  sbrc r21, 4 ; true ++
  inc r23
1:
  
  sbrs r21, 4 ; false --
  dec r23
1:

  sbrc r22, 4 ; true ++
  inc r24
1:

  sbrs r22, 4 ; false --
  dec r24
1:

  ; P1 = r25
  sts ball, r23 ; ball x
  sts (ball + 1), r24 ; ball y
  sts trajectory, r21 ; trajectory x
  sts (trajectory + 1), r22 ; trajectory y

  pop r25
  pop r18
  pop r16
  pop r22
  pop r21
  pop r24
  pop r23
ret

.global renderASM
renderASM:
  push r24
  push r22
  push r18
  push r19
  push r20
  push r16
  push r17

  lds r19, paddleSize ; render player paddle
  ldi r24, 15
  lds r22, P1
  clr r20
1:
    rcall setPixel
    inc r22
    inc r20
    cpse r19, r20
  rjmp 1b ; finish

  ldi r24, 0 ; render computer paddle
  lds r22, (ball + 1)
  lsr r22
  lds r18, (ball + 1)
  lds r19, paddleSize
  inc r19
  cp r19, r18
  brsh 1f
  ldi r17, 8
  lds r19, paddleSize
  sub r17, r19
  mov r22, r17
1:
  lds r18, (ball + 1)
  cpi r18, 1
  brsh 1f
  ldi r22, 0
1:

  ldi r18, 0
  lds r16, paddleSize
1:
  cp r18, r16
  brsh 1f
  inc r18
  rcall setPixel
  inc r22
  rjmp 1b ; finish
1:

  lds r24, ball
  lds r22, (ball + 1)
  rcall setPixel

  pop r17
  pop r16
  pop r20
  pop r19
  pop r18
  pop r22
  pop r24
ret

setPixel:
  ; imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
  ; pen x = r24
  ; pen y = r22
  ; selected imgBuffer = r28/r29 (y)
  push r22
  push r24
  push r28
  push r29
  push r19
  push r18
  push r20
  clr r1

  mov r20, r24
  lsr r24 ; pen[0] >> 3
  lsr r24
  lsr r24

  lsl r22 ; pen[1] << 1

  add r22, r24 ; +
  ldi_w 28, imgBuffer ; load imgBuffer
  add r28, r22
  adc r29, r1 ; finish load
  ldd r19, y+ ; imgBuffer byte stored in r19

  mov r24, r20
  ldi r18, 0x80 ; (0x80 >> (pen[0] & 0x07))
  andi r24, 0x07
1:
  cpse r24, r1
  lsr r18
  cpse r24, r1
  dec r24
  cpse r24, r1
  rjmp 1b ; finish

  or r19, r18 ; |=
  st y+, r19

  ; imgBuffer[((pen[0] >> 3) + (pen[1] << 1))] |= (0x80 >> (pen[0] & 0x07));
  ; pen x = r24
  ; pen y = r22
  ; selected imgBuffer = r28/r29 (y)
  pop r20
  pop r18
  pop r19
  pop r29
  pop r28
  pop r24
  pop r22
ret

.global resetGameASM
resetGameASM:
  jmp 0x0000
ret

.global dispClearASM
dispClearASM:
  push r28
  push r29
  push r18
  push r19
  clr r1
  clr r19
  ldi r18, 16

1:
  ldi_w 28, imgBuffer
  add r28, r19
  adc r29, r1
  st y+, r1
  inc r19
  cpse r19, r18
  rjmp 1b


  pop r19
  pop r18
  pop r29
  pop r28
ret

.global dispWriteASM
dispWriteASM:
  push r24
  push r16
  clr r16
  push r18
  push r19
  push r28
  push r29
  clr r1

1:
  cbi _SFR_IO_ADDR(PORTB), 2
  mov r24, r16 ; select row (with increment)
  inc r24
  rcall TXspi ; finish select
  mov r18, r16 ; prep image data
  lsl r18
  inc r18
  ldi_w 28, imgBuffer
  add r28, r18
  adc r29, r1
  ldd r24, y+
  rcall TXspi ; finish and send

  mov r24, r16 ; select row (without increment)
  inc r24
  rcall TXspi ; finish select
  mov r18, r16 ; prep image data
  lsl r18
  ldi_w 28, imgBuffer
  add r28, r18
  adc r29, r1
  ldd r24, y+
  rcall TXspi ; finish and send
  sbi _SFR_IO_ADDR(PORTB), 2

  inc r16 ; run iteration tests
  ldi r18, 8
  cpse r18, r16
  rjmp 1b

  ; add r28, r22
  ; adc r29, r1 ; finish load
  ; ldd r19, y+ ; imgBuffer byte stored in r19
  pop r29
  pop r28
  pop r19
  pop r18
  pop r16
  pop r24
ret

TXspi:
  push r18

  out _SFR_IO_ADDR(SPDR), r24 ; Initiate data transfer.
  1:
  in r18, _SFR_IO_ADDR(SPSR)
  sbrs r18, SPIF ; Wait for transmission to complete.
  rjmp 1b

  pop r18
ret

.global spiSetup
spiSetup:
  push r16 ; this was mostly just copied off avrbeginners.net

  sbi _SFR_IO_ADDR(DDRB), DDB5 ; Set MOSI as output.
  sbi _SFR_IO_ADDR(DDRB), DDB7 ; set sck as output
  sbi _SFR_IO_ADDR(DDRB), DDB4 ; set ss as output
  ldi r16, 0b01011101 ; set spi as master, interrupt disabled
  out _SFR_IO_ADDR(SPCR), r16 ; MSB first, SPI mode 3 and clock frequency fosc/16.

  pop r16
ret

.global main
main: ; time for setup!
  ldi r16, 0xff
  out _SFR_IO_ADDR(DDRD), r16
  ldi r16, 0b00101100
  out _SFR_IO_ADDR(DDRB), r16
  ldi r16, 0b00000011
  out _SFR_IO_ADDR(PORTB), r16
  call spiSetup
  call dispClearASM
  call dispWriteASM

  clr r16 ; PORTD = (1 << (scoreDivide - 1));
  lds r18, scoreDivide
  dec r18
  ldi r19, 1
1:
  lsl r19
  inc r16
  cpse r16, r18
  rjmp 1b

  out _SFR_IO_ADDR(PORTD), r19 ; finish

mainPostSetup:
  lds r18, updateBall
  inc r18
  sts updateBall, r18

  lds r16, scoreDivide ; if(updateBall > (7 - scoreDivide))
  ldi r19, 7
  sub r19, r16
  cp r19, r18
  brsh 1f ; finish
  clr r18
  sts updateBall, r18
  call ballUpdateASM
1:

  call playerUpdateASM
  call dispClearASM
  call renderASM
  call dispWriteASM

  lds r16, score ; if(score >= (1 << scoreDivide))
  ldi r18, 1
  lds r19, scoreDivide
  clr r20
1:
  lsl r18
  inc r20
  cpse r20, r19
  rjmp 1b

  cp r16, r18
  brlo 1f ; finish

  cpi r19, 8 ; if(!(scoreDivide > 7))
  brsh 2f
  inc r19
  sts scoreDivide, r19
  lds r18, paddleSize
  dec r18
  sts paddleSize, r18
2:

  cpi r19, 8 ; if(scoreDivide > 7)
  brlo 2f
  ldi r19, 7
  sts scoreDivide, r19
2:

  cpi r18, 1 ; if(paddleSize < 1)
  brsh 2f
  ldi r18, 1
  sts paddleSize, r18
2:
1:

  clr r16 ; PORTD = (1 << (scoreDivide - 1));
  lds r18, scoreDivide
  dec r18
  ldi r19, 1
1:
  lsl r19
  inc r16
  cpse r16, r18
  rjmp 1b

  out _SFR_IO_ADDR(PORTD), r19 ; finish

  push r24 ; delay
  push r25
  clr r25
  ldi r24, 50
  rcall delayMillis
  pop r25
  pop r24
jmp mainPostSetup

; arg1 (r24:r25) - number of milliseconds to delay (uint_16)
.global delayMillis ; thanks uri for the delay function ;)
delayMillis:
  ; 16000 cycles
  ldi r26, 4000 & 0xff
  ldi r27, 4000 >> 8
1:
  sbiw r26, 1  ; 2 cycles
  brne 1b      ; 2 cycles 
  sbiw r24, 1
  brne delayMillis
ret