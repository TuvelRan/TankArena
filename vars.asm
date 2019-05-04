		include "eTank.asm" ; Character file handler
		include "eShot.asm" ; Enemy shot file handler
		include "pTank.asm" ; Character file handler
		include "pShot.asm" ; Players Shot file handler
		include "pointer.asm" ; Main screen pointer
		newEnemyPos		dw	?
		oldEnemyPos		dw	?
		enemyX			dw	?
		enemyY			dw	?
		eTankHeight		dw	42 ; My tank height
		eTankWidth		dw	21 ; My tank width
		scrKeep			db	99*57 dup(?)
		eScrKeep		db	99*57 dup(?)
		filename 		db 'gameBack.bmp',0
		filehandle 		dw ?
		Header 			db 54 	dup (0)
		Palette 		db 256*4 dup (0)
		ScrLine 		db 320 dup (0)
		ErrorMsg 		db 'Error', 13, 10,'$'
		goodByeMsg 		db 'Hope you enjoyed. Goodbye!$'
		divisorTable 	db 10,1,0
		Clock 			equ es:6Ch
		EndMessage 		db 13,10,'$'
		eTurnValue 		db ?
		eShotX 			dw ?
		eShotY 			dw ?
		shotX			dw ?
		shotY			dw ?
		color 			db 0078
		newPos			dw	?
		oldPos			dw	?
		x				dw	?
		y				dw	?
		tankHeight		dw	42 ; My tank height
		tankWidth		dw	21 ; My tank width
		newShotPos		dw ?
		oldShotPos		dw ?
		pShotHeight		dw	8 ; Player's shot height
		pShotWidth		dw	3 ; Player's shot width
		eShotNewPos		dw ?
		eShotOldPos		dw ?
		eShotHeight		dw	8 ; Enemys shot height
		eShotWidth		dw	3 ; Enemys shot width
		shotLength		dw	10
		eShotLength		dw	10
		playerHP		db 3
		enemyHP			db 3
		shotScrKeep		db 99*57 dup(?)
		eShotScrKeep	db 99*57 dup(?)
		youWon			db 'You Won! Congrats!!!$'
		youLost			db 'You Lost! LOSER!!!$'
		playerHPtxt		db 'HP: ','$'
		enemyHPtxt		db 'HP: ','$'
		shotWait		db 3
		pShotOn			db 0
		eShotOn			db 0
		cursorWidth		db 9
		cursorHeight	db 5
		mainScrFile		db 'mainScr.bmp',0
		pointerX		dw ?
		pointerY		dw ?
		helpScrFile		db 'helpScr.bmp',0
		delayAmount		db ?
		timer1			db ?
		timer2			db ?