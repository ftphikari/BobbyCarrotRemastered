package main

Average_Calculator :: struct {
	accumulator, count, average: f64,
}

avg_add :: proc(using avg_calc: ^Average_Calculator, value: f64) {
	accumulator += value
	count += 1
}

avg_calculate :: proc(using avg_calc: ^Average_Calculator) {
	average = accumulator/count
	accumulator = 0
	count = 0
}
