package spl

Timer :: _Timer

has_precise_timer :: #force_inline proc() -> bool { return _has_precise_timer() }
create_timer :: #force_inline proc(timer: ^Timer, rate: uint) -> bool { return _create_timer(timer, rate) }
destroy_timer :: #force_inline proc(timer: ^Timer) { _destroy_timer(timer) }
wait_timer :: #force_inline proc(timer: ^Timer) { _wait_timer(timer) }

make_scheduler_precise :: #force_inline proc() { _make_scheduler_precise() }
restore_scheduler :: #force_inline proc() { _restore_scheduler() }
