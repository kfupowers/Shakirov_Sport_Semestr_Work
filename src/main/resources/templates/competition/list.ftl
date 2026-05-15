<#import "/layout.ftl" as l>
<@l.page title="Соревнования">
    <h2>Соревнования</h2>
    <form method="get" action="/competitions" class="row g-3 mb-4">
        <div class="col-md-3">
            <select name="discipline" class="form-select">
                <option value="">Все дисциплины</option>
                <#list disciplines as d>
                    <option value="${d.name}" <#if currentDiscipline?? && currentDiscipline == d.name>selected</#if>>${d.name}</option>
                </#list>
            </select>
        </div>
        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">Все статусы</option>
                <option value="OPEN" <#if currentStatus?? && currentStatus == "OPEN">selected</#if>>Открыт</option>
                <option value="IN_PROGRESS" <#if currentStatus?? && currentStatus == "IN_PROGRESS">selected</#if>>Идёт</option>
                <option value="COMPLETED" <#if currentStatus?? && currentStatus == "COMPLETED">selected</#if>>Завершён</option>
            </select>
        </div>
        <div class="col-md-3">
            <input type="text" name="city" class="form-control" placeholder="Город"
                   value="${currentCity!''}">
        </div>
        <div class="col-md-3">
            <button type="submit" class="btn btn-outline-primary">Фильтровать</button>
        </div>
    </form>

    <div class="row">
        <#list competitions as comp>
            <div class="col-md-6 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">${comp.title!''}</h5>
                        <h6 class="card-subtitle mb-2 text-muted">${comp.disciplineName!''}</h6>
                        <p class="card-text">
                            ${comp.formattedDatetime!''} | ${comp.address!"Онлайн"}<br>
                            Статус: <span class="badge bg-<#if comp.status == 'OPEN'>success<#elseif comp.status == 'IN_PROGRESS'>warning<#else>secondary</#if>">${comp.status!''}</span>
                        </p>
                        <a href="/competitions/${comp.id}" class="btn btn-primary btn-sm">Подробнее</a>
                    </div>
                </div>
            </div>
        <#else>
            <div class="col-12">
                <div class="alert alert-info">Соревнований не найдено.</div>
            </div>
        </#list>
    </div>
</@l.page>