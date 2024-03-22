# 110nanboku.md - 南北方向(非周期データ)のフーリエ変換

三角関数は周期関数なので、1周期ぶんのデータを変換するのは考えやすい。
1周期のデータがない場合には境界条件を考えなければいけなくなる。

球面上の経緯度格子の場合、南北方向については1周期が得られない。
今回考えている東西288x南北145格子の場合、南北方向に 0 番目（北極）と144番目（南極）の値が異なりうることが周期データとの違いになる。

最終目的は2次元フーリエ変換だがまずは南北1次元の変換について考える。

## 基底

南北格子数 $N_j+1=145$ として、
格子位置 $i$ ($0\le i\le N_j$) について次を基底とする。
```math
{\rm cosy}_n[j] = \cos\frac{2n\pi j}{N_j}
\quad\text{for}\quad n=1..\frac{N_j}{2};
```
```math
{\rm siny}_n[j] = \sin\frac{2n\pi j}{N_j}
\quad\text{for}\quad n=1..\frac{N_j}{2}-1
```

## 準基底

実は後の考察で準基底は不要になるケースがでてくるのだが、
とりあえず一般の非周期境界条件について考えておく。

両端の値が異なるため、準基底は1つ増やす必要がある。

```math
{\rm cosy}_0[j] = \cos 0 = 1
```
```math
{\rm cosy}_{\tfrac{1}{2}}[j] = \cos\frac{\pi j}{N_j}
```

準基底
$\text{cosy}_0$
はどの格子位置 j でも同じ値 1 なので、その役割はいうまでもなく周期境界条件のときと同じ、DC成分の除去である。

もうひとつの準基底
$\text{cosy}_{1/2}$
は北極で 1, 南極で -1 となるので、両端で値が異なる状況を処理するためのものである。

## 展開式

これらの基底・準基底を用いて、関数 $F[i]$ を次のように変換することを目指す。

```math
F[i] = a_0
+ a_{\tfrac{1}{2}} {\rm cosy}_{\tfrac{1}{2}}[j]
+ \sum_{n=1}^{N_j/2} (a_n{\rm cosy}_n[j] + b_n{\rm siny}_n[j])
```

# テストプログラム

東西のときとほとんど変わらないが、直交性を確認する。

```c:110nanboku.c
#include <stdio.h>
#include <math.h>

#define NJ 144
#define HALF_NJ (NJ/2)

float
degpx(int i) {
  return 360.0 * i / NJ;
}

float
sinpy(int i) {
  return sinf(i*M_PI/HALF_NJ);
}

float
cospy(int i) {
  return cosf(i*M_PI/HALF_NJ);
}

float
cospy2(int i) {
  return cosf(i*M_PI/NJ);
}

const float PREC = 2.5e-6f;

int
main(void) {

  puts("cos*cos");
  for (int m=1; m<=HALF_NJ; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int j=0; j<NJ; j++) {
        sum += cospy(m*j) * cospy(n*j);
      }
      float expect = (m == n) ? 0.5f : 0.0f;
      if (fabsf(sum/NJ-expect) > PREC) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NJ-expect);
      }
    }
  }

  puts("cos*sin");
  for (int m=1; m<=HALF_NJ; m++) {
    for (int n=1; n<=HALF_NJ; n++) {
      float sum = 0.0f;
      for (int j=0; j<NJ; j++) {
        sum += cospy(m*j) * sinpy(n*j);
      }
      float expect = 0.0;
      if (fabsf(sum/NJ-expect) > PREC) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NJ-expect);
      }
    }
  }

  puts("sin*sin");
  for (int m=1; m<=HALF_NJ; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int j=0; j<NJ; j++) {
        sum += sinpy(m*j) * sinpy(n*j);
      }
      float expect = (m == n) ? 0.5f : 0.0f;
      if (fabsf(sum/NJ-expect) > PREC) {
        printf("%4d %4d %+9.2g\n", m, n, sum/NJ-expect);
      }
    }
  }

  return 0;
}
```

実行結果
```text:110nanboku.txt
cos*cos
  72   72      +0.5
cos*sin
sin*sin
  72   72      -0.5
```
