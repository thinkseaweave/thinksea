# 프로젝트 설정 가이드

My Star 프로젝트의 초기 설정 방법입니다.

## 📦 1. 패키지 설치

### 기본 패키지 설치

```bash
pnpm install
```

### 추가 패키지 설치

```bash
pnpm add @supabase/supabase-js react-router-dom @radix-ui/react-label
```

또는 자동 설치 스크립트 사용:

```bash
chmod +x install-deps.sh
./install-deps.sh
```

---

## 🔧 2. 환경 변수 설정

### `.env` 파일 생성

```bash
cp .env.example .env
```

### Supabase 정보 입력

`.env` 파일을 열고 다음 정보를 입력하세요:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Supabase 프로젝트 정보 얻기

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. 프로젝트 선택
3. **Settings** > **API** 이동
4. 다음 정보 복사:
   - `Project URL`
   - `anon public` API key

---

## 🔐 3. Supabase Authentication 설정

### 필수 설정

Supabase 대시보드에서:

1. **Authentication** > **Providers**
   - Email provider 활성화 확인

2. **Authentication** > **URL Configuration**
   - **Site URL**: `http://localhost:5173`
   - **Redirect URLs**에 추가:
     ```
     http://localhost:5173/**
     http://localhost:5173/auth/reset-password
     ```

---

## 🚀 4. 개발 서버 실행

```bash
pnpm dev
```

브라우저에서 다음 주소로 접속:

- **홈페이지**: http://localhost:5173/
- **로그인**: http://localhost:5173/auth/login
- **회원가입**: http://localhost:5173/auth/signup

---

## 📁 5. 프로젝트 구조

FSD (Feature-Sliced Design) 아키텍처를 사용합니다:

```
src/
├── app/         # 애플리케이션 초기화 및 프로바이더
├── pages/       # 페이지 컴포넌트
├── features/    # 비즈니스 기능 (auth, etc.)
├── entities/    # 비즈니스 엔티티 (user, etc.)
└── shared/      # 공유 리소스 (ui, config, etc.)
```

자세한 내용은 [README-FSD.md](./README-FSD.md)를 참고하세요.

---

## 🔍 추가 리소스

- **Supabase 설정**: [Supabase 공식 문서](https://supabase.com/docs)
- **FSD 아키텍처**: [README-FSD.md](./README-FSD.md)
- **기여 가이드**: [README.md](./README.md#기여하기)

---

## ❓ 문제 해결

### "Missing Supabase environment variables" 에러

- `.env` 파일이 프로젝트 루트에 있는지 확인
- 환경 변수가 `VITE_` 접두사로 시작하는지 확인
- 개발 서버를 재시작: `pnpm dev`

### 이메일이 발송되지 않음

- Supabase Dashboard > **Authentication** > **Providers**에서 Email 활성화 확인
- 스팸 메일함 확인

### 회원가입 후 로그인이 안됨

- **Authentication** > **Settings**에서 "Enable email confirmations" 설정 확인
- 테스트 중이라면 이 옵션을 끄면 즉시 로그인 가능

---

설정 완료 후 [README.md](./README.md)에서 프로젝트의 전체 기능을 확인하세요.
