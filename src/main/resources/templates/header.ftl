<header>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="/">Турниры</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="/competitions">Соревнования</a>
                    </li>
                    <#if user??>
                        <li class="nav-item">
                            <a class="nav-link" href="/teams">Мои команды</a>
                        </li>
                    </#if>
                    <#if user?? && (user.authorities?seq_contains('ROLE_ORGANIZER') || user.authorities?seq_contains('ROLE_ADMIN'))>
                        <li class="nav-item">
                            <a class="nav-link" href="/competitions/new">Создать соревнование</a>
                        </li>
                    </#if>
                    <#if user??>
                        <li class="nav-item">
                            <a class="nav-link" href="/profile">Профиль</a>
                        </li>
                    </#if>
                    <#if user?? && user.authorities?seq_contains('ROLE_ADMIN')>
                        <li class="nav-item">
                            <a class="nav-link" href="/admin">Админ-панель</a>
                        </li>
                    </#if>
                    <li class="nav-item">
                        <a class="nav-link" href="/players/search">Поиск игроков</a>
                    </li>
                </ul>
                <div class="navbar-nav">
                    <#if user??>
                        <span class="nav-link text-light">${user.name} ${user.surname}</span>
                        <form class="d-inline" action="/logout" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button class="btn btn-outline-light btn-sm" type="submit">Выйти</button>
                        </form>
                    <#else>
                        <a class="nav-link" href="/login">Войти</a>
                        <a class="nav-link" href="/register">Регистрация</a>
                    </#if>
                </div>
            </div>
        </div>
    </nav>
</header>