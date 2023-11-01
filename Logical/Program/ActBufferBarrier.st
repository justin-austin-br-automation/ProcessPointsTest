ACTION ActBufferBarrier:
	
	CASE BufferBarrier.Step OF
		WAIT:
			BufferBarrier.RoutedMoveAbs.Execute := FALSE;
			
			ShuttlesToStation1 := 0;
			FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
				IF gShuttleList[i].State = RTE_TO_STATION_1 THEN
					ShuttlesToStation1 := ShuttlesToStation1 + 1;
				END_IF
			END_FOR
			
			IF BufferBarrier.TrgEnable.EventCount <> 0 AND ShuttlesToStation1 < MAX_SHUTTLES_TO_STATION_1 THEN
				BufferBarrier.TrgGetInfo.Execute := TRUE;
				BufferBarrier.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF BufferBarrier.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				BufferBarrier.Shuttle := BufferBarrier.TrgGetInfo.TrgPointInfo.Axis;
				
				FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
					IF BufferBarrier.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
						gShuttleList[i].State := AT_BUFFER;
					END_IF
				END_FOR
				
				BufferBarrier.TrgGetInfo.Execute := FALSE;
				BufferBarrier.Step := SEND_SHUTTLE;
			ELSE
				BufferBarrier.TrgGetInfo.Execute := FALSE;
				BufferBarrier.Step := WAIT;
			END_IF
			
		SEND_SHUTTLE:
			BufferBarrier.RoutedMoveAbs.Axis := ADR(BufferBarrier.Shuttle);
			BufferBarrier.RoutedMoveAbs.Sector := ADR(ProcessPoints);
			BufferBarrier.RoutedMoveAbs.Position := 0.0;
			BufferBarrier.RoutedMoveAbs.Velocity := gTrakAsm.Parameter.Velocity;
			BufferBarrier.RoutedMoveAbs.Acceleration := gTrakAsm.Parameter.Acceleration;
			BufferBarrier.RoutedMoveAbs.Deceleration := gTrakAsm.Parameter.Deceleration;
			BufferBarrier.RoutedMoveAbs.Jerk := 0.0;
			BufferBarrier.RoutedMoveAbs.BufferMode := mcABORTING;
			BufferBarrier.RoutedMoveAbs.Execute := TRUE;
			
			FOR i := 1 TO gMAX_SHUTTLE_CNT BY 1 DO
				IF BufferBarrier.Shuttle.controlif = gShuttleList[i].Axis.controlif THEN
					gShuttleList[i].State := RTE_TO_STATION_1;
				END_IF
			END_FOR
			
			BufferBarrier.Step := WAIT;
		
	END_CASE
	
	BufferBarrier.Command();
	BufferBarrier.RoutedMoveAbs();
	BufferBarrier.TrgEnable();
	BufferBarrier.TrgGetInfo();
END_ACTION