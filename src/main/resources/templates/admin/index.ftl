<#import "/layout.ftl" as l>
<@l.page title="Админ-панель">
    <h2>Админ-панель</h2>
    <div class="list-group">
        <a href="/admin/grant" class="list-group-item list-group-item-action">Выдать роль организатора</a>
        <a href="/admin/competitions" class="list-group-item list-group-item-action">Управление соревнованиями</a>
        <a href="/admin/requests" class="list-group-item list-group-item-action">Управление заявками</a>
    </div>
</@l.page>