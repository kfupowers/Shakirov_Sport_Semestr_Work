<#import "/layout.ftl" as l>
<@l.page title="Поиск игроков">
    <h2>Игроки ищут команду</h2>
    <div class="d-flex justify-content-between mb-3">
        <form method="get" action="/players/search" class="row g-3">
            <div class="col-auto">
                <select name="discipline" class="form-select">
                    <option value="">Все дисциплины</option>
                    <#list disciplines as d>
                        <option value="${d.name}" <#if currentDiscipline?? && currentDiscipline == d.name>selected</#if>>${d.name}</option>
                    </#list>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-outline-primary">Фильтровать</button>
            </div>
        </form>
        <a href="/players/new" class="btn btn-success">Создать заявку</a>
    </div>

    <div class="row">
        <#list requests as req>
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">${req.author.name} ${req.author.surname} – ${req.discipline.name}</h5>
                        <p class="card-text">${req.description!''}</p>
                        <#if req.contact??>
                            <p class="card-text"><strong>Контакт:</strong> ${req.contact}</p>
                        </#if>

                        <#if currentUserId?? && currentUserId == req.author.id>
                            <form action="/players/${req.id}/close" method="post" class="d-inline" onsubmit="return confirm('Закрыть заявку?');">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-warning btn-sm">Закрыть</button>
                            </form>
                        </#if>

                        <#if isAdmin?? && isAdmin>
                            <form action="/players/${req.id}/delete" method="post" class="d-inline" onsubmit="return confirm('Удалить заявку?');">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" class="btn btn-danger btn-sm">Удалить</button>
                            </form>
                        </#if>
                    </div>
                </div>
            </div>
        <#else>
            <div class="col-12"><div class="alert alert-info">Нет активных заявок</div></div>
        </#list>
    </div>
</@l.page>