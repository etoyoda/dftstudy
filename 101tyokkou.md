# 101tyokkou.md - 三角関数の直交性

フーリエ変換の基底である三角関数は相互に直交である。
だから基底と内積を取るだけで展開係数を得る。

```math
(1/N_i) \sum_{i=0}^{N_i-1}\cos_n[i]\cos_m[i]
= \left\{\begin{matrix}
0 & \text{if}\quad n \ne m \fill \\
1/2 & \text{if}\quad n = m \ne N_i/2 \\
1 & \text{if}\quad n = m = N_i/2
\end{matrix}\right.
```

```math
(1/N_i) \sum_{i=0}^{N_i-1}\cos_n[i]\sin_m[i]
= 0
```

```math
(1/N_i) \sum_{i=0}^{N_i-1}\sin_n[i]\sin_m[i]
= \left\{\begin{matrix}
0 & \text{if}\quad n \ne m \fill \\
1/2 & \text{if}\quad n = m \ne N_i/2 \\
0 & \text{if}\quad n = m = N_i/2
\end{matrix}\right.
```

実数の連続区間ではそうだが離散系でもそうか、
floatで精度よく計算できるかを確認しておく。

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

  puts("cos*cos");
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

  puts("cos*sin");
  for (int m=1; m<=HALF_NI; m++) {
    for (int n=1; n<=HALF_NI; n++) {
      float sum = 0.0f;
      for (int i=0; i<NI; i++) {
        sum += cospx(m*i) * sinpx(n*i);
      }
      float expect = 0.0;
      if (fabsf(sum/NI-expect) > 2.5e-6f) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NI-expect);
      }
    }
  }

  puts("sin*sin");
  for (int m=1; m<=HALF_NI; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int i=0; i<NI; i++) {
        sum += sinpx(m*i) * sinpx(n*i);
      }
      float expect = (m == n) ? 0.5f : 0.0f;
      if (fabsf(sum/NI-expect) > 2.5e-6f) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NI-expect);
      }
    }
  }

  return 0;
}
```

実行結果
```text:101tyokkou.txt
cos*cos
 143   26  +2.6e-06
 144  113  -2.9e-06
 144  144      +0.5
cos*sin
 101  144    +3e-06
 102  119  -2.7e-06
 103  144  -2.9e-06
 131  131  +3.4e-06
sin*sin
 144  102    -4e-06
 144  144      -0.5
```
