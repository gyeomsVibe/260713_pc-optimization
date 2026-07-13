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
