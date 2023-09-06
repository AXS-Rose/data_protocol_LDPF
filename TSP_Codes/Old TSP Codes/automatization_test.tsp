function function_test(ciclos)
	-- función para probar las funciones de conexión entre keithley y EIS
	
	reset()
	ExtBuffer = buffer.make(300000)
	
	FileNumber=file.open("/usb1/TestData.csv",file.MODE_WRITE) --si testdata tiene data?
	file.write(FileNumber, "Current, Voltage, Capacity, Cumulative_capacity, Seconds, Test_State, SOC\r\n")
	
	SOC = 100
	iteration2 = 1
	
	-- Declaramos los pineas ocmo input y output
	-- Se usa el pin 1 como output y el 2 como input
	digio.line[1].mode = digio.MODE_DIGITAL_OUT
	digio.line[2].mode = digio.MODE_DIGITAL_IN
	digio.line[3].mode = digio.MODE_DIGITAL_OUT
	digio.line[4].mode = digio.MODE_DIGITAL_OUT

	-- Como el EIS termino el experimento ahora el out = 1 para que la acción la ejecute el keithley
	digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL)
	digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SEÑAL PARA CONECTAR LA CELDA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
	digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY )Enviamos un 0 porque no queremos desactivar el Normally Open aún
	
	print('keithley comienza tomando el control')
	delay(10)
	print('keithley esta realizando las pruebas iniciales')
	charge(4.2, 1.25, 0.05, 3)
	-- (voltaje cargado,corriente de carga,corriente de corte CV, número de identificación data)
	resting(2.5, 300, 4) -- esta es una descarga a 0A
	-- (voltaje limite descarga,segundos de descanso,número de identificación data)
	print('keithley termino las pruebas iniciales')
	
	for i = 1 , ciclos do
		print('el keithley esta haciendo sus weas dentro del ciclo')
		capacity_discharge(2.5, 1.25, 200, 9)
		resting(2.5, 180, 4)
		print('el keithley dejo de hacer sus weas dentro del ciclo')
		
		digio.line[3].state = 1 -- (CELDA CONECTADA AL EIS) Enviamos un 1 para activar fuente y Normally Open del Rele
		digio.line[4].state = 0 -- Enviamos un 0 porque no queremos desactivar el Normally Open aún
		delay(2)
		digio.line[1].state = 0 -- (KEITHLEY DEJA DE OPERAR)Enviamos un 0 para darle la acción al EIS y no al keithley
		print("Señal enviada, EIS tomo control")
		-- Se espera a que el EIS mande una señal High indicando el término de su experimento
		-- En este momento el EIS está haciendo una prueba
		while digio.line[2].state != digio.STATE_HIGH do
			print(digio.line[2].state)
			delay(1)
		end
		-- El EIS terminó la prueba
		print('EIS termino la prueba')
		print('Keithley esta tomando control')
		digio.line[1].state = 1 -- (KEITHLEY TOMA CONTROL)Se quita la acción al EIS, momento en el que se puede 
		delay(2)
		digio.line[3].state = 0 -- (SE DEJA DE ENVIAR LA SEÑAL PARA CONECTAR LA CELDA AL EIS)Enviamos un 0 para dejar de activar la fuente y el Normally Open del Rele
		digio.line[4].state = 1 -- (SE CONECTA LA CELDA AL KEITHLEY)Enviamos un 1 para desactivar fuente y que funcione el Normally Closed del Rele 
		print('keithley tomo control')
	end
end