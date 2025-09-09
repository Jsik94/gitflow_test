#!/usr/bin/env node

import fs from 'fs';
import path from 'path';

/**
 * PR 본문 검증 스크립트
 * GitHub Actions에서 PR 본문이 규칙에 맞는지 검사합니다.
 */

class PRLintChecker {
  constructor(rulesPath) {
    this.rules = JSON.parse(fs.readFileSync(rulesPath, 'utf-8'));
  }

  /**
   * PR 본문에서 템플릿 타입을 추출합니다.
   * @param {string} prBody - PR 본문
   * @returns {string|null} - 템플릿 타입 (feature, fix, hotfix-main, etc.)
   */
  detectTemplate(prBody) {
    const templatePatterns = {
      'feature': /새로운 기능 추가|# 새로운 기능/,
      'fix': /버그 수정|# 버그 수정/,
      'hotfix-main': /긴급 핫픽스|# 긴급 핫픽스/,
      'release-main': /릴리스 \(Main\)|# 릴리스 \(Main\)/,
      'release-backmerge': /릴리스 백머지|# 릴리스 백머지/
    };

    for (const [type, pattern] of Object.entries(templatePatterns)) {
      if (pattern.test(prBody)) {
        return type;
      }
    }

    return null;
  }

  /**
   * PR 제목에서 템플릿 타입을 추출합니다.
   * @param {string} prTitle - PR 제목
   * @returns {string|null} - 템플릿 타입
   */
  detectTemplateFromTitle(prTitle) {
    // hotfix 패턴 먼저 체크 (더 구체적)
    if (/^hotfix:\s.+$/.test(prTitle)) {
      return 'hotfix-main';
    }
    
    // release 패턴 체크
    if (/^release:\sv?\d+\.\d+\.\d+(-[\w\.+]+)?$/.test(prTitle)) {
      return 'release-main';
    }
    
    // backmerge 패턴 체크  
    if (/^chore\(backmerge\):\sv?\d+\.\d+\.\d+(-[\w\.+]+)?$/.test(prTitle)) {
      return 'release-backmerge';
    }
    
    // 일반 conventional commit 패턴 (feature, fix 등)
    if (/^(feat|fix|refactor|perf|test|docs|chore)(\([\w\-\/]+\))?:\s.+$/.test(prTitle)) {
      if (prTitle.startsWith('fix')) {
        return 'fix';
      }
      return 'feature'; // feat, refactor, perf, test, docs, chore 등은 feature로 분류
    }
    
    return null;
  }

  /**
   * PR 본문에서 특정 섹션의 내용을 추출합니다.
   * @param {string} prBody - PR 본문
   * @param {string} sectionTitle - 섹션 제목
   * @returns {string} - 섹션 내용
   */
  extractSection(prBody, sectionTitle) {
    const regex = new RegExp(`##\\s*${sectionTitle}\\s*\\n([\\s\\S]*?)(?=\\n##|$)`, 'i');
    const match = prBody.match(regex);
    return match ? match[1].trim() : '';
  }

  /**
   * 체크박스 검증
   * @param {string} content - 섹션 내용
   * @param {Array} requiredCheckboxes - 필수 체크박스 목록
   * @returns {Object} - 검증 결과
   */
  validateCheckboxes(content, requiredCheckboxes) {
    const errors = [];
    
    for (const checkbox of requiredCheckboxes) {
      const pattern = new RegExp(`-\\s*\\[x\\]\\s*${checkbox}`, 'i');
      if (!pattern.test(content)) {
        errors.push(`필수 체크박스가 체크되지 않음: ${checkbox}`);
      }
    }

    return { valid: errors.length === 0, errors };
  }

  /**
   * 섹션 내용 길이 검증
   * @param {string} content - 섹션 내용
   * @param {number} minLength - 최소 길이
   * @returns {Object} - 검증 결과
   */
  validateLength(content, minLength) {
    const cleanContent = content.replace(/<!--[\s\S]*?-->/g, '').trim();
    const valid = cleanContent.length >= minLength;
    
    return {
      valid,
      errors: valid ? [] : [`섹션 내용이 너무 짧습니다. 최소 ${minLength}자 이상 작성해주세요.`]
    };
  }

  /**
   * 필수 필드 검증
   * @param {string} content - 섹션 내용
   * @param {Array} requiredFields - 필수 필드 목록
   * @returns {Object} - 검증 결과
   */
  validateRequiredFields(content, requiredFields) {
    const errors = [];
    
    for (const field of requiredFields) {
      if (!content.includes(field)) {
        errors.push(`필수 필드가 누락됨: ${field}`);
      }
    }

    return { valid: errors.length === 0, errors };
  }

  /**
   * PR 본문과 제목을 검증합니다.
   * @param {string} prBody - PR 본문
   * @param {string} prTitle - PR 제목 (선택적)
   * @returns {Object} - 검증 결과
   */
  validate(prBody, prTitle = '') {
    const result = {
      valid: true,
      errors: [],
      warnings: [],
      template: null
    };

    // 전역 규칙 검증
    if (prBody.length < this.rules.global_rules.min_body_length) {
      result.errors.push(`PR 본문이 너무 짧습니다. 최소 ${this.rules.global_rules.min_body_length}자 이상 작성해주세요.`);
    }

    // 금지 단어 검증
    for (const forbiddenWord of this.rules.global_rules.forbidden_words) {
      if (prBody.includes(forbiddenWord)) {
        result.warnings.push(`주의: '${forbiddenWord}' 단어가 포함되어 있습니다.`);
      }
    }

    // 템플릿 타입 감지 (제목 우선, 본문 보조)
    let templateType = this.detectTemplateFromTitle(prTitle);
    if (!templateType) {
      templateType = this.detectTemplate(prBody);
    }
    result.template = templateType;

    if (!templateType) {
      result.errors.push('PR 템플릿 타입을 감지할 수 없습니다. 적절한 템플릿을 사용하거나 제목을 올바른 형식으로 작성해주세요.');
      result.valid = false;
      return result;
    }

    const templateRules = this.rules.templates[templateType];
    if (!templateRules) {
      result.errors.push(`알 수 없는 템플릿 타입: ${templateType}`);
      result.valid = false;
      return result;
    }

    // 제목 검증
    if (prTitle && templateRules.title) {
      const titleRegex = new RegExp(templateRules.title);
      if (!titleRegex.test(prTitle)) {
        result.errors.push(`PR 제목이 ${templateType} 템플릿의 규칙에 맞지 않습니다. 예상 패턴: ${templateRules.title}`);
      }
    }

    // 필수 섹션 검증
    for (const section of templateRules.required_sections) {
      const sectionContent = this.extractSection(prBody, section);
      
      if (!sectionContent) {
        result.errors.push(`필수 섹션이 누락됨: ${section}`);
        continue;
      }

      // 섹션별 규칙 검증
      const sectionRules = templateRules.validation_rules[section];
      if (sectionRules) {
        // 길이 검증
        if (sectionRules.min_length) {
          const lengthResult = this.validateLength(sectionContent, sectionRules.min_length);
          if (!lengthResult.valid) {
            result.errors.push(...lengthResult.errors.map(err => `[${section}] ${err}`));
          }
        }

        // 체크박스 검증
        if (sectionRules.required_checkboxes) {
          const checkboxResult = this.validateCheckboxes(sectionContent, sectionRules.required_checkboxes);
          if (!checkboxResult.valid) {
            result.errors.push(...checkboxResult.errors.map(err => `[${section}] ${err}`));
          }
        }

        // 필수 필드 검증
        if (sectionRules.required_fields) {
          const fieldsResult = this.validateRequiredFields(sectionContent, sectionRules.required_fields);
          if (!fieldsResult.valid) {
            result.errors.push(...fieldsResult.errors.map(err => `[${section}] ${err}`));
          }
        }
      }
    }

    result.valid = result.errors.length === 0;
    return result;
  }
}

// 스크립트 실행 부분
async function main() {
  try {
    const prBody = process.env.PR_BODY || '';
    const prTitle = process.env.PR_TITLE || '';
    const rulesPath = path.join(process.cwd(), '.github/pr-lint/rules.json');
    
    if (!fs.existsSync(rulesPath)) {
      console.error('❌ 규칙 파일을 찾을 수 없습니다:', rulesPath);
      process.exit(1);
    }

    const checker = new PRLintChecker(rulesPath);
    const result = checker.validate(prBody, prTitle);

    console.log('🔍 PR 본문 검증 결과');
    console.log('==================');
    
    if (result.template) {
      console.log(`📋 감지된 템플릿: ${result.template}`);
    }

    if (result.valid) {
      console.log('✅ 모든 검증을 통과했습니다!');
    } else {
      console.log('❌ 검증 실패:');
      result.errors.forEach(error => console.log(`  - ${error}`));
    }

    if (result.warnings.length > 0) {
      console.log('⚠️  경고:');
      result.warnings.forEach(warning => console.log(`  - ${warning}`));
    }

    // GitHub Actions 출력
    if (process.env.GITHUB_ACTIONS) {
      console.log(`::set-output name=valid::${result.valid}`);
      console.log(`::set-output name=template::${result.template || 'unknown'}`);
      console.log(`::set-output name=errors::${result.errors.join('\\n')}`);
    }

    process.exit(result.valid ? 0 : 1);
  } catch (error) {
    console.error('❌ 스크립트 실행 중 오류 발생:', error.message);
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
