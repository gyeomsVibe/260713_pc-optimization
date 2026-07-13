# 260713 Notebook PC 환경 최적화

MSI GL75 9SDK (Intel i7-9750H · 32GB RAM · Windows 11 Enterprise LTSC 2024) 노트북을
**AI Agent / IDE 작업에 최적화**하기 위한 발열·성능·개발 환경 튜닝 기록.

모든 변경은 `시뮬레이션 검증 → 안정화 확인 → 적용 → 사후 검증 → 롤백 경로 확보` 절차를 따랐다.

---

## 대상 시스템

| 항목 | 사양 |
|---|---|
| 모델 | MSI GL75 9SDK |
| CPU | Intel Core i7-9750H (6C/12T, Turbo 4.5GHz) |
| RAM | 32 GB |
| OS | Windows 11 Enterprise LTSC 2024 (10.0.26100) |
| 저장소 | NVMe SSD (C:) + SATA HDD (D:/E:) |

---

## 적용 내역

### 1. 전원 · 발열 최적화 (Thermal / Latency)
기존 ThrottleStop 튜닝(−125mV 언더볼팅, PROCHOT 93°C, EPP 16)은 **비침범 보존**하고,
Windows 전원 스킴만 조율했다.

- **"Agent Optimized" 전원 스킴 신설** (원본 '고성능' 스킴 무수정 복제)
  - 최소 프로세서 상태(AC) `100% → 5%` — 유휴 발열·팬소음 감소
  - 터보 부스트 모드 `Aggressive → Efficient Aggressive(AC) / Efficient Enabled(DC)` — 전압 스파이크 완화
  - 시스템 냉각 정책 `Active` 명시 고정
- 페이지파일 `C: 고정 8192MB` (자동관리 해제)
- 미사용 전원 스킴 4개 정리, Microsoft PC Manager 제거

→ [`scratch/cpu_boost_optimizer.ps1`](scratch/cpu_boost_optimizer.ps1) (`-DryRun` / `-Apply` / `-Rollback` 지원)

### 2. 개발 스택 최신화 (2026-07 기준)
| 도구 | 버전 |
|---|---|
| Python | 3.14.6 (Python Install Manager 관리, `py` 런처) |
| Node.js | 24.18.0 (Active LTS) |
| Git | 2.55 (+ 전역 성능 설정: fscache, preloadindex, untrackedcache, longpaths, fetch.prune) |
| uv / npm / pip | 최신 확인 |
| 신규 설치 | GitHub CLI, ripgrep |

*에이전트의 원활한 동작을 위해 명령어 자동 실행 권한([`.claude/settings.local.json`](../.claude/settings.local.json)) 설정이 함께 연동되어 보존됩니다.*

### 3. LTSC → Pro급 사용성 복원
LTSC에서 누락된 구성 요소를 **정품 경로**(`wsreset -i` + winget `msstore`)로 복원.

- Microsoft Store 복원
- Inbox 앱 10종: 계산기, 메모장, 캡처 도구, 그림판, Windows Terminal, Photos, HEIF/VP9/WebP/RAW 코덱

---

## 문서

| 파일 | 내용 |
|---|---|
| [`implementation_plan.md`](implementation_plan.md) | 초기 발열·지연 방지 최적화 계획서 |
| [`throttlestop_report.md`](throttlestop_report.md) | ThrottleStop 현재 설정 분석 (Read-only 조사) |
| [`optimization_result.md`](optimization_result.md) | 전 단계 적용 결과 및 롤백 방법 (1~4차) |
| [`agent_env_config.md`](agent_env_config.md) | 에이전트 개발 도구 버전 및 자동 실행 권한 설정 내역 |

---

## 롤백

```powershell
# 전원 스킴 원복
powershell -File .\scratch\cpu_boost_optimizer.ps1 -Rollback

# Store 앱 개별 제거
Get-AppxPackage Microsoft.WindowsCalculator | Remove-AppxPackage
```

각 단계는 개별 원복 가능하도록 백업/스크립트를 확보했다. 상세는 `optimization_result.md` 참고.

---

## 주의

- 본 저장소의 스크립트는 **i7-9750H / LTSC 2024 환경 기준**이다. 다른 하드웨어에서는 값 재계산이 필요하다.
- 전압/전력 튜닝은 하드웨어 손상 위험이 있으므로 값의 의미를 이해한 뒤 사용할 것.
- ThrottleStop 설정은 이 저장소에서 다루지 않으며 별도 유지된다.
