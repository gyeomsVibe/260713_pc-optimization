# 나만의 반려동물 캐릭터 만들기

Codex 반려동물 스프라이트를 빠르고 재현 가능하게 제작·교정·검증하기 위한 실전 가이드입니다. 이 문서는 실제 제작 중 발생한 캐릭터 불일치, 행별 크기 편차, 잘못된 바지색, 방향 오류, 투명 배경 잔여색과 반복 재작업을 예방합니다.

## 완료 기준

- 캐릭터의 얼굴·머리·상의·검은 바지·신발이 모든 프레임에서 동일합니다.
- 표준 동작 0~8행의 보이는 높이 편차가 8% 이내입니다.
- 각 동작이 실제로 움직이며 방향이 화면 좌표 기준과 일치합니다.
- v2 아틀라스는 1536×2288, RGBA, 8열×11행입니다.
- 투명 픽셀의 RGB 잔여값과 크로마키 테두리가 없습니다.
- `idle` 행의 `r0c6` 중립 프레임을 보존하고 `r0c7`만 비웁니다.
- 설치 전후 공식 검증 결과와 SHA-256 해시가 일치합니다.

## 가장 빠른 제작 순서

1. 기준 이미지와 파일명을 확정하고 SHA-256 목록을 남깁니다.
2. 얼굴, 머리, 검은 소매·밝은 회색 몸판, 검은 바지, 검은 운동화를 정체성 계약으로 고정합니다.
3. 금지 요소를 명시합니다. 이 캐릭터는 후드와 지퍼 아우터를 사용하지 않습니다.
4. 아틀라스 전체를 반복 생성하지 말고 문제가 있는 동작 행만 교체합니다.
5. 한 행의 모든 프레임에 동일한 배율을 적용해 보이는 높이를 맞춥니다.
6. 최종 합성 후 디스필(Despill)은 단 한 번만 수행합니다.
7. 구조·크기·동작·색상·방향을 검증하고 접촉 시트로 시각 확인합니다.
8. 기존 설치본을 백업한 뒤 설치하고 설치 위치에서 다시 검증합니다.

## 도구 사용 예시

```powershell
python custom-pet-guide/scripts/replace_atlas_rows.py spritesheet.webp `
  --output repaired.png --report row-report.json `
  --replace running-left=frames/run-left `
  --replace jumping=frames/jump

python custom-pet-guide/scripts/normalize_atlas_scale.py repaired.png `
  --output normalized.png --rows 0 1 2 3 4 5 6 7 8

python custom-pet-guide/scripts/clear_unused_cells.py normalized.png `
  --output cleaned.png --webp-output spritesheet.webp

python custom-pet-guide/scripts/validate_pet_package.py package `
  --report validation.json
```

공식 `hatch-pet` 검증기도 함께 실행해야 합니다. 보조 검증기만 통과했다고 설치하지 않습니다.

## 폴더 구성

- `scripts/`: 행 교체, 크기 정규화, 미사용 칸 정리, 패키지 검증
- `tests/`: 검증기 회귀 테스트
- `templates/`: 개인 경로와 이미지를 제외한 요청·메타데이터 예시
- `CHECKLIST.md`: 제작·설치 전 최종 점검표
- `FAILURE_PLAYBOOK.md`: 실제 실패 원인과 재발 방지책

## 개인정보와 저장소 위생

개인 사진, 생성 원본, 절대 경로, 사용자명, 설치된 반려동물 패키지는 커밋하지 않습니다. 저장소에는 재현 절차, 범용 도구, 익명 템플릿만 포함합니다.
