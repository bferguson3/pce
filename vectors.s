;;;
; Vector table

.align $1ff6

.word $e000 ; irq2 brk/ext_bus =f6
.word VBLANK ; irq1 vdc =f8
.word $e000 ; timer =fa
.word $ffff ; nmi (not used) = fc
.word INIT ; reset = fe