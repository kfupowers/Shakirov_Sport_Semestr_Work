<#import "/layout.ftl" as l>
<@l.page title="Мои команды">
    <h2>Мои команды</h2>
    <a href="/teams/new" class="btn btn-success mb-3">Создать команду</a>
    <#if teams?size gt 0>
        <div class="list-group">
            <#list teams as team>
                <a href="/teams/${team.id}" class="list-group-item list-group-item-action">
                    <strong>${team.name}</strong> (капитан: ${team.captain.name} ${team.captain.surname})
                    <span class="badge bg-<#if team.active>success<#else>secondary</#if> float-end"><#if team.active>Активна<#else>Неактивна</#if></span>
                </a>
            </#list>
        </div>
    <#else>
        <div class="alert alert-info">У вас пока нет команд.</div>
    </#if>
</@l.page>