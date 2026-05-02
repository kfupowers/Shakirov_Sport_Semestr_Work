<#import "layout.ftl" as l>
<@l.page title="Вход">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <h2 class="mb-4">Вход в систему</h2>
            <#if loginError??>
                <div class="alert alert-danger">${loginError}</div>
            </#if>
            <#if logoutMessage??>
                <div class="alert alert-success">${logoutMessage}</div>
            </#if>
            <form action="/login" method="post"> ...
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label for="username" class="form-label">Логин</label>
                    <input type="text" class="form-control" id="username" name="username" required autofocus>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Пароль</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                <button type="submit" class="btn btn-primary w-100">Войти</button>
            </form>
        </div>
    </div>
</@l.page>