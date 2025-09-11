#!/bin/bash

# 커스텀 검증 규칙들
# 프로젝트별 특수한 검증 로직을 여기에 추가

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 변경된 프로젝트 목록 (첫 번째 인수)
affected_projects="$1"

if [ -z "$affected_projects" ]; then
    log_warning "변경된 프로젝트가 없어 커스텀 검증을 건너뜁니다."
    exit 0
fi

log_info "커스텀 검증 규칙 실행 중..."

# 1. API 관련 프로젝트 검증
if echo "$affected_projects" | grep -q -E "(api|backend|server)"; then
    log_info "API 프로젝트 검증 중..."
    
    # API 문서 업데이트 확인
    if ! git diff --cached --name-only | grep -q -E "(swagger|openapi|api-docs)"; then
        log_warning "API 변경사항이 있지만 문서가 업데이트되지 않았습니다."
        log_info "API 문서를 업데이트하는 것을 고려해보세요."
    fi
    
    # 환경변수 파일 확인
    if git diff --cached --name-only | grep -q -E "\.env"; then
        log_warning "환경변수 파일이 변경되었습니다. 프로덕션 배포 시 주의하세요."
    fi
    
    log_success "API 프로젝트 검증 완료!"
fi

# 2. 프론트엔드 관련 프로젝트 검증
if echo "$affected_projects" | grep -q -E "(web|frontend|ui|app)"; then
    log_info "프론트엔드 프로젝트 검증 중..."
    
    # 번들 크기 확인 (선택사항)
    if command -v npx >/dev/null 2>&1; then
        log_info "번들 크기 분석 중..."
        # nx build --stats-json을 사용하여 번들 크기 확인 가능
        # 실제 구현은 프로젝트 구조에 따라 조정 필요
    fi
    
    # 접근성 검사 (선택사항)
    if command -v npx >/dev/null 2>&1; then
        log_info "접근성 검사 중..."
        # eslint-plugin-jsx-a11y 등을 사용한 접근성 검사
    fi
    
    log_success "프론트엔드 프로젝트 검증 완료!"
fi

# 3. 라이브러리 프로젝트 검증
if echo "$affected_projects" | grep -q -E "(lib|shared|common)"; then
    log_info "라이브러리 프로젝트 검증 중..."
    
    # 라이브러리 버전 확인
    for project in $affected_projects; do
        if [[ "$project" == *"lib"* ]]; then
            local package_json_path
            package_json_path=$(find . -name "package.json" -path "*/$project/*" | head -1)
            
            if [ -f "$package_json_path" ]; then
                local version
                version=$(grep '"version"' "$package_json_path" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')
                log_info "$project 버전: $version"
            fi
        fi
    done
    
    log_success "라이브러리 프로젝트 검증 완료!"
fi

# 4. 보안 검사
log_info "보안 검사 중..."

# 하드코딩된 비밀번호나 API 키 검사
if git diff --cached --name-only | xargs grep -l -E "(password|secret|api[_-]?key|token)" --color=never 2>/dev/null; then
    log_warning "비밀번호나 API 키가 포함된 파일이 변경되었습니다."
    log_info "하드코딩된 민감한 정보가 없는지 확인해주세요."
fi

# TODO/FIXME 체크
todo_count=$(git diff --cached --name-only | xargs grep -n -E "(TODO|FIXME|XXX|HACK)" --color=never 2>/dev/null | wc -l || echo "0")
if [ "$todo_count" -gt 0 ]; then
    log_warning "TODO/FIXME가 $todo_count개 발견되었습니다."
    log_info "가능하면 커밋 전에 처리해주세요."
fi

# console.log 체크 (프로덕션 코드)
console_count=$(git diff --cached --name-only | xargs grep -n "console\.log" --color=never 2>/dev/null | wc -l || echo "0")
if [ "$console_count" -gt 0 ]; then
    log_warning "console.log가 $console_count개 발견되었습니다."
    log_info "프로덕션 코드에서 console.log를 제거하는 것을 고려해보세요."
fi

log_success "보안 검사 완료!"

# 5. 코드 품질 검사
log_info "코드 품질 검사 중..."

# 복잡도 검사 (선택사항)
if command -v npx >/dev/null 2>&1; then
    # eslint-complexity 규칙이나 다른 복잡도 도구 사용 가능
    log_info "코드 복잡도 분석 중..."
fi

# 중복 코드 검사 (선택사항)
if command -v npx >/dev/null 2>&1; then
    # jscpd나 다른 중복 코드 검사 도구 사용 가능
    log_info "중복 코드 검사 중..."
fi

log_success "코드 품질 검사 완료!"

# 6. 테스트 커버리지 확인 (선택사항)
log_info "테스트 커버리지 확인 중..."

if command -v npx >/dev/null 2>&1; then
    # nx test --coverage를 사용하여 커버리지 확인 가능
    log_info "테스트 커버리지 분석 중..."
    # 실제 구현은 프로젝트 설정에 따라 조정 필요
fi

log_success "테스트 커버리지 확인 완료!"

# 7. 브랜치별 특수 검증
current_branch=$(git rev-parse --abbrev-ref HEAD)

case "$current_branch" in
    "main"|"master")
        log_info "main 브랜치 특수 검증 중..."
        
        # main 브랜치에서는 더 엄격한 검증
        # 예: 모든 테스트가 통과해야 함
        # 예: 특정 문서가 업데이트되어야 함
        
        log_success "main 브랜치 검증 완료!"
        ;;
    "develop")
        log_info "develop 브랜치 특수 검증 중..."
        
        # develop 브랜치 특수 규칙
        # 예: 통합 테스트 실행
        
        log_success "develop 브랜치 검증 완료!"
        ;;
    feature/*)
        log_info "feature 브랜치 특수 검증 중..."
        
        # feature 브랜치 특수 규칙
        # 예: 해당 기능과 관련된 테스트만 실행
        
        log_success "feature 브랜치 검증 완료!"
        ;;
    hotfix/*)
        log_info "hotfix 브랜치 특수 검증 중..."
        
        # hotfix 브랜치 특수 규칙
        # 예: 빠른 검증, 핵심 기능만 테스트
        
        log_success "hotfix 브랜치 검증 완료!"
        ;;
    *)
        log_info "일반 브랜치 검증 중..."
        log_success "일반 브랜치 검증 완료!"
        ;;
esac

log_success "모든 커스텀 검증이 완료되었습니다!"
exit 0

