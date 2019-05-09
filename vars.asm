		include "eTank.asm" ; Character file handler
		include "eShot.asm" ; Enemy shot file handler
		include "pTank.asm" ; Character file handler
		include "pShot.asm" ; Players Shot file handler
		include "pointer.asm" ; Main screen pointer
		newEnemyPos		dw	? ; Recent enemy position to use later to restore location
		oldEnemyPos		dw	? ; Position to return the scrKeep to
		enemyX			dw	? ; X position for the robot
		enemyY			dw	? ; Y position for the robot
		eTankHeight		dw	42 ; My tank height
		eTankWidth		dw	21 ; My tank width
		scrKeep			db	99*57 dup(?) ; Keeping the screen of the oldPos for The player
		eScrKeep		db	99*57 dup(?) ; Keeping the screen of the oldPos for The robot
		gameBack 		db 'gameBack.bmp',0 ; The bmp file for the gameplay background
		fileName		dw  ?
		filehandle 		dw ? ; file handle for BMP image
		Header 			db 54 	dup (0) ; Header for bmp image
		Palette 		db 256*4 dup (0) ; The color palette for bmp image
		ScrLine 		db 320 dup (0) ; The Width of the screen (pixels for each line)
		ErrorMsg 		db 'Error', 13, 10,'$' ; Error message if bmp couldn't be loaded
		goodByeMsg 		db 'Thank you for playing$' ; When closing the game this message will appear
		divisorTable 	db 10,1,0 ; 
		Clock 			equ es:6Ch ; Clock address in the memory
		EndMessage 		db 13,10,'$'
		eTurnValue 		db ? ; The random robot move, each number move to other side
		eShotX 			dw ? ; robot shot X position
		eShotY 			dw ? ; robot shot Y position
		shotX			dw ? ; player shot X position
		shotY			dw ? ; player shot Y position
		newPos			dw	? ; Recent player position to use later to restore location
		oldPos			dw	? ; Position to return the scrKeep to
		x				dw	? ; X position of player
		y				dw	? ; Y position of player
		tankHeight		dw	42 ; Player's tank height
		tankWidth		dw	21 ; Player's tank width
		newShotPos		dw ? ; Recent shot position to use later to restore location
		oldShotPos		dw ? ; Position to return the scrKeep to
		pShotHeight		dw	8 ; Player's shot height
		pShotWidth		dw	3 ; Player's shot width
		eShotNewPos		dw ? ; Recent enemy shot position to use later to restore location
		eShotOldPos		dw ? ; Position to 
		eShotHeight		dw	8 ; Enemys shot height
		eShotWidth		dw	3 ; Enemys shot width
		shotLength		dw	10 ; Player's shot length
		eShotLength		dw	10 ; Enemy's shot length
		playerHP		db 3 ; Player's hitpoints
		enemyHP			db 3 ; Enemy's hitpoints
		shotScrKeep		db 99*57 dup(?) ; Shot scrKeep
		eShotScrKeep	db 99*57 dup(?) ; enemy shot scrKeep
		playerHPtxt		db 'HP: ','$' ; Variable for printing the player's HP
		enemyHPtxt		db 'HP: ','$' ; Variable for printing the enemy's HP
		shotWait		db 1 ; Counter of when equals to 0 enemy shoot and restore to 3
		pShotOn			db 0 ; Not in use currently
		eShotOn			db 0 ; Not in use currently
		mainScrFile		db 'mainScr.bmp',0 ; MainScreen file name to load
		helpScrFile		db 'helpScr.bmp',0 ; Instructions file name to load
		delayAmount		db ? ; Delay variable
		note			dw 2000h
		moveEnemyTank	dw 250
		pauseFile		db 'pauseScr.bmp',0
		wonFile			db 'winScr.bmp',0
		cDelayAmount	dw 0
		lostFile		db 'lostScr.bmp',0
		hardLvlFile		db 'hardLvl.bmp',0
		moveHardEnemyTank	dw 200
		selectedLvl		db 0
		selectLvlFile	db 'selector.bmp',0
		moveEnemyTankSpeed	dw	?
		getRdy1File		db 'getRdy1.bmp',0
		rdyGo1File		db 'rdyGo1.bmp',0
		getRdy2File		db 'getRdy2.bmp',0
		rdyGo2File		db 'rdyGo2.bmp',0
		tryAgainFile	db 'tryAgain.bmp',0