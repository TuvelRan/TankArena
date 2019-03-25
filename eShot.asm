	eShotMask 	db 0FFh,0FFh,0FFh,0FFh
				db 0FFh,0000,0000,0FFh
				db 0FFh,0000,0000,0FFh
				db 0FFh,0000,0000,0FFh
				db 0FFh,0000,0000,0FFh
				db 0FFh,0000,0000,0FFh
				db 0FFh,0FFh,0FFh,0FFh
				
	eShot	db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			db 0000,0000,0000,0000
			
	newShotPos	dw ?
	oldShotPos	dw ?
	eShotHeight	dw	7 ; Enemys shot height
	eShotWidth	dw	4 ; Enemys shot width