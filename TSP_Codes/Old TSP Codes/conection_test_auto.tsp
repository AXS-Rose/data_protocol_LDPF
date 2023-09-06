function conection_test_auto(ciclos)
	-- función para probar las funciones de conexión entre keithley y EIS
	
	keithley_control()
	print('keithley comienza tomando el control')
	delay(10)
	
	for i = 1 , ciclos do
		print('el keithley está realizando tareas')
		delay(15)
		print('el keithley dejo de hacer tareas')
		
		-- Se espera a que el EIS mande una señal High indicando el término de su experimento
		EIS_control()
		
		-- El EIS terminó la prueba
		print('EIS termino la prueba')
		print('Keithley està tomando control')
		keithley_control()
		print('keithley tomo control')
		delay(15)
		print('corriente estabilizada')
	end
end