# GitHub 저장소 업데이트 가이드

기존 GitHub 저장소(https://github.com/thinkseaweave/thinksea)의 내용을 삭제하고 현재 프로젝트로 교체하는 방법입니다.

## 옵션 1: 기존 저장소의 모든 히스토리 삭제하고 새로 시작 (권장)

### 1. Git 저장소 초기화

```bash
# 현재 디렉토리에서 git 초기화
git init

# 모든 파일 스테이징
git add .

# 첫 커밋 생성
git commit -m "Initial commit: FSD architecture with Supabase auth

- Feature-Sliced Design (FSD) 아키텍처 적용
- Supabase 인증 시스템 구현 (로그인/회원가입)
- shadcn/ui 컴포넌트 통합
- React Router 라우팅 설정
- Tailwind CSS v4 스타일링"
```

### 2. GitHub 저장소 연결 및 강제 푸시

```bash
# 원격 저장소 추가
git remote add origin https://github.com/thinkseaweave/thinksea.git

# 기존 내용을 완전히 덮어쓰기 (주의: 기존 히스토리가 모두 삭제됩니다)
git push -u origin main --force
```

**⚠️ 주의**: `--force` 옵션은 기존 저장소의 모든 내용과 히스토리를 삭제합니다. 기존 데이터가 필요하다면 먼저 백업하세요.

### 3. 브랜치가 main이 아닌 경우

기존 저장소가 `master` 브랜치를 사용한다면:

```bash
# 현재 브랜치 이름 확인
git branch

# master 브랜치로 푸시
git branch -M main  # 현재 브랜치를 main으로 이름 변경
git push -u origin main --force

# 또는 master 브랜치로 직접 푸시
git push -u origin master --force
```

## 옵션 2: 기존 저장소 복제 후 내용 교체

### 1. 기존 저장소 복제 (임시 디렉토리)

```bash
cd ..
git clone https://github.com/thinkseaweave/thinksea.git thinksea-backup
cd thinksea-backup

# 기존 내용 모두 삭제 (숨김 파일 제외)
rm -rf *

# my-star 프로젝트 내용 복사
cp -r ../my-star/* .
cp ../my-star/.gitignore .
cp ../my-star/.env.example .

# 변경사항 커밋
git add .
git commit -m "Refactor: Complete project restructure with FSD architecture"

# 푸시
git push origin main
```

## 옵션 3: GitHub에서 저장소 삭제 후 새로 생성

### 1. GitHub에서 저장소 삭제

1. https://github.com/thinkseaweave/thinksea/settings 접속
2. 페이지 맨 아래 "Danger Zone" 섹션으로 이동
3. "Delete this repository" 클릭
4. 저장소 이름 입력 후 확인

### 2. 새 저장소 생성

1. GitHub에서 "New repository" 클릭
2. Repository name: `thinksea`
3. 다른 옵션은 기본값 유지
4. "Create repository" 클릭

### 3. 로컬에서 푸시

```bash
# Git 초기화 (my-star 디렉토리에서)
git init
git add .
git commit -m "Initial commit: FSD architecture with Supabase auth"

# 원격 저장소 추가 및 푸시
git remote add origin https://github.com/thinkseaweave/thinksea.git
git branch -M main
git push -u origin main
```

## 푸시 전 확인사항

### 1. 민감한 정보 확인

```bash
# .env 파일이 .gitignore에 포함되어 있는지 확인
cat .gitignore | grep .env

# Git에 추가될 파일 확인
git status
```

### 2. 커밋하지 말아야 할 파일들

다음 파일들이 `.gitignore`에 포함되어 있는지 확인:
- `.env`
- `.env.local`
- `.env.production`
- `node_modules/`
- `dist/`

## 푸시 후 확인사항

### 1. GitHub Actions 설정 (선택사항)

저장소에 CI/CD를 추가하려면 `.github/workflows` 디렉토리를 생성하세요.

### 2. README.md 확인

GitHub에서 README.md가 제대로 표시되는지 확인하세요.

### 3. .env.example 확인

협업자들이 `.env.example`을 복사하여 사용할 수 있도록 파일이 커밋되었는지 확인하세요.

## 협업자 안내

다른 개발자들이 프로젝트를 클론할 때:

```bash
# 저장소 클론
git clone https://github.com/thinkseaweave/thinksea.git
cd thinksea

# Node.js 버전 설정
nvm use 22.14.0

# 의존성 설치
pnpm install
pnpm add @supabase/supabase-js react-router-dom @radix-ui/react-label

# 환경 변수 설정
cp .env.example .env
# .env 파일 편집하여 Supabase 정보 입력

# 개발 서버 실행
pnpm dev
```

## 문제 해결

### "Permission denied" 에러

SSH 키 설정이 필요할 수 있습니다:

```bash
# SSH 키 생성
ssh-keygen -t ed25519 -C "your_email@example.com"

# SSH 키를 GitHub에 추가
cat ~/.ssh/id_ed25519.pub
# 출력된 내용을 GitHub Settings > SSH Keys에 추가

# SSH URL 사용
git remote set-url origin git@github.com:thinkseaweave/thinksea.git
```

### "Authentication failed" 에러

Personal Access Token이 필요할 수 있습니다:

1. GitHub Settings > Developer settings > Personal access tokens
2. "Generate new token" 클릭
3. 필요한 권한 선택 (repo)
4. 토큰 생성 후 복사
5. Git 푸시 시 비밀번호 대신 토큰 사용
