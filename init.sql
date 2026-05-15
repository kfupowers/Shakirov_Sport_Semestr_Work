-- ============================================================
-- СОЗДАНИЕ СХЕМЫ И ТАБЛИЦ
-- ============================================================
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
    tournament_size INTEGER,
    required_team_size INTEGER,
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

-- Объявления о поиске игроков / команды
CREATE TABLE IF NOT EXISTS sport.player_requests (
    id BIGSERIAL PRIMARY KEY,
    author_id BIGINT NOT NULL,
    discipline_id BIGINT NOT NULL,
    description TEXT,
    contact VARCHAR(255),
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES sport.accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES sport.discipline(id) ON DELETE CASCADE
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
-- НАЧАЛЬНЫЕ ДАННЫЕ
-- ============================================================

-- Роли
INSERT INTO sport.roles (name) VALUES ('USER') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.roles (name) VALUES ('ORGANIZER') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.roles (name) VALUES ('ADMIN') ON CONFLICT (name) DO NOTHING;

-- Дисциплины
INSERT INTO sport.discipline (name) VALUES ('Футбол') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Теннис') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Баскетбол') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Волейбол') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Хоккей') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Настольный теннис') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Бадминтон') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Плавание') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Шахматы') ON CONFLICT (name) DO NOTHING;
INSERT INTO sport.discipline (name) VALUES ('Киберспорт') ON CONFLICT (name) DO NOTHING;

-- Аккаунты (100 пользователей)
-- Пароль "qwerty" для admin и "password" для остальных (все хэши одинаковые – замените при необходимости)
INSERT INTO sport.accounts (login, name, surname, email, password, birth_date) VALUES
('qwerty', 'Admin', 'Adminov', 'admin@sport.ru', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1990-01-01'),
('user1', 'Иван', 'Иванов', 'ivan@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1995-02-15'),
('user2', 'Петр', 'Петров', 'petr@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1996-03-20'),
('user3', 'Сергей', 'Сергеев', 'sergey@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1997-04-10'),
('user4', 'Анна', 'Смирнова', 'anna@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1998-05-05'),
('user5', 'Елена', 'Кузнецова', 'elena@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1999-06-12'),
('user6', 'Дмитрий', 'Попов', 'dmitry@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '2000-07-25'),
('user7', 'Ольга', 'Васильева', 'olga@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '2001-08-30'),
('user8', 'Николай', 'Соколов', 'nikolay@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '2002-09-14'),
('user9', 'Мария', 'Михайлова', 'maria@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '2003-10-18'),
('user10', 'Алексей', 'Федоров', 'alexey@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1994-11-22'),
('user11', 'Татьяна', 'Морозова', 'tatiana@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1993-12-01'),
('user12', 'Павел', 'Волков', 'pavel@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1992-01-17'),
('user13', 'Юлия', 'Зайцева', 'yulia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1991-02-28'),
('user14', 'Владимир', 'Лебедев', 'vladimir@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1990-03-05'),
('user15', 'Анастасия', 'Соловьева', 'anastasia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1989-04-11'),
('user16', 'Роман', 'Григорьев', 'roman@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1988-05-20'),
('user17', 'Светлана', 'Филиппова', 'svetlana@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1987-06-15'),
('user18', 'Александр', 'Иванов', 'alexandr@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1986-07-22'),
('user19', 'Ксения', 'Петрова', 'ksenia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1985-08-30'),
('user20', 'Максим', 'Сидоров', 'maxim@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1984-09-10'),
('user21', 'Екатерина', 'Козлова', 'ekaterina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1983-10-15'),
('user22', 'Андрей', 'Новиков', 'andrey@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1982-11-20'),
('user23', 'Валерия', 'Матвеева', 'valeria@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1981-12-25'),
('user24', 'Игорь', 'Алексеев', 'igor@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1980-01-30'),
('user25', 'Людмила', 'Тихонова', 'ludmila@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1979-02-14'),
('user26', 'Артем', 'Борисов', 'artem@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1978-03-18'),
('user27', 'Виктория', 'Голубева', 'viktoria@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1977-04-22'),
('user28', 'Кирилл', 'Крылов', 'kirill@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1976-05-10'),
('user29', 'Дарья', 'Журавлева', 'daria@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1975-06-05'),
('user30', 'Виталий', 'Егоров', 'vitaly@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1974-07-12'),
('user31', 'Олеся', 'Семенова', 'olesya@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1973-08-19'),
('user32', 'Федор', 'Орлов', 'fedor@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1972-09-01'),
('user33', 'Маргарита', 'Тарасова', 'margarita@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1971-10-10'),
('user34', 'Станислав', 'Макаров', 'stanislav@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1970-11-15'),
('user35', 'Инна', 'Андреева', 'inna@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1969-12-20'),
('user36', 'Георгий', 'Белов', 'georgy@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1968-01-25'),
('user37', 'Алина', 'Комарова', 'alina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1967-02-14'),
('user38', 'Даниил', 'Никитин', 'daniil@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1966-03-08'),
('user39', 'Полина', 'Чернова', 'polina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1965-04-01'),
('user40', 'Антон', 'Антонов', 'anton@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1964-05-05'),
('user41', 'Ирина', 'Иринова', 'irina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1963-06-06'),
('user42', 'Григорий', 'Григорьев', 'grigory@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1962-07-07'),
('user43', 'Валентина', 'Валентинова', 'valentina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1961-08-08'),
('user44', 'Борис', 'Борисов', 'boris@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1960-09-09'),
('user45', 'Наталья', 'Натальева', 'natalia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1959-10-10'),
('user46', 'Денис', 'Денисов', 'denis@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1958-11-11'),
('user47', 'Лариса', 'Ларисова', 'larisa@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1957-12-12'),
('user48', 'Тимофей', 'Тимофеев', 'timofey@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1956-01-13'),
('user49', 'Вера', 'Верова', 'vera@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1955-02-14'),
('user50', 'Константин', 'Константинов', 'konstantin@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1954-03-15'),
('user51', 'Зоя', 'Зоева', 'zoya@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1953-04-16'),
('user52', 'Руслан', 'Русланов', 'ruslan@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1952-05-17'),
('user53', 'Яна', 'Янова', 'yana@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1951-06-18'),
('user54', 'Аркадий', 'Аркадьев', 'arkady@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1950-07-19'),
('user55', 'Любовь', 'Любовская', 'lyubov@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1949-08-20'),
('user56', 'Степан', 'Степанов', 'stepan@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1948-09-21'),
('user57', 'Раиса', 'Раисова', 'raisa@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1947-10-22'),
('user58', 'Евгений', 'Евгеньев', 'evgeny@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1946-11-23'),
('user59', 'София', 'Софиева', 'sofia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1945-12-24'),
('user60', 'Михаил', 'Михайлов', 'mikhail@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1944-01-25'),
('user61', 'Василий', 'Васильев', 'vasily@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1943-02-26'),
('user62', 'Марина', 'Маринина', 'marina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1942-03-27'),
('user63', 'Филипп', 'Филиппов', 'philip@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1941-04-28'),
('user64', 'Дарья', 'Дарьева', 'darya@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1940-05-29'),
('user65', 'Никита', 'Никитин', 'nikita@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1939-06-30'),
('user66', 'Варвара', 'Варварова', 'varvara@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1938-07-01'),
('user67', 'Афанасий', 'Афанасьев', 'afanasy@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1937-08-02'),
('user68', 'Алина', 'Алинова', 'alina.alinova@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1936-09-03'),
('user69', 'Семён', 'Семёнов', 'semen@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1935-10-04'),
('user70', 'Эльвира', 'Эльвирова', 'elvira@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1934-11-05'),
('user71', 'Глеб', 'Глебов', 'gleb@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1933-12-06'),
('user72', 'Кира', 'Кирова', 'kira@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1932-01-07'),
('user73', 'Матвей', 'Матвеев', 'matvey@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1931-02-08'),
('user74', 'Лидия', 'Лидиева', 'lidia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1930-03-09'),
('user75', 'Ярослав', 'Ярославов', 'yaroslav@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1929-04-10'),
('user76', 'Нелли', 'Неллина', 'nelli@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1928-05-11'),
('user77', 'Захар', 'Захаров', 'zakhar@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1927-06-12'),
('user78', 'Анфиса', 'Анфисова', 'anfisa@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1926-07-13'),
('user79', 'Герман', 'Германов', 'german@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1925-08-14'),
('user80', 'Тамара', 'Тамарова', 'tamara@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1924-09-15'),
('user81', 'Роберт', 'Робертов', 'robert@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1923-10-16'),
('user82', 'Агата', 'Агатова', 'agata@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1922-11-17'),
('user83', 'Игнат', 'Игнатов', 'ignat@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1921-12-18'),
('user84', 'Прасковья', 'Прасковьева', 'praskovia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1920-01-19'),
('user85', 'Давид', 'Давидов', 'david@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1919-02-20'),
('user86', 'Рада', 'Радова', 'rada@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1918-03-21'),
('user87', 'Трофим', 'Трофимов', 'trofim@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1917-04-22'),
('user88', 'Серафима', 'Серафимова', 'serafima@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1916-05-23'),
('user89', 'Викентий', 'Викентьев', 'vikenty@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1915-06-24'),
('user90', 'Фёкла', 'Фёклова', 'fekla@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1914-07-25'),
('user91', 'Демьян', 'Демьянов', 'demian@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1913-08-26'),
('user92', 'Акулина', 'Акулинова', 'akulina@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1912-09-27'),
('user93', 'Прохор', 'Прохоров', 'prokhor@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1911-10-28'),
('user94', 'Ефросинья', 'Ефросиньева', 'efrosinia@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1910-11-29'),
('user95', 'Лука', 'Луков', 'luka@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1909-12-30'),
('user96', 'Степанида', 'Степанидова', 'stepanida@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1908-01-31'),
('user97', 'Фома', 'Фомин', 'foma@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1907-02-01'),
('user98', 'Глафира', 'Глафирова', 'glafira@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1906-03-02'),
('user99', 'Ермолай', 'Ермолаев', 'ermolai@example.com', '$2a$10$RWGzW.ZOwAycXMmBPI5jjuLZujLdEL3F/UnJ2eIYsvzOyt4MpA8Kq', '1905-04-03') ON CONFLICT (login) DO NOTHING;

-- Роли для пользователей
INSERT INTO sport.accounts_roles (account_id, role_id)
SELECT a.id, r.id FROM sport.accounts a, sport.roles r
WHERE a.login = 'qwerty' AND r.name IN ('ADMIN','ORGANIZER')
ON CONFLICT DO NOTHING;

-- ORGANIZER для нескольких (user2,5,10,15,20,25,30,35,40,45,50)
INSERT INTO sport.accounts_roles (account_id, role_id)
SELECT a.id, r.id FROM sport.accounts a, sport.roles r
WHERE a.login IN ('user2','user5','user10','user15','user20','user25','user30','user35','user40','user45','user50') AND r.name = 'ORGANIZER'
ON CONFLICT DO NOTHING;

-- USER для остальных, у кого ещё нет ролей
INSERT INTO sport.accounts_roles (account_id, role_id)
SELECT a.id, r.id FROM sport.accounts a, sport.roles r
WHERE a.id NOT IN (SELECT account_id FROM sport.accounts_roles) AND r.name = 'USER'
ON CONFLICT DO NOTHING;

-- ============================================================
-- СОРЕВНОВАНИЯ (без явного ID)
-- ============================================================
INSERT INTO sport.competitions (title, datetime, tournament_size, required_team_size, address, discipline_id, owner_id, status) VALUES
('Весенний турнир по футболу', '2026-05-20 18:00:00+03', 8, 1, 'г. Москва, ул. Лужники, 24, стр.1', (SELECT id FROM sport.discipline WHERE name='Футбол'), (SELECT id FROM sport.accounts WHERE login='user2'), 'OPEN'),
('Теннисный кубок', '2026-06-01 10:00:00+03', 4, 2, 'г. Санкт-Петербург, Невский проспект, 120', (SELECT id FROM sport.discipline WHERE name='Теннис'), (SELECT id FROM sport.accounts WHERE login='user5'), 'OPEN'),
('Баскетбольные выходные', '2026-05-25 12:00:00+03', 8, 5, 'г. Казань, ул. Спартаковская, 1', (SELECT id FROM sport.discipline WHERE name='Баскетбол'), (SELECT id FROM sport.accounts WHERE login='user10'), 'IN_PROGRESS'),
('Волейбольный микс', '2026-07-10 14:00:00+03', 4, 6, 'г. Екатеринбург, ул. Большакова, 90', (SELECT id FROM sport.discipline WHERE name='Волейбол'), (SELECT id FROM sport.accounts WHERE login='user15'), 'OPEN'),
('Хоккейный матч', '2026-08-15 19:00:00+03', 2, 6, 'г. Омск, проспект Мира, 33', (SELECT id FROM sport.discipline WHERE name='Хоккей'), (SELECT id FROM sport.accounts WHERE login='user20'), 'OPEN'),
('Настольный теннис – любители', '2026-05-30 16:00:00+03', 4, 1, 'г. Новосибирск, Красный проспект, 36', (SELECT id FROM sport.discipline WHERE name='Настольный теннис'), (SELECT id FROM sport.accounts WHERE login='user2'), 'COMPLETED'),
('Бадминтонный турнир', '2026-06-05 11:00:00+03', 4, 2, 'г. Самара, ул. Молодогвардейская, 222', (SELECT id FROM sport.discipline WHERE name='Бадминтон'), (SELECT id FROM sport.accounts WHERE login='user5'), 'OPEN'),
('Заплыв на 100 метров', '2026-07-20 09:00:00+03', 2, 1, 'г. Сочи, ул. Навагинская, 9', (SELECT id FROM sport.discipline WHERE name='Плавание'), (SELECT id FROM sport.accounts WHERE login='user10'), 'OPEN'),
('Киберспортивный турнир (LAN)', '2026-06-10 20:00:00+03', 16, 5, 'г. Москва, ул. Тверская, 7, LAN-центр', (SELECT id FROM sport.discipline WHERE name='Киберспорт'), (SELECT id FROM sport.accounts WHERE login='user15'), 'IN_PROGRESS'),
('Шахматный блиц', '2026-05-22 15:00:00+03', 8, 1, 'г. Москва, ул. Тверская, 7', (SELECT id FROM sport.discipline WHERE name='Шахматы'), (SELECT id FROM sport.accounts WHERE login='qwerty'), 'OPEN'),
('Футбольный кубок чемпионов', '2026-06-15 17:00:00+03', 16, 1, 'г. Москва, ул. Лужники, 24', (SELECT id FROM sport.discipline WHERE name='Футбол'), (SELECT id FROM sport.accounts WHERE login='user25'), 'COMPLETED') ON CONFLICT DO NOTHING;

-- Команды (id нужны для связей, оставляем)
INSERT INTO sport.teams (id, name, captain_id, active) VALUES
(1, 'Футбольные львы', (SELECT id FROM sport.accounts WHERE login='user1'), true),
(2, 'Теннисные ракетки', (SELECT id FROM sport.accounts WHERE login='user3'), true),
(3, 'Баскетбольные орлы', (SELECT id FROM sport.accounts WHERE login='user4'), true),
(4, 'Волейбольные акулы', (SELECT id FROM sport.accounts WHERE login='user5'), true),
(5, 'Хоккейные медведи', (SELECT id FROM sport.accounts WHERE login='user6'), true),
(6, 'Настольные мастера', (SELECT id FROM sport.accounts WHERE login='user7'), true),
(7, 'Бадминтонные ястребы', (SELECT id FROM sport.accounts WHERE login='user8'), true),
(8, 'Пловцы-скоростники', (SELECT id FROM sport.accounts WHERE login='user9'), true),
(9, 'Киберспортсмены', (SELECT id FROM sport.accounts WHERE login='user10'), true),
(10, 'Шахматные гении', (SELECT id FROM sport.accounts WHERE login='user11'), true),
(11, 'Футбольные тигры', (SELECT id FROM sport.accounts WHERE login='user12'), true),
(12, 'Футбольные соколы', (SELECT id FROM sport.accounts WHERE login='user13'), true),
(13, 'Футбольные молнии', (SELECT id FROM sport.accounts WHERE login='user14'), true),
(14, 'Футбольные ураганы', (SELECT id FROM sport.accounts WHERE login='user16'), true),
(15, 'Футбольные громы', (SELECT id FROM sport.accounts WHERE login='user17'), true),
(16, 'Футбольные вихри', (SELECT id FROM sport.accounts WHERE login='user18'), true),
(17, 'Футбольные ястребы', (SELECT id FROM sport.accounts WHERE login='user19'), true),
(18, 'Кибер-драконы', (SELECT id FROM sport.accounts WHERE login='user21'), true),
(19, 'Кибер-фениксы', (SELECT id FROM sport.accounts WHERE login='user22'), true),
(20, 'Кибер-титаны', (SELECT id FROM sport.accounts WHERE login='user23'), true),
(21, 'Кибер-волки', (SELECT id FROM sport.accounts WHERE login='user24'), true),
(22, 'Кибер-пантеры', (SELECT id FROM sport.accounts WHERE login='user26'), true),
(23, 'Кибер-ястребы', (SELECT id FROM sport.accounts WHERE login='user27'), true),
(24, 'Кибер-медведи', (SELECT id FROM sport.accounts WHERE login='user28'), true),
(25, 'Кибер-скорпионы', (SELECT id FROM sport.accounts WHERE login='user29'), true),
(26, 'Кибер-рыси', (SELECT id FROM sport.accounts WHERE login='user30'), true),
(27, 'Кибер-грифоны', (SELECT id FROM sport.accounts WHERE login='user31'), true),
(28, 'Кибер-единороги', (SELECT id FROM sport.accounts WHERE login='user32'), true),
(29, 'Кибер-фантомы', (SELECT id FROM sport.accounts WHERE login='user33'), true),
(30, 'Кибер-вампиры', (SELECT id FROM sport.accounts WHERE login='user34'), true),
(31, 'Кибер-зомби', (SELECT id FROM sport.accounts WHERE login='user35'), true),
(32, 'Кибер-роботы', (SELECT id FROM sport.accounts WHERE login='user36'), true),
(33, 'Футбольные чемпионы', (SELECT id FROM sport.accounts WHERE login='user41'), true),
(34, 'Футбольные легенды', (SELECT id FROM sport.accounts WHERE login='user42'), true),
(35, 'Футбольные звёзды', (SELECT id FROM sport.accounts WHERE login='user43'), true),
(36, 'Футбольные боги', (SELECT id FROM sport.accounts WHERE login='user44'), true),
(37, 'Футбольные короли', (SELECT id FROM sport.accounts WHERE login='user45'), true),
(38, 'Футбольные империи', (SELECT id FROM sport.accounts WHERE login='user46'), true),
(39, 'Футбольные атланты', (SELECT id FROM sport.accounts WHERE login='user47'), true),
(40, 'Футбольные титаны', (SELECT id FROM sport.accounts WHERE login='user48'), true),
(41, 'Футбольные богатыри', (SELECT id FROM sport.accounts WHERE login='user49'), true),
(42, 'Футбольные витязи', (SELECT id FROM sport.accounts WHERE login='user50'), true),
(43, 'Футбольные герои', (SELECT id FROM sport.accounts WHERE login='user51'), true),
(44, 'Футбольные маги', (SELECT id FROM sport.accounts WHERE login='user52'), true),
(45, 'Футбольные волшебники', (SELECT id FROM sport.accounts WHERE login='user53'), true),
(46, 'Футбольные колдуны', (SELECT id FROM sport.accounts WHERE login='user54'), true),
(47, 'Футбольные шаманы', (SELECT id FROM sport.accounts WHERE login='user55'), true),
(48, 'Футбольные друиды', (SELECT id FROM sport.accounts WHERE login='user56'), true) ON CONFLICT DO NOTHING;

-- Участники команд (минимальный состав)
INSERT INTO sport.team_members (team_id, account_id) VALUES
(1, (SELECT id FROM sport.accounts WHERE login='user1')), (1, (SELECT id FROM sport.accounts WHERE login='user12')), (1, (SELECT id FROM sport.accounts WHERE login='user13')), (1, (SELECT id FROM sport.accounts WHERE login='user14')),
(2, (SELECT id FROM sport.accounts WHERE login='user3')), (2, (SELECT id FROM sport.accounts WHERE login='user15')), (2, (SELECT id FROM sport.accounts WHERE login='user16')),
(3, (SELECT id FROM sport.accounts WHERE login='user4')), (3, (SELECT id FROM sport.accounts WHERE login='user17')), (3, (SELECT id FROM sport.accounts WHERE login='user18')), (3, (SELECT id FROM sport.accounts WHERE login='user19')),
(4, (SELECT id FROM sport.accounts WHERE login='user5')), (4, (SELECT id FROM sport.accounts WHERE login='user20')), (4, (SELECT id FROM sport.accounts WHERE login='user21')),
(5, (SELECT id FROM sport.accounts WHERE login='user6')), (5, (SELECT id FROM sport.accounts WHERE login='user22')), (5, (SELECT id FROM sport.accounts WHERE login='user23')), (5, (SELECT id FROM sport.accounts WHERE login='user24')),
(6, (SELECT id FROM sport.accounts WHERE login='user7')), (6, (SELECT id FROM sport.accounts WHERE login='user25')), (6, (SELECT id FROM sport.accounts WHERE login='user26')),
(7, (SELECT id FROM sport.accounts WHERE login='user8')), (7, (SELECT id FROM sport.accounts WHERE login='user27')), (7, (SELECT id FROM sport.accounts WHERE login='user28')),
(8, (SELECT id FROM sport.accounts WHERE login='user9')), (8, (SELECT id FROM sport.accounts WHERE login='user29')), (8, (SELECT id FROM sport.accounts WHERE login='user30')),
(9, (SELECT id FROM sport.accounts WHERE login='user10')), (9, (SELECT id FROM sport.accounts WHERE login='user31')), (9, (SELECT id FROM sport.accounts WHERE login='user32')), (9, (SELECT id FROM sport.accounts WHERE login='user33')), (9, (SELECT id FROM sport.accounts WHERE login='user34')),
(10, (SELECT id FROM sport.accounts WHERE login='user11')), (10, (SELECT id FROM sport.accounts WHERE login='user35')), (10, (SELECT id FROM sport.accounts WHERE login='user36')),
(11, (SELECT id FROM sport.accounts WHERE login='user12')), (11, (SELECT id FROM sport.accounts WHERE login='user37')),
(12, (SELECT id FROM sport.accounts WHERE login='user13')), (12, (SELECT id FROM sport.accounts WHERE login='user38')),
(13, (SELECT id FROM sport.accounts WHERE login='user14')), (13, (SELECT id FROM sport.accounts WHERE login='user39')),
(14, (SELECT id FROM sport.accounts WHERE login='user16')), (14, (SELECT id FROM sport.accounts WHERE login='user40')),
(15, (SELECT id FROM sport.accounts WHERE login='user17')), (15, (SELECT id FROM sport.accounts WHERE login='user41')),
(16, (SELECT id FROM sport.accounts WHERE login='user18')), (16, (SELECT id FROM sport.accounts WHERE login='user42')),
(17, (SELECT id FROM sport.accounts WHERE login='user19')), (17, (SELECT id FROM sport.accounts WHERE login='user43')),
(18, (SELECT id FROM sport.accounts WHERE login='user21')), (18, (SELECT id FROM sport.accounts WHERE login='user44')),
(19, (SELECT id FROM sport.accounts WHERE login='user22')), (19, (SELECT id FROM sport.accounts WHERE login='user45')),
(20, (SELECT id FROM sport.accounts WHERE login='user23')), (20, (SELECT id FROM sport.accounts WHERE login='user46')),
(21, (SELECT id FROM sport.accounts WHERE login='user24')), (21, (SELECT id FROM sport.accounts WHERE login='user47')),
(22, (SELECT id FROM sport.accounts WHERE login='user26')), (22, (SELECT id FROM sport.accounts WHERE login='user48')),
(23, (SELECT id FROM sport.accounts WHERE login='user27')), (23, (SELECT id FROM sport.accounts WHERE login='user49')),
(24, (SELECT id FROM sport.accounts WHERE login='user28')), (24, (SELECT id FROM sport.accounts WHERE login='user50')),
(25, (SELECT id FROM sport.accounts WHERE login='user29')), (25, (SELECT id FROM sport.accounts WHERE login='user51')),
(26, (SELECT id FROM sport.accounts WHERE login='user30')), (26, (SELECT id FROM sport.accounts WHERE login='user52')),
(27, (SELECT id FROM sport.accounts WHERE login='user31')), (27, (SELECT id FROM sport.accounts WHERE login='user53')),
(28, (SELECT id FROM sport.accounts WHERE login='user32')), (28, (SELECT id FROM sport.accounts WHERE login='user54')),
(29, (SELECT id FROM sport.accounts WHERE login='user33')), (29, (SELECT id FROM sport.accounts WHERE login='user55')),
(30, (SELECT id FROM sport.accounts WHERE login='user34')), (30, (SELECT id FROM sport.accounts WHERE login='user56')),
(31, (SELECT id FROM sport.accounts WHERE login='user35')), (31, (SELECT id FROM sport.accounts WHERE login='user57')),
(32, (SELECT id FROM sport.accounts WHERE login='user36')), (32, (SELECT id FROM sport.accounts WHERE login='user58')),
(33, (SELECT id FROM sport.accounts WHERE login='user41')), (33, (SELECT id FROM sport.accounts WHERE login='user59')),
(34, (SELECT id FROM sport.accounts WHERE login='user42')), (34, (SELECT id FROM sport.accounts WHERE login='user60')),
(35, (SELECT id FROM sport.accounts WHERE login='user43')), (35, (SELECT id FROM sport.accounts WHERE login='user61')),
(36, (SELECT id FROM sport.accounts WHERE login='user44')), (36, (SELECT id FROM sport.accounts WHERE login='user62')),
(37, (SELECT id FROM sport.accounts WHERE login='user45')), (37, (SELECT id FROM sport.accounts WHERE login='user63')),
(38, (SELECT id FROM sport.accounts WHERE login='user46')), (38, (SELECT id FROM sport.accounts WHERE login='user64')),
(39, (SELECT id FROM sport.accounts WHERE login='user47')), (39, (SELECT id FROM sport.accounts WHERE login='user65')),
(40, (SELECT id FROM sport.accounts WHERE login='user48')), (40, (SELECT id FROM sport.accounts WHERE login='user66')),
(41, (SELECT id FROM sport.accounts WHERE login='user49')), (41, (SELECT id FROM sport.accounts WHERE login='user67')),
(42, (SELECT id FROM sport.accounts WHERE login='user50')), (42, (SELECT id FROM sport.accounts WHERE login='user68')),
(43, (SELECT id FROM sport.accounts WHERE login='user51')), (43, (SELECT id FROM sport.accounts WHERE login='user69')),
(44, (SELECT id FROM sport.accounts WHERE login='user52')), (44, (SELECT id FROM sport.accounts WHERE login='user70')),
(45, (SELECT id FROM sport.accounts WHERE login='user53')), (45, (SELECT id FROM sport.accounts WHERE login='user71')),
(46, (SELECT id FROM sport.accounts WHERE login='user54')), (46, (SELECT id FROM sport.accounts WHERE login='user72')),
(47, (SELECT id FROM sport.accounts WHERE login='user55')), (47, (SELECT id FROM sport.accounts WHERE login='user73')),
(48, (SELECT id FROM sport.accounts WHERE login='user56')), (48, (SELECT id FROM sport.accounts WHERE login='user74'))
ON CONFLICT DO NOTHING;

-- Участия (без явного ID)
-- Для футбольного турнира (8 команд, OPEN) добавим 8 участий
INSERT INTO sport.participation (team_id, competition_id) VALUES
((SELECT id FROM sport.teams WHERE name='Футбольные львы'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные тигры'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные соколы'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные молнии'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные ураганы'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные громы'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные вихри'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу')),
((SELECT id FROM sport.teams WHERE name='Футбольные ястребы'), (SELECT id FROM sport.competitions WHERE title='Весенний турнир по футболу'))
ON CONFLICT DO NOTHING;

-- Для теннисного кубка (4 команды)
INSERT INTO sport.participation (team_id, competition_id) VALUES
((SELECT id FROM sport.teams WHERE name='Теннисные ракетки'), (SELECT id FROM sport.competitions WHERE title='Теннисный кубок')),
((SELECT id FROM sport.teams WHERE name='Футбольные львы'), (SELECT id FROM sport.competitions WHERE title='Теннисный кубок')),
((SELECT id FROM sport.teams WHERE name='Волейбольные акулы'), (SELECT id FROM sport.competitions WHERE title='Теннисный кубок')),
((SELECT id FROM sport.teams WHERE name='Хоккейные медведи'), (SELECT id FROM sport.competitions WHERE title='Теннисный кубок'))
ON CONFLICT DO NOTHING;

-- Для баскетбольных выходных (IN_PROGRESS, 8 команд, добавим команды)
INSERT INTO sport.participation (team_id, competition_id) VALUES
((SELECT id FROM sport.teams WHERE name='Баскетбольные орлы'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Волейбольные акулы'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Хоккейные медведи'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Настольные мастера'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Пловцы-скоростники'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Киберспортсмены'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные')),
((SELECT id FROM sport.teams WHERE name='Шахматные гении'), (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'))
ON CONFLICT DO NOTHING;

-- Киберспортивный турнир (LAN) – 15 команд, одна не хватает до 16
INSERT INTO sport.participation (team_id, competition_id) VALUES
((SELECT id FROM sport.teams WHERE name='Киберспортсмены'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-драконы'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-фениксы'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-титаны'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-волки'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-пантеры'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-ястребы'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-медведи'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-скорпионы'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-рыси'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-грифоны'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-единороги'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-фантомы'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-вампиры'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)')),
((SELECT id FROM sport.teams WHERE name='Кибер-зомби'), (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'))
ON CONFLICT DO NOTHING;

-- Футбольный кубок чемпионов (COMPLETED, 16 команд)
INSERT INTO sport.participation (team_id, competition_id, place) VALUES
-- 1 место
((SELECT id FROM sport.teams WHERE name='Футбольные богатыри'), (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1),
-- 2 место
((SELECT id FROM sport.teams WHERE name='Футбольные маги'),        (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 2),
-- 3 место (полуфиналисты)
((SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'),    (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 3),
((SELECT id FROM sport.teams WHERE name='Футбольные волшебники'),  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 3),
-- 5 место (четвертьфиналисты)
((SELECT id FROM sport.teams WHERE name='Футбольные боги'),        (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 5),
((SELECT id FROM sport.teams WHERE name='Футбольные короли'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 5),
((SELECT id FROM sport.teams WHERE name='Футбольные титаны'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 5),
((SELECT id FROM sport.teams WHERE name='Футбольные друиды'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 5),
-- 9 место (проигравшие в 1/8 финала)
((SELECT id FROM sport.teams WHERE name='Футбольные легенды'),     (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные звёзды'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные империи'),     (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные атланты'),     (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные витязи'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные герои'),       (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные колдуны'),     (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9),
((SELECT id FROM sport.teams WHERE name='Футбольные шаманы'),      (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 9)
ON CONFLICT DO NOTHING;

-- Остальные участия для прочих турниров (по минимуму)
INSERT INTO sport.participation (team_id, competition_id) VALUES
((SELECT id FROM sport.teams WHERE name='Волейбольные акулы'), (SELECT id FROM sport.competitions WHERE title='Волейбольный микс')),
((SELECT id FROM sport.teams WHERE name='Хоккейные медведи'), (SELECT id FROM sport.competitions WHERE title='Волейбольный микс')),
((SELECT id FROM sport.teams WHERE name='Настольные мастера'), (SELECT id FROM sport.competitions WHERE title='Волейбольный микс')),
((SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), (SELECT id FROM sport.competitions WHERE title='Волейбольный микс')),
((SELECT id FROM sport.teams WHERE name='Хоккейные медведи'), (SELECT id FROM sport.competitions WHERE title='Хоккейный матч')),
((SELECT id FROM sport.teams WHERE name='Волейбольные акулы'), (SELECT id FROM sport.competitions WHERE title='Хоккейный матч')),
((SELECT id FROM sport.teams WHERE name='Настольные мастера'), (SELECT id FROM sport.competitions WHERE title='Настольный теннис – любители')),
((SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), (SELECT id FROM sport.competitions WHERE title='Настольный теннис – любители')),
((SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), (SELECT id FROM sport.competitions WHERE title='Бадминтонный турнир')),
((SELECT id FROM sport.teams WHERE name='Настольные мастера'), (SELECT id FROM sport.competitions WHERE title='Бадминтонный турнир')),
((SELECT id FROM sport.teams WHERE name='Пловцы-скоростники'), (SELECT id FROM sport.competitions WHERE title='Бадминтонный турнир')),
((SELECT id FROM sport.teams WHERE name='Шахматные гении'), (SELECT id FROM sport.competitions WHERE title='Бадминтонный турнир')),
((SELECT id FROM sport.teams WHERE name='Пловцы-скоростники'), (SELECT id FROM sport.competitions WHERE title='Заплыв на 100 метров')),
((SELECT id FROM sport.teams WHERE name='Киберспортсмены'), (SELECT id FROM sport.competitions WHERE title='Заплыв на 100 метров')),
((SELECT id FROM sport.teams WHERE name='Шахматные гении'), (SELECT id FROM sport.competitions WHERE title='Шахматный блиц')),
((SELECT id FROM sport.teams WHERE name='Киберспортсмены'), (SELECT id FROM sport.competitions WHERE title='Шахматный блиц')),
((SELECT id FROM sport.teams WHERE name='Футбольные львы'), (SELECT id FROM sport.competitions WHERE title='Шахматный блиц'))
ON CONFLICT DO NOTHING;

-- Места для завершённых турниров (пока только для настольного тенниса и футбольного кубка)
UPDATE sport.participation SET place = 1 WHERE team_id = (SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы') AND competition_id = (SELECT id FROM sport.competitions WHERE title='Настольный теннис – любители');
UPDATE sport.participation SET place = 2 WHERE team_id = (SELECT id FROM sport.teams WHERE name='Настольные мастера') AND competition_id = (SELECT id FROM sport.competitions WHERE title='Настольный теннис – любители');

-- Матчи для турниров (оставляем id для связей)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
-- Баскетбольные выходные (IN_PROGRESS, 8 команд) – используем упрощённую сетку, 1 матч для демонстрации
(1, (SELECT id FROM sport.competitions WHERE title='Настольный теннис – любители'), 1, (SELECT id FROM sport.teams WHERE name='Настольные мастера'), (SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), (SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'), 3, 2, NULL);

-- Баскетбольные выходные (8 команд) – полная сетка
-- Полуфиналы и финал пока без результатов (будут позже)

-- Финал (round 3)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id) VALUES
(100, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 3, NULL, NULL);

-- Полуфиналы (round 2)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, next_match_id) VALUES
(101, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 2, NULL, NULL, 100),
(102, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 2, NULL, NULL, 100);

-- Четвертьфиналы (round 1) – первые два матча уже сыграны, остальные без результатов
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
(103, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 1,
 (SELECT id FROM sport.teams WHERE name='Баскетбольные орлы'),
 (SELECT id FROM sport.teams WHERE name='Волейбольные акулы'),
 (SELECT id FROM sport.teams WHERE name='Баскетбольные орлы'), 25, 20, 101),
(104, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 1,
 (SELECT id FROM sport.teams WHERE name='Хоккейные медведи'),
 (SELECT id FROM sport.teams WHERE name='Настольные мастера'),
 (SELECT id FROM sport.teams WHERE name='Хоккейные медведи'), 30, 28, 101),
(105, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 1,
 (SELECT id FROM sport.teams WHERE name='Бадминтонные ястребы'),
 (SELECT id FROM sport.teams WHERE name='Пловцы-скоростники'),
 NULL, NULL, NULL, 102),   -- матч ещё не играли
(106, (SELECT id FROM sport.competitions WHERE title='Баскетбольные выходные'), 1,
 (SELECT id FROM sport.teams WHERE name='Киберспортсмены'),
 (SELECT id FROM sport.teams WHERE name='Шахматные гении'),
 NULL, NULL, NULL, 102)    -- матч ещё не играли
ON CONFLICT DO NOTHING;

-- Киберспортивный турнир (LAN) – полная сетка (16 команд, одна отсутствует)

-- Финал (round 4)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id) VALUES
(200, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 4, NULL, NULL);

-- Полуфиналы (round 3)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, next_match_id) VALUES
(201, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 3, NULL, NULL, 200),
(202, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 3, NULL, NULL, 200);

-- Четвертьфиналы (round 2)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, next_match_id) VALUES
(203, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 2, NULL, NULL, 201),
(204, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 2, NULL, NULL, 201),
(205, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 2, NULL, NULL, 202),
(206, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 2, NULL, NULL, 202);

-- Первый раунд (1/8 финала) – 8 матчей, в одном из них пустой слот → техническая победа
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
(207, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Киберспортсмены'),
 (SELECT id FROM sport.teams WHERE name='Кибер-драконы'),
 NULL, NULL, NULL, 203),   -- матч ещё не играли
(208, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-фениксы'),
 (SELECT id FROM sport.teams WHERE name='Кибер-титаны'),
 NULL, NULL, NULL, 203),
(209, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-волки'),
 (SELECT id FROM sport.teams WHERE name='Кибер-пантеры'),
 NULL, NULL, NULL, 204),
(210, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-ястребы'),
 (SELECT id FROM sport.teams WHERE name='Кибер-медведи'),
 NULL, NULL, NULL, 204),
(211, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-скорпионы'),
 (SELECT id FROM sport.teams WHERE name='Кибер-рыси'),
 NULL, NULL, NULL, 205),
(212, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-грифоны'),
 (SELECT id FROM sport.teams WHERE name='Кибер-единороги'),
 NULL, NULL, NULL, 205),
(213, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-фантомы'),
 (SELECT id FROM sport.teams WHERE name='Кибер-вампиры'),
 NULL, NULL, NULL, 206),
-- Матч, где одна команда отсутствует: Кибер-зомби против NULL → техническая победа
(214, (SELECT id FROM sport.competitions WHERE title='Киберспортивный турнир (LAN)'), 1,
 (SELECT id FROM sport.teams WHERE name='Кибер-зомби'),
 NULL,
 (SELECT id FROM sport.teams WHERE name='Кибер-зомби'), NULL, NULL, 206)
ON CONFLICT DO NOTHING;

-- Футбольный кубок чемпионов (COMPLETED, 16 команд) – полная сетка (15 матчей)
-- Футбольный кубок чемпионов (16 команд, COMPLETED) – полная сетка с явными командами

-- Финал (round 4)
-- Футбольный кубок чемпионов (16 команд, COMPLETED) – исправленная сетка

-- Финал (round 4)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2) VALUES
(18, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 4,
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'),
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'), 3, 2);

-- Полуфиналы (round 3)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
(16, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 3,
 (SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'), 4, 2, 18),
(17, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 3,
 (SELECT id FROM sport.teams WHERE name='Футбольные волшебники'),
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'), 1, 0, 18);

-- Четвертьфиналы (round 2)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
(12, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 2,
 (SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'),
 (SELECT id FROM sport.teams WHERE name='Футбольные боги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'), 2, 1, 16),
(13, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 2,
 (SELECT id FROM sport.teams WHERE name='Футбольные короли'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'), 0, 3, 16),
(14, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 2,
 (SELECT id FROM sport.teams WHERE name='Футбольные волшебники'),
 (SELECT id FROM sport.teams WHERE name='Футбольные титаны'),
 (SELECT id FROM sport.teams WHERE name='Футбольные волшебники'), 2, 1, 17),
(15, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 2,
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные друиды'),
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'), 3, 1, 17);

-- Первый раунд (1/8 финала, round 1)
INSERT INTO sport.match (id, competition_id, round, first_team_id, second_team_id, winner_team_id, score1, score2, next_match_id) VALUES
(4,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'),
 (SELECT id FROM sport.teams WHERE name='Футбольные легенды'),
 (SELECT id FROM sport.teams WHERE name='Футбольные чемпионы'), 2, 1, 12),
(5,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные звёзды'),
 (SELECT id FROM sport.teams WHERE name='Футбольные боги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные боги'), 1, 3, 12),
(6,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные короли'),
 (SELECT id FROM sport.teams WHERE name='Футбольные империи'),
 (SELECT id FROM sport.teams WHERE name='Футбольные короли'), 4, 2, 13),
(7,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные атланты'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'),
 (SELECT id FROM sport.teams WHERE name='Футбольные богатыри'), 0, 1, 13),
(8,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные витязи'),
 (SELECT id FROM sport.teams WHERE name='Футбольные волшебники'),
 (SELECT id FROM sport.teams WHERE name='Футбольные волшебники'), 0, 2, 14),
(9,  (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные герои'),
 (SELECT id FROM sport.teams WHERE name='Футбольные титаны'),
 (SELECT id FROM sport.teams WHERE name='Футбольные титаны'), 1, 2, 14),
(10, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'),
 (SELECT id FROM sport.teams WHERE name='Футбольные колдуны'),
 (SELECT id FROM sport.teams WHERE name='Футбольные маги'), 3, 0, 15),
(11, (SELECT id FROM sport.competitions WHERE title='Футбольный кубок чемпионов'), 1,
 (SELECT id FROM sport.teams WHERE name='Футбольные шаманы'),
 (SELECT id FROM sport.teams WHERE name='Футбольные друиды'),
 (SELECT id FROM sport.teams WHERE name='Футбольные друиды'), 1, 2, 15)
ON CONFLICT DO NOTHING;

-- Заявки на поиск игроков
INSERT INTO sport.player_requests (author_id, discipline_id, description, contact, status, created_at) VALUES
((SELECT id FROM sport.accounts WHERE login='user12'), (SELECT id FROM sport.discipline WHERE name='Футбол'), 'Ищу команду для весеннего турнира. Уровень – любитель.', '@ivan_tg', 'OPEN', '2026-05-10 10:00:00+03'),
((SELECT id FROM sport.accounts WHERE login='user16'), (SELECT id FROM sport.discipline WHERE name='Теннис'), 'Играю пару, нужен партнёр для турнира.', '@tennis_lover', 'OPEN', '2026-05-11 12:00:00+03'),
((SELECT id FROM sport.accounts WHERE login='user22'), (SELECT id FROM sport.discipline WHERE name='Киберспорт'), 'Ищем пятого игрока в киберспортивную команду.', '@cyber_player', 'OPEN', '2026-05-12 14:00:00+03')
ON CONFLICT DO NOTHING;

SELECT setval('sport.teams_id_seq', COALESCE((SELECT MAX(id) FROM sport.teams), 1));
SELECT setval('sport.match_id_seq', COALESCE((SELECT MAX(id) FROM sport.match), 1));
SELECT setval('sport.participation_id_seq', COALESCE((SELECT MAX(id) FROM sport.participation), 1));
SELECT setval('sport.player_requests_id_seq', COALESCE((SELECT MAX(id) FROM sport.player_requests), 1));