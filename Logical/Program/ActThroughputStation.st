ACTION ActThroughputStation:
	IF ThroughputTimer.Q THEN
		ThroughputTimer.IN := FALSE;
		CurrentThroughput := ThroughputCounter;
		ThroughputCounter := 0;
	ELSIF NOT ThroughputTimer.IN THEN
		ThroughputTimer.IN := TRUE;
	END_IF
		
	
	CASE ThroughputStation.Step OF
		WAIT:
			ThroughputStation.RoutedMoveAbs.Execute := FALSE;
			ThroughputStation.Timer.PT := MAINTENANCE_TIMER_LENGTH;
			ThroughputStation.Timer.IN := TRUE;
			
			IF ThroughputStation.Timer.Q AND ThroughputStation.TrgEnable.EventCount <> 0 THEN
				ThroughputStation.Timer.IN := FALSE;
				ThroughputStation.TrgGetInfo.Execute := TRUE;
				ThroughputStation.Step := DIRECTION_CHECK;
			ELSIF NOT ThroughputStation.Timer.Q AND ThroughputStation.TrgEnable.EventCount <> 0 THEN
				ThroughputStation.TrgGetInfo.Execute := TRUE;
				ThroughputStation.Step := DO_NOTHING;
			END_IF
			
		DO_NOTHING:
			IF ThroughputStation.TrgGetInfo.Done THEN
				ThroughputStation.TrgGetInfo.Execute := FALSE;
				ThroughputCounter := ThroughputCounter + 1;
				ThroughputStation.Step := WAIT;
			END_IF
			
		DIRECTION_CHECK:
			ThroughputStation.Shuttle := ThroughputStation.TrgGetInfo.TrgPointInfo.Axis;
			ThroughputStation.TrgGetInfo.Execute := FALSE;
			ThroughputCounter := ThroughputCounter + 1;
			ThroughputStation.Step := SEND_SHUTTLE;
			
		SEND_SHUTTLE:
			ThroughputStation.RoutedMoveAbs.Axis := ADR(ThroughputStation.Shuttle);
			ThroughputStation.RoutedMoveAbs.Sector := ADR(MaintPoint);
			ThroughputStation.RoutedMoveAbs.Position := 0.33;
			ThroughputStation.RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			ThroughputStation.RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			ThroughputStation.RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			ThroughputStation.RoutedMoveAbs.Jerk := 0.0;
			ThroughputStation.RoutedMoveAbs.BufferMode := mcABORTING;
			ThroughputStation.RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
				IF ThroughputStation.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_MAINT;
				END_IF
			END_FOR
			
			ThroughputStation.Step := WAIT;
		
	END_CASE
	
	ThroughputStation.RoutedMoveAbs();
	ThroughputStation.TrgEnable();
	ThroughputStation.TrgGetInfo();
	ThroughputStation.Timer();
END_ACTION