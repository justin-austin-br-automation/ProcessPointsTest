ACTION ActMaintenanceStation:
	
	CASE MaintenanceStation.Step OF
		WAIT:
			MaintenanceStation.RoutedMoveAbs.Execute := FALSE;
			
			IF MaintenanceStation.TrgEnable.EventCount > 0 THEN
				MaintenanceStation.TrgGetInfo.Execute := TRUE;
				MaintenanceStation.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF MaintenanceStation.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				MaintenanceStation.Shuttle := MaintenanceStation.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT DO
					IF MaintenanceStation.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_MAINT;
					END_IF
				END_FOR
				
				MaintenanceStation.TrgGetInfo.Execute := FALSE;
				MaintenanceStation.Step := PROCESS;
			ELSE
				MaintenanceStation.TrgGetInfo.Execute := FALSE;
				MaintenanceStation.Step := WAIT;
			END_IF
			
		PROCESS:
			MaintenanceStation.Timer.PT := T#5s;
			MaintenanceStation.Timer.IN := TRUE;
			
			IF MaintenanceStation.Timer.Q THEN
				MaintenanceStation.Timer.IN := FALSE;
				MaintenanceStation.Step := SEND_SHUTTLE;
			END_IF
			
		SEND_SHUTTLE:
			MaintenanceStation.RoutedMoveAbs.Axis := ADR(ThroughputStation.Shuttle);
			MaintenanceStation.RoutedMoveAbs.Sector := ADR(Barrier);
			MaintenanceStation.RoutedMoveAbs.Position := 0.2;
			MaintenanceStation.RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			MaintenanceStation.RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			MaintenanceStation.RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			MaintenanceStation.RoutedMoveAbs.Jerk := 0.0;
			MaintenanceStation.RoutedMoveAbs.BufferMode := mcABORTING;
			MaintenanceStation.RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT DO
				IF MaintenanceStation.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_BUFFER;
				END_IF
			END_FOR
			
			MaintenanceStation.Step := WAIT;
		
	END_CASE
	
	MaintenanceStation.RoutedMoveAbs();
	MaintenanceStation.TrgEnable();
	MaintenanceStation.TrgGetInfo();
	MaintenanceStation.Timer();
END_ACTION