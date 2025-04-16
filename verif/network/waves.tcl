database -open waves -shm
probe -create snn_tb_top -depth all -all -shm -database waves -mem -functions -tasks -packed 16318
run
exit