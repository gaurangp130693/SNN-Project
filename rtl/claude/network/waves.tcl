database -open waves -shm
probe -create tb_digit_recognition_network -depth all -all -shm -database waves -mem -functions -tasks -packed 16318
run
exit