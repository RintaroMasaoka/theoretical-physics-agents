---
kind: narrative
status: active
last_meeting: ""
---
# Hopf Insulator と QBT の接続 — 研究状態

## Current State
基礎文献5本の読解と分析を完了。**プロジェクトの前提に重要な修正が必要**。

### 前提の修正: 「表面QBT」は存在しない ($\chi = 1$)
当初の前提「Hopf insulator表面にQBTが現れる」は不正確。Alexandradinata et al. (1910.10717) のdomain-wall解析により:
- $\chi = 1$ の(001)表面バンドは**1本**、Schrödinger型放物分散 $\varepsilon = -\eta(k_1^2 + k_2^2 - |\phi'|)$
- これは「2バンドが2次的に接触するQBT」ではなく、単一バンドの放物分散
- ギャップレスリングは表面バンドとバルク連続体の交差でありdetachable

### Hopf insulatorに関連する真のQBT
1. **バルクTQCP QBT**: 相転移点 ($m=3$) でバルクギャップが二次的に閉じる。Berry dipole構造。Ladovrechis-Sur (2501.05376) が2D QBT半金属・Luttinger半金属との次元接続を確立
2. **Berry-dipole半金属のQBT**: Hopf写像の双線型性 $d_i = \zeta^\dagger \sigma_i \zeta$ に由来するQBT。Zhuang et al. (2404.10049)

### 研究方向の候補（ユーザーとの相談が必要）
A. バルクTQCP QBT × $c=-2$ CFT（部分的にカバー済み、CFT接続が新規性）
B. $\chi \geq 2$ の表面バンド間band touching（未開拓）
C. 表面Chern数 $C_s = \chi$ の物理（Berry曲率テレポーテーション）
D. 高次元一般化

## 子ノード構成
- **hopf-basics/** [active]: 基礎理論確立。5論文読解完了
- **prior-work-qbt/** [open]: arXiv:2511.16496 の精読。未着手
- **surface-qbt/** [active]: 名称は要改訂。表面状態はQBTではなくSchrödinger型。$\chi \geq 2$ の可能性を含む
- **direction-search/** [active]: 前提修正により方向性再設計が必要

## Background
- **Hopf insulator**: ten-fold way外の3D TI。Hopf写像に基づく。2バンド・$U(1)$保護
- **先行研究 arXiv:2511.16496**: QBTにおける$c=-2$ CFT
- **arXiv:2501.05376**: バルクTQCP QBTとLuttinger半金属の接続。$\epsilon$展開RG。$d_c = 2$
- **arXiv:1910.10717**: 表面Chern数 $C_s = \chi$。Berry曲率テレポーテーション。表面状態はSchrödinger型
- **arXiv:2404.10049**: Berry-dipole半金属。Hopf写像→QBTの数学的機構

## Evidence
- scout結果 (2026-04-14): 38論文をreading_listに登録
- reading_0804-4527: Moore-Ran-Wen原論文
- reading_1307-7206: Deng-Wang-Shen-Duan。任意$\chi$モデル
- reading_2501-05376: Ladovrechis-Sur。バルクTQCP QBT、次元接続
- reading_2404-10049: Berry-dipole半金属
- reading_1910-10717: Alexandradinata et al. 表面Chern数、Schrödinger型表面分散
- attempt_1_surface_qbt: 「表面QBT」は不正確という分析。critic検証中
