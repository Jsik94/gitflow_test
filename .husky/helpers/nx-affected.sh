#!/bin/bash

# Nx affected 관련 헬퍼 함수들
# pre-push와 다른 훅에서 재사용 가능한 함수들

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

# Nx affected 프로젝트 목록 가져오기
get_affected_projects() {
    local base_commit="$1"
    local project_type="$2"
    
    if [ -n "$project_type" ]; then
        npx nx show projects --affected --base="$base_commit" --type="$project_type" 2>/dev/null || echo ""
    else
        npx nx show projects --affected --base="$base_commit" 2>/dev/null || echo ""
    fi
}

# Nx affected 앱 목록 가져오기
get_affected_apps() {
    get_affected_projects "$1" "app"
}

# Nx affected 라이브러리 목록 가져오기
get_affected_libs() {
    get_affected_projects "$1" "lib"
}

# 변경된 파일 목록 가져오기
get_changed_files() {
    local base_commit="$1"
    git diff --name-only "$base_commit" HEAD 2>/dev/null || echo ""
}

# Nx affected 명령 실행
run_affected_command() {
    local target="$1"
    local base_commit="$2"
    local parallel="${3:-3}"
    local extra_args="${4:-}"
    
    log_info "실행 중: nx run-many --target=$target --affected --base=$base_commit --parallel=$parallel $extra_args"
    
    if npx nx run-many --target="$target" --affected --base="$base_commit" --parallel="$parallel" $extra_args; then
        log_success "$target 완료!"
        return 0
    else
        log_error "$target 실패!"
        return 1
    fi
}

# Nx affected 명령 실행 (조건부)
run_affected_if_changed() {
    local target="$1"
    local base_commit="$2"
    local project_type="$3"
    local parallel="${4:-3}"
    
    local affected_projects
    affected_projects=$(get_affected_projects "$base_commit" "$project_type")
    
    if [ -n "$affected_projects" ]; then
        log_info "$project_type 프로젝트가 변경되어 $target 실행합니다."
        run_affected_command "$target" "$base_commit" "$parallel"
    else
        log_info "$project_type 프로젝트 변경사항이 없어 $target를 건너뜁니다."
    fi
}

# Nx 캐시 상태 확인
check_nx_cache() {
    log_info "Nx 캐시 상태 확인 중..."
    
    if command -v npx >/dev/null 2>&1; then
        local cache_info
        cache_info=$(npx nx show projects --affected --base=HEAD~1 2>/dev/null | head -5)
        
        if [ -n "$cache_info" ]; then
            log_success "Nx 캐시가 정상적으로 작동하고 있습니다."
        else
            log_warning "Nx 캐시에 문제가 있을 수 있습니다."
        fi
    else
        log_error "npx를 찾을 수 없습니다."
        return 1
    fi
}

# Nx 그래프 의존성 확인
check_dependencies() {
    local base_commit="$1"
    local affected_projects="$2"
    
    if [ -z "$affected_projects" ]; then
        return 0
    fi
    
    log_info "의존성 그래프 확인 중..."
    
    # 각 프로젝트의 의존성 확인
    for project in $affected_projects; do
        local deps
        deps=$(npx nx show project "$project" --json 2>/dev/null | jq -r '.implicitDependencies[]?' 2>/dev/null || echo "")
        
        if [ -n "$deps" ]; then
            log_info "$project 의존성: $deps"
        fi
    done
}

# 성능 메트릭 수집
collect_performance_metrics() {
    local start_time="$1"
    local end_time="$2"
    local operation="$3"
    
    local duration=$((end_time - start_time))
    log_info "$operation 완료 시간: ${duration}초"
    
    # 메트릭을 파일에 저장 (선택사항)
    if [ -f ".husky/helpers/metrics.log" ]; then
        echo "$(date): $operation - ${duration}s" >> .husky/helpers/metrics.log
    fi
}

# Nx 워크스페이스 상태 확인
check_workspace_health() {
    log_info "Nx 워크스페이스 상태 확인 중..."
    
    # nx.json 파일 확인
    if [ ! -f "nx.json" ]; then
        log_error "nx.json 파일을 찾을 수 없습니다."
        return 1
    fi
    
    # package.json의 nx 스크립트 확인
    if ! grep -q "nx" package.json; then
        log_warning "package.json에 nx 관련 스크립트가 없습니다."
    fi
    
    # node_modules/nx 확인
    if [ ! -d "node_modules/nx" ]; then
        log_error "Nx가 설치되지 않았습니다. 'npm install' 또는 'pnpm install'을 실행하세요."
        return 1
    fi
    
    log_success "Nx 워크스페이스가 정상적으로 설정되어 있습니다."
}

# 프로젝트별 상세 정보 출력
show_project_details() {
    local affected_projects="$1"
    
    if [ -z "$affected_projects" ]; then
        return 0
    fi
    
    log_info "변경된 프로젝트 상세 정보:"
    
    for project in $affected_projects; do
        echo ""
        echo "📦 프로젝트: $project"
        
        # 프로젝트 타입 확인
        local project_type
        project_type=$(npx nx show project "$project" --json 2>/dev/null | jq -r '.projectType' 2>/dev/null || echo "unknown")
        echo "   타입: $project_type"
        
        # 프로젝트 루트 확인
        local project_root
        project_root=$(npx nx show project "$project" --json 2>/dev/null | jq -r '.root' 2>/dev/null || echo "unknown")
        echo "   루트: $project_root"
        
        # 사용 가능한 타겟들 확인
        local targets
        targets=$(npx nx show project "$project" --json 2>/dev/null | jq -r '.targets | keys[]' 2>/dev/null | tr '\n' ' ' || echo "unknown")
        echo "   타겟들: $targets"
    done
}

# 메인 함수들
main() {
    case "${1:-help}" in
        "get-affected")
            get_affected_projects "${2:-HEAD~1}" "${3:-}"
            ;;
        "get-apps")
            get_affected_apps "${2:-HEAD~1}"
            ;;
        "get-libs")
            get_affected_libs "${2:-HEAD~1}"
            ;;
        "run-command")
            run_affected_command "${2}" "${3}" "${4:-3}" "${5:-}"
            ;;
        "check-cache")
            check_nx_cache
            ;;
        "check-workspace")
            check_workspace_health
            ;;
        "show-details")
            show_project_details "${2:-}"
            ;;
        "help"|*)
            echo "사용법: $0 <command> [args...]"
            echo ""
            echo "명령어:"
            echo "  get-affected [base_commit] [type]  - 변경된 프로젝트 목록 가져오기"
            echo "  get-apps [base_commit]             - 변경된 앱 목록 가져오기"
            echo "  get-libs [base_commit]             - 변경된 라이브러리 목록 가져오기"
            echo "  run-command <target> <base> [parallel] [extra] - affected 명령 실행"
            echo "  check-cache                        - Nx 캐시 상태 확인"
            echo "  check-workspace                    - 워크스페이스 상태 확인"
            echo "  show-details <projects>            - 프로젝트 상세 정보 출력"
            echo "  help                               - 이 도움말 표시"
            ;;
    esac
}

# 스크립트가 직접 실행된 경우에만 main 함수 호출
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

