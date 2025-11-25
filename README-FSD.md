# FSD (Feature-Sliced Design) 구조

이 프로젝트는 Feature-Sliced Design 아키텍처를 따릅니다.

## 폴더 구조

```
src/
├── app/                    # 애플리케이션 초기화 레이어
│   ├── providers/         # 전역 Provider (Context, Router, Store 등)
│   ├── styles/            # 전역 스타일
│   └── main.tsx           # 애플리케이션 진입점
│
├── pages/                  # 페이지 레이어
│   └── home/              # 홈 페이지
│       ├── App.tsx
│       └── index.ts
│
├── widgets/                # 위젯 레이어 (복합 컴포넌트)
│
├── features/               # 기능 레이어 (비즈니스 기능)
│
├── entities/               # 엔티티 레이어 (비즈니스 엔티티)
│
└── shared/                 # 공유 레이어
    ├── ui/                # UI 컴포넌트 (Button, Input 등)
    ├── lib/               # 유틸리티 함수
    ├── config/            # 설정 파일
    └── assets/            # 정적 파일 (이미지, 폰트 등)
```

## FSD 레이어 설명

### 1. App (애플리케이션)
- 앱 초기화 로직
- 전역 Provider 설정
- 라우팅 설정
- 전역 스타일

### 2. Pages (페이지)
- 라우팅 페이지
- 각 페이지는 widgets, features, entities를 조합

### 3. Widgets (위젯)
- 여러 features와 entities를 조합한 복합 컴포넌트
- 예: Header, Footer, Sidebar

### 4. Features (기능)
- 사용자 시나리오와 비즈니스 기능
- 예: 로그인, 댓글 작성, 상품 필터링

### 5. Entities (엔티티)
- 비즈니스 엔티티
- 예: User, Product, Order

### 6. Shared (공유)
- 재사용 가능한 컴포넌트, 유틸리티, 설정
- 비즈니스 로직이 없는 순수한 공유 코드

## Import 규칙

### 허용되는 Import
- 하위 레이어 → 상위 레이어 ❌
- 상위 레이어 → 하위 레이어 ✅
- 같은 레이어 내 다른 슬라이스 ❌ (특별한 경우 제외)

### Import 순서
```
app → pages → widgets → features → entities → shared
```

### 예시
```typescript
// ✅ Good: pages에서 shared 사용
import { Button } from '@/shared/ui';

// ✅ Good: pages에서 features 사용
import { LoginForm } from '@/features/auth';

// ❌ Bad: shared에서 features 사용
import { LoginForm } from '@/features/auth'; // in shared layer

// ❌ Bad: features에서 pages 사용
import { HomePage } from '@/pages/home'; // in features layer
```

## Path Aliases

프로젝트는 다음과 같은 path aliases를 사용합니다:

```typescript
@/app/*       → src/app/*
@/pages/*     → src/pages/*
@/widgets/*   → src/widgets/*
@/features/*  → src/features/*
@/entities/*  → src/entities/*
@/shared/*    → src/shared/*
```

## 새로운 기능 추가하기

1. **Shared 컴포넌트**: `src/shared/ui/` 에 추가
2. **비즈니스 엔티티**: `src/entities/` 에 추가
3. **사용자 기능**: `src/features/` 에 추가
4. **복합 컴포넌트**: `src/widgets/` 에 추가
5. **새로운 페이지**: `src/pages/` 에 추가

## 참고 자료

- [Feature-Sliced Design 공식 문서](https://feature-sliced.design/)
