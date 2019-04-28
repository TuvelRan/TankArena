proc pShotAnding
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[pShotNewPos]
	mov si, offset eShotMask
	mov cx,[pShotHeight]
	
and3:
	push cx
	mov cx,[pShotWidth]
	
xx3:
	lodsb
	and [es:di],al
	inc di
	loop xx3
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop and3
	doPop cx, si, di, es, ax
	ret
endp pShotAnding

proc eShotOring
	doPush ax, es, di, si, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[pShotNewPos]
	mov si, offset eShot
	mov cx,[pShotHeight]
	
or3:
	push cx
	mov cx,[pShotWidth]
	
yy3:
	lodsb
	or [es:di],al
	inc di
	loop yy3
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop or3
	doPop cx, si, di, es, ax
	ret
endp eShotOring

proc eShotTakeSqr
	; input: taking the current position into pShotNewPos variable
	; output: taking the sqr size into scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es, ax
	mov di, [pShotNewPos]
	mov si, offset scrKeep
	mov cx, [pShotHeight]
	
takeLine3:
	push cx
	mov cx, [pShotWidth]
	
takeCol3:
	mov al, [es:di]
	mov [si], al
	inc si
	inc di
	loop takeCol3
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop takeLine3
	doPop cx, di, si, ax, es
	ret
endp eShotTakeSqr

proc eShotRetSqr
	; input: the last position into oldShotPos variable
	; output: restoring the last sqr in scrKeep variable
	doPush es, ax, si, di, cx
	mov ax, 0A000h
	mov es,ax
	mov di,[oldShotPos]
	mov si, offset scrKeep
	mov cx, [pShotHeight]
	
retLine:
	push cx
	mov cx, [pShotWidth]
	
retCol:
	mov al, [si]
	mov [es:di], al
	inc si
	inc di
	loop retCol
	add di, 320
	sub di, [pShotWidth]
	pop cx
	loop retLine
	doPop cx, di, si, ax, es
	ret
endp eShotRetSqr

proc eShotWithSqr
	; input: getting positions eShotY + eShotX
	; output: moving the character and restoring the background and taking the new square the character is going to
	doPush bx, cx
	mov bx, [enemyX] ; The current position of eShotX.
	mov cx, [enemyY] ; The times we will need to loop for rows.
	
createR3: ; Creating the row. Adding 320 to go to the next line
	add bx, 320
	loop createR3

returnSqr3:
	mov [pShotNewPos], bx ; The new position we got into pShotNewPos variable
	call eShotRetSqr ; Return last sqr to the old position
	call eShotTakeSqr ; Taking new sqr from the pShotNewPos
	call pShotAnding
	call eShotOring
	mov bx, [pShotNewPos]
	mov [oldShotPos], bx
	doPop cx, bx
	ret
endp eShotWithSqr