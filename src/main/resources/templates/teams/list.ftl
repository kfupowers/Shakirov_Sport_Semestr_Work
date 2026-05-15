<#import "/layout.ftl" as l>
<@l.page title="Мои команды">
    <h2>Мои команды</h2>
    <a href="/teams/new" class="btn btn-success mb-3">Создать команду</a>
    <#if teams?size gt 0>
        <div class="list-group">
            <#list teams as team>
                <div class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                    <div>
                        <a href="/teams/${team.id}" class="text-decoration-none">
                            <strong>${team.name}</strong>
                        </a>
                        (капитан: ${team.captain.name} ${team.captain.surname})
                        <span class="badge bg-<#if team.active>success<#else>secondary</#if> ms-2">
                            <#if team.active>Активна<#else>Неактивна</#if>
                        </span>
                    </div>
                    <#if currentUserId?? && team.captain.id == currentUserId>
                        <a href="/teams/${team.id}/edit" class="btn btn-sm btn-outline-secondary">Редактировать</a>
                    </#if>
                </div>
            </#list>
        </div>
    <#else>
        <div class="alert alert-info">Вы пока не состоите ни в одной команде.</div>
    </#if>
</@l.page>