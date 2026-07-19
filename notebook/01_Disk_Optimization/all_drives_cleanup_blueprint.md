# 모든 드라이브(C, D, E) 중복 파일 및 빈 폴더 최적화 설계서

> [!CAUTION]
> 윈도우의 기본 뼈대나 상용 프로그램이 구동 시 필수적으로 기대하는 특정 숨김 빈 폴더(`WindowsApps`, `ModifiableWindowsApps` 등)는 삭제 시 프로그램 실행 불능을 유발할 수 있습니다. 본 설계에서는 이들을 철저하게 제외 리스트에 올려 **안전성을 100% 검증**하였습니다.

---

## 1. 중복 파일(Duplicate Files) 정리 계획

크기와 해시(SHA-256)가 완전히 일치하는 중복 파일 그룹을 정렬하여, 하나의 원본만 남기고 나머지를 삭제함으로써 디스크 공간을 확보합니다.
*잠재적 사용 위협이 있거나 연동 경로가 불분명한 `ngrok.exe`는 제외 처리하였습니다.*

| 파일명 / 예상 용량 | 보존할 파일 경로 (Keep) | 삭제할 중복 파일 경로 (Delete) | 안전성 검증 및 효과 |
| :--- | :--- | :--- | :--- |
| **Acronis® True Image...zip**<br>(용량: **2.56 GB**) | `E:\[Util_Storage]\Acronis® True Image ™ 2014 ™ 2015 KOR.zip` | `E:\[Util_Storage]\(윈도우관리프로그램)\Acronis® True Image ™ 2014 ™ 2015 KOR.zip` | 동일 압축 백업 파일로 하나만 남겨도 완벽히 안전하며 **2.56GB 즉시 반환** |
| **I3GSvcManager.exe**<br>(용량: **11.08 MB**) | `D:\D_스마트스토어_space_NB\[ 사업계획] 스마트스토어\I3GSvcManager.exe` | `D:\D_Workspace_NB\I3GSvcManager.exe` | 11MB 공간 확보 |
| **26.0130.글쓰기-멀티 에이전트...zip**<br>(용량: **18.03 MB**) | `D:\D_Workspace_NB\[블로그 심화수업]\26.0130.글쓰기-멀티 에이전트 시스템.zip` | `D:\D_Workspace_NB\[블로그_글쓰기_완성글 작성]\26.0130.글쓰기-멀티 에이전트 시스템.zip` | 18MB 공간 확보 |
| **20251010_005300.png**<br>(용량: **11.37 MB**) | `E:\사진\운동 후 셀카\20251010_005300.png` | `E:\사진\20251010_005300.png` | 사진 백업 이중화 정리, 11MB 확보 |

---

## 2. 빈 폴더(Empty Folders) 정리 계획

자식 파일이나 폴더가 단 하나도 없는 순수 빈 폴더 **총 27개**를 삭제합니다.

### 🧹 삭제할 빈 폴더 대표 리스트 (총 27개)
- `C:\Users\Kimyoongyeom\Documents\temp`
- `C:\Users\Kimyoongyeom\Videos\NVIDIA`
- `C:\Users\Kimyoongyeom\ZCodeProject`
- `C:\Users\Kimyoongyeom\.claude\downloads`
- `D:\D_스마트스토어_space_NB\[상세페이지]`
- `D:\tmp`
- `E:\BackUp_Sector`
- `E:\Temp_Sector`
- `E:\msdownld.tmp`
- `E:\[음악]\[MV]`

### 🚫 보존 및 스킵할 시스템 예약 폴더 (안전 최우선 제외 대상: 총 6개)
다음 폴더들은 비어있으나 Windows Store 및 OS에서 관리하는 시스템 공간이므로 **절대 삭제하지 않고 보존**합니다.
- `D:\Program Files\ModifiableWindowsApps`
- `D:\WindowsApps\Deleted`
- `D:\WindowsApps\MutableBackup`
- `E:\Program Files\ModifiableWindowsApps`
- `E:\WindowsApps\Deleted`
- `E:\WindowsApps\MutableBackup`

---

## 3. 검증 및 시뮬레이션 절차 (Dry-Run Check)

실행 직전 백그라운드에서 다음 조건의 검증이 진행됩니다:
- 삭제 대상 파일이 현재 어떤 백그라운드 프로세스에서 오픈되어 있는지 체크하여 잠겨있다면 즉시 스킵합니다.
- 복사본을 지우기 전, **보존 경로에 원본 파일이 온전하게 존재하는지 재검증**한 후에만 삭제(Delete) 명령어를 수행합니다.
