proc anding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset tank_North_Mask
	mov cx,[tankHeight]
and1:
	push cx
	mov cx,[tankWidth]
xx:
	lodsb
	and [es:di],al
	inc di
	loop xx
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop and1
	doPop cx, si, di, es, ax
	ret
endp anding

proc oring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[newPos]
	mov si, offset tank_North
	mov cx,[tankHeight]
or1:
	push cx
	mov cx,[tankWidth]
yy:
	lodsb
	or [es:di],al
	inc di
	loop yy
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop or1
	doPop cx, si, di, es, ax
	ret
endp oring

proc takeSqr
	; input: taking the current position into newPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [newPos]
	mov si, offset scrKeep
	mov cx, [tankHeight]
takeLine:
	push cx
	mov cx, [tankWidth]
takeCol:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop takeLine
	doPop cx, di, si, ax, es
	ret
endp takeSqr

proc retSqr
	; input: the last position into oldPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldPos]
	mov si, offset scrKeep
	mov cx, [tankHeight]
retLine:
	push cx
	mov cx, [tankWidth]
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol
	add di, 320
	sub di, [tankWidth]
	pop cx
	loop retLine
	doPop cx, di, si, ax, es
	ret
endp retSqr

proc moveWithSqr
	; input: getting positions y + x
	; output: moving the character and restoring the background and taking the new square the character is going to
	doPush bx, cx
	mov bx, [x] ; The current position of X.
	mov cx, [y] ; The times we will need to loop for rows.
	
createR: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR

returnSqr:
	mov [newPos], bx ; The new position we got into newPos variable
	call retSqr ; Return last sqr to the old position
	call takeSqr ; Taking new sqr from the newPos
	call anding
	call oring
	mov bx, [newPos]
	mov [oldPos], bx
	doPop cx, bx
	ret
endp moveWithSqr