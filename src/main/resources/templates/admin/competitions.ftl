<#import "/layout.ftl" as l>
<@l.page title="Управление соревнованиями">
    <h2>Все соревнования</h2>
    <table class="table">
        <thead>
        <tr><th>ID</th><th>Название</th><th>Статус</th><th></th></tr>
        </thead>
        <tbody>
        <#list competitions as comp>
            <tr>
                <td>${comp.id}</td>
                <td>${comp.title}</td>
                <td>${comp.status}</td>
                <td>
                    <form action="/admin/competitions/${comp.id}/delete" method="post" onsubmit="return confirm('Удалить соревнование?');">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-danger btn-sm">Удалить</button>
                    </form>
                </td>
            </tr>
        </#list>
        </tbody>
    </table>
</@l.page>