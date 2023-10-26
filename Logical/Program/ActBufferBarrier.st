ACTION ActBufferBarrier:
	
	CASE BufferBarrier.Step OF
		WAIT:
			BufferBarrier.Command.Command := mcACPTRAK_BARRIER_CLOSE;
			BufferBarrier.Command.Execute := TRUE;
			
			IF BufferBarrier.TrgEnable.EventCount <> 0 THEN
				BufferBarrier.Command.Execute := FALSE;
				BufferBarrier.TrgGetInfo.Execute := TRUE;
				BufferBarrier.Step := DIRECTION_CHECK;
			END_IF
			
		DIRECTION_CHECK:
			IF BufferBarrier.TrgGetInfo.TrgPointInfo.Event = mcACPTRAK_TP_PASSED_POSITIVE THEN
				BufferBarrier.Shuttle := BufferBarrier.TrgGetInfo.TrgPointInfo.Axis;
				BufferBarrier.TrgGetInfo.Execute := FALSE;
				BufferBarrier.Step := PROCESS;
			ELSE
				BufferBarrier.TrgGetInfo.Execute := FALSE;
				BufferBarrier.Step := WAIT;
			END_IF
			
		PROCESS:
			IF WorkZone.TrgEnable.EventCount < 3 THEN
				BufferBarrier.Step := SEND_SHUTTLE;
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
			
			BufferBarrier.Command.Command := mcACPTRAK_BARRIER_ADD_TICKETS;
			BufferBarrier.Command.AdvancedParameters.TicketCount := 1;
			BufferBarrier.Command.Execute := TRUE;
			
			IF BufferBarrier.Command.Done THEN
				BufferBarrier.Command.Execute := FALSE;
				BufferBarrier.RoutedMoveAbs.Execute := FALSE;
				BufferBarrier.Step := WAIT;
			END_IF
		
	END_CASE
	
	BufferBarrier.Command();
	BufferBarrier.RoutedMoveAbs();
	BufferBarrier.TrgEnable();
	BufferBarrier.TrgGetInfo();
END_ACTION