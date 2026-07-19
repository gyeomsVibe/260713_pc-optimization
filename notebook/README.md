# 260713 Notebook PC 환경 최적화

MSI GL75 9SDK 노트북의 발열·성능·개발 도구·AI 에이전트 환경을 안전하게
정리한 작업대입니다. 모든 적용은 `조사 → 계획 → 백업/롤백 준비 → 최소 변경 → 검증`
순서로 진행합니다.

## 문서 구조

| 영역 | 내용 | 바로가기 |
|---|---|---|
| 프로젝트 관리 | 전체 최적화 내역, 적용 결과, 롤백 절차 | [00_Project_Management](00_Project_Management/README.md) |
| 디스크 최적화 | 저장소 정리와 IDE 경량화 기록 | [01_Disk_Optimization](01_Disk_Optimization/) |
| 하드웨어 최적화 | GPU·전원·발열 분석 자료 | [02_Hardware_Optimization](02_Hardware_Optimization/) |
| 에이전트 환경 | Claude Code·Codex·Antigravity 전용 설정 문서 | [플랫폼 최적화 저장소](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization) |

## AI 에이전트 환경

세 에이전트는 비슷한 기능을 제공하지만, 설정 위치와 권한 모델이 다릅니다.
한 에이전트는 다른 에이전트의 설정을 수정하지 않습니다.

| 에이전트 | 전용 문서 | 관리 범위 |
|---|---|---|
| Claude Code | [환경 기록](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization/blob/main/claude/environment-notebook.md) | `.claude/`, 로컬 플러그인·MCP, 계정 커넥터 |
| Codex | [환경 기록](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization/blob/main/codex/environment-notebook.md) | `~/.codex/`, Codex 플러그인, Desktop 연동 |
| Antigravity | [환경 기록](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization/blob/main/antigravity/environment-notebook.md) | `.agents/`, IDE 확장, 로컬 MCP |

공통 규칙 정본과 동기화 방법은
[글로벌 룰 영문 정본](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization/tree/main/shared/global-rules)에서 관리하고,
설계 근거와 적용 결과는
[글로벌 룰 작성 계획서](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization/blob/main/shared/global-rules-writing-plan.md)에 기록합니다.

## 안전 원칙

- 인증 정보·개인정보·머신 고유 경로는 저장소에 기록하지 않습니다.
- 삭제·배포·권한 변경·외부 서비스 호출은 영향과 복구 방법을 확인한 뒤 수행합니다.
- 변경 뒤에는 해당 도구의 상태 확인과 롤백 경로를 함께 검증합니다.
