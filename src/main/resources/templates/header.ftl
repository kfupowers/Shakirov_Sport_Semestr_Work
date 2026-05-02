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
                        <li class="nav-item">
                            <a class="nav-link" href="/competitions/new">Создать соревнование</a>
                        </li>
                    </#if>
                </ul>
                <!-- Форма быстрого поиска соревнований (AJAX) -->
                <form class="d-flex me-3" id="searchForm" onsubmit="return false;">
                    <input class="form-control me-2" type="search" id="searchInput" placeholder="Поиск..." aria-label="Search">
                    <div id="searchResults" class="dropdown-menu" style="display: none;"></div>
                </form>
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