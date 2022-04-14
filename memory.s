
	INCLUDE equates.h
	INCLUDE h6280.h
	INCLUDE vdc.h

	EXPORT void
	EXPORT empty_R
	EXPORT empty_W
	EXPORT empty_IO_W
	EXPORT ram_R
	EXPORT ram_W
	EXPORT sram_R
	EXPORT sram_W
	EXPORT cdram_W
	EXPORT scdram_W
	EXPORT rom_R0
	EXPORT rom_W
	EXPORT bytecopy_
	EXPORT memset_
	EXPORT memorr_
;----------------------------------------------------------------------------
 AREA rom_code, CODE, READONLY
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
bytecopy_		;void bytecopy(u8 *dst,u8 *src,int count)
;----------------------------------------------------------------------------
	subs r2,r2,#1
	ldrplb r3,[r1,r2]
	strplb r3,[r0,r2]
	bhi bytecopy_
	bx lr

;----------------------------------------------------------------------------
empty_R		;read bad address (error)
;----------------------------------------------------------------------------
	[ DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	]

void ;- - - - - - - - -empty function
	mov r11,r11				;No$GBA debugg
	mov r0,#0xff			;seems to be the standard on PCE
	mov pc,lr
;----------------------------------------------------------------------------
empty_W		;write bad address (error)
;----------------------------------------------------------------------------
	[ DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	|
		mov r11,r11			;No$GBA debugg
		mov pc,lr
	]
;----------------------------------------------------------------------------
empty_IO_W		;write bad IO address (error)
;----------------------------------------------------------------------------
;		mov r11,r11			;No$GBA debugg
		mov pc,lr
;----------------------------------------------------------------------------
rom_W		;write ROM address (SF2 needs this)
;----------------------------------------------------------------------------
	mov r11,r11			;No$GBA debugg
	ldr r1,rommask		;rommask=romsize-1
	cmp r1,#0x80
	ldr r1,=0x1ffc
	ldr r2,=0x1ff0
	and r1,r1,addy
	cmppl r1,r2
	andeq r1,addy,#3
	ldreq r2,=SF2Mapper
	streq r1,[r2]
	mov pc,lr


;----------------------------------------------------------------------------
	AREA wram_code2, CODE, READWRITE
;----------------------------------------------------------------------------
ram_R	;ram read ($0000-$1FFF)
;----------------------------------------------------------------------------
	bic r1,addy,#0xfe000
	ldrb r0,[pce_zpage,r1]
	mov pc,lr
;----------------------------------------------------------------------------
ram_W	;ram write ($0000-$1FFF)
;----------------------------------------------------------------------------
	bic r1,addy,#0xfe000
	strb r0,[pce_zpage,r1]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R0	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R1	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+4
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R2	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+8
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R3	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+12
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R4	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+16
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R5	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+20
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R6	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+24
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
rom_R7	;rom read
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+28
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
;rom_R	;rom read
;----------------------------------------------------------------------------
;	adr r2,memmap_tbl
;	ldr r1,[r2,r1,lsr#11]	;r1=addy & 0xe000
;	ldrb r0,[r1,addy]
;	mov pc,lr
;----------------------------------------------------------------------------
cdram_W	;CD Ram write
;----------------------------------------------------------------------------
	adr r2,memmap_tbl
	ldr r1,[r2,r1,lsr#11]	;r1=addy & 0xe000
	strb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
scdram_W;Super-CD Ram write
;----------------------------------------------------------------------------
	and r0,r0,#0xFF			;ROL & ASL can set bit 8 of r0.
	adr r2,memmap_tbl
	ldr r1,[r2,r1,lsr#11]	;r1=addy & 0xe000
	eor r2,addy,#1			;switch lowest bit
	ldrb r2,[r1,r2]
	tst addy,#1
	orreq r0,r0,r2,lsl#8
	orrne r0,r2,r0,lsl#8
	bic r2,addy,#1
	strh r0,[r1,r2]
	mov pc,lr
;----------------------------------------------------------------------------
sram_R	;sram read
;----------------------------------------------------------------------------
	bic r1,addy,#0xfe000
	mov r0,#AGB_SRAM
	ldrb r0,[r0,r1]
	ldrb r1,bramaccess
	cmp r1,#0
	moveq r0,#0xff

	mov pc,lr
;----------------------------------------------------------------------------
sram_W	;sram write
;----------------------------------------------------------------------------
	ldrb r1,bramaccess
	cmp r1,#0

	bicne r2,addy,#0xfe000
	orrne r1,r2,#AGB_SRAM	;r1=e000000+
	strneb r0,[r1]
	mov pc,lr
;----------------------------------------------------------------------------
memset_ ;r0=dest r1=data r2=word count
;	exit with r0 & r1 unchanged, r2=0
;----------------------------------------------------------------------------
	subs r2,r2,#1
	strpl r1,[r0,r2,lsl#2]
	bhi memset_
	bx lr
;----------------------------------------------------------------------------
memorr_ ;r0=dest r1=data r2=word count
;	exit with r0 & r1 unchanged, r2=0, r3 trashed
;----------------------------------------------------------------------------
	subs r2,r2,#1
	ldrpl r3,[r0,r2,lsl#2]
	orrpl r3,r3,r1
	strpl r3,[r0,r2,lsl#2]
	bhi memorr_
	bx lr
;----------------------------------------------------------------------------
	END
