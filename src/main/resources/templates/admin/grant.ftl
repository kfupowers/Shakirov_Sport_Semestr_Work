<#import "/layout.ftl" as l>
<@l.page title="Выдать роль организатора">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <h2>Назначение роли Организатора</h2>
            <#if success??>
                <div class="alert alert-success">${success}</div>
            </#if>
            <#if error??>
                <div class="alert alert-danger">${error}</div>
            </#if>
            <form action="/admin/grant" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <div class="mb-3">
                    <label for="login" class="form-label">Логин пользователя</label>
                    <input type="text" class="form-control" id="login" name="login" required>
                </div>
                <button type="submit" class="btn btn-primary">Сделать организатором</button>
            </form>
        </div>
    </div>
</@l.page>