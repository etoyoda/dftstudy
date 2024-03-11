# 100sincos.md - 三角関数

```c:100sincos.c
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
  for (int i=0; i<=NI; i++) {
    printf("%04d %7.1f %+6.3f %+6.3f %+6.3f %+6.3f\n",
    i, degpx(i), sinpx(i), cospx(i), sinpx(2*i), cospx(2*i));
  }
}
```


