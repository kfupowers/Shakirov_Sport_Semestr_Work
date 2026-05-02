<#import "layout.ftl" as l>
<@l.page title="Регистрация">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <h2 class="mb-4">Создать аккаунт</h2>
            <#if error??>
                <div class="alert alert-danger">${error}</div>
            </#if>
            <form action="/register" method="post" id="registerForm">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label for="login" class="form-label">Логин</label>
                    <input type="text" class="form-control <#if errors?? && errors.login??>is-invalid</#if>" id="login" name="login" value="${(request.login)!''}" required minlength="3">
                    <#if errors?? && errors.login??>
                        <div class="invalid-feedback">${errors.login}</div>
                    </#if>
                </div>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="name" class="form-label">Имя</label>
                        <input type="text" class="form-control <#if errors?? && errors.name??>is-invalid</#if>" id="name" name="name" value="${(request.name)!''}" required>
                        <#if errors?? && errors.name??>
                            <div class="invalid-feedback">${errors.name}</div>
                        </#if>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="surname" class="form-label">Фамилия</label>
                        <input type="text" class="form-control <#if errors?? && errors.surname??>is-invalid</#if>" id="surname" name="surname" value="${(request.surname)!''}" required>
                        <#if errors?? && errors.surname??>
                            <div class="invalid-feedback">${errors.surname}</div>
                        </#if>
                    </div>
                </div>
                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control <#if errors?? && errors.email??>is-invalid</#if>" id="email" name="email" value="${(request.email)!''}" required>
                    <#if errors?? && errors.email??>
                        <div class="invalid-feedback">${errors.email}</div>
                    </#if>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">Пароль</label>
                    <input type="password" class="form-control <#if errors?? && errors.password??>is-invalid</#if>" id="password" name="password" required minlength="6">
                    <#if errors?? && errors.password??>
                        <div class="invalid-feedback">${errors.password}</div>
                    </#if>
                </div>
                <div class="mb-3">
                    <label for="birthDate" class="form-label">Дата рождения</label>
                    <input type="date" class="form-control <#if errors?? && errors.birthDate??>is-invalid</#if>"
                           id="birthDate" name="birthDate" value="${(request.birthDate)!''}">
                </div>
                <button type="submit" class="btn btn-success w-100">Зарегистрироваться</button>
            </form>
        </div>
    </div>
</@l.page>