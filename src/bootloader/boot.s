; Do sheet idk
; AAAAAAAAA ICANT BREATHE
;
;
;

;	Drive 0
;	__________________________________
;	| Bootloader (we are here) (S. 1)|
;	|________________________________|
;	| Kernel (Sector 2)		 |
;	|________________________________|
;	Drive 1 - Fat16, OS
;


[ORG 0x7c00]
[BITS 16]

_start:
	mov	ax, 0x0
	mov	ds, ax

	; dark magic

	;mov	dl, 0x80
	mov	[BOOT_DRIVE], dl

	; Resetting disk

	mov	ah, 0x0
	int	0x13
	
	mov	si, DRIVE_DBG
	call	printf
	xor	dh, dh
	mov	si, dx
	call	itos
	mov	si, di
	call	printf
	mov	si, NEWLINE
	call	printf

	mov	si, STARTUP_MSG
	call	printf

	mov	si, READING_MSG
	call	printf

	;	if we load it infront of 0x7c00,(0x7e00)
	;	when this sector ends it should go there.

	mov	si, 0x0
	mov	es, si
	mov	ebx, 0x1000

	mov	al, 0x2		; sector count
	mov	ch, 0x0		; cylinder
	mov	cl, 0x2		; sector
	mov	dh, 0x0		; head
	mov	dl, [BOOT_DRIVE]; drive

	mov	ah, 0x2		; func mode
	int	0x13		; interrupting bios
	jc	disk_error	; disk error

	mov	si, PROTECT_MSG
	call	printf

	mov	si, LAUNCH_MSG
	call	printf
	; enabling protected mode

	cli
	lgdt	[gdt_descriptor]

	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax


	; stack

	mov	esp, 0x900000

	jmp	0x08:protected_mode_exec


; GDT

gdt_start:
	
gdt_null:
	dq	0x0
gdt_code:
	dw	0xFFFF
	dw	0x0
	db	0x0
	db	10011010b
	db	11001111b
	db	0x0
gdt_data:
	dw	0xFFFF
	dw	0x0
	db	0x0
	db	10010010b
	db	11001111b
	db	0x0
gdt_end:
gdt_descriptor:
	dw	gdt_end - gdt_start - 1
	dd	gdt_start

; si - integer, di - string, dh - offset
itos:
	mov	bx, 10
	mov	byte [di], 0
	dec	di
.loop:
	xor	dx, dx
	mov	ax, si
	div	bx

	;	DX:AX - dividend
	;	AX - quotient
	;	DX - remainder

	add	dl, '0'
	mov	[di], dl
	dec	di

	mov	si, ax
	test	si, si
	jnz	.loop

	inc	di
	ret

printf:
	mov	al, [si]
	inc	si
	cmp	al, 0	
	je	.done

	mov	ah, 0x0E
	int	0x10

	jmp	printf
.done:
	ret

disk_error:
	mov	si, ERR_MSG
	call	printf
	
	; ah - error code

	mov	dl, ah
	xor	dh, dh
	mov	si, dx
	call	itos
	mov	si, di
	call	printf
	mov	si, NEWLINE
	call	printf

	ret


STARTUP_MSG	db "[Boot]: Hello, World", 0x0A, 0x0D, 0x0
LAUNCH_MSG	db "[Boot]: Attempting launching...", 0x0A, 0x0D, 0x0
PROTECT_MSG	db "[Boot]: Entering protected mode.", 0xA, 0xD, 0x0
READING_MSG	db "[Boot]: Reading kernel initializer...", 0x0A, 0x0D, 0x0
ERR_MSG		db "[ERROR]: [Boot]: Couldn't read disk: ",  0x0
;UNEXP_MSG	db "You're not supposed to be here.", 0xA, 0xD, 0x0
DRIVE_DBG	db "[Boot]: Drive: ", 0x0
NEWLINE		db 0xA, 0xD, 0x0

BOOT_DRIVE	db 0x0

[BITS 32]

protected_mode_exec:
	mov	ax, 0x10
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	fs, ax
	mov	gs, ax

	jmp	0x1000


times		510 - ($ - $$) db 0
dw		0xAA55
