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

### 4. Claude Code 에이전트 환경 구성 (학습모드)

에이전트 도구의 "확장"은 **3개 층위**로 나뉜다. 이 구분을 알아야 *무엇을 어디서 켜고 끄는지* 헷갈리지 않는다.

| 층위 | 무엇인가 | 관리 위치 | 리소스 성격 |
|---|---|---|---|
| **① 로컬 플러그인** | 마켓플레이스에서 로컬 설치한 스킬·명령·에이전트 묶음 | `claude plugin` CLI (에이전트가 직접 제어) | 컨텍스트 토큰 |
| **② 로컬 MCP 서버** | 로컬 설정에 등록된 외부 도구 서버 | `claude mcp` / `/mcp` | 프로세스·연결 |
| **③ 계정 커넥터 번들** | claude.ai 계정에 연결되어 로그인 시 주입되는 업무용 번들 | **claude.ai 웹 설정에서만** | 목록·연결시도 오버헤드 |

> 핵심 원리: **①②는 이 노트북 로컬에서 제어**되지만, **③은 claude.ai 계정 쪽**에 있어 CLI로 못 지운다.

**이번에 적용한 정리:**
- **① 로컬 플러그인**: 설치된 10개 중 불필요·중복 **3개 비활성화**(`plugin-dev`, `example-skills`, `pr-review-toolkit`) → 활성 7개 유지. `disable`은 컨텍스트 미로딩 = 리소스 절약이며 가역적(`claude plugin enable`로 원복).
- **② 로컬 MCP**: Notion(연결) / Canva(인증 필요) 상태 확인.
- **③ 계정 커넥터 15종**: 전부 사용 0회. bio-research·legal·marketing 등 **업무용 번들 11개는 삭제 권장**이나, 계정 쪽 설정이라 claude.ai 웹에서 직접 제거해야 함.
각 층위의 전체 목록·판단 근거·claude.ai 삭제 절차는 → [`claude-agent-environment.md`](claude-agent-environment.md)

---
### 5. Codex 에이전트 환경 구성

Codex는 플러그인마다 상시 프로세스를 띄우기보다, 대화에서 사용할 수 있는
도구·스킬·지침을 확장한다. 따라서 노트북에서는 **실제 작업에 필요한 기능만
활성화**해 컨텍스트 토큰과 플러그인 캐시 사용량을 줄였다.

| 구분 | 관리 위치 | 이번 구성 |
|---|---|---|
| **로컬 플러그인** | `%USERPROFILE%\.codex\config.toml`, `codex plugin` CLI | 35개 활성 상태를 25개로 정리 |
| **플러그인 캐시** | `%USERPROFILE%\.codex\plugins\cache` | 중복 Claude 계열 번들을 포함해 약 43MB 절감 |
| **업무 연동 도구** | Codex Desktop의 연결된 계정·플러그인 | Google Workspace·GitHub·Notion·Zoom 중심으로 유지 |

**정리한 플러그인(10개):**

- Claude API, 중복 문서 스킬, 예제 스킬 묶음
- Asana, Brand24, Carta CRM, Cloudinary, HeyGen, MarcoPolo, 사설 레지스트리 연동

**유지한 핵심 기능:**

- 개발: GitHub, 코드 리뷰(Code Review), 기능 개발(Feature Development), 커밋, 보안 가이드
- 문서: 문서·PDF·스프레드시트·프레젠테이션
- 업무: Gmail, Google Drive, Google Calendar, Notion, Zoom
- 조작·표현: 내장 브라우저, Chrome 제어, 화면 제어, 사이트 제작, 시각화

> 변경 사항을 완전히 반영하고 이미 메모리에 올라온 도구 정의를 해제하려면
> Codex Desktop을 종료한 뒤 다시 실행한다. 플러그인 마켓플레이스의 공유 캐시는
> 재설치·업데이트용이므로, 설치 목록에 없는 항목까지 수동 삭제하지 않는다.


## 문서

| 파일 | 내용 |
|---|---|
| [`implementation_plan.md`](implementation_plan.md) | 초기 발열·지연 방지 최적화 계획서 |
| [`throttlestop_report.md`](throttlestop_report.md) | ThrottleStop 현재 설정 분석 (Read-only 조사) |
| [`optimization_result.md`](optimization_result.md) | 전 단계 적용 결과 및 롤백 방법 (1~4차) |
| [`claude-agent-environment.md`](claude-agent-environment.md) | Claude Code 에이전트 설정 구성 및 정리 가이드 |

## 🤖 Antigravity 에이전트 설정 환경

노트북 환경에서 에이전트(Antigravity)가 정상 작동하는 데 필요한 시스템 기본 사양 및 도구 스택 버전입니다.

- **OS**: Microsoft Windows 11 Enterprise LTSC (Version: 10.0.26100, 64-bit)
- **Git**: `2.55.0.windows.2`
- **Node.js**: `v24.18.0`
- **npm**: `11.16.0`
- **uv (Python 패키지 관리자)**: `0.11.28`
- **Python (py 런처)**: `3.14.6`

### 에이전트 환경설정 (.agents/)
에이전트(Antigravity)의 사용자 설정 및 MCP 서버 구성을 보존하기 위해 루트 경로의 [`.agents/config.json`](../.agents/config.json) 및 [`.agents/mcp_config.json`](../.agents/mcp_config.json) 파일이 리포지토리에 저장되어 함께 동기화됩니다.

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
