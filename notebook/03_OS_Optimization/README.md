# ⚙️ OS 최적화 및 복구 (03_OS_Optimization)

이 섹션은 Windows OS의 튜닝, 오작동 교정, 환경 설정 복구와 관련된 스크립트 및 히스토리를 관리합니다.

## 🗂 구성 요소
* `scripts/`: 자동 설정 복구 및 시스템 튜닝 PowerShell 스크립트 모음
* `README.md`: OS 최적화/복구 내역 가이드 및 수동 조치 절차 기록

---

## 🛠 조치 및 유지보수 이력

### 1. 윈도우 시작 시 알림(Toast) 자동 꺼짐 현상 해결
* **해결 일자**: 2026-07-21
* **관찰 현상**: 노트북 부팅 혹은 사용자 로그인 시 시스템 알림(Toast Notifications) 허용 설정이 자동으로 꺼지는(비활성화) 현상.
* **원인 분석**:
  - Windows Push Notification 데이터베이스(`wpndatabase.db`) 손상으로 인한 상태 보존 실패.
  - 로그인 세션 생성 시 특정 환경 정책에 의한 전역 알림 레지스트리 초기화.
* **전역 알림 복구 조치**:
  1. **알림 DB 재빌드**: WPN 관련 서비스 중단 후 손상 의심 데이터베이스(`wpndatabase.db`) 백업 후 초기화하여 새 DB 생성을 유도.
  2. **레지스트리 보정**: `ToastEnabled`와 호환 알림 값을 수동 복구 스크립트에서 함께 보정.
* **관련 스크립트**:
  - [Fix-WindowsNotifications.ps1](scripts/Fix-WindowsNotifications.ps1): 알림 DB 초기화 및 알림 전역 활성화 레지스트리 적용.
  - [Register-NotificationStartupTask.ps1](scripts/Register-NotificationStartupTask.ps1): 퇴역된 레거시 자동 시작 등록기. 기본 실행은 변경 없이 중단하며, 명시적 `-InstallLegacyStartup`에서만 동작.
  - [Test-NotificationStartupVbs.ps1](scripts/Test-NotificationStartupVbs.ps1): 시작프로그램 VBScript의 인용 경로 문법을 무해한 명령으로 검증.

### 1-1. 시작프로그램 VBScript 컴파일 오류 교정 (2026-07-21)
* **관찰 현상**: `Fix-Notifications-Startup.vbs` 실행 시 Windows Script Host 800A0401 컴파일 오류 발생.
* **근본 원인**: PowerShell `-File` 경로를 감싼 큰따옴표가 VBScript 문자열 안에서 이스케이프되지 않아 문자열이 조기에 종료됨.
* **교정 및 재발 방지**: 등록 스크립트가 VBScript 규칙에 맞게 큰따옴표를 두 번(`""`) 출력하도록 수정하고, Windows Script Host 파싱 테스트를 추가.

### 1-2. 방해 금지 자동 활성화 근본 교정 (2026-07-21)
* **오진 정정**: 작업 표시줄의 `zZ` 아이콘은 전역 알림 해제가 아니라 Windows **방해 금지(Do Not Disturb)** 활성 상태입니다. 레지스트리 알림 값을 반복 설정하는 VBS는 이 상태를 치료하지 못합니다.
* **확정 원인**: 설정 > 시스템 > 알림에서 방해 금지가 켜져 있었고, 자동 규칙 중 `디스플레이 복제`, `게임`, `전체 화면 앱`, `Windows 기능 업데이트 후 첫 1시간`이 모두 활성화돼 있었습니다.
* **교정**: 방해 금지 본체와 위 자동 규칙 네 개를 모두 해제했습니다. Windows 공식 `readCloudDataSettings.exe`로 `windows.data.donotdisturb.quietmoment` 인스턴스 네 개가 모두 `isEnabled: false`임을 확인했습니다.
* **잘못된 우회책 퇴역**: `Fix-Notifications-Startup.vbs`는 Startup에서 제거해 `PC-Maintenance\Backups`로 이동했습니다. 등록 스크립트는 기본 실행 시 변경 없이 중단합니다.
* **Startup 보관 규칙**: 확장자가 `.vbs`가 아니어도 Startup 폴더의 파일은 로그인 때 열릴 수 있으므로, 백업 파일은 Startup 밖 `PC-Maintenance\Backups`에만 보관합니다.
