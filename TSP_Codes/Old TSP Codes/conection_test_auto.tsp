function conection_test_auto(ciclos)
	-- funci�n para probar las funciones de conexi�n entre keithley y EIS
	
	keithley_control()
	print('keithley comienza tomando el control')
	delay(10)
	
	for i = 1 , ciclos do
		print('el keithley est� realizando tareas')
		delay(15)
		print('el keithley dejo de hacer tareas')
		
		-- Se espera a que el EIS mande una se�al High indicando el t�rmino de su experimento
		EIS_control()
		
		-- El EIS termin� la prueba
		print('EIS termino la prueba')
		print('Keithley est� tomando control')
		keithley_control()
		print('keithley tomo control')
		delay(15)
		print('corriente estabilizada')
	end
end