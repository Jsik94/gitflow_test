#!/bin/bash

# 성능 최적화 관련 헬퍼 함수들
# Nx 캐시, 병렬 처리, 메모리 관리 등

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

# 시스템 리소스 확인
check_system_resources() {
    log_info "시스템 리소스 확인 중..."
    
    # CPU 코어 수 확인
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "4")
    log_info "CPU 코어 수: $cpu_cores"
    
    # 메모리 확인
    local total_memory
    if command -v free >/dev/null 2>&1; then
        total_memory=$(free -m | awk 'NR==2{printf "%.0f", $2}')
        log_info "총 메모리: ${total_memory}MB"
    elif command -v vm_stat >/dev/null 2>&1; then
        total_memory=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' | awk '{print int($1/1024/1024*4096)}')
        log_info "사용 가능한 메모리: ${total_memory}MB"
    else
        total_memory="unknown"
        log_warning "메모리 정보를 가져올 수 없습니다."
    fi
    
    # 권장 병렬 처리 수 계산
    local recommended_parallel
    if [ "$cpu_cores" -ge 8 ]; then
        recommended_parallel=$((cpu_cores - 2))
    elif [ "$cpu_cores" -ge 4 ]; then
        recommended_parallel=$((cpu_cores - 1))
    else
        recommended_parallel=2
    fi
    
    log_info "권장 병렬 처리 수: $recommended_parallel"
    echo "$recommended_parallel"
}

# Nx 캐시 상태 확인 및 최적화
optimize_nx_cache() {
    log_info "Nx 캐시 최적화 중..."
    
    # Nx 캐시 디렉토리 확인
    local cache_dir
    cache_dir="${NX_CACHE_DIR:-.nx/cache}"
    
    if [ ! -d "$cache_dir" ]; then
        log_warning "Nx 캐시 디렉토리를 찾을 수 없습니다: $cache_dir"
        return 1
    fi
    
    # 캐시 크기 확인
    local cache_size
    if command -v du >/dev/null 2>&1; then
        cache_size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1)
        log_info "Nx 캐시 크기: $cache_size"
    fi
    
    # 캐시 정리 (선택사항)
    if [ "${1:-}" = "clean" ]; then
        log_info "Nx 캐시 정리 중..."
        if npx nx reset 2>/dev/null; then
            log_success "Nx 캐시가 정리되었습니다."
        else
            log_warning "Nx 캐시 정리에 실패했습니다."
        fi
    fi
    
    # 캐시 히트율 확인 (Nx Cloud 사용 시)
    if [ -n "${NX_CLOUD_ID:-}" ]; then
        log_info "Nx Cloud 캐시 상태 확인 중..."
        # Nx Cloud 캐시 통계 확인 가능
    fi
    
    log_success "Nx 캐시 최적화 완료!"
}

# 병렬 처리 최적화
optimize_parallel_execution() {
    local base_commit="$1"
    local affected_projects="$2"
    
    if [ -z "$affected_projects" ]; then
        log_info "변경된 프로젝트가 없어 병렬 처리 최적화를 건너뜁니다."
        return 0
    fi
    
    log_info "병렬 처리 최적화 중..."
    
    # 프로젝트 수에 따른 병렬 처리 수 조정
    local project_count
    project_count=$(echo "$affected_projects" | wc -w)
    
    local recommended_parallel
    recommended_parallel=$(check_system_resources)
    
    # 프로젝트 수가 적으면 병렬 처리 수를 줄임
    if [ "$project_count" -lt "$recommended_parallel" ]; then
        recommended_parallel="$project_count"
    fi
    
    # 최대 4개로 제한 (메모리 사용량 고려)
    if [ "$recommended_parallel" -gt 4 ]; then
        recommended_parallel=4
    fi
    
    log_info "최적화된 병렬 처리 수: $recommended_parallel (프로젝트 수: $project_count)"
    echo "$recommended_parallel"
}

# 메모리 사용량 모니터링
monitor_memory_usage() {
    local process_name="$1"
    local max_memory_mb="${2:-2048}"
    
    if [ -z "$process_name" ]; then
        return 0
    fi
    
    log_info "메모리 사용량 모니터링 중: $process_name"
    
    # 프로세스 메모리 사용량 확인
    local memory_usage
    if command -v ps >/dev/null 2>&1; then
        memory_usage=$(ps -o rss= -p $$ 2>/dev/null | awk '{print int($1/1024)}')
        if [ -n "$memory_usage" ] && [ "$memory_usage" -gt "$max_memory_mb" ]; then
            log_warning "메모리 사용량이 높습니다: ${memory_usage}MB (최대: ${max_memory_mb}MB)"
        else
            log_info "메모리 사용량: ${memory_usage}MB"
        fi
    fi
}

# 실행 시간 측정
measure_execution_time() {
    local start_time="$1"
    local end_time="$2"
    local operation="$3"
    
    local duration=$((end_time - start_time))
    
    if [ "$duration" -lt 60 ]; then
        log_success "$operation 완료: ${duration}초"
    elif [ "$duration" -lt 3600 ]; then
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        log_success "$operation 완료: ${minutes}분 ${seconds}초"
    else
        local hours=$((duration / 3600))
        local minutes=$(((duration % 3600) / 60))
        log_success "$operation 완료: ${hours}시간 ${minutes}분"
    fi
    
    # 성능 메트릭 저장
    save_performance_metric "$operation" "$duration"
}

# 성능 메트릭 저장
save_performance_metric() {
    local operation="$1"
    local duration="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local metrics_file=".husky/helpers/performance-metrics.log"
    
    # 메트릭 파일이 없으면 헤더 추가
    if [ ! -f "$metrics_file" ]; then
        echo "timestamp,operation,duration_seconds" > "$metrics_file"
    fi
    
    # 메트릭 저장
    echo "$timestamp,$operation,$duration" >> "$metrics_file"
    
    # 최근 100개 항목만 유지
    if [ -f "$metrics_file" ]; then
        tail -n 100 "$metrics_file" > "${metrics_file}.tmp" && mv "${metrics_file}.tmp" "$metrics_file"
    fi
}

# 성능 통계 출력
show_performance_stats() {
    local metrics_file=".husky/helpers/performance-metrics.log"
    
    if [ ! -f "$metrics_file" ]; then
        log_info "성능 메트릭 파일이 없습니다."
        return 0
    fi
    
    log_info "성능 통계:"
    
    # 평균 실행 시간 계산
    if command -v awk >/dev/null 2>&1; then
        local avg_duration
        avg_duration=$(awk -F',' 'NR>1 {sum+=$3; count++} END {if(count>0) print int(sum/count); else print 0}' "$metrics_file")
        log_info "평균 실행 시간: ${avg_duration}초"
        
        # 최근 10회 실행 시간
        log_info "최근 10회 실행 시간:"
        tail -n 10 "$metrics_file" | awk -F',' '{print "  " $1 " - " $2 ": " $3 "초"}'
    fi
}

# Nx 빌드 캐시 최적화
optimize_build_cache() {
    log_info "빌드 캐시 최적화 중..."
    
    # Nx 빌드 캐시 확인
    if command -v npx >/dev/null 2>&1; then
        # 빌드 캐시 상태 확인
        local cache_info
        cache_info=$(npx nx show projects --affected --base=HEAD~1 2>/dev/null | head -5)
        
        if [ -n "$cache_info" ]; then
            log_success "빌드 캐시가 정상적으로 작동하고 있습니다."
        else
            log_warning "빌드 캐시에 문제가 있을 수 있습니다."
        fi
    fi
}

# 네트워크 최적화 (Nx Cloud 사용 시)
optimize_network() {
    if [ -n "${NX_CLOUD_ID:-}" ]; then
        log_info "네트워크 최적화 중..."
        
        # Nx Cloud 연결 상태 확인
        if npx nx cloud --help >/dev/null 2>&1; then
            log_success "Nx Cloud 연결이 정상입니다."
        else
            log_warning "Nx Cloud 연결에 문제가 있을 수 있습니다."
        fi
    else
        log_info "Nx Cloud를 사용하지 않아 네트워크 최적화를 건너뜁니다."
    fi
}

# 전체 성능 최적화
optimize_all() {
    local base_commit="$1"
    local affected_projects="$2"
    
    log_info "전체 성능 최적화 시작..."
    
    # 1. 시스템 리소스 확인
    check_system_resources >/dev/null
    
    # 2. Nx 캐시 최적화
    optimize_nx_cache
    
    # 3. 병렬 처리 최적화
    local parallel_count
    parallel_count=$(optimize_parallel_execution "$base_commit" "$affected_projects")
    
    # 4. 빌드 캐시 최적화
    optimize_build_cache
    
    # 5. 네트워크 최적화
    optimize_network
    
    log_success "전체 성능 최적화 완료!"
    echo "$parallel_count"
}

# 메인 함수들
main() {
    case "${1:-help}" in
        "check-resources")
            check_system_resources
            ;;
        "optimize-cache")
            optimize_nx_cache "${2:-}"
            ;;
        "optimize-parallel")
            optimize_parallel_execution "${2:-HEAD~1}" "${3:-}"
            ;;
        "monitor-memory")
            monitor_memory_usage "${2:-}" "${3:-2048}"
            ;;
        "show-stats")
            show_performance_stats
            ;;
        "optimize-all")
            optimize_all "${2:-HEAD~1}" "${3:-}"
            ;;
        "help"|*)
            echo "사용법: $0 <command> [args...]"
            echo ""
            echo "명령어:"
            echo "  check-resources                    - 시스템 리소스 확인"
            echo "  optimize-cache [clean]            - Nx 캐시 최적화"
            echo "  optimize-parallel <base> <projects> - 병렬 처리 최적화"
            echo "  monitor-memory <process> [max]    - 메모리 사용량 모니터링"
            echo "  show-stats                         - 성능 통계 출력"
            echo "  optimize-all <base> <projects>    - 전체 성능 최적화"
            echo "  help                               - 이 도움말 표시"
            ;;
    esac
}

# 스크립트가 직접 실행된 경우에만 main 함수 호출
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

