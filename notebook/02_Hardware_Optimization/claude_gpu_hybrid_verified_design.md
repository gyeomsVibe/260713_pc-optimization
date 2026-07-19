# ✅ 듀얼 GPU 공존 설계 — 실측 검증판 (2026-07-14 적용 완료)

> 원안 [`gpu_analysis_report.md`](gpu_analysis_report.md)를 실환경 전수조사로 검증·수정해 적용한 최종 설계.
> 하드웨어: Intel UHD 630(내장) + NVIDIA GTX 1660 Ti 6GB(외장) · 드라이버 596.36

---

## 1. 실측으로 확정된 전제 (원안과 다른 점)

| 항목 | 실측 결과 | 설계 영향 |
|---|---|---|
| 하이브리드 모드 | **이미 동작 중** (내장 GPU 활성 + 내장 패널 구동). GL75 9SDK는 MUX 스위치 미탑재 | 원안 1단계(Dragon Center MUX 변경) **폐기** |
| 외장 모니터 | **GTX에 직결** (`display_active=Enabled`) | dGPU 완전 절전 불가 → 목표를 "VRAM 보호 + P8 저전력 유지"로 재정의 |
| NVIDIA 제어판 | Windows 10 1803+ 부터 **Windows 그래픽 설정이 우선** | 원안 3단계 **폐기** — 레지스트리 한 곳으로 일원화 |
| '최고 성능 선호' | 클럭 상시 고정 = 발열 증가, IDE 체감 이득 없음 (P8에서도 원활) | **비적용** — 발열 최적화 기조 유지 |
| Dragon Center 경로 | `C:\Program Files (x86)\MSI\Dragon Center\` (원안은 MSI 폴더 누락) | 경로 정정 후 적용 |

## 2. 적용된 배분 (HKCU\Software\Microsoft\DirectX\UserGpuPreferences) — 최종 6건

| 앱 | 배분 | GpuPreference |
|---|---|---|
| Antigravity IDE.exe | 🚀 외장 GTX — 주력 에디터 VRAM 우선권 | `2` |
| python.exe (3.14.6) | 🚀 외장 GTX — CUDA 연산 대비 | `2` |
| chrome.exe | 💻 내장 Intel — 다중 탭 VRAM 잠식 차단 | `1` |
| IGCC (AUMID: `AppUp.IntelGraphicsExperience_…!App`) | 💻 내장 Intel | `1` |
| Claude 데스크톱 (AUMID: `Claude_…!Claude`) | 💻 내장 Intel — 채팅 UI | `1` |
| WebView2 (현재 버전 경로) | 💻 내장 Intel — 버전업 시 항목만 무효화(무해), 재등록 필요 | `1` |

- 관리자 권한 불필요(사용자 레지스트리). **각 앱을 재시작해야 반영**된다.
- 패키지 앱(IGCC·Claude)은 AUMID 값 이름 방식으로 등록 — 경로 불안정 문제 없음.
- dwm/셸 프로세스는 창이 놓인 모니터의 GPU가 자동 담당 — 강제 지정 대상 아님.
- ~~Dragon Center.exe~~ 프로그램 자체 제거됨(2026-07-14) → 항목 불필요. VS Code(code.exe)는 시스템에 미설치 확인 → 원안 항목 대상 부재로 제외.

## 2-1. 전수 재검토 결과 (2026-07-14 2차 감사)

- 배분 6건 전수 검증: 경로 실존 ✓ · AUMID 패키지 실존 ✓ · WebView2 버전 드리프트 없음 ✓
- **배분 실효성 실측**: chrome 렌더 메모리는 Intel(52.8MB), NVIDIA엔 표시용 24MB뿐 → GpuPreference=1 정상 작동.
  ⚠️ `nvidia-smi` 목록에 chrome/claude가 보이는 것은 **클론 호스트(NVIDIA)에 창을 표시하기 위한 Present 컨텍스트**로 정상이며 배분 실패가 아님. 렌더 위치 판별은 `Get-Counter '\GPU Process Memory(pid_*)\Shared Usage'`의 luid별 분포로 할 것.
- HAGS 활성 확인(dxdiag), 페이지파일 8192MB 할당 확인 — "재부팅 대기" 항목 전부 완료 상태.
- Claude 데스크톱 AUMID 배분은 현재 실행 중인 인스턴스(등록 전 시작)에는 미적용 — **다음 앱 재시작부터 자동 적용** (조치 불요).

## 3. 검증 방법

```powershell
# 배분 설정 확인
Get-ItemProperty 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'

# 외장 GPU 상태 (P8 = 저전력 유지가 정상, IDE 사용 중 VRAM 점유 확인)
nvidia-smi --query-gpu=power.draw,memory.used,temperature.gpu,utilization.gpu --format=csv
```
적용 시점 기준: 6.19W · P8 · 448/6144MiB · 47°C — 저전력 상태 정상.

## 4. 최고 성능 반영구 패키지 (2026-07-14 추가 적용)

사용자 요구("한번 설정하면 반영구 + 최고 성능")에 따라 실제 성능 지렛대를 추가 적용:

| # | 항목 | 적용 값 | 성격 |
|---|---|---|---|
| ① | CPU 터보 부스트 (AC) | Efficient Aggressive(4) → **Aggressive(2)** 복귀 | **최대 지렛대.** -125mV 언더볼팅 + PROCHOT 93°C 방어선이 있어 안전. 팬소음 증가 감수. DC(배터리)는 3 유지 |
| ② | HAGS (GPU 하드웨어 스케줄링) | HwSchMode = **2 (ON)** | ✅ **활성 확인됨** (2026-07-14 dxdiag 실측: `Enabled:True, Stable` — GTX측. Intel UHD 630은 드라이버 미지원으로 AlwaysOff가 정상) |
| ③ | 디스플레이 토폴로지 | **복제(Clone) 모드 유지 — 사용자 결정** | 외장 단독 전환 시 노트북 화면이 꺼져 사용자가 불편을 겪음 → 즉시 복제 모드로 원복(2026-07-14). 복제 모드는 프레임 복사 오버헤드가 있으나 사용자 화면 구성이 성능 수치보다 우선. **디스플레이 구성은 에이전트가 임의 변경 금지** |

> 반영구성 근거: 레지스트리(UserGpuPreferences·HwSchMode)와 powercfg 스킴 값은 재부팅·드라이버 업데이트에도 유지된다. NVIDIA 제어판 방식(원안)은 드라이버 클린 설치 시 초기화될 수 있어 채택하지 않았다.

**성능/발열 트레이드오프 정직 고지**: ①로 순간 반응성·버스트 성능이 최고치가 되는 대신 부하 시 온도·팬소음이 이전보다 올라간다. 장시간 풀부하 빌드의 지속 성능은 열 한계가 지배하므로 큰 차이가 없고, 체감 차이는 짧은 버스트 구간에서 난다. 발열 우선으로 되돌리려면:
```powershell
powercfg /setacvalueindex 0482f20d-125e-4f77-82ac-8e4f1fa77b69 SUB_PROCESSOR PERFBOOSTMODE 4
powercfg /setactive 0482f20d-125e-4f77-82ac-8e4f1fa77b69
```

> **스킴 GUID 변경 이력 (2026-07-14)**: 타 에이전트가 오타 GUID(…d47017)로 무효 레지스트리 키를 전원 카탈로그와 스킴에 주입한 사고가 있어, 카탈로그 키는 제거하고 스킴은 `0482f20d-125e-4f77-82ac-8e4f1fa77b69`로 클린 재생성함(구 d8b6868d 삭제). 실제 유효 부스트 GUID는 `be337238-…-4f3749d470c7`(끝 70c7)이며 AC=2/DC=3 검증 완료.

## 5. 롤백 (1초 원복)

```powershell
$k='HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
'C:\Users\Kimyoongyeom\AppData\Local\Programs\Antigravity IDE\Antigravity IDE.exe',
'C:\Users\Kimyoongyeom\AppData\Local\Python\pythoncore-3.14-64\python.exe',
'C:\Program Files (x86)\MSI\Dragon Center\Dragon Center.exe',
'C:\Program Files\Google\Chrome\Application\chrome.exe' |
  ForEach-Object { Remove-ItemProperty -Path $k -Name $_ -ErrorAction SilentlyContinue }
```
