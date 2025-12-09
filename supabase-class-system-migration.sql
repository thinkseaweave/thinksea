-- ============================================
-- 클래스 시스템 마이그레이션 SQL
-- ============================================
-- 기존 class_master를 classes로 리네임하고 확장된 클래스 시스템 구축
--
-- 실행 순서:
-- 1. 함수 생성 (updated_at 자동 업데이트)
-- 2. 기존 테이블 백업 및 마이그레이션
-- 3. 새로운 테이블 생성
-- 4. 외래키 및 제약조건 설정

-- ============================================
-- 1. updated_at 자동 업데이트 함수 생성
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2. 클래스 계열 테이블
-- ============================================
-- 궁수계열, 힐러계열, 도적계열, 전사계열 등
CREATE TABLE IF NOT EXISTS class_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE, -- '궁수계열', '힐러계열', '도적계열', '전사계열'
  code TEXT NOT NULL UNIQUE, -- 'ARCHER', 'HEALER', 'ROGUE', 'WARRIOR' (내부용)
  icon_url TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_class_categories_updated_at
  BEFORE UPDATE ON class_categories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 3. 클래스 마스터 테이블 (기존 class_master 확장)
-- ============================================
-- 기존 class_master 테이블이 있다면 백업
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'class_master') THEN
    -- 백업 테이블 생성
    EXECUTE 'CREATE TABLE class_master_backup_' || to_char(NOW(), 'YYYYMMDD_HH24MISS') || ' AS SELECT * FROM class_master';
    RAISE NOTICE 'class_master 테이블이 백업되었습니다.';
  END IF;
END $$;

-- 새로운 classes 테이블 생성
CREATE TABLE IF NOT EXISTS classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES class_categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL, -- '견습궁수', '궁수', '장궁병', '석궁사수' 등
  code TEXT NOT NULL UNIQUE, -- 'APPRENTICE_ARCHER', 'ARCHER', 'LONGBOWMAN', 'CROSSBOWMAN' (내부용)

  -- 클래스 타입
  is_beginner BOOLEAN DEFAULT false, -- 견습 클래스 여부 (true면 전직 전 클래스)

  -- 전직 관련
  promotion_level INT, -- 전직 가능 레벨 (is_beginner=true인 클래스의 경우 필수)
  promoted_from UUID REFERENCES classes(id) ON DELETE SET NULL, -- 어떤 클래스에서 전직했는지

  -- 장비 요구사항
  required_weapon_type TEXT, -- 필요 무기 타입: 'BOW', 'STAFF', 'DAGGER', 'SWORD' 등

  -- UI 관련
  icon_url TEXT,
  emblem_icon_url TEXT, -- 클래스 엠블럼 아이콘
  description TEXT,
  display_order INT DEFAULT 0, -- 정렬 순서

  -- 레벨 관련
  max_level INT DEFAULT 65 CHECK (max_level > 0), -- 클래스 최대 레벨

  -- 활성화 여부
  is_active BOOLEAN DEFAULT true, -- 비활성화된 클래스는 선택 불가

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 제약조건: 견습 클래스는 반드시 promotion_level이 있어야 함
  CONSTRAINT check_beginner_promotion_level
    CHECK (is_beginner = false OR promotion_level IS NOT NULL)
);

-- 인덱스
CREATE INDEX idx_classes_category ON classes(category_id);
CREATE INDEX idx_classes_is_beginner ON classes(is_beginner);
CREATE INDEX idx_classes_promoted_from ON classes(promoted_from);

-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_classes_updated_at
  BEFORE UPDATE ON classes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 4. 스킬 마스터 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,

  -- 스킬 타입
  skill_type TEXT NOT NULL CHECK (skill_type IN ('active', 'passive', 'ultimate')),
  slot_number INT CHECK (slot_number BETWEEN 1 AND 6), -- 1~5: 액티브, 6: 궁극기, NULL: 패시브

  -- 스킬 정보
  name TEXT NOT NULL,
  code TEXT NOT NULL, -- 'POWER_SHOT', 'HEALING_WAVE' 등 (내부용)
  description TEXT,

  -- 스킬 수치
  cooldown INT DEFAULT 0, -- 쿨타임 (초)
  mp_cost INT DEFAULT 0, -- 마나 소비량
  damage_multiplier DECIMAL(5,2), -- 데미지 배율 (예: 1.5 = 150%)
  healing_multiplier DECIMAL(5,2), -- 힐링 배율

  -- 궁극기 요구사항
  requires_emblem BOOLEAN DEFAULT false, -- true면 클래스 엠블럼 필요 (궁극기)

  -- UI 관련
  icon_url TEXT,
  animation_url TEXT, -- 스킬 애니메이션

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 유니크 제약: 같은 클래스, 같은 슬롯에 중복 불가
  CONSTRAINT unique_class_slot UNIQUE (class_id, slot_number),
  -- 제약조건: 궁극기는 6번 슬롯이어야 함
  CONSTRAINT check_ultimate_slot
    CHECK (skill_type != 'ultimate' OR slot_number = 6),
  -- 제약조건: 패시브는 슬롯이 없어야 함
  CONSTRAINT check_passive_no_slot
    CHECK (skill_type != 'passive' OR slot_number IS NULL)
);

-- 인덱스
CREATE INDEX idx_skills_class ON skills(class_id);
CREATE INDEX idx_skills_type ON skills(skill_type);

-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_skills_updated_at
  BEFORE UPDATE ON skills
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 5. 스킬 태그 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS skill_tags (
  skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
  tag TEXT NOT NULL, -- 'CC', 'DOT', 'AOE', 'HEAL', 'BUFF', 'DEBUFF', 'DAMAGE' 등
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (skill_id, tag)
);

-- 인덱스
CREATE INDEX idx_skill_tags_tag ON skill_tags(tag);

-- ============================================
-- 6. 유저 클래스 정보 테이블
-- ============================================
-- 유저가 보유하고 있는 클래스들과 레벨, 엠블럼 소유 여부
CREATE TABLE IF NOT EXISTS user_classes (
  user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,

  -- 레벨 및 경험치
  level INT DEFAULT 1 CHECK (level >= 1 AND level <= 65),
  experience INT DEFAULT 0 CHECK (experience >= 0),

  -- 엠블럼 소유 여부 (전직 시 획득)
  has_emblem BOOLEAN DEFAULT false,
  emblem_acquired_at TIMESTAMPTZ, -- 엠블럼 획득 시간

  -- 장착 여부
  is_equipped BOOLEAN DEFAULT false, -- 현재 장착 중인 클래스인지

  -- 획득 및 업데이트 시간
  acquired_at TIMESTAMPTZ DEFAULT NOW(), -- 클래스 획득 시간
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  PRIMARY KEY (user_id, class_id),

  -- 제약조건: 유저당 하나의 클래스만 장착 가능
  CONSTRAINT unique_equipped_class UNIQUE NULLS NOT DISTINCT (user_id, CASE WHEN is_equipped THEN true END)
);

-- 인덱스
CREATE INDEX idx_user_classes_user ON user_classes(user_id);
CREATE INDEX idx_user_classes_equipped ON user_classes(user_id, is_equipped) WHERE is_equipped = true;

-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_user_classes_updated_at
  BEFORE UPDATE ON user_classes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 7. 샘플 데이터 삽입
-- ============================================

-- 클래스 계열 삽입
INSERT INTO class_categories (name, code, description) VALUES
  ('궁수계열', 'ARCHER', '활과 원거리 무기를 사용하는 클래스'),
  ('힐러계열', 'HEALER', '아군을 치료하고 지원하는 클래스'),
  ('도적계열', 'ROGUE', '빠른 스피드와 암습을 사용하는 클래스'),
  ('전사계열', 'WARRIOR', '강력한 방어력과 근접 전투를 하는 클래스')
ON CONFLICT (code) DO NOTHING;

-- 견습 클래스 삽입 (시작 클래스)
INSERT INTO classes (category_id, name, code, is_beginner, promotion_level, required_weapon_type, description) VALUES
  (
    (SELECT id FROM class_categories WHERE code = 'ARCHER'),
    '견습궁수',
    'APPRENTICE_ARCHER',
    true,
    10,
    'BOW',
    '궁수의 길을 걷기 시작한 초보자'
  ),
  (
    (SELECT id FROM class_categories WHERE code = 'HEALER'),
    '견습힐러',
    'APPRENTICE_HEALER',
    true,
    10,
    'STAFF',
    '치유의 힘을 배우기 시작한 초보자'
  ),
  (
    (SELECT id FROM class_categories WHERE code = 'ROGUE'),
    '견습도적',
    'APPRENTICE_ROGUE',
    true,
    10,
    'DAGGER',
    '은밀함의 기술을 익히는 초보자'
  ),
  (
    (SELECT id FROM class_categories WHERE code = 'WARRIOR'),
    '견습전사',
    'APPRENTICE_WARRIOR',
    true,
    10,
    'SWORD',
    '전장의 기본을 배우는 초보자'
  )
ON CONFLICT (code) DO NOTHING;

-- 궁수 계열 전직 클래스
INSERT INTO classes (category_id, name, code, is_beginner, promoted_from, required_weapon_type, description) VALUES
  (
    (SELECT id FROM class_categories WHERE code = 'ARCHER'),
    '궁수',
    'ARCHER',
    false,
    (SELECT id FROM classes WHERE code = 'APPRENTICE_ARCHER'),
    'BOW',
    '정확한 조준과 빠른 공격이 특징인 기본 궁수'
  ),
  (
    (SELECT id FROM class_categories WHERE code = 'ARCHER'),
    '장궁병',
    'LONGBOWMAN',
    false,
    (SELECT id FROM classes WHERE code = 'APPRENTICE_ARCHER'),
    'LONGBOW',
    '긴 사정거리와 강력한 관통력을 가진 궁수'
  ),
  (
    (SELECT id FROM class_categories WHERE code = 'ARCHER'),
    '석궁사수',
    'CROSSBOWMAN',
    false,
    (SELECT id FROM classes WHERE code = 'APPRENTICE_ARCHER'),
    'CROSSBOW',
    '높은 명중률과 치명타가 특징인 석궁 전문가'
  )
ON CONFLICT (code) DO NOTHING;

-- 샘플 스킬 (궁수 클래스)
DO $$
DECLARE
  archer_id UUID;
BEGIN
  SELECT id INTO archer_id FROM classes WHERE code = 'ARCHER';

  -- 액티브 스킬 1-5
  INSERT INTO skills (class_id, skill_type, slot_number, name, code, description, cooldown, damage_multiplier) VALUES
    (archer_id, 'active', 1, '파워 샷', 'POWER_SHOT', '강력한 화살을 발사합니다', 5, 1.5),
    (archer_id, 'active', 2, '다중 화살', 'MULTI_ARROW', '여러 개의 화살을 동시에 발사합니다', 8, 0.8),
    (archer_id, 'active', 3, '후퇴', 'RETREAT', '뒤로 빠르게 이동합니다', 10, NULL),
    (archer_id, 'active', 4, '독 화살', 'POISON_ARROW', '독을 묻힌 화살을 발사합니다', 12, 1.2),
    (archer_id, 'active', 5, '조준', 'AIM', '다음 공격의 명중률과 치명타율이 증가합니다', 15, NULL);

  -- 궁극기
  INSERT INTO skills (class_id, skill_type, slot_number, name, code, description, cooldown, damage_multiplier, requires_emblem) VALUES
    (archer_id, 'ultimate', 6, '화살 폭풍', 'ARROW_STORM', '하늘에서 수많은 화살이 비처럼 쏟아집니다', 60, 3.0, true);

  -- 패시브 스킬
  INSERT INTO skills (class_id, skill_type, slot_number, name, code, description) VALUES
    (archer_id, 'passive', NULL, '날카로운 시야', 'SHARP_SIGHT', '치명타 확률이 10% 증가합니다'),
    (archer_id, 'passive', NULL, '민첩성', 'AGILITY', '이동 속도가 5% 증가합니다');

  -- 스킬 태그 추가
  INSERT INTO skill_tags (skill_id, tag) VALUES
    ((SELECT id FROM skills WHERE code = 'POWER_SHOT'), 'DAMAGE'),
    ((SELECT id FROM skills WHERE code = 'POWER_SHOT'), 'SINGLE_TARGET'),
    ((SELECT id FROM skills WHERE code = 'MULTI_ARROW'), 'DAMAGE'),
    ((SELECT id FROM skills WHERE code = 'MULTI_ARROW'), 'AOE'),
    ((SELECT id FROM skills WHERE code = 'RETREAT'), 'MOBILITY'),
    ((SELECT id FROM skills WHERE code = 'POISON_ARROW'), 'DAMAGE'),
    ((SELECT id FROM skills WHERE code = 'POISON_ARROW'), 'DOT'),
    ((SELECT id FROM skills WHERE code = 'AIM'), 'BUFF'),
    ((SELECT id FROM skills WHERE code = 'ARROW_STORM'), 'DAMAGE'),
    ((SELECT id FROM skills WHERE code = 'ARROW_STORM'), 'AOE'),
    ((SELECT id FROM skills WHERE code = 'ARROW_STORM'), 'ULTIMATE');
END $$;

-- ============================================
-- 8. RLS (Row Level Security) 설정
-- ============================================

-- class_categories, classes, skills, skill_tags는 모두가 읽을 수 있음
ALTER TABLE class_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_classes ENABLE ROW LEVEL SECURITY;

-- 마스터 데이터는 누구나 읽기 가능
CREATE POLICY "Anyone can read class categories" ON class_categories FOR SELECT USING (true);
CREATE POLICY "Anyone can read classes" ON classes FOR SELECT USING (true);
CREATE POLICY "Anyone can read skills" ON skills FOR SELECT USING (true);
CREATE POLICY "Anyone can read skill tags" ON skill_tags FOR SELECT USING (true);

-- user_classes는 본인 것만 읽고 수정 가능
CREATE POLICY "Users can read their own classes" ON user_classes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own classes" ON user_classes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own classes" ON user_classes
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- 완료!
-- ============================================
-- 이제 다음과 같은 구조를 갖게 됩니다:
--
-- 1. class_categories: 클래스 계열 (궁수계열, 힐러계열 등)
-- 2. classes: 개별 클래스 (견습궁수, 궁수, 장궁병 등)
-- 3. skills: 스킬 정보 (액티브 1-5, 궁극기 6, 패시브)
-- 4. skill_tags: 스킬 태그 (CC, AOE, DOT 등)
-- 5. user_classes: 유저가 보유한 클래스 정보
--
-- 기존 class_master 테이블이 있었다면 백업 테이블이 생성되었습니다.
