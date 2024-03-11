# 101tyokkou.md - 三角関数

```c:101tyokkou.c
#include <stdio.h>
#include <math.h>

#define NI 288
#define HALF_NI (NI/2)

float
degpx(int i) {
  return 360.0 * i / NI;
}

float
sinpx(int i) {
  return sinf(i*M_PI/HALF_NI);
}

float
cospx(int i) {
  return cosf(i*M_PI/HALF_NI);
}

int
main(void) {
  for (int m=1; m<=HALF_NI; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int i=0; i<NI; i++) {
        sum += cospx(m*i) * cospx(n*i);
      }
      float expect = (m == n) ? 0.5f : 0.0f;
      if (fabsf(sum/NI-expect) > 2.5e-6f) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NI-expect);
      }
    }
  }
}
```

実行結果
```text:101tyokkou.txt
 143   26  +2.6e-06
 144  113  -2.9e-06
 144  144      +0.5
```
