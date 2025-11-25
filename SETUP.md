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

## 가입된 사용자 데이터 확인

### 방법 1: Authentication 대시보드 (추천)

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. 프로젝트 선택
3. 왼쪽 메뉴에서 **Authentication** 클릭
4. **Users** 탭 선택
5. 모든 가입된 사용자 정보 확인:
   - 이메일
   - 가입 일시 (created_at)
   - 마지막 로그인 시간 (last_sign_in_at)
   - 이메일 확인 상태 (email_confirmed_at)
   - User ID (UUID)

### 방법 2: Table Editor

1. 왼쪽 메뉴에서 **Table Editor** 클릭
2. 스키마: `auth` 선택
3. `users` 테이블에서 모든 사용자 데이터 확인

### 방법 3: SQL Editor로 쿼리

왼쪽 메뉴 **SQL Editor**에서 다음 쿼리 실행:

```sql
-- 모든 사용자 조회
SELECT * FROM auth.users;

-- 특정 정보만 조회
SELECT
  id,
  email,
  created_at,
  last_sign_in_at,
  email_confirmed_at
FROM auth.users
ORDER BY created_at DESC;

-- 최근 가입한 사용자 5명
SELECT
  email,
  created_at,
  CASE
    WHEN email_confirmed_at IS NOT NULL THEN '확인됨'
    ELSE '미확인'
  END as email_status
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
```

### 사용자 관리

**Authentication > Users** 페이지에서:
- **Add user**: 사용자 수동 추가
- **...** 메뉴: 사용자 삭제, 비밀번호 재설정 등

### 개발 팁: 이메일 확인 비활성화

테스트 중 이메일 확인을 건너뛰려면:

1. **Authentication** > **Settings** 이동
2. "Enable email confirmations" 체크 해제
3. 이제 회원가입 시 즉시 로그인 가능

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
