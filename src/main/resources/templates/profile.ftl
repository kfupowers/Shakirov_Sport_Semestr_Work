<#import "/layout.ftl" as l>
<@l.page title="Профиль">
    <h2>Мой профиль</h2>
    <p>Логин: ${account.login}</p>
    <p>Имя: ${account.name} ${account.surname}</p>
    <p>Email: ${account.email}</p>

    <h3 class="mt-4">История участия в турнирах</h3>
    <#if participations?size gt 0>
        <table class="table">
            <thead>
            <tr>
                <th>Турнир</th>
                <th>Команда</th>
                <th>Статус</th>
                <th>Место</th>
            </tr>
            </thead>
            <tbody>
            <#list participations as p>
                <tr>
                    <td><a href="/competitions/${p.competition.id}">${p.competition.title}</a></td>
                    <td><a href="/teams/${p.team.id}">${p.team.name}</a></td>
                    <td>${p.competition.status}</td>
                    <td><#if p.place??>${p.place}<#else>-</#if></td>
                </tr>
            </#list>
            </tbody>
        </table>
    <#else>
        <p>Вы ещё не участвовали в турнирах.</p>
    </#if>
</@l.page>