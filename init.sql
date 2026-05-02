-- Создаём схему, если не существует
CREATE SCHEMA IF NOT EXISTS sport;

-- Тип спортивной дисциплины
CREATE TABLE IF NOT EXISTS sport.discipline (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Роли пользователей
CREATE TABLE IF NOT EXISTS sport.roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Пользователь (аккаунт)
CREATE TABLE IF NOT EXISTS sport.accounts (
    id BIGSERIAL PRIMARY KEY,
    login VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100),
    surname VARCHAR(100),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    birth_date DATE
);

-- Связь ManyToMany: пользователь - роли
CREATE TABLE IF NOT EXISTS sport.accounts_roles (
    account_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (account_id, role_id),
    FOREIGN KEY (account_id) REFERENCES sport.accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES sport.roles(id) ON DELETE CASCADE
);

-- Соревнования
CREATE TABLE IF NOT EXISTS sport.competitions (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    datetime TIMESTAMPTZ NOT NULL,
    address VARCHAR(255),
    discipline_id BIGINT NOT NULL,
    owner_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN',
    FOREIGN KEY (discipline_id) REFERENCES sport.discipline(id),
    FOREIGN KEY (owner_id) REFERENCES sport.accounts(id)
);

-- Команды
CREATE TABLE IF NOT EXISTS sport.teams (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    captain_id BIGINT NOT NULL,
    active BOOLEAN DEFAULT true,
    FOREIGN KEY (captain_id) REFERENCES sport.accounts(id)
);

-- Состав команды (ManyToMany: команды - пользователи)
CREATE TABLE IF NOT EXISTS sport.team_members (
    team_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    PRIMARY KEY (team_id, account_id),
    FOREIGN KEY (team_id) REFERENCES sport.teams(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES sport.accounts(id) ON DELETE CASCADE
);

-- Участие команды в соревновании
CREATE TABLE IF NOT EXISTS sport.participation (
    id BIGSERIAL PRIMARY KEY,
    team_id BIGINT NOT NULL,
    competition_id BIGINT NOT NULL,
    place INTEGER,
    UNIQUE (team_id, competition_id),
    FOREIGN KEY (team_id) REFERENCES sport.teams(id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES sport.competitions(id) ON DELETE CASCADE
);

-- Сетка матчей
CREATE TABLE IF NOT EXISTS sport.match (
    id BIGSERIAL PRIMARY KEY,
    competition_id BIGINT NOT NULL,
    round INT,
    first_team_id BIGINT,
    second_team_id BIGINT,
    winner_team_id BIGINT,
    score1 INT,
    score2 INT,
    next_match_id BIGINT,
    FOREIGN KEY (competition_id) REFERENCES sport.competitions(id) ON DELETE CASCADE,
    FOREIGN KEY (first_team_id) REFERENCES sport.teams(id) ON DELETE SET NULL,
    FOREIGN KEY (second_team_id) REFERENCES sport.teams(id) ON DELETE SET NULL,
    FOREIGN KEY (winner_team_id) REFERENCES sport.teams(id) ON DELETE SET NULL,
    FOREIGN KEY (next_match_id) REFERENCES sport.match(id) ON DELETE SET NULL
);

-- ============================================================
-- Начальные данные (выполнятся при spring.sql.init.mode=always)
-- ============================================================

-- Роли по умолчанию
INSERT INTO sport.roles (name) VALUES ('USER') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.roles (name) VALUES ('ADMIN') ON CONFLICT (name) DO NOTHING;