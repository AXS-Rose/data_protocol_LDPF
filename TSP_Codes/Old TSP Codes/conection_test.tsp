function conection_test(ciclos)
	-- funci�n para probar las funciones de conexi�n entre keithley y EIS
	
	-- Declaramos los pineas ocmo input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT

	-- Como el EIS termino el experimento ahora el out = 1 para que la acci�n la ejecute el keithley
	digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL)
	digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SE�AL PARA CONECTAR LA CELDA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
	digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY )Enviamos un 0 porque no queremos desactivar el Normally Open a�n
	
	print('keithley comienza tomando el control')
	delay(10)
	
	for i = 1 , ciclos do
		-- capacity_discharge(2.5, 1.25, discap, 9)
		--resting(2.5, rest_time, 4)
		print('el keithley est� haciendo sus weas')
		delay(15)
		print('el keithley dej� de hacer sus weas')
		
		digio.line[3].state = 1 -- (CELDA CONECTADA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
		digio.line[4].state = 0 -- Enviamos un 0 porque no queremos desactivar el Normally Open a�n
		delay(2)
		digio.line[1].state = 0 -- (KEITHLEY DEJA DE OPERAR)Enviamos un 0 para darle la acci�n al EIS y no al keithley
		print("Se�al enviada, EIS tomo control")
		-- Se espera a que el EIS mande una se�al High indicando el t�rmino de su experimento
		-- En este momento el EIS est� haciendo una prueba
		while digio.line[2].state != digio.STATE_HIGH do
			print(digio.line[2].state)
			delay(1)
		end
		-- El EIS termin� la prueba
		print('EIS termino la prueba')
		print('Keithley est� tomando control')
		digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL)Se quita la acci�n al EIS, momento en el que se puede 
		delay(2)
		digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SE�AL PARA CONECTAR LA CELDA AL EIS)Enviamos un 0 para dejar de activar la fuente y el Normally Open del Rele
		digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY)Enviamos un 1 para desactivar fuente y que funcione el Normally Closed del Rele 
		print('keithley tomo control')
		delay(15)
		print('corriente estabilizada')
	end
end