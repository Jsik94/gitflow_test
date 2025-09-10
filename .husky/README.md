# 🐕 Husky 커밋린트 설정 가이드

이 디렉토리는 Git hooks를 통한 커밋 검증 시스템을 포함하고 있습니다. 브랜치별로 다른 커밋 메시지 규칙을 적용하여 코드 품질과 일관성을 보장합니다.

## 📌 기본 커밋 메시지 형식

모든 브랜치에서 다음 형식을 따라야 합니다:

```
type(scope): summary [TICKET]
```

### 📋 구성 요소 설명

| 구성 요소 | 설명 | 필수 여부 | 예시 |
|-----------|------|-----------|------|
| **type** | 커밋 유형 | ✅ 필수 | `feat`, `fix`, `docs` |
| **scope** | 앱/도메인/패키지명 | ✅ 필수 | `user-api`, `auth-service`, `web-admin` |
| **summary** | 간결한 설명 | ✅ 필수 | `사용자 로그인 기능 추가` |
| **[TICKET]** | Jira 티켓 번호 | 🔄 브랜치별 | `[PROJ-123]`, `[PROJ-123][PROJ-456]` |

## 📁 디렉토리 구조

```
.husky/
├── _/                           # husky helper (자동 생성)
├── helpers/
│   └── branch.sh               # 브랜치 감지 및 티켓 검증 공통함수
├── branch-rules/
│   ├── feature/
│   │   └── commit-msg.sh       # Feature 브랜치 규칙 (티켓 선택)
│   ├── hotfix/
│   │   └── commit-msg.sh       # Hotfix 브랜치 규칙 (티켓 필수)
│   ├── release/
│   │   └── commit-msg.sh       # Release 브랜치 규칙 (티켓 필수)
│   ├── develop/
│   │   └── commit-msg.sh       # Develop 브랜치 규칙 (티켓 필수)
│   └── main/
│       └── commit-msg.sh       # Main 브랜치 규칙 (티켓 필수)
├── pre-commit                  # Pre-commit hook
├── commit-msg                  # Commit-msg hook (메인)
└── README.md                   # 이 파일
```

## 🎯 Type 목록

| type | 사용 시점 | 예시 |
|------|-----------|------|
| `feat` | 새로운 기능 추가 | `feat(user-api): 소셜 로그인 기능 추가` |
| `fix` | 버그 수정 | `fix(auth-service): JWT 토큰 만료 오류 수정` |
| `refactor` | 코드 리팩토링 (기능 변화 없음) | `refactor(shared-lib): 유틸리티 함수 구조 개선` |
| `perf` | 성능 개선 | `perf(api): 데이터베이스 쿼리 최적화` |
| `test` | 테스트 코드 추가/수정 | `test(user-api): 회원가입 API 단위 테스트 추가` |
| `docs` | 문서 관련 변경 | `docs(readme): API 엔드포인트 문서 업데이트` |
| `chore` | 빌드/도구/환경 설정 변경, 유지보수성 작업 | `chore(webpack): 빌드 설정 최적화` |

## 🎯 Scope 작성 규칙

- **반드시 작성해야 함** (빈 값 불가)
- 해당 변경이 일어난 **앱/도메인/패키지명**을 입력
- **kebab-case** 형식 권장

### 📋 Scope 예시

| 분류 | Scope 예시 | 설명 |
|------|-----------|------|
| **API 서비스** | `user-api`, `auth-service`, `payment-api` | 백엔드 API 서비스 |
| **프론트엔드** | `web-admin`, `mobile-app`, `dashboard` | 프론트엔드 앱 |
| **공통 라이브러리** | `shared-lib`, `utils`, `components` | 공유 라이브러리 |
| **인프라/도구** | `build`, `docker`, `ci`, `webpack` | 빌드/배포 관련 |
| **문서** | `readme`, `api-docs`, `changelog` | 문서 관련 |

## 📝 Summary 작성 규칙

- **한 줄 요약** (명령문 형태 권장)
- **최대 100자 이내**
- **한국어/영어 모두 가능**
- **마침표(.) 붙이지 않음**

### ✅ Summary 예시

```bash
# ✅ 좋은 예시
feat(user-api): 사용자 프로필 이미지 업로드 기능 추가
fix(auth-service): 로그인 시 토큰 검증 로직 오류 수정
refactor(shared-lib): HTTP 클라이언트 모듈 구조 개선

# ❌ 나쁜 예시
feat(user-api): 기능을 추가했습니다.  # 마침표 사용
fix(): 버그 수정  # scope 누락
feat(user-api): 이 커밋은 사용자 API에 새로운 기능을 추가하는데 그 기능은 프로필 이미지를 업로드할 수 있는 기능입니다.  # 너무 김
```

## 🎫 [TICKET] 작성 규칙

- **반드시 메시지 끝에 기입**
- **Jira 티켓 번호 형식**: `[PROJ-123]`
- **여러 개 가능**: `[PROJ-123][PROJ-456]`
- **브랜치별 요구사항이 다름** (아래 표 참고)

### 📋 브랜치별 티켓 요구사항

| 브랜치 | 티켓 [TICKET] | 설명 |
|--------|---------------|------|
| `feature/*` | **선택 (권장)** | 기능 개발 시 권장하지만 필수 아님 |
| `hotfix/*` | **필수** | 긴급 수정은 반드시 티켓 필요 |
| `release/*` | **필수** | 릴리즈 관련 작업은 추적 필요 |
| `develop` | **필수** | 통합 브랜치는 추적성 필요 (원칙적으로 직접 커밋 금지) |
| `main` | **필수** | 프로덕션 브랜치는 모든 변경사항 추적 (원칙적으로 직접 커밋 금지) |

## 🌿 브랜치별 커밋 규칙 상세

### 📋 Feature 브랜치 (`feature/*`, `feat/*`)

**특징**: 가장 유연한 규칙, 모든 개발 작업 허용

- **허용 타입**: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`
- **티켓 요구사항**: 선택 (권장)
- **권장**: `feat` 타입 사용

```bash
# ✅ 올바른 예시
feat(user-api): 사용자 로그인 기능 추가 [PROJ-123]
fix(auth-service): 인증 토큰 갱신 로직 수정
refactor(shared-lib): 공통 유틸리티 함수 개선 [PROJ-456]
test(user-api): 회원가입 API 테스트 케이스 추가

# ❌ 잘못된 예시
feat: 로그인 기능 추가  # scope 누락
feat(user-api) 로그인 기능 추가  # 콜론 누락
release(v1.0.0): 버전 릴리즈  # 허용되지 않는 타입
```

### 🚨 Hotfix 브랜치 (`hotfix/*`)

**특징**: 가장 엄격한 규칙, 긴급 수정만 허용

- **허용 타입**: `fix`, `docs` (제한적)
- **티켓 요구사항**: 필수
- **목적**: 프로덕션 긴급 버그 수정

```bash
# ✅ 올바른 예시
fix(payment): 결제 프로세스 크리티컬 버그 수정 [PROJ-123]
fix(auth-service): 보안 취약점 긴급 패치 [PROJ-456][PROJ-789]
docs(readme): 긴급 보안 패치 관련 문서 업데이트 [PROJ-123]

# ❌ 잘못된 예시
feat(payment): 새 결제 방식 추가 [PROJ-123]  # feat 타입 불허
fix(payment): 결제 버그 수정  # 티켓 누락
refactor(utils): 코드 정리 [PROJ-123]  # refactor 타입 불허
```

### 🚀 Release 브랜치 (`release/*`)

**특징**: 배포 준비 작업만 허용

- **허용 타입**: `fix`, `docs`, `chore`, `test`
- **티켓 요구사항**: 필수
- **목적**: 릴리즈 준비 및 버전 관리

```bash
# ✅ 올바른 예시
fix(build): 빌드 스크립트 오류 수정 [PROJ-123]
docs(changelog): v1.2.0 변경사항 문서화 [PROJ-456]
chore(version): package.json 버전 업데이트 [PROJ-789]
test(e2e): 릴리즈 검증용 E2E 테스트 추가 [PROJ-123]

# ❌ 잘못된 예시
feat(user): 새 기능 추가 [PROJ-123]  # feat 타입 불허
fix(build): 빌드 수정  # 티켓 누락
refactor(api): API 구조 개선 [PROJ-123]  # refactor 타입 불허
```

### 🔀 Develop 브랜치 (`develop`, `development`)

**특징**: 관대한 규칙, 모든 유형 허용

- **허용 타입**: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`
- **티켓 요구사항**: 필수
- **Merge 커밋**: 자동으로 허용 (티켓 요구사항 예외)
- **주의**: 원칙적으로 직접 커밋 금지, PR 머지 전용

```bash
# ✅ 올바른 예시
feat(user-api): 사용자 관리 기능 추가 [PROJ-123]
fix(auth-service): API 인증 오류 수정 [PROJ-456]
refactor(shared-lib): 유틸리티 함수 개선 [PROJ-789]
Merge branch 'feature/login' into develop  # 티켓 불필요

# ❌ 잘못된 예시
feat(user-api): 사용자 기능 추가  # 티켓 누락
fix(): 버그 수정 [PROJ-123]  # scope 누락
```

### 🏛️ Main 브랜치 (`main`, `master`)

**특징**: 가장 엄격한 규칙, 프로덕션 코드만

- **허용 타입**: `fix`, `docs` (매우 제한적)
- **티켓 요구사항**: 필수
- **Merge 제한**: `release/*`, `hotfix/*` 브랜치만 병합 가능
- **주의**: 원칙적으로 직접 커밋 금지, PR 머지 전용

```bash
# ✅ 올바른 예시
fix(security): 보안 취약점 긴급 패치 [PROJ-123]
docs(readme): 긴급 보안 패치 관련 문서 업데이트 [PROJ-456]
Merge branch 'release/v1.2.0' into main  # 티켓 불필요
Merge branch 'hotfix/critical-bug' into main  # 티켓 불필요

# ❌ 잘못된 예시
feat(user): 새 기능 추가 [PROJ-123]  # feat 타입 불허
fix(security): 보안 패치  # 티켓 누락
Merge branch 'feature/login' into main  # feature 브랜치 병합 불허
```

## 🔍 Pre-commit 검증

커밋 전에 다음 항목들이 자동으로 검증됩니다:

### 1. **ESLint 검사**
- JavaScript/TypeScript 파일의 코딩 스타일 검증
- 최대 경고 수: 0개 (모든 경고 해결 필요)

### 2. **TypeScript 타입 체크**
- 타입 오류 검증 (`tsc --noEmit`)
- 컴파일 오류 방지

### 3. **Prettier 포맷팅 체크**
- 코드 포맷팅 일관성 검증
- 자동 수정 가능

### 4. **코드 패턴 체크**
- `console.log` 감지 (경고)
- `TODO`/`FIXME` 개수 체크 (정보)

## 🛠️ 헬퍼 함수 (`helpers/branch.sh`)

### 주요 함수들

#### 🌿 브랜치 관련 함수

- **`get_current_branch()`**: 현재 Git 브랜치명 반환
- **`get_branch_type(branch_name)`**: 브랜치명에서 타입 추출
- **`get_commit_rule_path(branch_type)`**: 브랜치 타입에 맞는 규칙 스크립트 경로 반환

#### 🎫 티켓 검증 함수

- **`validate_ticket_format(commit_msg)`**: 티켓 번호 형식 검증
- **`check_ticket_requirement(branch_type, commit_msg)`**: 브랜치별 티켓 요구사항 체크
- **`validate_commit_format(commit_msg)`**: 전체 커밋 메시지 형식 검증

#### 🔍 디버깅 함수

- **`print_branch_info()`**: 현재 브랜치 정보 출력

### 헬퍼 함수 테스트

```bash
# 헬퍼 함수 테스트 실행
.husky/helpers/branch.sh
```

## 🔧 설치 및 설정

### 1. 의존성 설치

```bash
# 워크스페이스 루트에서 실행
pnpm add -D husky @commitlint/cli @commitlint/config-conventional -w
```

### 2. Husky 초기화

```bash
# Husky 설정
npx husky init

# package.json에 prepare 스크립트 추가
npm pkg set scripts.prepare="husky install"
```

### 3. Git hooks 활성화

이미 모든 Git hooks가 생성되어 있으므로 별도 설정이 불필요합니다.
Git 커밋 시 자동으로 실행됩니다.

## 🚀 사용 예시

### 1. Feature 브랜치에서 작업

```bash
# 브랜치 생성 및 이동
git checkout -b feature/user-auth

# 파일 수정 후 커밋
git add .
git commit -m "feat(user-api): 사용자 인증 시스템 추가 [PROJ-123]"
# ✅ 통과: Feature 브랜치 규칙에 맞음

git commit -m "feat(user-api): 소셜 로그인 기능 추가"
# ✅ 통과: Feature 브랜치에서는 티켓 선택사항

git commit -m "fix: 버그 수정 [PROJ-123]"
# ❌ 실패: scope 누락
```

### 2. Hotfix 브랜치에서 긴급 수정

```bash
# 긴급 수정 브랜치 생성
git checkout -b hotfix/payment-bug

# 버그 수정 후 커밋
git add .
git commit -m "fix(payment): 결제 프로세스 오류 수정 [PROJ-456]"
# ✅ 통과: Hotfix 브랜치 규칙에 맞음

git commit -m "feat(payment): 새 기능 추가 [PROJ-123]"
# ❌ 실패: Hotfix 브랜치에서 feat 타입 허용 안됨

git commit -m "fix(payment): 버그 수정"
# ❌ 실패: 티켓 번호 필수
```

### 3. Release 브랜치에서 배포 준비

```bash
# 릴리즈 브랜치 생성
git checkout -b release/v1.2.0

# 배포 준비 작업
git add .
git commit -m "chore(version): package.json 버전 v1.2.0으로 업데이트 [PROJ-789]"
# ✅ 통과: Release 브랜치 규칙에 맞음

git commit -m "feat(user): 새 기능 추가 [PROJ-123]"
# ❌ 실패: Release 브랜치에서 feat 타입 허용 안됨
```

### 4. Main 브랜치에서 프로덕션 관리

```bash
# Main 브랜치로 이동
git checkout main

# Release 브랜치 병합
git merge release/v1.2.0
# ✅ 통과: Release 브랜치 병합 허용

git commit -m "fix(security): 보안 취약점 긴급 패치 [PROJ-999]"
# ✅ 통과: 긴급 수정 허용 (티켓 필수)

git commit -m "feat(user): 새 기능 직접 추가 [PROJ-123]"
# ❌ 실패: Main 브랜치에서 feat 타입 허용 안됨
```

## 🐛 문제 해결

### 1. Pre-commit 검증 실패

```bash
# ESLint 오류 수정
npx eslint --fix <파일명>

# Prettier 포맷팅 적용
npx prettier --write <파일명>

# TypeScript 오류 확인
npx tsc --noEmit
```

### 2. 커밋 메시지 규칙 위반

#### 형식 오류
```bash
# ❌ 잘못된 형식
git commit -m "add user feature"

# ✅ 올바른 형식
git commit -m "feat(user-api): 사용자 기능 추가 [PROJ-123]"
```

#### Scope 누락
```bash
# ❌ Scope 누락
git commit -m "feat: 새 기능 추가 [PROJ-123]"

# ✅ Scope 포함
git commit -m "feat(user-api): 새 기능 추가 [PROJ-123]"
```

#### 티켓 번호 누락
```bash
# ❌ 티켓 누락 (hotfix/release/develop/main 브랜치)
git commit -m "fix(payment): 결제 오류 수정"

# ✅ 티켓 포함
git commit -m "fix(payment): 결제 오류 수정 [PROJ-123]"
```

### 3. 스크립트 실행 권한 오류

```bash
# 실행 권한 복구
chmod +x .husky/pre-commit
chmod +x .husky/commit-msg
chmod +x .husky/helpers/branch.sh
chmod +x .husky/branch-rules/*/commit-msg.sh
```

### 4. 헬퍼 스크립트 로드 실패

```bash
# 경로 확인
ls -la .husky/helpers/branch.sh

# 헬퍼 스크립트 테스트
.husky/helpers/branch.sh
```

## 📝 커스터마이징

### 새로운 브랜치 타입 추가

1. `helpers/branch.sh`의 `get_branch_type()` 함수에 패턴 추가
2. `branch-rules/` 아래에 새 디렉토리 생성
3. 해당 디렉토리에 `commit-msg.sh` 스크립트 작성
4. 실행 권한 부여: `chmod +x branch-rules/새타입/commit-msg.sh`

### 기존 규칙 수정

각 브랜치별 `commit-msg.sh` 파일을 직접 수정하여 규칙을 조정할 수 있습니다.

### 새로운 Type 추가

`commitlint.config.js` 파일의 `type-enum` 규칙에 새로운 타입을 추가할 수 있습니다.

## 📊 커밋 메시지 예시 모음

### ✅ 완벽한 예시들

```bash
# Feature 개발
feat(user-api): OAuth 2.0 소셜 로그인 구현 [PROJ-123]
feat(dashboard): 실시간 사용자 통계 대시보드 추가 [PROJ-456][PROJ-789]

# 버그 수정
fix(auth-service): JWT 토큰 갱신 시 만료 시간 검증 로직 수정 [PROJ-234]
fix(payment-api): 결제 금액 계산 시 소수점 오류 해결 [PROJ-567]

# 리팩토링
refactor(shared-lib): HTTP 클라이언트 모듈을 async/await 패턴으로 전환 [PROJ-345]
refactor(web-admin): 사용자 관리 컴포넌트 구조 개선 [PROJ-678]

# 성능 개선
perf(database): 사용자 검색 쿼리 인덱스 최적화로 응답속도 50% 향상 [PROJ-456]
perf(image-service): 이미지 압축 알고리즘 개선으로 용량 30% 감소 [PROJ-789]

# 테스트
test(user-api): 회원가입 API 엣지케이스 테스트 추가 [PROJ-123]
test(payment): 결제 실패 시나리오 E2E 테스트 구현 [PROJ-456]

# 문서
docs(api): 사용자 인증 API 엔드포인트 상세 문서 작성 [PROJ-234]
docs(readme): 로컬 개발 환경 설정 가이드 업데이트 [PROJ-567]

# 빌드/도구
chore(webpack): 개발 서버 HMR 설정 최적화 [PROJ-345]
chore(docker): 프로덕션 이미지 빌드 시간 단축을 위한 레이어 최적화 [PROJ-678]
```

### ❌ 피해야 할 예시들

```bash
# 형식 오류
"add login feature"  # type, scope, 콜론 누락
"feat add login"  # scope, 콜론 누락
"feat(user) add login"  # 콜론 누락
"feat(user): add login."  # 마침표 사용

# Scope 오류
"feat(): 빈 scope"  # 빈 scope
"feat(user_api): 언더스코어 사용"  # kebab-case 권장
"feat(UserAPI): 대문자 사용"  # 소문자 권장

# Summary 오류
"feat(user): 기능 추가했습니다."  # 마침표 사용
"feat(user): "  # 빈 summary
"feat(user): 이 커밋은 사용자 관리를 위한 새로운 기능을 추가하는데 그 기능은 로그인과 회원가입 그리고 프로필 관리 기능을 포함합니다"  # 너무 김

# 티켓 오류 (필수 브랜치에서)
"fix(payment): 버그 수정"  # 티켓 누락
"feat(user): 기능 추가 [INVALID]"  # 잘못된 티켓 형식
"feat(user): 기능 추가 PROJ-123"  # 대괄호 누락
```

## 🎉 마무리

이 커밋린트 설정을 통해:

- ✅ **일관된 커밋 메시지** 형식 유지
- ✅ **브랜치별 적절한 규칙** 자동 적용  
- ✅ **티켓 추적성** 보장
- ✅ **코드 품질** 향상
- ✅ **협업 효율성** 증대

궁금한 점이 있으시면 개발팀에 문의해주세요! 🚀

---

**📅 마지막 업데이트**: 2025년 9월  
**🔧 설정 버전**: v2.0 (새로운 커밋 형식 적용)