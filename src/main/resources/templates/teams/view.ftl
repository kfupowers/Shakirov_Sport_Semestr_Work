<#import "/layout.ftl" as l>
<@l.page title="${team.name}">
    <h2>${team.name}</h2>
    <p>Капитан: ${team.captain.name} ${team.captain.surname}</p>
    <p>Статус: <#if team.active>Активна<#else>Неактивна</#if></p>

    <#if user.id == team.captain.id>
        <div class="mb-3">
            <form action="/teams/${team.id}/<#if team.active>deactivate<#else>activate</#if>" method="post" class="d-inline">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <button type="submit" class="btn btn-<#if team.active>warning<#else>success</#if> btn-sm">
                    <#if team.active>Сделать неактивной<#else>Активировать</#if>
                </button>
            </form>
        </div>
    </#if>

    <h4>Участники</h4>
    <ul id="membersList" class="list-group mb-3">
        <#list members as member>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                ${member.name} ${member.surname}
                <#if canModifyMembers && member.id != user.id>
                    <button class="btn btn-danger btn-sm remove-member" data-account-id="${member.id}">Удалить</button>
                </#if>
            </li>
        </#list>
    </ul>

    <#if canModifyMembers>
        <h5>Добавить участника</h5>
        <form id="addMemberForm" class="row g-2">
            <div class="col-auto">
                <input type="text" class="form-control" id="memberLogin" placeholder="Логин пользователя" required>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Добавить</button>
            </div>
        </form>
        <div id="addMemberMessage" class="mt-2"></div>
    </#if>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const teamId = ${team.id};
            const addForm = document.getElementById('addMemberForm');
            const memberInput = document.getElementById('memberLogin');
            const messageDiv = document.getElementById('addMemberMessage');

            if (addForm) {
                addForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    const login = memberInput.value.trim();
                    if (!login) return;
                    fetch('/api/teams/' + teamId + '/members', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            [document.querySelector('meta[name="_csrf_header"]').content]: document.querySelector('meta[name="_csrf"]').content
                        },
                        body: 'login=' + encodeURIComponent(login)
                    })
                        .then(response => {
                            if (response.ok) return response.text();
                            else throw new Error('Ошибка при добавлении');
                        })
                        .then(msg => {
                            messageDiv.innerHTML = '<div class="alert alert-success">' + msg + '</div>';
                            location.reload();
                        })
                        .catch(err => {
                            messageDiv.innerHTML = '<div class="alert alert-danger">' + err.message + '</div>';
                        });
                });
            }

            document.querySelectorAll('.remove-member').forEach(btn => {
                btn.addEventListener('click', function() {
                    const accountId = this.dataset.accountId;
                    if (confirm('Удалить участника?')) {
                        fetch('/api/teams/' + teamId + '/members/' + accountId, {
                            method: 'DELETE',
                            headers: {
                                [document.querySelector('meta[name="_csrf_header"]').content]: document.querySelector('meta[name="_csrf"]').content
                            }
                        })
                            .then(response => {
                                if (response.ok) location.reload();
                                else alert('Ошибка удаления');
                            });
                    }
                });
            });
        });
    </script>
</@l.page>