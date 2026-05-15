<#import "/layout.ftl" as l>
<@l.page title="${comp.title}">
    <h2>${comp.title}</h2>
    <#if error??>
        <div class="alert alert-danger">${error}</div>
    </#if>
    <p><strong>Дисциплина:</strong> ${comp.discipline.name}</p>
    <p><strong>Дата и время:</strong> ${formattedDatetime}</p>
    <p><strong>Адрес:</strong> ${comp.address!"Не указан"}</p>
    <p><strong>Статус:</strong> ${comp.status}</p>
    <p><strong>Организатор:</strong> ${comp.owner.name} ${comp.owner.surname}</p>
    <p><strong>Максимальное количество команд:</strong> ${comp.tournamentSize!'-'}</p>
    <p><strong>Минимальное количество участников в команде:</strong> ${comp.requiredTeamSize!'-'}</p>

    <#if comp.address?? && comp.address?has_content>
        <div class="mt-3">
            <h5>Местоположение</h5>
            <iframe src="https://yandex.ru/map-widget/v1/?text=${comp.address?url('UTF-8')}&z=15"
                    width="100%" height="300" frameborder="0" style="border:0" allowfullscreen="true">
            </iframe>
        </div>
    </#if>

    <#if comp.status == 'OPEN'>
        <#if !isOwner>
            <#assign myParticipation = false>
            <#list participations as p>
                <#if p.team.captain.id == user.id>
                    <#assign myParticipation = true>
                    <#assign myTeam = p.team>
                </#if>
            </#list>
            <#if myParticipation>
                <h4>Моя команда уже участвует</h4>
                <form action="/competitions/${comp.id}/unregister" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <input type="hidden" name="teamId" value="${myTeam.id}"/>
                    <button type="submit" class="btn btn-danger">Сняться с турнира</button>
                </form>
            <#else>
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
        </#if>
    </#if>

    <h4 class="mt-4">Зарегистрированные команды</h4>
    <#if participations?size gt 0>
        <ul class="list-group">
            <#list participations as p>
                <li class="list-group-item">
                    <a href="/teams/${p.team.id}">${p.team.name}</a>
                    <#if p.place??>(место: ${p.place})</#if>
                </li>
            </#list>
        </ul>
    <#else>
        <p>Нет зарегистрированных команд.</p>
    </#if>

    <#if comp.status == 'OPEN'>
        <#if (isOwner || isAdmin)>
            <div class="card mt-4">
                <div class="card-header">Начать турнир</div>
                <div class="card-body">
                    <p>Требуется команд: <strong>${comp.tournamentSize}</strong>, минимум участников в каждой: <strong>${comp.requiredTeamSize}</strong></p>
                    <form action="/competitions/${comp.id}/start" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-success">Начать турнир</button>
                    </form>
                </div>
            </div>
        </#if>
    </#if>

    <#if comp.status == 'IN_PROGRESS' || comp.status == 'COMPLETED'>
        <h4 class="mt-4">Сетка турнира</h4>
        <#assign rounds = 0>
        <#list matches as m>
            <#if m.round gt rounds><#assign rounds = m.round></#if>
        </#list>
        <#list 1..rounds as round>
            <h5>Раунд ${round}</h5>
            <#list matches?filter(m -> m.round == round) as match>
                <div class="card mb-2">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-5 text-end">
                                <#if match.firstTeam??>
                                    ${match.firstTeam.name}
                                <#else>
                                    <span class="text-muted">-</span>
                                </#if>
                            </div>
                            <div class="col-2 text-center">
                                <#if match.winnerTeam?? && !match.firstTeam?? || match.winnerTeam?? && !match.secondTeam??>
                                    <span class="badge bg-info">Тех.победа</span>
                                <#elseif match.score1?? && match.score2??>
                                    <strong>${match.score1} : ${match.score2}</strong>
                                <#else>
                                    <span class="text-muted">- : -</span>
                                </#if>
                            </div>
                            <div class="col-5">
                                <#if match.secondTeam??>
                                    ${match.secondTeam.name}
                                <#else>
                                    <span class="text-muted">-</span>
                                </#if>
                            </div>
                        </div>
                        <#if (isOwner || isAdmin) && !match.winnerTeam??>
                            <form action="/competitions/${comp.id}/matches/${match.id}/result" method="post" class="mt-2">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <div class="row">
                                    <div class="col-auto">
                                        <input type="number" name="score1" class="form-control form-control-sm" style="width:60px" placeholder="0" required>
                                    </div>
                                    <div class="col-auto">:</div>
                                    <div class="col-auto">
                                        <input type="number" name="score2" class="form-control form-control-sm" style="width:60px" placeholder="0" required>
                                    </div>
                                    <div class="col-auto">
                                        <button type="submit" class="btn btn-primary btn-sm">Сохранить</button>
                                    </div>
                                </div>
                            </form>
                        <#elseif match.winnerTeam??>
                            <p class="mt-2"><strong>Победитель:</strong> ${match.winnerTeam.name}</p>
                        </#if>
                    </div>
                </div>
            </#list>
        </#list>
    </#if>
</@l.page>