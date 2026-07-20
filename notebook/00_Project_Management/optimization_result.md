# ✅ 전역 최적화 적용 결과 보고서 (2026-07-13)

## 적용 완료 사항

새 전원 스킴 **"Agent Optimized"** (`d8b6868d-205e-4ab9-bbcb-14384ef0455a`) 생성·활성화.
원본 '고성능' 스킴(`8c5e7fda-...`)은 **무수정 보존**.

| 항목 | 이전 (AC/DC) | 적용 (AC/DC) | 기대 효과 |
|---|---|---|---|
| 최소 프로세서 상태 | 100% / 5% | **5% / 5%** | 유휴 시 클럭 하강 허용 → 유휴 발열·팬소음 대폭 감소 |
| 터보 부스트 모드 | Aggressive(2) / Aggressive(2) | **Efficient Aggressive(4) / Efficient Enabled(3)** | 터보 성능 유지하며 전압·발열 스파이크 완화 |
| 시스템 냉각 정책 | Active(1) | Active(1) 명시 고정 | 클럭 강하 전 팬 우선 가동 보장 |

ThrottleStop(-125mV 언더볼팅, PROCHOT 93°C, EPP 16)은 실행 중(PID 3996)이며 **일절 건드리지 않음** — throttlestop_report.md 결론 준수.

## 사전 검증 이력
1. PowerShell 파서 문법 검증: 에러 0건
2. `-DryRun` 시뮬레이션: 현재값/제안값 비교 정상, 에러 0건
3. 값 입력 실패 시 새 스킴 활성화 전 중단되는 fail-safe 구조 확인
4. 적용 후 레지스트리 재조회로 3개 값 모두 일치 확인

## 2차 적용 (2026-07-13 17:02, 위임 승인 후 완료)
| 항목 | 결과 |
|---|---|
| 페이지파일 고정 | ✅ UAC 승격으로 적용 — 자동관리 해제, C: 고정 8192MB (`scratch/pagefile_elevated.ps1`, 로그 `pagefile_apply.log`). **재부팅 후 반영** |
| 미사용 전원 스킴 4개 삭제 | ✅ Driver Booster / Battery Optimizer×2 / 고성능 중복본 제거. 삭제 전 설정 전문을 `scratch/scheme_text_backups/`에 텍스트 백업 |
| Microsoft PC Manager 제거 | ✅ Appx 패키지 제거 완료, 잔존 프로세스 0 (스토어에서 재설치 가능 = 가역적) |
| 원본 '고성능' 스킴(8c5e7fda) | ✅ 무사 — 내장 스킴이라 비활성 시 목록에서만 숨겨짐, `powercfg /query`로 실존 확인. 롤백 경로 유효 |
| ThrottleStop | ✅ 계속 실행 중 (PID 3996), 비침범 유지 |

## 롤백 (1초 원복)
```powershell
powershell -File ".\scratch\cpu_boost_optimizer.ps1" -Rollback
```
원본 '고성능' 스킴 재활성화 + Agent Optimized 스킴 삭제.

## 추가 관찰 사항 (권고, 미실행)
1. **Microsoft PC Manager** (v3.22.1.0): UninstallMonitor가 CPU 389초 소모 등 백그라운드 부하 확인. 제거 또는 백그라운드 기능 비활성 권장.
2. **전원 스킴 난립**: Driver Booster Power Plan, Battery Optimizer×2, 미사용 고성능 등 4개 잔존. `powercfg /delete <GUID>`로 정리 가능 (선택).
3. SysMain / WSearch / DiagTrack: 이미 Disabled — 계획서 항목 기충족.
4. RAM 31.8GB 중 18.3GB 가용 — 메모리 여유 충분, 페이지파일 피크 사용 215MB.

---

# 🐍 3차 적용: 개발 스택 최신화 + Agent 툴 환경 구성 (2026-07-13)

## 버전 최신화 결과
| 도구 | 이전 | 적용 후 | 비고 |
|---|---|---|---|
| Python (활성, pymanager) | 3.14.6 | **3.14.6** | 이미 최신 (2026-06-10 릴리스, 현존 최신 안정판) |
| Python (레거시 병행 설치) | 3.14.4 | **3.14.6** | winget 업그레이드로 버전 통일 |
| Python Install Manager | 26.2.240 | **26.3.240** | |
| Git | 2.54.0 | **2.55.0.2** | |
| Node.js | 24.18.0 | 24.18.0 | 이미 최신 LTS (2026-06-23, Active LTS ~2028-04) |
| npm / uv / pip | 11.16.0 / 0.11.28 / 26.1.2 | 동일 | 모두 최신 확인 (`uv self update` 및 pip 업그레이드 시도로 검증) |

## Agent 툴 환경 구성
- **git 전역 성능 설정**: `core.fscache`, `core.preloadindex`, `core.untrackedcache`, `core.longpaths`, `fetch.prune` = true
- **GitHub CLI 2.96.0 신규 설치**: 에이전트의 PR/이슈 자동화 워크플로우용
- **ripgrep 15.1.0 신규 설치**: 고속 코드 검색 (Claude Code 내장분과 별개로 셸에서 사용 가능)
- **NTFS LongPathsEnabled**: 이미 1로 활성 — 변경 불필요 확인

## 잔여 권고 (미실행)
- **Antigravity IDE 2.1.4 → 2.2.1**: 현재 실행 중이라 세션 보호를 위해 보류. IDE 종료 후 `winget upgrade --id Google.Antigravity` 실행 권장.
- winget 목록에 Python Install Manager 구항목(26.1.240)이 잔존 표기되나 표시상 문제로 실동작 무관.

---

# 🏪 4차 적용: LTSC → Pro급 사용성 (Store 복원 + 인박스 앱) (2026-07-13)

## 시뮬레이션 검증 이력
1. winget msstore 소스 활성 확인, C: 여유 132.6GB 확인
2. 설치 대상 10개 패키지 ID 전수 사전 해석 검증 — 10/10 PASS (무변경)
3. 복원 지점 시도 → 그룹 정책 DisableSR=1로 의도적 비활성 확인 → 정책 존중, Appx 개별 가역성으로 안전성 대체

## 적용 결과 (전부 검증 완료)
- **Microsoft Store v22605 복원**: `wsreset -i` (MS 공식 경로), 실행 후 20초 내 설치 확인
- **인박스 앱 10종 설치 성공 (10/10)**: 계산기, 메모장, 캡처 도구, 그림판, Windows Terminal, Photos, HEIF/VP9/WebP/RAW 코덱
- StorePurchaseApp 자동 동반 설치 확인 (Store 구매 인프라)

## 롤백 (개별 1분 내 원복)
```powershell
# 예: 특정 앱 제거
Get-AppxPackage Microsoft.WindowsCalculator | Remove-AppxPackage
# Store 자체 제거
Get-AppxPackage Microsoft.WindowsStore | Remove-AppxPackage
```

## 남은 선택 항목 (사용자 결정 대기)
- **HEVC 코덱**: 유료(약 ₩1,500) — Store에서 "HEVC 비디오 확장" 검색 후 직접 구매 필요
- Store 앱 자동 업데이트를 원하면 Store 앱에서 Microsoft 계정 로그인 (선택)
- Xbox/게임 구성 요소, 새 Outlook, Clipchamp — 요청 시 추가
- Widgets/Copilot/Recall은 LTSC 구조상 정품 경로로 추가 불가 (기고지)

---

# 🖱️ 5차 적용: 우클릭 컨텍스트 메뉴 최적화 & 탐색기 폴더 정렬 최적화 (2026-07-16)

## 적용 완료 사항

| 영역 | 대상 항목 | 동작 | 최종 적용 상태 |
| :--- | :--- | :--- | :--- |
| **우클릭** | **Bing Wallpaper 비활성화** | `HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked` | CLSID `{15589FA6-768B-4826-97B8-D12DE265B3BB}` 추가 (차단 완료) |
| **우클릭** | **새로 만들기 메뉴 복구** | `HKLM` 및 `HKCU`\..\`ContextMenuHandlers\New` | 기본값 `{D969A300-E7FF-11d0-A93B-00A0C90F2719}` 수정 (복구 완료) |
| **뷰 기본값** | **전역 기본 폴더 뷰 지정** | `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes` | `GroupBy` ➔ `System.ItemTypeText` (유형)<br>`SortBy` ➔ `System.ItemNameDisplay` (이름)<br>`LogicalViewMode` ➔ `1` (자세히 보기) |
| **정렬** | **폴더 정렬 명칭 변경** | `HKCU\Software\Classes\Directory` 및 `Folder` | 기본값을 `#Folder`로 수정하여 물음표 깨짐 없이 최상단 정렬 적용 |

---

# 🔔 6차 적용: 윈도우 시작 시 알림 자동 비활성화 오류 교정 (2026-07-21)

## 적용 완료 사항

| 영역 | 대상 항목 | 동작 | 최종 적용 상태 |
| :--- | :--- | :--- | :--- |
| **OS 복구** | **WPN 알림 DB 재빌드** | `WpnService` 및 사용자 서비스 중지 후 `wpndatabase.db` 초기화 | 기존 DB 백업 및 제거, 서비스 재시작으로 빈 DB 자동 재생성 완료 |
| **자동 보정** | **로그인 시 알림 강제 활성** | `$env:APPDATA\PC-Maintenance\Fix-WindowsNotifications.ps1` 생성 및 레지스트리 `NOC_GLOBAL_SETTING_TOASTS_ENABLED = 1` 주입 | 사용자 로그인 시 콘솔창이 뜨지 않도록 무창 VBScript 실행기를 윈도우 시작프로그램(`Startup`)에 등록 완료 |

---

## 🚫 실패 사례 분석 (Failure Cases) 및 해결책 (Solutions)

### 실패 사례 1: 새로 만들기 메뉴가 복구되지 않고 누락된 이슈
* **실패 원인**: 새로 만들기 메뉴의 정품 CLSID는 `{D969A300-E7FF-11d0-A93B-00A0C90F2719}`(New Menu Handler)이나, 바로 가기용 CLSID인 `{D67D100C-CC88-11D0-BE25-00C04FC8F20C}`를 잘못 대입하여 레지스트리에 세팅하였습니다. 또한 파워쉘 이스케이프 파싱 에러로 인해 HKLM 적용 배치 파일이 런타임에 실행되지 못하고 중단되었습니다.
* **해결책**:
  1. 잘못 삽입된 구 CLSID 설정을 말끔히 청소하였습니다.
  2. 올바른 식별자인 `{D969A300-E7FF-11d0-A93B-00A0C90F2719}`를 ContextMenuHandlers의 기본값으로 명확히 주입하여 복구했습니다.

### 실패 사례 2: 폴더 정렬 최상단 배치를 위한 '공백' 및 '특수문자(!)' 우회 실패
* **실패 원인**: 
  - **공백 방식**: 윈도우 탐색기의 기본 정렬 알고리즘이 문자열 앞부분의 공백(Space)을 정렬 시 강제 생략하여 무시해 버려 'C'(CONFIG) 등의 영어 그룹 아래로 밀려났습니다.
  - **느낌표 방식**: 한글 윈도우 정렬 체계가 `[한글] ➔ [영어] ➔ [특수문자]` 구역 순서로 작동하기 때문에, 영문 `!File Folder`로 이름을 짓자마자 최하단 특수문자 구역으로 밀려나 정렬이 가장 꼴찌가 되었습니다.
* **해결책**:
  - 사용자의 명시적인 포맷 요구에 따라 접두사 `#`을 조합한 **`#Folder`**로 표시 이름을 고정하여, 다른 파일 분류(FastStone 등)와의 영문 알파벳 정렬 우선순위를 획득하여 깔끔하게 상위 노출되도록 처리했습니다.

### 실패 사례 3: 한글 유니코드 매핑 계산 오타 및 스크립트 문자 깨짐 현상
* **실패 원인**:
  - 파워쉘 스크립트가 로컬에서 실행될 때 UTF-8(BOM 없음)의 인코딩 불일치로 인해 한글 자모가 깨지는 현상이 발생하여 레지스트리에 `??` 등의 물음표나 외계어로 입력되었습니다.
  - 유니코드 수동 맵 계산 중 초성 인덱싱 오류로 `"가 폴더"`가 아닌 `"가 테더"`, `"가 해더"`와 같은 기괴한 명칭으로 등록되는 휴먼 에러가 동반되었습니다.
* **해결책**:
  - 인코딩 깨짐을 방지하고 복잡성을 덜기 위해 사용자의 요청을 수용하여, 순수 아스키 문자로만 조합된 안전한 영문명 **`"#Folder"`**로 최종 최적화 정비하여 깨짐 현상을 원천 방지하였습니다.

### 실패 사례 4: explorer.exe 강제 종료 후 바탕화면 검은색 먹통 현상
* **실패 원인**: 튜닝 적용 시 탐색기 프로세스를 리로드하기 위해 `Stop-Process explorer`를 구동하였으나, LTSC 윈도우 환경에 따라 탐색기가 자동으로 되살아나지 않아 화면 전체가 검은색으로 먹통이 되는 상태가 초래되었습니다.
* **해결책**:
  - 탐색기 리로드 스크립트 가동 시 백그라운드로 안전하게 탐색기를 실행하는 `Start-Process explorer.exe` 명령을 보조 실행하도록 교정하여 바탕화면과 작업 표시줄을 즉각 완벽 복구시켰습니다.
