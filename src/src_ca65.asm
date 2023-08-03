; MIT License
;
; Copyright (c) 2019 David Macintosh (Dawid Z. D.)
; CC65 port by Persune 2023
; Additional modifications to audio and graphics by Persune 2023
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

NSF_mode = 0
Screen_wiggle = 0
Screen_scroll = 0

screen_x = $02
screen_y = $08

palette_0 = $FF
palette_1 = $FF
palette_2 = $2B
palette_3 = $2C

cutoff_bank = $FA
loop_mode = 1

.segment "INESHDR"
;; NES 2.0
	.byte $4E, $45, $53, $1A, $00, $00, $20, $08, $00, $01, $00, $07, $00, $00, $00, $00

;;; PRG

;;; PRGAudio

.segment "PCMDATA"
	.incbin "audio.bin"

;;; PRGLast

.segment "CODE"

;; RESET routine
RESET:
	sei
	cld
	
	ldx #$40
	stx $4017
	
	;; Set the stack pointer @ $01ff
	ldx #$ff
	txs
	inx
	stx $2000
	stx $2001
	jsr VBlank
	
	@ClearRAM:
		lda #$ff
		sta $0200,x
		lda #$00
		sta $0000,x
		sta $0100,x
		sta $0300,x
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		inx
		bne @ClearRAM
	
	jsr VBlank
	
	;; Load CHRRAM
	jsr LoadCHRRAM
	jsr VBlank
	
	;; Load palette
	jsr LoadPalette
	jsr VBlank
	
	;; Load background
	jsr LoadBackground
	jsr VBlank
	lda $2002
	lda #%00001110
	sta $2001
	lda #$00
	sta $2006
	sta $2006
	lda #screen_x
	sta $2005
	lda #screen_y
	sta $2005
	lda #$80
	sta $01

	jsr VBlank
	
	lda #$00
	sta $ff
	tay
	ldx #$40
	jmp DMCDirectLoad



;; Nametable data (for background)
NameTable:
	.incbin "nametable.bin"
	.res 64,0

;; CHR Data
CHRData:
	.incbin "chr.bin"

;;; Subroutines

;; Wait for the VBlank
VBlank:
	lda $2002
	bpl VBlank
	rts
	
;; Quick load the palette
LoadPalette:
	lda $2002
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	lda #palette_0
	sta $2007
	lda #palette_1
	sta $2007
	lda #palette_2
	sta $2007
	lda #palette_3
	sta $2007
	rts

;;Load the CHR data into CHRRAM
LoadCHRRAM:
	lda #<CHRData
	sta $03
	lda #>CHRData
	sta $04
	
	ldy $2002
	ldy #$00
	sty $2001
	sty $2006
	sty $2006
	ldx #$32
	
@loop:
	lda ($03),y
	sta $2007
	iny
	bne @loop
	inc $04
	dex
	bne @loop
	rts
	
;; Load background
LoadBackground:
	ldx #$04
	ldy #$00
	lda #<NameTable
	sta $03
	lda #>NameTable
	sta $04
	lda $2002
	lda #$20
	sta $2006
	lda #$00
	sta $2006
@loop:
	lda ($03),y
	sta $2007
	iny
	bne @loop
	inc $04
	dex
	bne @loop
	rts
	
;; Here's where the whole magic happens (PCM streaming)
;; writes a sample every 45 CPU cycles
;; samplerate is actually 39,772.73333...
DMCDirectLoad:
	ldy #$00
	ldx #$40
	
	lda $ff
	cmp #cutoff_bank
	bne @res
.if loop_mode
	jmp end
.else
	lda #$00
	sta $ff
.endif

@res:
	sta $8000
	lda #$80
	sta $01
@LoopXY:
.if Screen_wiggle
	lda ($00),y
	sta $4011
	; wiggle the screen according to the audio
	sec
	sbc #$40
	sta $2005
	lda #screen_y
	sta $2005

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	iny
	bne @LoopXY
	inc $01
	dex
	bne @LoopXY
	inc $ff
.elseif Screen_scroll
	lda ($00),y
	sta $4011
	; scroll the screen according to the current bank
	lda $ff
	sta $2005
	lda #screen_y
	sta $2005
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bit $00
	
	iny
	bne @LoopXY
	inc $01
	dex
	bne @LoopXY
	inc $ff
.else
	lda ($00),y
	sta $4011

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	iny
	bne @LoopXY
	inc $01
	dex
	bne @LoopXY
	inc $ff
.endif
	jmp DMCDirectLoad

NMI:
IRQ:
end:
	lda #screen_x
	sta $2005
	lda #screen_y
	sta $2005
loop:
	jmp loop

;; Interrupt vectors
.segment "STUB15"
	.word NMI, RESET, IRQ
