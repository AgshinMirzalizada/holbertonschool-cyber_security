# Room: Risk Qiymətləndirməsi (CVSS)

**Path:** Reporting & Capstone
**Module:** Professional Reporting
**Çətinlik:** Beginner
**Təxmini vaxt:** 1 saat

## Room haqqında

"Hansı tapıntı daha təhlükəlidir?" sualına standart cavab — CVSS skorudur. Bu room-da CVSS skorlama sisteminin komponentlərini (Attack Vector, Complexity, Impact və s.), vektor sətrinin oxunmasını/yazılmasını, Critical/High/Medium/Low kateqoriyalarını və kontekst ilə şərhi öyrənəcəksiniz. Hesabat room-undakı "severity qoyuldu" — burada "severity hesablanır və müdafiə olunur".

## Öyrənmə nəticələri

- CVSS-in əsas metrik qruplarını və hər metrikin mənasını izah etmək
- Vektor sətrini (məs. `AV:N/AC:L/PR:N/UI:N`) oxumaq və qurmaq
- Severity kateqoriyalarını və onların hesabat diliğini bilmək
- Skorun kontekstlə şərhi (CVSS-in məhdudiyyətləri) bacarmaq

## Task 1 — CVSS Nədir və Niyə Standartdır

**CVSS (Common Vulnerability Scoring System)** — zəifliklərin şiddətini vahid ölçüdə (0-10) ifadə edən, FIRST (Forum of Incident Response and Security Teams) tərəfindən idarə olunan açıq standart.

Niyə standart lazımdır? Əks halda hər vendor/konsultant öz "çox təhlükəlidir!" dilində danışardı. CVSS hamını bir dilə gətirir: skaner (Nessus), istehsalçı (Microsoft advisory), tədqiqatçı (CVE məqaləsi), pentester (hesabat) — hamısı eyni ölçüdən istifadə edir. Bu, müqayisə və avtomatiklaşdırma (bug tracker-ə avtomatik priority) imkanı verir.

CVSS üç qrup metrikdən ibarətdir:

1. **Base Score** — zəifliyin özünün daxili xüsusiyyətləri (dəyişməz). *Əsas bizim mövzumuz.*
2. **Threat Score (Temporal)** — vaxtla dəyişən: exploit mövcuddur? patch var? (EPSS/KEV dünyası bura bağlanır.)
3. **Environmental Score** — təşkilata özəl: bizim mühitdə bu komponent nə qədər vacib?

Bu room-da əsasən **Base Score** öyrənilir (hesabatlarda standart "CVSS" adı buna gedir); Threat/Environmental — kontekst şərhi hissəsində.

Base Score-un üç alt qrup metriksi:

- **Exploitability** (istismar oluna bilmə): AV, AC, PR, UI (+ Scope).
- **Scope** (təsir sərhədi): zəiflik təsirə düşən komponentdən kənara çıxırmı?
- **Impact** (təsir): C (Confidentiality), I (Integrity), A (Availability).

Skor bu metrikaların kombinasiyasından düsturla hesablanır — əzbərləmək lazım deyil (kalkulyatorlar var), **metrikaların mənasını bilmək** əsasdır.

### Sual 1

CVSS nəyə görə "vahid dil" sayılır?

### Sual 2.

CVSS-in üç metrik qrupu hansılardır?

### Sual 3.

Base Score-un üç alt qrupu nədir?

## Task 2 — Exploitability Metrikləri: Zəifliyə Çatmaq

Beş metrik — "attacker bunu nə qədər asan istismar edə bilər":

**Attack Vector (AV) — haradan:**

| Dəyər | Məna | Nümunə |
|---|---|---|
| **Network (N)** | İnternet/şəbəkədən — istənilən yerdən | Açıq web servisdə SQLi |
| **Adjacent (A)** | Yalnız lokal şəbəkə/qonşu (Wi-Fi, VLAN) | BLE/LLMNR zəifliyi |
| **Local (L)** | Hədəf sistemdə lokal hesab/ sessiya lazımdır | SUID privesc (shell lazımdır) |
| **Physical (P)** | Fiziki giriş lazımdır | USB/evil maid hücumları |

AV:N ən yüksək çəki daşıyır — internetdən istismar oluna bilən zəiflik ən geniş hədəf səthidir. Privesc zəifliklərinin çoxu AV:L-dır (artıq sistemdə olmaq lazımdır) — bu səbəbdən privesc tapıntıları texniki olaraq "gözəl" olsa da, skorları orta salxaqda qalır (amma zəncirdə kritik!). Bu incəlik hesabatda həmişə qeyd olunmalıdır: **skor zəifliyin tək başına dəyəridir, zəncirdəki rolu yox.**

**Attack Complexity (AC):** istismar nə qədər çətin/şanslı olmalıdır?

- **Low (L):** etibarlı, dərhal istismar — sadə payload.
- **High (H):** xüsusi şərait lazımdır (race condition, xüsusi konfiqurasiya) — uğur şərtsi.

**Privileges Required (PR):** istismar üçün hesab lazımdırmı?

- **None (N):** anonim.
- **Low (L):** adi istifadəçi.
- **High (H):** admin/özəl hüquq.

**User Interaction (UI):** qurban bir şey etməlidirmi? **None (N)** — avtomatik; **Required (R)** — klik/link açma lazımdır (phishing-ə bağlı zəifliklər).

**Scope (S):** zəiflik təsirə düşən komponentin sərhədini aşır mı? **Unchanged (U)** — təsir eyni komponentdə; **Changed (C)** — başqa komponentə keçir (məs. VM-dən host-a, sandbox-dan kənara). Scope:Changed skorları qaldırır — "sərhəd aşımı" təhlükəsizlik arxitekturasına zərbədir.

Bu beşinin birləşməsi — vektor sətri:

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H  →  9.8 (Critical)
```

Bu sətri oxumaq peşəkar bacarıqdır: "şəbəkədən, asan, hesabsız, qurban iştiraksız, sərhəd daxilində, tam təsir" — EternalBlue tipli "remote, dərhal" zəifliklərin imzasıdır.

### Sual 1

AV:L (privesc zəifliklərinin çoxu) nə deməkdir və hesabatda nəyə diqqət?

### Sual 2.

PR və UI metrikaları hansı suallara cavab verir?

### Sual 3.

Scope:Changed nə üçün skor qaldırır?

## Task 3 — Impact Metrikləri və Skorun Hesablanması

**CIA triadası** — zəifliyin nəyinə təsir etdiyi:

| Metrik | Sual | High nümunə | Low nümunə |
|---|---|---|---|
| **Confidentiality (C)** | Məlumat sızır? | Bütün DB oxunur | Yalnız var/yox bilinir |
| **Integrity (I)** | Məlumat dəyişilir? | İstənilən record dəyişilir | Kiçik/istifadəçisiz dəyişiklik |
| **Availability (A)** | Xidmət dayanır? | Tam shutdown/DoS | Yavaşlama |

Hər biri: **None (N) / Low (L) / High (H)**. Kombinasiyalar tanış formalarda görünür:

- `C:H/I:H/A:H` — "hamısı" — RCE mənzərəsi (oğur, dəyiş, söndür).
- `C:H/I:N/A:N` — yalnız oxuma — SQLi data oğurluğu.
- `C:N/I:N/A:H` — yalnç dayandırma — DoS zəifliyi.
- `C:L/I:N/A:N` — aşağı sızma — verbose error, info leak.

**Skorun düsturu** — metrikaların çəkili birləşməsidir (əzbər lazım deyil; FIRST-in rəsmi kalkulyatoru var: first.org/cvss). Mühüm nüanslar:

- Exploitability asanlıqları (AV:N/PR:N) Impact-ilə **vurulur** — hər ikisi yüksək olanda skor 9+ qaçır.
- Impact metrikaları üçün **ən yüksək** olan aparıcıdır (C:H + I:L ≈ C:H səviyyəsinə yaxın).
- Scope:Changed hesabı kəskin dəyişir (iki komponentin impact-i birləşir).

**Severity kateqoriyaları** (hesabat dili):

| Skor | Kateqoriya | Hesabatdakı rəng/qərar |
|---|---|---|
| 9.0-10.0 | **Critical** | dərhal — tam kompromit |
| 7.0-8.9 | **High** | qısa müddət |
| 4.0-6.9 | **Medium** | planlı |
| 0.1-3.9 | **Low** | növbəti dövr |
| 0.0 | **None** | — |

Praktik məşq (özünüz üçün): tanış zəifliklərin vektorlarını qurun — SQLi (AV:N/AC:L/PR:N/UI:N, C:H/I:H/A:N → ~9.1), XSS (C:L/I:L/A:N + UI:R → ~6.1 Medium), SUID privesc (AV:L/PR:L, C:H/I:H/A:H → ~7.8 High). Nəticələri NVD-dəki rəsmi vektorlarla müqayisə edin — bu, metrikaları "hiss etməyin" ən yaxşı yolu.

### Sual 1

C:H/I:H/A:H kombinasiyası hansı zəiflik ailəsinin imzasıdır?

### Sual 2.

UI:R olan zəifliyin praktiki mənası nədir?

### Sual 3.

Niyə SQLi skoru XSS-dən yüksək olur — metrikalarla izah edin?

## Task 4 — Skorun Şərhi: CVSS-in Məhdudiyyətləri

CVSS rəqəmdir; risk isə kontekstdir. Professional hesabat skoru şərh edir (VA room-un dərslərinin CVSS-dəxi tətbiqi):

**1. Skor ≠ ehtimal.** CVSS "olsaydı nə qədər pis" deyir; "nə qədər tez-tez olacaq" demir. Buna cavab: **EPSS** (Exploit Prediction Scoring System — istismar olunma ehtimalı 0-1) və **KEV** (CISA Known Exploited Vulnerabilities — aktiv istismar siyahısı). Müasir triada: CVSS (şiddət) + EPSS (ehtimal) + KEV (aktuallıq).

**2. Mühit fərqi (Environmental):** eyni CVE — internetə açıq frontend-də Critical; izolyəlı daxili test sistemində Medium. CVSS-in environmental qrupu bunu rəsmən hesablayır (amma adətən hesabatlarda kontekst şərhi kimi tətbiq olunur).

**3. Zəncir dəyəri:** hər zəiflik tək başına qiymətləndirilir; amma real hücumda zəncirlər toplanır (medium + medium = critical ssenari). Hesabatda zəncir ayrıca tapıntı kimi təqdim olunur (pentest hesabatının skaner hesabatından fərqi!).

**4. Məlumat dəyəri:** CVSS "məlumat nə qədər dəyərlidir" bilmir — health data ilə demo data eyni skor ala bilər. GDPR/tənzimləmə konteksti şərhdə əlavə olunmalıdır.

**5. "9.8 syndrome":** gözəl, amma aldadıcı — skoru 9.8 olan minlərlə CVE var; hamısı eyni təcili deyil. Prioritizasiya üçün skor kifayət etmir (buna görə triada).

Pentester üçün praktik nəticə: hesabatda hər tapıntıda **CVSS vektoru + skor + kontekst şərhi** göstərilir. Məsələn:

> Severity: High (CVSS 8.1 — AV:N/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H)
> Kontekst: hədəf sistem internetə açıqdır və müştəri məlumatı saxlayır — risk yuxarı; AC:H olmasa Critical səviyyəsi qiymətləndirilərdi.

Bu şəkil client-ə həm standart ölçü (müqayisə üçün), həm peşəkar mühakimə (qərar üçün) verir — CVSS-in düzgün istifadə formuludur.

### Sual 1

CVSS, EPSS və KEV-in rol bölgüsü nədir?

### Sual 2.

"Zəncir dəyəri" hesabatda necə əks olunur?

### Sual 3.

"CVSS vektoru + skor + kontekst şərhi" kombinasiyası nə verir?

## Task 5 — Praktika və Module Yekunu

Praktik tapşırıqlar (cvss kalkulyatoru ilə):

1. **Vektor oxu:** NVD-dən 3 tanış CVE-nin vektorunu tapın (məs. EternalBlue CVE-2017-0144, Log4Shell CVE-2021-44228) və hər metrikin niyə elə olduğunu izah edin.
2. **Vektor qur:** öz tapıntılarınızdan (əvvəlki room-un praktik hesabatından) hər tapıntıya vektor qurun — kalkulyatorla skor yoxlayın.
3. **Mübahisə həll et:** "XSS tapıntım Medium-dur, amma admin panelində stored-dir və admin sessiyasını oğurlaya bilər" — skoru dəyişmədən kontekst şərhiylə bunu hesabatda necə təqdim edərsiniz?
4. **Prioritizasiya masası:** 10 tapıntılıq siyahı təsəvvür edin — yalnız skora görə sıralayın, sonra "skor + exploit mövcudluğu + açıqlıq" üçlüyünə görə — fərqi müşahidə edin (bu, real remediation planının məntiqidir).

Module 8.1 (Professional Reporting) tamamlandı:

- **Hesabat room-u:** struktur, tapıntı anatomiyası, auditoriya dilləri.
- **Bu room:** severity-nin elmi — CVSS metrikaları, vektorlar, şərh.

İki room-un birgə mesajı: **professional tapıntı = sübut + ölçü + şərh.** Sübut (PoC), ölçü (CVSS), şərh (kontekst) — üçlüyü olmadan tapıntı ya qorxu hekayəsidir, ya da boş rəqəmdir.

Növbəti — və bütün curriculum-un sonuncu — room: **Capstone: Uçdan-uca Simulyasiya.** Orada bu path-dəki hər şey (recon → enum → istismar → privesc → post-exploitation → hesabat) vahid ssenaridə birləşəcək. Bu room-da öyrənilən CVSS — capstone hesabatının severity dilidir.

### Sual 1

"EternalBlue vektorunu izah et" tapşırığı nəyi gücləndirir?

### Sual 2.

Prioritizasiya masası təcrübəsi nəyi göstərir?

### Sual 3.

"Sübut + ölçü + şərh" üçlüyü nə deməkdir?

## Yekun Yoxlama (Summary Quiz)

1. CVSS-in üç metrik qrupu və Base Score-un alt qrupları.
2. AV, AC, PR, UI, S metrikalarının dəyərlərini izah edin.
3. CIA impact metrikaları və C:H/I:H/A:H-nin mənası.
4. CVSS + EPSS + KEV triadası nə üçün lazımdır?
5. Kontekst şərhi olmayan CVSS skoru nə üçün çatışmır?

---

## CƏVAB AÇARI (yalnız content creator üçün — istifadəçiyə göstərilməməlidir)

**Task 1 sualları:**
1. Skanerlər, istehsalçılar, tədqiqatçılar, pentesterlər — hamısı eyni 0-10 ölçüsündən istifadə edir; müqayisə və avtomatik prioritetləndirmə mümkün olur.
2. Base (daxili, dəyişməz), Threat/Temporal (vaxtla: exploit/patch), Environmental (təşkilata özəl).
3. Exploitability (AV/AC/PR/UI), Scope, Impact (C/I/A).

**Task 2 sualları:**
1. İstismar üçün hədəf sistemdə lokal mövqe lazımdır (shell/sessiya); skor aşağı düşür — amma zəncirdə rolunu şərhdə qeyd etmək lazımdır (skor tək zəifliyin dəyəridir, hücum hekayəsinin yox).
2. PR — istismar üçün hesab lazımdırmı (None/Low/High); UI — qurban iştirakı lazımdırmı (None/Required — phishing/link açma).
3. Çünki zəiflik təsirə düşən komponentin sərhədini aşır (başqa komponentə keçir) — arxitektura sərhədlərinin (sandbox/VM) qırılması ekstra təhlükədir, hesab iki komponenti birləşdirir.

**Task 3 sualları:**
1. RCE — oğurma (C), dəyişmə (I) və dayandırma (A) hamısı mümkündür.
2. Qurban bir şey etməlidir (link açma, klik) — istismar sosial mühəndislik tələb edir; avtomatik yayılan deyil.
3. SQLi: C:H/I:H (data oxu/dəyiş) + UI:N (avtomatik); XSS: C:L/I:L (kiçik təsir) + UI:R (qurban lazımdır) — impact və UI fərqi skoru aşağı salır.

**Task 4 sualları:**
1. CVSS — şiddət (nə qədər pis); EPSS — istismar ehtimalı (nə qədər provable); KEV — aktiv istismar reallığı (indi istismar olunurmu).
2. Zəncir ayrıca tapıntı kimi: hər halqanın öz severity-si + birgə nəticənin (məs. RCE) qiymətləndirilməsi — pentest hesabatının skaner hesabatından fərqi.
3. Standart müqayisə ölçüsü (rəqəm) + peşəkar mühakimə (kontekst) — client həm siyahıda yerləşdirir, həm real qərar verir.

**Task 5 sualları:**
1. Metrikaların praktiki mənasını — vektor sətri artıq "şifrə" deyil, zəifliyin portreti kimi oxunur.
2. Yalnız skora görə sıralama ilə real prioritetin (skor+exploit+açıqlıq) fərqini — rəqəm tək başına remediation planı deyil.
3. Tapıntının üç vacib tərəfini: nə olduğunu sübut edən PoC, nə qədər olduğunu ölçən CVSS, biznes üçün nə demək olduğunu deyən şərh.

**Yekun Quiz:**
1. Base/Threat/Environmental; Base alt qrupları: Exploitability (AV/AC/PR/UI), Scope, Impact (C/I/A).
2. AV — Network/Adjacent/Local/Physical (haradan); AC — Low/High (çətinlik); PR — None/Low/High (hesab); UI — None/Required (qurban); S — Unchanged/Changed (sərhəd).
3. Confidentiality/Integrity/Availability — None/Low/High; C:H/I:H/A:H — tam kompromit (oğur+dəyiş+dayandır) — RCE imzası.
4. Çünki CVSS ehtimal/aktuallıq bilmir — triada şiddət+ehtimal+aktuallıq verir: real prioritetləndirmə üçün.
5. Çünki eyni skor fərqli mühitlərdə fərqli riskdir (açıqlıq, data dəyəri, zəncir) — rəqəm kontekstsiz qərar vermir, şərh ona qərar qabiliyyəti qazandırır.
