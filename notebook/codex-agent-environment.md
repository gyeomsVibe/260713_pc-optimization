# 🧩 Codex 에이전트 환경설정 기록 (노트북)

> 대상 환경: **노트북** (MSI GL75 9SDK / Windows 11 Enterprise LTSC 2024)
> 관리 도메인: `~/.codex/` · `codex plugin` CLI / Codex Desktop
> 이 문서는 **Codex 전용**이다. Claude·Antigravity 설정은 각자의 문서에서 다룬다.

---

## 1. Codex란 (학습모드)

Codex는 대화 중 사용할 도구·스킬·지침을 확장하는 에이전트다. Claude Code와 마찬가지로
확장은 **3층위**로 이해하면 관리가 쉽다. (개념 표는 [노트북 README](README.md#에이전트-환경-학습모드) 참조)

| 층위 | Codex에서의 위치 |
|---|---|
| **① 로컬 플러그인** | `~/.codex/config.toml` + `codex plugin` CLI, 플러그인 캐시 `~/.codex/.tmp/plugins` |
| **② 로컬 MCP / 마켓플레이스** | `~/.codex/.tmp/marketplaces`, `bundled-marketplaces` |
| **③ 계정·업무 연동** | Codex Desktop에서 연결한 계정·커넥터 (Google Workspace, GitHub, Notion 등) |

> ⚠️ `config.toml`에는 인증 정보가 포함될 수 있어 **이 저장소에 원문을 커밋하지 않는다.** 이 문서는 위치·구조만 기록한다.

---

## 2. 실제 설정 위치 (검증됨)

`~/.codex/` 하위 구조 (2026-07-13 확인):

```
~/.codex/
├─ config.toml                 # Codex 주 설정 (인증 포함 가능 → 비커밋)
├─ .codex-global-state.json    # 전역 상태
├─ .tmp/
│  ├─ plugins/                 # 설치 플러그인 캐시
│  ├─ marketplaces/            # 사용자 추가 마켓플레이스
│  └─ bundled-marketplaces/    # 내장 마켓플레이스
├─ .sandbox/                   # 샌드박스 실행 로그
└─ .sandbox-bin/               # codex 실행 바이너리(버전별)
```

---

## 3. 정리 원칙 (노트북 최적화 관점)

Codex도 로컬 플러그인이 늘수록 **컨텍스트 토큰과 캐시 용량**을 소모한다. 따라서 노트북에서는
**실제로 쓰는 기능만 활성화**하는 것을 원칙으로 한다.

**유지 대상 (실사용 핵심):**
- 개발: GitHub, 코드 리뷰, 기능 개발, 커밋, 보안 가이드
- 문서: 문서·PDF·스프레드시트·프레젠테이션 스킬
- 업무: Gmail, Google Drive, Google Calendar, Notion
- 조작·표현: 내장 브라우저, 화면 제어, 시각화

**정리 대상 (미사용·중복):**
- Claude 계열과 중복되는 문서/예제 스킬 묶음
- 노트북에서 안 쓰는 업무 커넥터(예: Asana, 사설 레지스트리 등)

> 구체적인 활성/비활성 개수는 Codex Desktop의 플러그인 화면 기준으로 그때그때 달라지므로,
> **"안 쓰는 것은 비활성화"** 규칙만 유지하고 수치는 도구 화면에서 직접 확인한다.

---

## 4. 관리 방법

```bash
codex plugin list          # 설치·활성 상태 확인
codex plugin disable <id>  # 미사용 플러그인 비활성 (컨텍스트 절약)
codex plugin enable  <id>  # 원복
```

- 계정 커넥터(③층위)는 **Codex Desktop의 연결 설정**에서만 관리된다. CLI로 못 지운다.
- 변경을 완전히 반영하려면 **Codex Desktop을 재시작**해 메모리에 올라온 도구 정의를 해제한다.
- 마켓플레이스 공유 캐시는 재설치·업데이트용이므로, **설치 목록에 없는 캐시 항목까지 수동 삭제하지 않는다.**

---

## 5. 도메인 격리

- 이 문서와 Codex는 **`~/.codex/` 만** 다룬다.
- Claude 설정(`.claude/`)·Antigravity 설정(`.agents/`)은 **건드리지 않는다.**
- 관련: [Claude 환경](claude-agent-environment.md) · [Antigravity 환경](antigravity-agent-environment.md)

> 보안 주의: 이 문서에는 토큰·API 키·머신 고유 경로를 포함하지 않는다. `config.toml` 등 인증 파일은 열람·커밋하지 않았다.
