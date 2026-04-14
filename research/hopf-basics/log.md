---
kind: study
status: active
---
# Hopf insulatorの基礎理論

## Current State
5本の★★★論文を読解完了。基礎的な理解が確立された。

**確立された理解:**
- Hopf不変量: Abel的Chern-Simons形式 $\chi = -\int_{\text{BZ}} \mathbf{F} \cdot \mathbf{A}\, d\mathbf{k}$。全Chern数ゼロでゲージ不変
- ターゲット空間 $M_{1,1} = S^2$、$\pi_3(S^2) = \mathbb{Z}$ は2バンドモデル固有
- Moore-Ran-Wenモデル: Hopf写像に基づく2バンドハミルトニアン。$\chi = 1$
- Deng-Wang-Shen-Duan: 一般化Hopf写像により任意 $\chi$ のモデル構築
- $U(1)$ 電荷保存のみで保護。時間反転対称性は不要
- バルク-バウンダリー対応: 表面Chern数 $C_s = \chi$ (Alexandradinata et al.)

**重要な発見: 表面状態はQBTではない**
- Alexandradinata et al. (1910.10717) のdomain-wall解析: 表面モードは $\varepsilon_\eta = -\eta(k_1^2 + k_2^2 - |\phi'|)$ → 単一バンドのSchrödinger型放物分散
- 「ギャップレスリング」= 表面バンドとバルク連続体のエネルギー交差。detachable（表面変形で除去可能）
- $\chi = 1$ では表面バンドは1本。「2バンドが2次的に接触するQBT」ではない
- (010)/(100)面ではDirac点（線形分散）— 面方向で異なる

**残る問い:**
- $\chi \geq 2$ の場合: 複数表面バンド間のband touching（QBT含む）の可能性は未開拓
- 表面Chern数 $C_s = \chi$ の物理的帰結と相互作用効果

## Evidence
- reading_0804-4527: Moore-Ran-Wen原論文。Hopf不変量定義、モデル、(001)面ギャップレスリング、(010)面Dirac点
- reading_1307-7206: Deng-Wang-Shen-Duan。任意Hopfインデックス、U(1)保護の数値検証
- reading_2501-05376: Ladovrechis-Sur。バルクTQCP QBT = Berry dipole。次元接続、RG解析
- reading_2404-10049: Berry-dipole半金属。Hopf写像の双線型性がQBTの数学的起源
- reading_1910-10717: Alexandradinata et al. 表面Chern数 $C_s = \chi$。表面分散はSchrödinger型。Berry曲率テレポーテーション
- attempt_1_surface_qbt: 「表面QBT」は不正確。$\chi=1$ では単一バンド放物分散であり、QBT（2バンドの2次接触）ではない。critic検証中
