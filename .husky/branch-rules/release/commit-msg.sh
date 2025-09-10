#!/bin/bash

# Release 브랜치 커밋 메시지 규칙
# 릴리즈 준비 브랜치에서 사용되는 커밋 메시지 검증 규칙

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# 헬퍼 함수 로드
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../../helpers/branch.sh"

echo "🚀 Release 브랜치 커밋 메시지 검증 중..."
echo "📝 커밋 메시지: $commit_msg"

# Release 브랜치 허용 타입들
allowed_types="fix|docs|chore|test"

# 새로운 형식 검증: type(scope): summary [TICKET]
# scope는 필수, 티켓은 필수
pattern="^($allowed_types)\([^)]+\): .{1,100} \[[A-Z]+\-[0-9]+\](\[[A-Z]+\-[0-9]+\])*$"

# Merge 커밋 패턴
merge_pattern="^Merge (branch|pull request)"

# Merge 커밋 허용
if [[ $commit_msg =~ $merge_pattern ]]; then
    echo "🔀 Merge 커밋이 감지되었습니다."
    echo "✅ Release 브랜치 Merge 커밋 허용!"
    exit 0
fi

# 기본 패턴 검증
if [[ ! $commit_msg =~ $pattern ]]; then
    echo ""
    echo "❌ Release 브랜치 커밋 메시지 규칙 위반!"
    echo ""
    echo "📌 올바른 형식: type(scope): summary [TICKET]"
    echo ""
    echo "📋 Release 브랜치 허용 타입:"
    echo "   fix(scope): 버그 수정 (릴리즈 차단 이슈만)"
    echo "   docs(scope): 문서 수정 (changelog, readme 등)"
    echo "   chore(scope): 빌드/배포 관련 작업"
    echo "   test(scope): 테스트 수정 (릴리즈 검증용)"
    echo ""
    echo "🚀 Release 브랜치는 배포 준비 작업만 허용됩니다!"
    echo ""
    echo "📋 scope 규칙:"
    echo "   • 반드시 포함 (빈 값 불가)"
    echo "   • 앱/도메인/패키지명 (예: build, version, changelog)"
    echo ""
    echo "📋 summary 규칙:"
    echo "   • 최대 100자 이내"
    echo "   • 한국어/영어 모두 가능"
    echo "   • 마침표(.) 붙이지 않음"
    echo ""
    echo "📋 [TICKET] 규칙 (Release 브랜치: 필수):"
    echo "   • 형식: [PROJ-123] 또는 [PROJ-123][PROJ-456]"
    echo "   • 반드시 포함해야 함"
    echo ""
    echo "✅ 올바른 예시:"
    echo "   fix(build): 빌드 스크립트 오류 수정 [PROJ-123]"
    echo "   docs(changelog): v1.2.0 변경사항 문서화 [PROJ-456]"
    echo "   chore(version): package.json 버전 업데이트 [PROJ-789]"
    echo "   test(e2e): 릴리즈 검증용 E2E 테스트 추가 [PROJ-123]"
    echo ""
    echo "❌ 잘못된 예시:"
    echo "   $commit_msg"
    echo ""
    exit 1
fi

# 티켓 번호 검증 (Release 브랜치는 필수)
if ! check_ticket_requirement "release" "$commit_msg"; then
    exit 1
fi

# Release 브랜치 특별 규칙
if [[ $commit_msg =~ ^(fix|chore|docs|test) ]]; then
    echo "✅ Release 브랜치에 적합한 커밋 타입입니다!"
    echo "💡 릴리즈 차단 이슈 해결이나 배포 준비 작업인지 확인해주세요."
fi

# 버전 태그 확인
if [[ $commit_msg =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "🏷️  버전 태그가 포함된 커밋입니다."
fi

echo "✅ Release 브랜치 커밋 메시지 검증 통과!"
exit 0
