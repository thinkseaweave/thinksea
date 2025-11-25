# Supabase 인증 설정 가이드

## 1. 패키지 설치

터미널에서 다음 명령어를 실행하세요:

```bash
chmod +x install-deps.sh
./install-deps.sh
```

또는 수동으로 설치:

```bash
pnpm add @supabase/supabase-js react-router-dom @radix-ui/react-label
```

## 2. Supabase 프로젝트 설정

1. [Supabase](https://supabase.com)에 접속하여 계정을 만들고 새 프로젝트를 생성합니다.
2. 프로젝트 대시보드에서 **Settings** > **API**로 이동합니다.
3. 다음 정보를 복사합니다:
   - `Project URL`
   - `anon public` API key

## 3. 환경 변수 설정

프로젝트 루트 디렉토리에 `.env` 파일을 생성하고 다음 내용을 추가합니다:

```bash
cp .env.example .env
```

`.env` 파일을 열고 Supabase 정보를 입력합니다:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

## 4. Supabase Authentication 설정

Supabase 대시보드에서:

1. **Authentication** > **Providers**로 이동
2. **Email** provider가 활성화되어 있는지 확인
3. **Email Templates**에서 이메일 확인 템플릿을 커스터마이징할 수 있습니다

## 5. 개발 서버 실행

```bash
pnpm dev
```

브라우저에서 다음 페이지들을 확인할 수 있습니다:

- 홈페이지: http://localhost:5173/
- 로그인: http://localhost:5173/login
- 회원가입: http://localhost:5173/signup

## 프로젝트 구조

```
src/
├── app/
│   ├── providers/
│   │   └── router.tsx          # React Router 설정
│   ├── styles/
│   └── main.tsx
├── pages/
│   ├── home/
│   ├── login/
│   │   └── LoginPage.tsx       # 로그인 페이지
│   └── signup/
│       └── SignupPage.tsx      # 회원가입 페이지
├── features/
│   └── auth/
│       ├── login/
│       │   └── ui/
│       │       └── LoginForm.tsx    # 로그인 폼 컴포넌트
│       └── signup/
│           └── ui/
│               └── SignupForm.tsx   # 회원가입 폼 컴포넌트
├── entities/
│   └── user/
│       ├── api/
│       │   └── authApi.ts      # Supabase Auth API
│       └── model/
│           └── types.ts        # User 타입 정의
└── shared/
    ├── config/
    │   └── supabase.ts         # Supabase 클라이언트 설정
    ├── ui/                     # shadcn/ui 컴포넌트
    │   ├── button.tsx
    │   ├── card.tsx
    │   ├── input.tsx
    │   └── label.tsx
    └── lib/
        └── utils.ts

```

## 주요 기능

### 회원가입
- 이메일/비밀번호로 계정 생성
- 비밀번호 확인 검증
- 이메일 인증 (Supabase에서 자동 발송)

### 로그인
- 이메일/비밀번호 인증
- 에러 핸들링
- 로그인 후 홈페이지로 리다이렉트

### 보안
- Supabase Auth를 통한 안전한 인증
- 환경 변수를 통한 API 키 관리
- Row Level Security (RLS) 지원

## 추가 개발 가이드

### 사용자 정보 가져오기

```typescript
import { authApi } from '@/entities/user';

// 현재 로그인한 사용자 정보
const user = await authApi.getCurrentUser();
```

### 로그아웃

```typescript
import { authApi } from '@/entities/user';

await authApi.signOut();
```

### Auth 상태 변화 구독

```typescript
import { authApi } from '@/entities/user';

const { data: { subscription } } = authApi.onAuthStateChange((user) => {
  console.log('User:', user);
});

// 구독 해제
subscription.unsubscribe();
```

## 문제 해결

### "Missing Supabase environment variables" 에러
- `.env` 파일이 생성되었는지 확인
- 환경 변수가 `VITE_` 접두사로 시작하는지 확인
- 개발 서버를 재시작

### 이메일이 발송되지 않음
- Supabase 대시보드에서 Email Provider가 활성화되어 있는지 확인
- 개발 환경에서는 Supabase가 제공하는 메일 서비스 사용
- 프로덕션 환경에서는 SMTP 설정 필요

### 회원가입 후 로그인이 안됨
- 이메일 확인이 필요한지 Supabase 설정 확인
- **Authentication** > **Settings**에서 "Enable email confirmations" 설정 확인
