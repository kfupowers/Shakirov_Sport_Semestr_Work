<#import "/layout.ftl" as l>
<@l.page title="<#if competitionId??>Редактировать<#else>Создать</#if> соревнование">
    <h2><#if competitionId??>Редактировать<#else>Создать</#if> соревнование</h2>

<#-- Общие ошибки валидации (например, неверный формат даты) -->
    <#if errors?? && errors.global??>
        <div class="alert alert-danger">${errors.global}</div>
    </#if>

    <form action="<#if competitionId??>/competitions/${competitionId}/edit<#else>/competitions/new</#if>" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

        <div class="mb-3">
            <label for="title" class="form-label">Название</label>
            <input type="text" class="form-control <#if errors?? && errors.title??>is-invalid</#if>"
                   id="title" name="title" value="${(competition.title)!''}" required>
            <#if errors?? && errors.title??>
                <div class="invalid-feedback">${errors.title}</div>
            </#if>
        </div>

        <div class="mb-3">
            <label for="datetime" class="form-label">Дата и время</label>
            <input type="datetime-local" class="form-control <#if errors?? && errors.datetime??>is-invalid</#if>"
                   id="datetime" name="datetime"
                   value="${(formattedDatetime)!''}" required>
            <#if errors?? && errors.datetime??>
                <div class="invalid-feedback">${errors.datetime}</div>
            </#if>
        </div>

        <div class="mb-3">
            <label for="address" class="form-label">Адрес</label>
            <input type="text" class="form-control <#if errors?? && errors.address??>is-invalid</#if>"
                   id="address" name="address" value="${(competition.address)!''}">
            <#if errors?? && errors.address??>
                <div class="invalid-feedback">${errors.address}</div>
            </#if>
        </div>

        <div class="mb-3">
            <label for="disciplineId" class="form-label">Дисциплина</label>
            <select class="form-select <#if errors?? && errors.disciplineId??>is-invalid</#if>"
                    id="disciplineId" name="disciplineId" required>
                <#list disciplines as d>
                    <option value="${d.id}"
                            <#if competition?? && competition.disciplineId?? && competition.disciplineId == d.id>selected</#if>>
                        ${d.name}
                    </option>
                </#list>
            </select>
            <#if errors?? && errors.disciplineId??>
                <div class="invalid-feedback">${errors.disciplineId}</div>
            </#if>
        </div>

        <button type="submit" class="btn btn-primary">Сохранить</button>
        <a href="/competitions" class="btn btn-secondary">Отмена</a>
    </form>
</@l.page>