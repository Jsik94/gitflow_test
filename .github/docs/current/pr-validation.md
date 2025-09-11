### 현재 `pr-validation.yml` 동작 요약
- **트리거**: `pull_request` 이벤트(`opened`, `edited`, `synchronize`, `reopened`)
- **검사 대상**: PR “제목”만 검사 (본문 검증 없음)
- **차단 조건**: 제목이 허용 패턴에 “맞지 않으면” 코멘트 남기고 워크플로우 실패 처리(차단)

### 허용 제목 패턴
- **Conventional Commits (scope 선택)**
  - `type(scope): summary`
  - `type: summary`
  - 허용 type: `feat|fix|refactor|perf|test|docs|chore`
  - 정규식: `^(feat|fix|refactor|perf|test|docs|chore)(\([^\)]+\))?:\s.+$`
- **Hotfix 전용**
  - `hotfix: summary`
  - 정규식: `^hotfix:\s.+$`
- **Release 전용**
  - `release: v1.2.3` (간소 지원: 현재는 텍스트도 허용)
  - 정규식(현상): `^release:\s.+$` 
  - 원하면 버전 전용으로 강화 가능: `^release:\sv?\d+\.\d+\.\d+(-[\w\.+]+)?$`

### 실패 시 동작
- PR에 위반 안내 코멘트 작성
- 워크플로우 `fail`로 처리 → PR 체크가 빨간 불(머지 차단 정책에 따름)

### 예시
- 통과: `feat(api): 사용자 조회 API 추가`
- 통과: `fix: 로그인 토큰 검증 수정`
- 통과: `hotfix: 보안 취약점 긴급 패치`
- 통과: `release: v1.2.3`
- 차단: `add new feature`(type 형식 아님)
- 차단: `feat add login`(콜론/형식 불일치)
- 차단: `feat(): 내용`(빈 scope)

### 커스터마이징 포인트
- 허용 type 추가/삭제: 정규식의 type 그룹 수정
- `release` 패턴 엄격화: 버전 전용 정규식으로 교체 가능
- 메시지/가이드 문구: 스크립트 내 코멘트 본문 수정 가능

필요하면 `release`를 버전 표기에만 통과하도록 바로 강화해 드릴게요.