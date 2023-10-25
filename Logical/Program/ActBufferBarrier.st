ACTION ActBufferBarrier:
	CASE BufferBarrier.Step OF
		WAIT:
			
			
		PROCESS:
			
	END_CASE
	
	BufferBarrier.Command();
	BufferBarrier.ElasticMoveVel();
	BufferBarrier.GetShuttle();
	BufferBarrier.ReadInfo();
	BufferBarrier.RoutedMoveVel();
	BufferBarrier.Timer();
END_ACTION