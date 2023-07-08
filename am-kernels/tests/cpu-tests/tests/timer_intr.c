#include "trap.h"

// void __am_timer_uptime(AM_TIMER_UPTIME_T *);


int main() {
	uint64_t timer_val;

    // __am_timer_uptime(&timer_val);
	ioe_write(AM_TIMER_UPTIME, &timer_val);

	return 0;
}
