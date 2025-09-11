### 현재 `auto-labeler.yml` 라벨링 규칙 적용 패턴 요약
- **브랜치명 기준** (`.github/pr-lint/labeling-rules.json > branch_patterns.rules`)
  - `^feature/`, `^feat/` → `type:feature`
  - `^fix/`, `^bugfix/` → `type:fix`
  - `^hotfix/` → `type:hotfix`, `priority:high`
  - `^release/`, `^rel/` → `type:release`, `versioning:semver`
  - `^sync/`, `^merge/` → `sync:release→develop`

- **PR 제목 기준** (`title_patterns`)
  - Conventional Commits
    - `^feat(...)?:` → `type:feature`
    - `^fix(...)?:` → `type:fix`
    - `^hotfix(...)?:` → `type:hotfix`, `priority:high`
    - 그 외 `refactor|perf|test|docs|chore`도 각각 `type:*` 매핑
  - 한글/자연어 패턴
    - `^(기능|feature)` → `type:feature`
    - `^(수정|fix|버그)` → `type:fix`
    - `^(긴급|핫픽스|hotfix)` → `type:hotfix`, `priority:high`
    - `^(릴리스|release|배포)` → `type:release`
  - 우선순위 키워드
    - `(긴급|urgent|critical|hotfix|중요|important)` → `priority:high`
  - 작업 크기 키워드
    - `minor|작은|소규모|tiny` → `size/XS`
    - `small|작음|간단` → `size/S`
    - `medium|보통|중간` → `size/M`
    - `large|큼|대규모` → `size/L`
    - `huge|매우|거대|massive` → `size/XL`

- **PR 본문 기준** (`content_analysis`)
  - 템플릿/키워드 감지
    - “새로운 기능 추가” 등 → `type:feature`
    - “버그 수정” 등 → `type:fix`
    - “긴급 핫픽스” 등 → `type:hotfix`, `priority:high`
    - “릴리스 (Main)”/“릴리스” 등 → `type:release`
    - “릴리스 백머지” 등 → `sync:release→develop`
  - 브레이킹 체인지 감지
    - `breaking change`, `!:`, `major`, `BREAKING` 포함 → `versioning:semver`

- **기타 동작**
  - 중복 라벨은 Set으로 제거 후 적용.
  - 규칙 파일이 없으면 스킵.
  - PR 번호/브랜치/제목/본문을 기준으로 위 규칙을 모두 적용해 라벨 부여.

예시
- 브랜치 `feature/user-auth`, 제목 `feat(api): add login`, 본문에 “새로운 기능 추가” 포함
  - 최종 라벨: `type:feature` (중복 제거 후 1개)