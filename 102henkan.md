# 102henkan.md - 離散フーリエ変換

順変換・逆変換が精度良くできるか試験する。

## 前処理(DC成分除去)
元のデータ $F[i]$ から平均値を差し引いた $F^*[i]$ を処理対象とする。

数学的には DC 成分は全基底との内積がゼロなので効果がないはずだが、無駄に桁が大きい数値を加減算すると桁落ちのおそれがある。

```math
a_0 = \frac{1}{N_i} \sum_{i=0}^{N_i} F[i]
```

```math
F^*[i] = F[i] - a_0
```

## 順変換
数学的に美しいのは基底を
$\sqrt{2}\cos_m[i], \sqrt{2}\sin_m[i]$
とする正規直交基底を選ぶのであろうが、
とりあえず逆変換を sin, cos ですっきり書けるように、
順変換で2をかけてしまう実装にしている。

二進数計算機なのに、順変換・逆変換ともに $\sqrt{2}$ を乗じるのが気味悪いので。
(あとで考えを変えるかもしれない)

```math
a_m = \frac{2}{N_i} \sum_{i=0}^{N_i} \cos_m[i]F^*[i]
\quad\text{for}\quad m=1..N_i-1
```

波数 $N_i$ についてだけ基底の内積が 1/2 じゃなくて 1 なので別扱い

```math
a_{N_i} = \frac{1}{N_i} \sum_{i=0}^{N_i} \cos_{N_i}[i]F^*[i]
```

```math
b_n = \frac{2}{N_i} \sum_{i=0}^{N_i} \sin_m[i]F^*[i]
\quad\text{for}\quad n=1..N_i-1
```

## 逆変換

```math
F[i] = a_0 + \sum_{m=1}^{N_i} (a_m\cos_m[i] + b_m\sin_m[i])
```



```c:102henkan.c
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
  for (int i=0; i<NI; i++) {
    float img[NI];
    float eddy[NI];
    float xform[NI];
    float reimg[NI];

    // 入力イメージ作成 (この時点では自由度 NI)
    for (int ci=0; ci<NI; ci++) { img[ci] = (ci==i); }

    // 平均を減算 (これにより自由度 NI-1)
    float imgavg = 0.0f;
    for (int ci=0; ci<NI; ci++) { imgavg += img[ci]; }
    imgavg /= (float)NI;
    for (int ci=0; ci<NI; ci++) { eddy[ci] = img[ci]-imgavg; }

    // フーリエ変換
    // xform[0]: 平均
    xform[0] = imgavg;
    // xform[1..HALF_NI]: cos image
    for (int m=1; m<=HALF_NI; m++) {
      float sum = 0.0f;
      for (int ci=0; ci<NI; ci++) {
        sum += cospx(m*ci)*eddy[ci];
      }
      xform[m] = sum*2.0/NI;
    }
    // xform[HALF_NI+1..NI-1]: sin image
    for (int m=1; m<HALF_NI; m++) {
      float sum = 0.0f;
      for (int ci=0; ci<NI; ci++) {
        sum += sinpx(m*ci)*eddy[ci];
      }
      xform[m+HALF_NI] = sum*2.0/NI;
    }
    xform[HALF_NI] *= 0.5;

    // イメージ復元
    for (int ci=0; ci<NI; ci++) {
      reimg[ci] = xform[0];
      for (int m=1; m<=HALF_NI; m++) {
        reimg[ci] += xform[m] * cospx(m*ci);
      }
      for (int m=1; m<HALF_NI; m++) {
        reimg[ci] += xform[m+HALF_NI] * sinpx(m*ci);
      }
    }

    float sumerr = 0.0f;
    for (int ci=0; ci<NI; ci++) {
      float err = reimg[ci]-img[ci];
      sumerr += err*err;
    }
    sumerr /= NI;
    sumerr = sqrt(sumerr);

    if (sumerr > 1.0e-6f) {
      printf("i=%04d err=%8.6f\n", i, sumerr);
      printf("%4s %8s %8s %8s\n", "i", "img", "xform", "reimg");
      for (int ci=0; ci<NI; ci++) {
        printf("%04d %+8.5f %+8.5f %+8.5f\n", ci,
          img[ci], xform[ci], reimg[ci]);
      }
    }

  }
  return 0;
}
```

実行結果
```text:102henkan.txt
```
