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
巽も言っているように関数形には任意性があり、
三角関数でなくてもよいのだが、微分や積分してあまり突飛な形状になっても困るとなると巽も選んだ三角関数が候補になる。

## 展開式

これらの基底・準基底を用いて、関数 $F[i]$ を次のように変換することを目指す。

```math
F[i] = a_0
+ a_{\tfrac{1}{2}} {\rm cosy}_{\tfrac{1}{2}}[j]
+ \sum_{n=1}^{N_j/2} (a_n{\rm cosy}_n[j] + b_n{\rm siny}_n[j])
```

# 直交性の確認

東西のときとほとんど変わらないが、直交性を確認する。

ひとつ非周期境界条件で気をつけなければならないのは、
準基底 $\text{cosy}_{1/2}$ は sin 系列の基底とは直交しないことである。

```c:110nanboku.c
#include <stdio.h>
#include <math.h>

#define NJ 144
#define HALF_NJ (NJ/2)

float
sinpy(int j) {
  return sinf(j*M_PI/HALF_NJ);
}

float
cospy(int j) {
  return cosf(j*M_PI/HALF_NJ);
}

float
cospy2(int j) {
  return cosf(j*M_PI/NJ);
}

const float PREC = 2.5e-6f;

int
main(void) {

  float maxerr = 0.0f;

  puts("cos*cos1/2");
  for (int m=1; m<=HALF_NJ; m++) {
    float sum=0.0f;
    for (int j=0; j<=NJ; j++) {
      sum+=cospy(m*j)*cospy2(j);
    }
    float expect=0.0f;
    float err=fabsf(sum/NJ-expect);
    if (err>maxerr) maxerr=err;
    if (err<PREC) continue;
    printf("%4d  1/2 %#9.3g\n", m, sum/NJ-expect);
  }

  puts("cos*1");
  for (int m=1; m<=HALF_NJ; m++) {
    float sum=0.0f;
    for (int j=0; j<NJ; j++) {
      sum+=cospy(m*j);
    }
    float expect=0.0f;
    float err=fabsf(sum/NJ-expect);
    if (err>maxerr) maxerr=err;
    if (err<PREC) continue;
    printf("%4d %4d %#9.3g\n", m, 0, sum/NJ-expect);
  }

  puts("sin*1");
  for (int m=1; m<=HALF_NJ; m++) {
    float sum=0.0f;
    for (int j=0; j<NJ; j++) {
      sum+=sinpy(m*j);
    }
    float expect=0.0f;
    float err=fabsf(sum/NJ-expect);
    if (err>maxerr) maxerr=err;
    if (err<PREC) continue;
    printf("%4d %4d %#9.3g\n", m, 0, sum/NJ-expect);
  }

  puts("cos*cos");
  for (int m=1; m<=HALF_NJ; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int j=0; j<NJ; j++) {
        sum += cospy(m*j) * cospy(n*j);
      }
      float expect = (m == n) ? ((m == HALF_NJ) ? 1.0f : 0.5f) : 0.0f;
      float err = fabsf(sum/NJ-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, sum/NJ-expect);
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
      float err = fabsf(sum/NJ-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, sum/NJ-expect);
    }
  }

  puts("sin*sin");
  for (int m=1; m<=HALF_NJ; m++) {
    for (int n=1; n<=m; n++) {
      float sum = 0.0f;
      for (int j=0; j<NJ; j++) {
        sum += sinpy(m*j) * sinpy(n*j);
      }
      float expect = (m == n) ? ((m==HALF_NJ) ? 0.0f : 0.5f) : 0.0f;
      float err = fabsf(sum/NJ-expect);
      if (err > maxerr) maxerr = err;
      if (err < PREC) continue;
      printf("%4d %4d %#9.3g\n", m, n, sum/NJ-expect);
    }
  }
  printf("maxerr=%#9.3g\n", maxerr);

  puts("sin*cos1/2");
  for (int m=1; m<=HALF_NJ; m++) {
    float sum=0.0f;
    for (int j=0; j<=NJ; j++) {
      sum+=sinpy(m*j)*cospy2(j);
    }
    float expect=0.0f;
    float err=fabsf(sum/NJ-expect);
    if (err>maxerr) maxerr=err;
    if (err<PREC) continue;
    printf("%4d  1/2 %#9.3g\n", m, sum/NJ-expect);
  }
  printf("maxerr=%#9.3g\n", maxerr);

  return 0;
}
```

実行結果
```text:110nanboku.txt
cos*cos1/2
cos*1
sin*1
cos*cos
cos*sin
sin*sin
maxerr= 2.01e-06
sin*cos1/2
   1  1/2     0.424
   2  1/2     0.170
   3  1/2     0.109
   4  1/2    0.0806
   5  1/2    0.0641
   6  1/2    0.0531
   7  1/2    0.0454
   8  1/2    0.0395
   9  1/2    0.0350
  10  1/2    0.0314
  11  1/2    0.0284
  12  1/2    0.0260
  13  1/2    0.0239
  14  1/2    0.0221
  15  1/2    0.0205
  16  1/2    0.0191
  17  1/2    0.0179
  18  1/2    0.0168
  19  1/2    0.0158
  20  1/2    0.0149
  21  1/2    0.0141
  22  1/2    0.0133
  23  1/2    0.0127
  24  1/2    0.0120
  25  1/2    0.0114
  26  1/2    0.0109
  27  1/2    0.0104
  28  1/2   0.00992
  29  1/2   0.00947
  30  1/2   0.00905
  31  1/2   0.00866
  32  1/2   0.00828
  33  1/2   0.00792
  34  1/2   0.00758
  35  1/2   0.00726
  36  1/2   0.00695
  37  1/2   0.00665
  38  1/2   0.00636
  39  1/2   0.00609
  40  1/2   0.00583
  41  1/2   0.00557
  42  1/2   0.00533
  43  1/2   0.00509
  44  1/2   0.00486
  45  1/2   0.00464
  46  1/2   0.00442
  47  1/2   0.00421
  48  1/2   0.00401
  49  1/2   0.00381
  50  1/2   0.00362
  51  1/2   0.00343
  52  1/2   0.00324
  53  1/2   0.00306
  54  1/2   0.00288
  55  1/2   0.00270
  56  1/2   0.00253
  57  1/2   0.00236
  58  1/2   0.00219
  59  1/2   0.00202
  60  1/2   0.00186
  61  1/2   0.00170
  62  1/2   0.00154
  63  1/2   0.00138
  64  1/2   0.00122
  65  1/2   0.00107
  66  1/2  0.000915
  67  1/2  0.000761
  68  1/2  0.000607
  69  1/2  0.000455
  70  1/2  0.000303
  71  1/2  0.000152
maxerr=    0.424
```
