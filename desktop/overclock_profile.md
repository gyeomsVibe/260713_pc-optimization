# 🖥️ 데스크톱 메인보드 및 오버클럭 설정 프로필 (Overclocking Profile)

이 문서는 데스크톱 PC 메인보드의 설정 정보, 현재 BIOS 상태의 공식 최신 버전 대조 결과, 외부 바이오스 파일 검증 내역, CMOS 배터리 교체 현황 및 향후 수동 오버클럭 적용을 위한 가이드를 정리한 설정 동기화 프로필입니다.

---

## 📋 1. 시스템 및 메인보드 기본 사양

| 분류 | 세부 항목 | 현재 설정값 |
|---|---|---|
| **메인보드** | 제조사 | ASRock |
| | 모델명 | **Fatal1ty Z170 Gaming K6** |
| | BIOS 버전 | **P7.50** (배포일: 2018-10-18) |
| **CPU** | 프로세서 모델 | Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz |
| | 작동 클럭 | 4008 MHz (4.0 GHz Base / 4.2 GHz Boost) |
| | 베이스 클럭 (BCLK) | 100 MHz |
| | 코어 / 스레드 수 | 4 Cores / 8 Threads |
| | L3 캐시 용량 | 8 MB |
| **오버클럭** | 현재 설정 상태 | **순정 (Stock / Non-OC)** |
| **CMOS 배터리** | 배터리 상태 | **교체 완료 (CR2032 / 정상 수명)** |

---

## 🔍 2. BIOS 체크 및 외부 파일 진단 결과

### ① 공식 홈페이지 최신 버전 대조
- **현재 메인보드 BIOS**: `P7.50` (2018-10-18 배포)
- **공식 지원 최신 BIOS**: `7.50` (2018-10-26 배포)
- **결과**: 현재 시스템은 제조사에서 정식 배포한 **최신 버전의 BIOS**를 이미 사용하고 있습니다. 추가적인 신규 업데이트는 불필요합니다.

### ② F:\BIOS 내 준비된 파일 검증 (`E17E5IMS.106`)
- **분석 결과**: 해당 파일은 **MSI 노트북 MS-17E5 (GL75 9SE / GL75 9SEK / GL75 9SD / GL75 9SDK)** 시리즈 전용 공식 BIOS 펌웨어 파일입니다.
- **🚨 호환성 위험 경고**: ASRock Fatal1ty Z170 Gaming K6 메인보드에 타사 노트북용 바이오스 파일(`E17E5IMS.106`)을 주입(Flashing)할 경우, 바이오스 EEPROM이 손상되어 **시스템이 영구 부팅 불가(벽돌) 상태**가 됩니다. 
- **조치 사항**: 안전을 위해 실제 플래싱(업데이트) 작업을 전면 차단하고 동기화 대상에서 제외하였습니다.

### ③ CMOS 배터리 점검 결과
- **진단**: 기존에 메인보드에 장착되어 있던 배터리가 수명을 다해 전원 차단 시 날짜/시각 정보가 유실되고 부팅 순서가 지워지던 현상이 있었습니다.
- **결과**: **CR2032 규격 배터리로의 하드웨어 교체가 수동으로 완료**되었습니다. 이로써 메인보드의 RTC 전원 공급 및 설정값 캐싱 기능이 완전 복구되었습니다.

---

## 🛠️ 3. ASRock Z170 Gaming K6 오버클럭 튜닝 매뉴얼

Intel K-시리즈 프로세서(i7-6700K)와 Z170 칩셋 보드는 오버클럭을 정식 지원합니다. 향후 BIOS(UEFI)에 진입하여 수동 오버클럭 프로필을 적용하고자 할 때 사용할 수 있는 가이드라인입니다.

### ① 오버클럭 핵심 설정값 (안정화 추천 프로필)
> [!IMPORTANT]
> 오버클럭 적용 전, 고성능 CPU 쿨러(2열 이상 수냉 또는 대장급 공랭 쿨러)가 장착되어 있는지 반드시 확인하세요.

| BIOS 메뉴 경로 | 상세 옵션 명칭 | 권장 설정값 | 설명 |
|---|---|---|---|
| **OC Tweaker\CPU Configuration** | CPU Ratio | **Apply All Cores** | 모든 코어에 동일 배수 적용 |
| | All Core | **45** | 4.5 GHz 타겟 동작 클럭 설정 |
| | CPU Cache Ratio | **41** | 캐시 속도 조절 (CPU 배수보다 3~4 낮게 설정) |
| | Minimum CPU Cache Ratio | **41** | 최저 캐시 속도 고정 |
| | Intel SpeedStep | **Enabled** | Idle 시 클럭 강하 허용 |
| | Intel Turbo Boost | **Enabled** | 터보 부스트 활성화 |
| **OC Tweaker\DRAM Configuration** | Load XMP Setting | **XMP 2.0 Profile 1** | 메모리 XMP 프로필 로드 (해당하는 경우) |
| **OC Tweaker\Voltage Configuration** | CPU Vcore Voltage | **Fixed Mode** | 전압 고정 모드 |
| | Fixed Voltage(V) | **1.320V ~ 1.350V** | 4.5GHz 안정화를 위한 전압 값 |
| | CPU Load-Line Calibration | **Level 2** (또는 Level 1) | 부하 시 전압 강하(Vdroop) 보정 |

### ② BIOS 상에서 설정 프로필 저장 및 복구
1. **프로필 저장 (Save to Disk)**:
   - BIOS 진입 후 `OC Tweaker` 메뉴 하단의 `Save User UEFI Setup Profile to Disk` 선택.
   - FAT32 포맷으로 포맷된 USB 드라이브를 선택하고 파일 저장 (확장자 `.bin` 파일 생성).
2. **프로필 복구 (Load from Disk)**:
   - BIOS의 `OC Tweaker` 메뉴 하단의 `Load User UEFI Setup Profile from Disk` 선택.
   - 저장했던 USB 내 `.bin` 프로필 파일을 선택하여 한 번에 설정 복구 가능.
   > [!WARNING]
   > BIOS 버전을 업데이트하면 기존 버전에 맞춰 저장된 `.bin` 프로필은 로드할 수 없게 되므로, 설정값을 텍스트로 미리 받아두는 것이 안전합니다.
