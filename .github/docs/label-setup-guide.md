# GitHub 라벨 설정 완전 가이드 (2024년 최신)

## 🎯 **현재 구현된 라벨 시스템**

### 📊 **라벨 현황 (총 17개)**
```yaml
타입 라벨 (9개):
✅ type:feature      # 새로운 기능 추가
✅ type:fix          # 버그 수정
✅ type:refactor     # 코드 리팩토링  
✅ type:performance  # 성능 개선
✅ type:test         # 테스트 추가/수정
✅ type:docs         # 문서화
✅ type:chore        # 빌드/설정 변경
✅ type:hotfix       # 긴급 핫픽스
✅ type:release      # 릴리즈

특수 라벨 (4개):
✅ has-ticket           # Jira 티켓 연결됨
✅ sync:release→develop # 릴리즈 백머지
✅ priority:high        # 높은 우선순위
✅ versioning:semver    # 시맨틱 버저닝
✅ guard:override       # 규칙 우회

크기 라벨 (5개):
✅ size/XS, size/S, size/M, size/L, size/XL
```

### 🤖 **자동 라벨링 시스템**
현재 `auto-labeler.yml`이 다음과 같이 자동 적용합니다:

```yaml
브랜치명 기반:
- feature/* → type:feature
- fix/* → type:fix  
- hotfix/* → type:hotfix
- release/* → type:release

PR 제목 기반:
- feat(scope): → type:feature
- fix(scope): → type:fix
- refactor(scope): → type:refactor
- perf(scope): → type:performance
- test(scope): → type:test
- docs(scope): → type:docs
- chore(scope): → type:chore
- [PROJ-123] → has-ticket

PR 내용 기반:
- 체크박스 개수로 size/* 자동 판정
- 키워드로 priority:high 자동 적용
```

## 🚀 **방법 1: 자동 설치 (추천) - sync-labels.yml**

### **GitHub Actions 자동 동기화**
현재 구현된 워크플로우: **없음** (필요 시 생성)

#### **sync-labels.yml 생성**
```yaml
# .github/workflows/sync-labels.yml
name: Sync GitHub Labels

on:
  push:
    branches: [main]
    paths: ['.github/labels.yml']
  workflow_dispatch:

jobs:
  sync-labels:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Sync Labels
        uses: crazy-max/ghaction-github-labeler@v5
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          yaml-file: .github/labels.yml
          skip-delete: false
          dry-run: false
```

#### **실행 방법**:
```bash
# 1. labels.yml 파일 수정 후 main 브랜치에 푸시
git add .github/labels.yml
git commit -m "feat: update label configuration"
git push origin main

# 2. 또는 수동으로 워크플로우 실행
# GitHub 웹 → Actions → "Sync GitHub Labels" → "Run workflow"
```

## 🔧 **방법 2: GitHub CLI 자동 설치**

### **일괄 라벨 생성 스크립트**
```bash
#!/bin/bash
# create-labels.sh

echo "🏷️ GitHub 라벨 생성 시작..."

# 타입 라벨
gh label create "type:feature" --color "2E86AB" --description "새로운 기능 추가" --force
gh label create "type:fix" --color "E67E22" --description "버그 수정" --force
gh label create "type:refactor" --color "3498DB" --description "코드 리팩토링" --force
gh label create "type:performance" --color "F39C12" --description "성능 개선" --force
gh label create "type:test" --color "16A085" --description "테스트 추가/수정" --force
gh label create "type:docs" --color "9B59B6" --description "문서화" --force
gh label create "type:chore" --color "95A5A6" --description "빌드/설정 변경" --force
gh label create "type:hotfix" --color "C0392B" --description "긴급 핫픽스" --force
gh label create "type:release" --color "8E44AD" --description "릴리즈" --force

# 특수 라벨
gh label create "has-ticket" --color "F1C40F" --description "Jira 티켓 연결됨" --force
gh label create "sync:release→develop" --color "95A5A6" --description "릴리즈 백머지" --force
gh label create "priority:high" --color "D35400" --description "높은 우선순위" --force
gh label create "versioning:semver" --color "27AE60" --description "시맨틱 버저닝" --force
gh label create "guard:override" --color "7F8C8D" --description "규칙 우회" --force

# 크기 라벨
gh label create "size/XS" --color "B3E5FC" --description "매우 작은 작업 (1-3 체크박스)" --force
gh label create "size/S" --color "81D4FA" --description "작은 작업 (4-6 체크박스)" --force
gh label create "size/M" --color "4FC3F7" --description "중간 작업 (7-10 체크박스)" --force
gh label create "size/L" --color "29B6F6" --description "큰 작업 (11-15 체크박스)" --force
gh label create "size/XL" --color "03A9F4" --description "매우 큰 작업 (16+ 체크박스)" --force

echo "✅ 총 17개 라벨 생성 완료!"
```

### **실행 방법**:
```bash
# GitHub CLI 로그인 (최초 1회)
gh auth login

# 스크립트 실행
chmod +x create-labels.sh
./create-labels.sh
```

## 🎨 **라벨 색상 체계 (현재 구현)**

### **타입별 색상 매핑**
```yaml
🔵 파란색 계열:
- type:feature    → #2E86AB (진한 파랑)
- type:refactor   → #3498DB (밝은 파랑)

🟠 주황색 계열:  
- type:fix        → #E67E22 (주황)
- type:performance → #F39C12 (노란 주황)
- priority:high   → #D35400 (진한 주황)

🔴 빨간색 계열:
- type:hotfix     → #C0392B (빨강)

🟣 보라색 계열:
- type:release    → #8E44AD (보라)
- type:docs       → #9B59B6 (밝은 보라)

🟢 녹색 계열:
- type:test       → #16A085 (청록)
- versioning:semver → #27AE60 (녹색)

⚪ 회색 계열:
- type:chore      → #95A5A6 (연한 회색)
- sync:release→develop → #95A5A6 (연한 회색)
- guard:override  → #7F8C8D (진한 회색)

🟡 노란색 계열:
- has-ticket      → #F1C40F (노랑)

💙 크기별 파란색 그라데이션:
- size/XS         → #B3E5FC (매우 연한 파랑)
- size/S          → #81D4FA (연한 파랑)
- size/M          → #4FC3F7 (보통 파랑)
- size/L          → #29B6F6 (진한 파랑)
- size/XL         → #03A9F4 (매우 진한 파랑)
```

## 🔍 **라벨 확인 및 검증**

### **현재 라벨 상태 확인**
```bash
# 모든 라벨 목록
gh label list

# 특정 라벨 존재 확인
gh label list | grep "type:feature"

# 라벨 개수 확인 (총 17개여야 함)
gh label list | wc -l
```

### **누락된 라벨 자동 감지 스크립트**
```bash
#!/bin/bash
# check-labels.sh

REQUIRED_LABELS=(
  "type:feature" "type:fix" "type:refactor" "type:performance"
  "type:test" "type:docs" "type:chore" "type:hotfix" "type:release"
  "has-ticket" "sync:release→develop" "priority:high" 
  "versioning:semver" "guard:override"
  "size/XS" "size/S" "size/M" "size/L" "size/XL"
)

echo "🔍 라벨 상태 검증 중..."
MISSING_COUNT=0

for label in "${REQUIRED_LABELS[@]}"; do
  if gh label list | grep -q "^$label"; then
    echo "✅ $label"
  else
    echo "❌ 누락: $label"
    ((MISSING_COUNT++))
  fi
done

echo ""
if [ $MISSING_COUNT -eq 0 ]; then
  echo "🎉 모든 라벨이 정상적으로 설정되어 있습니다!"
else
  echo "⚠️ $MISSING_COUNT개의 라벨이 누락되었습니다."
  echo "📝 create-labels.sh 스크립트를 실행하여 생성하세요."
fi
```

## 🎯 **자동 라벨링 규칙 (auto-labeler.yml)**

### **현재 구현된 자동 라벨링**
```javascript
// 브랜치명 기반 라벨링
const branchRules = {
  '/^feature\//': ['type:feature'],
  '/^(fix|bugfix)\//': ['type:fix'],
  '/^hotfix\//': ['type:hotfix'],
  '/^release\//': ['type:release', 'versioning:semver']
};

// PR 제목 기반 라벨링  
const titleRules = {
  '^feat\\([^)]+\\):': ['type:feature'],
  '^fix\\([^)]+\\):': ['type:fix'],
  '^refactor\\([^)]+\\):': ['type:refactor'],
  '^perf\\([^)]+\\):': ['type:performance'],
  '^test\\([^)]+\\):': ['type:test'],
  '^docs\\([^)]+\\):': ['type:docs'],
  '^chore\\([^)]+\\):': ['type:chore'],
  '\\[PROJ-\\d+\\]': ['has-ticket'],
  '\\[\\w+-\\d+\\]': ['has-ticket']
};

// PR 본문 기반 크기 판정
const sizeRules = {
  checkboxCount: {
    '1-3': ['size/XS'],
    '4-6': ['size/S'], 
    '7-10': ['size/M'],
    '11-15': ['size/L'],
    '16+': ['size/XL']
  }
};
```

### **라벨 적용 예시**
```yaml
# feature/user-auth → develop
브랜치: feature/user-auth → type:feature
제목: "feat(auth): JWT 인증 구현 [PROJ-123]" → type:feature, has-ticket
내용: 체크박스 5개 → size/S

최종 라벨: [type:feature, has-ticket, size/S]

# hotfix/security-patch → main  
브랜치: hotfix/security-patch → type:hotfix
제목: "hotfix: XSS 취약점 긴급 수정 [URGENT-456]" → type:hotfix, has-ticket
키워드: "긴급", "보안" → priority:high

최종 라벨: [type:hotfix, has-ticket, priority:high]
```

## ⚡ **빠른 설정 (권장)**

### **1단계: 라벨 일괄 생성**
```bash
# GitHub CLI로 한 번에 생성
curl -sSL https://raw.githubusercontent.com/your-repo/scripts/create-labels.sh | bash

# 또는 수동 실행
gh auth login
./create-labels.sh
```

### **2단계: 자동 동기화 설정 (선택사항)**
```bash
# sync-labels.yml 워크플로우 생성
cat > .github/workflows/sync-labels.yml << 'EOF'
# [위의 sync-labels.yml 내용]
EOF

git add .github/workflows/sync-labels.yml
git commit -m "feat: add automatic label sync workflow"
git push
```

### **3단계: 결과 확인**
```bash
# 라벨 개수 확인 (17개)
gh label list | wc -l

# 자동 라벨링 테스트 
# 새 PR 생성 후 라벨이 자동으로 붙는지 확인
```

## 🔄 **라벨 관리 모범 사례**

### **라벨 추가 시**
1. `.github/labels.yml`에 새 라벨 정의
2. `auto-labeler.yml`에 자동 적용 규칙 추가
3. `create-labels.sh` 스크립트 업데이트
4. 팀에 새 라벨 용도 공유

### **라벨 수정 시**
```bash
# 기존 라벨 업데이트
gh label edit "type:feature" --color "2E86AB" --description "새로운 기능 개발"

# 또는 삭제 후 재생성
gh label delete "old-label"
gh label create "new-label" --color "123456" --description "New description"
```

### **라벨 삭제 시**
```bash
# 안전한 삭제 (사용 중인지 확인)
gh pr list --label "deprecated-label"  # 사용 중인 PR 확인
gh label delete "deprecated-label"     # 안전하면 삭제
```

## 📊 **라벨 사용 통계 및 분석**

### **라벨별 사용 빈도 확인**
```bash
# 가장 많이 사용되는 라벨 Top 10
gh pr list --state all --json labels | jq -r '.[].labels[].name' | sort | uniq -c | sort -nr | head -10

# 특정 라벨의 PR 목록
gh pr list --label "type:feature" --state all
```

### **크기별 작업 분포 분석**
```bash
# 크기별 PR 개수
for size in XS S M L XL; do
  count=$(gh pr list --label "size/$size" --state all --json number | jq '. | length')
  echo "size/$size: $count개"
done
```

## 🎯 **체크리스트**

### **초기 설정 완료 확인**
- [ ] **17개 라벨 모두 생성됨** (gh label list | wc -l)
- [ ] **자동 라벨링 정상 작동** (새 PR에서 테스트)
- [ ] **라벨 색상 정상 표시** (GitHub UI에서 확인)
- [ ] **sync-labels.yml 설정** (선택사항)
- [ ] **팀 교육 완료** (라벨 의미 및 용도)

### **운영 중 확인사항**
- [ ] **새 라벨 추가 시 자동화 규칙 업데이트**
- [ ] **월간 라벨 사용 통계 리뷰**
- [ ] **불필요한 라벨 정리**
- [ ] **라벨 색상 일관성 유지**

## 🚀 **고급 활용**

### **라벨 기반 자동화**
```yaml
# GitHub Actions에서 라벨 기반 조건 처리
- name: Deploy to staging
  if: contains(github.event.pull_request.labels.*.name, 'type:feature')
  
- name: Hotfix notification
  if: contains(github.event.pull_request.labels.*.name, 'type:hotfix')
```

### **라벨 기반 프로젝트 관리**
```bash
# Epic 관리 (size/XL 라벨 활용)
gh pr list --label "size/XL" --json title,number

# 릴리즈 준비 상황 확인
gh pr list --label "type:release" --state open
```

**이제 완벽한 라벨 시스템으로 PR 관리가 자동화됩니다!** 🏷️✨