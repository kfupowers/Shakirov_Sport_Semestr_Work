<#import "/layout.ftl" as l>
<@l.page title="Новая заявка">
    <h2>Создать заявку на поиск команды/игрока</h2>
    <form action="/players/new" method="post">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        <div class="mb-3">
            <label for="disciplineId" class="form-label">Дисциплина</label>
            <select name="disciplineId" class="form-select" required>
                <option value="">-- Выберите дисциплину --</option>
                <#list disciplines as d>
                    <option value="${d.id}">${d.name}</option>
                </#list>
            </select>
        </div>
        <div class="mb-3">
            <label for="description" class="form-label">Описание (о себе, уровень игры и т.п.)</label>
            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
        </div>
        <div class="mb-3">
            <label for="contact" class="form-label">Контакт (Telegram, Discord, email)</label>
            <input type="text" class="form-control" id="contact" name="contact" placeholder="Например: @username">
        </div>
        <button type="submit" class="btn btn-primary">Опубликовать</button>
        <a href="/players/my-requests" class="btn btn-secondary">Отмена</a>
    </form>
</@l.page>