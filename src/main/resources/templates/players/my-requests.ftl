<#import "/layout.ftl" as l>
<@l.page title="Мои заявки">
    <h2>Мои заявки</h2>
    <a href="/players/new" class="btn btn-success mb-3">Создать заявку</a>
    <#if requests?size gt 0>
        <#list requests as req>
            <div class="card mb-2">
                <div class="card-body">
                    <h5>${req.discipline.name} – ${req.status}</h5>
                    <p>${req.description!''}</p>
                    <#if req.contact??><p>Контакт: ${req.contact}</p></#if>
                    <#if req.status.name() == 'OPEN'>
                        <form action="/players/${req.id}/close" method="post" class="d-inline">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button type="submit" class="btn btn-warning btn-sm">Закрыть заявку</button>
                        </form>
                    </#if>
                </div>
            </div>
        </#list>
    <#else>
        <p>У вас нет заявок</p>
    </#if>
</@l.page>