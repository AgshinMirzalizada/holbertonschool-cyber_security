# Room: File Upload Zəiflikləri

**Path:** Web Application Hacking
**Module:** OWASP Top 10
**Çətinlik:** Easy
**Təxmini vaxt:** 1 saat

## Room haqqında

Fayl yükləmə — tətbiqlərin ən gündəlik funksiyalarından biridir: avatar, sənəd, şəkil. Amma bu funksiya yanlış qurulanda, istifadəçiyə server-də öz faylını yerləşdirmək imkanı verir — və bu fayl web server tərəfindən icra oluna bilirsə, RCE (Remote Code Execution) yaranır. Bu room-da fayl növü yoxlamalarının bypass üsullarını, webshell konseptini və düzgün fayl validasiyası prinsiplərini öyrənəcəksiniz.

## Öyrənmə nəticələri

- Fayl yükləmə zəifliyinin RCE-yə necə çevrildiyini izah etmək
- Client-side və zəif server-side yoxlamaların bypass üsullarını bilmək
- Webshell-in nə olduğunu və necə işlədiyini konseptual başa düşmək
- Düzgün fayl validasiyasının çoxtəbəqəli prinsiplərini sadalamaq

## Task 1 — Problem: Server-ə Yazmaq = İcra Etmək

Təsəvvür edin: profil səhifəsində avatar yükləmə var. Yüklənən fayllar `www.site.com/uploads/` qovluğuna düşür. İndi təsəvvür edin ki, bu qovluqda PHP faylı icra olunur: `uploads/shell.php` açılanda web server onu **kod kimi işlədir**, yox şəkil kimi göstərir.

Zəifliyin anatomiyası — zəncir:

1. İstifadəçi fayl yükləyir → server qəbul edir.
2. Server yalnız "gözlənilən" yoxlama aparır (məs. yalnız adına baxır) və ya heç aparmır.
3. Fayl web root-a (icra olunan qovluğa) yazılır.
4. Faylın adı/uzantısı/məzmunu icra üçün kifayətdir (`shell.php`).
5. Attacker `site.com/uploads/shell.php`-ə GET/POST edir → server kodu icra edir → RCE.

Bir dəfə RCE yarananda attacker server üzərində əmrlər icra edir: sistem məlumatı oxuyur, geri bağlantı qurur (reverse shell), içəridə hərəkət edir. Bir "avatar yükləmə" funksiyası — bütün server.

Hansı texnologiyalarda icra mümkündür:

| Texnologiya | İcra uzantıları | Qeyd |
|---|---|---|
| PHP | .php, .php3, .php5, .phtml | Ən klassik |
| JSP/Java | .jsp, .jspx | Tomcat |
| ASP/ASPX | .asp, .aspx, .cer | IIS |
| CGI | .cgi, .pl | Köhnə sistemlər |

Amma diqqət: icra yalnız uzantı ilə yox, **server konfiqurasiyası** ilə bağlıdır — `uploads/` qovluğunda PHP icrası söndürülmüşüsə, `.php` faylı mətn kimi qayıdır (yaxşı müdafiə). Yəni zəiflik = (icra edilə bilən yer) + (yoxlamanın keçilməsi).

Fayl yükləmənin RCE-dən başqa təhlükələri də var: XSS (SVG faylında skript — `image/svg+xml` icra olunur), path traversal (`../../public_html/shell.php` adı ilə başqa qovluğa yazma), DoS (nəhəng fayllarla doldurma), zərərli fayl yayımı (istifadəçilərə virus "host" olmaq). Bu room əsasən RCE yoluna konsentrasiya olunur.

### Sual 1

Fayl yükləmə zəifliyinin RCE-yə çevrilməsi üçün hansı iki şərt lazımdır?

### Sual 2.

`uploads/` qovluğunda PHP icrası söndürülmüşüsə nə baş verir?

### Sual 3.

RCE-dən başqa fayl yükləmə hansı təhlükələr daşıyır?

## Task 2 — Webshell: Nədir, Necə İşləyir

**Webshell** — web server tərəfindən icra olunan və attacker-ə əmr göndərmək interfeysi verən kiçik skriptdir. Ən sadə PHP webshell (izah üçün, bir sətirlik):

```php
<?php system($_GET['cmd']); ?>
```

Məntiqi: `shell.php?cmd=whoami` URL-i açılanda server `system()` funksiyası ilə `whoami` əmrini icra edir və nəticəni səhifəyə yazır. Attacker browser ilə sistem əmrləri verir. Bu, "web-ə yerləşdirilmiş uzaqdan idarə"dir.

Webshell növləri:

- **Kiçik/one-liner** — yuxarıdakı kimi; aşkarlanması asan deyil (log-da sadəcə GET sorğuları görünür).
- **Tam funksional panel-lər** — b4kp4ck tipli, çoxsaylı funksiyalı (fayl idarəetməsi, terminal, DB çıxışı); böyük, imzalı, aşkarlanması asan.
- **Memory-based/avto-silinən** — footprint azaltmaq üçün (red team konteksti).

Webshell-dən sonrakı addım adətən **reverse shell**-dir: webshell vasitəsilə bir əmr icra olunur ki, server attacker-in dinləyən maşınına qoşulan tam interaktiv shell qursun (netcat/PowerShell əsaslı). Webshell HTTP üzərində "əmr-cavab" verir; reverse shell tam terminal verir — fərq interaktivlik və rahatlıqdır. (Detallı shell mövzusu exploitation module-larına aiddir; burada konsept kifayətdir.)

Webshell necə yüklənir? Task-ın əvvəlindəki zəncir üzrə: zəif yükləmə nöqtəsi + yoxlamanın bypass-ı. Növbəti task-da bypass üsullarına keçərik.

Müdafiə tərəfdən baxanda webshell-in mövcudluğu — hesabatda adətən **Critical** tapıntıdır: uzaqdan kod icrası, tam server nəzarəti. Sübut: `id`/`whoami` çıxışının ekran görüntüsü (lab şəraitində). Real pentest-də isə webshell yükləmə əvəzinə daha "məsum" icra sübutu (məs. `id` çıxışı) göstərilir — hədəf sistemə qalıcı shell qoymaq ROE ilə məhdudlaşır.

### Sual 1

Webshell nə edir — işləmə prinsipini izah edin.

### Sual 2.

Webshell və reverse shell arasındakı fərq nədir?

### Sual 3.

Webshell tapıntısının severity-si nə üçün Critical sayılır?

## Task 3 — Yoxlamaların Bypass-ı: Uzantı, Content-Type, Magic Bytes

İndi müdafiə tərəfdən: tətbiqlər faylları necə yoxlayır və bu yoxlamalar necə keçilir? (Lab/öz sistemlərinizdə məşq üçün; hər üsul müdafiə anlayışı kimi də öyrənilir.)

**Səviyyə 1 — Client-side yoxlama (JavaScript ilə).** Ən zəif: JS yalnız browser-də işləyir, server-ə birbaşa sorğu (Burp ilə) onu tam atlayır. Bypass: sorğunu proxy-də tutub faylı/uzantını dəyişmək. Bu, arxitektura room-undakı "client-a etibar etmə" dərsinin fayl tətbiqi.

**Səviyyə 2 — Uzantı yoxlaması (blacklist).** Server `.php`-i qadağan edir. Bypass variantları:

- Alternativ uzantılar: `.php3`, `.php5`, `.phtml` (server konfiqurası onları icra edirsə).
- Hərf oyunları: `.PHP`, `.Php` (case-sensitive yoxlamalarda).
- İkili uzantı: `shell.php.jpg` (bəzi server-lər soldan ilk tanınanı icra edir).
- Null byte (köhnə PHP): `shell.php%00.jpg` — %00-dan sonra hissə "yox olur".
- Trailing space/dot: `shell.php.` və ya `shell.php ` — Windows-da/düzgün təmizlənməyəndə.

**Səviyyə 3 — Whitelist uzantı.** Yalnız `.jpg`, `.png` qəbul olunur — blacklist-dən yaxşıdır. Bypass: yüklənilən faylın **məzmunu** şəkil olub web server konfiqurasiyasında icra tapa biləcəyi hallar: `.htaccess` yükləmək (Apache-də — `AddType application/x-httpd-php .jpg` yazaraq .jpg-ni PHP edir; `.htaccess` yükləmək mümkünsə), `.user.ini` (PHP-FPM), web.config (IIS). Yəni hədəf təkcə "shell.php" yox, "icra konfiqurasiyası"dır.

**Səviyyə 4 — Content-Type yoxlaması.** Sorğunun `Content-Type: image/jpeg` başlığı yoxlanılır. Amma bu başlıq client tərəfindən gəlir — Burp ilə dəyişilir. Məzmun heç yoxlanılmır.

**Səviyyə 5 — Magic bytes / məzmun yoxlaması.** Faylın ilk baytları (JPEG `FF D8 FF`, PNG `89 50 4E 47`, GIF `GIF89a`) yoxlanılır. Daha güclüdür, amma bypass: polyglot fayllar — həm şəkil, həm skript kimi düzgün olan fayllar (GIF başlığı + PHP kodu: `GIF89a<?php system(...); ?>`) — magic byte keçir, uzantı `.php` qalır (uzantı yoxlaması zəifdirsə).

**Səviyyə 6 — Harada saxlanılır.** Fayl web root-da, icra icazəli qovluqdadırsa — risk artır. Düzgün: web-dən çıxarılmış storage (S3 və s.) və ya icra söndürülmüş qovluq.

Ümumi dərs: **tək yoxlama təbəqəsi heç vaxt kifayət etmir** — bypass hər zaman növbəti təbəqəni axtarır. Düzgün müdafiə — növbəti task.

### Sual 1

Client-side fayl yoxlaması nə üçün heç bir müdafiə deyil?

### Sual 2.

Magic bytes yoxlaması nədir və polyglot fayl onu necə keçir?

### Sual 3.

`.htaccess` yükləmək nə üçün təhlükəlidir?

## Task 4 — Düzgün Fayl Validasiyası: Çoxtəbəqəli Model

Etibarlı fayl yükləmə sistemi bir neçə müstəqil qat qurur:

**1. Məqsəd sualı — fayl lazımdırmı?** Ən yaxşı müdafiə: yoxlama sisteminə ehtiyac olmayan funksiya. Şəkil yükləmə — bəs original fayl lazımdır, yoxsa proses olunmuş surəti? Əksər hallarda server şəkli yenidən emal edib (resize/re-encode) saxlaya bilər — originalın saxlanması ehtiyac yoxdursa, zəhərli məzmun re-encode-dan sağ çıxmır.

**2. Whitelist yanaşması.** Qadağan siyahısı (`.php` qadağan) deyil, icazə siyahısı: yalnız `image/jpeg`, `image/png` qəbul olunur. Hər şey qadağan, sadəcə göstərilənlər açıq.

**3. Məzmun əsaslı identifikasiya.** Uzantıya və Content-Type-a deyil, faylın özünə baxmaq: magic bytes + (şəkillər üçün) gerçek dekod testi — faylı açıb yenidən yaz (re-encode). Bu, bütün ad oyunlarını (`shell.php.jpg`, GIF+PHP) neytrallaşdırır.

**4. Adın tam yenidən yaradılması.** İstifadəçinin verdiyi addan heç nə saxlanmır: yeni random ad (`a7f3b2...jpg`) generasiya olunur. Path traversal (`../`), ikili uzantı, xüsusi simvollar — hamısı avtomatik yox olur.

**5. Saxlama yeri.** Yüklənən fayllar icra olunmayan yerdə: ayrı storage (S3/CDN), icra söndürülmüş statik qovluq (`uploads/`-da PHP handler off), və ya tam ayrı domain (static.site.com — həm təcrid, həm cookie isolasiyası).

**6. Ölçü və say limiti.** Max fayl ölçüsü, istifadəçi başına limit — DoS-a qarşı.

**7. Skan (əlavə).** Zərərli məzmun (malware) skanı — istifadəçilər bir-birinə fayl "paylaşdıqda" vacibdir.

Bu modelin fəlsəfəsi: **istifadəçinin faylı — istifadəçinin məlumatıdır, server-in əmridir yox.** Ad, tip, məzmun — hamısı "input"dur və bütün input qaydaları (validate, normalize, isolate) burada da geçərlidir.

Test yanaşması (pentest tərəfdən): yuxarıdakı hər qatı sırayla sına — client-side (Burp ilə atla), blacklist (alternativlər), whitelist+content-type (polyglot), magic (re-encode yoxdursa), saxlama yeri (icra varmı: `.jpg`-i `.php` adı ilə yox, `test.php` məzmunlu şəkli yükləyib açmaqla yoxla — amma bunlar yalnız icazəlı hədəfdə).

### Sual 1

Re-encode (şəkli yenidən emal etmək) nə üçün güclü müdafiədir?

### Sual 2.

Fayl adını tam yenidən yaratmaq hansı hücumları avtomatik yox edir?

### Sual 3.

"Whitelist yanaşması" fayl kontekstində necə tətbiq olunur?

## Task 5 — Ssenari Lab: Zəif Yükləmədən RCE-yə

Bütün room-u bir axında birləşdirən konseptual ssenari (öz lab-ınızda təkrarlayın — məs. DVWA fayl yükləmə modulu):

**Addım 1 — Səthin tapılması.** Profil səhifəsində avatar yükləmə; Burp ilə sorğu tutulur: `POST /upload` multipart/form-data; fayl sahəsi `image`; cavab: "uğurla yükləndi: /uploads/avatar1.png".

**Addım 2 — İlkin sınaq.** `test.php` (məzmunu: `<?php echo "OK"; ?>`) yükləmək → "yalnız şəkil" xətası. Deməli, uzantı yoxlaması var.

**Addım 3 — Uzantı oyunları.** `test.phtml` → qəbul olundu! `/uploads/test.phtml` açılır → "OK". Zəiflik təsdiq: blacklist var (`php` qadağan), amma alternativləri əhatə etmir və qovluqda icra var.

**Addım 4 — İstismarın sübutu.** Webshell yerləşdirilir (`cmd` parametrli kiçik skript), `?cmd=id` çağırılır → `uid=33(www-data)`. RCE sübut olundu (lab-da bununla dayanılır).

**Addım 5 — Hesabat.** Tapıntı: "File upload funksiyası blacklist uzantı yoxlaması ilə web root-a icra icazəli qovluqda fayl yazır — RCE mümkündür". Sübut: yuxarıdakı zəncir + `id` çıxışı. Remediation: whitelist + re-encode + random ad + icra söndürülmüş qovluq.

Bu ssenari bir də vacib dərs verir: zəifliyin **kökü tək qərar** idi — "yüklənən faylı web root-da, icra icazəli saxlayaq". Bütün bypass zənciri (uzantılar, content-type) ikinci dərəcəli idi; bir qərar düzgün olsaydı (icra yox idi), qalan zəifliklər öz əhəmiyyətini itirərdi. Müdafiə dizaynında "ən yuxarı səviyyəli düzgün qərar" (saxlama yeri, arxitektura) bütün aşağıdakı xətalardan qoruyur.

Module bağlanarkən yadda saxlanacaq formul: **yükləmə = yazma icazəsidir; yazma + icra = RCE.** Müdafiə ya yazmanı təmizləyir (validasiya), ya icranı ayırır (izolyasiya) — idealda hər ikisi.

### Sual 1

Ssenaridə zəifliyin kök qərarı hansı idi?

### Sual 2.

İstismarın minimum sübutu kimi nə göstərilir və nə üçün dayanılır?

### Sual 3.

"Yazma + icra = RCE" formulu room-un hansı mesajını ifadə edir?

## Yekun Yoxlama (Summary Quiz)

1. Fayl yükləmə zəifliyinin RCE-yə çevrilmə zəncirini təsvir edin.
2. Blacklist uzantı yoxlamasının dörd bypass üsulunu sadalayın.
3. Magic bytes nədir və polyglot fayl nə deməkdir?
4. Düzgün fayl validasiyasının beş qatını sadalayın.
5. Niyə "whitelist" "blacklist"-dən üstün müdafiədir?

---

## CƏVAB AÇARI (yalnız content creator üçün — istifadəçiyə göstərilməməlidir)

**Task 1 sualları:**
1. Yüklənən faylın icra oluna bilən yerə (web root, icra aktiv) düşməsi; faylın ad/uzantı/məzmun yoxlamasının keçilməsi (və ya olmaması).
2. `.php` faylı kod kimi yox, mətn/soruşma kimi qaytarılır — RCE yaranmır; müdafiə təbəqəsidir.
3. XSS (SVG-də skript), path traversal (başqa qovluğa yazma), DoS (böyük fayllarla doldurma), zərərli faylın yayılması/hostlanması.

**Task 2 sualları:**
1. Server tərəfindən icra olunan kiçik skript — HTTP sorğusu vasitəsilə attacker-in əmrlərini sistemdə icra edib nəticəni qaytarır (məs. `system($_GET['cmd'])`).
2. Webshell HTTP üzərində əmr-cavab verir (yarı-interaktiv); reverse shell server-in attacker-ə qoşulub tam terminal verdiyi bağlantıdır — interaktiv və daha güclü.
3. Çünki uzaqdan kod icrası = server üzərində tam nəzarət; bütün digər tapıntıların hamısı bundan sonra mümkündür.

**Task 3 sualları:**
1. JS browser-də icra olunur; sorğu Burp/curl ilə birbaşa göndərildikdə bu yoxlama mövcud olmur — yalnız "normal" istifadəçini saxlayır.
2. Faylın ilk baytlarının fayl formatını göstərməsi (JPEG: FF D8 FF); polyglot — həm şəkil magic bytes-ları, həm skript məzmunu daşıyan fayl: yoxlama şəkili görür, server (uzantı/konfiq zəifdirsə) skripti icra edir.
3. Apache konfiqurasiya faylıdır — yükləmə mümkünsə attacker `.jpg` fayllarını PHP kimi icra etməyi əmr edə bilər; "icra qaydalarını" dəyişmək qapısı açılır.

**Task 4 sualları:**
1. Çünki fayl tam dekod olunub yenidən kodlanır — original baytlar (zəhərli skript hissəsi) itir; sadə header yoxlaması deyil, məzmunun tam çevrilməsidir.
2. Path traversal (`../`), ikili/qəribə uzantılar (`shell.php.jpg`), xüsusi simvollar/null byte — istifadəçi adı heç istifadə olunmadığından bütün ad əsaslı hücumlar avtomatik yox olur.
3. Qadağan siyahısı yox: yalnız açıq şəkildə icazə verilən növlər (məs. image/jpeg, image/png) qəbul olunur; hər yeni/qəribə növ default olaraq rədd edilir.

**Task 5 sualları:**
1. Yüklənən faylı web root-da, icra icazəli qovluqda saxlamaq — arxitektura qərarı; bütün bypass-lar bunun üzərində "işlədi".
2. `id`/`whoami` çıxışı — kod icrasının sübutu; qalıcı shell/real ziyan ROE çərçivəsində deyil, lab-da isə tapıntı təsdiqləndikdən sonra daylanılır.
3. Müdafiənin iki istiqamətini: yazmanı təmizlə (validasiya/re-encode) və icranı ayır (izolyasiya) — hər ikisi birgə RCE-ni qeyri-mümkün edir.

**Yekun Quiz:**
1. Yükləmə qəbul olunur → zəif/yox yoxlama → web root-a (icra aktiv) yazılır → icra edilən ad/məzmun (shell.php) → URL ilə çağırılır → kod icrası (RCE).
2. Alternativ uzantılar (.phtml, .php5), hərf oyunları (.PHP), ikili uzantı (shell.php.jpg), null byte/trailing simvollar (shell.php%00.jpg, "shell.php.").
3. Faylın ilk baytları — format imzası (JPEG FF D8 FF); polyglot — eyni fayl həm şəkil kimi valid başlıq, həm skript kimi icra olunan məzmun daşıyır.
4. Whitelist (yalnız icazəli növlər); məzmun yoxlaması/re-encode; adın random yenidən yaradılması; icra olunmayan yerdə saxlama; ölçü/say limiti (+ zərərli skan).
5. Blacklist hər yeni variantı (uzantı, encoding, sintaksis) tuta bilmir — yarımçıq siyahıdır; whitelist default-deny edir: bilinməyən hər şey rədd olunur, yeni bypass sahəsi yoxdur.
