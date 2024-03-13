# 102henkan.md - 離散フーリエ変換

順変換・逆変換が精度良くできるか試験する。

## 順変換
正規化について真面目に考えていなかったので

```math
a_0 = (1/N_i)\Sigma_{i=0}^{N_i} F[i]
```

```math
~F[i] = F[i] - a_0
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
