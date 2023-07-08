#include <am.h>
#include <npc.h>

void __am_timer_init() {
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  // uptime->us = 0;
  uint64_t cnt = 0;
  cnt += inl(RTC_ADDR+4);
  cnt <<= 32;
  cnt += inl(RTC_ADDR);
  uptime->us = cnt/100;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}

void __am_timer_wcmp(AM_TIMER_CMP_W_T *cmpv) {
  uint64_t time_val = cmpv->us*100;
  outl(RTC_ADDR+8, time_val);
  outl(RTC_ADDR+0xc, (time_val>>32));
}

void __am_timer_rcmp(AM_TIMER_CMP_W_T *cmpv) {
  uint64_t cnt = 0;
  cnt += inl(RTC_ADDR+0xc);
  cnt <<= 32;
  cnt += inl(RTC_ADDR+8);
  cmpv->us = cnt/100;
}
