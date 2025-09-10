# GitHub 표준 연동 가이드

## 🎯 **선택지 제안**

현재 Gitflow 설정을 GitHub 표준에 맞추는 3가지 옵션을 제공합니다:

### **옵션 1: GitHub Flow 완전 전환 (권장)**
```yaml
# 현재 워크플로우 교체
.github/workflows/pr-branch-validation.yml → DISABLE
.github/workflows/github-flow-option.yml → ENABLE

# 브랜치 전략 변경
모든 브랜치 → main 직접 병합
develop 브랜치 → 단계적 폐지
```

### **옵션 2: 하이브리드 접근 (유연)**
```yaml
# 두 워크플로우 모두 유지
pr-branch-validation.yml (Gitflow) - 큰 기능용
github-flow-option.yml (GitHub Flow) - 작은 수정용

# 브랜치별 선택적 적용
feature/major-* → develop (Gitflow)
feature/minor-* → main (GitHub Flow)
fix/* → main (GitHub Flow)
hotfix/* → main (GitHub Flow)
```

### **옵션 3: 현재 Gitflow 유지 + GitHub 표준 개선**
```yaml
# 현재 설정 유지하되 GitHub 관례 적용
브랜치 보호 규칙 → GitHub 표준
머지 전략 → GitHub 권장사항
라벨링 → GitHub 표준 라벨
```

## 🛠️ **GitHub 네이티브 기능 활용**

### **1. Branch Protection Rules (Repository Settings)**

#### **main 브랜치 설정**
```
Settings → Branches → Add rule

Branch name pattern: main

☑️ Require a pull request before merging
  ☑️ Require approvals: 1
  ☑️ Dismiss stale PR approvals when new commits are pushed
  ☑️ Require review from code owners

☑️ Require status checks to pass before merging
  ☑️ Require branches to be up to date before merging
  - pr-branch-validation (Gitflow용)
  - github-flow-validation (GitHub Flow용)

☑️ Require linear history
☑️ Include administrators
☑️ Restrict pushes that create files
```

#### **develop 브랜치 설정 (Gitflow 유지시)**
```
Branch name pattern: develop

☑️ Require a pull request before merging
  ☑️ Require approvals: 1

☑️ Require status checks to pass before merging
  ☑️ Require branches to be up to date before merging
```

### **2. GitHub Labels (자동 연동)**

현재 `labels.yml`을 GitHub 표준에 맞춰 확장:

```yaml
# GitHub 표준 라벨 추가
- name: bug
  color: "d73a4a"
  description: "Something isn't working"
  
- name: enhancement  
  color: "a2eeef"
  description: "New feature or request"
  
- name: documentation
  color: "0075ca"  
  description: "Improvements or additions to documentation"
  
- name: good first issue
  color: "7057ff"
  description: "Good for newcomers"
  
- name: help wanted
  color: "008672"
  description: "Extra attention is needed"
```

### **3. Merge Strategies (Repository Settings)**

```
Settings → General → Pull Requests

GitHub 권장 설정:
☑️ Allow squash merging (기본값, 권장)
  Default to pull request title and commit details
  
☑️ Allow merge commits (릴리즈/핫픽스용)
  Default to pull request title
  
☑️ Allow rebase merging (작은 수정용)

☑️ Always suggest updating pull request branches
☑️ Automatically delete head branches
```

### **4. GitHub Actions 통합**

#### **Gitflow 유지 버전**
```yaml
# .github/workflows/pr-branch-validation.yml (현재)
- Gitflow 규칙 엄격 적용
- develop/main 브랜치 보호
- 브랜치 방향 검증
```

#### **GitHub Flow 버전**  
```yaml
# .github/workflows/github-flow-option.yml (신규)
- 모든 브랜치 → main 허용
- GitHub 표준 브랜치 이름 검증
- 머지 전략 자동 제안
```

## 🔄 **단계별 전환 가이드**

### **1단계: 현재 상태 분석**
```bash
# 현재 브랜치 상태 확인
git branch -r

# 활성 개발 브랜치 확인
git log --oneline --graph --all

# PR 히스토리 분석
gh pr list --state all
```

### **2단계: GitHub 표준 적용**
```bash
# GitHub CLI로 브랜치 보호 설정
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["pr-validation"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

### **3단계: 워크플로우 선택**

#### **GitHub Flow 선택시**
```bash
# 현재 Gitflow 워크플로우 비활성화
mv .github/workflows/pr-branch-validation.yml \
   .github/workflows/pr-branch-validation.yml.disabled

# GitHub Flow 워크플로우 활성화  
# (이미 생성됨: github-flow-option.yml)
```

#### **하이브리드 선택시**
```bash
# 두 워크플로우 모두 유지
# 조건부 실행 로직 추가
```

### **4단계: 팀 교육 및 문서화**

#### **GitHub Flow 가이드**
```markdown
# 개발 프로세스 (GitHub Flow)

1. main에서 브랜치 생성
   git checkout main
   git checkout -b feature/new-feature

2. 개발 및 커밋
   git add .
   git commit -m "feat: add new feature"

3. GitHub에 푸시
   git push origin feature/new-feature

4. PR 생성 (main 타겟)
   gh pr create --title "feat: add new feature" --base main

5. 리뷰 후 병합 (Squash 권장)
   gh pr merge --squash
```

## 📊 **권장사항 매트릭스**

| 팀 규모 | 배포 주기 | 복잡도 | 권장 전략 |
|---------|-----------|--------|-----------|
| 1-3명 | 일일 | 단순 | **GitHub Flow** |
| 4-8명 | 주간 | 중간 | **하이브리드** |
| 9명+ | 월간 | 복잡 | **현재 Gitflow** |

## 🎯 **최종 실행 명령어**

### **GitHub Flow 전환 (권장)**
```bash
# 1. 현재 Gitflow 워크플로우 비활성화
git mv .github/workflows/pr-branch-validation.yml \
       .github/workflows/gitflow-backup.yml.disabled

# 2. GitHub Flow 워크플로우 활성화
git mv .github/workflows/github-flow-option.yml \
       .github/workflows/pr-branch-validation.yml

# 3. 브랜치 전략 문서 업데이트
git add .github/branch-strategy-comparison.md

# 4. 변경사항 커밋
git commit -m "feat: migrate to GitHub Flow standard"
```

### **하이브리드 유지**
```bash
# 두 워크플로우 모두 유지
# 필요시 조건부 실행 로직만 추가
```

### **현재 상태 유지**
```bash
# GitHub 표준 라벨만 추가
git add .github/labels.yml
git commit -m "chore: add GitHub standard labels"
```

## 📋 **체크리스트**

- [ ] **브랜치 전략 결정** (GitHub Flow vs Gitflow vs 하이브리드)
- [ ] **Branch Protection Rules 설정** (Repository Settings)
- [ ] **워크플로우 선택** (기존 vs 새로운)
- [ ] **Merge Strategy 설정** (Repository Settings)
- [ ] **표준 라벨 적용** (GitHub 표준 라벨)
- [ ] **팀 교육 진행** (새로운 프로세스 안내)
- [ ] **문서 업데이트** (개발 가이드라인)

**결론**: GitHub는 공식 Gitflow를 제공하지 않지만, 현재 시스템을 GitHub 표준에 맞춰 최적화할 수 있습니다. 팀 상황에 맞는 옵션을 선택하세요!
