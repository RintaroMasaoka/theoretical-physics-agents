# Attempt 1: Hopf insulatorの表面状態の分散はquadratic (QBT)か？

**Target item**: hopf-basics — 表面状態の分散構造の解明
**Kind**: question

---

## 1. 問題の核心

プロジェクトの前提として「Hopf insulatorの表面状態にQBTが現れる」とされているが、読解済み論文のいずれもこれを明示的に確認していない。本研究ノートでは、Moore-Ran-Wen (MRW) モデルの表面状態について、分散関係を解析的に調べることを試みる。

## 2. 文献から確立されている事実

### 2a. MRW原論文 (0804.4527) の報告

Moore-Ran-Wenの数値計算結果:
- **(001)面**: ギャップレス点の**リング**が存在。Dirac点（単一点）ではない
- **(010)/(100)面**: $\Gamma$点に**単一のDirac点**（線形分散を示唆）
- 全方向で分散的なギャップレス表面状態が存在し、単一の中間ギャップバンドから生じる

### 2b. Alexandradinata-Nelson-Soluyanov (1910.10717) の解析

この論文がHopf insulator表面状態の性質について最も深い議論を行っている。核心的な結果:

1. **表面バンドのChern数**: 表面Chern数 $C_s$ がバルクHopf不変量 $\chi$ と一対一対応する: $C_s = \chi$
2. **表面状態はdetachable**: 全Chern数がゼロであるため、表面バンドはバルクバンドから連続的にエネルギー的分離可能
3. **連続体描像**: 表面状態は一般化Weyl方程式のドメインウォール上の**非カイラル、Schrodinger型モード**として生じる
4. **domain-wall解**: $\phi(r_3) = \phi' r_3$ として解くと、ガウス型に局在したスピン偏極モードが現れ、その分散は

$$\varepsilon_\eta = -\eta(k_1^2 + k_2^2 - |\phi'|)$$

ここで $\eta = -\text{sign}[\phi']$ であり、$\eta = +1$ が電子的（正の有効質量）、$\eta = -1$ が正孔的（負の有効質量）モード。

**この分散は明白にquadratic ($E \propto k^2$) であり、Schrodinger型である。**

5. **Berry曲率のテレポーテーション**: 有限スラブの上面と下面の表面バンドが反対の（しかし非自明な）Chern数を持ち、厳密2次元格子モデルでは実現不可能な非局所的Berry曲率構造を示す

### 2c. Ladovrechis-Sur (2501.05376) のバルクTQCPとの区別

バルクTQCPのQBT（$m = 3$でのバルクギャップ閉塞）は表面QBTとは**異なる現象**:
- バルクTQCPのQBTは3次元運動量空間で全方向にquadratic: $E = \pm[v^2(q_x^2 + q_y^2) + v_z^2 q_z^2]$
- これはBerry dipole構造を持つ
- 表面QBTは2次元表面BZ上での分散

### 2d. Zhuang et al. (2404.10049) のBerry-dipole半金属

Berry-dipole半金属のバルクノードは全方向に2次分散を持つが、これはHopf insulator表面とは別の系。ただし、Hopf写像の双線型性 $d_i = \zeta^\dagger \sigma_i \zeta$ がQBTの数学的起源であるという点は共有される。

## 3. 解析的導出: MRWモデルの(001)表面状態

### 3a. バルクハミルトニアン

MRWモデル:

$$z_\uparrow = \sin k_x + i\sin k_y, \quad z_\downarrow = \sin k_z + i(\cos k_x + \cos k_y + \cos k_z - 3/2)$$

$$H(\mathbf{k}) = \mathbf{v} \cdot \boldsymbol{\sigma}, \quad v^i = \mathbf{z}^\dagger \sigma^i \mathbf{z}$$

展開すると:

$$v_x = 2\text{Re}(z_\uparrow^* z_\downarrow) = 2(\sin k_x \sin k_z + \sin k_y \cdot m(\mathbf{k}))$$

$$v_y = 2\text{Im}(z_\uparrow^* z_\downarrow) = 2(\sin k_y \sin k_z - \sin k_x \cdot m(\mathbf{k}))$$

$$v_z = |z_\uparrow|^2 - |z_\downarrow|^2 = \sin^2 k_x + \sin^2 k_y - \sin^2 k_z - m(\mathbf{k})^2$$

ここで $m(\mathbf{k}) = \cos k_x + \cos k_y + \cos k_z - 3/2$。

### 3b. 連続体極限と一般化Weyl方程式

Alexandradinata et al. (1910.10717) はMRWモデルが一般化Weyl方程式

$$H(\mathbf{k}) = -\mathbf{B} \cdot \boldsymbol{\sigma}, \quad \mathbf{B} = (\mathbf{z}^\dagger \boldsymbol{\sigma} \mathbf{z}), \quad \mathbf{z} = (k_1 + ik_2, k_3 + i\phi)^T$$

の格子正則化であることを示した。$\Gamma$点近傍で $\sin k_j \approx k_j$, $\cos k_j \approx 1 - k_j^2/2$ とおくと:

$$z_\uparrow \approx k_x + ik_y$$

$$z_\downarrow \approx k_z + i\left(3 - \frac{k_x^2 + k_y^2 + k_z^2}{2} - \frac{3}{2}\right) = k_z + i\left(\frac{3}{2} - \frac{k_x^2 + k_y^2 + k_z^2}{2}\right)$$

パラメータ $\phi = 3/2 - (k_x^2 + k_y^2 + k_z^2)/2$ は $\Gamma$点で $\phi_0 = 3/2 > 0$ であり、Hopf insulator相内部にあたる。

### 3c. (001)面のdomain-wall解析

(001)面（$z$方向に境界）を考える。Alexandradinata et al. の連続体解析に従い、$k_3 \to -i\partial_{r_3}$ と置換し、$\phi(r_3)$ がdomain-wall profileを持つとする（Hopf insulator内部から真空へ）。

domain-wallモードの分散は:

$$\varepsilon_\eta(k_1, k_2) = -\eta(k_1^2 + k_2^2 - |\phi'|)$$

これは $(k_1, k_2) = (0, 0)$ で極値を持つ**放物的分散**であり、「ギャップレスリング」は $k_1^2 + k_2^2 = |\phi'|$ の円上に位置する。

### 3d. ギャップレスリングの起源

Alexandradinata et al. が指摘しているように（論文の脚注的な記述 199行目）:

> "returning Thouless pump guarantees that an abrupt surface termination always intersects the hybrid band on a ring in rBZ"

急峻な(001)表面終端では、ハイブリッドBloch-Wannierバンドが必ず表面バンドとバルクバンドの交差するリングを生じさせる。これがMRWが数値的に観測した「ギャップレスリング」の正体である。

**重要な点**: このリングはdetachableである。表面を適切に変形（表面ポテンシャルを調整）すれば、表面バンドをバルクバンドから完全にエネルギー分離できる。分離後の表面バンドの分散は放物的であり、$\Gamma$点で極値を持つ。

### 3e. 分散の次数の確認

domain-wall解から得られる表面状態の分散をまとめる:

$$E_\text{surface}(k_x, k_y) = -\eta(k_x^2 + k_y^2) + \text{const}$$

これは**等方的quadratic分散**である。ただし:

1. これは**通常のSchrodinger型分散**（有効質量を持つ自由粒子的な分散）であり、QBT（2つのバンドが2次的に接触する点）とは**概念的に異なる**
2. 表面バンドは1本であり（$\chi = 1$ の場合）、2つのバンドが接触するQBTではない
3. 「ギャップレスリング」は表面バンドとバルクバンドの交差であり、2つの表面バンド間のband touchingではない

## 4. (010)/(100)面のDirac点について

MRWは(010)/(100)面で $\Gamma$点にDirac点を報告している。これはモデルの異方性（$z$方向がスピノルの $z_\downarrow$ 成分でmass項に結合している）に由来する。(010)面では $k_y \to -i\partial_{r_y}$ とし、残る $(k_x, k_z)$ が表面BZを構成する。

~~この場合も連続体極限でSchrodinger型の分散が得られるのではないか、と考えた。~~

→ しかし、MRWの数値結果はDirac点（線形分散）を明示的に報告しており、(010)/(100)面と(001)面で分散の性質が異なることを示唆する。モデルの $C_4^z$ 回転対称性が(001)面では保たれるが(010)/(100)面では破れることが、この異方性の原因と考えられる。(010)面の詳細な$k \cdot p$解析は本ノートの範囲外とするが、面方向によって分散の次数が異なりうることは重要な観察である。

## 5. 「表面QBT」の主張の根拠は何か？

### 5a. 根拠の追跡

読解済み4論文のいずれもHopf insulator相内部の表面状態を「QBT」とは呼んでいない:

- **Moore-Ran-Wen (0804.4527)**: 「ギャップレスリング」および「Dirac点」
- **Deng-Wang-Shen-Duan (1307.7206)**: 表面状態の存在確認のみ。分散の次数は特徴づけていない
- **Ladovrechis-Sur (2501.05376)**: バルクTQCPのQBTを議論。表面QBTは未検討
- **Zhuang et al. (2404.10049)**: Berry-dipole半金属のバルクQBT。Hopf insulator表面とは別の系
- **Alexandradinata et al. (1910.10717)**: （未読だったが今回LaTeX sourceを解析）表面状態を「Schrodinger型モード」と明確に記述。「QBT」とは呼んでいない

### 5b. 「表面QBT」は不正確な表現である可能性

**結論**: 「Hopf insulator表面にQBTが現れる」という主張の出典は、読解範囲の文献には見つからない。

表面状態の分散がquadraticであること自体は正しい（Alexandradinata et al.のdomain-wall解析から確認）。しかし、「QBT」は通常「2つのバンドが2次的に接触する点」を意味し、Hopf insulator表面で起きていることとは以下の点で異なる:

1. **バンド数**: Hopf insulator ($\chi = 1$) の(001)面には1本の表面バンドしかない。QBTには2バンドが必要
2. **接触の性質**: 「ギャップレスリング」は表面バンドとバルク連続体の交差であり、2つの離散バンド間のband touchingではない
3. **detach後の構造**: 表面バンドをバルクからdetachすると、単一バンドの放物的分散が残り、band touchingは存在しない

**ただし、$\chi = 2$ 以上の場合**: Deng-Wang-Shen-Duan (1307.7206) は $\chi = 2$ で4つの表面状態、$\chi = 3$ で6つの表面状態を報告している。$|\chi| \geq 2$ では複数の表面バンドが存在し、それらの間でband touching（QBTを含む）が原理的に起こりうる。この場合、$C_4^z$ 対称性がQBTを保護する機構として機能する可能性がある（$C_4$ 回転の角運動量量子数の差が2であれば、2次のband touchingが生じうる）。

## 6. バルクTQCPのQBTとの混同の可能性

プロジェクトの前提における「表面QBT」は、以下の2つの現象の混同に由来する可能性がある:

1. **バルクTQCPのQBT**: $m = 3$ でバルクギャップが閉じる臨界点でのQBT。これはLadovrechis-Sur (2501.05376) とZhuang et al. (2404.10049) が詳しく議論。Berry dipole構造を持つ
2. **表面状態のquadratic分散**: Hopf insulator相内部の(001)表面状態がSchrodinger型のquadratic分散を持つこと。Alexandradinata et al. (1910.10717) が解析

前者は3次元運動量空間での真のQBTであり、後者は2次元表面BZ上での単一バンドのquadratic分散である。両者は物理的に全く異なるが、どちらも「Hopf insulator」「quadratic」というキーワードを共有するため混同されやすい。

## 7. 結論

### 7a. 各質問への回答

**Q: 分散は本当にquadratic ($E \propto k^2$) か？**
→ **(001)面**: Yes。Alexandradinata et al.のdomain-wall解析により、表面バンドの分散は $E \propto -(k_x^2 + k_y^2)$（Schrodinger型、放物的）。ただしこれは「QBT」（2バンドの2次接触）ではなく、単一表面バンドの放物的分散。

**Q: それともlinear (Dirac) か？**
→ **(010)/(100)面**: MRWの数値結果はDirac点（線形分散）を報告。面方向によって分散の次数が異なる。

**Q: Moore-Ran-Wenの「ギャップレスリング」とはどういう構造か？**
→ 急峻な(001)表面終端において、放物的分散を持つ表面バンドがバルク連続体とエネルギー的に重なり合う結果として生じるリング状の交差。Alexandradinata et al.はこれを returning Thouless pump の帰結として理解し、表面変形により除去可能（detachable）であることを示した。

**Q: 「表面QBT」の主張の根拠は何か？**
→ 読解範囲の文献には、Hopf insulator相内部の表面状態を「QBT」と呼ぶ記述は見つからなかった。表面分散がquadraticであること自体は正しいが、これは厳密にはQBT（2バンドの2次接触点）ではなく、Schrodinger型の単一バンド分散である。「表面QBT」はバルクTQCPのQBTとの混同に由来する可能性がある。

### 7b. 研究への含意

この発見はプロジェクトの方向性に重要な影響を与える:

1. **「表面QBT」の存在自体が疑問**: $\chi = 1$ の場合、表面状態はQBTではなく放物的分散を持つ単一バンド。「Hopf insulator表面QBT」と「先行研究のQBT」の接続という研究テーマの前提を再検討する必要がある
2. **バルクTQCPのQBTは確立済み**: Ladovrechis-Sur (2501.05376) が既に詳しく議論。ここに新規性を見出すのは困難
3. **$\chi \geq 2$ の表面バンド間のband touchingは未開拓**: 複数表面バンド間の接触構造は文献で系統的に調べられていない可能性がある。ここに研究の余地がありうる
4. **表面Chern数 $C_s = \chi$ の物理**: Alexandradinata et al.の結果は、表面状態の非自明なBerry曲率構造を示す。これは相互作用効果との接続点になりうる

---

## 貢献の自己評価

### 各成分の出自
- (001)表面状態のSchrodinger型quadratic分散: **Alexandradinata et al. (1910.10717)** の既存結果。本ノートではこの論文のLaTeX sourceを直接解析して抽出した（この論文は読解リストに存在するが未読状態であった）
- ギャップレスリングのdetachability: **Alexandradinata et al. (1910.10717)** の既存結果
- 「表面QBT」が実は単一バンドの放物的分散であり、厳密なQBTではないという指摘: **本研究の分析**。各文献を横断的に比較し、「表面QBT」の主張に文献的根拠がないことを確認した
- バルクTQCP QBTと表面分散の概念的区別の明確化: **本研究の分析**

### 非自明性の評価
- 既存文献の結果を正しく組み合わせたものであり、新しい定理や計算を含まない
- ただし、プロジェクトの前提に対する重要な修正を含む。「表面QBT」の不在はresearch directionの再設計を要求する

### 最も近い既存研究との差異
- Alexandradinata et al. (1910.10717) が表面状態を最も詳しく議論しているが、「QBT」という文脈での議論は行っていない。本ノートの貢献は、QBTの文脈でこの結果を再解釈し、プロジェクトの前提との矛盾を指摘した点にある

---

## 範囲と限界

### 本分析が扱ったこと
- MRWモデル（$\chi = 1$）の(001)表面状態の分散の次数
- 既存文献における「表面QBT」の根拠の有無
- バルクTQCPのQBTと表面分散の概念的区別

### 本分析が扱わなかったこと
- **(010)/(100)面のDirac分散の解析的導出**: MRWの数値結果は報告されているが、$k \cdot p$ 解析は未実施
- **$\chi \geq 2$ の場合の複数表面バンド間の接触構造**: 原理的にQBTが生じうるが、未調査
- **Alexandradinata et al. (1910.10717) の完全な読解**: LaTeX sourceからの抽出のみ。reading noteとしての正式な読解は未実施。scope claims について、この論文が「表面QBT」に言及していないという否定的主張は、未読であるためやや弱い証拠。ただし論文の主テーマが「Berry曲率のテレポーテーション」であり、QBTは議論の対象外であることはLaTeX source全体の走査から確認している
- **格子模型の直接数値計算**: 分散関係を数値的にプロットする計算は行っていない。これがあれば結果を独立に検証できる

### 代替的アプローチ
- 直接数値計算（スラブ計算）による表面分散の可視化
- 有効ハミルトニアンの対称性解析による分散の次数の決定（$C_4^z$ 対称性の帰結としてのquadratic分散の保護）
- $\chi \geq 2$ モデルの表面バンド構造の系統的研究

---

## ステータス評価

**Status: active** — 核心的な質問（「分散はquadraticか？」）に対する回答は得られたが、以下が残されている:

1. Alexandradinata et al. (1910.10717) の正式読解が必要
2. $\chi \geq 2$ の場合の表面バンド間QBTの可能性は未調査
3. プロジェクト全体の方向性（「表面QBT」前提の修正）への含意をPIが判断する必要がある

---

## 引用文献

- Moore, Ran, Wen, "Topological surface states in three-dimensional magnetic insulators," arXiv:0804.4527
- Deng, Wang, Shen, Duan, "Hopf Insulators and Their Topologically Protected Surface States," arXiv:1307.7206
- Alexandradinata, Nelson, Soluyanov, "Teleportation of Berry curvature on the surface of a Hopf insulator," arXiv:1910.10717
- Ladovrechis, Sur, "Correlated Hopf insulators," arXiv:2501.05376
- Zhuang, Zhang, Wang, Yan, "Berry-dipole Semimetals," arXiv:2404.10049
