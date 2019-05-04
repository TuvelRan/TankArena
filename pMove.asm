include mPushPop.asm
IDEAL
MODEL small
STACK 100h
DATASEG

; ------------------------------

	include "vars.asm" ; All variables for project
	
; ------------------------------

CODESEG
	include "openFile.asm"
	include "procs.asm"

start:
	mov ax, @data
	mov ds, ax
	
; ------------------------------

	; Entering graphic mode:
	mov ax, 13h
	int 10h

	; Print background:
	call bmp
	
	; initializing:
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0

	; Printing the character && getting the first pos:
	mov [newPos], 320*140+150 ; Middle Screen
	call takeSqr ; Take the first square before printing the character
	mov [oldPos], 320*140+150 ; Middle Screen
	mov [x], 150 ; Using X + Y to control the character
	mov [y], 140 ; Using X + Y to control the character
	; Printing the sprite:
	call anding
	call oring
	
printCharacterEnemy:
	; Printing the character && getting the first position:
	mov [newEnemyPos], 320*15+150 ; Middle Screen
	call eTakeSqr ; Take the first square before printing the character
	mov [oldEnemyPos], 320*15+150 ; Middle Screen
	mov [enemyX], 150 ; Using enemyX + enemyY to control the character
	mov [enemyY], 15 ; Using enemyX + enemyY to control the character
	; Printing the sprite:
	call eAnding
	call eOring
	jmp goRandom

mainLoop:
; The main code loop to run everything	
	
checkKey:
	; Check if there is any key
	mov ah,0bh
	int 21h
	cmp al,0ffh ; If there is any key go to contGetKey
	je contGetKey
	
goRandom:
	; Move the robot randomly to right or left
	call randomMove
	jmp mainLoop
	
contGetKey:
	; Get a key (1 symbol):
	mov ah, 7h
	int 21h
	; Check if right arrow:
	cmp al, 4Dh
	je arrowRight
	; Check if left arrow:
	cmp al, 4Bh
	je arrowLeft
	; Check if space key:
	cmp al, 20h
	je ifSpaceShoot
	; Check if esc key:
	cmp al, 1Bh
	je goEndProgram
	jmp mainLoop
	
goEndProgram:
	; Shortcut to jump to label endProgram
	jmp endProgram

arrowRight:
	; Moving the player tank to right
	cmp [x], 320-60
	jae	mainLoop
	add [x], 40
	call movePlayer
	jmp mainLoop

arrowLeft:
	; Moving the player tank to left
	sub [newPos], 25
	cmp [x], 60
	jbe	mainLoop
	sub [x], 40
	call movePlayer
	jmp mainLoop

ifSpaceShoot:
	call moveShot
	jmp mainLoop
	
controlls:
	; if got 0 or dice move enemy to left
	cmp [eTurnValue], 0
	je enemyLeft
	; if got 1 or dice move enemy to left
	cmp [eTurnValue], 1
	je enemyRight
	; if got 3 or dice enemy Shoot!
	;cmp [eTurnValue], 2
	;je enemyShoot
	jmp mainLoop
	
enemyLeft:
	; Moving the enemy tank to left
	sub [newEnemyPos], 25
	cmp [enemyX], 60
	jbe	mainLoop
	sub [enemyX], 40
	call eMoveWithSqr
	jmp mainLoop

enemyRight:
	; Moving the enemy tank to right
	cmp [enemyX], 320-60
	jae	gotoMain
	add [enemyX], 40
	call eMoveWithSqr
	jmp mainLoop

enemyShoot:
	; Making the enemy tank to shoot
	jmp mainLoop
	
gotoMain:
	; Shortcut to mainLoop
	jmp mainLoop
	
endProgram:
	; Entering text mode
	mov ax, 3h
	int 10h
	; Print goodbye message
	mov dx, offset goodByeMsg
	mov ah, 9h
	int 21h
	
; ------------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start


