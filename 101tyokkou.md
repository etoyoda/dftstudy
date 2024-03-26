# 101tyokkou.md - 基底の直交性

## 基底の直交性

フーリエ変換の基底である三角関数は相互に直交である。
だから基底と内積を取るだけで展開係数を得る。

ふたつの波数 $1\le n\le N_i/2$, $1\le m\le N_i/2$ について:

```math
\frac{1}{N_i} \sum_{i=0}^{N_i-1}{\rm cosx}_n[i]{\rm cosx}_m[i]
= \left\{\begin{matrix}
0 & \text{if}\quad n \ne m \hfill \\
1/2 & \text{if}\quad n = m \ne N_i/2 \\
1 & \text{if}\quad n = m = N_i/2
\end{matrix}\right.
```

```math
\frac{1}{N_i} \sum_{i=0}^{N_i-1}{\rm cosx}_n[i]{\rm sinx}_m[i]
= 0
```

```math
\frac{1}{N_i} \sum_{i=0}^{N_i-1}{\rm sinx}_n[i]{\rm sinx}_m[i]
= \left\{\begin{matrix}
0 & \text{if}\quad n \ne m \hfill \\
1/2 & \text{if}\quad n = m \ne N_i/2 \\
0 & \text{if}\quad n = m = N_i/2
\end{matrix}\right.
```

## 準基底

準基底 ${\rm cosx}_0$ を含めるように拡張しても上記の関係は成り立つ。
ただし、いうまでもないかもしれないが、 ${\rm cosx}_0\cdot{\rm cosx}_0 = 1$ である。

## 数値的確認

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

const float PREC = 2.5e-6f;

int
main(void) {

  float maxerr = 0.0f;

  puts("cos*1");
  for (int m=1; m<=HALF_NI; m++) {
    float sum = 0.0f;
    for (int i=0; i<NI; i++) {
      sum += cospx(m*i);
    }
    float err = fabsf(sum/NI);
    if (err > maxerr) maxerr = err;
    if (err < PREC) continue;
    printf("%4d %#9.3g\n", m, err);
  }

  puts("sin*1");
  for (int m=1; m<=HALF_NI; m++) {
    float sum = 0.0f;
    for (int i=0; i<NI; i++) {
      sum += sinpx(m*i);
    }
    float err = fabsf(sum/NI);
    if (err > maxerr) maxerr = err;
    if (err < PREC) continue;
    printf("%4d %#9.3g\n", m, err);
  }

  puts("cos*cos");
  for (int m=1; m<=HALF_NI; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int i=0; i<NI; i++) {
        sum += cospx(m*i) * cospx(n*i);
      }
      float expect = (m == n) ? ((m == HALF_NI) ? 1.0f : 0.5f) : 0.0f;
      float err = fabsf(sum/NI-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, err);
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
      float err = fabsf(sum/NI-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, err);
    }
  }

  puts("sin*sin");
  for (int m=1; m<=HALF_NI; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int i=0; i<NI; i++) {
        sum += sinpx(m*i) * sinpx(n*i);
      }
      float expect = (m == n) ? ((m == HALF_NI) ? 0.0f : 0.5f) : 0.0f;
      float err = fabsf(sum/NI-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, err);
    }
  }

  printf("maxerr=%#9.3g\n", maxerr);

  return 0;
}
```

実行結果
```text:101tyokkou.txt
cos*1
sin*1
cos*cos
 143   26  2.59e-06
 144  113  2.86e-06
cos*sin
 101  144  3.03e-06
 102  119  2.71e-06
 103  144  2.94e-06
 131  131  3.38e-06
sin*sin
 144  102  3.99e-06
maxerr= 3.99e-06
```
