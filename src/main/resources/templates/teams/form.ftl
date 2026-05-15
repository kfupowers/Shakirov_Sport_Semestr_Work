<#import "/layout.ftl" as l>
<@l.page title="<#if teamId??>Редактировать<#else>Создать</#if> команду">
    <h2><#if teamId??>Редактировать<#else>Создать</#if> команду</h2>
    <form action="<#if teamId??>/teams/${teamId}/edit<#else>/teams/new</#if>" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <div class="mb-3">
            <label for="name" class="form-label">Название команды</label>
            <input type="text" class="form-control" id="name" name="name" value="${(team.name)!''}" required>
        </div>
        <div class="mb-3 form-check">
            <input type="checkbox" class="form-check-input" id="active" name="active" <#if (team.active)!false>checked</#if>>
            <label class="form-check-label" for="active">Активна</label>
        </div>
        <button type="submit" class="btn btn-primary">Сохранить</button>
        <a href="/teams" class="btn btn-secondary">Отмена</a>
    </form>
</@l.page>