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
| OS 최적화 | Windows 알림 복구 및 OS 튜닝 기록 | [03_OS_Optimization](03_OS_Optimization/) |
| 에이전트 환경 | Claude Code·Codex·Antigravity 전용 설정 문서 | [플랫폼 최적화 저장소](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization) |

## AI 에이전트 환경

에이전트별 환경 설정·글로벌 룰은 **플랫폼 저장소에서 단일 관리**합니다(위 문서 구조 표 참조). 본 저장소는 PC 하드웨어·전원·디스크·OS 최적화만 다룹니다.

→ [gyeomsVibe/260718_agentic-ai-platform-optimization](https://github.com/gyeomsVibe/260718_agentic-ai-platform-optimization)

## 안전 원칙

- 인증 정보·개인정보·머신 고유 경로는 저장소에 기록하지 않습니다.
- 삭제·배포·권한 변경·외부 서비스 호출은 영향과 복구 방법을 확인한 뒤 수행합니다.
- 변경 뒤에는 해당 도구의 상태 확인과 롤백 경로를 함께 검증합니다.
