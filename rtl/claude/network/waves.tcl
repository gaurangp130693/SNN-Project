database -open waves -shm
probe -create spike_neural_network_tb -depth all -all -shm -database waves -mem -functions -tasks -packed 16318
run
exit