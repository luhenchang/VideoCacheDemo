export function throttle(func: Function, interval: number) {
  let lastTime = 0;
  return () => {
    const nowTime = Date.now();
    const remainTime = interval - (nowTime - lastTime);
    if (remainTime <= 0) {
      lastTime = nowTime;
      func();
    }
  };
}