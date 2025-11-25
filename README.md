# My Star

React + TypeScript + Vite 프로젝트로 FSD (Feature-Sliced Design) 아키텍처를 적용했습니다.

## 기술 스택

- **Node.js v22.14.0** - JavaScript 런타임
- **pnpm** - 패키지 매니저
- **React 19** - UI 라이브러리
- **TypeScript** - 타입 안정성
- **Vite** - 빌드 도구 (Rolldown-Vite 사용)
- **Tailwind CSS v4** - 스타일링
- **shadcn/ui** - UI 컴포넌트
- **Supabase** - 인증 및 백엔드
- **React Router** - 라우팅
- **FSD** - 아키텍처 패턴

## 프로젝트 구조

FSD (Feature-Sliced Design) 아키텍처를 사용합니다. 자세한 내용은 [README-FSD.md](./README-FSD.md)를 참고하세요.

```
src/
├── app/         # 애플리케이션 초기화
├── pages/       # 페이지 컴포넌트
├── widgets/     # 복합 UI 위젯
├── features/    # 비즈니스 기능
├── entities/    # 비즈니스 엔티티
└── shared/      # 공유 리소스
```

## 시작하기

### 필수 요구사항

- **Node.js v22.14.0** 이상
- **pnpm** (권장)

### Node.js 설치 (NVM 사용)

프로젝트는 Node.js v22.14.0을 사용합니다. NVM을 통해 설치하는 것을 권장합니다:

```bash
# NVM으로 Node.js 설치
nvm install 22.14.0
nvm use 22.14.0

# Node 버전 확인
node --version  # v22.14.0
```

### pnpm 설치

```bash
npm install -g pnpm
```

### 프로젝트 설치

```bash
# 1. 의존성 패키지 설치
pnpm install

# 2. Supabase 및 추가 패키지 설치
pnpm add @supabase/supabase-js react-router-dom @radix-ui/react-label

# 3. 환경 변수 설정
cp .env.example .env
# .env 파일을 열어 Supabase 정보 입력
```

### 터미널에서 개발 서버 실행

#### 방법 1: pnpm 사용 (권장)

```bash
pnpm dev
```

#### 방법 2: zsh/bash에서 직접 실행

```bash
# Node.js 환경 로드 (필요한 경우)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22.14.0

# 개발 서버 실행
pnpm dev
```

개발 서버가 시작되면 브라우저에서 http://localhost:5173 으로 접속하세요.

### 빌드

```bash
pnpm build
```

### 프리뷰

```bash
pnpm preview
```

## 개발 가이드

### Path Aliases

프로젝트는 FSD 레이어별 path aliases를 사용합니다:

```typescript
@/app/*       → src/app/*
@/pages/*     → src/pages/*
@/widgets/*   → src/widgets/*
@/features/*  → src/features/*
@/entities/*  → src/entities/*
@/shared/*    → src/shared/*
```

### 코드 스타일

```bash
pnpm lint
```

### 아키텍처 가이드

FSD 아키텍처에 대한 자세한 내용은 [README-FSD.md](./README-FSD.md)를 참고하세요.

### Supabase 설정

Supabase 인증 설정에 대한 자세한 내용은 [SETUP.md](./SETUP.md)를 참고하세요.

## 주요 기능

### 🔐 인증 시스템
- **회원가입** (`/auth/signup`): 이메일/비밀번호 기반 회원가입
  - 비밀번호 확인 검증
  - 이메일 인증 (Supabase 자동 발송)
  - 입력 유효성 검사
- **로그인** (`/auth/login`): Supabase Auth를 통한 안전한 인증
  - 세션 관리
  - 에러 핸들링
  - 자동 리다이렉션
- **비밀번호 찾기** (`/auth/forgot-password`): 이메일로 재설정 링크 전송
  - 이메일 주소 입력
  - Supabase를 통한 안전한 재설정 링크 발송
  - 상세한 안내 메시지
- **비밀번호 재설정** (`/auth/reset-password`): 새 비밀번호 설정
  - 이메일 링크를 통한 안전한 인증
  - 비밀번호 확인 검증
  - 자동 로그인 페이지 리다이렉션
- **보안**: Row Level Security (RLS) 지원

#### 인증 플로우
```
회원가입 → 이메일 확인 → 로그인
                          ↓
                    비밀번호 찾기 → 이메일 확인 → 비밀번호 재설정 → 로그인
```

### 🎨 UI/UX
- **shadcn/ui**: 모던하고 접근성이 좋은 컴포넌트
  - Card, Input, Label, Button 등
- **Tailwind CSS v4**: 유틸리티 우선 스타일링
- **반응형 디자인**: 모바일 친화적인 레이아웃

### 🏗️ 아키텍처
- **FSD (Feature-Sliced Design)**: 확장 가능한 프로젝트 구조
  - 명확한 레이어 분리
  - 의존성 규칙 준수
  - 코드 재사용성 향상
- **Type Safety**: TypeScript로 타입 안정성 보장
- **React Router**: 선언적 라우팅

### ⚡ 성능
- **Vite (Rolldown)**: 빠른 빌드 및 HMR
- **React 19**: 최신 React 기능 활용
- **코드 스플리팅**: 최적화된 번들 크기

## 주요 페이지

### 메인
- **홈**: http://localhost:5173/

### 인증 (Auth)
- **로그인**: http://localhost:5173/auth/login
- **회원가입**: http://localhost:5173/auth/signup
- **비밀번호 찾기**: http://localhost:5173/auth/forgot-password
- **비밀번호 재설정**: http://localhost:5173/auth/reset-password

> 💡 레거시 경로(`/login`, `/signup`)도 호환성을 위해 지원됩니다.

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
