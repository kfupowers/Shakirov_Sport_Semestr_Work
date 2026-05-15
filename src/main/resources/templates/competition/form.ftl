<#import "/layout.ftl" as l>
<@l.page title="<#if competitionId??>Редактировать<#else>Создать</#if> соревнование">
    <h2><#if competitionId??>Редактировать<#else>Создать</#if> соревнование</h2>
    <form action="<#if competitionId??>/competitions/${competitionId}/edit<#else>/competitions/new</#if>" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <div class="mb-3">
            <label for="title" class="form-label">Название</label>
            <input type="text" class="form-control" id="title" name="title" value="${(competition.title)!''}" required>
        </div>
        <div class="mb-3">
            <label for="datetime" class="form-label">Дата и время</label>
            <input type="datetime-local" class="form-control <#if errors?? && errors.datetime??>is-invalid</#if>"
                   id="datetime" name="datetime" value="${formattedDatetime!''}" required>
            <#if errors?? && errors.datetime??>
                <div class="invalid-feedback">${errors.datetime}</div>
            </#if>
        </div>
        <div class="mb-3">
            <label for="address" class="form-label">Адрес</label>
            <input type="text" class="form-control" id="address" name="address" value="${(competition.address)!''}">
        </div>
        <div class="mb-3">
            <label for="disciplineId" class="form-label">Дисциплина</label>
            <select class="form-select" id="disciplineId" name="disciplineId" required>
                <option value="">-- Выберите дисциплину --</option>
                <#list disciplines as d>
                    <option value="${d.id}" <#if (competition.disciplineId)?? && competition.disciplineId == d.id>selected</#if>>${d.name}</option>
                </#list>
            </select>
        </div>
        <#if !competitionId??>
            <div class="mb-3">
                <label for="tournamentSize" class="form-label">Количество команд в турнире</label>
                <select class="form-select" id="tournamentSize" name="tournamentSize" required>
                    <option value="4" <#if (competition.tournamentSize!0) == 4>selected</#if>>4</option>
                    <option value="8" <#if (competition.tournamentSize!0) == 8>selected</#if>>8</option>
                    <option value="16" <#if (competition.tournamentSize!0) == 16>selected</#if>>16</option>
                </select>
            </div>
            <div class="mb-3">
                <label for="requiredTeamSize" class="form-label">Минимальное количество участников в команде</label>
                <input type="number" class="form-control" id="requiredTeamSize" name="requiredTeamSize" value="${(competition.requiredTeamSize)!1}" min="1" required>
            </div>
        </#if>
        <button type="submit" class="btn btn-primary">Сохранить</button>
        <a href="/competitions" class="btn btn-secondary">Отмена</a>
    </form>
</@l.page>