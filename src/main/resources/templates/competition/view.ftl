<#import "/layout.ftl" as l>
<@l.page title="${comp.title}">
    <h2>${comp.title}</h2>
    <p><strong>Дисциплина:</strong> ${comp.discipline.name}</p>
    <p><strong>Дата и время:</strong> ${formattedDatetime}</p>
    <p><strong>Адрес:</strong> ${comp.address!"Не указан"}</p>
    <p><strong>Статус:</strong> ${comp.status}</p>
    <p><strong>Организатор:</strong> ${comp.owner.name} ${comp.owner.surname}</p>

    <#if user?? && user.id != comp.owner.id && comp.status == 'OPEN'>
        <h4>Зарегистрировать команду</h4>
        <form action="/competitions/${comp.id}/register" method="post" class="row g-2">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <div class="col-auto">
                <select name="teamId" class="form-select" required>
                    <option value="">-- Выберите команду --</option>
                    <#list userTeams as team>
                        <option value="${team.id}">${team.name}</option>
                    </#list>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-success">Зарегистрировать</button>
            </div>
        </form>
    </#if>

    <h4 class="mt-4">Зарегистрированные команды</h4>
    <#if participations?size gt 0>
        <ul class="list-group">
            <#list participations as p>
                <li class="list-group-item">${p.team.name} <#if p.place??>(место: ${p.place})</#if></li>
            </#list>
        </ul>
    <#else>
        <p>Нет зарегистрированных команд.</p>
    </#if>

    <#if matches?size gt 0>
        <h4 class="mt-4">Турнирная сетка</h4>
        <div class="bracket">
            <#list matches as match>
                <div class="card mb-2">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-5 text-end">${(match.firstTeam.name)!"TBD"}</div>
                            <div class="col-2 text-center"><strong>${match.score1!"-"} : ${match.score2!"-"}</strong></div>
                            <div class="col-5">${(match.secondTeam.name)!"TBD"}</div>
                        </div>
                        <small class="text-muted">Раунд ${match.round}</small>
                    </div>
                </div>
            </#list>
        </div>
    </#if>
</@l.page>