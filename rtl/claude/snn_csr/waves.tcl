database -open waves -shm
probe -create snn_csr_apb_tb -depth all -all -shm -database waves -mem -functions -tasks -packed 16318
run
exit