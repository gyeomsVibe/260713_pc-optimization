# AI 에이전트 바이브코딩 전용 듀얼 그래픽카드 공존 최적화 설계서

> [!NOTE]
> 본 설계서는 AI 에이전트(Antigravity, Claude Code, Codex)를 활용하여 대규모 코딩을 수행하는 환경에 맞춰져 있습니다. 구세대 외장 GPU(GTX 1660 Ti)의 리소스(VRAM 6GB)가 단순 윈도우 UI나 잡다한 백그라운드 툴에 낭비되는 것을 차단하고, 오직 **개발 환경 가속(IDE 렌더링 및 AI 로컬 CUDA 연산)**에만 집중하도록 내/외장 그래픽의 공존 배분을 설계했습니다.

---

## 1. 하드웨어 현황 및 공존계(Co-existence)의 목적

- **장착 장치**: `Intel UHD Graphics 630` (내장) + `NVIDIA GeForce GTX 1660 Ti` (외장)
- **공존의 필요성**: 
  - GTX 1660 Ti는 AI 가속 텐서 코어(Tensor Core)가 없는 구세대 칩셋입니다. 따라서 AI 에이전트 구동 및 에디터 화면 가속 시 VRAM(비디오 메모리) 관리가 매우 엄격해야 합니다.
  - 가벼운 앱들이 외장 GPU를 점유하면 VRAM 부족으로 인해 에디터 스크롤 지연, 터미널 가속 렉, 프로세스 정체 병목이 발생합니다.
  - 따라서, **내장 GPU가 2D 데스크톱 화면과 일반 유틸리티를 전담**하게 하고, **외장 GPU의 그래픽 가속과 CUDA 코어는 오직 개발 환경(IDE, 터미널 가속, AI 에이전트 CUDA)이 독점**하게 유기적으로 분담시킵니다.

---

## 2. 프로세스별 역할 분담 설계 (Role Allocation)

| 프로세스 명칭 | 권장 그래픽 프로세서 | 최적화 이유 |
| :--- | :--- | :--- |
| **Windows 데스크톱 (dwm.exe, explorer.exe)** | 💻 **내장 그래픽** (Intel) | 기본 화면 렌더링은 내장 GPU에 맡겨 외장 GPU의 기초 오버헤드를 제로화합니다. |
| **Antigravity IDE / VS Code (code.exe)** | 🚀 **외장 그래픽** (NVIDIA) | AI 코드 렌더링, 코드 렌즈, 시각적 디프 가속을 위해 외장 성능을 온전히 활용합니다. |
| **Python / AI 에이전트 가속 (python.exe)** | 🚀 **외장 그래픽** (NVIDIA) | 에이전트가 로컬 연산이나 데이터 분석 시 외장의 CUDA 가속을 쓰도록 연결합니다. |
| **MSIGamingCenter / Dragon Center** | 💻 **내장 그래픽** (Intel) | 단순 하드웨어 모니터링 앱이 외장 VRAM을 차지하는 것을 방지합니다. |
| **Intel Graphics Command Center (IGCC)** | 💻 **내장 그래픽** (Intel) | 인텔 설정 앱이 외장에 탑재되는 비효율 설정을 강제 해제합니다. |
| **WebView2 / 백그라운드 브라우저** | 💻 **내장 그래픽** (Intel) | 슬랙, 디스코드, 웹뷰 등은 내장 GPU 가속으로 격리하여 외장 부하를 낮춥니다. |

---

## 3. 초보 개발자(윤겸스님)를 위한 정밀 설정 가이드

"모르는 걸 모르는" 초보자도 마우스 클릭 몇 번으로 쉽게 완벽한 공존계를 셋업하는 가이드입니다.

### 🛠️ 1단계: MUX 스위치 MSHybrid(하이브리드) 모드로 원복
1. 노트북 제어 프로그램인 **MSI Dragon Center**를 실행합니다.
2. `General Settings` 혹은 `User Scenario` 메뉴로 이동합니다.
3. GPU Switch 설정을 `Discrete GPU`에서 **'MSHybrid (하이브리드 모드)'**로 변경한 후 노트북을 재부팅합니다.
   - *이 설정을 해야만 디스플레이의 출력을 내장이 담당하고, 필요할 때만 외장을 빌려 쓰는 하이브리드 공존 모드가 활성화됩니다.*

### 🛠️ 2단계: Windows 그래픽 전용 배분 설정 (핵심)
1. 바탕 화면 빈 곳 우클릭 ➔ **디스플레이 설정** ➔ 맨 아래 **그래픽 설정(Graphics settings)**을 클릭합니다.
2. **[기본 앱 등록 및 내장 고정]**
   - 아래 경로를 찾아보기(Browse)하여 추가한 뒤 **옵션** ➔ **'절전(Intel UHD 630)'**으로 저장합니다.
     * `C:\Program Files (x86)\Dragon Center\Dragon Center.exe`
     * `C:\Program Files\WindowsApps\...\IGCC.exe` (인텔 그래픽 센터)
     * `C:\Program Files (x86)\Microsoft\EdgeWebView\...\msedgewebview2.exe`
3. **[개발 IDE 외장 고정]**
   - **Antigravity IDE** (또는 VS Code 실행 파일 `code.exe`)를 추가한 뒤 **옵션** ➔ **'고성능(NVIDIA GeForce GTX 1660 Ti)'**으로 저장합니다.
     * *주의: 이 설정을 해야 코딩 텍스트 스크롤 및 AI 어시스턴트 렌더링이 번개처럼 빨라집니다.*

### 🛠️ 3단계: NVIDIA 제어판 드라이버 설정 조율
1. 바탕 화면 우클릭 ➔ **NVIDIA 제어판**을 실행합니다.
2. **3D 설정 관리** 메뉴로 이동합니다.
3. **전역 설정(Global Settings)** 탭:
   - **기본 그래픽 프로세서**: **'통합 그래픽 (Intel)'**으로 설정합니다. (일반 앱의 외장 점유 원천 차단)
4. **프로그램 설정(Program Settings)** 탭:
   - `추가` 버튼을 눌러 **Antigravity IDE** (또는 VS Code)와 **Python**을 등록합니다.
   - 이 프로그램들의 기본 그래픽 프로세서를 **'고성능 NVIDIA 프로세서'**로 개별 강제 지정합니다.
   - **전원 관리 옵션**: **'최고 성능 선호'**로 두어, 코딩 실행 순간의 외장 GPU 반응 지연을 방지합니다.
5. 적용을 누르고 설정을 완료합니다.
