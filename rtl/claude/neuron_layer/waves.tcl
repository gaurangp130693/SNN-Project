database -open waves -shm
probe -create neuron_layer_tb -depth all -all -shm -database waves -mem -functions -tasks -packed 16318
run
exit