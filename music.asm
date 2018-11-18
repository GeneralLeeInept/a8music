VVBLKD	= $0224
SDMCTL	= $022F

COLBK	= $D01A

AUDF1	= $D200
AUDC1	= $D201
AUDF2	= $D202
AUDC2	= $D203
AUDF3	= $D204
AUDC3	= $D205
AUDF4	= $D206
AUDC4	= $D207
AUDCTL	= $D208
SKCTL	= $D20F

WSYNC	= $D40A
VCOUNT	= $D40B

SETVBV 	= $E45C
XITVBV	= $E462

	org $80
	
music_idx
	.byte $ff

music_clock
	.byte $01

envelope_ptr
	.word $0000
	
envelope_idx
	.byte $00
		
	org $2000

	.proc main
	
; turn off Antic DMA
	mva #0 SDMCTL
	
; initialize audio registers
	mva #0 AUDF1
	mva #0 AUDC1
	mva #0 AUDCTL
	mva #3 SKCTL	; ?? D.R.A. says to do this to match sound 0,0,0,0 in basic, so I did it

; set VBI deferred handler
	lda #07
	ldx #>(vvblkd_handler)
	ldy #<(vvblkd_handler)
	jsr SETVBV
	
; lights & music!
loop	lda VCOUNT
	sta WSYNC
	sta COLBK
	jmp loop
	
	.endp

	.proc vvblkd_handler
	
; update music
	dec music_clock
	lda #0
	cmp music_clock
	bne envelope

	inc music_idx
	ldx music_idx

	lda length,x
	bne play
	ldx #0
	stx music_idx
	lda length,x
	
play
	mvy #$ff envelope_idx
	sta music_clock
	
useenv45
	cmp #45
	bne useenv20
	mwa #envelope45 envelope_ptr
	jmp envset
	
useenv20
	cmp #20
	bne useenv5
	mwa #envelope20 envelope_ptr
	jmp envset
	
useenv5
	mwa #envelope5 envelope_ptr
	jmp envset
		
envset
	mva notes,x AUDF1
		 	
envelope
	inc envelope_idx
	ldy envelope_idx
	lda (envelope_ptr),y
	ora #$a0
	sta AUDC1
	
; exit handler
	jmp XITVBV
	
	.endp
	
notes
	; c c g g a a g-
	.byte	121, 0, 121, 0, 81, 0, 81, 0, 72, 0, 72, 0, 81, 0
	
	; f f e e d d c-
	.byte	91, 0, 91, 0, 96, 0, 96, 0, 108, 0, 108, 0, 121, 0
	 
	; g g f f e e d-
	.byte	81, 0, 81, 0, 91, 0, 91, 0, 96, 0, 96, 0, 108, 0
	
	; g g f f e e d-
	.byte	81, 0, 81, 0, 91, 0, 91, 0, 96, 0, 96, 0, 108, 0

	; c c g g a a g-
	.byte	121, 0, 121, 0, 81, 0, 81, 0, 72, 0, 72, 0, 81, 0

	; f f e e d d c-
	.byte	91, 0, 91, 0, 96, 0, 96, 0, 108, 0, 108, 0, 121, 0

	.byte	0
	
length
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 45, 5
	.byte	0

envelope5
	.byte	0, 0, 0, 0, 0
	
envelope20
	.byte	4, 8, 12, 10, 10
	.byte	10, 9, 9, 8, 8, 7, 6, 6, 6, 6
	.byte	6, 4, 2, 1, 1
		
envelope45
	.byte	4, 8, 12, 10, 10
	.byte	10, 9, 9, 8, 8, 7, 7, 7, 7, 7
	.byte	7, 7, 7, 7, 7, 7, 7, 7, 7, 7
	.byte	7, 7, 7, 7, 7, 7, 7, 7, 6, 6
	.byte	5, 5, 4, 4, 3, 3, 2, 2, 1, 1

	run main
	