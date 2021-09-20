
; PC Engine Test

.define PAGE_RAM $f8 
.define PAGE_IO $FF

.define VDCDATA_H $0103
.define VDCDATA_L $0102
.define VDCPORT $0100

.define REG_CR $5
.define REG_RCR 6
.define REG_BXR $7
.define REG_BYR $8
.define REG_MWR 9
.define REG_HSR 10
.define REG_HDR 11
.define REG_VPR $0c
.define REG_VDW $0d 
.define REG_VCR $0e 

.define TILESIZE_32X32 0
.define TILESIZE_64X32 %10000

.define BB %10000000
.define SB %01000000

.define ZEROPAGE $2000

.define _NUMTILES 32
.define ASCII_TABLE 512-64

.macro ResetPalettes
	stz $0400
.endmacro
.macro SetVDCReg reg, dat
	st0 #reg 
	st1 #((dat) & $ff)
	st2 #((dat) >> 8)
.endmacro
.macro SelectColor index 
	lda #(index & $ff)
	sta $0402 
	lda #(index >> 8)
	sta $0403 ; pal no
.endmacro 
.macro SetColor r,g,b 
	lda #(((g & %11) << 6)|(r << 3)|(b))
	sta $0404 
	lda #((g&%100)>>2)
	sta $0405
.endmacro 
.macro PageMemory pg,slot 
	lda #pg 
	tam #(1<<slot)
.endmacro 
.macro SetTile tileno,index,pal  
	st0 #0 
	st1 #((tileno)&$ff) 
	st2 #((tileno)>>8)
	st0 #2 
	st1 #(index & $ff)
	st2 #((index >> 8)|(pal << 4))
.endmacro 
.macro Push16 val 
	lda #>val 
	pha 
	lda #<val 
	pha
.endmacro 
.macro SetZReturn
	ply 
	plx  
	stx ZEROPAGE+$1
	iny  
	sty ZEROPAGE
.endmacro
.macro Push8 arg 
	lda #(arg)
	pha
.endmacro	


	.org $e000

INIT:
	; disable interrupts
	sei 
	; toggle in ram and I/O pages:
	PageMemory PAGE_IO, 0
	PageMemory PAGE_RAM, 1
	
	; set CR:
	SetVDCReg REG_CR, BB|SB 
	
	; set bat x
	SetVDCReg REG_BXR,0
	SetVDCReg REG_BYR,0

	; Mem width register: set tilemap to 64x32
	SetVDCReg REG_MWR,TILESIZE_64X32|%0000
	; Set Hsync IRQ to raster 259 ($143-$40)
	SetVDCReg REG_RCR, $143
	;  256x240 display mode:
	; HDS: 3, HSW: 3 ($0202) +1/+1
	SetVDCReg REG_HSR,$0202
	; HDE: 4, HDW: 32 ($031f) +1/+1
	SetVDCReg REG_HDR,$031f
	; VDS: 17, VSW: 2 ($0f02) +2/+0
	SetVDCReg REG_VPR,$0f02
	; VDW: 240 ($ef) +1
	SetVDCReg REG_VDW,$00ef
	; VCR: 3
	SetVDCReg REG_VCR,$0003

	; Set up basic colors
	ResetPalettes
	
	SelectColor 0 
	SetColor 1,1,1
	
	SelectColor 1
	SetColor 0,0,7 
	
	SelectColor 2
	SetColor 7,0,0

	; Load tiles test
	Push8 (_NUMTILES/8)
	Push16 CHARTABLE 
	Push16 $2000
	jsr LoadTileData

	;SetTile (64*1)+1,(ASCII_TABLE+'A'),0
	;SetTile (64*1)+2,(ASCII_TABLE+'B'),0
	;SetTile (64*1)+3,(ASCII_TABLE+'C'),0
	;SetTile (64*1)+4,(ASCII_TABLE+'Z'),0
	; Hachinoid PNG test
	SetTile (64*1)+1,512,0
	SetTile (64*1)+2,513,0
	SetTile (64*1)+3,514,0
	SetTile (64*1)+4,515,0
	SetTile (64*1)+5,516,0
	SetTile (64*1)+6,517,0

	
loop:
	jmp loop

;;;

LoadTileData:
; Copy N tiles from SRCADDR to VDPDEST
; Uses ZP 0-4
; Push8 N/8
; Push16 ROMsrc
; Push16 VDPdest
; 
	SetZReturn  ; sets return address in (ZEROPAGE+$0)	
	
	st0 #0       ; VDP destination addr
	pla 
	sta VDCDATA_L
	pla 
	sta VDCDATA_H 

	; indirect location of tile bytes 
	pla 
	sta ZEROPAGE+$2
	pla 
	sta ZEROPAGE+$3
	
	; number of tiles / 8
	pla 
	sta ZEROPAGE+$4
	; write loop: indrect
	ldx #0
	st0 #2 
	_cpyloopw:
	ldy #0
	_cpyloop:
	lda ($02),y
	sta VDCDATA_L
	iny 
	lda ($02),y
	sta VDCDATA_H
	iny 
	cpy #0 				; if y = 0 8 chars were copied
	bne _cpyloop
	inc ZEROPAGE+$3		; next 256 bytes
	inx 
	cpx ZEROPAGE+$4
	bne _cpyloopw
	
	jmp (ZEROPAGE)

;;;

VBLANK:
	rti 

;;;

CHARTABLE:  
.include "bar_sprite.s"


.include "vectors.s"
