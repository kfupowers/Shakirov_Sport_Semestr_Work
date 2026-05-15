<#import "/layout.ftl" as l>
<@l.page title="Управление заявками">
    <h2>Все заявки на поиск</h2>
    <table class="table">
        <thead>
        <tr><th>ID</th><th>Автор</th><th>Дисциплина</th><th>Статус</th><th></th></tr>
        </thead>
        <tbody>
        <#list requests as req>
            <tr>
                <td>${req.id}</td>
                <td>${req.author.login}</td>
                <td>${req.discipline.name}</td>
                <td>${req.status}</td>
                <td>
                    <form action="/admin/requests/${req.id}/delete" method="post" onsubmit="return confirm('Удалить заявку?');">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="btn btn-danger btn-sm">Удалить</button>
                    </form>
                </td>
            </tr>
        </#list>
        </tbody>
    </table>
</@l.page>